/// 🤖 Generated with DeepSeek v4 Flash
library;

import 'dart:math';
import 'dart:ui' show Offset;

import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/tools/eraser.dart';

/// Detects when the user is scribbling back-and-forth with the pen tool
/// and switches to erase mode for those strokes.
///
/// Algorithm:
/// 1. Buffer the last [windowSize] pen positions
/// 2. Subsample points to reduce noise, then count direction-quadrant changes
/// 3. Measure the bounding box diagonal of the window
/// 4. If >= [minDirectionChanges] direction changes within a moderate cluster → scribbling mode
/// 5. Once mode is determined (drawing/erasing), stay in that mode for the gesture
class ScribbleDetector {
  /// Current state of the detection for the active gesture.
  ScribbleState state = ScribbleState.undetermined;

  final List<Offset> _points = [];
  final List<Stroke> _erasedStrokes = [];
  Eraser? _eraser;

  /// Number of recent positions to keep in the sliding window.
  static const int windowSize = 20;

  /// Minimum points needed before attempting detection.
  static const int minPoints = 8;

  /// Minimum direction-quadrant changes to classify as scribbling.
  static const int minDirectionChanges = 4;

  /// Bounding-box diagonal multiplier relative to pen stroke width.
  /// Scribbling over a stroke typically spans 10-30× the pen width.
  static const double boundingBoxMultiplier = 20.0;

  /// Reset the detector for a new gesture.
  void start(Offset firstPoint) {
    _points.clear();
    _erasedStrokes.clear();
    _eraser = null;
    state = ScribbleState.undetermined;
    _points.add(firstPoint);
  }

  /// Feed a new pen position.
  ///
  /// Returns the list of strokes that should be erased
  /// (empty list means continue drawing normally).
  ///
  /// [penStrokeWidth] is the current pen's stroke width,
  /// used as the eraser diameter when in scribble-erase mode.
  List<Stroke> update(
    Offset point,
    List<Stroke> existingStrokes,
    double penStrokeWidth,
  ) {
    _points.add(point);
    if (_points.length > windowSize) {
      _points.removeAt(0);
    }

    if (state == ScribbleState.erasing) {
      return _eraseAt(point, existingStrokes, penStrokeWidth);
    }

    if (state == ScribbleState.drawing) {
      return const [];
    }

    // Still undetermined — need enough points to decide
    if (_points.length < minPoints) {
      return const [];
    }

    if (_isScribbling(_points, penStrokeWidth)) {
      state = ScribbleState.erasing;
      return _eraseAt(point, existingStrokes, penStrokeWidth);
    }

    // Full window collected and still not scribbling → it's drawing
    if (_points.length >= windowSize) {
      state = ScribbleState.drawing;
    }

    return const [];
  }

  /// Call when the gesture ends.
  /// Returns the final list of erased strokes (for history recording).
  List<Stroke> end() {
    final erased = List<Stroke>.of(_erasedStrokes);
    _erasedStrokes.clear();
    _points.clear();
    _eraser = null;
    state = ScribbleState.undetermined;
    return erased;
  }

  /// Clear all state.
  void reset() {
    _eraser = null;
    _points.clear();
    _erasedStrokes.clear();
    state = ScribbleState.undetermined;
  }

  /// Analyze the buffered points to determine if the user is scribbling.
  bool _isScribbling(List<Offset> points, double penStrokeWidth) {
    if (points.length < 8) return false;

    // Subsample points to reduce natural jitter
    final step = (points.length / 6).ceil().clamp(1, 3);
    final sampled = <Offset>[];
    for (int i = 0; i < points.length; i += step) {
      sampled.add(points[i]);
    }

    // Count direction-quadrant changes
    int directionChanges = 0;
    int? lastQuadrant;
    for (int i = 1; i < sampled.length; i++) {
      final dx = sampled[i].dx - sampled[i - 1].dx;
      final dy = sampled[i].dy - sampled[i - 1].dy;

      // Skip tiny movements (natural jitter)
      if (dx.abs() < 3 && dy.abs() < 3) continue;

      final int quadrant;
      if (dx.abs() > dy.abs()) {
        quadrant = dx > 0 ? 0 : 2; // moving right (0) or left (2)
      } else {
        quadrant = dy > 0 ? 1 : 3; // moving down (1) or up (3)
      }

      if (lastQuadrant != null && quadrant != lastQuadrant) {
        directionChanges++;
      }
      lastQuadrant = quadrant;
    }

    // Measure bounding box diagonal
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    final diagonal = Offset(maxX - minX, maxY - minY).distance;

    // Scribbling requires frequent direction changes within a moderate area
    return directionChanges >= minDirectionChanges &&
        diagonal < boundingBoxMultiplier * penStrokeWidth;
  }

  /// Erase strokes at the given position using the eraser tool.
  List<Stroke> _eraseAt(
    Offset position,
    List<Stroke> existingStrokes,
    double penStrokeWidth,
  ) {
    _eraser ??= Eraser(size: penStrokeWidth);
    final erased =
        _eraser!.checkForOverlappingStrokes(position, existingStrokes);
    _erasedStrokes.addAll(erased);
    return erased;
  }

  /// Angle between two vectors in degrees.
  static double _angleBetween(Offset a, Offset b) {
    final dot = a.dx * b.dx + a.dy * b.dy;
    final magA = a.distance;
    final magB = b.distance;
    if (magA <= 0 || magB <= 0) return 0;
    final cosAngle = (dot / (magA * magB)).clamp(-1.0, 1.0);
    return acos(cosAngle) * 180 / pi;
  }
}

/// The state of the scribble detector for the current gesture.
enum ScribbleState {
  /// Not enough points yet to determine if the user is drawing or erasing.
  undetermined,

  /// Determined to be a normal drawing gesture.
  drawing,

  /// Determined to be a scribble-erase gesture.
  erasing,
}
