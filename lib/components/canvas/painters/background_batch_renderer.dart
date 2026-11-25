/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/painters/background_pattern_element.dart';
import 'package:saber/components/canvas/painters/background_viewport_helper.dart';

/// Growable [Float32List] buffer for batching line segments and point coordinates.
class Float32Buffer {
  Float32List _data;
  var _length = 0;

  Float32Buffer([int initialCapacity = 64])
    : _data = Float32List(initialCapacity);

  /// Current number of float elements stored in this buffer.
  int get length => _length;

  /// Appends a 2D point `(x, y)`.
  void addPoint(double x, double y) {
    if (_length + 2 > _data.length) _grow(_length + 2);
    _data[_length++] = x;
    _data[_length++] = y;
  }

  /// Appends a line segment from [start] to [end].
  void addSegment(Offset start, Offset end) {
    if (_length + 4 > _data.length) _grow(_length + 4);
    _data[_length++] = start.dx;
    _data[_length++] = start.dy;
    _data[_length++] = end.dx;
    _data[_length++] = end.dy;
  }

  void _grow(int minCapacity) {
    var newCap = _data.length * 2;
    if (newCap < minCapacity) newCap = minCapacity;
    _data = Float32List(newCap)..setRange(0, _length, _data);
  }

  /// Returns a zero-copy view over the populated slice of the buffer.
  Float32List view() => Float32List.sublistView(_data, 0, _length);
}

/// Batches and paints [elements] onto [canvas], optionally culling against
/// [cullRect].
void paintBackgroundPatternElements({
  required Canvas canvas,
  required Paint paint,
  required Iterable<PatternElement> elements,
  required Rect? cullRect,
  required int lineThickness,
  required double infiniteThicknessScale,
  required Color effectivePrimary,
  required Color effectiveSecondary,
}) {
  final defaultThickness = lineThickness * infiniteThicknessScale;
  final primaryLines = Float32Buffer(128);
  final dots = Float32Buffer(256);
  Map<double, Float32Buffer>? customPrimaryLines;
  List<PatternElement>? secondaryElements;

  for (final element in elements) {
    if (cullRect != null && !isElementInRect(element, cullRect)) continue;

    if (!element.isLine) {
      if (element.secondaryColor || element.thickness != null) {
        (secondaryElements ??= <PatternElement>[]).add(element);
      } else {
        dots.addPoint(element.start.dx, element.start.dy);
      }
      continue;
    }

    if (element.secondaryColor) {
      (secondaryElements ??= <PatternElement>[]).add(element);
      continue;
    }

    if (element.thickness == null) {
      primaryLines.addSegment(element.start, element.end);
      continue;
    }

    final scaledThickness = element.thickness! * infiniteThicknessScale;
    if (scaledThickness == defaultThickness) {
      primaryLines.addSegment(element.start, element.end);
    } else {
      customPrimaryLines ??= <double, Float32Buffer>{};
      (customPrimaryLines[scaledThickness] ??= Float32Buffer(
        32,
      )).addSegment(element.start, element.end);
    }
  }

  _paintPrimaryLines(
    canvas,
    paint,
    primaryLines,
    defaultThickness,
    effectivePrimary,
  );
  _paintCustomPrimaryLines(canvas, paint, customPrimaryLines, effectivePrimary);
  _paintDots(canvas, paint, dots, defaultThickness, effectivePrimary);
  _paintSecondaryElements(
    canvas,
    paint,
    secondaryElements,
    defaultThickness,
    infiniteThicknessScale,
    effectivePrimary,
    effectiveSecondary,
  );
}

void _paintPrimaryLines(
  Canvas canvas,
  Paint paint,
  Float32Buffer primaryLines,
  double defaultThickness,
  Color effectivePrimary,
) {
  if (primaryLines.length == 0) return;
  paint
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.butt
    ..strokeWidth = defaultThickness
    ..color = effectivePrimary;
  _drawLineBatch(canvas, primaryLines, paint);
}

void _paintCustomPrimaryLines(
  Canvas canvas,
  Paint paint,
  Map<double, Float32Buffer>? customPrimaryLines,
  Color effectivePrimary,
) {
  if (customPrimaryLines == null) return;
  paint
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.butt
    ..color = effectivePrimary;
  for (final entry in customPrimaryLines.entries) {
    paint.strokeWidth = entry.key;
    _drawLineBatch(canvas, entry.value, paint);
  }
}

void _paintDots(
  Canvas canvas,
  Paint paint,
  Float32Buffer dots,
  double defaultThickness,
  Color effectivePrimary,
) {
  if (dots.length == 0) return;
  final dotRadius = defaultThickness * 4 / 3;
  final raw = dots.view();
  if (raw.length >= 16) {
    paint
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = dotRadius * 2
      ..color = effectivePrimary;
    canvas.drawRawPoints(ui.PointMode.points, raw, paint);
    return;
  }
  paint
    ..style = PaintingStyle.fill
    ..color = effectivePrimary;
  for (int i = 0; i < raw.length; i += 2) {
    canvas.drawCircle(Offset(raw[i], raw[i + 1]), dotRadius, paint);
  }
}

void _paintSecondaryElements(
  Canvas canvas,
  Paint paint,
  List<PatternElement>? secondaryElements,
  double defaultThickness,
  double infiniteThicknessScale,
  Color effectivePrimary,
  Color effectiveSecondary,
) {
  if (secondaryElements == null) return;
  for (final element in secondaryElements) {
    final width = element.thickness != null
        ? element.thickness! * infiniteThicknessScale
        : defaultThickness;
    paint
      ..strokeWidth = width
      ..color = element.secondaryColor ? effectiveSecondary : effectivePrimary;
    if (element.isLine) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawLine(element.start, element.end, paint);
    } else {
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(element.start, width * 4 / 3, paint);
    }
  }
}

void _drawLineBatch(Canvas canvas, Float32Buffer buffer, Paint paint) {
  final raw = buffer.view();
  if (raw.length >= 32) {
    canvas.drawRawPoints(ui.PointMode.lines, raw, paint);
    return;
  }
  for (int i = 0; i < raw.length; i += 4) {
    canvas.drawLine(
      Offset(raw[i], raw[i + 1]),
      Offset(raw[i + 2], raw[i + 3]),
      paint,
    );
  }
}
