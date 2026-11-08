import 'package:flutter/widgets.dart';

/// GaliTrack's signature texture: a loose sketch of winding lanes, like a
/// hand-drawn map of a neighbourhood's galis, with dots for the corners
/// where people stop.
///
/// Decorative only and hidden from screen readers. Fills its parent.
class GaliLanes extends StatelessWidget {
  const GaliLanes({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _LanesPainter(color),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LanesPainter extends CustomPainter {
  _LanesPainter(this.color)
    : _linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap = StrokeCap.round,
      _dotPaint = Paint()..color = color;

  final Color color;
  final Paint _linePaint;
  final Paint _dotPaint;

  static const _strokeWidth = 2.5;
  static const _dotRadius = 4.0;

  /// Each lane is a cubic curve in 0..1 space: start, two controls, end.
  static const _lanes = <List<Offset>>[
    [Offset(0, 0.2), Offset(0.3, 0.02), Offset(0.62, 0.5), Offset(1, 0.3)],
    [Offset(0, 0.68), Offset(0.28, 0.5), Offset(0.55, 0.96), Offset(1, 0.74)],
    [Offset(0.2, 0), Offset(0.36, 0.34), Offset(0.06, 0.66), Offset(0.28, 1)],
    [Offset(0.8, 0), Offset(0.6, 0.32), Offset(0.98, 0.62), Offset(0.74, 1)],
    [Offset(0.44, 1), Offset(0.5, 0.86), Offset(0.62, 0.84), Offset(0.68, 0.7)],
  ];

  static const _stops = [
    Offset(0.32, 0.2),
    Offset(0.71, 0.8),
    Offset(0.12, 0.56),
    Offset(0.88, 0.36),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final lane in _lanes) {
      final start = _scale(lane[0], size);
      final first = _scale(lane[1], size);
      final second = _scale(lane[2], size);
      final end = _scale(lane[3], size);
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(first.dx, first.dy, second.dx, second.dy, end.dx, end.dy);
      canvas.drawPath(path, _linePaint);
    }
    for (final stop in _stops) {
      canvas.drawCircle(_scale(stop, size), _dotRadius, _dotPaint);
    }
  }

  Offset _scale(Offset point, Size size) =>
      Offset(point.dx * size.width, point.dy * size.height);

  @override
  bool shouldRepaint(_LanesPainter oldDelegate) => oldDelegate.color != color;
}
