import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galitrack/app.dart';
import 'package:galitrack/core/calendar_day.dart';
import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/core/models/onboarding_answers.dart';
import 'package:galitrack/core/models/theme_preference.dart';
import 'package:galitrack/core/models/user_profile.dart';
import 'package:galitrack/data/db/app_database.dart';
import 'package:galitrack/data/repositories/goal_repository.dart';
import 'package:galitrack/data/repositories/onboarding_repository.dart';
import 'package:galitrack/data/repositories/settings_repository.dart';

import 'helpers/fake_app_log.dart';
import 'helpers/test_harness.dart';

/// Acceptance tests: the real app, wired exactly as bootstrap() wires it,
/// over an in-memory database.
void main() {
  late AppDatabase database;
  late FakeAppLog log;

  setUp(() {
    database = createTestDatabase();
    log = FakeAppLog();
  });

  Future<void> launchApp(WidgetTester tester) async {
    // A typical Android phone: 360 x 800 logical pixels.
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final overrides = await tester.runAsync(
      () => buildTestOverrides(database: database, log: log),
    );
    await tester.pumpWidget(
      ProviderScope(overrides: overrides!, child: const GaliTrackApp()),
    );
  }

  /// Unmounts the app before closing the database, so no query stream is
  /// still listening when the connection goes away.
  Future<void> shutDown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    await tester.runAsync(database.close);
  }

  ThemeMode themeModeOf(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

  Future<void> tapNext(WidgetTester tester) async {
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  }

  /// Scrolls [finder] into view, then taps it, like a user would.
  Future<void> scrollToAndTap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  testWidgets('a new user goes through onboarding and lands on Today', (
    tester,
  ) async {
    await launchApp(tester);
    await pumpUntilFound(tester, find.text('Walk your galis'));

    await tapNext(tester);
    expect(find.text('About you'), findsOneWidget);
    expect(find.text('65.0 kg'), findsOneWidget);

    await tapNext(tester);
    expect(find.text('Your daily goal'), findsOneWidget);
    expect(find.text('6,000 steps'), findsOneWidget);

    await tapNext(tester);
    expect(find.text('Choose your look'), findsOneWidget);
    expect(themeModeOf(tester), ThemeMode.system);

    // Picking a preview restyles the whole app at once.
    await scrollToAndTap(tester, find.text('Dark'));
    await pumpUntil(tester, () => themeModeOf(tester) == ThemeMode.dark);

    await tester.tap(find.text('Start walking'));
    await pumpUntilFound(tester, find.text("Today's goal"));
    expect(find.text('0 of 6,000 steps'), findsOneWidget);
    expect(find.text('No streak yet'), findsOneWidget);

    // Everything the user chose is in the database, not just on screen.
    final saved = await tester.runAsync(
      () => SettingsRepository(database, log).load(),
    );
    expect(saved!.onboardingCompleted, isTrue);
    expect(saved.themePreference, ThemePreference.dark);
    expect(
      saved.profile,
      const UserProfile(weight: UserProfile.suggestedWeight),
    );
    final goal = await tester.runAsync(
      () => GoalRepository(database).watchGoalOn(CalendarDay.of(testNow)).first,
    );
    expect(goal, DailyGoal.suggested);
    expect(log.errorCodes, isEmpty);

    await shutDown(tester);
  });

  testWidgets('a returning user opens on Today and can change the theme', (
    tester,
  ) async {
    await tester.runAsync(
      () => OnboardingRepository(database, log, Clock.fixed(testNow)).complete(
        const OnboardingAnswers(
          profile: UserProfile(weight: UserProfile.suggestedWeight),
          goal: DailyGoal.suggested,
        ),
      ),
    );

    await launchApp(tester);
    await pumpUntilFound(tester, find.text("Today's goal"));
    expect(find.text('Walk your galis'), findsNothing);

    await tester.tap(find.byTooltip('Settings'));
    await pumpUntilFound(tester, find.text('Appearance'));
    await scrollToAndTap(tester, find.text('Light'));
    await pumpUntil(tester, () => themeModeOf(tester) == ThemeMode.light);

    final saved = await tester.runAsync(
      () => SettingsRepository(database, log).load(),
    );
    expect(saved!.themePreference, ThemePreference.light);

    await shutDown(tester);
  });
}
