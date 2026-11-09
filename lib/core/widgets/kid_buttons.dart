import 'package:flutter/material.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_spacing.dart';
import 'package:bedtime_stories/core/theme/app_typography.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';

/// Round icon button sized for small fingers.
class KidIconButton extends StatelessWidget {
  const KidIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = AppConstants.kidIconButton,
    this.background = AppColors.nightSurfaceHigh,
    this.foreground = AppColors.cream,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, color: foreground, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}

/// Big pill button with icon + label.
class KidPillButton extends StatelessWidget {
  const KidPillButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.background = AppColors.amber,
    this.foreground = AppColors.onAccent,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppConstants.kidIconButton,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.xl,
              vertical: AppSpace.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: foreground, size: 30),
                const SizedBox(width: AppSpace.sm),
                Flexible(
                  child: Text(
                    label,
                    style: AppText.kidButton.copyWith(color: foreground),
                    textAlign: TextAlign.center,
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
