import 'dart:async';
import 'dart:developer';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:web/web.dart' as web;

import 'package:bedtime_stories/core/services/narrator.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';

/// Web narrator built on the Web Audio API.
///
/// iOS Safari only lets a page start sound right after a tap, and loading a
/// clip over the network first breaks that. Here one shared [web.AudioContext]
/// is unlocked by the first tap anywhere, and clips are fetched and decoded
/// ahead of time ([preload]), so playback can start at any moment with no
/// network wait.
final class WebAudioNarrator implements Narrator {
  WebAudioNarrator() {
    _ensureContext();
  }

  /// Bumped by every play and stop. A call that sees a newer value
  /// after an await was superseded and must not start playback.
  int _gen = 0;
  web.AudioBufferSourceNode? _source;
  Completer<void>? _ended;

  static const _loadTimeout = Duration(seconds: 5);
  static const _endSlack = Duration(seconds: 2);
  static final _keepDir = AppConstants.uiAudioDir;

  // Shared by every narrator: one context, one decoded-clip cache.
  static web.AudioContext? _ctx;
  static final _buffers = <String, Future<web.AudioBuffer>>{};
  static web.EventListener? _unlockListener;
  static const _unlockEvents = ['touchend', 'pointerup', 'click', 'keydown'];

  static web.AudioContext _ensureContext() {
    final existing = _ctx;
    if (existing != null && existing.state != 'closed') return existing;
    // Buffers decoded by a closed context are dropped with it.
    if (existing != null) _buffers.clear();
    _usePlaybackSession();
    final ctx = web.AudioContext();
    _ctx = ctx;
    _installUnlock();
    return ctx;
  }

  /// Safari 16.4+: play even when the iPhone's silent switch is on, like an
  /// `<audio>` element does. Ignored where unsupported.
  static void _usePlaybackSession() {
    try {
      final session = web.window.navigator.getProperty<JSObject?>(
        'audioSession'.toJS,
      );
      session?.setProperty('type'.toJS, 'playback'.toJS);
    } catch (e) {
      log('audioSession not set: $e', name: 'WebAudioNarrator');
    }
  }

  /// Resumes the context on every tap or key press while it isn't running,
  /// and plays one silent sample (what iOS needs to really unlock output).
  /// Stays installed for good: iOS can suspend or interrupt the context at
  /// any time (lock screen, other audio, memory), and only a tap brings it
  /// back.
  static void _installUnlock() {
    if (_unlockListener != null) return;
    void unlock(web.Event _) {
      final ctx = _ctx;
      if (ctx == null || ctx.state == 'running') return;
      try {
        if (ctx.state == 'closed') {
          _ensureContext();
          return;
        }
        ctx.resume();
        final silent = ctx.createBufferSource()
          ..buffer = ctx.createBuffer(1, 1, ctx.sampleRate);
        silent.connect(ctx.destination);
        silent.start();
      } catch (e) {
        log('unlock failed: $e', name: 'WebAudioNarrator');
      }
    }

    final listener = unlock.toJS;
    _unlockListener = listener;
    for (final type in _unlockEvents) {
      web.document.addEventListener(type, listener);
    }
  }

  /// Fetches and decodes [url] once; later calls share the result. A failed
  /// load is forgotten so it can be retried.
  static Future<web.AudioBuffer> _buffer(String url) {
    return _buffers.putIfAbsent(url, () async {
      try {
        final response = await web.window.fetch(url.toJS).toDart;
        if (!response.ok) {
          throw StateError('HTTP ${response.status} for $url');
        }
        final bytes = await response.arrayBuffer().toDart;
        return await _ensureContext().decodeAudioData(bytes).toDart;
      } catch (_) {
        unawaited(_buffers.remove(url));
        rethrow;
      }
    });
  }

  static String _assetUrl(String assetPath) =>
      ui_web.assetManager.getAssetUrl(assetPath);

  @override
  Future<void> preload(List<String> assetPaths) async {
    await Future.wait([
      for (final path in assetPaths)
        _buffer(path.startsWith('data:') ? path : _assetUrl(path)).then<void>(
          (_) {},
          onError: (Object e) =>
              log('preload failed for $path: $e', name: 'WebAudioNarrator'),
        ),
    ]);
  }

  @override
  Future<bool> play(
    String assetPath, {
    void Function(Duration? duration)? onStart,
  }) => _run(assetPath, _assetUrl(assetPath), onStart);

  /// On web the name recording is a `data:` URI.
  @override
  Future<bool> playFile(String path) => _run(path, path);

  Future<bool> _run(
    String label,
    String url, [
    void Function(Duration? duration)? onStart,
  ]) async {
    _stopSource();
    final gen = ++_gen;
    try {
      final buffer = await _buffer(url).timeout(_loadTimeout);
      if (gen != _gen) return false;
      final ctx = _ensureContext();
      if (ctx.state != 'running') {
        await ctx.resume().toDart.timeout(const Duration(milliseconds: 500));
        if (gen != _gen) return false;
        if (ctx.state != 'running') {
          log('audio still locked, skipping $label', name: 'WebAudioNarrator');
          return false;
        }
      }
      final ended = Completer<void>();
      final source = ctx.createBufferSource()..buffer = buffer;
      source.connect(ctx.destination);
      source.onended = ((web.Event _) {
        if (!ended.isCompleted) ended.complete();
      }).toJS;
      _source = source;
      _ended = ended;
      onStart?.call(
        Duration(microseconds: (buffer.duration * 1000000).round()),
      );
      source.start();
      // If iOS interrupts the context mid-clip, `ended` never fires; don't
      // let the story wait on it forever.
      await ended.future.timeout(
        Duration(microseconds: (buffer.duration * 1000000).round()) + _endSlack,
        onTimeout: () =>
            log('clip never ended: $label', name: 'WebAudioNarrator'),
      );
      return true;
    } catch (e) {
      log('play failed for $label: $e', name: 'WebAudioNarrator');
      return false;
    }
  }

  void _stopSource() {
    final source = _source;
    _source = null;
    if (source != null) {
      try {
        source.onended = null;
        source.stop();
        source.disconnect();
      } catch (_) {
        // Already stopped.
      }
    }
    final ended = _ended;
    _ended = null;
    if (ended != null && !ended.isCompleted) ended.complete();
  }

  @override
  Future<void> stop() async {
    _gen++;
    _stopSource();
  }

  /// The context is shared, so only this narrator's sound stops. Decoded
  /// story clips are dropped (each story is tens of MB of raw audio, and iOS
  /// Safari cuts audio under memory pressure); shared UI lines stay.
  @override
  Future<void> dispose() async {
    await stop();
    _buffers.removeWhere((url, _) => !url.contains(_keepDir));
  }
}
