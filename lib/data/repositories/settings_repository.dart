import 'package:drift/drift.dart';
import 'package:galitrack/core/app_log.dart';
import 'package:galitrack/core/failure.dart';
import 'package:galitrack/core/models/app_settings.dart';
import 'package:galitrack/core/models/theme_preference.dart';
import 'package:galitrack/core/result.dart';
import 'package:galitrack/data/db/app_database.dart';
import 'package:galitrack/data/mappers/settings_mapper.dart';
import 'package:galitrack/data/repositories/guarded_write.dart';
import 'package:meta/meta.dart';

/// The single read and write path for app-wide settings.
class SettingsRepository {
  SettingsRepository(this._database, this._log);

  final AppDatabase _database;
  final AppLog _log;

  /// Reads the settings once. Used by bootstrap() before the first frame.
  Future<AppSettings> load() async =>
      settingsFromRow(await _database.appSettingsDao.getRow());

  /// Emits the settings now and again after every committed change.
  Stream<AppSettings> watch() =>
      _database.appSettingsDao.watchRow().map(settingsFromRow);

  /// Saves the theme. Watchers of [watch] see it once it has committed.
  @useResult
  Future<Result<void, StorageFailure>> setThemePreference(
    ThemePreference preference,
  ) {
    return guardedWrite(
      _log,
      'settings.set_theme',
      () => _database.appSettingsDao.updateRow(
        AppSettingsTableCompanion(themePreference: Value(preference.name)),
      ),
    );
  }
}
