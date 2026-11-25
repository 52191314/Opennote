/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

/// The 6 isometric grid directions (±30°, ±90°, ±150°) in radians.
const List<double> isometricAnglesRad = [
  pi / 6,
  pi / 2,
  5 * pi / 6,
  -pi / 6,
  -pi / 2,
  -5 * pi / 6,
];

/// Snaps [point] to the nearest Cartesian grid intersection with spacing [gridSize].
Offset snapPointToGrid(Offset point, double gridSize) {
  if (gridSize <= 0) return point;
  final gridX = (point.dx / gridSize).round() * gridSize;
  final gridY = (point.dy / gridSize).round() * gridSize;
  return Offset(gridX, gridY);
}

/// Snaps [point] to the nearest vertex on an isometric triangular grid
/// with vertical spacing [lineHeight].
///
/// Uses an O(1) 4-candidate nearest vertex algorithm across the bounding columns.
Offset snapPointToIsometricGrid(Offset point, double lineHeight) {
  if (lineHeight <= 0) return point;
  final l = lineHeight;
  final dx = l * (sqrt(3) / 2);

  final col0 = (point.dx / dx).floor();
  final col1 = col0 + 1;

  Offset? bestVertex;
  var minDistanceSq = double.infinity;

  for (final col in [col0, col1]) {
    final x = col * dx;
    final yShift = (col % 2 != 0) ? 0.5 * l : 0.0;
    final rowCenter = (point.dy - yShift) / l;
    final rowA = rowCenter.floor();
    final rowB = rowCenter.ceil();

    for (final row in [rowA, rowB]) {
      final y = row * l + yShift;
      final dX = point.dx - x;
      final dY = point.dy - y;
      final distSq = dX * dX + dY * dY;
      if (distSq < minDistanceSq) {
        minDistanceSq = distSq;
        bestVertex = Offset(x, y);
      }
    }
  }

  return bestVertex ?? point;
}

/// Snaps a line to horizontal or vertical if within 5°, or to [angleStepDegrees]
/// / isometric axes when requested.
(PointVector firstPoint, PointVector lastPoint) snapStrokeLine(
  PointVector firstPoint,
  PointVector lastPoint, {
  double? angleStepDegrees,
  bool isIsometric = false,
}) {
  if (isIsometric ||
      (angleStepDegrees != null &&
          (angleStepDegrees > 0 || angleStepDegrees == -30))) {
    return snapStrokeLineToAngle(
      firstPoint,
      lastPoint,
      angleStepDegrees ?? 30.0,
      isIsometric: isIsometric,
    );
  }

  final absDx = (lastPoint.dx - firstPoint.dx).abs();
  final absDy = (lastPoint.dy - firstPoint.dy).abs();
  final angle = atan2(absDy, absDx);

  const snapAngle = 5 * pi / 180;
  if (angle < snapAngle) {
    return (
      firstPoint,
      PointVector(lastPoint.dx, firstPoint.dy, lastPoint.pressure),
    );
  }
  if (angle > pi / 2 - snapAngle) {
    return (
      firstPoint,
      PointVector(firstPoint.dx, lastPoint.dy, lastPoint.pressure),
    );
  }
  return (firstPoint, lastPoint);
}

/// Snaps a line to the nearest multiple of [stepDegrees] or to the 3-axis
/// isometric directions when [isIsometric] is true or [stepDegrees] is -30.
///
/// The line's length is preserved; only its direction is adjusted.
(PointVector firstPoint, PointVector lastPoint) snapStrokeLineToAngle(
  PointVector firstPoint,
  PointVector lastPoint,
  double stepDegrees, {
  bool isIsometric = false,
}) {
  final dx = lastPoint.dx - firstPoint.dx;
  final dy = lastPoint.dy - firstPoint.dy;
  final length = sqrt(dx * dx + dy * dy);
  if (length < 0.001) return (firstPoint, lastPoint);

  var angleRad = atan2(dy, dx);

  if (isIsometric || stepDegrees == -30) {
    angleRad = _nearestIsometricAngle(angleRad);
  } else {
    if (stepDegrees <= 0) return (firstPoint, lastPoint);
    final stepRad = stepDegrees * pi / 180;
    angleRad = (angleRad / stepRad).round() * stepRad;
  }

  return (
    firstPoint,
    PointVector(
      firstPoint.dx + length * cos(angleRad),
      firstPoint.dy + length * sin(angleRad),
      lastPoint.pressure,
    ),
  );
}

double _nearestIsometricAngle(double angleRad) {
  var minDiff = double.infinity;
  var bestAngle = isometricAnglesRad.first;
  for (final target in isometricAnglesRad) {
    var diff = (angleRad - target) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    if (diff < -pi) diff += 2 * pi;
    final absDiff = diff.abs();
    if (absDiff < minDiff) {
      minDiff = absDiff;
      bestAngle = target;
    }
  }
  return bestAngle;
}
