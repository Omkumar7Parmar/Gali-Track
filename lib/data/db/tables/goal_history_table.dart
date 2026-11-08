import 'package:drift/drift.dart';

/// Every daily goal the user has set, one row per day it changed.
///
/// A day is judged by the latest row that started on or before it, so
/// changing the goal never rewrites past days or breaks a streak. The CHECK
/// limits mirror `DailyGoal` in lib/core/models;
/// test/data/schema_constraints_test.dart keeps them in step.
@DataClassName('GoalHistoryRow')
class GoalHistoryTable extends Table {
  @override
  String get tableName => 'goal_history';

  IntColumn get id => integer().autoIncrement()();

  /// The local calendar day (days since 1970-01-01) this goal starts on.
  /// Unique: a second change on the same day replaces the first.
  IntColumn get effectiveFromDay => integer().unique()();

  TextColumn get goalType => text()();

  IntColumn get stepTarget => integer()();

  IntColumn get distanceTargetMeters => integer()();

  @override
  List<String> get customConstraints => const [
    "CHECK (goal_type IN ('steps', 'distance', 'both'))",
    'CHECK (step_target BETWEEN 1000 AND 30000)',
    'CHECK (distance_target_meters BETWEEN 500 AND 30000)',
  ];

  @override
  bool get isStrict => true;
}
