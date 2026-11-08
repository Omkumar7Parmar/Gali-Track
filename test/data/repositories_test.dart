import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galitrack/core/calendar_day.dart';
import 'package:galitrack/core/failure.dart';
import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/core/models/onboarding_answers.dart';
import 'package:galitrack/core/models/theme_preference.dart';
import 'package:galitrack/core/models/user_profile.dart';
import 'package:galitrack/core/result.dart';
import 'package:galitrack/core/units.dart';
import 'package:galitrack/data/db/app_database.dart';
import 'package:galitrack/data/mappers/goal_mapper.dart';
import 'package:galitrack/data/repositories/goal_repository.dart';
import 'package:galitrack/data/repositories/onboarding_repository.dart';
import 'package:galitrack/data/repositories/settings_repository.dart';

import '../helpers/fake_app_log.dart';
import '../helpers/test_harness.dart';

void main() {
  late AppDatabase database;
  late FakeAppLog log;

  setUp(() {
    database = createTestDatabase();
    addTearDown(database.close);
    log = FakeAppLog();
  });

  group('SettingsRepository', () {
    test('a saved theme is emitted by watch()', () async {
      final repository = SettingsRepository(database, log);
      final themes = repository.watch().map(
        (settings) => settings.themePreference,
      );
      final expectation = expectLater(
        themes,
        emitsThrough(ThemePreference.dark),
      );

      final result = await repository.setThemePreference(ThemePreference.dark);

      expect(result, isA<Ok<void, StorageFailure>>());
      await expectation;
    });
  });

  group('OnboardingRepository', () {
    const answers = OnboardingAnswers(
      profile: UserProfile(weight: Grams(70500), height: Centimeters(172)),
      goal: DailyGoal(
        type: GoalType.both,
        stepTarget: 8000,
        distanceTarget: Meters(5000),
      ),
    );
    final today = CalendarDay.of(testNow);

    test(
      'saves the profile, the goal from today, and marks onboarding done',
      () async {
        final repository = OnboardingRepository(
          database,
          log,
          Clock.fixed(testNow),
        );

        final result = await repository.complete(answers);

        expect(result, isA<Ok<void, StorageFailure>>());
        final settings = await SettingsRepository(database, log).load();
        expect(settings.onboardingCompleted, isTrue);
        expect(settings.profile, answers.profile);
        expect(
          await GoalRepository(database).watchGoalOn(today).first,
          answers.goal,
        );
      },
    );

    test(
      'is all-or-nothing: a rejected profile leaves no goal behind',
      () async {
        final repository = OnboardingRepository(
          database,
          log,
          Clock.fixed(testNow),
        );
        const invalid = OnboardingAnswers(
          profile: UserProfile(weight: Grams(1)),
          goal: DailyGoal.suggested,
        );

        final result = await repository.complete(invalid);

        expect(result, isA<Err<void, StorageFailure>>());
        expect(log.errorCodes, ['onboarding.complete']);
        expect(await GoalRepository(database).watchGoalOn(today).first, isNull);
        expect(
          (await SettingsRepository(database, log).load()).onboardingCompleted,
          isFalse,
        );
      },
    );
  });

  group('GoalRepository', () {
    const firstGoal = DailyGoal(
      type: GoalType.steps,
      stepTarget: 5000,
      distanceTarget: Meters(3000),
    );
    const laterGoal = DailyGoal(
      type: GoalType.distance,
      stepTarget: 5000,
      distanceTarget: Meters(6000),
    );
    const day100 = CalendarDay.fromSerial(100);

    Future<void> setGoal(DailyGoal goal, CalendarDay from) {
      return database.goalHistoryDao.upsert(goalToCompanion(goal, from));
    }

    test('each day uses the latest goal set on or before it', () async {
      await setGoal(firstGoal, day100);
      await setGoal(laterGoal, day100.plusDays(5));
      final goals = GoalRepository(database);

      expect(await goals.watchGoalOn(day100.plusDays(-1)).first, isNull);
      expect(await goals.watchGoalOn(day100).first, firstGoal);
      expect(await goals.watchGoalOn(day100.plusDays(4)).first, firstGoal);
      expect(await goals.watchGoalOn(day100.plusDays(5)).first, laterGoal);
      expect(await goals.watchGoalOn(day100.plusDays(400)).first, laterGoal);
    });

    test('a second change on the same day replaces the first', () async {
      await setGoal(firstGoal, day100);
      await setGoal(laterGoal, day100);

      expect(
        await GoalRepository(database).watchGoalOn(day100).first,
        laterGoal,
      );
      final rows = await database.select(database.goalHistoryTable).get();
      expect(rows, hasLength(1));
    });
  });
}
