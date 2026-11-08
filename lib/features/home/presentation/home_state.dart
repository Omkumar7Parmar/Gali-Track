import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/core/numeric.dart';
import 'package:galitrack/core/units.dart';
import 'package:meta/meta.dart';

/// What the home screen shows for today.
@immutable
final class HomeState {
  const HomeState({
    required this.date,
    required this.goal,
    required this.stepsToday,
    required this.distanceToday,
    required this.streakDays,
  });

  /// The moment "today" was read, for the date shown in the header.
  final DateTime date;
  final DailyGoal goal;
  final int stepsToday;
  final Meters distanceToday;
  final int streakDays;

  /// Progress towards the step target, from 0 to 1. Derived, never stored.
  double get stepProgress => progressFraction(stepsToday, goal.stepTarget);

  /// Progress towards the distance target, from 0 to 1. Derived, never stored.
  double get distanceProgress =>
      progressFraction(distanceToday.value, goal.distanceTarget.value);

  @override
  bool operator ==(Object other) =>
      other is HomeState &&
      other.date == date &&
      other.goal == goal &&
      other.stepsToday == stepsToday &&
      other.distanceToday == distanceToday &&
      other.streakDays == streakDays;

  @override
  int get hashCode =>
      Object.hash(date, goal, stepsToday, distanceToday, streakDays);
}
