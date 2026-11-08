import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/app_settings.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/routing/app_router.dart';
import 'package:galitrack/theme/app_theme.dart';
import 'package:galitrack/theme/theme_mode.dart';

/// The root widget. It knows nothing about how its dependencies are built;
/// bootstrap() wires them through ProviderScope overrides.
class GaliTrackApp extends ConsumerWidget {
  const GaliTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themePreference = ref.watch(
      appSettingsProvider.select((settings) => settings.themePreference),
    );
    return MaterialApp.router(
      routerConfig: router,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: themeModeFor(themePreference),
      // Theme changes are instant, so there is no animation to switch off
      // for users who turned animations off.
      themeAnimationStyle: AnimationStyle.noAnimation,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
