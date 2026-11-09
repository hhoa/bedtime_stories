import 'package:flutter/painting.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';

/// Text scale. Kid-facing headings use rounded Baloo 2 (variable font, so
/// weight is set via [FontVariation]); captions and parent text use
/// Be Vietnam Pro. Both cover Vietnamese diacritics.
abstract final class AppText {
  static const _baloo = 'Baloo2';
  static const _body = 'BeVietnamPro';

  static TextStyle _kid(double size, double weight) => TextStyle(
    fontFamily: _baloo,
    fontSize: size,
    height: 1.15,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation.weight(weight)],
    color: AppColors.cream,
  );

  static final kidDisplay = _kid(40, 800);
  static final kidTitle = _kid(30, 700);
  static final kidLabel = _kid(22, 700);
  static final kidButton = _kid(20, 700);

  /// Story text on tablets (read along by a parent).
  static const captionLarge = TextStyle(
    fontFamily: _body,
    fontSize: 24,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.cream,
  );

  static const caption = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.cream,
  );

  static const body = TextStyle(
    fontFamily: _body,
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.creamMuted,
  );

  static const label = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.cream,
  );
}
