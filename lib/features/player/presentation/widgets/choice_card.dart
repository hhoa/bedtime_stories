import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_spacing.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/core/widgets/story_image.dart';

enum ChoiceCardState { idle, reading, selected, faded }

/// One big picture option. Glows while its label is read aloud, pops when
/// tapped, fades when the other option was picked.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    required this.iconAsset,
    required this.label,
    required this.state,
    required this.horizontal,
    required this.onTap,
    this.count,
    super.key,
  });

  /// Picture of the option; with [count], the one counted object drawn
  /// [count] times under the digit (math answers).
  final String iconAsset;
  final int? count;
  final String label;
  final ChoiceCardState state;

  /// Icon beside label (wide panel) vs icon above label (phone).
  final bool horizontal;
  final VoidCallback onTap;

  bool get _lit =>
      state == ChoiceCardState.reading || state == ChoiceCardState.selected;

  @override
  Widget build(BuildContext context) {
    final iconSize = horizontal
        ? AppConstants.choiceIconSize
        : AppConstants.choiceIconSizeCompact;
    final count = this.count;
    final icon = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: count == null
          ? StoryImage(iconAsset, width: iconSize, height: iconSize)
          : CountIcon(asset: iconAsset, count: count, size: iconSize),
    );
    final text = Text(
      label,
      style: AppText.kidLabel,
      textAlign: horizontal ? TextAlign.start : TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );

    final content = horizontal
        ? Row(
            children: [
              icon,
              const SizedBox(width: AppSpace.lg),
              Expanded(child: text),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: AppSpace.sm),
              text,
            ],
          );

    return Semantics(
      button: true,
      label: label,
      child: AnimatedOpacity(
        duration: AppConstants.sceneFadeDuration,
        opacity: state == ChoiceCardState.faded ? 0.35 : 1,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          scale: state == ChoiceCardState.reading ? 1.04 : 1,
          child:
              AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    constraints: const BoxConstraints(
                      minHeight: AppConstants.kidMinTarget,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.nightSurface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: _lit ? AppColors.amber : AppColors.nightBorder,
                        width: _lit ? 4 : 2,
                      ),
                      boxShadow: _lit
                          ? [
                              BoxShadow(
                                color: AppColors.amber.withValues(alpha: 0.45),
                                blurRadius: 28,
                              ),
                            ]
                          : const [],
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        onTap: state == ChoiceCardState.faded ? null : onTap,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpace.md),
                          child: content,
                        ),
                      ),
                    ),
                  )
                  .animate(target: state == ChoiceCardState.selected ? 1 : 0)
                  .scaleXY(end: 1.1, curve: Curves.elasticOut)
                  .shimmer(color: AppColors.amber.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

/// Math answer card picture: a big amber digit over [count] copies of the
/// counted object, spread out so each one is easy to count. Same slate blue
/// as the composed choice icons.
class CountIcon extends StatelessWidget {
  const CountIcon({
    required this.asset,
    required this.count,
    required this.size,
    super.key,
  });

  final String asset;
  final int count;
  final double size;

  /// Objects per row: 3 → one row, 4 → 2 + 2, 5 → 3 + 2.
  static List<int> rows(int count) => switch (count) {
    <= 3 => [count],
    4 => [2, 2],
    _ => [(count + 1) ~/ 2, count ~/ 2],
  };

  @override
  Widget build(BuildContext context) {
    final layout = rows(count);
    final object = size * (layout.length == 1 && count <= 2 ? 0.38 : 0.28);
    return Semantics(
      label: '$count',
      child: Container(
        width: size,
        height: size,
        color: AppColors.countIconBg,
        padding: EdgeInsets.all(size * 0.04),
        child: Column(
          children: [
            SizedBox(
              height: size * 0.34,
              child: FittedBox(
                child: Text(
                  '$count',
                  style: AppText.kidDisplay.copyWith(
                    color: AppColors.amber,
                    height: 1,
                    shadows: const [
                      Shadow(color: AppColors.onAccent, blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final n in layout)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var i = 0; i < n; i++)
                          StoryImage(
                            asset,
                            width: object,
                            height: object,
                            fit: BoxFit.contain,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
