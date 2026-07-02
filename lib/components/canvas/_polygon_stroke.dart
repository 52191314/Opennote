import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:sbn/has_size.dart';

/// A stroke representing an arbitrary polygon with N vertices.
///
/// If [closed] is true, the first and last vertices are connected
/// (forming a closed shape). Polygons can be filled with [fillColor].
class PolygonStroke extends Stroke {
  final List<Offset> vertices;
  bool closed;

  PolygonStroke({
    required super.color,
    required super.pressureEnabled,
    required super.options,
    required super.pageIndex,
    required super.page,
    required super.toolId,
    required this.vertices,
    this.closed = true,
    super.fillColor,
    super.lineStyle,
  }) {
    options.isComplete = true;
  }

  factory PolygonStroke.fromJson(
    Map<String, dynamic> json, {
    required int fileVersion,
    required int pageIndex,
    required HasSize page,
  }) {
    assert(json['shape'] == 'polygon');

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

    final verticesJson = json['v'] as List<dynamic>? ?? [];
    final vertices = verticesJson.map((v) {
      final vMap = v as Map<String, dynamic>;
      return Offset(
        (vMap['x'] as num).toDouble(),
        (vMap['y'] as num).toDouble(),
      );
    }).toList();

    return PolygonStroke(
      color: color,
      pressureEnabled: json['pe'] ?? Stroke.defaultPressureEnabled,
      options: StrokeOptions.fromJson(json),
      pageIndex: pageIndex,
      page: page,
      toolId: .parsePenType(json['ty'], fallback: .shapePen),
      vertices: vertices,
      closed: json['cl'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'shape': 'polygon',
      'i': pageIndex,
      'ty': toolId.id,
      'pe': pressureEnabled,
      'c': color.toARGB32(),
      'v': vertices
          .map((v) => {'x': v.dx, 'y': v.dy})
          .toList(),
      'cl': closed,
      if (fillColor != null) 'fc': fillColor!.toARGB32(),
      if (lineStyle != LineStyle.solid) 'ls': lineStyle.name,
    }..addAll(options.toJson());
  }

  @override
  bool get isEmpty => vertices.isEmpty;
  @override
  int get length => vertices.length * 10;

  @override
  List<Offset> getPolygon({required StrokeQuality quality}) {
    return vertices;
  }

  @override
  Path getPath(List<Offset> polygon, {bool smooth = true}) {
    if (vertices.isEmpty) return Path();
    return Path()..addPolygon(vertices, closed);
  }

  @override
  String toSvgPath() {
    if (vertices.isEmpty) return '';
    final buf = StringBuffer();
    buf.write('M${vertices.first.dx},${vertices.first.dy}');
    for (int i = 1; i < vertices.length; i++) {
      buf.write(' L${vertices[i].dx},${vertices[i].dy}');
    }
    if (closed) buf.write(' Z');
    return buf.toString();
  }

  @override
  double get maxY {
    return vertices.isEmpty ? 0 : vertices.map((v) => v.dy).reduce(max);
  }

  @override
  void shift(Offset offset) {
    for (int i = 0; i < vertices.length; i++) {
      vertices[i] = vertices[i] + offset;
    }
    super.shift(offset);
  }

  @override
  void addPoint(Offset point, [double? pressure]) {
    throw UnsupportedError('Cannot add points to a polygon stroke.');
  }

  @override
  void popFirstPoint() {
    throw UnsupportedError('Cannot pop points from a polygon stroke.');
  }

  @override
  void optimisePoints({double thresholdMultiplier = 0}) {
    // no-op
  }

  @override
  bool isStraightLine([int minLength = 0]) => false;

  @override
  PolygonStroke copy() => PolygonStroke(
    color: color,
    pressureEnabled: pressureEnabled,
    options: options.copyWith(),
    pageIndex: pageIndex,
    page: page,
    toolId: toolId,
    vertices: List.from(vertices),
    closed: closed,
    fillColor: fillColor,
    lineStyle: lineStyle,
  );
}
