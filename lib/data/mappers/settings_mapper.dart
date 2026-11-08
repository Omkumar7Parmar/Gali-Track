import 'package:galitrack/core/models/app_settings.dart';
import 'package:galitrack/core/models/theme_preference.dart';
import 'package:galitrack/core/models/user_profile.dart';
import 'package:galitrack/core/units.dart';
import 'package:galitrack/data/db/app_database.dart';

/// Maps the stored settings row to the [AppSettings] value type.
AppSettings settingsFromRow(AppSettingsRow row) {
  final weightGrams = row.weightGrams;
  final heightCentimeters = row.heightCentimeters;
  return AppSettings(
    onboardingCompleted: row.onboardingCompleted,
    themePreference: themePreferenceFromName(row.themePreference),
    profile: weightGrams == null
        ? null
        : UserProfile(
            weight: Grams(weightGrams),
            height: heightCentimeters == null
                ? null
                : Centimeters(heightCentimeters),
          ),
  );
}

/// Parses a stored theme name. The CHECK constraint only allows the three
/// enum names; anything else falls back to following the phone.
ThemePreference themePreferenceFromName(String name) => switch (name) {
  'light' => ThemePreference.light,
  'dark' => ThemePreference.dark,
  _ => ThemePreference.system,
};
