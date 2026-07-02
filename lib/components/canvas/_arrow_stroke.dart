import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:sbn/has_size.dart';

/// The style of arrowhead on one end of an [ArrowStroke].
enum ArrowheadStyle {
  none,
  single,
  double;

  static const defaultStyle = ArrowheadStyle.single;
}

/// A stroke representing an arrow with optional arrowheads on either end.
///
/// The arrow runs from [start] to [end]. Arrowheads can be drawn at the
/// endpoint ([ArrowheadStyle.single]) or both ends ([ArrowheadStyle.double]).
class ArrowStroke extends Stroke {
  Offset start;
  Offset end;
  ArrowheadStyle arrowheadStyle;
  double headLength;
  double headAngle;

  ArrowStroke({
    required super.color,
    required super.pressureEnabled,
    required super.options,
    required super.pageIndex,
    required super.page,
    required super.toolId,
    required this.start,
    required this.end,
    this.arrowheadStyle = ArrowheadStyle.single,
    this.headLength = 12.0,
    this.headAngle = 0.5, // ~28 degrees
    super.fillColor,
    super.lineStyle,
  }) {
    options.isComplete = true;
  }

  factory ArrowStroke.fromJson(
    Map<String, dynamic> json, {
    required int fileVersion,
    required int pageIndex,
    required HasSize page,
  }) {
    assert(json['shape'] == 'arrow');

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

    return ArrowStroke(
      color: color,
      pressureEnabled: json['pe'] ?? Stroke.defaultPressureEnabled,
      options: StrokeOptions.fromJson(json),
      pageIndex: pageIndex,
      page: page,
      toolId: .parsePenType(json['ty'], fallback: .shapePen),
      start: Offset(json['sx'] ?? 0, json['sy'] ?? 0),
      end: Offset(json['ex'] ?? 0, json['ey'] ?? 0),
      arrowheadStyle: switch (json['ah'] as String?) {
        'none' => ArrowheadStyle.none,
        'double' => ArrowheadStyle.double,
        _ => ArrowheadStyle.single,
      },
      headLength: (json['hl'] as num?)?.toDouble() ?? 12.0,
      headAngle: (json['ha'] as num?)?.toDouble() ?? 0.5,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'shape': 'arrow',
      'i': pageIndex,
      'ty': toolId.id,
      'pe': pressureEnabled,
      'c': color.toARGB32(),
      'sx': start.dx,
      'sy': start.dy,
      'ex': end.dx,
      'ey': end.dy,
      'ah': arrowheadStyle.name,
      'hl': headLength,
      'ha': headAngle,
      if (fillColor != null) 'fc': fillColor!.toARGB32(),
      if (lineStyle != LineStyle.solid) 'ls': lineStyle.name,
    }..addAll(options.toJson());
  }

  @override
  bool get isEmpty => start == end;
  @override
  int get length => 50;

  /// Returns the polygon for this arrow (shaft + arrowheads).
  @override
  List<Offset> getPolygon({required StrokeQuality quality}) {
    final dir = (end - start);
    final length = dir.distance;
    if (length < 0.001) return [start, end];

    final unitDir = dir / length;
    final perp = Offset(-unitDir.dy, unitDir.dx);

    final points = <Offset>[start, end];

    // End arrowhead
    if (arrowheadStyle == .single || arrowheadStyle == .double) {
      final tip = end;
      final left = tip - unitDir * headLength + perp * headLength * headAngle;
      final right = tip - unitDir * headLength - perp * headLength * headAngle;
      points.addAll([left, tip, right, tip]);
    }

    // Start arrowhead
    if (arrowheadStyle == .double) {
      final tip = start;
      final left = tip + unitDir * headLength + perp * headLength * headAngle;
      final right = tip + unitDir * headLength - perp * headLength * headAngle;
      points.addAll([left, tip, right, tip]);
    }

    return points;
  }

  @override
  Path getPath(List<Offset> polygon, {bool smooth = true}) {
    final path = Path();
    final dir = (end - start);
    final length = dir.distance;
    if (length < 0.001) return path;

    final unitDir = dir / length;
    final perp = Offset(-unitDir.dy, unitDir.dx);

    // Draw shaft
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    // End arrowhead
    if (arrowheadStyle == .single || arrowheadStyle == .double) {
      final tip = end;
      final left = tip - unitDir * headLength + perp * headLength * headAngle;
      final right = tip - unitDir * headLength - perp * headLength * headAngle;
      path.moveTo(left.dx, left.dy);
      path.lineTo(tip.dx, tip.dy);
      path.lineTo(right.dx, right.dy);
    }

    // Start arrowhead
    if (arrowheadStyle == .double) {
      final tip = start;
      final left = tip + unitDir * headLength + perp * headLength * headAngle;
      final right = tip + unitDir * headLength - perp * headLength * headAngle;
      path.moveTo(left.dx, left.dy);
      path.lineTo(tip.dx, tip.dy);
      path.lineTo(right.dx, right.dy);
    }

    return path;
  }

  @override
  String toSvgPath() {
    final dir = (end - start);
    final length = dir.distance;
    if (length < 0.001) return '';

    final unitDir = dir / length;
    final perp = Offset(-unitDir.dy, unitDir.dx);

    final buffer = StringBuffer();
    buffer.write('M${start.dx},${start.dy} L${end.dx},${end.dy}');

    // End arrowhead
    if (arrowheadStyle == .single || arrowheadStyle == .double) {
      final tip = end;
      final left = tip - unitDir * headLength + perp * headLength * headAngle;
      final right = tip - unitDir * headLength - perp * headLength * headAngle;
      buffer.write(' M${left.dx},${left.dy} L${tip.dx},${tip.dy}');
      buffer.write(' L${right.dx},${right.dy}');
    }

    // Start arrowhead
    if (arrowheadStyle == .double) {
      final tip = start;
      final left = tip + unitDir * headLength + perp * headLength * headAngle;
      final right = tip + unitDir * headLength - perp * headLength * headAngle;
      buffer.write(' M${left.dx},${left.dy} L${tip.dx},${tip.dy}');
      buffer.write(' L${right.dx},${right.dy}');
    }

    return buffer.toString();
  }

  @override
  double get maxY => max(start.dy, end.dy);

  @override
  void shift(Offset offset) {
    start += offset;
    end += offset;
    super.shift(offset);
  }

  @override
  void addPoint(Offset point, [double? pressure]) {
    throw UnsupportedError('Cannot add points to an arrow stroke.');
  }

  @override
  void popFirstPoint() {
    throw UnsupportedError('Cannot pop points from an arrow stroke.');
  }

  @override
  void optimisePoints({double thresholdMultiplier = 0}) {
    // no-op
  }

  @override
  bool isStraightLine([int minLength = 0]) => false;

  @override
  ArrowStroke copy() => ArrowStroke(
    color: color,
    pressureEnabled: pressureEnabled,
    options: options.copyWith(),
    pageIndex: pageIndex,
    page: page,
    toolId: toolId,
    start: start,
    end: end,
    arrowheadStyle: arrowheadStyle,
    headLength: headLength,
    headAngle: headAngle,
    fillColor: fillColor,
    lineStyle: lineStyle,
  );
}
