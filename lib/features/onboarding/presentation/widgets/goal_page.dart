import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/core/models/daily_goal.dart';
import 'package:galitrack/features/onboarding/presentation/onboarding_notifier.dart';
import 'package:galitrack/features/onboarding/presentation/widgets/onboarding_page_frame.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/theme/app_spacing.dart';
import 'package:galitrack/ui/value_adjuster.dart';

/// Page 3: what the daily goal counts, and its targets.
class GoalPage extends ConsumerWidget {
  const GoalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final spacing = AppSpacing.of(context);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final goal = ref.watch(
      onboardingNotifierProvider.select((state) => state.goal),
    );

    return OnboardingPageFrame(
      headline: l10n.goalHeadline,
      body: l10n.goalBody,
      children: [
        SegmentedButton<GoalType>(
          segments: [
            ButtonSegment(
              value: GoalType.steps,
              label: Text(l10n.goalTypeSteps),
            ),
            ButtonSegment(
              value: GoalType.distance,
              label: Text(l10n.goalTypeDistance),
            ),
            ButtonSegment(value: GoalType.both, label: Text(l10n.goalTypeBoth)),
          ],
          selected: {goal.type},
          onSelectionChanged: (selection) =>
              notifier.setGoalType(selection.single),
        ),
        if (goal.type.countsSteps) ...[
          SizedBox(height: spacing.xl),
          ValueAdjuster(
            label: l10n.stepTargetLabel,
            value: goal.stepTarget.toDouble(),
            min: DailyGoal.minStepTarget.toDouble(),
            max: DailyGoal.maxStepTarget.toDouble(),
            step: DailyGoal.stepTargetIncrement.toDouble(),
            formatValue: (steps) => l10n.stepTargetValue(steps.round()),
            onChanged: notifier.setStepTarget,
          ),
        ],
        if (goal.type.countsDistance) ...[
          SizedBox(height: spacing.xl),
          ValueAdjuster(
            label: l10n.distanceTargetLabel,
            value: goal.distanceTarget.inKilometers,
            min: DailyGoal.minDistanceTarget.inKilometers,
            max: DailyGoal.maxDistanceTarget.inKilometers,
            step: DailyGoal.distanceTargetIncrement.inKilometers,
            formatValue: l10n.distanceTargetValue,
            onChanged: notifier.setDistanceTargetKilometers,
          ),
        ],
      ],
    );
  }
}
