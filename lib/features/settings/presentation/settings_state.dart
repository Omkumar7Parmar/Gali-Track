import 'package:galitrack/core/models/theme_preference.dart';
import 'package:galitrack/ui/save_status.dart';
import 'package:meta/meta.dart';

/// What the settings screen shows.
@immutable
final class SettingsState {
  const SettingsState({
    required this.themePreference,
    this.saveStatus = const SaveIdle(),
  });

  final ThemePreference themePreference;
  final SaveStatus saveStatus;

  SettingsState copyWith({
    ThemePreference? themePreference,
    SaveStatus? saveStatus,
  }) {
    return SettingsState(
      themePreference: themePreference ?? this.themePreference,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SettingsState &&
      other.themePreference == themePreference &&
      other.saveStatus == saveStatus;

  @override
  int get hashCode => Object.hash(themePreference, saveStatus);
}
