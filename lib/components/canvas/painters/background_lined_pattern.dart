/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/painters/background_pattern_element.dart';
import 'package:sbn/canvas_background_pattern.dart';

/// Generates horizontal ruled lines clamped strictly to [clampedBounds].
Iterable<PatternElement> generateHorizontalLinesInBounds(
  Rect clampedBounds,
  int lineHeight,
) sync* {
  final startY =
      (clampedBounds.top / lineHeight).floor() * lineHeight.toDouble();
  final endY =
      (clampedBounds.bottom / lineHeight).ceil() * lineHeight.toDouble();
  final count = ((endY - startY) / lineHeight).ceil();
  if (count > 5000) return;
  for (double y = startY; y <= endY; y += lineHeight) {
    yield PatternElement(
      Offset(clampedBounds.left, y),
      Offset(clampedBounds.right, y),
      isLine: true,
    );
  }
}

/// Generates lined, college-LTR, or college-RTL background pattern elements.
///
/// When [clampedBounds] is non-null, pattern loops are strictly clamped to the
/// visible viewport rect for infinite-canvas performance.
Iterable<PatternElement> generateLinedPatternElements({
  required CanvasBackgroundPattern pattern,
  required Size size,
  required int lineHeight,
  Rect? clampedBounds,
}) sync* {
  if (clampedBounds != null) {
    yield* generateHorizontalLinesInBounds(clampedBounds, lineHeight);
    if (pattern == CanvasBackgroundPattern.collegeLtr) {
      yield PatternElement(
        Offset(lineHeight * 2, clampedBounds.top),
        Offset(lineHeight * 2, clampedBounds.bottom),
        isLine: true,
        secondaryColor: true,
      );
    } else if (pattern == CanvasBackgroundPattern.collegeRtl) {
      yield PatternElement(
        Offset(size.width - lineHeight * 2, clampedBounds.top),
        Offset(size.width - lineHeight * 2, clampedBounds.bottom),
        isLine: true,
        secondaryColor: true,
      );
    }
    return;
  }

  for (double y = lineHeight * 2; y < size.height; y += lineHeight) {
    yield PatternElement(Offset(0, y), Offset(size.width, y), isLine: true);
  }

  if (pattern == CanvasBackgroundPattern.collegeLtr) {
    yield PatternElement(
      Offset(lineHeight * 2, 0),
      Offset(lineHeight * 2, size.height),
      isLine: true,
      secondaryColor: true,
    );
  } else if (pattern == CanvasBackgroundPattern.collegeRtl) {
    yield PatternElement(
      Offset(size.width - lineHeight * 2, 0),
      Offset(size.width - lineHeight * 2, size.height),
      isLine: true,
      secondaryColor: true,
    );
  }
}
