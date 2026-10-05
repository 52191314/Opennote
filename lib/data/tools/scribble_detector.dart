/// 🤖 Generated wholely or partially with DeepSeek v4 Flash; Google Antigravity
library;

import 'dart:math';
import 'dart:ui' show Offset;

import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/tools/eraser.dart';

/// Detects when the user is scribbling back-and-forth with the pen tool
/// and switches to erase mode for those strokes.
class ScribbleDetector {
  /// Current state of the detection for the active gesture.
  ScribbleState state = ScribbleState.undetermined;

  final List<Offset> _points = [];
  final List<Stroke> _erasedStrokes = [];
  Eraser? _eraser;

  /// Effective eraser radius used when erasing scribbled-over strokes.
  static const eraserRadius = 24.0;

  /// Maximum points to retain in the sliding window.
  static const maxBufferedPoints = 60;

  static const minPointDistance = 5.0;
  static const minReversals = 3;
  static const minDiagonal = 12.0;
  static const maxDiagonal = 450.0;
  static const pathLengthRatio = 1.6;

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
  List<Stroke> update(
    Offset point,
    List<Stroke> existingStrokes,
    double penStrokeWidth,
  ) {
    _points.add(point);
    if (_points.length > maxBufferedPoints) {
      _points.removeAt(0);
    }

    if (state == ScribbleState.erasing) {
      return _eraseAt(point, existingStrokes);
    }

    if (_isScribbling(_points)) {
      state = ScribbleState.erasing;
      final newlyErased = <Stroke>[];
      for (final p in _points) {
        newlyErased.addAll(_eraseAt(p, existingStrokes));
      }
      return newlyErased;
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
  bool _isScribbling(List<Offset> points) {
    if (points.length < 8) return false;

    // 1. Simplify points by minimum distance to remove touch jitter
    final simplified = <Offset>[points.first];
    for (int i = 1; i < points.length; i++) {
      if ((points[i] - simplified.last).distance >= minPointDistance) {
        simplified.add(points[i]);
      }
    }
    if (simplified.length < 6) return false;

    // 2. Identify motion segments and direction reversals
    final turnaroundIndices = <int>[0];
    Offset? prevDir;

    for (int i = 1; i < simplified.length; i++) {
      final delta = simplified[i] - simplified[i - 1];
      final dist = delta.distance;
      if (dist < 1e-3) continue;
      final dir = delta / dist;

      if (prevDir != null) {
        final dot = prevDir.dx * dir.dx + prevDir.dy * dir.dy;
        if (dot < -0.2) {
          turnaroundIndices.add(i - 1);
        }
      }
      prevDir = dir;
    }
    turnaroundIndices.add(simplified.length - 1);

    final reversals = turnaroundIndices.length - 2;
    if (reversals < minReversals) return false;

    // 3. Check passes between turnarounds
    int overlappingPasses = 0;
    for (int p = 0; p < turnaroundIndices.length - 2; p++) {
      final start1 = simplified[turnaroundIndices[p]];
      final end1 = simplified[turnaroundIndices[p + 1]];
      final start2 = simplified[turnaroundIndices[p + 1]];
      final end2 = simplified[turnaroundIndices[p + 2]];

      final x1Min = min(start1.dx, end1.dx);
      final x1Max = max(start1.dx, end1.dx);
      final x2Min = min(start2.dx, end2.dx);
      final x2Max = max(start2.dx, end2.dx);
      final xOverlap = max(0.0, min(x1Max, x2Max) - max(x1Min, x2Min));
      final xSpan = min(x1Max - x1Min, x2Max - x2Min);

      final y1Min = min(start1.dy, end1.dy);
      final y1Max = max(start1.dy, end1.dy);
      final y2Min = min(start2.dy, end2.dy);
      final y2Max = max(start2.dy, end2.dy);
      final yOverlap = max(0.0, min(y1Max, y2Max) - max(y1Min, y2Min));
      final ySpan = min(y1Max - y1Min, y2Max - y2Min);

      final hasXOverlap = xSpan > 5.0 && (xOverlap / xSpan) > 0.35;
      final hasYOverlap = ySpan > 5.0 && (yOverlap / ySpan) > 0.35;

      final delta1 = end1 - start1;
      final delta2 = end2 - start2;

      final isHorizontalOscillation =
          hasXOverlap && (delta1.dx * delta2.dx < 0);
      final isVerticalOscillation =
          hasYOverlap && (delta1.dy * delta2.dy < 0) &&
          (hasXOverlap || (delta1.dx * delta2.dx < 0) || (x1Max - x1Min <= 8.0 && x2Max - x2Min <= 8.0));

      if (isHorizontalOscillation || isVerticalOscillation) {
        overlappingPasses++;
      }
    }

    if (overlappingPasses < minReversals) return false;

    // 4. Bounding box & path density check
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    double totalPathLength = 0;

    for (int i = 0; i < simplified.length; i++) {
      final pt = simplified[i];
      if (pt.dx < minX) minX = pt.dx;
      if (pt.dx > maxX) maxX = pt.dx;
      if (pt.dy < minY) minY = pt.dy;
      if (pt.dy > maxY) maxY = pt.dy;
      if (i > 0) {
        totalPathLength += (pt - simplified[i - 1]).distance;
      }
    }

    final diagonal = Offset(maxX - minX, maxY - minY).distance;
    if (diagonal < minDiagonal || diagonal > maxDiagonal) return false;
    if (totalPathLength < diagonal * pathLengthRatio) return false;

    return true;
  }

  /// Erase strokes at the given position using the eraser tool.
  List<Stroke> _eraseAt(
    Offset position,
    List<Stroke> existingStrokes,
  ) {
    _eraser ??= Eraser(size: eraserRadius);
    final erased =
        _eraser!.checkForOverlappingStrokes(position, existingStrokes);
    _erasedStrokes.addAll(erased);
    return erased;
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
