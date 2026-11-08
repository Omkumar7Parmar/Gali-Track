import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galitrack/theme/app_colors.dart';
import 'package:galitrack/theme/app_motion.dart';
import 'package:galitrack/theme/app_shapes.dart';
import 'package:galitrack/theme/app_spacing.dart';
import 'package:galitrack/theme/app_theme.dart';

/// WCAG contrast ratio between two opaque colours.
double contrastRatio(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  return (max(first, second) + 0.05) / (min(first, second) + 0.05);
}

/// A colour pair the app actually draws, and the minimum WCAG AA ratio:
/// 4.5 for text, 3.0 for icons, rings and borders.
typedef ColorPair = ({
  String name,
  Color foreground,
  Color background,
  double minimum,
});

List<ColorPair> pairsFor(ThemeData theme) {
  final s = theme.colorScheme;
  final c = theme.extension<AppColors>()!;
  return [
    (
      name: 'onSurface/surface',
      foreground: s.onSurface,
      background: s.surface,
      minimum: 4.5,
    ),
    (
      name: 'onSurface/card',
      foreground: s.onSurface,
      background: s.surfaceContainerLow,
      minimum: 4.5,
    ),
    (
      name: 'onSurface/highest',
      foreground: s.onSurface,
      background: s.surfaceContainerHighest,
      minimum: 4.5,
    ),
    (
      name: 'muted/surface',
      foreground: s.onSurfaceVariant,
      background: s.surface,
      minimum: 4.5,
    ),
    (
      name: 'muted/card',
      foreground: s.onSurfaceVariant,
      background: s.surfaceContainerLow,
      minimum: 4.5,
    ),
    (
      name: 'muted/highest',
      foreground: s.onSurfaceVariant,
      background: s.surfaceContainerHighest,
      minimum: 4.5,
    ),
    (
      name: 'onPrimary/primary',
      foreground: s.onPrimary,
      background: s.primary,
      minimum: 4.5,
    ),
    (
      name: 'primary text/surface',
      foreground: s.primary,
      background: s.surface,
      minimum: 4.5,
    ),
    (
      name: 'onPrimaryContainer',
      foreground: s.onPrimaryContainer,
      background: s.primaryContainer,
      minimum: 4.5,
    ),
    (
      name: 'onSecondary/secondary',
      foreground: s.onSecondary,
      background: s.secondary,
      minimum: 4.5,
    ),
    (
      name: 'onSecondaryContainer',
      foreground: s.onSecondaryContainer,
      background: s.secondaryContainer,
      minimum: 4.5,
    ),
    (
      name: 'onTertiary/tertiary',
      foreground: s.onTertiary,
      background: s.tertiary,
      minimum: 4.5,
    ),
    (
      name: 'onTertiaryContainer',
      foreground: s.onTertiaryContainer,
      background: s.tertiaryContainer,
      minimum: 4.5,
    ),
    (
      name: 'onError/error',
      foreground: s.onError,
      background: s.error,
      minimum: 4.5,
    ),
    (
      name: 'error text/surface',
      foreground: s.error,
      background: s.surface,
      minimum: 4.5,
    ),
    (
      name: 'onErrorContainer',
      foreground: s.onErrorContainer,
      background: s.errorContainer,
      minimum: 4.5,
    ),
    (
      name: 'snack bar',
      foreground: s.onInverseSurface,
      background: s.inverseSurface,
      minimum: 4.5,
    ),
    (
      name: 'outline/surface',
      foreground: s.outline,
      background: s.surface,
      minimum: 3,
    ),
    (
      name: 'steps ring/card',
      foreground: c.stepsAccent,
      background: s.surfaceContainerLow,
      minimum: 3,
    ),
    (
      name: 'distance ring/card',
      foreground: c.distanceAccent,
      background: s.surfaceContainerLow,
      minimum: 3,
    ),
    (
      name: 'streak icon/card',
      foreground: s.secondary,
      background: s.surfaceContainerLow,
      minimum: 3,
    ),
  ];
}

String _describeFailure(ColorPair pair) {
  final ratio = contrastRatio(pair.foreground, pair.background);
  return '${pair.name}: ${ratio.toStringAsFixed(2)} < ${pair.minimum}';
}

void main() {
  for (final (label, theme) in [
    ('light', appLightTheme),
    ('dark', appDarkTheme),
  ]) {
    group('$label theme', () {
      test('every drawn colour pair passes WCAG AA', () {
        final failures = [
          for (final pair in pairsFor(theme))
            if (contrastRatio(pair.foreground, pair.background) < pair.minimum)
              _describeFailure(pair),
        ];
        expect(failures, isEmpty, reason: failures.join('\n'));
      });

      test('carries every token extension', () {
        expect(theme.extension<AppColors>(), isNotNull);
        expect(theme.extension<AppSpacing>(), isNotNull);
        expect(theme.extension<AppShapes>(), isNotNull);
        expect(theme.extension<AppMotion>(), isNotNull);
      });
    });
  }

  test('the two themes have the brightness their names say', () {
    expect(appLightTheme.brightness, Brightness.light);
    expect(appDarkTheme.brightness, Brightness.dark);
  });
}
