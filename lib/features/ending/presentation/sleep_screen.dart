import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:bedtime_stories/core/router/app_routes.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_spacing.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/core/widgets/night_sky.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/profile_cubit.dart';

/// Near-black calm screen; text slowly fades. Tap anywhere to go home.
class SleepScreen extends StatelessWidget {
  const SleepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sleepBg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go(AppRoutes.home),
        child: NightSky(
          dim: true,
          starCount: 40,
          child: Center(
            child:
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                          Icons.nightlight_round,
                          color: AppColors.amber,
                          size: 96,
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(
                          begin: 1,
                          end: 1.06,
                          duration: AppConstants.bobDuration * 2,
                        ),
                    const SizedBox(height: AppSpace.xl),
                    Text(
                      context.strings.goodnight(context.profile.name),
                      style: AppText.kidTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpace.md),
                    Text(
                      context.strings.tapToWake,
                      style: AppText.body.copyWith(color: AppColors.creamFaint),
                    ),
                  ],
                ).animate().fade(
                  begin: 1,
                  end: 0.25,
                  delay: 2.seconds,
                  duration: AppConstants.sleepFadeDuration,
                ),
          ),
        ),
      ),
    );
  }
}
