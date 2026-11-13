import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bedtime_stories/core/router/app_routes.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_spacing.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/core/widgets/kid_buttons.dart';
import 'package:bedtime_stories/core/widgets/night_sky.dart';
import 'package:bedtime_stories/features/ending/presentation/ending_screen.dart';
import 'package:bedtime_stories/features/player/presentation/cubit/player_cubit.dart';
import 'package:bedtime_stories/features/player/presentation/cubit/player_state.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/scene_picture.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/story_panel.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/sticker_cubit.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';
import 'package:bedtime_stories/core/widgets/story_image.dart';

class StoryPlayerScreen extends StatelessWidget {
  const StoryPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PlayerCubit, PlayerState>(
          listenWhen: (a, b) =>
              a.phase != b.phase && b.phase == PlayerPhase.finished,
          listener: (context, state) {
            final story = state.story;
            if (story == null) return;
            // Saved here, once per finished play (not on the ending page,
            // which can be rebuilt).
            context.read<StickerCubit>().add(story.id, state.goodCount);
            context.go(
              AppRoutes.ending(story.id),
              extra: EndingArgs(
                story: story,
                goodCount: state.goodCount,
                choiceCount: state.firstPicks.length,
              ),
            );
          },
        ),
      ],
      child: Scaffold(
        body: NightSky(
          starCount: 14,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.lg),
              child: BlocBuilder<PlayerCubit, PlayerState>(
                buildWhen: (a, b) =>
                    (a.phase == PlayerPhase.loading) !=
                        (b.phase == PlayerPhase.loading) ||
                    (a.phase == PlayerPhase.failure) !=
                        (b.phase == PlayerPhase.failure),
                builder: (context, state) => switch (state.phase) {
                  PlayerPhase.loading => const Center(
                    child: CircularProgressIndicator(color: AppColors.amber),
                  ),
                  PlayerPhase.failure => const _LoadError(),
                  _ => const _PlayerLayout(),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerLayout extends StatelessWidget {
  const _PlayerLayout();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final wide =
            box.maxWidth >= AppConstants.wideLayoutMinWidth &&
            box.maxWidth > box.maxHeight;
        if (wide) {
          return const Column(
            children: [
              _TopBar(),
              SizedBox(height: AppSpace.lg),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: _Picture()),
                    SizedBox(width: AppSpace.xl),
                    Expanded(flex: 2, child: StoryPanel(wide: true)),
                  ],
                ),
              ),
            ],
          );
        }
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(),
            SizedBox(height: AppSpace.md),
            Expanded(child: _Picture()),
            SizedBox(height: AppSpace.lg),
            StoryPanel(wide: false),
          ],
        );
      },
    );
  }
}

class _Picture extends StatelessWidget {
  const _Picture();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerCubit, PlayerState>(
      listenWhen: (a, b) => a.nodeId != b.nodeId,
      listener: _precacheNext,
      buildWhen: (a, b) => a.node != b.node || a.cue != b.cue,
      builder: (context, state) {
        final node = state.node;
        final story = state.story;
        if (node == null || story == null) return const SizedBox.shrink();
        final layers = story.layers[node.imageAsset];
        return ScenePicture(
          imageAsset: node.imageAsset,
          layers: layers,
          hotspots: story.hotspots[node.imageAsset],
          cue: state.cue,
          poses: node.poses,
          placements: story.placements(node.id),
          ambient: node.ambient,
          ambientOrigin: node.ambientOrigin,
          semanticLabel: context.strings.listenAgain,
          onTap: () => context.read<PlayerCubit>().replay(),
        );
      },
    );
  }
}

/// Loads the pictures the kid can reach next, so their layers appear
/// together instead of popping in one by one.
void _precacheNext(BuildContext context, PlayerState state) {
  final story = state.story;
  final node = state.node;
  if (story == null || node == null) return;
  for (final id in story.nextIds(node.id)) {
    final next = story.nodes[id];
    if (next == null) continue;
    final image = next.imageAsset;
    final layers = story.layers[image];
    final assets = [
      if (layers == null) image else for (final l in layers) ...l.allAssets,
      if (next is ChoiceNode)
        for (final o in next.options) o.iconAsset,
    ];
    for (final a in assets) {
      precacheStoryImage(context, a);
    }
  }
}

/// Back to the list of the story's section (sections page if the story
/// never loaded).
void _goBack(BuildContext context) {
  final story = context.read<PlayerCubit>().state.story;
  context.go(story == null ? AppRoutes.home : AppRoutes.section(story.section));
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KidIconButton(
          icon: Icons.home_rounded,
          tooltip: context.strings.home,
          onPressed: () => _goBack(context),
        ),
        const Spacer(),
        KidIconButton(
          icon: Icons.volume_up_rounded,
          tooltip: context.strings.listenAgain,
          background: AppColors.lavenderDark,
          onPressed: () => context.read<PlayerCubit>().replay(),
        ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.strings.loadError, style: AppText.caption),
          const SizedBox(height: AppSpace.lg),
          KidPillButton(
            icon: Icons.home_rounded,
            label: context.strings.home,
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
    );
  }
}
