import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_spacing.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';
import 'package:bedtime_stories/core/widgets/story_image.dart';

/// Big tappable cover card. The whole card starts the story.
class StoryCard extends StatelessWidget {
  const StoryCard({required this.story, required this.onTap, super.key});

  final Story story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final profile = context.profile;
    final title = resolveName(story.title, profile);
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: AppColors.nightSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: AppConstants.sceneAspectRatio,
                child: RepaintBoundary(
                  child: StoryImage(
                    story.coverAsset,
                    fit: BoxFit.cover,
                    bitmap: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpace.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppText.kidLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpace.md),
                    // Own layer: the looping bob doesn't repaint the card.
                    const RepaintBoundary(child: _PlayBadge()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
          width: AppConstants.kidIconButton,
          height: AppConstants.kidIconButton,
          decoration: const BoxDecoration(
            color: AppColors.amber,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: AppColors.onAccent,
            size: 40,
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 1,
          end: 1.08,
          duration: AppConstants.bobDuration,
          curve: Curves.easeInOut,
        );
  }
}
