import 'package:galitrack/core/models/theme_preference.dart';
import 'package:galitrack/core/models/user_profile.dart';
import 'package:meta/meta.dart';

/// App-wide settings, stored as the single row of the `app_settings` table.
@immutable
final class AppSettings {
  const AppSettings({
    required this.onboardingCompleted,
    required this.themePreference,
    this.profile,
  });

  /// What a brand-new install starts with.
  static const initial = AppSettings(
    onboardingCompleted: false,
    themePreference: ThemePreference.system,
  );

  final bool onboardingCompleted;
  final ThemePreference themePreference;

  /// Null until onboarding is completed.
  final UserProfile? profile;

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.onboardingCompleted == onboardingCompleted &&
      other.themePreference == themePreference &&
      other.profile == profile;

  @override
  int get hashCode =>
      Object.hash(onboardingCompleted, themePreference, profile);

  @override
  String toString() =>
      'AppSettings(onboardingCompleted: $onboardingCompleted, theme: $themePreference, profile: $profile)';
}
