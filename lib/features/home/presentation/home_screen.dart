import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/features/home/presentation/home_notifier.dart';
import 'package:galitrack/features/home/presentation/home_state.dart';
import 'package:galitrack/features/home/presentation/widgets/streak_card.dart';
import 'package:galitrack/features/home/presentation/widgets/today_goal_card.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/routing/routes.dart';
import 'package:galitrack/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';

/// "Today": progress towards the daily goal, the streak, and Start walk.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeNotifierProvider);
    return Scaffold(
      body: SafeArea(
        child: home.when(
          data: (state) => _HomeContent(state: state),
          error: (_, _) =>
              _HomeError(onRetry: () => ref.invalidate(homeNotifierProvider)),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = AppSpacing.of(context);
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(
        spacing.lg,
        spacing.md,
        spacing.lg,
        spacing.xl,
      ),
      children: [
        _HomeHeader(date: state.date),
        SizedBox(height: spacing.lg),
        TodayGoalCard(state: state),
        SizedBox(height: spacing.md),
        StreakCard(days: state.streakDays),
        SizedBox(height: spacing.xl),
        FilledButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.trackingComingSoon)),
          ),
          icon: const Icon(Icons.directions_walk),
          label: Text(l10n.startWalk),
        ),
      ],
    );
  }
}

/// An editorial header: the date as a small coloured eyebrow over a big
/// "Today", with settings tucked in the corner.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.date});

  final DateTime date;

  static const _eyebrowLetterSpacing = 1.2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.todayDate(date),
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                  letterSpacing: _eyebrowLetterSpacing,
                ),
              ),
              Semantics(
                header: true,
                child: Text(l10n.homeTitle, style: textTheme.displaySmall),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: l10n.settingsTooltip,
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(Routes.settings),
        ),
      ],
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = AppSpacing.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.all(spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.homeLoadFailed, textAlign: TextAlign.center),
            SizedBox(height: spacing.md),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(l10n.actionTryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
