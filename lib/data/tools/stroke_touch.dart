/// 🤖 Generated wholely or partially with Claude Code (Claude Sonnet 5.5)
library;

import 'dart:math';
import 'dart:ui';

import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:sbn/tool_id.dart';

/// The most two sampled points of [strokeCenterline] are apart.
const strokeSampleGap = 4.0;

/// How far apart two strokes' edges can be and still count as touching,
/// to forgive that strokes are sampled at points.
const touchSlack = 2.0;

/// The path the pen took to draw [stroke], with a point at least every
/// [strokeSampleGap] along it.
///
/// Shapes are not drawn by the pen, so their outline is used instead.
List<Offset> strokeCenterline(Stroke stroke) =>
    _densify(_corners(stroke), strokeSampleGap);

/// Returns the strokes in [among] that are connected to one of [from],
/// directly or through other strokes, by their ink touching.
///
/// Tape never connects strokes, and a highlighter only connects to other
/// highlighter strokes, since both usually lie across lots of unrelated
/// writing.
List<Stroke> connectedStrokes({
  required Iterable<Stroke> from,
  required Iterable<Stroke> among,
}) {
  final start = from.toSet();
  final unvisited = [
    for (final stroke in among)
      if (!start.contains(stroke) && _canConnect(stroke)) _Body(stroke),
  ];
  final queue = [
    for (final stroke in start)
      if (_canConnect(stroke)) _Body(stroke),
  ];

  final found = <Stroke>[];
  while (queue.isNotEmpty && unvisited.isNotEmpty) {
    final current = queue.removeLast();
    unvisited.removeWhere((candidate) {
      if (!current.touches(candidate)) return false;
      found.add(candidate.stroke);
      queue.add(candidate);
      return true;
    });
  }
  return found;
}

bool _canConnect(Stroke stroke) => stroke is! TapeStroke;

List<Offset> _corners(Stroke stroke) {
  if (stroke.runtimeType != Stroke) return stroke.lowQualityPolygon;
  return [for (final point in stroke.rawPoints) Offset(point.x, point.y)];
}

List<Offset> _densify(List<Offset> points, double maxGap) {
  if (points.length < 2) return points;

  final dense = [points.first];
  for (int i = 1; i < points.length; i++) {
    final from = points[i - 1];
    final to = points[i];
    final pieces = ((to - from).distance / maxGap).ceil();
    for (int piece = 1; piece < pieces; piece++) {
      dense.add(Offset.lerp(from, to, piece / pieces)!);
    }
    dense.add(to);
  }
  return dense;
}

double _distanceToPolyline(Offset point, List<Offset> polyline) {
  if (polyline.length == 1) return (point - polyline.first).distance;

  var nearest = double.infinity;
  for (int i = 1; i < polyline.length; i++) {
    nearest = min(
      nearest,
      _distanceToSegment(point, polyline[i - 1], polyline[i]),
    );
  }
  return nearest;
}

double _distanceToSegment(Offset point, Offset a, Offset b) {
  final along = b - a;
  final lengthSquared = along.distanceSquared;
  if (lengthSquared == 0) return (point - a).distance;

  final t =
      (((point - a).dx * along.dx + (point - a).dy * along.dy) / lengthSquared)
          .clamp(0.0, 1.0);
  return (point - (a + along * t)).distance;
}

/// Where a stroke's ink is, in a form that is quick to compare.
class _Body {
  _Body(this.stroke)
    : corners = _corners(stroke),
      radius = stroke.options.size / 2,
      isHighlighter = stroke.toolId == ToolId.highlighter {
    samples = _densify(corners, strokeSampleGap);
    bounds = _boundsOf(samples).inflate(radius + touchSlack);
  }

  final Stroke stroke;
  final List<Offset> corners;
  final double radius;
  final bool isHighlighter;
  late final List<Offset> samples;
  late final Rect bounds;

  bool touches(_Body other) {
    if (isHighlighter != other.isHighlighter) return false;
    if (!bounds.overlaps(other.bounds)) return false;
    if (corners.isEmpty || other.corners.isEmpty) return false;

    final reach = radius + other.radius + touchSlack;
    return samples.any(
      (sample) => _distanceToPolyline(sample, other.corners) <= reach,
    );
  }

  static Rect _boundsOf(List<Offset> points) {
    if (points.isEmpty) return Rect.zero;
    var bounds = Rect.fromPoints(points.first, points.first);
    for (final point in points) {
      bounds = bounds.expandToInclude(Rect.fromPoints(point, point));
    }
    return bounds;
  }
}
