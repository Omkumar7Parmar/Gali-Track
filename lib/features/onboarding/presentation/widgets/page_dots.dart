import 'package:flutter/material.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/theme/app_motion.dart';
import 'package:galitrack/theme/app_spacing.dart';

/// One dot per page; the current page's dot is wider as well as coloured,
/// so it reads without colour. Screen readers hear "Step 2 of 4".
class PageDots extends StatelessWidget {
  const PageDots({required this.current, required this.count, super.key});

  final int current;
  final int count;

  static const _dotSize = 8.0;
  static const _currentDotWidth = 24.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final spacing = AppSpacing.of(context);
    final motion = AppMotion.of(context);
    return Semantics(
      label: l10n.onboardingProgress(current + 1, count),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < count; index++)
              AnimatedContainer(
                duration: resolveMotion(context, motion.short),
                curve: motion.standard,
                margin: EdgeInsetsDirectional.symmetric(
                  horizontal: spacing.xxs,
                ),
                width: index == current ? _currentDotWidth : _dotSize,
                height: _dotSize,
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: index == current
                      ? scheme.primary
                      : scheme.outlineVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
