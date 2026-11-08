import 'package:galitrack/core/calendar_day.dart';
import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/core/units.dart';
import 'package:galitrack/data/db/app_database.dart';

/// Maps a stored goal row to the [DailyGoal] value type.
DailyGoal goalFromRow(GoalHistoryRow row) {
  return DailyGoal(
    type: goalTypeFromName(row.goalType),
    stepTarget: row.stepTarget,
    distanceTarget: Meters(row.distanceTargetMeters),
  );
}

/// Builds the row that stores [goal] as starting on [from].
GoalHistoryTableCompanion goalToCompanion(DailyGoal goal, CalendarDay from) {
  return GoalHistoryTableCompanion.insert(
    effectiveFromDay: from.daysSinceEpoch,
    goalType: goal.type.name,
    stepTarget: goal.stepTarget,
    distanceTargetMeters: goal.distanceTarget.value,
  );
}

/// Parses a stored goal type. The CHECK constraint only allows the three
/// enum names; anything else falls back to steps.
GoalType goalTypeFromName(String name) => switch (name) {
  'distance' => GoalType.distance,
  'both' => GoalType.both,
  _ => GoalType.steps,
};
