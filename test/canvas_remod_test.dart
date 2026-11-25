/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_canvas_background_painter.dart';
import 'package:saber/components/canvas/_circle_stroke.dart';
import 'package:saber/components/canvas/_polygon_stroke.dart';
import 'package:saber/components/canvas/_rectangle_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/painters/background_viewport_helper.dart';
import 'package:saber/components/canvas/stroke/stroke_geometry.dart';
import 'package:saber/components/canvas/stroke/stroke_serialization.dart';
import 'package:saber/components/canvas/stroke/stroke_simplifier.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

class _TestPage implements HasSize {
  @override
  Size get size => const Size(1000, 1400);
  const _TestPage();
}

Stroke _makeStroke({
  Color color = Colors.black,
  Color? fillColor,
  LineStyle lineStyle = LineStyle.solid,
  double size = 10,
  ToolId toolId = ToolId.fountainPen,
  bool pressureEnabled = true,
}) {
  return Stroke(
    color: color,
    pressureEnabled: pressureEnabled,
    options: StrokeOptions(size: size),
    pageIndex: 0,
    page: const _TestPage(),
    toolId: toolId,
    fillColor: fillColor,
    lineStyle: lineStyle,
  );
}

void main() {
  group('Stroke geometry, transforms, and hit-testing', () {
    test('freehand boundingBox expands by half stroke size', () {
      final stroke = _makeStroke(size: 10)
        ..addPoint(const Offset(20, 30), 0.5)
        ..addPoint(const Offset(100, 80), 0.5);

      expect(stroke.boundingBox, const Rect.fromLTRB(15, 25, 105, 85));
    });

    test('shape subclass bounding boxes delegate accurately', () {
      const page = _TestPage();
      final circle = CircleStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 4),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        center: const Offset(50, 60),
        radius: 25,
      );
      expect(circle.boundingBox, const Rect.fromLTRB(25, 35, 75, 85));

      final rectStroke = RectangleStroke(
        color: Colors.red,
        pressureEnabled: false,
        options: StrokeOptions(size: 4),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        rect: const Rect.fromLTWH(10, 20, 40, 60),
      );
      expect(rectStroke.boundingBox, const Rect.fromLTWH(10, 20, 40, 60));

      final poly = PolygonStroke(
        color: Colors.green,
        pressureEnabled: false,
        options: StrokeOptions(size: 4),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        vertices: const [Offset(0, 10), Offset(30, 5), Offset(20, 40)],
      );
      expect(poly.boundingBox, const Rect.fromLTRB(0, 5, 30, 40));
    });

    test('rotateAround and scaleAround update geometry and revision', () {
      final stroke = _makeStroke(size: 4)
        ..addPoint(const Offset(10, 0), 0.5)
        ..addPoint(const Offset(20, 0), 0.5);
      final initialRev = stroke.geometryRevision;

      stroke.rotateAround(pi / 2, Offset.zero);
      expect(stroke.geometryRevision, initialRev + 1);
      expect(stroke.firstPoint!.dx, closeTo(0, 1e-6));
      expect(stroke.firstPoint!.dy, closeTo(10, 1e-6));

      stroke.scaleAround(2, 3, Offset.zero);
      expect(stroke.geometryRevision, initialRev + 2);
      expect(stroke.firstPoint!.dy, closeTo(30, 1e-6));
      expect(stroke.lastPoint!.dy, closeTo(60, 1e-6));
    });

    test('pointToSegmentDistance and isPointNearStroke detect hits', () {
      expect(
        pointToSegmentDistance(
          const Offset(50, 10),
          Offset.zero,
          const Offset(100, 0),
        ),
        closeTo(10, 1e-6),
      );
      expect(
        pointToSegmentDistance(
          const Offset(110, 0),
          Offset.zero,
          const Offset(100, 0),
        ),
        closeTo(10, 1e-6),
      );

      final stroke = _makeStroke(size: 6)
        ..addPoint(Offset.zero, 0.5)
        ..addPoint(const Offset(100, 0), 0.5);
      expect(
        isPointNearStroke(stroke, const Offset(50, 5), tolerance: 4),
        true,
      );
      expect(
        isPointNearStroke(stroke, const Offset(50, 30), tolerance: 4),
        false,
      );
    });

    test('renderSignature changes on color, lineStyle, or geometry edits', () {
      final stroke = _makeStroke()..addPoint(const Offset(10, 10), 0.5);
      final sig1 = stroke.renderSignature;
      stroke.color = Colors.red;
      final sig2 = stroke.renderSignature;
      stroke.lineStyle = LineStyle.dashed;
      final sig3 = stroke.renderSignature;
      stroke.shift(const Offset(5, 5));
      final sig4 = stroke.renderSignature;

      expect({sig1, sig2, sig3, sig4}.length, 4);
    });
  });

  group('Stroke snapping, simplification, and styled paths', () {
    test('Cartesian and isometric grid snapping', () {
      expect(
        Stroke.snapPointToGrid(const Offset(23, 38), 20),
        const Offset(20, 40),
      );
      expect(
        Stroke.snapPointToGrid(const Offset(23, 38), 0),
        const Offset(23, 38),
      );

      final iso = Stroke.snapPointToIsometricGrid(const Offset(1, 2), 40);
      expect(iso.dx, closeTo(0, 1e-6));
      expect(iso.dy, closeTo(0, 1e-6));
    });

    test('line angle snapping preserves length', () {
      const start = PointVector(0, 0, 0.5);
      const end = PointVector(100, 4, 0.5);
      final (_, snappedHv) = Stroke.snapLine(start, end);
      expect(snappedHv.y, 0);

      final (_, snapped45) = Stroke.snapLineToAngle(
        start,
        const PointVector(100, 90, 0.5),
        45,
      );
      final origLen = sqrt(100 * 100 + 90 * 90);
      final snappedLen = sqrt(
        snapped45.x * snapped45.x + snapped45.y * snapped45.y,
      );
      expect(snappedLen, closeTo(origLen, 1e-6));
      expect(snapped45.x, closeTo(snapped45.y, 1e-6));
    });

    test('simplifier and styledPath produce valid outputs', () {
      final pts = <PointVector>[
        for (int i = 0; i <= 20; i++) PointVector(i * 10.0, 0, 0.5),
      ];
      final simplified = simplifyStrokePoints(pts, 1.0);
      expect(simplified.length, 2);

      final stroke = _makeStroke(lineStyle: LineStyle.dashed, size: 4)
        ..addPoint(Offset.zero, 0.5)
        ..addPoint(const Offset(100, 0), 0.5)
        ..addPoint(const Offset(200, 0), 0.5);
      expect(stroke.styledPath.computeMetrics().length, greaterThan(1));
      expect(stroke.toSvgPath(), startsWith('M'));
    });
  });

  group('Stroke serialization', () {
    test(
      'toJson / fromJson round-trip preserves points, colors, and style',
      () {
        final original =
            _makeStroke(
                color: const Color(0xFF123456),
                fillColor: const Color(0x80ABCDEF),
                lineStyle: LineStyle.dotted,
                size: 8,
              )
              ..addPoint(const Offset(12.5, 25.0), 0.7)
              ..addPoint(const Offset(42.0, 88.5), 0.4);

        final json = original.toJson();
        final decoded = Stroke.fromJson(
          json,
          fileVersion: 14,
          pageIndex: 0,
          page: const _TestPage(),
        );

        expect(decoded.color.toARGB32(), original.color.toARGB32());
        expect(decoded.fillColor?.toARGB32(), original.fillColor?.toARGB32());
        expect(decoded.lineStyle, LineStyle.dotted);
        expect(decoded.length, 2);
        expect(decoded.firstPoint!.dx, closeTo(12.5, 0.01));
        expect(decoded.lastPoint!.dy, closeTo(88.5, 0.01));
      },
    );

    test('parseLineStyle and color helpers handle edge cases', () {
      expect(parseLineStyle('dashed'), LineStyle.dashed);
      expect(parseLineStyle('dotted'), LineStyle.dotted);
      expect(parseLineStyle(null), LineStyle.solid);
      expect(parseStrokeColor(null, fallback: Colors.black), Colors.black);
      expect(parseOptionalStrokeColor(null), isNull);
    });
  });

  group('Viewport-culled CanvasBackgroundPainter', () {
    test(
      'clampInfiniteBounds rejects sentinels, empty, and non-finite rects',
      () {
        expect(clampInfiniteBounds(Rect.zero), isNull);
        expect(clampInfiniteBounds(Rect.largest), isNull);
        expect(
          clampInfiniteBounds(const Rect.fromLTRB(0, 0, double.infinity, 100)),
          isNull,
        );
        expect(
          clampInfiniteBounds(const Rect.fromLTRB(-500, -400, 500, 400)),
          const Rect.fromLTRB(-500, -400, 500, 400),
        );
      },
    );

    test(
      'quantizedScaleForInfinite and quantizedInfiniteRect stabilize cache',
      () {
        expect(CanvasBackgroundPainter.quantizedScaleForInfinite(1.0), 1.0);
        expect(CanvasBackgroundPainter.quantizedScaleForInfinite(0.75), 0.5);
        expect(CanvasBackgroundPainter.quantizedScaleForInfinite(0.5), 0.5);
        expect(CanvasBackgroundPainter.quantizedScaleForInfinite(0.3), 0.25);

        final rectA = CanvasBackgroundPainter.quantizedInfiniteRect(
          const Rect.fromLTWH(100, 100, 400, 400),
          1.0,
        );
        final rectB = CanvasBackgroundPainter.quantizedInfiniteRect(
          const Rect.fromLTWH(110, 105, 400, 400),
          1.0,
        );
        expect(rectA, isNotNull);
        expect(rectA, rectB);
      },
    );

    test('all infinite-canvas patterns clamp strictly to visible viewport', () {
      const bounds = Rect.fromLTRB(-300, -200, 300, 200);
      const size = Size(1000, 1400);
      const lineHeight = 40;

      for (final pattern in CanvasBackgroundPattern.values) {
        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: pattern,
          size: size,
          lineHeight: lineHeight,
          bounds: bounds,
        ).toList();

        if (pattern == CanvasBackgroundPattern.none) {
          expect(elements, isEmpty);
          continue;
        }

        expect(elements, isNotEmpty, reason: 'Pattern $pattern yielded none');
        expect(
          elements.length,
          lessThan(500),
          reason: 'Pattern $pattern exceeded viewport-culled count',
        );

        for (final el in elements) {
          expect(el.start.dx.isFinite && el.start.dy.isFinite, true);
          expect(el.end.dx.isFinite && el.end.dy.isFinite, true);
          if (pattern != CanvasBackgroundPattern.isometric &&
              pattern != CanvasBackgroundPattern.collegeRtl) {
            expect(
              el.start.dx,
              inInclusiveRange(
                bounds.left - lineHeight,
                bounds.right + lineHeight,
              ),
            );
            expect(
              el.start.dy,
              inInclusiveRange(
                bounds.top - lineHeight,
                bounds.bottom + lineHeight,
              ),
            );
          }
        }
      }
    });

    test('paint executes cleanly for finite and infinite canvas modes', () {
      for (final pattern in CanvasBackgroundPattern.values) {
        for (final isInfinite in [false, true]) {
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);
          final painter = CanvasBackgroundPainter(
            invert: false,
            backgroundColor: Colors.white,
            backgroundPattern: pattern,
            lineHeight: 40,
            lineThickness: 2,
            isInfiniteCanvas: isInfinite,
            viewportRect: const Rect.fromLTWH(0, 0, 500, 500),
            currentScale: isInfinite ? 0.5 : 2.0,
          );
          painter.paint(canvas, const Size(1000, 1400));
          final picture = recorder.endRecording();
          picture.dispose();
        }
      }
    });

    test(
      'shouldRepaint returns false for tiny pans within quantized infinite rect',
      () {
        const a = CanvasBackgroundPainter(
          invert: false,
          backgroundColor: Colors.white,
          backgroundPattern: CanvasBackgroundPattern.grid,
          lineHeight: 40,
          lineThickness: 2,
          isInfiniteCanvas: true,
          viewportRect: Rect.fromLTWH(100, 100, 400, 400),
          currentScale: 1.0,
        );
        const b = CanvasBackgroundPainter(
          invert: false,
          backgroundColor: Colors.white,
          backgroundPattern: CanvasBackgroundPattern.grid,
          lineHeight: 40,
          lineThickness: 2,
          isInfiniteCanvas: true,
          viewportRect: Rect.fromLTWH(105, 105, 400, 400),
          currentScale: 1.0,
        );
        expect(b.shouldRepaint(a), false);
      },
    );
  });
}
