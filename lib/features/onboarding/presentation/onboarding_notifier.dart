import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/core/failure.dart';
import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/core/models/theme_preference.dart';
import 'package:galitrack/core/models/user_profile.dart';
import 'package:galitrack/core/numeric.dart';
import 'package:galitrack/core/result.dart';
import 'package:galitrack/core/units.dart';
import 'package:galitrack/data/providers.dart';
import 'package:galitrack/features/onboarding/presentation/onboarding_state.dart';
import 'package:galitrack/ui/save_status.dart';

/// The onboarding view model. Disposed when the user leaves onboarding.
final NotifierProvider<OnboardingNotifier, OnboardingState>
onboardingNotifierProvider =
    NotifierProvider.autoDispose<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

/// Holds the answers while the user moves through onboarding.
///
/// Widgets call the intent methods below; each one assigns a new state.
/// Values are snapped and clamped here, so the screens can only show values
/// the database accepts.
class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => OnboardingState.initial;

  void setWeightKilograms(double kilograms) {
    final grams = snapToStep(
      kilograms * 1000,
      step: UserProfile.weightIncrement.value,
      min: UserProfile.minWeight.value,
      max: UserProfile.maxWeight.value,
    );
    state = state.copyWith(weight: Grams(grams));
  }

  void setHeightCentimeters(double centimeters) {
    final snapped = snapToStep(
      centimeters,
      step: UserProfile.heightIncrement.value,
      min: UserProfile.minHeight.value,
      max: UserProfile.maxHeight.value,
    );
    state = state.copyWith(height: Centimeters(snapped));
  }

  void setHeightIncluded({required bool included}) {
    state = state.copyWith(heightIncluded: included);
  }

  void setGoalType(GoalType type) {
    state = state.copyWith(goal: state.goal.copyWith(type: type));
  }

  void setStepTarget(double steps) {
    final snapped = snapToStep(
      steps,
      step: DailyGoal.stepTargetIncrement,
      min: DailyGoal.minStepTarget,
      max: DailyGoal.maxStepTarget,
    );
    state = state.copyWith(goal: state.goal.copyWith(stepTarget: snapped));
  }

  void setDistanceTargetKilometers(double kilometers) {
    final meters = snapToStep(
      kilometers * 1000,
      step: DailyGoal.distanceTargetIncrement.value,
      min: DailyGoal.minDistanceTarget.value,
      max: DailyGoal.maxDistanceTarget.value,
    );
    state = state.copyWith(
      goal: state.goal.copyWith(distanceTarget: Meters(meters)),
    );
  }

  /// Saves the theme straight away, so the whole app previews it live.
  void chooseTheme(ThemePreference preference) {
    unawaited(
      _save(
        () =>
            ref.read(settingsRepositoryProvider).setThemePreference(preference),
      ),
    );
  }

  /// Saves every answer. On success the router leaves onboarding by itself,
  /// because the saved settings now say onboarding is complete.
  void finish() {
    if (state.isSaving) return;
    unawaited(
      _save(
        () => ref.read(onboardingRepositoryProvider).complete(state.answers),
      ),
    );
  }

  Future<void> _save(
    Future<Result<void, StorageFailure>> Function() write,
  ) async {
    state = state.copyWith(saveStatus: const SaveInProgress());
    final result = await write();
    // The user may already have left onboarding while the save ran.
    if (!ref.mounted) return;
    final status = switch (result) {
      Ok() => const SaveIdle(),
      Err(:final failure) => SaveFailed(failure),
    };
    state = state.copyWith(saveStatus: status);
  }
}
