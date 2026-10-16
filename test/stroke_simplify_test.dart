/// 🤖 Generated wholely or partially with Claude Code (Claude Sonnet 5.5)
library;

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:sbn/tool_id.dart';

PointVector p(double x, double y) => PointVector(x, y, 0.5);

Stroke strokeThrough(List<Offset> offsets, {double size = 20}) {
  final stroke = Stroke(
    color: const Color(0xFF000000),
    pressureEnabled: false,
    options: StrokeOptions(size: size, isComplete: true),
    pageIndex: 0,
    page: EditorPage(),
    toolId: ToolId.ballpointPen,
  );
  for (final offset in offsets) {
    stroke.addPoint(offset, 0.5);
  }
  return stroke;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('Stroke.simplifyPoints', () {
    test('keeps the first and last point', () {
      final points = [for (var i = 0; i <= 20; i++) p(i * 10.0, 0)];

      final simplified = Stroke.simplifyPoints(points, 1);

      expect(simplified.first, same(points.first));
      expect(simplified.last, same(points.last));
    });

    test('reduces a straight line to its end points', () {
      final points = [for (var i = 0; i <= 50; i++) p(i * 3.0, i * 1.5)];

      expect(Stroke.simplifyPoints(points, 1), hasLength(2));
    });

    test('keeps a sharp corner that is not on a regular index', () {
      // 'V' with the tip at index 7, which skipping every 4th point drops
      final points = [
        for (var i = 0; i <= 7; i++) p(i * 10.0, i * 10.0),
        for (var i = 1; i <= 9; i++) p(70 + i * 10.0, 70 - i * 10.0),
      ];

      final simplified = Stroke.simplifyPoints(points, 2);

      expect(simplified, contains(points[7]));
    });

    test('never strays further than the tolerance from the original', () {
      final points = [
        for (var i = 0; i <= 80; i++) p(i * 5.0, 40 * (i % 16 < 8 ? 1 : -1)),
      ];
      const tolerance = 3.0;

      final simplified = Stroke.simplifyPoints(points, tolerance);

      expect(simplified.length, lessThan(points.length));
      for (final point in points) {
        expect(
          _distanceToPolyline(Offset(point.x, point.y), simplified),
          lessThanOrEqualTo(tolerance + 1e-9),
        );
      }
    });

    test('keeps points where the pressure, and so the width, changes', () {
      final points = [
        for (var i = 0; i <= 40; i++)
          PointVector(i * 5.0, 0, i < 20 ? 0.2 : 0.9),
      ];

      final withoutPressure = Stroke.simplifyPoints(points, 1);
      final withPressure = Stroke.simplifyPoints(points, 1, pressureScale: 10);

      expect(withoutPressure, hasLength(2));
      expect(withPressure.length, greaterThan(2));
      expect(withPressure.any((point) => point.pressure == 0.2), isTrue);
      expect(withPressure.any((point) => point.pressure == 0.9), isTrue);
    });

    test('returns short strokes unchanged', () {
      final points = [p(0, 0), p(10, 5)];

      expect(Stroke.simplifyPoints(points, 5), points);
    });
  });

  group('low quality polygon', () {
    test('does not cut the corners of a sparsely sampled stroke', () {
      // a square outline with 3 points per side, so corners fall on
      // indices that skipping every 4th point would drop
      final corners = [
        Offset.zero,
        const Offset(300, 0),
        const Offset(300, 300),
        const Offset(0, 300),
        Offset.zero,
      ];
      final offsets = <Offset>[
        for (var side = 0; side < 4; side++)
          for (var i = 0; i < 3; i++)
            Offset.lerp(corners[side], corners[side + 1], i / 3)!,
        corners.last,
      ];
      final stroke = strokeThrough(offsets, size: 20);

      final high = Path()..addPolygon(stroke.highQualityPolygon, true);
      final low = Path()..addPolygon(stroke.lowQualityPolygon, true);

      final difference =
          high.getBounds().topLeft -
          low.getBounds().topLeft +
          (high.getBounds().bottomRight - low.getBounds().bottomRight);
      expect(difference.distance, lessThan(stroke.options.size));
    });

    test('is much smaller than the high quality one for dense strokes', () {
      final offsets = [for (var i = 0; i <= 400; i++) Offset(i * 2.0, i * 0.5)];
      final stroke = strokeThrough(offsets, size: 4);

      expect(
        stroke.lowQualityPolygon.length,
        lessThan(stroke.highQualityPolygon.length / 4),
      );
    });
  });
}

double _distanceToPolyline(Offset point, List<PointVector> polyline) {
  var best = double.infinity;
  for (var i = 0; i < polyline.length - 1; i++) {
    final a = Offset(polyline[i].x, polyline[i].y);
    final b = Offset(polyline[i + 1].x, polyline[i + 1].y);
    final ab = b - a;
    final lengthSquared = ab.distanceSquared;
    final t = lengthSquared == 0
        ? 0.0
        : (((point - a).dx * ab.dx + (point - a).dy * ab.dy) / lengthSquared)
              .clamp(0.0, 1.0);
    final distance = (point - (a + ab * t)).distance;
    if (distance < best) best = distance;
  }
  return best;
}
