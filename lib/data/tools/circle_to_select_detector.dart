/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:async';
import 'dart:ui';

/// Detects when a user draws a closed loop around content and holds the stylus,
/// converting the stroke into a lasso selection (Goodnotes 6 circle-to-select).
class CircleToSelectDetector {
  CircleToSelectDetector({
    this.holdDuration = const Duration(milliseconds: 450),
    required this.onCircleDetected,
  });

  final Duration holdDuration;
  final void Function(Path loopPath) onCircleDetected;

  final List<Offset> _points = [];
  Timer? _holdTimer;
  var _isClosedLoop = false;

  void start(Offset point) {
    _points.clear();
    _points.add(point);
    _isClosedLoop = false;
    _holdTimer?.cancel();
  }

  void update(Offset point) {
    _points.add(point);
    _holdTimer?.cancel();

    if (_points.length < 10) return;

    final first = _points.first;
    final current = point;
    final distanceToStart = (current - first).distance;

    // Compute bounding box
    double minX = _points[0].dx, maxX = _points[0].dx;
    double minY = _points[0].dy, maxY = _points[0].dy;
    for (int i = 1; i < _points.length; i++) {
      final p = _points[i];
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    final width = maxX - minX;
    final height = maxY - minY;
    final diagonal = (width * width + height * height);

    // Loop criteria:
    // 1. Min bounding box size of 20x20
    // 2. Start and end points are close relative to loop size
    if (width > 20 && height > 20 && distanceToStart < 50.0 && distanceToStart * distanceToStart < diagonal * 0.25) {
      _isClosedLoop = true;
      // Start hold timer: if stylus stays held near this endpoint, trigger circle-to-select
      _holdTimer = Timer(holdDuration, () {
        if (_isClosedLoop && _points.length >= 10) {
          final path = Path();
          path.moveTo(_points[0].dx, _points[0].dy);
          for (int i = 1; i < _points.length; i++) {
            path.lineTo(_points[i].dx, _points[i].dy);
          }
          path.close();
          onCircleDetected(path);
        }
      });
    } else {
      _isClosedLoop = false;
    }
  }

  void cancel() {
    _holdTimer?.cancel();
    _points.clear();
    _isClosedLoop = false;
  }

  void dispose() {
    cancel();
  }
}
