import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'package:bedtime_stories/core/widgets/language_toggle.dart';
import 'package:bedtime_stories/core/widgets/night_sky.dart';
import 'package:bedtime_stories/core/widgets/story_image.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/sticker_cubit.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';
import 'package:bedtime_stories/features/stories/presentation/cubit/story_list_cubit.dart';

/// The kid's sticker book: total, then each story's sticker with how many
/// were earned (not earned yet = faded). Parent can switch the language or
/// edit the name/recording from here.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LanguageCubit, AppLanguage>(
      listener: (context, language) =>
          context.read<StoryListCubit>().load(language),
      child: Scaffold(
        body: NightSky(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.contentMaxWidth,
                ),
                child: const CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpace.xl,
                        AppSpace.lg,
                        AppSpace.xl,
                        AppSpace.xl,
                      ),
                      sliver: SliverToBoxAdapter(child: _Header()),
                    ),
                    _StickerGrid(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final profile = context.profile;
    final strings = context.strings;
    final total = context.select<StickerCubit, int>((c) => c.total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            KidIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: strings.back,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go(AppRoutes.home),
            ),
            const Spacer(),
            const LanguageToggle(),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
        Row(
          children: [
            Container(
              decoration: const ShapeDecoration(
                color: AppColors.nightSurface,
                shape: CircleBorder(
                  side: BorderSide(color: AppColors.amber, width: 3),
                ),
              ),
              child: SvgPicture.asset(
                AppConstants.heroAvatar(profile.gender.name),
                width: 96,
                height: 96,
              ),
            ),
            const SizedBox(width: AppSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.name, style: AppText.kidDisplay),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.amber,
                        size: 36,
                      ),
                      const SizedBox(width: AppSpace.xs),
                      Flexible(
                        child: Text(
                          strings.stickerTotal(total),
                          style: AppText.kidTitle.copyWith(
                            color: AppColors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: KidPillButton(
            icon: Icons.edit_rounded,
            label: strings.editProfile,
            background: AppColors.lavenderDark,
            foreground: AppColors.cream,
            onPressed: () => context.push(AppRoutes.welcome),
          ),
        ),
        if (total == 0) ...[
          const SizedBox(height: AppSpace.xl),
          Text(
            strings.noStickersYet,
            style: AppText.kidLabel.copyWith(color: AppColors.lavender),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _StickerGrid extends StatelessWidget {
  const _StickerGrid();

  @override
  Widget build(BuildContext context) {
    final stickers = context.watch<StickerCubit>().state;
    return BlocBuilder<StoryListCubit, StoryListState>(
      builder: (context, state) {
        final stories = switch (state) {
          StoryListLoaded(:final stories) => [
            for (final s in stories)
              if (s.stickerAsset != null) s,
          ],
          _ => const <Story>[],
        };
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.xl,
            0,
            AppSpace.xl,
            AppSpace.xl,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: AppConstants.stickerTileSize + AppSpace.xl,
              mainAxisSpacing: AppSpace.lg,
              crossAxisSpacing: AppSpace.lg,
              mainAxisExtent: AppConstants.stickerTileSize + 44,
            ),
            itemCount: stories.length,
            itemBuilder: (context, i) => _StickerTile(
              story: stories[i],
              count: stickers[stories[i].id] ?? 0,
            ),
          ),
        );
      },
    );
  }
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({required this.story, required this.count});

  final Story story;
  final int count;

  @override
  Widget build(BuildContext context) {
    final earned = count > 0;
    final title = resolveName(story.title, context.profile);
    Widget sticker = StoryImage(
      story.stickerAsset!,
      fit: BoxFit.contain,
      bitmap: true,
    );
    if (!earned) {
      // Not earned yet: a faded grey shape to aim for.
      sticker = Opacity(
        opacity: 0.25,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.33, 0.33, 0.33, 0, 0, //
            0.33, 0.33, 0.33, 0, 0, //
            0.33, 0.33, 0.33, 0, 0, //
            0, 0, 0, 1, 0, //
          ]),
          child: sticker,
        ),
      );
    }
    return Semantics(
      label: '$title: $count',
      child: Column(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: RepaintBoundary(child: sticker)),
                if (earned)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.amber,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '×$count',
                        style: AppText.label.copyWith(
                          color: AppColors.onAccent,
                        ),
                      ),
                    ).animate().scaleXY(begin: 0, curve: Curves.elasticOut),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            title,
            style: AppText.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
