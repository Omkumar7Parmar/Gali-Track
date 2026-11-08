import 'package:flutter/material.dart';
import 'package:galitrack/theme/app_colors.dart';
import 'package:galitrack/theme/app_motion.dart';
import 'package:galitrack/theme/app_shapes.dart';
import 'package:galitrack/theme/app_spacing.dart';
import 'package:galitrack/theme/color_schemes.dart';

/// The light theme, built once and shared by the app and the onboarding
/// previews.
final ThemeData appLightTheme = buildAppTheme(Brightness.light);

/// The dark theme, built once and shared by the app and the onboarding
/// previews.
final ThemeData appDarkTheme = buildAppTheme(Brightness.dark);

/// Builds the complete theme for one brightness.
///
/// Light and dark are both built here, and every extension is attached to
/// both, so a screen never renders with a missing token.
ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = isDark ? AppColorSchemes.dark : AppColorSchemes.light;
  const shapes = AppShapes.standard;
  final textTheme = _buildTextTheme(scheme);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,
    extensions: <ThemeExtension<dynamic>>[
      if (isDark) AppColors.dark else AppColors.light,
      AppSpacing.standard,
      shapes,
      AppMotion.standardSet,
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      margin: EdgeInsets.zero,
      shape: shapes.cardShape(),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 56),
        shape: shapes.pillShape(),
        textStyle: textTheme.titleMedium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: shapes.pillShape(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: shapes.pillShape(),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: shapes.panelShape(),
    ),
  );
}

/// Material 3 type scale with heavier display and headline weights for the
/// big numbers, and tabular figures so changing digits don't jiggle.
TextTheme _buildTextTheme(ColorScheme scheme) {
  final base = ThemeData(useMaterial3: true, colorScheme: scheme).textTheme;
  const numbers = [FontFeature.tabularFigures()];
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontFeatures: numbers,
    ),
    displayMedium: base.displayMedium?.copyWith(
      fontWeight: FontWeight.w700,
      fontFeatures: numbers,
    ),
    displaySmall: base.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
      fontFeatures: numbers,
    ),
    headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
    headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
    headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
    titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  );
}
