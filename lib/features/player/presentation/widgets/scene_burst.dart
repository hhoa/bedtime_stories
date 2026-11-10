import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/particle_paint.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

/// Asks [SceneBurst] to play [burst] at [center]. A new object each time, so
/// the same burst twice still plays twice.
final class BurstEvent {
  const BurstEvent({required this.burst, required this.center});

  final Burst burst;

  /// Fractions (0–1) of the picture.
  final CanvasPoint center;
}

/// One-shot sparkles or hearts over a flat picture (hotspot tap or narration
/// cue). Never takes taps; plays nothing when the device asks for reduced
/// motion.
///
/// All bursts are drawn by one [BurstPainter]; the ticker runs only while a
/// burst is playing.
class SceneBurst extends StatefulWidget {
  const SceneBurst({required this.events, super.key});

  final ValueListenable<BurstEvent?> events;

  @override
  State<SceneBurst> createState() => _SceneBurstState();
}

class _SceneBurstState extends State<SceneBurst>
    with SingleTickerProviderStateMixin {
  final _active = <ActiveBurst>[];

  /// Seconds on the ticker; resets each time it starts from idle.
  final _now = ValueNotifier<double>(0);
  late final Ticker _ticker;
  var _seq = 0;
  late final _painter = BurstPainter(_active, _now);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    widget.events.addListener(_onEvent);
  }

  @override
  void didUpdateWidget(SceneBurst old) {
    super.didUpdateWidget(old);
    if (old.events != widget.events) {
      old.events.removeListener(_onEvent);
      widget.events.addListener(_onEvent);
    }
  }

  void _onEvent() {
    final e = widget.events.value;
    if (e == null || MediaQuery.disableAnimationsOf(context)) return;
    if (!_ticker.isActive) {
      _now.value = 0;
      _ticker.start();
    }
    _active.add(ActiveBurst(e, start: _now.value, seed: _seq++));
  }

  void _tick(Duration elapsed) {
    final now = secs(elapsed);
    final dur = secs(AppConstants.burstDuration);
    _active.removeWhere((b) => now - b.start >= dur);
    if (_active.isEmpty) _ticker.stop();
    _now.value = now;
  }

  @override
  void dispose() {
    widget.events.removeListener(_onEvent);
    _ticker.dispose();
    _now.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(size: Size.infinite, painter: _painter),
    ),
  );
}

/// One particle of a burst: [angle] (sparkles) or sideways spread (hearts),
/// [reach] as a fraction of the picture's short side, [size] in pixels.
typedef BurstBit = ({double angle, double reach, double size});

/// A burst that is playing, with its particles fixed at the start.
final class ActiveBurst {
  ActiveBurst(this.event, {required this.start, required int seed})
    : bits = _make(event.burst, Random(seed));

  final BurstEvent event;

  /// Ticker seconds when it began.
  final double start;
  final List<BurstBit> bits;

  static List<BurstBit> _make(Burst burst, Random rnd) => switch (burst) {
    Burst.sparkles => List.generate(AppConstants.burstSparkleCount, (i) {
      const n = AppConstants.burstSparkleCount;
      return (
        angle: 2 * pi * i / n + rnd.nextDouble() * 0.4,
        reach: 0.10 + rnd.nextDouble() * 0.08,
        size: 7.0 + rnd.nextDouble() * 7,
      );
    }),
    Burst.hearts => List.generate(AppConstants.burstHeartCount, (i) {
      final size = 18.0 + rnd.nextDouble() * 14;
      return (angle: 0.0, reach: 0.16 + rnd.nextDouble() * 0.1, size: size);
    }),
  };
}

/// Draws every playing burst.
class BurstPainter extends CustomPainter {
  BurstPainter(this.active, this.now) : super(repaint: now);

  final List<ActiveBurst> active;
  final ValueListenable<double> now;

  /// Kinds playing now (for tests).
  Iterable<Burst> get showing => active.map((b) => b.event.burst);

  static final _sparkle = GlowDot(AppColors.amber, glow: 0.8);
  static final _amberFlash = GlowDisc(AppColors.amber);
  static final _pinkFlash = GlowDisc(AppColors.pink);
  final _heartPaint = Paint()..isAntiAlias = true;

  /// Heart filling a 1×1 box centred on 0,0 (like the old icon glyph).
  static final Path _unitHeart = () {
    Path half(double s) => Path()
      ..moveTo(0, 0.36)
      ..cubicTo(s * 0.2, 0.2, s * 0.46, 0.04, s * 0.46, -0.14)
      ..cubicTo(s * 0.46, -0.3, s * 0.34, -0.4, s * 0.22, -0.4)
      ..cubicTo(s * 0.11, -0.4, s * 0.04, -0.34, 0, -0.26)
      ..close();
    return Path.combine(PathOperation.union, half(-1), half(1));
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final dur = secs(AppConstants.burstDuration);
    final reach = size.shortestSide;
    for (final b in active) {
      final t = ((now.value - b.start) / dur).clamp(0.0, 1.0);
      final c = Offset(
        size.width * b.event.center.x,
        size.height * b.event.center.y,
      );
      switch (b.event.burst) {
        case Burst.sparkles:
          _flash(canvas, _amberFlash, c, reach * 0.16, 1.2, t);
          final out = Curves.easeOutCubic.transform(span(t, 0, 0.8));
          final grow = t < 0.3
              ? lerpDouble(0.4, 1.1, span(t, 0, 0.3))!
              : 1.1 * lerpDouble(1, 0.4, span(t, 0.3, 0.5))!;
          final opacity = 1 - span(t, 0.65, 0.35);
          for (final bit in b.bits) {
            final p =
                c +
                Offset(cos(bit.angle), sin(bit.angle)) *
                    reach *
                    bit.reach *
                    out;
            _sparkle.paint(canvas, p, bit.size / 2 * grow, opacity);
          }
        case Burst.hearts:
          _flash(canvas, _pinkFlash, c, reach * 0.14, 1.1, t);
          final n = b.bits.length;
          for (var i = 0; i < n; i++) {
            final bit = b.bits[i];
            final start = 0.08 * i;
            final rise = Curves.easeOut.transform(span(t, start, 0.75));
            final opacity = 1 - span(t, start + 0.4, 0.35);
            if (opacity <= 0) continue;
            final dx = (i / (n - 1) - 0.5) * reach * 0.22;
            final s = bit.size * lerpDouble(0.3, 1, span(t, start, 0.25))!;
            canvas
              ..save()
              ..translate(c.dx + dx * rise, c.dy - reach * bit.reach * rise)
              ..scale(s)
              ..drawPath(
                _unitHeart,
                _heartPaint..color = AppColors.pink.withValues(alpha: opacity),
              )
              ..restore();
          }
      }
    }
  }

  /// Soft light behind the particles, so the tap point lights up.
  void _flash(
    Canvas canvas,
    GlowDisc disc,
    Offset c,
    double radius,
    double maxScale,
    double t,
  ) => disc.paint(
    canvas,
    c,
    radius * lerpDouble(0.3, maxScale, span(t, 0, 0.5))!,
    1 - span(t, 0.2, 0.6),
  );

  @override
  bool shouldRepaint(BurstPainter old) =>
      old.active != active || old.now != now;
}
