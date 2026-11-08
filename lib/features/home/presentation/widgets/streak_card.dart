import 'package:flutter/material.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/theme/app_spacing.dart';

/// How many days in a row the goal has been reached.
class StreakCard extends StatelessWidget {
  const StreakCard({required this.days, super.key});

  final int days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final spacing = AppSpacing.of(context);
    return Card(
      child: Padding(
        padding: EdgeInsetsDirectional.all(spacing.lg),
        child: Row(
          children: [
            Icon(Icons.local_fire_department, color: scheme.secondary),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.streakDays(days), style: textTheme.titleMedium),
                  if (days == 0)
                    Text(
                      l10n.streakStartHint,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
