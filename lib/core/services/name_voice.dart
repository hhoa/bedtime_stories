import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bedtime_stories/core/services/mic_permission_stub.dart'
    if (dart.library.js_interop) 'package:bedtime_stories/core/services/mic_permission_web.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/core/utils/wav_gain.dart';

/// Mic permission before recording.
enum MicStatus {
  /// Recording starts straight away.
  granted,

  /// The system / browser will ask (or we can't tell): explain first.
  ask,

  /// Refused for good: only Settings can turn it back on.
  blocked,
}

/// A parent's recording of the child's name, spliced into narration
/// wherever the story says `{name}`.
abstract interface class NameVoice {
  /// Where to play the saved recording from, or null when there is none.
  /// A file path on device, a `data:` URI on web (see [Narrator.playFile]).
  Future<String?> recordingPath();

  /// Current permission, without asking.
  Future<MicStatus> micStatus();

  /// Asks for mic permission if needed. False when denied or failed.
  Future<bool> startRecording();

  /// Saves the take, replacing any earlier one. False when nothing usable.
  Future<bool> stopRecording();

  Future<void> cancelRecording();

  Future<void> deleteRecording();

  /// Opens the system Settings page for this app so the parent can turn the
  /// mic on. False on web: a page can't open the browser's settings.
  Future<bool> openMicSettings();

  Future<void> dispose();
}

/// Records 16 kHz mono WAV. When saved, the silence before and after the
/// name is cut ([trimWav]) and it is boosted ([normalizeWav]), since phone
/// mics pick up a spoken name much quieter than the narration clips.
/// Device: saves `child_name.wav` in the documents folder.
/// Web: the recorder only gives a blob URL that dies on reload, so the take
/// is kept in prefs (localStorage) as a `data:` URI. A name is ~100 KB.
final class RecordNameVoice implements NameVoice {
  RecordNameVoice(this._prefs, {AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final SharedPreferences _prefs;
  final AudioRecorder _recorder;

  static const _fileName = 'child_name.wav';
  static const _takeName = 'child_name_take.wav';

  /// Before WAV + boost; still played until the parent records again.
  static const _legacyFileName = 'child_name.m4a';
  static const _webKey = 'child_name_voice_v1';

  // WAV is made by the plugin itself, so it works in every browser too.
  static const _config = RecordConfig(
    encoder: AudioEncoder.wav,
    sampleRate: AppConstants.nameSampleRate,
    numChannels: 1,
    autoGain: true,
  );

  // Resolve the folder each time: on iOS the app container path can change
  // between launches, so never persist an absolute path.
  Future<File> _file(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$name');
  }

  @override
  Future<String?> recordingPath() async {
    if (kIsWeb) return _prefs.getString(_webKey);
    try {
      for (final name in [_fileName, _legacyFileName]) {
        final file = await _file(name);
        if (await file.exists()) return file.path;
      }
      return null;
    } catch (e) {
      log('recordingPath failed: $e', name: 'RecordNameVoice');
      return null;
    }
  }

  @override
  Future<MicStatus> micStatus() async {
    try {
      if (kIsWeb) {
        return switch (await webMicState()) {
          'granted' => MicStatus.granted,
          'denied' => MicStatus.blocked,
          _ => MicStatus.ask,
        };
      }
      final status = await ph.Permission.microphone.status;
      if (status.isGranted || status.isLimited) return MicStatus.granted;
      // iOS reports "not asked yet" as denied; after a refusal it is
      // permanently denied. Android: denied = may ask again.
      if (status.isPermanentlyDenied || status.isRestricted) {
        return MicStatus.blocked;
      }
      return MicStatus.ask;
    } catch (e) {
      log('micStatus failed: $e', name: 'RecordNameVoice');
      return MicStatus.ask;
    }
  }

  @override
  Future<bool> startRecording() async {
    try {
      if (!await _recorder.hasPermission()) return false;
      final path = kIsWeb ? '' : (await _file(_takeName)).path; // '' on web
      await _recorder.start(_config, path: path);
      return true;
    } catch (e) {
      log('startRecording failed: $e', name: 'RecordNameVoice');
      return false;
    }
  }

  @override
  Future<bool> stopRecording() async {
    try {
      final path = await _recorder.stop();
      if (path == null) return false;
      return kIsWeb ? await _saveWebTake(path) : await _saveFileTake(path);
    } catch (e) {
      log('stopRecording failed: $e', name: 'RecordNameVoice');
      return false;
    }
  }

  Future<bool> _saveFileTake(String path) async {
    final take = File(path);
    if (!await take.exists()) return false;
    final bytes = await take.readAsBytes();
    if (bytes.isEmpty) return false;
    await (await _file(_fileName)).writeAsBytes(_boost(bytes), flush: true);
    await take.delete();
    await _deleteIfExists(_legacyFileName);
    return true;
  }

  /// [blobUrl] is only valid in this tab, so copy the bytes out.
  Future<bool> _saveWebTake(String blobUrl) async {
    final response = await http.get(Uri.parse(blobUrl));
    final bytes = response.bodyBytes;
    if (bytes.isEmpty) return false;
    return _prefs.setString(
      _webKey,
      'data:audio/wav;base64,${base64Encode(_boost(bytes))}',
    );
  }

  /// Trims the silence before and after the name, then makes it louder.
  Uint8List _boost(Uint8List wav) => normalizeWav(
    trimWav(wav),
    targetPeak: AppConstants.nameTargetPeak,
    maxGain: AppConstants.nameMaxGain,
  );

  Future<void> _deleteIfExists(String name) async {
    final file = await _file(name);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> cancelRecording() async {
    try {
      await _recorder.cancel();
    } catch (e) {
      log('cancelRecording failed: $e', name: 'RecordNameVoice');
    }
  }

  @override
  Future<void> deleteRecording() async {
    try {
      if (kIsWeb) {
        await _prefs.remove(_webKey);
        return;
      }
      await _deleteIfExists(_fileName);
      await _deleteIfExists(_legacyFileName);
    } catch (e) {
      log('deleteRecording failed: $e', name: 'RecordNameVoice');
    }
  }

  @override
  Future<bool> openMicSettings() async {
    if (kIsWeb) return false;
    try {
      return await ph.openAppSettings();
    } catch (e) {
      log('openMicSettings failed: $e', name: 'RecordNameVoice');
      return false;
    }
  }

  @override
  Future<void> dispose() => _recorder.dispose();
}
