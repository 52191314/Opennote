/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_circle_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_polygon_stroke.dart';
import 'package:saber/components/canvas/_rectangle_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';

/// Computes the axis-aligned bounding box of [stroke] in page coordinates.
///
/// For freehand strokes, returns null so [Stroke] can manage its own cached
/// point-based bounding box via [computePointsBoundingBox].
Rect? computeShapeBoundingBox(Stroke stroke) {
  if (stroke case final CircleStroke circle) {
    return Rect.fromCircle(center: circle.center, radius: circle.radius);
  }
  if (stroke case final RectangleStroke rectangle) {
    return rectangle.rect;
  }
  if (stroke case final TapeStroke tape) {
    return tape.rect;
  }
  if (stroke case final ArrowStroke arrow) {
    return Rect.fromPoints(arrow.start, arrow.end).inflate(arrow.headLength);
  }
  if (stroke case final DimensionStroke dim) {
    return computeDimensionBoundingBox(dim);
  }
  if (stroke case final PolygonStroke polygon) {
    return computePolygonBoundingBox(polygon.vertices);
  }
  return null;
}

/// Computes the bounding box of a [DimensionStroke] including extension lines
/// and label margin.
Rect computeDimensionBoundingBox(DimensionStroke dim) {
  final (_, perp) = dim.computeVectors();
  final dimOffset = perp * dim.offset;
  final dimStart = dim.start + dimOffset;
  final dimEnd = dim.end + dimOffset;
  final minX = min(min(dim.start.dx, dim.end.dx), min(dimStart.dx, dimEnd.dx));
  final minY = min(min(dim.start.dy, dim.end.dy), min(dimStart.dy, dimEnd.dy));
  final maxX = max(max(dim.start.dx, dim.end.dx), max(dimStart.dx, dimEnd.dx));
  final maxY = max(max(dim.start.dy, dim.end.dy), max(dimStart.dy, dimEnd.dy));
  return Rect.fromLTRB(minX, minY, maxX, maxY).inflate(dim.headLength + 60);
}

/// Computes the tight axis-aligned bounding box of [vertices].
Rect computePolygonBoundingBox(List<Offset> vertices) {
  if (vertices.isEmpty) return Rect.zero;
  var minX = vertices.first.dx;
  var maxX = minX;
  var minY = vertices.first.dy;
  var maxY = minY;
  for (int i = 1; i < vertices.length; i++) {
    final v = vertices[i];
    if (v.dx < minX) minX = v.dx;
    if (v.dx > maxX) maxX = v.dx;
    if (v.dy < minY) minY = v.dy;
    if (v.dy > maxY) maxY = v.dy;
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

/// Computes the bounding box of freehand [points] expanded by half of [strokeSize].
Rect computePointsBoundingBox(List<PointVector> points, double strokeSize) {
  if (points.isEmpty) return Rect.zero;
  var minX = points.first.x;
  var maxX = minX;
  var minY = points.first.y;
  var maxY = minY;
  for (int i = 1; i < points.length; i++) {
    final p = points[i];
    if (p.x < minX) minX = p.x;
    if (p.x > maxX) maxX = p.x;
    if (p.y < minY) minY = p.y;
    if (p.y > maxY) maxY = p.y;
  }
  final halfSize = strokeSize * 0.5;
  return Rect.fromLTRB(
    minX - halfSize,
    minY - halfSize,
    maxX + halfSize,
    maxY + halfSize,
  );
}

/// Computes a fast state fingerprint covering in-place mutations to [stroke].
int computeStrokeRenderSignature(Stroke stroke, int geometryRevision) {
  var h = identityHashCode(stroke) ^ (geometryRevision * 0x9E3779B9);
  h ^= stroke.color.toARGB32();
  h ^= (stroke.lineStyle.index << 16) ^ stroke.options.size.hashCode;
  if (stroke.fillColor != null) h ^= stroke.fillColor!.toARGB32() << 1;
  if (stroke case final TapeStroke tape) {
    h ^=
        (tape.isConcealed ? 0x5555 : 0xAAAA) ^
        (tape.pattern.index << 8) ^
        tape.rect.hashCode;
  } else if (stroke case final DimensionStroke dim) {
    h ^=
        dim.start.hashCode ^
        dim.end.hashCode ^
        dim.offset.hashCode ^
        dim.text.hashCode;
  } else if (stroke case final ArrowStroke arrow) {
    h ^=
        arrow.start.hashCode ^
        arrow.end.hashCode ^
        (arrow.arrowheadStyle.index << 4) ^
        (arrow.connectorStyle.index << 8);
  } else if (stroke case final CircleStroke circle) {
    h ^= circle.center.hashCode ^ circle.radius.hashCode;
  } else if (stroke case final RectangleStroke rectStroke) {
    h ^= rectStroke.rect.hashCode;
  }
  return h & 0x1fffffff;
}

/// Rotates [points] in-place by [angleRadians] around [center].
void rotatePointVectors(
  List<PointVector> points,
  double angleRadians,
  Offset center,
) {
  final cosA = cos(angleRadians);
  final sinA = sin(angleRadians);
  for (int i = 0; i < points.length; i++) {
    final p = points[i];
    final dx = p.x - center.dx;
    final dy = p.y - center.dy;
    points[i] = PointVector(
      center.dx + dx * cosA - dy * sinA,
      center.dy + dx * sinA + dy * cosA,
      p.pressure,
    );
  }
}

/// Rotates [offsets] in-place by [angleRadians] around [center].
void rotateOffsets(List<Offset> offsets, double angleRadians, Offset center) {
  final cosA = cos(angleRadians);
  final sinA = sin(angleRadians);
  for (int i = 0; i < offsets.length; i++) {
    final point = offsets[i];
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    offsets[i] = Offset(
      center.dx + dx * cosA - dy * sinA,
      center.dy + dx * sinA + dy * cosA,
    );
  }
}

/// Scales [points] in-place by [scaleX]/[scaleY] around [pivot].
void scalePointVectors(
  List<PointVector> points,
  double scaleX,
  double scaleY,
  Offset pivot,
) {
  for (int i = 0; i < points.length; i++) {
    final p = points[i];
    points[i] = PointVector(
      pivot.dx + (p.x - pivot.dx) * scaleX,
      pivot.dy + (p.y - pivot.dy) * scaleY,
      p.pressure,
    );
  }
}

/// Scales [offsets] in-place by [scaleX]/[scaleY] around [pivot].
void scaleOffsets(
  List<Offset> offsets,
  double scaleX,
  double scaleY,
  Offset pivot,
) {
  for (int i = 0; i < offsets.length; i++) {
    final point = offsets[i];
    offsets[i] = Offset(
      pivot.dx + (point.dx - pivot.dx) * scaleX,
      pivot.dy + (point.dy - pivot.dy) * scaleY,
    );
  }
}

/// Returns the shortest Euclidean distance from [point] to segment
/// `[segStart, segEnd]`.
double pointToSegmentDistance(Offset point, Offset segStart, Offset segEnd) {
  final dx = segEnd.dx - segStart.dx;
  final dy = segEnd.dy - segStart.dy;
  final lengthSquared = dx * dx + dy * dy;
  if (lengthSquared == 0) return (point - segStart).distance;
  final t =
      (((point.dx - segStart.dx) * dx + (point.dy - segStart.dy) * dy) /
              lengthSquared)
          .clamp(0.0, 1.0);
  final projX = segStart.dx + t * dx;
  final projY = segStart.dy + t * dy;
  final rx = point.dx - projX;
  final ry = point.dy - projY;
  return sqrt(rx * rx + ry * ry);
}

/// Returns whether [point] lies within [tolerance] (plus half stroke width) of
/// any segment of [stroke].
bool isPointNearStroke(Stroke stroke, Offset point, {double tolerance = 8.0}) {
  final hitRadius = tolerance + stroke.options.size * 0.5;
  if (!stroke.boundingBox.inflate(tolerance).contains(point)) return false;

  final pts = stroke.rawPoints;
  if (pts.isEmpty) return true;
  if (pts.length == 1) {
    return (point - Offset(pts.first.x, pts.first.y)).distance <= hitRadius;
  }
  for (int i = 0; i < pts.length - 1; i++) {
    final a = Offset(pts[i].x, pts[i].y);
    final b = Offset(pts[i + 1].x, pts[i + 1].y);
    if (pointToSegmentDistance(point, a, b) <= hitRadius) return true;
  }
  return false;
}
