/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/painters/background_lined_pattern.dart';
import 'package:saber/components/canvas/painters/background_pattern_element.dart';

/// Generates Cornell Notes template elements (header fields, 28% cue column,
/// ruled notes area, and 25% summary footer).
///
/// On an infinite canvas ([clampedBounds] non-null), yields viewport-culled
/// horizontal lines within [clampedBounds].
Iterable<PatternElement> generateCornellPatternElements({
  required Size size,
  required int lineHeight,
  required int lineThickness,
  Rect? clampedBounds,
}) sync* {
  if (clampedBounds != null) {
    yield* generateHorizontalLinesInBounds(clampedBounds, lineHeight);
    return;
  }

  final headerBottom = lineHeight * 3.5;
  yield PatternElement(
    Offset(lineHeight.toDouble(), lineHeight * 2),
    Offset(size.width / 2 - lineHeight / 2, lineHeight * 2),
    isLine: true,
  );
  yield PatternElement(
    Offset(size.width / 2 + lineHeight / 2, lineHeight * 2),
    Offset(size.width - lineHeight, lineHeight * 2),
    isLine: true,
  );
  yield PatternElement(
    Offset(lineHeight.toDouble(), lineHeight * 3),
    Offset(size.width - lineHeight, lineHeight * 3),
    isLine: true,
  );

  final cueRight = size.width * 0.28;
  final summaryTop = size.height * 0.75;

  yield PatternElement(
    Offset(cueRight, headerBottom),
    Offset(cueRight, summaryTop),
    isLine: true,
    thickness: lineThickness * 1.5,
    secondaryColor: true,
  );
  yield PatternElement(
    Offset(lineHeight.toDouble(), summaryTop),
    Offset(size.width - lineHeight, summaryTop),
    isLine: true,
    thickness: lineThickness * 1.5,
    secondaryColor: true,
  );

  for (double y = lineHeight * 5; y < summaryTop; y += lineHeight) {
    yield PatternElement(
      Offset(cueRight, y),
      Offset(size.width - lineHeight, y),
      isLine: true,
    );
  }

  for (
    double y = summaryTop + lineHeight;
    y < size.height - lineHeight;
    y += lineHeight
  ) {
    yield PatternElement(
      Offset(lineHeight.toDouble(), y),
      Offset(size.width - lineHeight, y),
      isLine: true,
    );
  }
}
