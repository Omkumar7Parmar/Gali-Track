import 'package:galitrack/core/calendar_day.dart';
import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/data/db/app_database.dart';
import 'package:galitrack/data/mappers/goal_mapper.dart';

/// The single read path for daily goals.
class GoalRepository {
  GoalRepository(this._database);

  final AppDatabase _database;

  /// Emits the goal in force on [day], or null if none has been set yet.
  Stream<DailyGoal?> watchGoalOn(CalendarDay day) {
    return _database.goalHistoryDao
        .watchInEffectOn(day.daysSinceEpoch)
        .map((row) => row == null ? null : goalFromRow(row));
  }
}
