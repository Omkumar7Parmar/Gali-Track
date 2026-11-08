import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:galitrack/core/app_log.dart';
import 'package:galitrack/core/calendar_day.dart';
import 'package:galitrack/core/failure.dart';
import 'package:galitrack/core/models/onboarding_answers.dart';
import 'package:galitrack/core/result.dart';
import 'package:galitrack/data/db/app_database.dart';
import 'package:galitrack/data/mappers/goal_mapper.dart';
import 'package:galitrack/data/repositories/guarded_write.dart';
import 'package:meta/meta.dart';

/// Saves the answers collected during onboarding.
class OnboardingRepository {
  OnboardingRepository(this._database, this._log, this._clock);

  final AppDatabase _database;
  final AppLog _log;
  final Clock _clock;

  /// Saves the profile and the first goal, then marks onboarding done, all
  /// in one transaction: either everything is saved or nothing is.
  @useResult
  Future<Result<void, StorageFailure>> complete(OnboardingAnswers answers) {
    final today = CalendarDay.of(_clock.now());
    return guardedWrite(_log, 'onboarding.complete', () {
      return _database.transaction(() async {
        await _database.goalHistoryDao.upsert(
          goalToCompanion(answers.goal, today),
        );
        await _database.appSettingsDao.updateRow(
          AppSettingsTableCompanion(
            weightGrams: Value(answers.profile.weight.value),
            heightCentimeters: Value(answers.profile.height?.value),
            onboardingCompleted: const Value(true),
          ),
        );
      });
    });
  }
}
