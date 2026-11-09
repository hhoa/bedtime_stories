import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/core/widgets/twinkle_field.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

/// Calm looping effect drawn over a scene picture. Never takes taps, and
/// draws nothing when the device asks for reduced motion.
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
      child: LayoutBuilder(
        builder: (context, box) {
          final size = box.biggest;
          return switch (ambient) {
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
            Ambient.sparkles => _Sparkles(size: size, seed: seed),
            Ambient.zzz => _Zzz(size: size, origin: origin ?? (x: 0.6, y: 0.4)),
            Ambient.motes => _Motes(size: size, seed: seed),
          };
        },
      ),
    );
  }
}

/// Amber dots rising slowly and fading (Lulu's magic).
class _Sparkles extends StatelessWidget {
  const _Sparkles({required this.size, required this.seed});

  final Size size;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final rnd = Random(seed);
    const total = AppConstants.sparkleDuration;
    return Stack(
      children: List.generate(AppConstants.ambientSparkleCount, (i) {
        final dot = 6.0 + rnd.nextDouble() * 6;
        final dur = total * (0.8 + rnd.nextDouble() * 0.4);
        return Positioned(
          left: rnd.nextDouble() * (size.width - dot),
          top: size.height * (0.35 + rnd.nextDouble() * 0.5),
          child: _Dot(size: dot, color: AppColors.amber, glow: true)
              .animate(
                delay: total * (i / AppConstants.ambientSparkleCount),
                onPlay: (c) => c.repeat(),
              )
              .moveY(end: -size.height * 0.25, duration: dur)
              .scaleXY(begin: 0.6, end: 1.1, duration: dur)
              .fadeIn(duration: dur * 0.3)
              .fadeOut(delay: dur * 0.6, duration: dur * 0.4),
        );
      }),
    );
  }
}

/// "z" letters floating up and right from a sleeping head.
class _Zzz extends StatelessWidget {
  const _Zzz({required this.size, required this.origin});

  final Size size;
  final AmbientOrigin origin;

  @override
  Widget build(BuildContext context) {
    const dur = AppConstants.zzzDuration;
    const n = AppConstants.ambientZzzCount;
    final letter = AppText.kidLabel.copyWith(color: AppColors.lavender);
    return Stack(
      children: List.generate(n, (i) {
        return Positioned(
          left: size.width * origin.x,
          top: size.height * origin.y,
          child: Text('z', style: letter)
              .animate(delay: dur * (i / n), onPlay: (c) => c.repeat())
              .move(
                end: Offset(size.width * 0.08, -size.height * 0.2),
                duration: dur,
                curve: Curves.easeOut,
              )
              .scaleXY(begin: 0.6, end: 1.5, duration: dur)
              .fadeIn(duration: dur * 0.25)
              .fadeOut(delay: dur * 0.55, duration: dur * 0.45),
        );
      }),
    );
  }
}

/// Faint dust specks drifting in morning light.
class _Motes extends StatelessWidget {
  const _Motes({required this.size, required this.seed});

  final Size size;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final rnd = Random(seed);
    const total = AppConstants.moteDuration;
    return Stack(
      children: List.generate(AppConstants.ambientMoteCount, (i) {
        final dot = 3.0 + rnd.nextDouble() * 4;
        final dur = total * (0.7 + rnd.nextDouble() * 0.6);
        final dx = (rnd.nextDouble() - 0.5) * 80;
        final dy = (rnd.nextDouble() - 0.5) * 40;
        return Positioned(
          left: rnd.nextDouble() * (size.width - dot),
          top: rnd.nextDouble() * (size.height * 0.7),
          child: _Dot(size: dot, color: AppColors.cream)
              .animate(
                delay: total * (rnd.nextDouble() * 0.5),
                onPlay: (c) => c.repeat(reverse: true),
              )
              .move(end: Offset(dx, dy), duration: dur, curve: Curves.easeInOut)
              .fade(begin: 0.15, end: 0.6, duration: dur),
        );
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.color, this.glow = false});

  final double size;
  final Color color;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.7),
                  blurRadius: size * 1.5,
                ),
              ]
            : null,
      ),
    );
  }
}
