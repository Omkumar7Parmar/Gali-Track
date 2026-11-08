import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A circular progress arc drawn over a full track, starting at the top.
///
/// Decorative only: it is hidden from screen readers, so always show the
/// value in a text label nearby. Fills whatever size its parent gives it.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    super.key,
  });

  /// From 0 (empty) to 1 (full). Values outside are clamped.
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _RingPainter(
          progress: clampDouble(progress, 0, 1),
          color: color,
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
    required this.trackColor,
    required this.strokeWidth,
  }) : _trackPaint = Paint()
         ..color = trackColor
         ..style = PaintingStyle.stroke
         ..strokeWidth = strokeWidth,
       _arcPaint = Paint()
         ..color = color
         ..style = PaintingStyle.stroke
         ..strokeWidth = strokeWidth
         ..strokeCap = StrokeCap.round;

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final Paint _trackPaint;
  final Paint _arcPaint;

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
    canvas.drawArc(
      bounds,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      _arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
