import 'package:drift/drift.dart';
import 'package:galitrack/data/db/app_database.dart';
import 'package:galitrack/data/db/tables/goal_history_table.dart';

part 'goal_history_dao.g.dart';

/// Queries for the `goal_history` table.
@DriftAccessor(tables: [GoalHistoryTable])
class GoalHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$GoalHistoryDaoMixin {
  GoalHistoryDao(super.attachedDatabase);

  /// Emits the goal in force on [daySerial]: the latest row that started on
  /// or before that day, or null if no goal has been set yet.
  Stream<GoalHistoryRow?> watchInEffectOn(int daySerial) {
    final query = select(goalHistoryTable)
      ..where((t) => t.effectiveFromDay.isSmallerOrEqualValue(daySerial))
      ..orderBy([(t) => OrderingTerm.desc(t.effectiveFromDay)])
      ..limit(1);
    return query.watchSingleOrNull();
  }

  /// Saves [row] as the goal from its day onward. A goal already set for the
  /// same day is replaced.
  Future<void> upsert(GoalHistoryTableCompanion row) {
    return into(goalHistoryTable).insert(
      row,
      onConflict: DoUpdate(
        (_) => row,
        target: [goalHistoryTable.effectiveFromDay],
      ),
    );
  }
}
