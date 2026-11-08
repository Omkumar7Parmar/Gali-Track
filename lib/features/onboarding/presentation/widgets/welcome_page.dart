import 'package:flutter/material.dart';
import 'package:galitrack/l10n/app_localizations.dart';
import 'package:galitrack/theme/app_colors.dart';
import 'package:galitrack/theme/app_shapes.dart';
import 'package:galitrack/theme/app_spacing.dart';
import 'package:galitrack/ui/gali_lanes.dart';
import 'package:galitrack/ui/progress_ring.dart';

/// Page 1: what the app is, and its privacy promise.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final spacing = AppSpacing.of(context);
    return ListView(
      padding: EdgeInsetsDirectional.all(spacing.lg),
      children: [
        const _HeroRings(),
        SizedBox(height: spacing.xl),
        Text(
          l10n.appTitle,
          style: textTheme.titleMedium?.copyWith(color: scheme.primary),
        ),
        SizedBox(height: spacing.xs),
        Semantics(
          header: true,
          child: Text(l10n.welcomeHeadline, style: textTheme.displaySmall),
        ),
        const _BrushStroke(),
        SizedBox(height: spacing.sm),
        Text(
          l10n.welcomeBody,
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
        SizedBox(height: spacing.lg),
        _PrivacyPoint(
          icon: Icons.person_off_outlined,
          text: l10n.privacyNoAccount,
        ),
        _PrivacyPoint(icon: Icons.phone_android, text: l10n.privacyOnDevice),
        _PrivacyPoint(icon: Icons.wifi_off, text: l10n.privacyOffline),
      ],
    );
  }
}

/// Decorative steps and distance rings: the app's visual signature.
class _HeroRings extends StatelessWidget {
  const _HeroRings();

  static const _outerSize = 200.0;
  static const _innerSize = 146.0;
  static const _iconSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final shapes = AppShapes.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: SizedBox(
        height: _outerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: GaliLanes(color: colors.laneLine)),
            SizedBox.square(
              dimension: _outerSize,
              child: ProgressRing(
                progress: 0.72,
                color: colors.stepsAccent,
                startColor: colors.stepsAccentSoft,
                trackColor: colors.ringTrack,
                strokeWidth: shapes.ringStroke,
              ),
            ),
            SizedBox.square(
              dimension: _innerSize,
              child: ProgressRing(
                progress: 0.48,
                color: colors.distanceAccent,
                startColor: colors.distanceAccentSoft,
                trackColor: colors.ringTrack,
                strokeWidth: shapes.ringStroke,
              ),
            ),
            Icon(
              Icons.directions_walk,
              size: _iconSize,
              color: scheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  const _PrivacyPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spacing = AppSpacing.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: spacing.sm),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

/// A quick marigold brush stroke under the headline, like a highlighter
/// swipe on a street map. Decorative only.
class _BrushStroke extends StatelessWidget {
  const _BrushStroke();

  static const _width = 148.0;
  static const _height = 14.0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ExcludeSemantics(
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: CustomPaint(
          size: const Size(_width, _height),
          painter: _BrushStrokePainter(colors.stepsAccent),
        ),
      ),
    );
  }
}

class _BrushStrokePainter extends CustomPainter {
  _BrushStrokePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.5
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.height * 0.4, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.15,
        size.width - size.height * 0.4,
        size.height * 0.45,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BrushStrokePainter oldDelegate) =>
      oldDelegate.color != color;
}
