import 'package:clock/clock.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:galitrack/app_settings.dart';
import 'package:galitrack/core/app_log.dart';
import 'package:galitrack/core/clock_provider.dart';
import 'package:galitrack/data/db/app_database.dart';
import 'package:galitrack/data/providers.dart';
import 'package:galitrack/data/repositories/settings_repository.dart';

import 'fake_app_log.dart';

/// The frozen "now" used by every test: 8 Nov 2026, 09:30 local time.
final DateTime testNow = DateTime(2026, 11, 8, 9, 30);

/// A fresh, empty database that lives in memory: real SQLite, real
/// constraints, nothing on disk.
///
/// Each test gets its own in-memory database, so Drift's warning about the
/// same database class being opened twice does not apply here.
AppDatabase createTestDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// The overrides that wire the app to [database], [log] and a fixed clock,
/// the same seams bootstrap() uses in the real app.
Future<List<Override>> buildTestOverrides({
  required AppDatabase database,
  required AppLog log,
  Clock? clock,
}) async {
  final initialSettings = await SettingsRepository(database, log).load();
  return [
    appDatabaseProvider.overrideWithValue(database),
    appLogProvider.overrideWithValue(log),
    initialSettingsProvider.overrideWithValue(initialSettings),
    clockProvider.overrideWithValue(clock ?? Clock.fixed(testNow)),
  ];
}

/// A headless Riverpod container over a fresh in-memory database.
///
/// Teardown is registered here: the container is disposed first, then the
/// database closed, so no stream outlives the test.
Future<({AppDatabase database, FakeAppLog log, ProviderContainer container})>
openTestScope({
  List<Override> extraOverrides = const [],
}) async {
  final database = createTestDatabase();
  addTearDown(database.close);
  final log = FakeAppLog();
  final overrides = await buildTestOverrides(database: database, log: log);
  final container = ProviderContainer(
    overrides: [...overrides, ...extraOverrides],
  );
  addTearDown(container.dispose);
  return (database: database, log: log, container: container);
}

/// Pumps in 100 ms steps until [finder] matches, failing after [maxPumps].
///
/// Used instead of pumpAndSettle where a spinner may be on screen, since a
/// spinner never settles.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 50,
}) async {
  for (var pumps = 0; pumps < maxPumps; pumps++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

/// Pumps in 100 ms steps until [condition] holds, failing after [maxPumps].
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  int maxPumps = 50,
}) async {
  for (var pumps = 0; pumps < maxPumps; pumps++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (condition()) return;
  }
  throw TestFailure('Timed out waiting for the condition');
}
