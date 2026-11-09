import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_spacing.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';

/// Small VI | EN switch (parent-facing). Changes UI, story text and voice.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  static const _labels = {AppLanguage.vi: 'VI', AppLanguage.en: 'EN'};

  @override
  Widget build(BuildContext context) {
    final current = context.language;
    final strings = context.strings;
    return Semantics(
      label: strings.languageLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.nightSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.nightBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final lang in AppLanguage.values)
                _Option(
                  label: _labels[lang]!,
                  tooltip: lang == AppLanguage.vi
                      ? strings.languageVi
                      : strings.languageEn,
                  selected: lang == current,
                  onTap: () => context.read<LanguageCubit>().select(lang),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected ? AppColors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: onTap,
            child: SizedBox(
              width: 56,
              height: 44,
              child: Center(
                child: Text(
                  label,
                  style: AppText.label.copyWith(
                    color: selected ? AppColors.onAccent : AppColors.cream,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
