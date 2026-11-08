import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/app_settings.dart';
import 'package:galitrack/features/home/presentation/home_screen.dart';
import 'package:galitrack/features/onboarding/presentation/onboarding_screen.dart';
import 'package:galitrack/features/settings/presentation/settings_screen.dart';
import 'package:galitrack/routing/app_redirect.dart';
import 'package:galitrack/routing/not_found_screen.dart';
import 'package:galitrack/routing/routes.dart';
import 'package:go_router/go_router.dart';

/// The app's one router.
///
/// The onboarding guard re-runs whenever the saved onboarding flag changes:
/// finishing onboarding moves the user to Today with no navigation call.
final routerProvider = Provider<GoRouter>((ref) {
  // Bridges the Riverpod value to the Listenable go_router watches.
  final onboardingCompleted = ValueNotifier<bool>(
    ref.read(appSettingsProvider).onboardingCompleted,
  );
  ref
    ..onDispose(onboardingCompleted.dispose)
    ..listen(
      appSettingsProvider.select((settings) => settings.onboardingCompleted),
      (_, completed) => onboardingCompleted.value = completed,
    );

  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: onboardingCompleted,
    redirect: (_, state) => appRedirect(
      onboardingCompleted: onboardingCompleted.value,
      location: state.uri.path,
    ),
    errorBuilder: (_, _) => const NotFoundScreen(),
    routes: [
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
