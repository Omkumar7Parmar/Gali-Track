import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/core/models/onboarding_answers.dart';
import 'package:galitrack/core/models/user_profile.dart';
import 'package:galitrack/core/units.dart';
import 'package:galitrack/ui/save_status.dart';
import 'package:meta/meta.dart';

/// Everything the onboarding screens show, as one immutable value.
@immutable
final class OnboardingState {
  const OnboardingState({
    required this.weight,
    required this.height,
    required this.heightIncluded,
    required this.goal,
    this.saveStatus = const SaveIdle(),
  });

  /// The answers a new user starts with.
  static const initial = OnboardingState(
    weight: UserProfile.suggestedWeight,
    height: UserProfile.suggestedHeight,
    heightIncluded: false,
    goal: DailyGoal.suggested,
  );

  final Grams weight;

  /// Kept even while [heightIncluded] is off, so turning it back on restores
  /// the last value.
  final Centimeters height;
  final bool heightIncluded;
  final DailyGoal goal;
  final SaveStatus saveStatus;

  bool get isSaving => saveStatus is SaveInProgress;

  /// The answers to save when the user finishes.
  OnboardingAnswers get answers => OnboardingAnswers(
    profile: UserProfile(
      weight: weight,
      height: heightIncluded ? height : null,
    ),
    goal: goal,
  );

  OnboardingState copyWith({
    Grams? weight,
    Centimeters? height,
    bool? heightIncluded,
    DailyGoal? goal,
    SaveStatus? saveStatus,
  }) {
    return OnboardingState(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      heightIncluded: heightIncluded ?? this.heightIncluded,
      goal: goal ?? this.goal,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is OnboardingState &&
      other.weight == weight &&
      other.height == height &&
      other.heightIncluded == heightIncluded &&
      other.goal == goal &&
      other.saveStatus == saveStatus;

  @override
  int get hashCode =>
      Object.hash(weight, height, heightIncluded, goal, saveStatus);
}
