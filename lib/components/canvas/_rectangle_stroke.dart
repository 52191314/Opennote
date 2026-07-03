import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:sbn/has_size.dart';

class RectangleStroke extends Stroke {
  Rect rect;

  RectangleStroke({
    required super.color,
    required super.pressureEnabled,
    required super.options,
    required super.pageIndex,
    required super.page,
    required super.toolId,
    required this.rect,
    super.fillColor,
    super.lineStyle,
  }) {
    options.isComplete = true;
  }

  factory RectangleStroke.fromJson(
    Map<String, dynamic> json, {
    required int fileVersion,
    required int pageIndex,
    required HasSize page,
  }) {
    assert(json['shape'] == 'rect');
    assert(json['i'] == pageIndex || json['i'] == null);

    final Color color;
    switch (json['c']) {
      case (final int value):
        color = Color(value);
      case (final Int64 value):
        color = Color(value.toInt());
      case null:
        color = Stroke.defaultColor;
      default:
        throw Exception(
          'Invalid color value: (${json['c'].runtimeType}) ${json['c']}',
        );
    }

    return RectangleStroke(
      color: color,
      pressureEnabled: json['pe'] ?? Stroke.defaultPressureEnabled,
      options: StrokeOptions.fromJson(json),
      pageIndex: pageIndex,
      page: page,
      toolId: .parsePenType(json['ty'], fallback: .shapePen),
      rect: .fromLTWH(
        json['rl'] ?? 0,
        json['rt'] ?? 0,
        json['rw'] ?? 0,
        json['rh'] ?? 0,
      ),
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      'shape': 'rect',
      'i': pageIndex,
      'rl': rect.left,
      'rt': rect.top,
      'rw': rect.width,
      'rh': rect.height,
      'pe': pressureEnabled,
      'c': color.toARGB32(),
    }..addAll(options.toJson());
  }

  @override
  bool get isEmpty => rect.isEmpty;
  @override
  int get length => 100;

  /// A list of points that form the rectangle's perimeter.
  /// Each side has 24/N points.
  @override
  List<Offset> getPolygon({required StrokeQuality quality}) => [
    // left side
    for (int i = 0; i < 24 / quality.N; ++i)
      Offset(rect.left, rect.top + rect.height * i / 24),
    // bottom side
    for (int i = 0; i < 24 / quality.N; ++i)
      Offset(rect.left + rect.width * i / 24, rect.bottom),
    // right side
    for (int i = 0; i < 24 / quality.N; ++i)
      Offset(rect.right, rect.bottom - rect.height * i / 24),
    // top side
    for (int i = 0; i < 24 / quality.N; ++i)
      Offset(rect.right - rect.width * i / 24, rect.top),
  ];

  /// Returns a [Path] with four lines for each side of the rectangle.
  @override
  Path getPath(List<Offset> polygon, {bool smooth = true}) =>
      Path()..addRect(rect);

  @override
  @Deprecated('Cannot add points to a rectangle stroke.')
  void addPoint(Offset point, [double? pressure]) {
    throw UnsupportedError('Cannot add points to a rectangle stroke.');
  }

  @override
  @Deprecated('Cannot pop points from a rectangle stroke.')
  void popFirstPoint() {
    throw UnsupportedError('Cannot pop points from a rectangle stroke.');
  }

  @override
  void optimisePoints({double thresholdMultiplier = 0}) {
    // no-op
  }

  @override
  String toSvgPath() {
    return 'M${rect.left},${rect.top} '
        'L${rect.right},${rect.top} '
        'L${rect.right},${rect.bottom} '
        'L${rect.left},${rect.bottom} '
        'Z';
  }

  @override
  double get maxY {
    return rect.bottom;
  }

  @override
  void shift(Offset offset) {
    rect = rect.shift(offset);
    super.shift(offset);
  }

  @override
  void rotateAround(double angleRadians, Offset center) {
    if (angleRadians == 0) return;

    final cosA = cos(angleRadians);
    final sinA = sin(angleRadians);

    Offset _rotatePoint(Offset p) {
      final dx = p.dx - center.dx;
      final dy = p.dy - center.dy;
      return Offset(
        center.dx + dx * cosA - dy * sinA,
        center.dy + dx * sinA + dy * cosA,
      );
    }

    final topLeft = _rotatePoint(rect.topLeft);
    final topRight = _rotatePoint(rect.topRight);
    final bottomRight = _rotatePoint(rect.bottomRight);
    final bottomLeft = _rotatePoint(rect.bottomLeft);

    final newLeft = min(topLeft.dx, min(topRight.dx, min(bottomRight.dx, bottomLeft.dx)));
    final newTop = min(topLeft.dy, min(topRight.dy, min(bottomRight.dy, bottomLeft.dy)));
    final newRight = max(topLeft.dx, max(topRight.dx, max(bottomRight.dx, bottomLeft.dx)));
    final newBottom = max(topLeft.dy, max(topRight.dy, max(bottomRight.dy, bottomLeft.dy)));

    rect = Rect.fromLTRB(newLeft, newTop, newRight, newBottom);

    super.rotateAround(angleRadians, center);
  }

  @override
  void scaleAround(double scaleX, double scaleY, Offset pivot) {
    if (scaleX == 0 || scaleY == 0) return;
    Offset scalePoint(Offset p) => Offset(
      pivot.dx + (p.dx - pivot.dx) * scaleX,
      pivot.dy + (p.dy - pivot.dy) * scaleY,
    );
    final topLeft = scalePoint(rect.topLeft);
    final topRight = scalePoint(rect.topRight);
    final bottomRight = scalePoint(rect.bottomRight);
    final bottomLeft = scalePoint(rect.bottomLeft);
    rect = Rect.fromLTRB(
      min(topLeft.dx, min(topRight.dx, min(bottomRight.dx, bottomLeft.dx))),
      min(topLeft.dy, min(topRight.dy, min(bottomRight.dy, bottomLeft.dy))),
      max(topLeft.dx, max(topRight.dx, max(bottomRight.dx, bottomLeft.dx))),
      max(topLeft.dy, max(topRight.dy, max(bottomRight.dy, bottomLeft.dy))),
    );
    super.scaleAround(scaleX, scaleY, pivot);
  }

  @override
  @Deprecated('We already know the shape is a rectangle.')
  RecognizedUnistroke detectShape() {
    return RecognizedUnistroke(
      DefaultUnistrokeNames.rectangle,
      1,
      originalPoints: lowQualityPolygon,
      referenceUnistrokes: default$1Unistrokes,
    );
  }

  @override
  @Deprecated('We already know the shape is a rectangle.')
  bool isStraightLine([int minLength = 0]) => false;

  @override
  RectangleStroke copy() => RectangleStroke(
    color: color,
    pressureEnabled: pressureEnabled,
    options: options.copyWith(),
    pageIndex: pageIndex,
    page: page,
    toolId: toolId,
    rect: rect,
    fillColor: fillColor,
    lineStyle: lineStyle,
  );
}
