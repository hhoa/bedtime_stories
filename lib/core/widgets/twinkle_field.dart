import 'dart:math';

import 'package:flutter/material.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';

/// Softly twinkling stars scattered over the top [heightFactor] of the box.
///
/// One ticker and one painter for all stars, behind its own repaint boundary,
/// so the twinkle never repaints the content drawn on top (cheap on web).
class TwinkleField extends StatefulWidget {
  const TwinkleField({
    required this.count,
    this.seed = 7,
    this.heightFactor = 1,
    this.minOpacity = 0.2,
    this.maxOpacity = 0.9,
    this.minSize = 6,
    this.maxSize = 16,
    super.key,
  });

  final int count;

  /// Fixed seed: stars stay put across rebuilds.
  final int seed;
  final double heightFactor;
  final double minOpacity;
  final double maxOpacity;
  final double minSize;
  final double maxSize;

  @override
  State<TwinkleField> createState() => _TwinkleFieldState();
}

class _TwinkleFieldState extends State<TwinkleField>
    with SingleTickerProviderStateMixin {
  /// One full fade in + fade out.
  static final _period = AppConstants.twinkleDuration * 2;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _period,
  );
  late List<_Star> _stars = _makeStars();

  List<_Star> _makeStars() {
    final rnd = Random(widget.seed);
    return List<_Star>.generate(widget.count, (i) {
      final size =
          widget.minSize + rnd.nextDouble() * (widget.maxSize - widget.minSize);
      final offset = rnd.nextInt(2000) / _period.inMilliseconds;
      return _Star(
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        size: size,
        phase: offset,
        color: i % 5 == 0 ? AppColors.amber : AppColors.cream,
      );
    });
  }

  @override
  void didUpdateWidget(TwinkleField old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count ||
        old.seed != widget.seed ||
        old.minSize != widget.minSize ||
        old.maxSize != widget.maxSize) {
      _stars = _makeStars();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _StarPainter(
            stars: _stars,
            progress: _controller,
            heightFactor: widget.heightFactor,
            minOpacity: widget.minOpacity,
            maxOpacity: widget.maxOpacity,
          ),
        ),
      ),
    );
  }
}

class _Star {
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.color,
  });

  /// Position as 0–1 fractions of the free area.
  final double x;
  final double y;
  final double size;

  /// Start offset as a fraction of the period, so stars don't pulse together.
  final double phase;
  final Color color;
}

class _StarPainter extends CustomPainter {
  _StarPainter({
    required this.stars,
    required this.progress,
    required this.heightFactor,
    required this.minOpacity,
    required this.maxOpacity,
  }) : super(repaint: progress);

  final List<_Star> stars;
  final Animation<double> progress;
  final double heightFactor;
  final double minOpacity;
  final double maxOpacity;

  /// Unit five-point star centered on 0,0 (radius 0.5).
  static final Path _unitStar = () {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? 0.5 : 0.22;
      final a = -pi / 2 + i * pi / 5;
      final p = Offset(cos(a) * r, sin(a) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final rounding = Paint()
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 0.12
      ..isAntiAlias = true;
    for (final star in stars) {
      // Triangle wave 0→1→0 over the period, eased like the old fade.
      final t = (progress.value + star.phase) % 1 * 2;
      final x = Curves.easeInOut.transform(t < 1 ? t : 2 - t);
      final color = star.color.withValues(
        alpha: minOpacity + (maxOpacity - minOpacity) * x,
      );
      final left = star.x * (size.width - star.size);
      final top = star.y * (size.height * heightFactor - star.size);
      // Icon glyph had padding; star body is ~80% of the box.
      final scale = star.size * 0.85;
      canvas
        ..save()
        ..translate(left + star.size / 2, top + star.size / 2)
        ..scale(scale);
      canvas
        ..drawPath(_unitStar, paint..color = color)
        ..drawPath(_unitStar, rounding..color = color)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.stars != stars ||
      old.heightFactor != heightFactor ||
      old.minOpacity != minOpacity ||
      old.maxOpacity != maxOpacity;
}
