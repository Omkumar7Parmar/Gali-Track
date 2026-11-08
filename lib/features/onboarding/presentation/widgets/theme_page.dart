import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/app_settings.dart';
import 'package:galitrack/core/models/theme_preference.dart';
import 'package:galitrack/features/onboarding/presentation/onboarding_notifier.dart';
import 'package:galitrack/features/onboarding/presentation/widgets/onboarding_page_frame.dart';
import 'package:galitrack/features/onboarding/presentation/widgets/theme_preview_card.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/theme/app_spacing.dart';
import 'package:galitrack/theme/app_theme.dart';

/// Page 4: light or dark, picked from live previews of the home screen.
///
/// Tapping a preview saves the choice at once, so the whole onboarding
/// flow switches to it too.
class ThemePage extends ConsumerWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final spacing = AppSpacing.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final preference = ref.watch(
      appSettingsProvider.select((settings) => settings.themePreference),
    );

    return OnboardingPageFrame(
      headline: l10n.themeHeadline,
      body: l10n.themeBody,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ThemePreviewCard(
                theme: appLightTheme,
                label: l10n.themeLight,
                selected: preference == ThemePreference.light,
                onTap: () => notifier.chooseTheme(ThemePreference.light),
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: ThemePreviewCard(
                theme: appDarkTheme,
                label: l10n.themeDark,
                selected: preference == ThemePreference.dark,
                onTap: () => notifier.chooseTheme(ThemePreference.dark),
              ),
            ),
          ],
        ),
        if (preference == ThemePreference.system) ...[
          SizedBox(height: spacing.lg),
          Text(
            l10n.themeFollowingPhone,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
