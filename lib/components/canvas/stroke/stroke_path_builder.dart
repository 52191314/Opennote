/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/stroke/stroke_simplifier.dart';

/// Builds a polyline [Path] connecting the raw center points of a stroke.
Path buildCenterlinePath(List<PointVector> points) {
  final path = Path();
  if (points.isEmpty) return path;
  path.moveTo(points.first.x, points.first.y);
  for (int i = 1; i < points.length; i++) {
    path.lineTo(points[i].x, points[i].y);
  }
  return path;
}

/// Builds a dashed or dotted [Path] from [centerlinePath] for [lineStyle].
Path buildStyledPath(
  Path centerlinePath,
  LineStyle lineStyle,
  double strokeWidth,
) {
  final dashArray = lineStyle == LineStyle.dotted
      ? CircularIntervalList<double>([1.0, strokeWidth * 1.8])
      : CircularIntervalList<double>([strokeWidth * 3.0, strokeWidth * 1.8]);
  return dashPath(centerlinePath, dashArray: dashArray);
}

/// Builds a closed smooth quadratic-bezier [Path] from [polygon] vertices.
Path smoothPathFromPolygon(List<Offset> polygon) {
  final path = Path();
  path.moveTo(polygon.first.dx, polygon.first.dy);
  for (int i = 1; i < polygon.length - 1; i++) {
    final p1 = polygon[i];
    final p2 = polygon[i + 1];
    final mid = (p1 + p2) / 2;
    path.quadraticBezierTo(p1.dx, p1.dy, mid.dx, mid.dy);
  }
  return path..close();
}

/// Builds a [Path] representing [polygon], optionally smoothed with quadratic
/// bezier curves when [smooth] is true and at least 3 vertices exist.
Path buildPathFromPolygon(List<Offset> polygon, {bool smooth = true}) {
  if (smooth && polygon.length >= 3) {
    return smoothPathFromPolygon(polygon);
  }
  return Path()..addPolygon(polygon, true);
}

/// Generates an outline polygon for [points] at the requested [quality].
List<Offset> buildStrokePolygon({
  required List<PointVector> points,
  required StrokeOptions options,
  required StrokeQuality quality,
  required bool pressureEnabled,
  required double lowQualityTolerance,
  required VoidCallback onSimulatedPressureApplied,
}) {
  if (!pressureEnabled) {
    options.simulatePressure = false;
  }
  final rememberSimulatedPressure =
      quality == StrokeQuality.high &&
      options.simulatePressure &&
      options.isComplete;

  final polygon = getStroke(
    switch (quality) {
      StrokeQuality.low => simplifyStrokePoints(
        points,
        lowQualityTolerance,
        pressureScale: pressureEnabled ? options.size / 2 : 0,
      ),
      StrokeQuality.high => points,
    },
    options: switch (quality) {
      StrokeQuality.low => options.copyWith(
        simulatePressure: false,
        smoothing: options.smoothing * 0.5,
        streamline: options.streamline * 0.5,
      ),
      StrokeQuality.high => options,
    },
    rememberSimulatedPressure: rememberSimulatedPressure,
  );

  if (rememberSimulatedPressure) {
    options.simulatePressure = false;
    onSimulatedPressureApplied();
  }

  return polygon;
}

/// Converts [polygon] into an SVG path string with Y-axis flipped relative to
/// [pageHeight].
String strokePolygonToSvgPath(List<Offset> polygon, double pageHeight) {
  final svgPoints = polygon
      .where((offset) => offset.isFinite)
      .map((point) => '${point.dx} ${pageHeight - point.dy}');
  return svgPoints.isNotEmpty ? 'M${svgPoints.join('L')}' : '';
}
