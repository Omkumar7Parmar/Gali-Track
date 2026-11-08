import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galitrack/core/calendar_day.dart';
import 'package:galitrack/core/failure.dart';
import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/core/models/onboarding_answers.dart';
import 'package:galitrack/core/models/theme_preference.dart';
import 'package:galitrack/core/models/user_profile.dart';
import 'package:galitrack/core/result.dart';
import 'package:galitrack/core/units.dart';
import 'package:galitrack/data/providers.dart';
import 'package:galitrack/data/repositories/onboarding_repository.dart';
import 'package:galitrack/features/onboarding/presentation/onboarding_notifier.dart';
import 'package:galitrack/features/onboarding/presentation/onboarding_state.dart';
import 'package:galitrack/ui/save_status.dart';

import '../../helpers/test_harness.dart';

/// Stands in for the real repository to exercise the failure path.
final class FailingOnboardingRepository implements OnboardingRepository {
  @override
  Future<Result<void, StorageFailure>> complete(
    OnboardingAnswers answers,
  ) async {
    return const Err(StorageWriteFailed('onboarding.complete'));
  }
}

void main() {
  late ProviderContainer container;

  Future<void> open({bool failingSaves = false}) async {
    final scope = await openTestScope(
      extraOverrides: [
        if (failingSaves)
          onboardingRepositoryProvider.overrideWithValue(
            FailingOnboardingRepository(),
          ),
      ],
    );
    // The notifier is autoDispose: keep it alive between reads, as the
    // screen does while it's open.
    container = scope.container..listen(onboardingNotifierProvider, (_, _) {});
  }

  OnboardingNotifier notifier() =>
      container.read(onboardingNotifierProvider.notifier);
  OnboardingState state() => container.read(onboardingNotifierProvider);

  group('snapping and clamping', () {
    setUp(open);

    test('weight snaps to the nearest half kilogram', () {
      notifier().setWeightKilograms(70.26);
      expect(state().weight, const Grams(70500));
    });

    test('weight is clamped to the allowed range', () {
      notifier().setWeightKilograms(900);
      expect(state().weight, UserProfile.maxWeight);
      notifier().setWeightKilograms(-3);
      expect(state().weight, UserProfile.minWeight);
    });

    test('step target snaps to steps of 500, half-way rounding up', () {
      notifier().setStepTarget(6249);
      expect(state().goal.stepTarget, 6000);
      notifier().setStepTarget(6250);
      expect(state().goal.stepTarget, 6500);
    });

    test('distance target snaps to half kilometres', () {
      notifier().setDistanceTargetKilometers(4.26);
      expect(state().goal.distanceTarget, const Meters(4500));
    });

    test('switching the goal type keeps both targets', () {
      notifier()
        ..setStepTarget(9000)
        ..setGoalType(GoalType.distance)
        ..setGoalType(GoalType.steps);
      expect(state().goal.stepTarget, 9000);
    });

    test('height is only saved while included, and is remembered when off', () {
      notifier()
        ..setHeightCentimeters(172.4)
        ..setHeightIncluded(included: true);
      expect(state().answers.profile.height, const Centimeters(172));

      notifier().setHeightIncluded(included: false);
      expect(state().answers.profile.height, isNull);

      notifier().setHeightIncluded(included: true);
      expect(state().answers.profile.height, const Centimeters(172));
    });
  });

  group('saving', () {
    test('finish saves the answers and marks onboarding complete', () async {
      await open();
      notifier()
        ..setWeightKilograms(58)
        ..setGoalType(GoalType.both)
        ..setStepTarget(8000)
        ..setDistanceTargetKilometers(5);

      notifier().finish();
      final settings = await container
          .read(settingsRepositoryProvider)
          .watch()
          .firstWhere((settings) => settings.onboardingCompleted)
          .timeout(const Duration(seconds: 5));

      expect(settings.profile, const UserProfile(weight: Grams(58000)));
      final goal = await container
          .read(goalRepositoryProvider)
          .watchGoalOn(CalendarDay.of(testNow))
          .first;
      expect(
        goal,
        const DailyGoal(
          type: GoalType.both,
          stepTarget: 8000,
          distanceTarget: Meters(5000),
        ),
      );
    });

    test('choosing a theme saves it straight away', () async {
      await open();

      notifier().chooseTheme(ThemePreference.dark);
      final settings = await container
          .read(settingsRepositoryProvider)
          .watch()
          .firstWhere(
            (settings) => settings.themePreference == ThemePreference.dark,
          )
          .timeout(const Duration(seconds: 5));

      expect(settings.themePreference, ThemePreference.dark);
    });

    test('a failed save reports the failure and keeps every answer', () async {
      await open(failingSaves: true);
      notifier().setWeightKilograms(80);
      final failed = Completer<SaveFailed>();
      container.listen(
        onboardingNotifierProvider.select((state) => state.saveStatus),
        (_, status) {
          if (status is SaveFailed && !failed.isCompleted) {
            failed.complete(status);
          }
        },
      );

      notifier().finish();
      final status = await failed.future.timeout(const Duration(seconds: 5));

      expect(status.failure, isA<StorageWriteFailed>());
      expect(state().weight, const Grams(80000));
      expect(state().isSaving, isFalse);
    });
  });
}
