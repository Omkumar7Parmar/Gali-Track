import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A circular progress arc drawn over a full track, starting at the top.
///
/// With [startColor], the arc shades from it into [color] along its length,
/// so a fuller ring glows deeper. Decorative only: it is hidden from screen
/// readers, so always show the value in a text label nearby. Fills whatever
/// size its parent gives it.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    this.startColor,
    super.key,
  });

  /// From 0 (empty) to 1 (full). Values outside are clamped.
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  /// Where the gradient sweep starts; a solid arc when null.
  final Color? startColor;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _RingPainter(
          progress: clampDouble(progress, 0, 1),
          color: color,
          startColor: startColor,
          trackColor: trackColor,
          strokeWidth: strokeWidth,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.startColor,
    required this.trackColor,
    required this.strokeWidth,
  }) : _trackPaint = Paint()
         ..color = trackColor
         ..style = PaintingStyle.stroke
         ..strokeWidth = strokeWidth;

  final double progress;
  final Color color;
  final Color? startColor;
  final Color trackColor;
  final double strokeWidth;
  final Paint _trackPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = math.min(size.width, size.height) - strokeWidth;
    if (diameter <= 0) return;
    final bounds = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: diameter,
      height: diameter,
    );
    canvas.drawOval(bounds, _trackPaint);
    if (progress == 0) return;

    final sweep = 2 * math.pi * progress;
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final start = startColor;
    if (start != null) {
      // The round cap pokes out before the arc's start angle; rotating the
      // gradient back by the cap's angle keeps the cap in the start colour.
      final capAngle = strokeWidth / diameter;
      arcPaint.shader = SweepGradient(
        endAngle: sweep + capAngle,
        colors: [start, color],
        transform: GradientRotation(-math.pi / 2 - capAngle),
      ).createShader(bounds);
    }
    canvas.drawArc(bounds, -math.pi / 2, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.startColor != startColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
