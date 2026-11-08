import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/core/models/theme_preference.dart';
import 'package:galitrack/features/settings/presentation/settings_notifier.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/theme/app_spacing.dart';
import 'package:galitrack/ui/failure_message.dart';
import 'package:galitrack/ui/save_status.dart';

/// Settings: the theme now; profile and goal editing arrive in Week 4.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final spacing = AppSpacing.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    ref.listen(settingsNotifierProvider.select((state) => state.saveStatus), (
      _,
      status,
    ) {
      if (status case SaveFailed(:final failure)) {
        final message = failureMessage(AppLocalizations.of(context), failure);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
    final preference = ref.watch(
      settingsNotifierProvider.select((state) => state.themePreference),
    );
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsetsDirectional.all(spacing.lg),
          children: [
            _SectionHeader(text: l10n.appearanceSection),
            SegmentedButton<ThemePreference>(
              segments: [
                ButtonSegment(
                  value: ThemePreference.light,
                  icon: const Icon(Icons.light_mode_outlined),
                  label: Text(l10n.themeLight),
                ),
                ButtonSegment(
                  value: ThemePreference.dark,
                  icon: const Icon(Icons.dark_mode_outlined),
                  label: Text(l10n.themeDark),
                ),
                ButtonSegment(
                  value: ThemePreference.system,
                  icon: const Icon(Icons.phone_android),
                  label: Text(l10n.themeSystem),
                ),
              ],
              selected: {preference},
              onSelectionChanged: (selection) =>
                  notifier.chooseTheme(selection.single),
            ),
            SizedBox(height: spacing.xs),
            Text(
              l10n.themeSystemHint,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.xl),
            _SectionHeader(text: l10n.aboutSection),
            ListTile(
              contentPadding: EdgeInsetsDirectional.zero,
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.openSourceLicences),
              onTap: () => showLicensePage(
                context: context,
                applicationName: l10n.appTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: spacing.sm),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: scheme.primary),
        ),
      ),
    );
  }
}
