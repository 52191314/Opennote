/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/painters/background_pattern_element.dart';

/// Generates Cartesian grid pattern elements, clamped to [clampedBounds] when
/// rendering on an infinite canvas.
Iterable<PatternElement> generateGridPatternElements({
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
    if (countX > 5000 || countY > 5000) return;

    for (double y = startY; y <= endY; y += lineHeight) {
      yield PatternElement(
        Offset(clampedBounds.left, y),
        Offset(clampedBounds.right, y),
        isLine: true,
      );
    }
    for (double x = startX; x <= endX; x += lineHeight) {
      yield PatternElement(
        Offset(x, clampedBounds.top),
        Offset(x, clampedBounds.bottom),
        isLine: true,
      );
    }
    return;
  }

  for (double y = lineHeight * 2; y < size.height; y += lineHeight) {
    yield PatternElement(Offset(0, y), Offset(size.width, y), isLine: true);
  }
  for (double x = 0; x < size.width; x += lineHeight) {
    yield PatternElement(
      Offset(x, lineHeight * 2),
      Offset(x, size.height),
      isLine: true,
    );
  }
}

/// Generates engineering grid elements with heavy major lines every 10 cells,
/// clamped to [clampedBounds] when rendering on an infinite canvas.
Iterable<PatternElement> generateEngineeringGridPatternElements({
  required Size size,
  required int lineHeight,
  required int lineThickness,
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
    if (countX > 5000 || countY > 5000) return;

    for (double y = startY; y <= endY; y += lineHeight) {
      final isHeavy = (y / lineHeight).round() % 10 == 0;
      yield PatternElement(
        Offset(clampedBounds.left, y),
        Offset(clampedBounds.right, y),
        thickness: isHeavy ? lineThickness * 3.0 : null,
      );
    }
    for (double x = startX; x <= endX; x += lineHeight) {
      final isHeavy = (x / lineHeight).round() % 10 == 0;
      yield PatternElement(
        Offset(x, clampedBounds.top),
        Offset(x, clampedBounds.bottom),
        thickness: isHeavy ? lineThickness * 3.0 : null,
      );
    }
    return;
  }

  for (double y = lineHeight * 2; y < size.height; y += lineHeight) {
    final isHeavy = ((y - lineHeight * 2) / lineHeight).round() % 10 == 0;
    yield PatternElement(
      Offset(0, y),
      Offset(size.width, y),
      thickness: isHeavy ? lineThickness * 3.0 : null,
    );
  }
  for (double x = 0; x < size.width; x += lineHeight) {
    final isHeavy = (x / lineHeight).round() % 10 == 0;
    yield PatternElement(
      Offset(x, lineHeight * 2),
      Offset(x, size.height),
      thickness: isHeavy ? lineThickness * 3.0 : null,
    );
  }
}

/// Generates 3-axis isometric triangular grid elements, clamped to
/// [clampedBounds] when rendering on an infinite canvas.
Iterable<PatternElement> generateIsometricPatternElements({
  required Size size,
  required int lineHeight,
  Rect? clampedBounds,
}) sync* {
  if (lineHeight <= 0) return;
  final l = lineHeight.toDouble();
  final dx = l * (sqrt(3) / 2);
  if (dx <= 0) return;
  final tan30 = 1 / sqrt(3);

  if (clampedBounds != null) {
    yield* _generateInfiniteIsometric(clampedBounds, l, dx, tan30);
    return;
  }

  for (double x = 0; x <= size.width + 1e-6; x += dx) {
    final clampedX = x.clamp(0.0, size.width);
    yield PatternElement(Offset(clampedX, 0), Offset(clampedX, size.height));
  }

  final mMin = (-tan30 * size.width / l).floor();
  final mMax = (size.height / l).ceil();
  for (int m = mMin; m <= mMax; m++) {
    final b = m * l;
    final candidates = <Offset>[
      if (b >= 0 && b <= size.height) Offset(0, b),
      if (-b / tan30 > 0 && -b / tan30 < size.width) Offset(-b / tan30, 0),
      if (tan30 * size.width + b >= 0 && tan30 * size.width + b <= size.height)
        Offset(size.width, tan30 * size.width + b),
      if ((size.height - b) / tan30 > 0 &&
          (size.height - b) / tan30 < size.width)
        Offset((size.height - b) / tan30, size.height),
    ];
    final element = _clipCandidatesToPage(candidates, size);
    if (element != null) yield element;
  }

  final kMax = ((size.height + tan30 * size.width) / l).ceil();
  for (int k = 0; k <= kMax; k++) {
    final c = k * l;
    final candidates = <Offset>[
      if (c >= 0 && c <= size.height) Offset(0, c),
      if (c / tan30 > 0 && c / tan30 < size.width) Offset(c / tan30, 0),
      if (-tan30 * size.width + c >= 0 &&
          -tan30 * size.width + c <= size.height)
        Offset(size.width, -tan30 * size.width + c),
      if ((c - size.height) / tan30 > 0 &&
          (c - size.height) / tan30 < size.width)
        Offset((c - size.height) / tan30, size.height),
    ];
    final element = _clipCandidatesToPage(candidates, size);
    if (element != null) yield element;
  }
}

Iterable<PatternElement> _generateInfiniteIsometric(
  Rect clampedBounds,
  double l,
  double dx,
  double tan30,
) sync* {
  final colMin = (clampedBounds.left / dx).floor();
  final colMax = (clampedBounds.right / dx).ceil();
  if (colMax - colMin > 5000) return;
  for (int col = colMin; col <= colMax; col++) {
    final x = col * dx;
    yield PatternElement(
      Offset(x, clampedBounds.top),
      Offset(x, clampedBounds.bottom),
    );
  }

  final mMin = ((clampedBounds.top - tan30 * clampedBounds.right) / l).floor();
  final mMax = ((clampedBounds.bottom - tan30 * clampedBounds.left) / l).ceil();
  if (mMax - mMin > 5000) return;
  for (int m = mMin; m <= mMax; m++) {
    final b = m * l;
    yield PatternElement(
      Offset((clampedBounds.top - b) / tan30, clampedBounds.top),
      Offset((clampedBounds.bottom - b) / tan30, clampedBounds.bottom),
    );
  }

  final kMin = ((clampedBounds.top + tan30 * clampedBounds.left) / l).floor();
  final kMax = ((clampedBounds.bottom + tan30 * clampedBounds.right) / l)
      .ceil();
  if (kMax - kMin > 5000) return;
  for (int k = kMin; k <= kMax; k++) {
    final c = k * l;
    yield PatternElement(
      Offset((c - clampedBounds.top) / tan30, clampedBounds.top),
      Offset((c - clampedBounds.bottom) / tan30, clampedBounds.bottom),
    );
  }
}

PatternElement? _clipCandidatesToPage(List<Offset> candidates, Size size) {
  if (candidates.length < 2) return null;
  candidates.sort((a, b) => a.dx.compareTo(b.dx));
  final start = Offset(
    candidates.first.dx.clamp(0.0, size.width),
    candidates.first.dy.clamp(0.0, size.height),
  );
  final end = Offset(
    candidates.last.dx.clamp(0.0, size.width),
    candidates.last.dy.clamp(0.0, size.height),
  );
  if ((end.dx - start.dx).abs() <= 1e-4 && (end.dy - start.dy).abs() <= 1e-4) {
    return null;
  }
  return PatternElement(start, end);
}
