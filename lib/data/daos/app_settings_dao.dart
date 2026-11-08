import 'package:drift/drift.dart';
import 'package:galitrack/data/db/app_database.dart';
import 'package:galitrack/data/db/tables/app_settings_table.dart';

part 'app_settings_dao.g.dart';

/// Queries for the single `app_settings` row.
@DriftAccessor(tables: [AppSettingsTable])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.attachedDatabase);

  static const _rowId = 1;

  Future<AppSettingsRow> getRow() => _selectRow().getSingle();

  /// Emits the row now and again after every committed change.
  Stream<AppSettingsRow> watchRow() => _selectRow().watchSingle();

  /// Applies [changes] to the row. Throws [StateError] if the seeded row is
  /// missing, which would be a bug, not a runtime condition.
  Future<void> updateRow(AppSettingsTableCompanion changes) async {
    final updatedRows = await (update(
      appSettingsTable,
    )..where((t) => t.id.equals(_rowId))).write(changes);
    if (updatedRows != 1) {
      throw StateError('app_settings row $_rowId is missing');
    }
  }

  SimpleSelectStatement<$AppSettingsTableTable, AppSettingsRow> _selectRow() {
    return select(appSettingsTable)..where((t) => t.id.equals(_rowId));
  }
}
