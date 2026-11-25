/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';
import 'dart:ui';

/// Detects when a user draws a closed loop around content and holds the stylus,
/// converting the stroke into a lasso selection (circle-to-select gesture).
class CircleToSelectDetector {
  CircleToSelectDetector({
    this.holdDuration = const Duration(milliseconds: 450),
    this.holdJitterDeadzonePx = 6.0,
    required this.onCircleDetected,
  });

  /// Minimum loop width and height in physical screen pixels.
  static const minLoopSizePx = 20.0;

  /// Maximum distance between loop start and end in physical screen pixels.
  static const maxClosureDistancePx = 50.0;

  final Duration holdDuration;

  /// Physical-pixel movement tolerance while holding still so 120Hz stylus
  /// micro-jitter does not cancel the hold timer.
  final double holdJitterDeadzonePx;

  final void Function(Path loopPath) onCircleDetected;

  final List<Offset> _points = [];
  Timer? _holdTimer;
  Offset? _holdAnchor;
  var _isClosedLoop = false;

  /// Begins tracking a new potential circle-to-select stroke at [point].
  void start(Offset point) {
    _points
      ..clear()
      ..add(point);
    _isClosedLoop = false;
    _holdAnchor = null;
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  /// Processes a new pointer sample [point] at canvas zoom [scale].
  void update(Offset point, {double scale = 1.0}) {
    final effectiveScale = (scale.isFinite && scale > 0) ? scale : 1.0;

    if (_isClosedLoop && _holdTimer != null && _holdAnchor != null) {
      final jitterPx = (point - _holdAnchor!).distance * effectiveScale;
      if (jitterPx <= holdJitterDeadzonePx) return;
    }

    _points.add(point);
    _holdTimer?.cancel();
    _holdTimer = null;
    _holdAnchor = null;

    if (_points.length < 10) return;

    final first = _points.first;
    final distanceToStart = (point - first).distance;

    var minX = _points[0].dx;
    var maxX = minX;
    var minY = _points[0].dy;
    var maxY = minY;
    for (int i = 1; i < _points.length; i++) {
      final p = _points[i];
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    final width = maxX - minX;
    final height = maxY - minY;
    final diagonalSq = width * width + height * height;

    final widthPx = width * effectiveScale;
    final heightPx = height * effectiveScale;
    final distanceToStartPx = distanceToStart * effectiveScale;

    if (widthPx > minLoopSizePx &&
        heightPx > minLoopSizePx &&
        distanceToStartPx < maxClosureDistancePx &&
        distanceToStart * distanceToStart < diagonalSq * 0.25) {
      _isClosedLoop = true;
      _holdAnchor = point;
      _holdTimer = Timer(holdDuration, _fireLoopDetected);
    } else {
      _isClosedLoop = false;
    }
  }

  void _fireLoopDetected() {
    if (!_isClosedLoop || _points.length < 10) return;
    final path = Path()..moveTo(_points[0].dx, _points[0].dy);
    for (int i = 1; i < _points.length; i++) {
      path.lineTo(_points[i].dx, _points[i].dy);
    }
    path.close();
    onCircleDetected(path);
  }

  /// Cancels any pending hold timer and clears accumulated points.
  void cancel() {
    _holdTimer?.cancel();
    _holdTimer = null;
    _holdAnchor = null;
    _points.clear();
    _isClosedLoop = false;
  }

  /// Disposes resources held by this detector.
  void dispose() => cancel();
}
