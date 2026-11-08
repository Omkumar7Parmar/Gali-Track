import 'package:drift/drift.dart';
import 'package:galitrack/data/daos/app_settings_dao.dart';
import 'package:galitrack/data/daos/goal_history_dao.dart';
import 'package:galitrack/data/db/tables/app_settings_table.dart';
import 'package:galitrack/data/db/tables/goal_history_table.dart';

part 'app_database.g.dart';

/// The app's on-device database: the single source of truth.
///
/// Only lib/data/ may import Drift. Everything above it sees the value types
/// in lib/core/models.
@DriftDatabase(
  tables: [AppSettingsTable, GoalHistoryTable],
  daos: [AppSettingsDao, GoalHistoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Stays 1 until the first Play Store release. After that, every schema
  /// change bumps this and adds a migration step with a test.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    beforeOpen: (details) async {
      // These settings belong to the connection, not the file, so they are
      // applied on every open.
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = FULL');
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
      if (details.wasCreated) {
        // Seed the single settings row; its defaults describe a new install.
        await into(
          appSettingsTable,
        ).insert(const AppSettingsTableCompanion(id: Value(1)));
      }
    },
  );
}
