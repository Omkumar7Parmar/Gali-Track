import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galitrack/core/models/user_profile.dart';
import 'package:galitrack/features/onboarding/presentation/onboarding_notifier.dart';
import 'package:galitrack/features/onboarding/presentation/widgets/onboarding_page_frame.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/theme/app_spacing.dart';
import 'package:galitrack/ui/value_adjuster.dart';

/// Page 2: weight (required) and height (optional).
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final spacing = AppSpacing.of(context);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final weight = ref.watch(
      onboardingNotifierProvider.select((state) => state.weight),
    );
    final height = ref.watch(
      onboardingNotifierProvider.select((state) => state.height),
    );
    final heightIncluded = ref.watch(
      onboardingNotifierProvider.select((state) => state.heightIncluded),
    );

    return OnboardingPageFrame(
      headline: l10n.profileHeadline,
      body: l10n.profileBody,
      children: [
        ValueAdjuster(
          label: l10n.weightLabel,
          value: weight.inKilograms,
          min: UserProfile.minWeight.inKilograms,
          max: UserProfile.maxWeight.inKilograms,
          step: UserProfile.weightIncrement.inKilograms,
          formatValue: l10n.weightValue,
          onChanged: notifier.setWeightKilograms,
        ),
        SizedBox(height: spacing.lg),
        SwitchListTile(
          contentPadding: EdgeInsetsDirectional.zero,
          title: Text(l10n.heightToggle),
          subtitle: Text(l10n.heightHint),
          value: heightIncluded,
          onChanged: (included) =>
              notifier.setHeightIncluded(included: included),
        ),
        if (heightIncluded) ...[
          SizedBox(height: spacing.md),
          ValueAdjuster(
            label: l10n.heightLabel,
            value: height.value.toDouble(),
            min: UserProfile.minHeight.value.toDouble(),
            max: UserProfile.maxHeight.value.toDouble(),
            step: UserProfile.heightIncrement.value.toDouble(),
            formatValue: (centimeters) => l10n.heightValue(centimeters.round()),
            onChanged: notifier.setHeightCentimeters,
          ),
        ],
      ],
    );
  }
}
