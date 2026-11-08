import 'package:flutter/material.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/theme/app_colors.dart';
import 'package:galitrack/theme/app_shapes.dart';
import 'package:galitrack/theme/app_spacing.dart';
import 'package:galitrack/ui/progress_ring.dart';

/// A tappable miniature of the home screen, drawn in [theme].
///
/// Selection shows four ways at once: a thicker border, a tick icon, the
/// border colour, and the screen reader's "selected" state.
class ThemePreviewCard extends StatelessWidget {
  const ThemePreviewCard({
    required this.theme,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final ThemeData theme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _previewAspectRatio = 0.62;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final shapes = AppShapes.of(context);
    final spacing = AppSpacing.of(context);
    final border = BorderSide(
      color: selected ? scheme.primary : scheme.outlineVariant,
      width: selected ? shapes.selectedOutlineWidth : shapes.outlineWidth,
    );

    return Semantics(
      button: true,
      selected: selected,
      label: l10n.themePreviewLabel(label),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: shapes.cardShape(),
        child: Column(
          children: [
            DecoratedBox(
              decoration: ShapeDecoration(
                shape: shapes.cardShape(side: border),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.all(spacing.xs),
                child: AspectRatio(
                  aspectRatio: _previewAspectRatio,
                  child: Theme(data: theme, child: const _MiniHome()),
                ),
              ),
            ),
            SizedBox(height: spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                SizedBox(width: spacing.xs),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The home screen in miniature, with sample numbers. It reads the preview's
/// own theme, not the app's.
class _MiniHome extends StatelessWidget {
  const _MiniHome();

  static const _sampleSteps = 4200;
  static const _sampleProgress = 0.7;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    final shapes = AppShapes.of(context);
    final spacing = AppSpacing.of(context);

    return Material(
      color: scheme.surface,
      shape: shapes.panelShape(),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsetsDirectional.all(spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.homeTitle,
              style: textTheme.titleSmall?.copyWith(color: scheme.onSurface),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.all(spacing.sm),
                child: ProgressRing(
                  progress: _sampleProgress,
                  color: colors.stepsAccent,
                  trackColor: colors.ringTrack,
                  strokeWidth: shapes.ringStrokeThin,
                ),
              ),
            ),
            Text(
              l10n.stepTargetValue(_sampleSteps),
              textAlign: TextAlign.center,
              style: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
            ),
            SizedBox(height: spacing.xs),
            DecoratedBox(
              decoration: ShapeDecoration(
                color: scheme.primary,
                shape: shapes.pillShape(),
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.symmetric(vertical: spacing.xs),
                child: Text(
                  l10n.startWalk,
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
