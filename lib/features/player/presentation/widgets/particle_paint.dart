import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// [d] in seconds.
double secs(Duration d) => d.inMicroseconds / Duration.microsecondsPerSecond;

/// Progress 0–1 of a loop that waits [delay] seconds (holding its first
/// frame) and then repeats every [period] seconds; [reverse] plays every
/// other round backwards.
double loopT(double now, double delay, double period, {bool reverse = false}) {
  if (now < delay) return 0;
  final round = (now - delay) / period;
  final t = round - round.floorToDouble();
  return reverse && round.floor().isOdd ? 1 - t : t;
}

/// How far [t] is through the window starting at [start] and lasting
/// [length] (all fractions of one run), clamped to 0–1.
double span(double t, double start, double length) =>
    ((t - start) / length).clamp(0.0, 1.0);

/// Seconds since this widget appeared, for one [CustomPainter] that draws a
/// whole particle effect. One ticker and one paint per frame, instead of a
/// widget and an animation per particle.
class ParticleLoop extends StatefulWidget {
  const ParticleLoop({required this.painter, super.key});

  /// Builds the painter; it should repaint on the given clock.
  final CustomPainter Function(ValueListenable<double> seconds) painter;

  @override
  State<ParticleLoop> createState() => _ParticleLoopState();
}

class _ParticleLoopState extends State<ParticleLoop>
    with SingleTickerProviderStateMixin {
  final _seconds = ValueNotifier<double>(0);
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) => _seconds.value = secs(elapsed))
      ..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(size: Size.infinite, painter: widget.painter(_seconds)),
  );
}

/// A soft glowing dot: a solid core inside a halo that fades out. The halo
/// is a gradient, not a blur, so each dot costs two plain circles per frame.
final class GlowDot {
  GlowDot(this.color, {double glow = 0.7})
    : _core = Paint()..isAntiAlias = true,
      _halo = Paint()
        ..isAntiAlias = true
        // Unit circle; scaled per dot. Stops roughly follow the old
        // BoxShadow blur (a Gaussian fall-off).
        ..shader = ui.Gradient.radial(
          Offset.zero,
          1,
          [
            color.withValues(alpha: glow),
            color.withValues(alpha: glow * 0.55),
            color.withValues(alpha: glow * 0.18),
            color.withValues(alpha: 0),
          ],
          const [0, 0.3, 0.6, 1],
        );

  final Color color;
  final Paint _core;
  final Paint _halo;

  /// Halo reach as a multiple of the core radius.
  static const haloScale = 4.0;

  void paint(Canvas canvas, Offset center, double radius, double opacity) {
    if (opacity <= 0 || radius <= 0) return;
    // With a shader, the paint color only sets opacity.
    _halo.color = Color.fromRGBO(0, 0, 0, opacity);
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(radius * haloScale)
      ..drawCircle(Offset.zero, 1, _halo)
      ..restore()
      ..drawCircle(
        center,
        radius,
        _core..color = color.withValues(alpha: opacity),
      );
  }
}

/// A big soft round light (the flash behind a burst).
final class GlowDisc {
  GlowDisc(Color color, {double alpha = 0.55})
    : _paint = Paint()
        ..isAntiAlias = true
        ..shader = ui.Gradient.radial(Offset.zero, 1, [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0),
        ]);

  final Paint _paint;

  void paint(Canvas canvas, Offset center, double radius, double opacity) {
    if (opacity <= 0 || radius <= 0) return;
    _paint.color = Color.fromRGBO(0, 0, 0, opacity);
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(radius)
      ..drawCircle(Offset.zero, 1, _paint)
      ..restore();
  }
}
