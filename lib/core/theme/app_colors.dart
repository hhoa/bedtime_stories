import 'package:flutter/painting.dart';

/// Bedtime palette. Kid screens are night-themed on purpose: no bright
/// white, warm accents only. Keep in sync with `tool/gen_art.py`.
abstract final class AppColors {
  static const nightDeep = Color(0xFF12143A);
  static const night = Color(0xFF1F2260);
  static const nightSurface = Color(0xFF2A2D6E);
  static const nightSurfaceHigh = Color(0xFF363A85);
  static const nightBorder = Color(0xFF4A4E9C);

  static const lavender = Color(0xFFB8A6FF);
  static const lavenderDark = Color(0xFF8E7BE0);
  static const amber = Color(0xFFFFC56E);
  static const peach = Color(0xFFFFB199);
  static const pink = Color(0xFFFF9EB5);
  static const mint = Color(0xFF8FE3C8);

  static const cream = Color(0xFFFFF4E0);
  static const creamMuted = Color(0xB3FFF4E0);
  static const creamFaint = Color(0x4DFFF4E0);

  /// Text/icon color on amber or lavender buttons.
  static const onAccent = Color(0xFF2B2340);

  /// Background of the composed choice icons (`ICON_BG` in tool/stage.py).
  static const countIconBg = Color(0xFF3E4C78);

  /// Sleep screen: almost black, slightly blue.
  static const sleepBg = Color(0xFF07081C);
}
