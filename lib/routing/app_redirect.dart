import 'package:galitrack/routing/routes.dart';

/// The onboarding guard, as a pure function: no I/O, no navigation.
///
/// Returns where to send the user instead of [location], or null to allow
/// it. It never redirects a location to itself, so it cannot loop.
String? appRedirect({
  required bool onboardingCompleted,
  required String location,
}) {
  final onOnboarding = location == Routes.onboarding;
  if (!onboardingCompleted) return onOnboarding ? null : Routes.onboarding;
  return onOnboarding ? Routes.home : null;
}
