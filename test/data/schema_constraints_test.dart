import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galitrack/core/calendar_day.dart';
import 'package:galitrack/core/models/app_settings.dart';
import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/core/models/user_profile.dart';
import 'package:galitrack/core/units.dart';
import 'package:galitrack/data/db/app_database.dart';
import 'package:galitrack/data/mappers/goal_mapper.dart';
import 'package:galitrack/data/repositories/settings_repository.dart';

import '../helpers/fake_app_log.dart';
import '../helpers/test_harness.dart';

/// These tests pin the database's CHECK limits to the Dart constants, so
/// the two can never drift apart: the exact limits are accepted and one
/// past either limit is rejected by SQLite itself.
void main() {
  late AppDatabase database;

  setUp(() {
    database = createTestDatabase();
    addTearDown(database.close);
  });

  Future<void> updateSettings(AppSettingsTableCompanion changes) {
    return database.appSettingsDao.updateRow(changes);
  }

  Future<void> saveGoal(DailyGoal goal) {
    return database.goalHistoryDao.upsert(
      goalToCompanion(goal, const CalendarDay.fromSerial(20000)),
    );
  }

  final rejectedBySqlite = throwsA(isA<SqliteException>());

  test('a new database starts with the seeded default settings', () async {
    final settings = await SettingsRepository(database, FakeAppLog()).load();
    expect(settings, AppSettings.initial);
  });

  test('foreign keys are switched on for the connection', () async {
    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  test('tables are STRICT: a wrong type is rejected, not coerced', () async {
    await expectLater(
      database.customStatement(
        "UPDATE app_settings SET weight_grams = 'heavy'",
      ),
      rejectedBySqlite,
    );
  });

  test('weight limits match UserProfile', () async {
    final min = UserProfile.minWeight.value;
    final max = UserProfile.maxWeight.value;
    await updateSettings(AppSettingsTableCompanion(weightGrams: Value(min)));
    await updateSettings(AppSettingsTableCompanion(weightGrams: Value(max)));
    await expectLater(
      updateSettings(AppSettingsTableCompanion(weightGrams: Value(min - 1))),
      rejectedBySqlite,
    );
    await expectLater(
      updateSettings(AppSettingsTableCompanion(weightGrams: Value(max + 1))),
      rejectedBySqlite,
    );
  });

  test('height limits match UserProfile', () async {
    final min = UserProfile.minHeight.value;
    final max = UserProfile.maxHeight.value;
    await updateSettings(
      AppSettingsTableCompanion(heightCentimeters: Value(min)),
    );
    await updateSettings(
      AppSettingsTableCompanion(heightCentimeters: Value(max)),
    );
    await expectLater(
      updateSettings(
        AppSettingsTableCompanion(heightCentimeters: Value(min - 1)),
      ),
      rejectedBySqlite,
    );
    await expectLater(
      updateSettings(
        AppSettingsTableCompanion(heightCentimeters: Value(max + 1)),
      ),
      rejectedBySqlite,
    );
  });

  test('only known theme names can be stored', () async {
    await expectLater(
      updateSettings(
        const AppSettingsTableCompanion(themePreference: Value('sepia')),
      ),
      rejectedBySqlite,
    );
  });

  test('onboarding cannot be marked complete without a weight', () async {
    await expectLater(
      updateSettings(
        const AppSettingsTableCompanion(onboardingCompleted: Value(true)),
      ),
      rejectedBySqlite,
    );
  });

  test('step target limits match DailyGoal', () async {
    const goal = DailyGoal.suggested;
    await saveGoal(goal.copyWith(stepTarget: DailyGoal.minStepTarget));
    await saveGoal(goal.copyWith(stepTarget: DailyGoal.maxStepTarget));
    await expectLater(
      saveGoal(goal.copyWith(stepTarget: DailyGoal.minStepTarget - 1)),
      rejectedBySqlite,
    );
    await expectLater(
      saveGoal(goal.copyWith(stepTarget: DailyGoal.maxStepTarget + 1)),
      rejectedBySqlite,
    );
  });

  test('distance target limits match DailyGoal', () async {
    const goal = DailyGoal.suggested;
    final min = DailyGoal.minDistanceTarget.value;
    final max = DailyGoal.maxDistanceTarget.value;
    await saveGoal(goal.copyWith(distanceTarget: Meters(min)));
    await saveGoal(goal.copyWith(distanceTarget: Meters(max)));
    await expectLater(
      saveGoal(goal.copyWith(distanceTarget: Meters(min - 1))),
      rejectedBySqlite,
    );
    await expectLater(
      saveGoal(goal.copyWith(distanceTarget: Meters(max + 1))),
      rejectedBySqlite,
    );
  });

  test('every GoalType can be stored, and nothing else', () async {
    for (final type in GoalType.values) {
      await saveGoal(DailyGoal.suggested.copyWith(type: type));
    }
    await expectLater(
      database.customStatement(
        "UPDATE goal_history SET goal_type = 'calories'",
      ),
      rejectedBySqlite,
    );
  });
}
