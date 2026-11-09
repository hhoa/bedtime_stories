import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
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
class SceneBurst extends StatefulWidget {
  const SceneBurst({required this.events, super.key});

  final ValueListenable<BurstEvent?> events;

  @override
  State<SceneBurst> createState() => _SceneBurstState();
}

class _SceneBurstState extends State<SceneBurst> {
  final _active = <(int, BurstEvent)>[];
  final _timers = <Timer>[];
  var _seq = 0;

  @override
  void initState() {
    super.initState();
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
    final id = _seq++;
    setState(() => _active.add((id, e)));
    _timers.add(
      Timer(AppConstants.burstDuration, () {
        if (mounted) setState(() => _active.removeWhere((a) => a.$1 == id));
      }),
    );
  }

  @override
  void dispose() {
    widget.events.removeListener(_onEvent);
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_active.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, box) {
          final size = box.biggest;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (final (id, e) in _active)
                Positioned(
                  key: ValueKey(id),
                  left: size.width * e.center.x,
                  top: size.height * e.center.y,
                  child: switch (e.burst) {
                    Burst.sparkles => _Sparkles(size: size, seed: id),
                    Burst.hearts => _Hearts(size: size, seed: id),
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Soft round glow behind the particles, so the tap point lights up.
Widget _glow(double radius, Color color) => Transform.translate(
  offset: Offset(-radius, -radius),
  child: Container(
    width: radius * 2,
    height: radius * 2,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0)],
      ),
    ),
  ),
);

/// Amber dots flying out in a ring (Lulu's magic).
class _Sparkles extends StatelessWidget {
  const _Sparkles({required this.size, required this.seed});

  final Size size;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final rnd = Random(seed);
    const dur = AppConstants.burstDuration;
    const n = AppConstants.burstSparkleCount;
    final reach = size.shortestSide;
    final glowRadius = reach * 0.16;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _glow(glowRadius, AppColors.amber)
            .animate()
            .scaleXY(begin: 0.3, end: 1.2, duration: dur * 0.5)
            .fadeOut(delay: dur * 0.2, duration: dur * 0.6),
        for (var i = 0; i < n; i++)
          () {
            final angle = 2 * pi * i / n + rnd.nextDouble() * 0.4;
            final dist = reach * (0.10 + rnd.nextDouble() * 0.08);
            final dot = 7.0 + rnd.nextDouble() * 7;
            return Transform.translate(
              offset: Offset(-dot / 2, -dot / 2),
              child: _Dot(size: dot, color: AppColors.amber)
                  .animate()
                  .move(
                    end: Offset(cos(angle) * dist, sin(angle) * dist),
                    duration: dur * 0.8,
                    curve: Curves.easeOutCubic,
                  )
                  .scaleXY(begin: 0.4, end: 1.1, duration: dur * 0.3)
                  .then()
                  .scaleXY(end: 0.4, duration: dur * 0.5)
                  .fadeOut(delay: dur * 0.35, duration: dur * 0.45),
            );
          }(),
      ],
    );
  }
}

/// Small pink hearts floating up (a hug, a happy kid).
class _Hearts extends StatelessWidget {
  const _Hearts({required this.size, required this.seed});

  final Size size;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final rnd = Random(seed);
    const dur = AppConstants.burstDuration;
    const n = AppConstants.burstHeartCount;
    final reach = size.shortestSide;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _glow(reach * 0.14, AppColors.pink)
            .animate()
            .scaleXY(begin: 0.3, end: 1.1, duration: dur * 0.5)
            .fadeOut(delay: dur * 0.2, duration: dur * 0.6),
        for (var i = 0; i < n; i++)
          () {
            final heart = 18.0 + rnd.nextDouble() * 14;
            final dx = (i / (n - 1) - 0.5) * reach * 0.22;
            final rise = reach * (0.16 + rnd.nextDouble() * 0.1);
            return Transform.translate(
              offset: Offset(-heart / 2, -heart / 2),
              child: Icon(Icons.favorite, size: heart, color: AppColors.pink)
                  .animate(delay: dur * 0.08 * i)
                  .move(
                    end: Offset(dx, -rise),
                    duration: dur * 0.75,
                    curve: Curves.easeOut,
                  )
                  .scaleXY(begin: 0.3, end: 1, duration: dur * 0.25)
                  .fadeOut(delay: dur * 0.4, duration: dur * 0.35),
            );
          }(),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: size * 1.5),
      ],
    ),
  );
}
