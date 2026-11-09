import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_spacing.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/core/widgets/kid_buttons.dart';
import 'package:bedtime_stories/features/player/presentation/cubit/player_cubit.dart';
import 'package:bedtime_stories/features/player/presentation/cubit/player_state.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/choice_card.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

/// Lower (phone) or right (tablet) area: caption, choices or rewind offer.
class StoryPanel extends StatelessWidget {
  const StoryPanel({required this.wide, super.key});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      buildWhen: (a, b) =>
          a.nodeId != b.nodeId ||
          a.phase != b.phase ||
          a.highlightedOption != b.highlightedOption ||
          a.selectedOptionId != b.selectedOptionId,
      builder: (context, state) {
        final node = state.node;
        final child = switch (node) {
          null => const SizedBox.shrink(),
          ChoiceNode() => _ChoicePanel(node: node, state: state, wide: wide),
          SceneNode() when state.phase == PlayerPhase.rewindOffer =>
            _RewindPanel(wide: wide),
          SceneNode() => _CaptionPanel(
            text: _resolve(context, node.text),
            showNext: true,
            wide: wide,
          ),
          EndingNode() => _CaptionPanel(
            text: _resolve(context, node.text),
            showNext: false,
            wide: wide,
          ),
        };
        return AnimatedSwitcher(
          duration: AppConstants.sceneFadeDuration,
          child: KeyedSubtree(
            key: ValueKey('${state.nodeId}-${state.phase}'),
            child: child,
          ),
        );
      },
    );
  }
}

String _resolve(BuildContext context, String text) =>
    resolveName(text, context.profile);

class _CaptionPanel extends StatelessWidget {
  const _CaptionPanel({
    required this.text,
    required this.showNext,
    required this.wide,
  });

  final String text;
  final bool showNext;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final caption = Text(
      text,
      style: wide ? AppText.captionLarge : AppText.caption,
    );
    final next = showNext
        ? KidIconButton(
            icon: Icons.arrow_forward_rounded,
            tooltip: context.strings.next,
            size: wide ? AppConstants.kidMinTarget : 72,
            background: AppColors.amber,
            foreground: AppColors.onAccent,
            onPressed: () => context.read<PlayerCubit>().next(),
          )
        : null;

    return _PanelSurface(
      child: wide
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(child: SingleChildScrollView(child: caption)),
                ),
                if (next != null) ...[
                  const SizedBox(height: AppSpace.lg),
                  Align(alignment: Alignment.centerRight, child: next),
                ],
              ],
            )
          : Row(
              children: [
                Expanded(child: caption),
                if (next != null) ...[const SizedBox(width: AppSpace.md), next],
              ],
            ),
    );
  }
}

class _ChoicePanel extends StatelessWidget {
  const _ChoicePanel({
    required this.node,
    required this.state,
    required this.wide,
  });

  final ChoiceNode node;
  final PlayerState state;
  final bool wide;

  ChoiceCardState _cardState(int i) {
    final selected = state.selectedOptionId;
    if (selected != null) {
      return node.options[i].id == selected
          ? ChoiceCardState.selected
          : ChoiceCardState.faded;
    }
    return state.highlightedOption == i
        ? ChoiceCardState.reading
        : ChoiceCardState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();
    final cards = List<Widget>.generate(node.options.length, (i) {
      final option = node.options[i];
      return ChoiceCard(
        iconAsset: option.iconAsset,
        label: _resolve(context, option.label),
        state: _cardState(i),
        horizontal: wide,
        onTap: () => cubit.choose(option.id),
      );
    });

    return Column(
      mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _resolve(context, node.text),
          style: wide ? AppText.kidTitle : AppText.kidLabel,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpace.lg),
        if (wide)
          for (final card in cards) ...[
            card,
            const SizedBox(height: AppSpace.lg),
          ]
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards.first),
              const SizedBox(width: AppSpace.md),
              Expanded(child: cards.last),
            ],
          ),
      ],
    );
  }
}

class _RewindPanel extends StatelessWidget {
  const _RewindPanel({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();
    return _PanelSurface(
      child: Column(
        mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.strings.rewindQuestion,
            style: wide ? AppText.kidTitle : AppText.kidLabel,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.xl),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpace.lg,
            runSpacing: AppSpace.md,
            children: [
              KidPillButton(
                icon: Icons.replay_rounded,
                label: context.strings.tryOtherChoice,
                background: AppColors.lavender,
                onPressed: cubit.rewind,
              ),
              KidPillButton(
                icon: Icons.arrow_forward_rounded,
                label: context.strings.keepGoing,
                onPressed: cubit.keepGoing,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelSurface extends StatelessWidget {
  const _PanelSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.nightSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.nightBorder),
      ),
      child: Padding(padding: const EdgeInsets.all(AppSpace.lg), child: child),
    );
  }
}
