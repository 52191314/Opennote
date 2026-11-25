/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/painters/background_pattern_element.dart';

/// Generates dot-grid pattern elements, strictly clamped to [clampedBounds]
/// when rendering on an infinite canvas.
Iterable<PatternElement> generateDotsPatternElements({
  required Size size,
  required int lineHeight,
  Rect? clampedBounds,
}) sync* {
  if (clampedBounds != null) {
    final startX =
        (clampedBounds.left / lineHeight).floor() * lineHeight.toDouble();
    final endX =
        (clampedBounds.right / lineHeight).ceil() * lineHeight.toDouble();
    final startY =
        (clampedBounds.top / lineHeight).floor() * lineHeight.toDouble();
    final endY =
        (clampedBounds.bottom / lineHeight).ceil() * lineHeight.toDouble();
    final countX = ((endX - startX) / lineHeight).ceil();
    final countY = ((endY - startY) / lineHeight).ceil();
    if (countX * countY > 50000) return;

    for (double y = startY; y <= endY; y += lineHeight) {
      for (double x = startX; x <= endX; x += lineHeight) {
        yield PatternElement(Offset(x, y), Offset(x, y), isLine: false);
      }
    }
    return;
  }

  for (double y = lineHeight * 2; y <= size.height; y += lineHeight) {
    for (double x = 0; x <= size.width; x += lineHeight) {
      yield PatternElement(Offset(x, y), Offset(x, y), isLine: false);
    }
  }
}
