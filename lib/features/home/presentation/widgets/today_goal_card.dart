import 'package:flutter/material.dart';
import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/features/home/presentation/home_state.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/theme/app_colors.dart';
import 'package:galitrack/theme/app_shapes.dart';
import 'package:galitrack/theme/app_spacing.dart';
import 'package:galitrack/ui/progress_ring.dart';

/// Today's progress: rings for the goal type, then a line per target.
///
/// The rings are decorative; the text lines carry the numbers for screen
/// readers. Steps are always marigold and outermost; distance is teal.
class TodayGoalCard extends StatelessWidget {
  const TodayGoalCard({required this.state, super.key});

  final HomeState state;

  static const _ringAreaHeight = 220.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = AppColors.of(context);
    final spacing = AppSpacing.of(context);
    final goal = state.goal;

    return Card(
      child: Padding(
        padding: EdgeInsetsDirectional.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.todayGoalTitle, style: textTheme.titleMedium),
            ),
            SizedBox(height: spacing.md),
            SizedBox(
              height: _ringAreaHeight,
              child: _GoalRings(state: state),
            ),
            SizedBox(height: spacing.md),
            if (goal.type.countsSteps)
              _GoalLine(
                icon: Icons.directions_walk,
                color: colors.stepsAccent,
                text: l10n.stepsProgress(state.stepsToday, goal.stepTarget),
              ),
            if (goal.type.countsDistance)
              _GoalLine(
                icon: Icons.straighten,
                color: colors.distanceAccent,
                text: l10n.distanceProgress(
                  state.distanceToday.inKilometers,
                  goal.distanceTarget.inKilometers,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalRings extends StatelessWidget {
  const _GoalRings({required this.state});

  final HomeState state;

  static const _innerRingScale = 0.74;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final shapes = AppShapes.of(context);
    final type = state.goal.type;
    final stepsRing = ProgressRing(
      progress: state.stepProgress,
      color: colors.stepsAccent,
      trackColor: colors.ringTrack,
      strokeWidth: shapes.ringStroke,
    );
    final distanceRing = ProgressRing(
      progress: state.distanceProgress,
      color: colors.distanceAccent,
      trackColor: colors.ringTrack,
      strokeWidth: shapes.ringStroke,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        switch (type) {
          GoalType.steps || GoalType.both => stepsRing,
          GoalType.distance => distanceRing,
        },
        if (type == GoalType.both)
          FractionallySizedBox(
            widthFactor: _innerRingScale,
            heightFactor: _innerRingScale,
            child: distanceRing,
          ),
        _RingCenter(state: state),
      ],
    );
  }
}

/// The headline number inside the rings: steps if they count, else km.
/// Hidden from screen readers because the goal lines below say the same.
class _RingCenter extends StatelessWidget {
  const _RingCenter({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final showSteps = state.goal.type.countsSteps;
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            showSteps
                ? l10n.ringStepsValue(state.stepsToday)
                : l10n.ringDistanceValue(state.distanceToday.inKilometers),
            style: textTheme.displaySmall,
          ),
          Text(
            showSteps ? l10n.ringStepsCaption : l10n.ringDistanceCaption,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalLine extends StatelessWidget {
  const _GoalLine({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(top: spacing.xs),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
