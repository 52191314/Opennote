import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:sbn/has_size.dart';

/// A dimension line for engineering drawings.
///
/// [start] and [end] are the measured points on the drawing.
/// The dimension line is drawn offset from these by [offset] pixels
/// perpendicular to the measured line, and has arrowheads indicating
/// the measurement direction.
class DimensionStroke extends Stroke {
  /// The two points being measured.
  Offset start;
  Offset end;

  /// The perpendicular offset of the dimension line from the measured line
  /// (positive = one direction, negative = the other).
  double offset;

  /// Optional text label for the measurement.
  String text;

  /// Arrowhead head length (forwarded to arrowheads).
  double headLength;

  /// Arrowhead head angle (forwarded to arrowheads).
  double headAngle;

  DimensionStroke({
    required super.color,
    required super.pressureEnabled,
    required super.options,
    required super.pageIndex,
    required super.page,
    required super.toolId,
    required this.start,
    required this.end,
    this.offset = 30.0,
    this.text = '',
    this.headLength = 10.0,
    this.headAngle = 0.4,
    super.fillColor,
    super.lineStyle,
  }) {
    options.isComplete = true;
  }

  factory DimensionStroke.fromJson(
    Map<String, dynamic> json, {
    required int fileVersion,
    required int pageIndex,
    required HasSize page,
  }) {
    assert(json['shape'] == 'dimension');

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

    return DimensionStroke(
      color: color,
      pressureEnabled: json['pe'] ?? Stroke.defaultPressureEnabled,
      options: StrokeOptions.fromJson(json),
      pageIndex: pageIndex,
      page: page,
      toolId: .parsePenType(json['ty'], fallback: .shapePen),
      start: Offset(json['sx'] ?? 0, json['sy'] ?? 0),
      end: Offset(json['ex'] ?? 0, json['ey'] ?? 0),
      offset: (json['o'] as num?)?.toDouble() ?? 30.0,
      text: json['t'] as String? ?? '',
      headLength: (json['hl'] as num?)?.toDouble() ?? 10.0,
      headAngle: (json['ha'] as num?)?.toDouble() ?? 0.4,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'shape': 'dimension',
      'i': pageIndex,
      'ty': toolId.id,
      'pe': pressureEnabled,
      'c': color.toARGB32(),
      'sx': start.dx,
      'sy': start.dy,
      'ex': end.dx,
      'ey': end.dy,
      'o': offset,
      if (text.isNotEmpty) 't': text,
      'hl': headLength,
      'ha': headAngle,
      if (fillColor != null) 'fc': fillColor!.toARGB32(),
      if (lineStyle != LineStyle.solid) 'ls': lineStyle.name,
    }..addAll(options.toJson());
  }

  /// Computes the unit direction and perpendicular vectors for the measured line.
  (Offset dir, Offset perp) _computeVectors() {
    final dir = (end - start);
    final length = dir.distance;
    if (length < 0.001) return (Offset.zero, Offset.zero);
    final unitDir = dir / length;
    return (unitDir, Offset(-unitDir.dy, unitDir.dx));
  }

  @override
  bool get isEmpty => start == end;
  @override
  int get length => 100;

  @override
  List<Offset> getPolygon({required StrokeQuality quality}) {
    return [start, end]; // Minimal polygon for hit testing
  }

  @override
  Path getPath(List<Offset> polygon, {bool smooth = true}) {
    final path = Path();
    final (unitDir, perp) = _computeVectors();
    if (unitDir == Offset.zero) return path;

    final dimOffset = perp * offset;
    final dimStart = start + dimOffset;
    final dimEnd = end + dimOffset;

    // Extension lines
    path.moveTo(start.dx, start.dy);
    path.lineTo(dimStart.dx, dimStart.dy);
    path.moveTo(end.dx, end.dy);
    path.lineTo(dimEnd.dx, dimEnd.dy);

    // Dimension line (with arrowheads at each end)
    path.moveTo(dimStart.dx, dimStart.dy);
    path.lineTo(dimEnd.dx, dimEnd.dy);

    // Arrowheads (standard: single at each end pointing inward)
    final headLen = headLength;
    final headAng = headAngle;

    // Arrowhead at dimStart (pointing toward dimEnd)
    final ah1Left = dimStart + unitDir * headLen + perp * headLen * headAng;
    final ah1Right = dimStart + unitDir * headLen - perp * headLen * headAng;
    path.moveTo(ah1Left.dx, ah1Left.dy);
    path.lineTo(dimStart.dx, dimStart.dy);
    path.lineTo(ah1Right.dx, ah1Right.dy);

    // Arrowhead at dimEnd (pointing toward dimStart)
    final ah2Left = dimEnd - unitDir * headLen + perp * headLen * headAng;
    final ah2Right = dimEnd - unitDir * headLen - perp * headLen * headAng;
    path.moveTo(ah2Left.dx, ah2Left.dy);
    path.lineTo(dimEnd.dx, dimEnd.dy);
    path.lineTo(ah2Right.dx, ah2Right.dy);

    return path;
  }

  @override
  String toSvgPath() {
    final (unitDir, perp) = _computeVectors();
    if (unitDir == Offset.zero) return '';

    final dimOffset = perp * offset;
    final dimStart = start + dimOffset;
    final dimEnd = end + dimOffset;
    final headLen = headLength;
    final headAng = headAngle;

    final buf = StringBuffer();

    // Extension lines
    buf.write('M${start.dx},${start.dy} L${dimStart.dx},${dimStart.dy}');
    buf.write(' M${end.dx},${end.dy} L${dimEnd.dx},${dimEnd.dy}');

    // Dimension line
    buf.write(' M${dimStart.dx},${dimStart.dy} L${dimEnd.dx},${dimEnd.dy}');

    // Arrowhead at dimStart
    final a1L = dimStart + unitDir * headLen + perp * headLen * headAng;
    final a1R = dimStart + unitDir * headLen - perp * headLen * headAng;
    buf.write(' M${a1L.dx},${a1L.dy} L${dimStart.dx},${dimStart.dy}');
    buf.write(' L${a1R.dx},${a1R.dy}');

    // Arrowhead at dimEnd
    final a2L = dimEnd - unitDir * headLen + perp * headLen * headAng;
    final a2R = dimEnd - unitDir * headLen - perp * headLen * headAng;
    buf.write(' M${a2L.dx},${a2L.dy} L${dimEnd.dx},${dimEnd.dy}');
    buf.write(' L${a2R.dx},${a2R.dy}');

    return buf.toString();
  }

  /// Computes the text position (centered on the dimension line).
  Offset get textPosition {
    final (_, perp) = _computeVectors();
    final dimOffset = perp * offset;
    final dimStart = start + dimOffset;
    final dimEnd = end + dimOffset;
    return (dimStart + dimEnd) / 2;
  }

  @override
  double get maxY {
    final (_, perp) = _computeVectors();
    final dimOffset = perp * offset;
    final dimStart = start + dimOffset;
    final dimEnd = end + dimOffset;
    return [
      start.dy, end.dy, dimStart.dy, dimEnd.dy,
    ].reduce(max);
  }

  @override
  void shift(Offset offset) {
    start += offset;
    end += offset;
    super.shift(offset);
  }

  @override
  void addPoint(Offset point, [double? pressure]) {
    throw UnsupportedError('Cannot add points to a dimension stroke.');
  }

  @override
  void popFirstPoint() {
    throw UnsupportedError('Cannot pop points from a dimension stroke.');
  }

  @override
  void optimisePoints({double thresholdMultiplier = 0}) {
    // no-op
  }

  @override
  bool isStraightLine([int minLength = 0]) => false;

  @override
  DimensionStroke copy() => DimensionStroke(
    color: color,
    pressureEnabled: pressureEnabled,
    options: options.copyWith(),
    pageIndex: pageIndex,
    page: page,
    toolId: toolId,
    start: start,
    end: end,
    offset: offset,
    text: text,
    headLength: headLength,
    headAngle: headAngle,
    fillColor: fillColor,
    lineStyle: lineStyle,
  );
}
