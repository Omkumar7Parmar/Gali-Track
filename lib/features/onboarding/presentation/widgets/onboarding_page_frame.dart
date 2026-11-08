import 'package:flutter/material.dart';
import 'package:galitrack/theme/app_spacing.dart';

/// Shared layout for an onboarding page: headline, explanation, content.
///
/// Scrolls, so large text sizes never overflow.
class OnboardingPageFrame extends StatelessWidget {
  const OnboardingPageFrame({
    required this.headline,
    required this.body,
    required this.children,
    super.key,
  });

  final String headline;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final spacing = AppSpacing.of(context);
    return ListView(
      padding: EdgeInsetsDirectional.all(spacing.lg),
      children: [
        Semantics(
          header: true,
          child: Text(headline, style: textTheme.headlineMedium),
        ),
        SizedBox(height: spacing.xs),
        Text(
          body,
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        SizedBox(height: spacing.xl),
        ...children,
      ],
    );
  }
}
