import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:bedtime_stories/core/utils/wav_gain.dart';

Uint8List _wav(List<int> samples, {int bits = 16, int format = 1}) {
  final dataSize = samples.length * 2;
  final b = ByteData(44 + dataSize);
  void tag(int at, String s) {
    for (var i = 0; i < 4; i++) {
      b.setUint8(at + i, s.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  b.setUint32(4, 36 + dataSize, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  b.setUint32(16, 16, Endian.little);
  b.setUint16(20, format, Endian.little);
  b.setUint16(22, 1, Endian.little); // mono
  b.setUint32(24, 16000, Endian.little);
  b.setUint32(28, 32000, Endian.little);
  b.setUint16(32, 2, Endian.little);
  b.setUint16(34, bits, Endian.little);
  tag(36, 'data');
  b.setUint32(40, dataSize, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    b.setInt16(44 + i * 2, samples[i], Endian.little);
  }
  return b.buffer.asUint8List();
}

List<int> _samples(Uint8List wav) {
  final v = ByteData.sublistView(wav);
  return [
    for (var i = 44; i + 1 < wav.length; i += 2) v.getInt16(i, Endian.little),
  ];
}

void main() {
  test('boosts a quiet take so its peak reaches the target', () {
    final out = normalizeWav(_wav([0, 4000, -8000, 2000]), maxGain: 100);
    final peak = (0.9 * 32767).round();
    expect(_samples(out), [0, (peak / 2).round(), -peak, (peak / 4).round()]);
  });

  test('caps the boost at maxGain', () {
    final out = normalizeWav(_wav([100, -200]), maxGain: 8);
    expect(_samples(out), [800, -1600]);
  });

  test('leaves loud takes, silence and header untouched', () {
    final loud = _wav([30000, -31000]);
    expect(normalizeWav(loud), same(loud));
    final silent = _wav([0, 0]);
    expect(normalizeWav(silent), same(silent));
    final out = normalizeWav(_wav([1000]));
    expect(out.sublist(0, 44), _wav([1000]).sublist(0, 44));
  });

  test('returns anything that is not 16-bit PCM WAV unchanged', () {
    final bytes = [
      Uint8List.fromList([1, 2, 3]),
      _wav([100], bits: 8),
      _wav([100], format: 3),
      _wav([100]).sublist(0, 30),
    ];
    for (final b in bytes) {
      expect(normalizeWav(b), same(b));
    }
  });

  group('trimWav', () {
    // 16 kHz: 10 ms = 160 samples, the default 80 ms margin = 1280 samples.
    List<int> tone(int n) => [
      for (var i = 0; i < n; i++) i.isEven ? 8000 : -8000,
    ];
    List<int> quiet(int n) => List.filled(n, 20);

    test('cuts the silence around the name, keeping the margin', () {
      final wav = _wav([...quiet(8000), ...tone(3200), ...quiet(8000)]);
      final out = trimWav(wav);
      final samples = _samples(out);
      expect(samples.length, 3200 + 2 * 1280);
      expect(samples.sublist(1280, 1280 + 3200), tone(3200));
      final v = ByteData.sublistView(out);
      expect(v.getUint32(4, Endian.little), out.length - 8);
      expect(v.getUint32(40, Endian.little), samples.length * 2);
    });

    test('keeps a take that has no silence to cut', () {
      final wav = _wav(tone(3200));
      expect(trimWav(wav), same(wav));
    });

    test('returns silence, tiny takes and non-PCM16 unchanged', () {
      for (final b in [
        _wav(List.filled(3200, 0)),
        _wav(tone(100)),
        _wav(tone(3200), bits: 8),
        Uint8List.fromList([1, 2, 3]),
      ]) {
        expect(trimWav(b), same(b));
      }
    });
  });
}
