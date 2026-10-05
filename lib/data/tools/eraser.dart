/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:ui';

import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:sbn/tool_id.dart';

double square(double x) => x * x;
double sqrDistanceBetween(Offset p1, Offset p2) =>
    square(p1.dx - p2.dx) + square(p1.dy - p2.dy);

class Eraser extends Tool {
  final double size;
  late final double sqrSize = square(size);

  List<Stroke> _erased = [];

  Eraser({this.size = 10});

  @override
  ToolId get toolId => .eraser;

  /// Returns any [strokes] that are close to the given [eraserPos].
  List<Stroke> checkForOverlappingStrokes(
    Offset eraserPos,
    List<Stroke> strokes,
  ) {
    final List<Stroke> overlapping = [];
    final isPrecision = stows.eraserMode.value == 'precision';
    final effectiveSqrSize = isPrecision ? sqrSize * 0.25 : sqrSize;

    for (int i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      if (stows.eraserEraseHighlighterOnly.value &&
          stroke.toolId != ToolId.highlighter) {
        continue;
      }
      if (stows.eraserEraseTapeOnly.value &&
          stroke.toolId != ToolId.studyTape &&
          stroke is! TapeStroke) {
        continue;
      }
      if (_shouldStrokeBeErased(
        eraserPos,
        stroke,
        effectiveSqrSize,
        isPrecision: isPrecision,
      )) {
        overlapping.add(stroke);
        _erased.add(stroke);
      }
    }
    return overlapping;
  }

  /// Returns the strokes that have been erased during this drag.
  List<Stroke> onDragEnd() {
    final List<Stroke> erased = _erased;
    _erased = [];
    return erased;
  }

  static bool _shouldStrokeBeErased(
    Offset eraserPos,
    Stroke stroke,
    double sqrSize, {
    bool isPrecision = false,
  }) {
    if (stroke is TapeStroke) {
      return stroke.rect.inflate(isPrecision ? 4 : 12).contains(eraserPos);
    }

    if (stroke.length <= 3) {
      if (stroke.lowQualityPath.contains(eraserPos)) return true;
    }

    /// skip checking every few vertices for performance in object mode
    final int verticesToSkip = isPrecision
        ? 0
        : switch (stroke.lowQualityPolygon.length) {
            < 100 => 0,
            < 1000 => 1,
            _ => 2,
          };

    for (
      int i = 0;
      i < stroke.lowQualityPolygon.length;
      i += verticesToSkip + 1
    ) {
      final Offset strokeVertex = stroke.lowQualityPolygon[i];
      if (sqrDistanceBetween(strokeVertex, eraserPos) <= sqrSize) return true;
    }
    return false;
  }
}
