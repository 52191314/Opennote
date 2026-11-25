/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_circle_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_polygon_stroke.dart';
import 'package:saber/components/canvas/_rectangle_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/data/extensions/point_extensions.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

/// Parses a color field from JSON/BSON, throwing on unexpected types.
Color parseStrokeColor(dynamic rawColor, {required Color fallback}) {
  return switch (rawColor) {
    final int value => Color(value),
    final Int64 value => Color(value.toInt()),
    null => fallback,
    _ => throw Exception(
      'Invalid color value: (${rawColor.runtimeType}) $rawColor',
    ),
  };
}

/// Parses an optional color field from JSON/BSON, returning null if absent.
Color? parseOptionalStrokeColor(dynamic rawColor) {
  return switch (rawColor) {
    final int value => Color(value),
    final Int64 value => Color(value.toInt()),
    _ => null,
  };
}

/// Parses a serialized [LineStyle] name, defaulting to [LineStyle.solid].
LineStyle parseLineStyle(String? rawStyle) {
  return switch (rawStyle) {
    'dashed' => LineStyle.dashed,
    'dotted' => LineStyle.dotted,
    _ => LineStyle.solid,
  };
}

/// Deserializes a [Stroke] (or shape subclass) from JSON/BSON map [json].
Stroke parseStrokeFromJson(
  Map<String, dynamic> json, {
  required int fileVersion,
  required int pageIndex,
  required HasSize page,
  required Logger log,
}) {
  assert(json['i'] == pageIndex || json['i'] == null);
  final shapeStroke = _parseShapeStroke(
    json,
    fileVersion: fileVersion,
    pageIndex: pageIndex,
    page: page,
    log: log,
  );
  if (shapeStroke != null) return shapeStroke;

  final toolId = ToolId.parsePenType(json['ty'], fallback: ToolId.fountainPen);
  final options = StrokeOptions.fromJson(json);
  final pressureEnabled = json['pe'] ?? Stroke.defaultPressureEnabled;
  if (toolId == ToolId.shapePen) {
    options.smoothing = 0;
    options.streamline = 0;
  }

  final color = parseStrokeColor(json['c'], fallback: Stroke.defaultColor);
  final fillColor = parseOptionalStrokeColor(json['fc']);
  final lineStyle = parseLineStyle(json['ls'] as String?);

  final offset = Offset(json['ox'] ?? 0, json['oy'] ?? 0);
  final pointsJson = json['p'] as List<dynamic>;
  final points = _decodePoints(
    pointsJson,
    fileVersion: fileVersion,
    offset: offset,
  );

  return Stroke(
    color: color,
    pressureEnabled: pressureEnabled,
    options: options,
    pageIndex: pageIndex,
    page: page,
    toolId: toolId,
    fillColor: fillColor,
    lineStyle: lineStyle,
  )..rawPoints.addAll(points);
}

/// Serializes [stroke] to a JSON/BSON-compatible map.
Map<String, dynamic> serializeStrokeToJson(Stroke stroke) {
  return {
    'shape': null,
    'p': stroke.rawPoints
        .where((point) => point.isFinite)
        .map((PointVector point) => point.toBsonBinary())
        .toList(),
    'i': stroke.pageIndex,
    'ty': stroke.toolId.id,
    'pe': stroke.pressureEnabled,
    'c': stroke.color.toARGB32(),
    if (stroke.fillColor != null) 'fc': stroke.fillColor!.toARGB32(),
    if (stroke.lineStyle != LineStyle.solid) 'ls': stroke.lineStyle.name,
  }..addAll(stroke.options.toJson());
}

Stroke? _parseShapeStroke(
  Map<String, dynamic> json, {
  required int fileVersion,
  required int pageIndex,
  required HasSize page,
  required Logger log,
}) {
  switch (json['shape'] as String?) {
    case null:
      return null;
    case 'circle':
      return CircleStroke.fromJson(
        json,
        fileVersion: fileVersion,
        pageIndex: pageIndex,
        page: page,
      );
    case 'rect':
      return RectangleStroke.fromJson(
        json,
        fileVersion: fileVersion,
        pageIndex: pageIndex,
        page: page,
      );
    case 'arrow':
      return ArrowStroke.fromJson(
        json,
        fileVersion: fileVersion,
        pageIndex: pageIndex,
        page: page,
      );
    case 'dimension':
      return DimensionStroke.fromJson(
        json,
        fileVersion: fileVersion,
        pageIndex: pageIndex,
        page: page,
      );
    case 'polygon':
      return PolygonStroke.fromJson(
        json,
        fileVersion: fileVersion,
        pageIndex: pageIndex,
        page: page,
      );
    case 'tape':
      return TapeStroke.fromJson(
        json,
        fileVersion: fileVersion,
        pageIndex: pageIndex,
        page: page,
      );
    default:
      log.severe('Unknown shape: ${json['shape']}');
      return null;
  }
}

Iterable<PointVector> _decodePoints(
  List<dynamic> pointsJson, {
  required int fileVersion,
  required Offset offset,
}) {
  if (fileVersion >= 13) {
    return pointsJson.map(
      (point) => PointExtensions.fromBsonBinary(json: point, offset: offset),
    );
  }
  return pointsJson.map(
    // ignore: deprecated_member_use_from_same_package
    (point) => PointExtensions.fromJson(
      json: Map<String, dynamic>.from(point),
      offset: offset,
    ),
  );
}
