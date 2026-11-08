import 'package:galitrack/core/app_log.dart';
import 'package:galitrack/core/clock_provider.dart';
import 'package:galitrack/data/db/app_database.dart';
import 'package:galitrack/data/repositories/goal_repository.dart';
import 'package:galitrack/data/repositories/onboarding_repository.dart';
import 'package:galitrack/data/repositories/settings_repository.dart';
import 'package:riverpod/riverpod.dart';

/// Throws until bootstrap() overrides it with the opened database. Tests
/// override it with an in-memory database.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError(
    'appDatabaseProvider is overridden in bootstrap()',
  ),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(appLogProvider),
  ),
);

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepository(ref.watch(appDatabaseProvider)),
);

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(appLogProvider),
    ref.watch(clockProvider),
  ),
);
