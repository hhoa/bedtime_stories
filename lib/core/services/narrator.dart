import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'package:bedtime_stories/core/services/narrator_factory_stub.dart'
    if (dart.library.js_interop) 'package:bedtime_stories/core/services/narrator_factory_web.dart'
    as platform;

/// The narrator for this platform: Web Audio on web (preloaded clips, works
/// with iOS Safari's autoplay rules), just_audio elsewhere.
Narrator createNarrator() => platform.createPlatformNarrator();

/// Plays narration clips one at a time.
abstract interface class Narrator {
  /// Plays a bundled asset. Completes when the clip ends or is stopped.
  /// Returns false when the clip could not be played (missing file etc.).
  /// [onStart] gets the clip length right before playback begins.
  Future<bool> play(
    String assetPath, {
    void Function(Duration? duration)? onStart,
  });

  /// Plays the parent's recording of the child's name: a file path on
  /// device, a `data:` URI on web.
  Future<bool> playFile(String path);

  /// Fetches clips ahead of time so playback starts without a network wait.
  /// Best-effort: never throws.
  Future<void> preload(List<String> assetPaths);

  Future<void> stop();

  Future<void> dispose();
}

final class JustAudioNarrator implements Narrator {
  JustAudioNarrator({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  /// Bumped by every play and stop. A call that sees a newer value
  /// after an await was superseded and must not start playback.
  int _gen = 0;

  @override
  Future<bool> play(
    String assetPath, {
    void Function(Duration? duration)? onStart,
  }) => _run(assetPath, () => _player.setAsset(assetPath), onStart);

  @override
  Future<bool> playFile(String path) => _run(
    path,
    () => kIsWeb ? _player.setUrl(path) : _player.setFilePath(path),
  );

  Future<bool> _run(
    String label,
    Future<Duration?> Function() load, [
    void Function(Duration? duration)? onStart,
  ]) async {
    final gen = ++_gen;
    try {
      await _player.stop();
      if (gen != _gen) return false;
      final duration = await load();
      if (gen != _gen) return false;
      onStart?.call(duration);
      // Completes on end, pause or stop.
      await _player.play();
      return true;
    } catch (e) {
      log('play failed for $label: $e', name: 'JustAudioNarrator');
      return false;
    }
  }

  @override
  Future<void> preload(List<String> assetPaths) async {}

  @override
  Future<void> stop() async {
    _gen++;
    try {
      await _player.stop();
    } catch (e) {
      log('stop failed: $e', name: 'JustAudioNarrator');
    }
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}
