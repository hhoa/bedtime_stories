import 'dart:math' as math;
import 'dart:typed_data';

/// Makes a 16-bit PCM WAV louder so its loudest sample reaches
/// [targetPeak] (0–1 of full scale), boosting by at most [maxGain].
///
/// Phone mics record a spoken name much quieter than the narration clips,
/// so the parent's recording is boosted once when saved. Anything that is
/// not a 16-bit PCM WAV, or already loud enough, comes back unchanged.
Uint8List normalizeWav(
  Uint8List wav, {
  double targetPeak = 0.9,
  double maxGain = 8,
}) {
  final data = _pcm16Data(wav);
  if (data == null) return wav;
  final (:start, :length, channels: _, sampleRate: _) = data;
  final view = ByteData.sublistView(wav);

  var peak = 0;
  for (var i = start; i + 1 < start + length; i += 2) {
    final s = view.getInt16(i, Endian.little).abs();
    if (s > peak) peak = s;
  }
  if (peak == 0) return wav;

  final gain = math.min(targetPeak * 32767 / peak, maxGain);
  if (gain <= 1) return wav;

  final out = Uint8List.fromList(wav);
  final outView = ByteData.sublistView(out);
  for (var i = start; i + 1 < start + length; i += 2) {
    final s = (view.getInt16(i, Endian.little) * gain).round();
    outView.setInt16(i, s.clamp(-32768, 32767), Endian.little);
  }
  return out;
}

/// Cuts the quiet lead-in and tail off a 16-bit PCM WAV, keeping [margin]
/// of room on each side so the first and last sounds are not clipped.
///
/// The parent taps record, waits, says the name, waits and taps stop; the
/// silence around the name would leave a gap in the middle of a sentence.
/// Speech starts at the first 10 ms frame louder than [threshold] × the
/// loudest frame (RMS), so a click or hiss stays out. Anything that is not
/// a 16-bit PCM WAV, or silent, comes back unchanged.
Uint8List trimWav(
  Uint8List wav, {
  double threshold = 0.08,
  Duration margin = const Duration(milliseconds: 80),
}) {
  final data = _pcm16Data(wav);
  if (data == null) return wav;
  final (:start, :length, :channels, :sampleRate) = data;
  final view = ByteData.sublistView(wav);
  final frameBytes = 2 * channels;
  final frameLen = math.max(sampleRate ~/ 100, 1) * frameBytes; // 10 ms
  final frames = length ~/ frameLen;
  if (frames < 3) return wav;

  final rms = List<double>.filled(frames, 0);
  for (var f = 0; f < frames; f++) {
    var sum = 0.0;
    final from = start + f * frameLen;
    for (var i = from; i < from + frameLen; i += 2) {
      final s = view.getInt16(i, Endian.little);
      sum += s * s;
    }
    rms[f] = math.sqrt(sum / (frameLen / 2));
  }
  final loudest = rms.reduce(math.max);
  if (loudest == 0) return wav;
  final first = rms.indexWhere((r) => r > loudest * threshold);
  final last = rms.lastIndexWhere((r) => r > loudest * threshold);

  final pad =
      (sampleRate * margin.inMicroseconds ~/ Duration.microsecondsPerSecond) *
      frameBytes;
  final cutFrom = math.max(first * frameLen - pad, 0);
  final cutTo = math.min((last + 1) * frameLen + pad, length);
  if (cutFrom == 0 && cutTo == length) return wav;

  // Header up to the data chunk, then only the kept samples.
  final kept = cutTo - cutFrom;
  final out = Uint8List(start + kept)
    ..setRange(0, start, wav)
    ..setRange(start, start + kept, wav, start + cutFrom);
  ByteData.sublistView(out)
    ..setUint32(4, out.length - 8, Endian.little)
    ..setUint32(start - 4, kept, Endian.little);
  return out;
}

/// Where the samples are and how they are laid out, or null when [wav] is
/// not a 16-bit PCM WAV.
({int start, int length, int channels, int sampleRate})? _pcm16Data(
  Uint8List wav,
) {
  if (wav.length < 12) return null;
  if (String.fromCharCodes(wav, 0, 4) != 'RIFF' ||
      String.fromCharCodes(wav, 8, 12) != 'WAVE') {
    return null;
  }
  final view = ByteData.sublistView(wav);
  var pcm16 = false;
  var channels = 1;
  var sampleRate = 0;
  var offset = 12;
  while (offset + 8 <= wav.length) {
    final id = String.fromCharCodes(wav, offset, offset + 4);
    final size = view.getUint32(offset + 4, Endian.little);
    final body = offset + 8;
    if (id == 'fmt ') {
      if (body + 16 > wav.length) return null;
      final format = view.getUint16(body, Endian.little);
      final bits = view.getUint16(body + 14, Endian.little);
      channels = math.max(view.getUint16(body + 2, Endian.little), 1);
      sampleRate = view.getUint32(body + 4, Endian.little);
      pcm16 = format == 1 && bits == 16 && sampleRate > 0;
    } else if (id == 'data') {
      if (!pcm16) return null;
      // Streaming writers may leave the size unset; use what is there.
      var length = math.min(size, wav.length - body);
      length -= length % (2 * channels);
      return (
        start: body,
        length: length,
        channels: channels,
        sampleRate: sampleRate,
      );
    }
    offset = body + size + (size.isOdd ? 1 : 0);
  }
  return null;
}
