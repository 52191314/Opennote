/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math';

import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

/// Default threshold multiplier of stroke size below which adjacent points
/// are considered duplicates.
const defaultOptimisePointsThreshold = 0.1;

/// Removes points that are closer than `strokeSize * thresholdMultiplier`
/// to both neighbors, as well as points with null pressure.
void optimiseStrokePoints(
  List<PointVector> points,
  double strokeSize, {
  double thresholdMultiplier = defaultOptimisePointsThreshold,
}) {
  if (points.length <= 3) return;

  final minDistance = strokeSize * thresholdMultiplier;
  final minDistSq = minDistance * minDistance;

  points.removeWhere((point) => point.pressure == null);

  for (int i = 1; i < points.length - 1; i++) {
    final point = points[i];
    final prev = points[i - 1];
    final next = points[i + 1];

    if (prev.distanceSquaredTo(point) < minDistSq &&
        point.distanceSquaredTo(next) < minDistSq) {
      points.removeAt(i);
      i--;
    }
  }
}

/// Returns a subset of [points] that stays within [tolerance] of every
/// dropped point using the Ramer–Douglas–Peucker algorithm.
///
/// If [pressureScale] is non-zero, pressure deviations scaled by
/// [pressureScale] are preserved alongside spatial deviations.
List<PointVector> simplifyStrokePoints(
  List<PointVector> points,
  double tolerance, {
  double pressureScale = 0,
}) {
  if (points.length <= 2) return points;

  final keep = List.filled(points.length, false);
  keep[0] = true;
  keep[points.length - 1] = true;

  final ranges = <(int start, int end)>[(0, points.length - 1)];
  while (ranges.isNotEmpty) {
    final (start, end) = ranges.removeLast();
    var farthest = -1;
    var farthestDistance = tolerance;
    for (int i = start + 1; i < end; i++) {
      final distance = _pointDeviation(
        points[i],
        points[start],
        points[end],
        pressureScale,
      );
      if (distance <= farthestDistance) continue;
      farthest = i;
      farthestDistance = distance;
    }
    if (farthest == -1) continue;

    keep[farthest] = true;
    ranges.add((start, farthest));
    ranges.add((farthest, end));
  }

  return [
    for (int i = 0; i < points.length; i++)
      if (keep[i]) points[i],
  ];
}

double _pointDeviation(
  PointVector point,
  PointVector start,
  PointVector end,
  double pressureScale,
) {
  final dx = end.x - start.x;
  final dy = end.y - start.y;
  final lengthSquared = dx * dx + dy * dy;
  final t = lengthSquared == 0
      ? 0.0
      : (((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSquared)
            .clamp(0.0, 1.0);
  final distance = sqrt(
    pow(point.x - (start.x + t * dx), 2) + pow(point.y - (start.y + t * dy), 2),
  );

  final pressure = point.pressure;
  final startPressure = start.pressure;
  final endPressure = end.pressure;
  if (pressureScale == 0 ||
      pressure == null ||
      startPressure == null ||
      endPressure == null) {
    return distance;
  }
  final expected = startPressure + t * (endPressure - startPressure);
  return max(distance, (pressure - expected).abs() * pressureScale);
}

/// Applies Laplacian smoothing to [points] in-place to beautify handwriting.
void smoothenStrokePoints(List<PointVector> points, {int iterations = 2}) {
  if (points.length < 4) return;
  for (int iter = 0; iter < iterations; iter++) {
    final smoothed = <PointVector>[points.first];
    for (int i = 1; i < points.length - 1; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final next = points[i + 1];
      final nx = 0.25 * prev.x + 0.5 * curr.x + 0.25 * next.x;
      final ny = 0.25 * prev.y + 0.5 * curr.y + 0.25 * next.y;
      final np = curr.pressure != null
          ? 0.25 * (prev.pressure ?? curr.pressure!) +
                0.5 * curr.pressure! +
                0.25 * (next.pressure ?? curr.pressure!)
          : null;
      smoothed.add(PointVector(nx, ny, np));
    }
    smoothed.add(points.last);
    points
      ..clear()
      ..addAll(smoothed);
  }
}

/// Recognizes a unistroke shape from [points], or returns null if too short.
RecognizedUnistroke? detectStrokeShape(List<PointVector> points) {
  if (points.length < 3) return null;
  return recognizeUnistroke(points);
}

/// Returns whether [points] represent a straight line sufficiently long
/// relative to [strokeSize].
bool isStrokeStraightLine(
  List<PointVector> points,
  double strokeSize, [
  int minLength = 5,
]) {
  if (points.length < 3) return false;

  final recognized = recognizeUnistroke(
    points,
    overrideReferenceUnistrokes: default$1Unistrokes
        .where((unistroke) => unistroke.name == DefaultUnistrokeNames.line)
        .toList(),
  );
  if (recognized == null) return false;
  assert(recognized.name == DefaultUnistrokeNames.line);
  if (recognized.score < 0.7) return false;

  final sqrLength = points.first.distanceSquaredTo(points.last);
  final sqrMinLength = minLength * minLength * strokeSize * strokeSize;
  return sqrLength >= sqrMinLength;
}
