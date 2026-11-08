import 'package:flutter_test/flutter_test.dart';
import 'package:galitrack/routing/app_redirect.dart';
import 'package:galitrack/routing/routes.dart';

void main() {
  const locations = [
    Routes.home,
    Routes.onboarding,
    Routes.settings,
    '/unknown',
  ];

  test('a new user is always sent to onboarding', () {
    for (final location in locations) {
      final expected = location == Routes.onboarding ? null : Routes.onboarding;
      expect(
        appRedirect(onboardingCompleted: false, location: location),
        expected,
        reason: location,
      );
    }
  });

  test('a returning user can go anywhere except back into onboarding', () {
    for (final location in locations) {
      final expected = location == Routes.onboarding ? Routes.home : null;
      expect(
        appRedirect(onboardingCompleted: true, location: location),
        expected,
        reason: location,
      );
    }
  });

  test('never loops: wherever it redirects to is allowed', () {
    for (final completed in [false, true]) {
      for (final location in locations) {
        final target = appRedirect(
          onboardingCompleted: completed,
          location: location,
        );
        if (target == null) continue;
        expect(
          appRedirect(onboardingCompleted: completed, location: target),
          isNull,
          reason: 'completed=$completed location=$location target=$target',
        );
      }
    }
  });
}
