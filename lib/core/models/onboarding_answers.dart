import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/core/models/user_profile.dart';
import 'package:meta/meta.dart';

/// Everything onboarding collects, saved together in one transaction.
///
/// The theme is not here: it is saved the moment the user picks it, so the
/// whole app can preview it live.
@immutable
final class OnboardingAnswers {
  const OnboardingAnswers({required this.profile, required this.goal});

  final UserProfile profile;
  final DailyGoal goal;

  @override
  bool operator ==(Object other) =>
      other is OnboardingAnswers &&
      other.profile == profile &&
      other.goal == goal;

  @override
  int get hashCode => Object.hash(profile, goal);
}
