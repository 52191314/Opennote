/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/painters/background_cornell_pattern.dart';
import 'package:saber/components/canvas/painters/background_dots_pattern.dart';
import 'package:saber/components/canvas/painters/background_grid_patterns.dart';
import 'package:saber/components/canvas/painters/background_lined_pattern.dart';
import 'package:saber/components/canvas/painters/background_music_patterns.dart';
import 'package:saber/components/canvas/painters/background_pattern_element.dart';
import 'package:saber/components/canvas/painters/background_viewport_helper.dart';
import 'package:sbn/canvas_background_pattern.dart';

/// Dispatches pattern element generation to the matching pattern module,
/// strictly clamping infinite-canvas [bounds] via [clampInfiniteBounds].
Iterable<PatternElement> generateBackgroundPatternElements({
  required CanvasBackgroundPattern pattern,
  required Size size,
  required int lineHeight,
  int lineThickness = 3,
  Rect? bounds,
}) sync* {
  if (lineHeight <= 0 || pattern == CanvasBackgroundPattern.none) return;

  Rect? clampedBounds;
  if (bounds != null) {
    clampedBounds = clampInfiniteBounds(bounds);
    if (clampedBounds == null) return;
  }

  switch (pattern) {
    case CanvasBackgroundPattern.none:
      return;
    case CanvasBackgroundPattern.collegeLtr:
    case CanvasBackgroundPattern.collegeRtl:
    case CanvasBackgroundPattern.lined:
      yield* generateLinedPatternElements(
        pattern: pattern,
        size: size,
        lineHeight: lineHeight,
        clampedBounds: clampedBounds,
      );
    case CanvasBackgroundPattern.grid:
      yield* generateGridPatternElements(
        size: size,
        lineHeight: lineHeight,
        clampedBounds: clampedBounds,
      );
    case CanvasBackgroundPattern.dots:
      yield* generateDotsPatternElements(
        size: size,
        lineHeight: lineHeight,
        clampedBounds: clampedBounds,
      );
    case CanvasBackgroundPattern.engineeringGrid:
      yield* generateEngineeringGridPatternElements(
        size: size,
        lineHeight: lineHeight,
        lineThickness: lineThickness,
        clampedBounds: clampedBounds,
      );
    case CanvasBackgroundPattern.isometric:
      yield* generateIsometricPatternElements(
        size: size,
        lineHeight: lineHeight,
        clampedBounds: clampedBounds,
      );
    case CanvasBackgroundPattern.staffs:
    case CanvasBackgroundPattern.tablature:
      yield* generateMusicPatternElements(
        pattern: pattern,
        size: size,
        lineHeight: lineHeight,
        clampedBounds: clampedBounds,
      );
    case CanvasBackgroundPattern.cornell:
      yield* generateCornellPatternElements(
        size: size,
        lineHeight: lineHeight,
        lineThickness: lineThickness,
        clampedBounds: clampedBounds,
      );
  }
}
