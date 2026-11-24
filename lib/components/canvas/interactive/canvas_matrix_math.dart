/// 🤖 Generated wholely or partially with Claude Code; Gemini; Google Antigravity
/// Adapted for Saber from Flutter's [InteractiveViewer] class.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/painting.dart' show Axis, Offset, Rect;
import 'package:vector_math/vector_math_64.dart' show Matrix4, Quad, Vector3;

/// Returns the closest point to [point] on the line segment from [l1] to [l2].
Vector3 canvasGetNearestPointOnLine(Vector3 point, Vector3 l1, Vector3 l2) {
  final double lengthSquared =
      math.pow(l2.x - l1.x, 2.0).toDouble() +
      math.pow(l2.y - l1.y, 2.0).toDouble();

  // In this case, l1 == l2.
  if (lengthSquared == 0) {
    return l1;
  }

  final Vector3 l1P = point - l1;
  final Vector3 l1L2 = l2 - l1;
  final double fraction = clampDouble(l1P.dot(l1L2) / lengthSquared, 0, 1);
  return l1 + l1L2 * fraction;
}

/// Given a [quad], returns its axis-aligned bounding box as a [Quad].
Quad canvasGetAxisAlignedBoundingBox(Quad quad) {
  final double minX = math.min(
    quad.point0.x,
    math.min(quad.point1.x, math.min(quad.point2.x, quad.point3.x)),
  );
  final double minY = math.min(
    quad.point0.y,
    math.min(quad.point1.y, math.min(quad.point2.y, quad.point3.y)),
  );
  final double maxX = math.max(
    quad.point0.x,
    math.max(quad.point1.x, math.max(quad.point2.x, quad.point3.x)),
  );
  final double maxY = math.max(
    quad.point0.y,
    math.max(quad.point1.y, math.max(quad.point2.y, quad.point3.y)),
  );
  return Quad.points(
    Vector3(minX, minY, 0),
    Vector3(maxX, minY, 0),
    Vector3(maxX, maxY, 0),
    Vector3(minX, maxY, 0),
  );
}

/// Returns true iff [point] is inside the rectangle given by [quad], inclusively.
/// Algorithm from https://math.stackexchange.com/a/190373.
bool canvasPointIsInside(Vector3 point, Quad quad) {
  final Vector3 aM = point - quad.point0;
  final Vector3 aB = quad.point1 - quad.point0;
  final Vector3 aD = quad.point3 - quad.point0;

  final double aMAB = aM.dot(aB);
  final double aBAB = aB.dot(aB);
  final double aMAD = aM.dot(aD);
  final double aDAD = aD.dot(aD);

  return 0 <= aMAB && aMAB <= aBAB && 0 <= aMAD && aMAD <= aDAD;
}

/// Returns the point inside (inclusively) [quad] that is nearest to [point].
Vector3 canvasGetNearestPointInside(Vector3 point, Quad quad) {
  if (canvasPointIsInside(point, quad)) {
    return point;
  }

  final List<Vector3> closestPoints = <Vector3>[
    canvasGetNearestPointOnLine(point, quad.point0, quad.point1),
    canvasGetNearestPointOnLine(point, quad.point1, quad.point2),
    canvasGetNearestPointOnLine(point, quad.point2, quad.point3),
    canvasGetNearestPointOnLine(point, quad.point3, quad.point0),
  ];
  double minDistance = double.infinity;
  late Vector3 closestOverall;
  for (final Vector3 closePoint in closestPoints) {
    final double distance = math.sqrt(
      math.pow(point.x - closePoint.x, 2) + math.pow(point.y - closePoint.y, 2),
    );
    if (distance < minDistance) {
      minDistance = distance;
      closestOverall = closePoint;
    }
  }
  return closestOverall;
}

/// Given a [velocity] and [drag], calculates the time at which motion will come
/// to a stop, within the margin of [effectivelyMotionless].
double canvasGetFinalTime(
  double velocity,
  double drag, {
  double effectivelyMotionless = 10,
}) {
  return math.log(effectivelyMotionless / velocity) / math.log(drag / 100);
}

/// Returns the translation from [matrix] as an [Offset].
Offset canvasGetMatrixTranslation(Matrix4 matrix) {
  final Vector3 nextTranslation = matrix.getTranslation();
  return Offset(nextTranslation.x, nextTranslation.y);
}

/// Transforms the four corners of [viewport] by the inverse of [matrix].
Quad canvasTransformViewport(Matrix4 matrix, Rect viewport) {
  final Matrix4 inverseMatrix = matrix.clone()..invert();
  return Quad.points(
    inverseMatrix.transform3(
      Vector3(viewport.topLeft.dx, viewport.topLeft.dy, 0),
    ),
    inverseMatrix.transform3(
      Vector3(viewport.topRight.dx, viewport.topRight.dy, 0),
    ),
    inverseMatrix.transform3(
      Vector3(viewport.bottomRight.dx, viewport.bottomRight.dy, 0),
    ),
    inverseMatrix.transform3(
      Vector3(viewport.bottomLeft.dx, viewport.bottomLeft.dy, 0),
    ),
  );
}

/// Finds the axis-aligned bounding box for [rect] rotated about its center by [rotation].
Quad canvasGetAxisAlignedBoundingBoxWithRotation(Rect rect, double rotation) {
  final Matrix4 rotationMatrix = Matrix4.identity()
    ..translateByDouble(rect.size.width / 2, rect.size.height / 2, 0, 1)
    ..rotateZ(rotation)
    ..translateByDouble(-rect.size.width / 2, -rect.size.height / 2, 0, 1);
  final Quad boundariesRotated = Quad.points(
    rotationMatrix.transform3(Vector3(rect.left, rect.top, 0)),
    rotationMatrix.transform3(Vector3(rect.right, rect.top, 0)),
    rotationMatrix.transform3(Vector3(rect.right, rect.bottom, 0)),
    rotationMatrix.transform3(Vector3(rect.left, rect.bottom, 0)),
  );
  return canvasGetAxisAlignedBoundingBox(boundariesRotated);
}

/// Returns the amount that [viewport] lies outside of [boundary].
/// If [viewport] is completely contained within [boundary] (inclusively), returns [Offset.zero].
Offset canvasExceedsBy(Quad boundary, Quad viewport) {
  final List<Vector3> viewportPoints = <Vector3>[
    viewport.point0,
    viewport.point1,
    viewport.point2,
    viewport.point3,
  ];
  Offset largestExcess = .zero;
  for (final Vector3 point in viewportPoints) {
    final Vector3 pointInside = canvasGetNearestPointInside(point, boundary);
    final Offset excess = Offset(
      pointInside.x - point.x,
      pointInside.y - point.y,
    );
    if (excess.dx.abs() > largestExcess.dx.abs()) {
      largestExcess = Offset(excess.dx, largestExcess.dy);
    }
    if (excess.dy.abs() > largestExcess.dy.abs()) {
      largestExcess = Offset(largestExcess.dx, excess.dy);
    }
  }

  return canvasRoundOffset(largestExcess);
}

/// Rounds [offset] to 9 decimal places to avoid floating-point precision noise near zero.
Offset canvasRoundOffset(Offset offset) {
  return Offset(
    double.parse(offset.dx.toStringAsFixed(9)),
    double.parse(offset.dy.toStringAsFixed(9)),
  );
}

/// Aligns [offset] to [axis] by allowing movement only in the axis direction.
Offset canvasAlignAxis(Offset offset, Axis axis) {
  return switch (axis) {
    Axis.horizontal => Offset(offset.dx, 0),
    Axis.vertical => Offset(0, offset.dy),
  };
}

/// Given two points, returns the axis where the distance between them is greatest.
/// Returns null if the two points are equal.
Axis? canvasGetPanAxis(Offset point1, Offset point2) {
  if (point1 == point2) {
    return null;
  }
  final double x = point2.dx - point1.dx;
  final double y = point2.dy - point1.dy;
  return x.abs() > y.abs() ? Axis.horizontal : Axis.vertical;
}
