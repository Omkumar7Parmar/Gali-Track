import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/app_settings.dart';
import 'package:galitrack/core/models/theme_preference.dart';
import 'package:galitrack/core/result.dart';
import 'package:galitrack/data/providers.dart';
import 'package:galitrack/features/settings/presentation/settings_state.dart';
import 'package:galitrack/ui/save_status.dart';

/// The settings screen's view model.
final NotifierProvider<SettingsNotifier, SettingsState>
settingsNotifierProvider =
    NotifierProvider.autoDispose<SettingsNotifier, SettingsState>(
      SettingsNotifier.new,
    );

/// Shows the saved theme and changes it through the repository.
///
/// The theme shown always comes from the database: after a save commits,
/// [appSettingsProvider] updates and this rebuilds with the new value.
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final preference = ref.watch(
      appSettingsProvider.select((settings) => settings.themePreference),
    );
    return SettingsState(themePreference: preference);
  }

  void chooseTheme(ThemePreference preference) {
    unawaited(_chooseTheme(preference));
  }

  Future<void> _chooseTheme(ThemePreference preference) async {
    final result = await ref
        .read(settingsRepositoryProvider)
        .setThemePreference(preference);
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        break; // appSettingsProvider re-emits, which rebuilds this state.
      case Err(:final failure):
        state = state.copyWith(saveStatus: SaveFailed(failure));
    }
  }
}
