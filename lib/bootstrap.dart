import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/app.dart';
import 'package:galitrack/app_settings.dart';
import 'package:galitrack/core/app_log.dart';
import 'package:galitrack/data/db/connection.dart';
import 'package:galitrack/data/providers.dart';
import 'package:galitrack/data/repositories/settings_repository.dart';
import 'package:galitrack/services/error_handlers.dart';
import 'package:galitrack/services/file_app_log.dart';

/// The composition root: the one place real implementations are built.
///
/// Order matters: the log and error handlers come first so nothing after
/// them can fail unseen. Then the database opens and the settings are read,
/// so the very first frame already has the right theme and screen.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final log = await FileAppLog.open();
  installErrorHandlers(log);
  log.info('app.started');

  // The only wait before the first frame: open (and on first launch create)
  // the database, then read the single settings row.
  final database = openAppDatabase();
  final initialSettings = await SettingsRepository(database, log).load();

  runApp(
    ProviderScope(
      // Every provider failure here is a local bug, not a flaky network, so
      // fail at once instead of retrying behind a spinner.
      retry: (_, _) => null,
      overrides: [
        appLogProvider.overrideWithValue(log),
        appDatabaseProvider.overrideWithValue(database),
        initialSettingsProvider.overrideWithValue(initialSettings),
      ],
      child: const GaliTrackApp(),
    ),
  );
}
