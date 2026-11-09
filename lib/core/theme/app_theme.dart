import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';

abstract final class AppTheme {
  /// Dark bars with light icons on every screen (night theme only).
  static const overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    // iOS: brightness of the bar background, so icons turn light.
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.night,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData get night => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'BeVietnamPro',
    scaffoldBackgroundColor: AppColors.nightDeep,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.amber,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.lavender,
      onSecondary: AppColors.onAccent,
      surface: AppColors.nightSurface,
      onSurface: AppColors.cream,
    ),
    appBarTheme: const AppBarTheme(systemOverlayStyle: overlayStyle),
    // Sparkle runs a shader on every touch-down; on web that makes the first
    // swipes over a card stutter, so web uses the plain ripple.
    splashFactory: kIsWeb ? InkRipple.splashFactory : InkSparkle.splashFactory,
  );
}
