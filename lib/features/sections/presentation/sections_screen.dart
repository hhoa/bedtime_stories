import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:bedtime_stories/core/models/story_section.dart';
import 'package:bedtime_stories/core/router/app_routes.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_spacing.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/core/widgets/night_sky.dart';
import 'package:bedtime_stories/core/widgets/story_image.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/sticker_cubit.dart';
import 'package:bedtime_stories/features/sections/presentation/cubit/sections_cubit.dart';
import 'package:bedtime_stories/features/stories/presentation/home_screen.dart';

/// First page after the welcome: the kid's avatar (sticker count, opens the
/// profile) and one big picture card per [StorySection]. Never scrolls:
/// cards sit side by side on a wide screen, stacked on a tall one, and
/// shrink to fit.
class SectionsScreen extends StatelessWidget {
  const SectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NightSky(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              final side = homeSidePadding(box.maxWidth);
              return Padding(
                padding: EdgeInsets.fromLTRB(side, AppSpace.xl, side, 0),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(),
                    SizedBox(height: AppSpace.xl),
                    Expanded(child: _Cards()),
                  ],
                ),
              );
            },
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
              Text(
                strings.greeting(profile.name),
                style: AppText.kidDisplay,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpace.xs),
              Text(
                strings.sectionsSubtitle,
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

class _Cards extends StatelessWidget {
  const _Cards();

  @override
  Widget build(BuildContext context) {
    final glowing = context.watch<SectionsCubit>().state;
    return LayoutBuilder(
      builder: (context, box) {
        // Side by side when there is room for two landscape cards.
        final wide = box.maxWidth > box.maxHeight;
        final cards = [
          for (final (i, section) in StorySection.values.indexed) ...[
            if (i > 0) const SizedBox(width: AppSpace.xl, height: AppSpace.lg),
            Expanded(
              child: _SectionCard(
                section: section,
                glowing: section == glowing,
              ),
            ),
          ],
        ];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.xl),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: cards,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: cards,
                ),
        );
      },
    );
  }
}

/// Picture + name. Tapping says the name and opens the section's list.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.glowing});

  final StorySection section;
  final bool glowing;

  @override
  Widget build(BuildContext context) {
    final title = context.strings.sectionTitle(section);
    return Semantics(
      button: true,
      label: title,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: glowing ? AppColors.amber : AppColors.nightBorder,
            width: 3,
          ),
        ),
        child: Material(
          color: AppColors.nightSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl - 3),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              context.read<SectionsCubit>().open(
                section,
                context.read<LanguageCubit>().state,
              );
              context.push(AppRoutes.section(section));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: RepaintBoundary(
                    child: StoryImage(
                      AppConstants.sectionArt(section),
                      fit: BoxFit.cover,
                      bitmap: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.lg,
                    vertical: AppSpace.md,
                  ),
                  child: Text(
                    title,
                    style: AppText.kidTitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
