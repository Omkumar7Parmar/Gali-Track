import 'package:flutter/material.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/routing/routes.dart';
import 'package:galitrack/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';

/// Shown for a link to a screen that doesn't exist.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = AppSpacing.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notFoundTitle)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.notFoundBody,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: spacing.lg),
              FilledButton(
                onPressed: () => context.go(Routes.home),
                child: Text(l10n.goToToday),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
