/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

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

/// The routing path style of an [ArrowStroke].
enum ConnectorStyle {
  straight,
  elbow,
  curved;

  static const defaultStyle = ConnectorStyle.straight;
}

/// A stroke representing an arrow or connector with optional arrowheads on either end.
///
/// The connector routes from [start] to [end] according to [connectorStyle].
/// Arrowheads can be drawn at the endpoint ([ArrowheadStyle.single]) or both ends ([ArrowheadStyle.double]).
class ArrowStroke extends Stroke {
  Offset start;
  Offset end;
  ArrowheadStyle arrowheadStyle;
  ConnectorStyle connectorStyle;
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
    this.connectorStyle = ConnectorStyle.straight,
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
      start: Offset(
        (json['sx'] as num?)?.toDouble() ?? 0,
        (json['sy'] as num?)?.toDouble() ?? 0,
      ),
      end: Offset(
        (json['ex'] as num?)?.toDouble() ?? 0,
        (json['ey'] as num?)?.toDouble() ?? 0,
      ),
      arrowheadStyle: switch (json['ah'] as String?) {
        'none' => ArrowheadStyle.none,
        'double' => ArrowheadStyle.double,
        _ => ArrowheadStyle.single,
      },
      connectorStyle: switch (json['cnt'] as String?) {
        'elbow' => ConnectorStyle.elbow,
        'curved' => ConnectorStyle.curved,
        _ => ConnectorStyle.straight,
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
      'cnt': connectorStyle.name,
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

  Offset _endTangent() {
    switch (connectorStyle) {
      case ConnectorStyle.straight:
        final dir = end - start;
        return dir.distance > 0.001 ? dir / dir.distance : const Offset(1, 0);
      case ConnectorStyle.elbow:
        final midX = (start.dx + end.dx) / 2;
        if ((end.dx - midX).abs() > 0.001) {
          return Offset((end.dx - midX).sign, 0);
        } else if ((end.dy - start.dy).abs() > 0.001) {
          return Offset(0, (end.dy - start.dy).sign);
        }
        return const Offset(1, 0);
      case ConnectorStyle.curved:
        final c2 = Offset(start.dx + (end.dx - start.dx) * 0.5, end.dy);
        final tangent = end - c2;
        if (tangent.distance > 0.001) return tangent / tangent.distance;
        final dir = end - start;
        return dir.distance > 0.001 ? dir / dir.distance : const Offset(1, 0);
    }
  }

  Offset _startTangent() {
    switch (connectorStyle) {
      case ConnectorStyle.straight:
        final dir = end - start;
        return dir.distance > 0.001 ? dir / dir.distance : const Offset(1, 0);
      case ConnectorStyle.elbow:
        final midX = (start.dx + end.dx) / 2;
        if ((midX - start.dx).abs() > 0.001) {
          return Offset((midX - start.dx).sign, 0);
        } else if ((end.dy - start.dy).abs() > 0.001) {
          return Offset(0, (end.dy - start.dy).sign);
        }
        return const Offset(1, 0);
      case ConnectorStyle.curved:
        final c1 = Offset(start.dx + (end.dx - start.dx) * 0.5, start.dy);
        final tangent = c1 - start;
        if (tangent.distance > 0.001) return tangent / tangent.distance;
        final dir = end - start;
        return dir.distance > 0.001 ? dir / dir.distance : const Offset(1, 0);
    }
  }

  /// Returns the polygon for this arrow (shaft + arrowheads).
  @override
  List<Offset> getPolygon({required StrokeQuality quality}) {
    if (start == end) return [start, end];

    final points = <Offset>[start];

    switch (connectorStyle) {
      case ConnectorStyle.straight:
        points.add(end);
      case ConnectorStyle.elbow:
        final midX = (start.dx + end.dx) / 2;
        points.addAll([Offset(midX, start.dy), Offset(midX, end.dy), end]);
      case ConnectorStyle.curved:
        final dx = end.dx - start.dx;
        final c1 = Offset(start.dx + dx * 0.5, start.dy);
        final c2 = Offset(start.dx + dx * 0.5, end.dy);
        for (int i = 1; i <= 16; i++) {
          final t = i / 16.0;
          final it = 1.0 - t;
          final pt = start * (it * it * it) +
              c1 * (3 * it * it * t) +
              c2 * (3 * it * t * t) +
              end * (t * t * t);
          points.add(pt);
        }
    }

    // End arrowhead
    if (arrowheadStyle == .single || arrowheadStyle == .double) {
      final unitDir = _endTangent();
      final perp = Offset(-unitDir.dy, unitDir.dx);
      final tip = end;
      final left = tip - unitDir * headLength + perp * headLength * headAngle;
      final right = tip - unitDir * headLength - perp * headLength * headAngle;
      points.addAll([left, tip, right, tip]);
    }

    // Start arrowhead
    if (arrowheadStyle == .double) {
      final unitDir = _startTangent();
      final perp = Offset(-unitDir.dy, unitDir.dx);
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
    if (start == end) return path;

    // Draw shaft according to connectorStyle
    switch (connectorStyle) {
      case ConnectorStyle.straight:
        path.moveTo(start.dx, start.dy);
        path.lineTo(end.dx, end.dy);
      case ConnectorStyle.elbow:
        final midX = (start.dx + end.dx) / 2;
        final dx1 = (midX - start.dx).abs();
        final dy = (end.dy - start.dy).abs();
        final dx2 = (end.dx - midX).abs();
        final r = min(12.0, min(dx1, min(dy, dx2)) / 2);
        if (r < 1.0) {
          path.moveTo(start.dx, start.dy);
          path.lineTo(midX, start.dy);
          path.lineTo(midX, end.dy);
          path.lineTo(end.dx, end.dy);
        } else {
          final sgnX1 = midX >= start.dx ? 1.0 : -1.0;
          final sgnY = end.dy >= start.dy ? 1.0 : -1.0;
          final sgnX2 = end.dx >= midX ? 1.0 : -1.0;
          path.moveTo(start.dx, start.dy);
          path.lineTo(midX - sgnX1 * r, start.dy);
          path.quadraticBezierTo(midX, start.dy, midX, start.dy + sgnY * r);
          path.lineTo(midX, end.dy - sgnY * r);
          path.quadraticBezierTo(midX, end.dy, midX + sgnX2 * r, end.dy);
          path.lineTo(end.dx, end.dy);
        }
      case ConnectorStyle.curved:
        final dx = end.dx - start.dx;
        final c1 = Offset(start.dx + dx * 0.5, start.dy);
        final c2 = Offset(start.dx + dx * 0.5, end.dy);
        path.moveTo(start.dx, start.dy);
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    }

    // End arrowhead
    if (arrowheadStyle == .single || arrowheadStyle == .double) {
      final unitDir = _endTangent();
      final perp = Offset(-unitDir.dy, unitDir.dx);
      final tip = end;
      final left = tip - unitDir * headLength + perp * headLength * headAngle;
      final right = tip - unitDir * headLength - perp * headLength * headAngle;
      path.moveTo(left.dx, left.dy);
      path.lineTo(tip.dx, tip.dy);
      path.lineTo(right.dx, right.dy);
    }

    // Start arrowhead
    if (arrowheadStyle == .double) {
      final unitDir = _startTangent();
      final perp = Offset(-unitDir.dy, unitDir.dx);
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
    if (start == end) return '';

    String toSvgPoint(Offset point) {
      return '${point.dx} ${page.size.height - point.dy}';
    }

    final buffer = StringBuffer();

    switch (connectorStyle) {
      case ConnectorStyle.straight:
        buffer.write('M${toSvgPoint(start)} L${toSvgPoint(end)}');
      case ConnectorStyle.elbow:
        final midX = (start.dx + end.dx) / 2;
        buffer.write(
          'M${toSvgPoint(start)} '
          'L${toSvgPoint(Offset(midX, start.dy))} '
          'L${toSvgPoint(Offset(midX, end.dy))} '
          'L${toSvgPoint(end)}',
        );
      case ConnectorStyle.curved:
        final dx = end.dx - start.dx;
        final c1 = Offset(start.dx + dx * 0.5, start.dy);
        final c2 = Offset(start.dx + dx * 0.5, end.dy);
        buffer.write(
          'M${toSvgPoint(start)} '
          'C${toSvgPoint(c1)} ${toSvgPoint(c2)} ${toSvgPoint(end)}',
        );
    }

    // End arrowhead
    if (arrowheadStyle == .single || arrowheadStyle == .double) {
      final unitDir = _endTangent();
      final perp = Offset(-unitDir.dy, unitDir.dx);
      final tip = end;
      final left = tip - unitDir * headLength + perp * headLength * headAngle;
      final right = tip - unitDir * headLength - perp * headLength * headAngle;
      buffer.write(' M${toSvgPoint(left)} L${toSvgPoint(tip)}');
      buffer.write(' L${toSvgPoint(right)}');
    }

    // Start arrowhead
    if (arrowheadStyle == .double) {
      final unitDir = _startTangent();
      final perp = Offset(-unitDir.dy, unitDir.dx);
      final tip = start;
      final left = tip + unitDir * headLength + perp * headLength * headAngle;
      final right = tip + unitDir * headLength - perp * headLength * headAngle;
      buffer.write(' M${toSvgPoint(left)} L${toSvgPoint(tip)}');
      buffer.write(' L${toSvgPoint(right)}');
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
  void rotateAround(double angleRadians, Offset center) {
    if (angleRadians == 0) return;

    final cosA = cos(angleRadians);
    final sinA = sin(angleRadians);

    final startDx = start.dx - center.dx;
    final startDy = start.dy - center.dy;
    start = Offset(
      center.dx + startDx * cosA - startDy * sinA,
      center.dy + startDx * sinA + startDy * cosA,
    );

    final endDx = end.dx - center.dx;
    final endDy = end.dy - center.dy;
    end = Offset(
      center.dx + endDx * cosA - endDy * sinA,
      center.dy + endDx * sinA + endDy * cosA,
    );

    super.rotateAround(angleRadians, center);
  }

  @override
  void scaleAround(double scaleX, double scaleY, Offset pivot) {
    if (scaleX == 0 || scaleY == 0) return;
    start = Offset(
      pivot.dx + (start.dx - pivot.dx) * scaleX,
      pivot.dy + (start.dy - pivot.dy) * scaleY,
    );
    end = Offset(
      pivot.dx + (end.dx - pivot.dx) * scaleX,
      pivot.dy + (end.dy - pivot.dy) * scaleY,
    );
    super.scaleAround(scaleX, scaleY, pivot);
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
    connectorStyle: connectorStyle,
    headLength: headLength,
    headAngle: headAngle,
    fillColor: fillColor,
    lineStyle: lineStyle,
  );
}
