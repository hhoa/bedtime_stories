import 'package:flutter/material.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/widgets/twinkle_field.dart';

/// Deep-blue gradient with softly twinkling stars behind [child].
class NightSky extends StatelessWidget {
  const NightSky({
    required this.child,
    this.starCount = 28,
    this.dim = false,
    super.key,
  });

  final Widget child;
  final int starCount;

  /// Darker variant for the sleep screen.
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dim
              ? const [AppColors.sleepBg, AppColors.nightDeep]
              : const [AppColors.nightDeep, AppColors.night],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          TwinkleField(
            count: starCount,
            minOpacity: dim ? 0.05 : 0.2,
            maxOpacity: dim ? 0.4 : 0.9,
          ),
          child,
        ],
      ),
    );
  }
}
