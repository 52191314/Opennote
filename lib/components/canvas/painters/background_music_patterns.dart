/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/painters/background_lined_pattern.dart';
import 'package:saber/components/canvas/painters/background_pattern_element.dart';
import 'package:sbn/canvas_background_pattern.dart';

/// Generates musical staff or guitar tablature pattern elements.
///
/// On an infinite canvas ([clampedBounds] non-null), yields viewport-culled
/// horizontal lines within [clampedBounds].
Iterable<PatternElement> generateMusicPatternElements({
  required CanvasBackgroundPattern pattern,
  required Size size,
  required int lineHeight,
  Rect? clampedBounds,
}) sync* {
  if (clampedBounds != null) {
    yield* generateHorizontalLinesInBounds(clampedBounds, lineHeight);
    return;
  }

  final staffSpaces = pattern == CanvasBackgroundPattern.staffs ? 4 : 5;
  final staffHeight = lineHeight * staffSpaces;
  final staffSpacing = lineHeight * 3;

  for (
    double topOfStaff = staffSpacing.toDouble() - lineHeight;
    topOfStaff + staffHeight < size.height;
    topOfStaff += staffHeight + staffSpacing
  ) {
    for (int line = 0; line < staffSpaces + 1; line++) {
      yield PatternElement(
        Offset(lineHeight.toDouble(), topOfStaff + lineHeight * line),
        Offset(size.width - lineHeight, topOfStaff + lineHeight * line),
        isLine: true,
      );
    }

    yield PatternElement(
      Offset(lineHeight.toDouble(), topOfStaff),
      Offset(lineHeight.toDouble(), topOfStaff + staffHeight),
      isLine: true,
    );
    yield PatternElement(
      Offset(size.width - lineHeight, topOfStaff),
      Offset(size.width - lineHeight, topOfStaff + staffHeight),
      isLine: true,
    );
  }
}
