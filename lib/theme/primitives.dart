import 'package:flutter/painting.dart';

/// Tier-1 colour primitives: the only file allowed raw colour literals.
///
/// Each name is a colour family plus its measured OKLCH lightness x100, so a
/// new shade always fits between two existing ones. Widgets never read these:
/// they read the `ColorScheme` roles and `AppColors` slots built from them.
abstract final class Primitives {
  // Warm neutrals: paper and ink.
  static const neutral100 = Color(0xFFFFFFFF);
  static const neutral98 = Color(0xFFFBF8F3);
  static const neutral95 = Color(0xFFF4EFE7);
  static const neutral93 = Color(0xFFEEE7DC);
  static const neutral91 = Color(0xFFE8E0D3);
  static const neutral89 = Color(0xFFE2D9CA);
  static const neutral86 = Color(0xFFD6CEC2);
  static const neutral76 = Color(0xFFB8B0A5);
  static const neutral61 = Color(0xFF8A8278);
  static const neutral46 = Color(0xFF5C564E);
  static const neutral39 = Color(0xFF4A453F);
  static const neutral32 = Color(0xFF36322D);
  static const neutral28 = Color(0xFF2B2824);
  static const neutral24 = Color(0xFF211F1B);
  static const neutral22 = Color(0xFF1D1B18);
  static const neutral19 = Color(0xFF141311);
  static const neutral0 = Color(0xFF000000);

  // Peacock teal: the primary action colour and distance.
  static const teal91 = Color(0xFFBFEDE6);
  static const teal81 = Color(0xFF6FD6CB);
  static const teal49 = Color(0xFF0B6E69);
  static const teal39 = Color(0xFF0E504B);
  static const teal29 = Color(0xFF00332F);
  static const teal22 = Color(0xFF00201E);

  // Marigold: steps.
  static const marigold92 = Color(0xFFFFDDB0);
  static const marigold81 = Color(0xFFF6B544);
  static const marigold54 = Color(0xFFA15C00);
  static const marigold39 = Color(0xFF5C3D00);
  static const marigold30 = Color(0xFF3F2700);
  static const marigold24 = Color(0xFF2E1C00);

  // Brick red: errors.
  static const red92 = Color(0xFFF9DEDC);
  static const red83 = Color(0xFFF2B8B5);
  static const red50 = Color(0xFFB3261E);
  static const red42 = Color(0xFF8C1D18);
  static const red33 = Color(0xFF601410);
  static const red25 = Color(0xFF410E0B);
}
