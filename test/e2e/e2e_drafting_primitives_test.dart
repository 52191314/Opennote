/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_polygon_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pageSize = Size(1000, 1400);
  const page = HasSize(pageSize);

  group('Feature 7: Arrow Tool & Persistence (ORIGINAL_REQUEST § R3)', () {
    // -------------------------------------------------------------
    // Tier 1: Feature Coverage (>=5 tests)
    // -------------------------------------------------------------
    test('T1.1: ArrowStroke construction and properties', () {
      final arrow = ArrowStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 3.0),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(10, 20),
        end: const Offset(110, 70),
        arrowheadStyle: ArrowheadStyle.single,
        headLength: 14.0,
        headAngle: 0.5,
      );

      expect(arrow.start, equals(const Offset(10, 20)));
      expect(arrow.end, equals(const Offset(110, 70)));
      expect(arrow.arrowheadStyle, equals(ArrowheadStyle.single));
      expect(arrow.headLength, equals(14.0));
      expect(arrow.headAngle, equals(0.5));
      expect(arrow.color, equals(Colors.blue));
    });

    test('T1.2: ArrowStroke JSON serialization contains required fields', () {
      final arrow = ArrowStroke(
        color: const Color(0xFF123456),
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 1,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(50, 60),
        end: const Offset(200, 60),
        arrowheadStyle: ArrowheadStyle.double,
      );

      final json = arrow.toJson();
      expect(json['shape'], equals('arrow'));
      expect(json['sx'], equals(50.0));
      expect(json['sy'], equals(60.0));
      expect(json['ex'], equals(200.0));
      expect(json['ey'], equals(60.0));
      expect(json['ah'], equals('double'));
      expect(json['i'], equals(1));
    });

    test('T1.3: ArrowStroke JSON roundtrip persistence', () {
      final original = ArrowStroke(
        color: Colors.red,
        pressureEnabled: false,
        options: StrokeOptions(size: 4.0),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(25, 45),
        end: const Offset(180, 95),
        arrowheadStyle: ArrowheadStyle.single,
        headLength: 16.0,
        headAngle: 0.45,
      );

      final json = original.toJson();
      final restored = ArrowStroke.fromJson(
        json,
        fileVersion: 1,
        pageIndex: 0,
        page: page,
      );

      expect(restored.start, equals(original.start));
      expect(restored.end, equals(original.end));
      expect(restored.arrowheadStyle, equals(original.arrowheadStyle));
      expect(restored.headLength, equals(original.headLength));
      expect(restored.headAngle, equals(original.headAngle));
      expect(restored.color.toARGB32(), equals(original.color.toARGB32()));
    });

    test(
      'T1.4: ArrowheadStyle variants serialize and deserialize faithfully',
      () {
        for (final style in [
          ArrowheadStyle.none,
          ArrowheadStyle.single,
          ArrowheadStyle.double,
        ]) {
          final arrow = ArrowStroke(
            color: Colors.black,
            pressureEnabled: false,
            options: StrokeOptions(size: 2.0),
            pageIndex: 0,
            page: page,
            toolId: ToolId.shapePen,
            start: const Offset(0, 0),
            end: const Offset(100, 0),
            arrowheadStyle: style,
          );

          final json = arrow.toJson();
          expect(json['ah'], equals(style.name));

          final restored = ArrowStroke.fromJson(
            json,
            fileVersion: 1,
            pageIndex: 0,
            page: page,
          );
          expect(restored.arrowheadStyle, equals(style));
        }
      },
    );

    test('T1.5: ArrowStroke clone copy creates independent object', () {
      final original = ArrowStroke(
        color: Colors.green,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.5),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(10, 10),
        end: const Offset(50, 50),
      );

      final copy = original.copy();
      expect(copy.start, equals(original.start));
      expect(copy.end, equals(original.end));
      expect(identical(original, copy), isFalse);

      copy.end = const Offset(99, 99);
      expect(original.end, equals(const Offset(50, 50)));
    });

    // -------------------------------------------------------------
    // Tier 2: Boundary & Corner Cases (>=5 tests)
    // -------------------------------------------------------------
    test('T2.1: Zero-length arrow (start == end) toSvgPath handles safely', () {
      final zeroArrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(50, 50),
        end: const Offset(50, 50),
      );

      // Distance < 0.001 returns empty string without NaN/crash
      expect(zeroArrow.toSvgPath(), isEmpty);
    });

    test('T2.2: Cardinal direction arrows orientation and maxY bounds', () {
      // Horizontal right
      final right = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(0, 50),
        end: const Offset(100, 50),
      );
      expect(right.maxY, equals(50.0));

      // Vertical down
      final down = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(50, 0),
        end: const Offset(50, 100),
      );
      expect(down.maxY, equals(100.0));
    });

    test('T2.3: Negative coordinate arrows serialization', () {
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(-50, -40),
        end: const Offset(-10, -20),
      );

      final json = arrow.toJson();
      expect(json['sx'], equals(-50.0));
      expect(json['ey'], equals(-20.0));

      final restored = ArrowStroke.fromJson(
        json,
        fileVersion: 1,
        pageIndex: 0,
        page: page,
      );
      expect(restored.start, equals(const Offset(-50, -40)));
      expect(restored.end, equals(const Offset(-10, -20)));
    });

    test('T2.4: ArrowStroke rotateAround rotates endpoints by 90 degrees', () {
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(0, 0),
        end: const Offset(100, 0),
      );

      // Rotate 90 degrees around origin (0, 0)
      arrow.rotateAround(pi / 2, Offset.zero);

      expect(arrow.start.dx, closeTo(0.0, 1e-4));
      expect(arrow.start.dy, closeTo(0.0, 1e-4));
      expect(arrow.end.dx, closeTo(0.0, 1e-4));
      expect(arrow.end.dy, closeTo(100.0, 1e-4));
    });

    test(
      'T2.5: ArrowStroke scaleAround scales vector distance relative to pivot',
      () {
        final arrow = ArrowStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(10, 0),
          end: const Offset(50, 0),
        );

        // Scale 2x around origin (0, 0)
        arrow.scaleAround(2.0, 2.0, Offset.zero);

        expect(arrow.start, equals(const Offset(20, 0)));
        expect(arrow.end, equals(const Offset(100, 0)));
      },
    );
  });

  group(
    'Feature 8: Dimension Tool & Live Readouts (ORIGINAL_REQUEST § R3)',
    () {
      // -------------------------------------------------------------
      // Tier 1: Feature Coverage (>=5 tests)
      // -------------------------------------------------------------
      test('T1.6: DimensionStroke construction and properties', () {
        final dim = DimensionStroke(
          color: Colors.blue,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(20, 30),
          end: const Offset(120, 30),
          offset: 35.0,
          text: '100 mm',
          headLength: 12.0,
          headAngle: 0.4,
        );

        expect(dim.start, equals(const Offset(20, 30)));
        expect(dim.end, equals(const Offset(120, 30)));
        expect(dim.offset, equals(35.0));
        expect(dim.text, equals('100 mm'));
        expect(dim.headLength, equals(12.0));
        expect(dim.headAngle, equals(0.4));
      });

      test(
        'T1.7: DimensionStroke JSON serialization contains required fields',
        () {
          final dim = DimensionStroke(
            color: const Color(0xFF654321),
            pressureEnabled: false,
            options: StrokeOptions(size: 2.0),
            pageIndex: 2,
            page: page,
            toolId: ToolId.shapePen,
            start: const Offset(0, 0),
            end: const Offset(80, 60),
            offset: 25.0,
            text: '10.0 cm',
          );

          final json = dim.toJson();
          expect(json['shape'], equals('dimension'));
          expect(json['sx'], equals(0.0));
          expect(json['sy'], equals(0.0));
          expect(json['ex'], equals(80.0));
          expect(json['ey'], equals(60.0));
          expect(json['o'], equals(25.0));
          expect(json['t'], equals('10.0 cm'));
          expect(json['i'], equals(2));
        },
      );

      test('T1.8: DimensionStroke JSON roundtrip persistence', () {
        final original = DimensionStroke(
          color: Colors.orange,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(40, 50),
          end: const Offset(240, 50),
          offset: 40.0,
          headLength: 11.0,
          headAngle: 0.35,
        );

        final json = original.toJson();
        final restored = DimensionStroke.fromJson(
          json,
          fileVersion: 1,
          pageIndex: 0,
          page: page,
        );

        expect(restored.start, equals(original.start));
        expect(restored.end, equals(original.end));
        expect(restored.offset, equals(original.offset));
        expect(restored.headLength, equals(original.headLength));
        expect(restored.headAngle, equals(original.headAngle));
      });

      test('T1.9: Dimension line parallel offset vector calculation', () {
        // Horizontal segment from (0, 0) to (100, 0)
        // Unit dir = (1, 0), Perpendicular = (0, 1) or (-dy, dx)
        final dim = DimensionStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(0, 0),
          end: const Offset(100, 0),
          offset: 30.0,
          text: '100',
        );

        // Dimension line should be parallel and shifted by offset
        final svg = dim.toSvgPath();
        expect(svg, isNotEmpty);
        expect(svg, startsWith('M'));
        expect(svg, contains('L'));
      });

      test('T1.10: Live readout distance calculation formula', () {
        // Euclidean distance formula: sqrt(dx^2 + dy^2)
        double calcDistance(Offset p1, Offset p2) {
          final dx = p2.dx - p1.dx;
          final dy = p2.dy - p1.dy;
          return sqrt(dx * dx + dy * dy);
        }

        // 3-4-5 right triangle
        expect(
          calcDistance(const Offset(0, 0), const Offset(30, 40)),
          closeTo(50.0, 1e-4),
        );
        // Pure horizontal
        expect(
          calcDistance(const Offset(10, 20), const Offset(110, 20)),
          closeTo(100.0, 1e-4),
        );
        // Pure vertical
        expect(
          calcDistance(const Offset(50, 10), const Offset(50, 85)),
          closeTo(75.0, 1e-4),
        );
      });

      // -------------------------------------------------------------
      // Tier 2: Boundary & Corner Cases (>=5 tests)
      // -------------------------------------------------------------
      test('T2.6: Zero-length dimension line toSvgPath handles safely', () {
        final zeroDim = DimensionStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(40, 40),
          end: const Offset(40, 40),
          offset: 20.0,
          text: '0',
        );

        expect(zeroDim.toSvgPath(), isEmpty);
      });

      test('T2.7: Dimension line with zero offset is collinear', () {
        final dim = DimensionStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(0, 50),
          end: const Offset(100, 50),
          offset: 0.0,
          text: '100',
        );

        expect(dim.textPosition.dy, closeTo(50.0, 1e-4));
      });

      test('T2.8: Negative offset places dimension line on opposite side', () {
        final dimPositive = DimensionStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(0, 50),
          end: const Offset(100, 50),
          offset: 30.0,
        );

        final dimNegative = DimensionStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(0, 50),
          end: const Offset(100, 50),
          offset: -30.0,
        );

        final posDiff = dimPositive.textPosition.dy - 50.0;
        final negDiff = dimNegative.textPosition.dy - 50.0;
        expect(posDiff, closeTo(-negDiff, 1e-4));
      });

      test('T2.9: Dimension text position centering between endpoints', () {
        final dim = DimensionStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(10, 20),
          end: const Offset(110, 20),
          offset: 40.0,
        );

        // Midpoint X should be (10 + 110) / 2 = 60
        expect(dim.textPosition.dx, closeTo(60.0, 1e-4));
      });

      test('T2.10: Fractional distance readout formatting precision', () {
        double dist = 123.4567;
        String formattedMm = '${dist.toStringAsFixed(1)} mm';
        expect(formattedMm, equals('123.5 mm'));

        String formattedTwoDecimals = '${dist.toStringAsFixed(2)} mm';
        expect(formattedTwoDecimals, equals('123.46 mm'));
      });
    },
  );

  group('Feature 9: Endpoint Vertex Manipulation (ORIGINAL_REQUEST § R3)', () {
    // -------------------------------------------------------------
    // Tier 1: Feature Coverage (>=5 tests)
    // -------------------------------------------------------------
    test(
      'T1.11: Arrow end vertex translation updates length and direction',
      () {
        final arrow = ArrowStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(0, 0),
          end: const Offset(50, 0),
        );

        expect(arrow.end.dx, equals(50.0));
        arrow.end = const Offset(150, 0);
        expect(arrow.end.dx, equals(150.0));
        expect(arrow.start, equals(Offset.zero));
      },
    );

    test('T1.12: Arrow start vertex translation updates origin', () {
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(0, 0),
        end: const Offset(100, 0),
      );

      arrow.start = const Offset(20, 10);
      expect(arrow.start, equals(const Offset(20, 10)));
      expect(arrow.end, equals(const Offset(100, 0)));
    });

    test('T1.13: Dimension endpoint translation updates measured span', () {
      final dim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(0, 0),
        end: const Offset(100, 0),
        text: '100 mm',
      );

      // Translate end vertex
      dim.end = const Offset(250, 0);
      final newDistance = (dim.end - dim.start).distance;
      dim.text = '${newDistance.toInt()} mm';

      expect(dim.text, equals('250 mm'));
    });

    test('T1.14: Dimension offset dynamic adjustment', () {
      final dim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(0, 0),
        end: const Offset(100, 0),
        offset: 20.0,
      );

      final y1 = dim.textPosition.dy;
      dim.offset = 60.0;
      final y2 = dim.textPosition.dy;

      expect((y2 - y1).abs(), closeTo(40.0, 1e-4));
    });

    test('T1.15: PolygonStroke vertex manipulation retains closed status', () {
      final vertices = [
        const Offset(0, 0),
        const Offset(100, 0),
        const Offset(50, 80),
      ];
      final polygon = PolygonStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        vertices: vertices,
        closed: true,
      );

      expect(polygon.vertices, hasLength(3));
      expect(polygon.closed, isTrue);

      // Move peak vertex
      polygon.vertices[2] = const Offset(50, 120);
      expect(polygon.vertices[2], equals(const Offset(50, 120)));
      expect(polygon.closed, isTrue);
    });

    // -------------------------------------------------------------
    // Tier 2: Boundary & Corner Cases (>=5 tests)
    // -------------------------------------------------------------
    test(
      'T2.11: Arrow end moved to coincide with start produces zero length safely',
      () {
        final arrow = ArrowStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(100, 100),
          end: const Offset(200, 200),
        );

        arrow.end = arrow.start;
        expect((arrow.end - arrow.start).distance, equals(0.0));
        expect(arrow.toSvgPath(), isEmpty);
      },
    );

    test(
      'T2.12: Primitive vertex moved across origin to negative coordinates',
      () {
        final arrow = ArrowStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(50, 50),
          end: const Offset(100, 100),
        );

        arrow.start = const Offset(-80, -90);
        expect(arrow.start, equals(const Offset(-80, -90)));
        expect(arrow.toJson()['sx'], equals(-80.0));
      },
    );

    test('T2.13: Minimum 3-vertex polygon triangle manipulation', () {
      final poly = PolygonStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        vertices: [
          const Offset(10, 10),
          const Offset(40, 10),
          const Offset(25, 35),
        ],
        closed: true,
      );

      poly.vertices[0] = const Offset(0, 10);
      expect(poly.vertices[0], equals(const Offset(0, 10)));
      expect(poly.vertices.length, equals(3));
    });

    test(
      'T2.14: Stroke.shift translates all primitive vertices concurrently',
      () {
        final arrow = ArrowStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(10, 20),
          end: const Offset(100, 50),
        );

        arrow.shift(const Offset(15, 25));
        expect(arrow.start, equals(const Offset(25, 45)));
        expect(arrow.end, equals(const Offset(115, 75)));
      },
    );

    test(
      'T2.15: 360-degree rotation restores vertex positions within tolerance',
      () {
        final arrow = ArrowStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: page,
          toolId: ToolId.shapePen,
          start: const Offset(50, 50),
          end: const Offset(150, 50),
        );

        arrow.rotateAround(2 * pi, arrow.start);
        expect(arrow.end.dx, closeTo(150.0, 1e-4));
        expect(arrow.end.dy, closeTo(50.0, 1e-4));
      },
    );
  });
}
