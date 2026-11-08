import 'package:flutter/material.dart';
import 'package:galitrack/core/models/theme_preference.dart';

/// Maps the stored preference to Flutter's [ThemeMode].
ThemeMode themeModeFor(ThemePreference preference) => switch (preference) {
  ThemePreference.light => ThemeMode.light,
  ThemePreference.dark => ThemeMode.dark,
  ThemePreference.system => ThemeMode.system,
};
