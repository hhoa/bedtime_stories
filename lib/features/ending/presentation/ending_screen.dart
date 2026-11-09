import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:bedtime_stories/core/router/app_routes.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_spacing.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/core/widgets/centered_scroll_view.dart';
import 'package:bedtime_stories/core/widgets/kid_buttons.dart';
import 'package:bedtime_stories/core/widgets/night_sky.dart';
import 'package:bedtime_stories/core/widgets/story_image.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

class EndingArgs {
  const EndingArgs({
    required this.story,
    required this.goodCount,
    required this.choiceCount,
  });

  final Story story;

  /// Choices whose first pick was kind = stickers earned this play.
  final int goodCount;
  final int choiceCount;
}

/// One sticker per good answer. No good answer: no sticker, a gentle nudge
/// to try another choice next time. The line is also read aloud
/// (`EndingCubit`).
class EndingScreen extends StatelessWidget {
  const EndingScreen({required this.args, super.key});

  final EndingArgs args;

  static const _stickerSize = 160.0;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final sticker = args.story.stickerAsset;
    final count = sticker == null ? 0 : args.goodCount;
    return Scaffold(
      body: NightSky(
        child: SafeArea(
          child: CenteredScrollView(
            padding: const EdgeInsets.all(AppSpace.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  strings.theEnd,
                  style: AppText.kidDisplay,
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(begin: -0.3),
                const SizedBox(height: AppSpace.xl),
                if (count > 0)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpace.lg,
                    runSpacing: AppSpace.lg,
                    children: [
                      for (var i = 0; i < count; i++)
                        _Sticker(asset: sticker!, size: _stickerSize, index: i),
                    ],
                  )
                else
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.pink,
                    size: 96,
                  ).animate().scaleXY(
                    begin: 0,
                    end: 1,
                    duration: 900.ms,
                    curve: Curves.elasticOut,
                  ),
                const SizedBox(height: AppSpace.lg),
                Text(
                  count > 0 ? strings.stickersEarned(count) : strings.noSticker,
                  style: AppText.kidLabel.copyWith(color: AppColors.amber),
                  textAlign: TextAlign.center,
                ).animate(delay: 900.ms).fadeIn(),
                const SizedBox(height: AppSpace.xxl),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpace.lg,
                  runSpacing: AppSpace.md,
                  children: [
                    KidPillButton(
                      icon: Icons.bedtime_rounded,
                      label: strings.goodnightButton,
                      onPressed: () => context.go(AppRoutes.sleep),
                    ),
                    KidPillButton(
                      icon: Icons.replay_rounded,
                      label: strings.readAgain,
                      background: AppColors.lavender,
                      onPressed: () =>
                          context.go(AppRoutes.story(args.story.id)),
                    ),
                  ],
                ).animate(delay: 1400.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Sticker extends StatelessWidget {
  const _Sticker({
    required this.asset,
    required this.size,
    required this.index,
  });

  final String asset;
  final double size;
  final int index;

  @override
  Widget build(BuildContext context) {
    return StoryImage(asset, width: size, height: size, bitmap: true)
        .animate(delay: (300 + index * 350).ms)
        .scaleXY(begin: 0, end: 1, duration: 900.ms, curve: Curves.elasticOut)
        .rotate(begin: -0.1, end: 0, duration: 900.ms)
        .then()
        .shimmer(duration: 1500.ms, color: AppColors.amber);
  }
}
