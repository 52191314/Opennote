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
/// 2. Count direction reversals (angle change > 90°) between consecutive segments
/// 3. Measure the bounding box diagonal of the window
/// 4. If [minReversals]+ reversals within a tight cluster → scribbling mode
/// 5. Once mode is determined (drawing/erasing), stay in that mode for the gesture
class ScribbleDetector {
  /// Current state of the detection for the active gesture.
  ScribbleState state = ScribbleState.undetermined;

  final List<Offset> _points = [];
  final List<Stroke> _erasedStrokes = [];
  Eraser? _eraser;

  static const int windowSize = 15;
  static const int minPoints = 10;
  static const int minReversals = 5;
  static const double boundingBoxMultiplier = 5.0;
  static const double angleThresholdDeg = 90;

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
    // Count direction reversals
    int reversals = 0;
    for (int i = 2; i < points.length; i++) {
      final prev = points[i - 1] - points[i - 2];
      final curr = points[i] - points[i - 1];
      if (_angleBetween(prev, curr) > angleThresholdDeg) {
        reversals++;
      }
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

    // Scribbling requires many reversals within a tight cluster
    return reversals >= minReversals &&
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
