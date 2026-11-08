import 'package:galitrack/core/units.dart';
import 'package:meta/meta.dart';

/// What a day's goal counts.
enum GoalType {
  steps,
  distance,

  /// Both targets must be reached.
  both
  ;

  bool get countsSteps => switch (this) {
    GoalType.steps || GoalType.both => true,
    GoalType.distance => false,
  };

  bool get countsDistance => switch (this) {
    GoalType.distance || GoalType.both => true,
    GoalType.steps => false,
  };
}

/// The daily walking goal.
///
/// Both targets are always kept, even when [type] counts only one, so
/// switching the goal type never loses the other number.
@immutable
final class DailyGoal {
  const DailyGoal({
    required this.type,
    required this.stepTarget,
    required this.distanceTarget,
  });

  /// The goal suggested to new users.
  static const suggested = DailyGoal(
    type: GoalType.steps,
    stepTarget: 6000,
    distanceTarget: Meters(4000),
  );

  // Allowed ranges. The database enforces the same limits with CHECK
  // constraints, so an out-of-range goal can never be saved.
  static const minStepTarget = 1000;
  static const maxStepTarget = 30000;
  static const stepTargetIncrement = 500;
  static const minDistanceTarget = Meters(500);
  static const maxDistanceTarget = Meters(30000);
  static const distanceTargetIncrement = Meters(500);

  final GoalType type;
  final int stepTarget;
  final Meters distanceTarget;

  DailyGoal copyWith({
    GoalType? type,
    int? stepTarget,
    Meters? distanceTarget,
  }) {
    return DailyGoal(
      type: type ?? this.type,
      stepTarget: stepTarget ?? this.stepTarget,
      distanceTarget: distanceTarget ?? this.distanceTarget,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DailyGoal &&
      other.type == type &&
      other.stepTarget == stepTarget &&
      other.distanceTarget == distanceTarget;

  @override
  int get hashCode => Object.hash(type, stepTarget, distanceTarget);

  @override
  String toString() =>
      'DailyGoal($type, $stepTarget steps, ${distanceTarget.value} m)';
}
