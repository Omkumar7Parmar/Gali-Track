import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galitrack/theme/app_theme.dart';

/// Guards a real bug: component themes were handed text styles with no font
/// size, so the app bar title rendered at the 14 px fallback.
void main() {
  for (final (label, theme) in [
    ('light', appLightTheme),
    ('dark', appDarkTheme),
  ]) {
    test('$label: component text styles carry real font sizes', () {
      expect(theme.appBarTheme.titleTextStyle?.fontSize, 22);
      final buttonStyle = theme.filledButtonTheme.style?.textStyle?.resolve(
        <WidgetState>{},
      );
      expect(buttonStyle?.fontSize, 16);
    });
  }
}
