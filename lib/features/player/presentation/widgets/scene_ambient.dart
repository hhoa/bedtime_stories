import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/core/widgets/twinkle_field.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/particle_paint.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

/// Calm looping effect drawn over a scene picture. Never takes taps, and
/// draws nothing when the device asks for reduced motion.
///
/// Each effect is one painter on one ticker (see [ParticleLoop]).
class SceneAmbient extends StatelessWidget {
  const SceneAmbient({
    required this.ambient,
    required this.seed,
    this.origin,
    super.key,
  });

  final Ambient ambient;

  /// Fixed per picture, so particles stay put across rebuilds.
  final int seed;
  final AmbientOrigin? origin;

  @override
  Widget build(BuildContext context) {
    if (ambient == Ambient.none || MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: switch (ambient) {
        Ambient.none => const SizedBox.shrink(),
        Ambient.stars => TwinkleField(
          count: AppConstants.ambientStarCount,
          seed: seed,
          heightFactor: 0.45,
          minOpacity: 0.05,
          maxOpacity: 0.7,
          minSize: 5,
          maxSize: 12,
        ),
        Ambient.sparkles => ParticleLoop(
          painter: (clock) => _SparklePainter(clock, seed),
        ),
        Ambient.zzz => _Zzz(origin: origin ?? (x: 0.6, y: 0.4)),
        Ambient.motes => ParticleLoop(
          painter: (clock) => _MotePainter(clock, seed),
        ),
      },
    );
  }
}

/// One looping particle. [x]/[y] are fractions of the free area, times in
/// seconds, [dx]/[dy] the drift in logical pixels.
typedef _Particle = ({
  double x,
  double y,
  double size,
  double delay,
  double period,
  double dx,
  double dy,
});

/// Amber dots rising slowly and fading (Lulu's magic).
class _SparklePainter extends CustomPainter {
  _SparklePainter(this.clock, int seed)
    : _dots = _make(seed),
      super(repaint: clock);

  final ValueListenable<double> clock;
  final List<_Particle> _dots;
  static final _glow = GlowDot(AppColors.amber);

  static List<_Particle> _make(int seed) {
    final rnd = Random(seed);
    final total = secs(AppConstants.sparkleDuration);
    const n = AppConstants.ambientSparkleCount;
    return List.generate(n, (i) {
      final size = 6.0 + rnd.nextDouble() * 6;
      final period = total * (0.8 + rnd.nextDouble() * 0.4);
      return (
        x: rnd.nextDouble(),
        y: 0.35 + rnd.nextDouble() * 0.5,
        size: size,
        delay: total * (i / n),
        period: period,
        dx: 0.0,
        dy: 0.0,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final now = clock.value;
    for (final d in _dots) {
      final t = loopT(now, d.delay, d.period);
      final opacity = span(t, 0, 0.3) * (1 - span(t, 0.6, 0.4));
      final center = Offset(
        d.x * (size.width - d.size) + d.size / 2,
        d.y * size.height - size.height * 0.25 * t + d.size / 2,
      );
      _glow.paint(
        canvas,
        center,
        d.size / 2 * lerpDouble(0.6, 1.1, t)!,
        opacity,
      );
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.clock != clock;
}

/// Faint dust specks drifting in morning light.
class _MotePainter extends CustomPainter {
  _MotePainter(this.clock, int seed)
    : _dots = _make(seed),
      super(repaint: clock);

  final ValueListenable<double> clock;
  final List<_Particle> _dots;
  final _paint = Paint()..isAntiAlias = true;

  static List<_Particle> _make(int seed) {
    final rnd = Random(seed);
    final total = secs(AppConstants.moteDuration);
    return List.generate(AppConstants.ambientMoteCount, (_) {
      final size = 3.0 + rnd.nextDouble() * 4;
      final period = total * (0.7 + rnd.nextDouble() * 0.6);
      final dx = (rnd.nextDouble() - 0.5) * 80;
      final dy = (rnd.nextDouble() - 0.5) * 40;
      return (
        x: rnd.nextDouble(),
        y: rnd.nextDouble() * 0.7,
        size: size,
        period: period,
        dx: dx,
        dy: dy,
        delay: total * rnd.nextDouble() * 0.5,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final now = clock.value;
    for (final d in _dots) {
      final t = loopT(now, d.delay, d.period, reverse: true);
      final e = Curves.easeInOut.transform(t);
      final center = Offset(
        d.x * (size.width - d.size) + d.dx * e + d.size / 2,
        d.y * size.height + d.dy * e + d.size / 2,
      );
      _paint.color = AppColors.cream.withValues(
        alpha: lerpDouble(0.15, 0.6, t)!,
      );
      canvas.drawCircle(center, d.size / 2, _paint);
    }
  }

  @override
  bool shouldRepaint(_MotePainter old) => old.clock != clock;
}

/// "z" letters floating up and right from a sleeping head. Owns the laid-out
/// letter so it is shaped once, not every frame.
class _Zzz extends StatefulWidget {
  const _Zzz({required this.origin});

  final AmbientOrigin origin;

  @override
  State<_Zzz> createState() => _ZzzState();
}

class _ZzzState extends State<_Zzz> {
  TextPainter? _letter;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _letter?.dispose();
    _letter = TextPainter(
      text: TextSpan(
        text: 'z',
        style: AppText.kidLabel.copyWith(color: AppColors.lavender),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
  }

  @override
  void dispose() {
    _letter?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ParticleLoop(
    painter: (clock) => _ZzzPainter(clock, widget.origin, _letter!),
  );
}

class _ZzzPainter extends CustomPainter {
  _ZzzPainter(this.clock, this.origin, this.letter) : super(repaint: clock);

  final ValueListenable<double> clock;
  final AmbientOrigin origin;
  final TextPainter letter;
  final _fade = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final now = clock.value;
    final dur = secs(AppConstants.zzzDuration);
    const n = AppConstants.ambientZzzCount;
    final half = Offset(letter.width / 2, letter.height / 2);
    final box = Rect.fromCenter(
      center: Offset.zero,
      width: letter.width,
      height: letter.height,
    );
    for (var i = 0; i < n; i++) {
      final t = loopT(now, dur * (i / n), dur);
      final opacity = span(t, 0, 0.25) * (1 - span(t, 0.55, 0.45));
      if (opacity <= 0) continue;
      final e = Curves.easeOut.transform(t);
      final scale = lerpDouble(0.6, 1.5, t)!;
      // Text has no per-draw opacity: fade through a small layer (3 letters).
      canvas
        ..save()
        ..translate(
          size.width * (origin.x + 0.08 * e) + half.dx,
          size.height * (origin.y - 0.2 * e) + half.dy,
        )
        ..scale(scale)
        ..saveLayer(box, _fade..color = Color.fromRGBO(0, 0, 0, opacity));
      letter.paint(canvas, -half);
      canvas
        ..restore()
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ZzzPainter old) =>
      old.clock != clock || old.origin != origin || old.letter != letter;
}
