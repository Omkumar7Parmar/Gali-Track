import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/core/app_log.dart';
import 'package:galitrack/core/models/app_settings.dart';
import 'package:galitrack/data/providers.dart';

/// The settings bootstrap() read before the first frame. Throws until
/// overridden, so a missing wiring fails loudly.
final initialSettingsProvider = Provider<AppSettings>(
  (ref) => throw UnimplementedError(
    'initialSettingsProvider is overridden in bootstrap()',
  ),
);

/// The current app-wide settings, read by the theme and the router.
final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

/// Holds the latest settings from the database.
///
/// It starts from the snapshot bootstrap() read, so the very first frame
/// already has the right theme. After that it follows the repository's
/// stream, which re-emits after every committed write. Nothing here writes:
/// changes go through the repository, and this notifier just follows.
class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final subscription = ref
        .watch(settingsRepositoryProvider)
        .watch()
        .listen(
          (settings) => state = settings,
          onError: (Object error, StackTrace stackTrace) => ref
              .read(appLogProvider)
              .error('settings.watch', error, stackTrace),
        );
    ref.onDispose(() {
      unawaited(subscription.cancel());
    });
    return ref.watch(initialSettingsProvider);
  }
}
