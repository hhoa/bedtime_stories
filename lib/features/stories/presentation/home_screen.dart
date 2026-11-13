import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/router/app_routes.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_spacing.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/core/widgets/kid_buttons.dart';
import 'package:bedtime_stories/core/widgets/night_sky.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/sticker_cubit.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';
import 'package:bedtime_stories/features/stories/presentation/cubit/story_list_cubit.dart';
import 'package:bedtime_stories/features/stories/presentation/widgets/story_card.dart';

/// Story covers in a lazy grid: only cards on screen are built and only
/// their covers decoded (small `cover.webp`, drawn once at box size).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LanguageCubit, AppLanguage>(
      listener: (context, language) =>
          context.read<StoryListCubit>().load(language),
      child: Scaffold(
        body: NightSky(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, box) {
                final side = homeSidePadding(box.maxWidth);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(side, AppSpace.xl, side, 0),
                      child: const _Header(),
                    ),
                    const SizedBox(height: AppSpace.xl),
                    // Full width, so drags on the side margins scroll the list.
                    Expanded(
                      child: RepaintBoundary(child: _StoryList(side: side)),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Home side margin for a screen [width]: content capped at
/// [AppConstants.contentMaxWidth] and centered; on wide screens at least
/// [AppConstants.adRailWidth] (+ gutter) per side stays free for future ads.
double homeSidePadding(double width) {
  final rail = width >= AppConstants.adRailMinScreenWidth
      ? AppConstants.adRailWidth + AppSpace.xl
      : 0.0;
  return math.max(
    AppSpace.xl + rail,
    (width - AppConstants.contentMaxWidth) / 2,
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final profile = context.profile;
    final strings = context.strings;
    final stickers = context.select<StickerCubit, int>((c) => c.total);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(
          asset: AppConstants.heroAvatar(profile.gender.name),
          stickers: stickers,
          tooltip: strings.openProfile,
          onTap: () => context.push(AppRoutes.profile),
        ),
        const SizedBox(width: AppSpace.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.greeting(profile.name), style: AppText.kidDisplay),
              const SizedBox(height: AppSpace.xs),
              Text(
                strings.homeSubtitle,
                style: AppText.kidLabel.copyWith(color: AppColors.lavender),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kid's face with their sticker count; opens the profile page.
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.asset,
    required this.stickers,
    required this.tooltip,
    required this.onTap,
  });

  final String asset;
  final int stickers;
  final String tooltip;
  final VoidCallback onTap;

  static const _size = AppConstants.kidIconButton + AppSpace.lg;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: AppColors.nightSurface,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.amber, width: 3),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SvgPicture.asset(asset, width: _size, height: _size),
            ),
          ),
          Positioned(
            right: -AppSpace.sm,
            bottom: -AppSpace.sm,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.nightDeep, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: AppColors.onAccent,
                    ),
                    Text(
                      '$stickers',
                      style: AppText.label.copyWith(color: AppColors.onAccent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryList extends StatelessWidget {
  const _StoryList({required this.side});

  final double side;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryListCubit, StoryListState>(
      buildWhen: (a, b) => a != b,
      builder: (context, state) => switch (state) {
        StoryListLoading() => const Center(
          child: CircularProgressIndicator(color: AppColors.amber),
        ),
        StoryListFailure() => _Message(
          text: context.strings.loadError,
          onRetry: () => context.read<StoryListCubit>().load(
            context.read<LanguageCubit>().state,
          ),
        ),
        StoryListLoaded(:final stories) when stories.isEmpty => _Message(
          text: context.strings.noStories,
        ),
        StoryListLoaded(:final stories) => _Grid(stories: stories, side: side),
      },
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.stories, required this.side});

  final List<Story> stories;
  final double side;

  /// Card part under the cover: padding + play badge row.
  static const _footer = AppSpace.lg * 2 + AppConstants.kidIconButton;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // Side margins (and ad rails) still scroll the grid.
        final inner = box.maxWidth - side * 2;
        final columns = inner >= AppConstants.storyGridTwoColumnWidth ? 2 : 1;
        final cardWidth = (inner - AppSpace.xl * (columns - 1)) / columns;
        return GridView.builder(
          padding: EdgeInsets.fromLTRB(side, 0, side, AppSpace.xl),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: AppSpace.xl,
            crossAxisSpacing: AppSpace.xl,
            mainAxisExtent: cardWidth / AppConstants.sceneAspectRatio + _footer,
          ),
          itemCount: stories.length,
          itemBuilder: (context, i) {
            final story = stories[i];
            return StoryCard(
              story: story,
              onTap: () => context.push(AppRoutes.story(story.id)),
            );
          },
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.lavender,
              size: 64,
            ),
            const SizedBox(height: AppSpace.lg),
            Text(text, style: AppText.kidLabel, textAlign: TextAlign.center),
            if (retry != null) ...[
              const SizedBox(height: AppSpace.lg),
              KidPillButton(
                icon: Icons.refresh_rounded,
                label: context.strings.retry,
                onPressed: retry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
