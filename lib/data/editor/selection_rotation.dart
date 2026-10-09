/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:math';
import 'dart:ui';

/// Returns [point] rotated by [angleRadians] around [center].
Offset rotateOffsetAround(Offset point, double angleRadians, Offset center) {
  final cosA = cos(angleRadians);
  final sinA = sin(angleRadians);
  final dx = point.dx - center.dx;
  final dy = point.dy - center.dy;
  return Offset(
    center.dx + dx * cosA - dy * sinA,
    center.dy + dx * sinA + dy * cosA,
  );
}

/// Returns [path] rotated by [angleRadians] around [center].
///
/// The result is traced from points sampled along [path],
/// so curves come back as short straight segments.
Path rotatePathAround(Path path, double angleRadians, Offset center) {
  if (angleRadians == 0) return path;
  final metrics = path.computeMetrics().toList();
  if (metrics.isEmpty) return path;

  final cosA = cos(angleRadians);
  final sinA = sin(angleRadians);

  final rotatedPath = Path();
  for (final metric in metrics) {
    for (double dist = 0; dist < metric.length; dist += 5) {
      final tangent = metric.getTangentForOffset(dist);
      if (tangent == null) continue;
      final dx = tangent.position.dx - center.dx;
      final dy = tangent.position.dy - center.dy;
      final rotated = Offset(
        center.dx + dx * cosA - dy * sinA,
        center.dy + dx * sinA + dy * cosA,
      );
      if (dist == 0) {
        rotatedPath.moveTo(rotated.dx, rotated.dy);
      } else {
        rotatedPath.lineTo(rotated.dx, rotated.dy);
      }
    }
  }
  return rotatedPath;
}
