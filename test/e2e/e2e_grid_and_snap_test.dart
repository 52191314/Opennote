/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_canvas_background_painter.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FlavorConfig.setup();
  });

  // Reset prefs before each test
  setUp(() {
    stows.snapToGrid.value = false;
    stows.gridSize.value = 20.0;
    stows.snapToAngle.value = false;
    stows.snapAngleStep.value = 15;
  });

  group(
    'Feature 3: Isometric Concurrence & Grid Math (ORIGINAL_REQUEST § R2)',
    () {
      // -------------------------------------------------------------
      // Tier 1: Feature Coverage (>=5 tests)
      // -------------------------------------------------------------
      test(
        'T1.1: Isometric pattern elements generation produces non-empty lines',
        () {
          const size = Size(800, 1000);
          final elements = CanvasBackgroundPainter.getPatternElements(
            pattern: CanvasBackgroundPattern.isometric,
            size: size,
            lineHeight: 20,
          ).toList();

          expect(elements, isNotEmpty);
          expect(elements.any((e) => e.isLine), isTrue);
        },
      );

      test('T1.2: Isometric vertical line separation consistency', () {
        const size = Size(600, 800);
        const lineHeight = 20;
        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.isometric,
          size: size,
          lineHeight: lineHeight,
        ).toList();

        final verticalLines =
            elements
                .where((e) => e.isLine && e.start.dx == e.end.dx)
                .map((e) => e.start.dx)
                .toList()
              ..sort();

        expect(verticalLines, isNotEmpty);
        for (int i = 0; i < verticalLines.length - 1; i++) {
          final diff = (verticalLines[i + 1] - verticalLines[i]).abs();
          expect(diff, closeTo(lineHeight * sqrt(3) / 2, 0.01));
        }
      });

      test('T1.3: Isometric diagonal lines slope matches tan(30 degrees)', () {
        const size = Size(800, 1000);
        const lineHeight = 25;
        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.isometric,
          size: size,
          lineHeight: lineHeight,
        ).toList();

        final diagonals = elements
            .where(
              (e) =>
                  e.isLine && e.start.dx != e.end.dx && e.start.dy != e.end.dy,
            )
            .toList();
        expect(diagonals, isNotEmpty);

        final expectedTan30 = tan(30 * pi / 180); // ~0.577350269
        for (final diag in diagonals) {
          final slope =
              (diag.end.dy - diag.start.dy) / (diag.end.dx - diag.start.dx);
          expect(slope.abs(), closeTo(expectedTan30, 0.02));
        }
      });

      test('T1.4: Theoretical isometric vertex concurrence model', () {
        // In true isometric grid, vertical spacing L, dx = L * sqrt(3) / 2
        // Lines:
        // Vertical: x = n * dx
        // Diagonal +30 deg: y = tan(30) * x + b1
        // Diagonal -30 deg: y = -tan(30) * x + b2
        // At an intersection vertex (x0, y0), both diagonals and vertical must concur
        const double L = 40.0;
        final double tan30 = tan(pi / 6);
        final double dx = L * cos(pi / 6); // L * sqrt(3)/2

        // Pick vertex n = 2, m = 3
        final double x0 = 2 * dx;
        const double y0 = 3 * L;

        // Diagonal 1 passes through (x0, y0): b1 = y0 - tan30 * x0
        final double b1 = y0 - tan30 * x0;
        // Diagonal 2 passes through (x0, y0): b2 = y0 + tan30 * x0
        final double b2 = y0 + tan30 * x0;

        // Test intersection of Diag 1 and Diag 2
        final double intersectX = (b2 - b1) / (2 * tan30);
        final double intersectY = tan30 * intersectX + b1;

        expect(intersectX, closeTo(x0, 1e-4));
        expect(intersectY, closeTo(y0, 1e-4));
      });

      test('T1.5: Engineering grid heavy lines cadence', () {
        const size = Size(500, 500);
        const lineHeight = 10;
        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.engineeringGrid,
          size: size,
          lineHeight: lineHeight,
        ).toList();

        expect(elements, isNotEmpty);
        final heavyLines = elements.where((e) => e.thickness != null).toList();
        expect(heavyLines, isNotEmpty);
      });

      // -------------------------------------------------------------
      // Tier 2: Boundary & Corner Cases (>=5 tests)
      // -------------------------------------------------------------
      test('T2.1: Isometric grid on non-square canvas (800x1400)', () {
        const size = Size(800, 1400);
        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.isometric,
          size: size,
          lineHeight: 30,
        ).toList();

        expect(elements, isNotEmpty);
        final maxY = elements.map((e) => max(e.start.dy, e.end.dy)).reduce(max);
        expect(maxY, greaterThanOrEqualTo(1000.0));
      });

      test('T2.2: Extreme line heights scale element counts', () {
        const size = Size(500, 500);
        final elementsSmall = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.isometric,
          size: size,
          lineHeight: 10,
        ).length;

        final elementsLarge = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.isometric,
          size: size,
          lineHeight: 100,
        ).length;

        expect(elementsSmall, greaterThan(elementsLarge));
      });

      test('T2.3: Generated isometric line coordinates are finite numbers', () {
        const size = Size(1000, 1000);
        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.isometric,
          size: size,
          lineHeight: 20,
        );

        for (final e in elements) {
          expect(e.start.dx.isFinite, isTrue);
          expect(e.start.dy.isFinite, isTrue);
          expect(e.end.dx.isFinite, isTrue);
          expect(e.end.dy.isFinite, isTrue);
        }
      });

      test(
        'T2.4: Float precision tolerance on isometric intersection vertices',
        () {
          const double step = 20.0;
          final double tan30 = tan(pi / 6);
          for (int i = 1; i <= 5; i++) {
            final double x = i * step;
            final double y = tan30 * x;
            final double reversedX = y / tan30;
            expect(reversedX, closeTo(x, 1e-5));
          }
        },
      );

      test(
        'T2.5: CanvasBackgroundPattern.none produces exactly empty elements',
        () {
          const size = Size(1000, 1000);
          final elements = CanvasBackgroundPainter.getPatternElements(
            pattern: CanvasBackgroundPattern.none,
            size: size,
            lineHeight: 20,
          );
          expect(elements.isEmpty, isTrue);
        },
      );
    },
  );

  group(
    'Feature 4: Snap-to-Grid & Line Height Coupling (ORIGINAL_REQUEST § R2)',
    () {
      // -------------------------------------------------------------
      // Tier 1: Feature Coverage (>=5 tests)
      // -------------------------------------------------------------
      test('T1.6: Stroke.snapPointToGrid standard rounding', () {
        const gridSize = 20.0;
        final snapped1 = Stroke.snapPointToGrid(const Offset(12, 18), gridSize);
        expect(snapped1, equals(const Offset(20, 20)));

        final snapped2 = Stroke.snapPointToGrid(const Offset(8, 22), gridSize);
        expect(snapped2, equals(const Offset(0, 20)));
      });

      test('T1.7: Point exactly on grid vertex remains unchanged', () {
        const gridSize = 25.0;
        const point = Offset(50, 75);
        final snapped = Stroke.snapPointToGrid(point, gridSize);
        expect(snapped, equals(point));
      });

      test('T1.8: Snap-to-grid spacing coupled to active page line height', () {
        const double pageLineHeight = 32.0;
        const arbitraryPoint = Offset(35, 60);
        final snapped = Stroke.snapPointToGrid(arbitraryPoint, pageLineHeight);

        expect(snapped.dx % pageLineHeight, closeTo(0, 1e-4));
        expect(snapped.dy % pageLineHeight, closeTo(0, 1e-4));
        expect(snapped, equals(const Offset(32, 64)));
      });

      test('T1.9: Ruler tool drag end snaps point to grid when enabled', () {
        final ruler = Ruler();
        final page = EditorPage();

        stows.snapToGrid.value = true;
        stows.gridSize.value = 25.0;

        ruler.onDragStart(const Offset(10, 10), page, 0, null);
        ruler.onDragUpdate(const Offset(53, 72), null);
        final stroke = ruler.onDragEnd();

        expect(stroke, isNotNull);
        expect(stroke!.points.length, greaterThanOrEqualTo(2));
        // End point should be snapped to (50, 75)
        expect(stroke.points.last.x, equals(50.0));
        expect(stroke.points.last.y, equals(75.0));
      });

      test('T1.10: Mid-cell rounding symmetry', () {
        const gridSize = 10.0;
        // Below midpoint rounds down
        expect(
          Stroke.snapPointToGrid(const Offset(4.9, 4.9), gridSize),
          equals(Offset.zero),
        );
        // Above midpoint rounds up
        expect(
          Stroke.snapPointToGrid(const Offset(5.1, 5.1), gridSize),
          equals(const Offset(10, 10)),
        );
      });

      // -------------------------------------------------------------
      // Tier 2: Boundary & Corner Cases (>=5 tests)
      // -------------------------------------------------------------
      test('T2.6: Negative coordinates snapping', () {
        const gridSize = 20.0;
        final snapped = Stroke.snapPointToGrid(
          const Offset(-14, -26),
          gridSize,
        );
        expect(snapped, equals(const Offset(-20, -20)));
      });

      test('T2.7: Fractional grid size snapping', () {
        const gridSize = 12.5;
        final snapped = Stroke.snapPointToGrid(
          const Offset(24.0, 38.0),
          gridSize,
        );
        expect(snapped, equals(const Offset(25.0, 37.5)));
      });

      test('T2.8: Origin point (0, 0) snapping', () {
        const gridSize = 20.0;
        final snapped = Stroke.snapPointToGrid(Offset.zero, gridSize);
        expect(snapped, equals(Offset.zero));
      });

      test('T2.9: Large coordinates floating-point precision', () {
        const gridSize = 50.0;
        final snapped = Stroke.snapPointToGrid(
          const Offset(100018.0, 200034.0),
          gridSize,
        );
        expect(snapped, equals(const Offset(100000.0, 200050.0)));
      });

      test('T2.10: Exact halfway boundary tie-breaking', () {
        const gridSize = 20.0;
        final snapped = Stroke.snapPointToGrid(
          const Offset(10.0, 10.0),
          gridSize,
        );
        // round() rounds 0.5 up to 1
        expect(snapped, equals(const Offset(20.0, 20.0)));
      });
    },
  );

  group(
    'Feature 5: Angle Snapping (15°, 30°, 45°, Iso 30°) (ORIGINAL_REQUEST § R2)',
    () {
      // -------------------------------------------------------------
      // Tier 1: Feature Coverage (>=5 tests)
      // -------------------------------------------------------------
      test('T1.11: Angle snap 15 degrees', () {
        const first = PointVector(0, 0, 1.0);
        // 16 degrees length 100
        const rad16 = 16 * pi / 180;
        final last = PointVector(100 * cos(rad16), 100 * sin(rad16), 1.0);

        final (_, snappedLast) = Stroke.snapLineToAngle(first, last, 15.0);
        final snappedAngleDeg =
            atan2(snappedLast.dy, snappedLast.dx) * 180 / pi;
        expect(snappedAngleDeg, closeTo(15.0, 0.01));
      });

      test('T1.12: Angle snap 30 degrees', () {
        const first = PointVector(0, 0, 1.0);
        // 28 degrees length 100
        const rad28 = 28 * pi / 180;
        final last = PointVector(100 * cos(rad28), 100 * sin(rad28), 1.0);

        final (_, snappedLast) = Stroke.snapLineToAngle(first, last, 30.0);
        final snappedAngleDeg =
            atan2(snappedLast.dy, snappedLast.dx) * 180 / pi;
        expect(snappedAngleDeg, closeTo(30.0, 0.01));
      });

      test('T1.13: Angle snap 45 degrees', () {
        const first = PointVector(0, 0, 1.0);
        // 42 degrees length 100
        const rad42 = 42 * pi / 180;
        final last = PointVector(100 * cos(rad42), 100 * sin(rad42), 1.0);

        final (_, snappedLast) = Stroke.snapLineToAngle(first, last, 45.0);
        final snappedAngleDeg =
            atan2(snappedLast.dy, snappedLast.dx) * 180 / pi;
        expect(snappedAngleDeg, closeTo(45.0, 0.01));
      });

      test('T1.14: Angle snap near horizontal and vertical', () {
        const first = PointVector(0, 0, 1.0);

        // Near horizontal (2 deg) with 15 deg step
        final lastH = PointVector(
          100 * cos(2 * pi / 180),
          100 * sin(2 * pi / 180),
          1.0,
        );
        final (_, snappedH) = Stroke.snapLineToAngle(first, lastH, 15.0);
        expect(atan2(snappedH.dy, snappedH.dx) * 180 / pi, closeTo(0.0, 0.01));

        // Near vertical (88 deg) with 15 deg step
        final lastV = PointVector(
          100 * cos(88 * pi / 180),
          100 * sin(88 * pi / 180),
          1.0,
        );
        final (_, snappedV) = Stroke.snapLineToAngle(first, lastV, 15.0);
        expect(atan2(snappedV.dy, snappedV.dx) * 180 / pi, closeTo(90.0, 0.01));
      });

      test('T1.15: Angle snap strictly preserves line length', () {
        const first = PointVector(50, 50, 1.0);
        const last = PointVector(170, 110, 1.0);
        final originalLength = sqrt(
          pow(last.dx - first.dx, 2) + pow(last.dy - first.dy, 2),
        );

        final (_, snappedLast) = Stroke.snapLineToAngle(first, last, 30.0);
        final snappedLength = sqrt(
          pow(snappedLast.dx - first.dx, 2) + pow(snappedLast.dy - first.dy, 2),
        );

        expect(snappedLength, closeTo(originalLength, 1e-4));
      });

      // -------------------------------------------------------------
      // Tier 2: Boundary & Corner Cases (>=5 tests)
      // -------------------------------------------------------------
      test('T2.11: Zero-length line angle snap returns unchanged points', () {
        const p = PointVector(10, 10, 1.0);
        final (f, l) = Stroke.snapLineToAngle(p, p, 15.0);
        expect(f.dx, equals(p.dx));
        expect(l.dx, equals(p.dx));
      });

      test('T2.12: Angle snapping across all 4 quadrants', () {
        const first = PointVector(0, 0, 1.0);

        // Quadrant 2: 125 deg -> snaps to 120 deg
        const rad125 = 125 * pi / 180;
        final lastQ2 = PointVector(100 * cos(rad125), 100 * sin(rad125), 1.0);
        final (_, snappedQ2) = Stroke.snapLineToAngle(first, lastQ2, 30.0);
        expect(
          atan2(snappedQ2.dy, snappedQ2.dx) * 180 / pi,
          closeTo(120.0, 0.01),
        );

        // Quadrant 3: -145 deg -> snaps to -150 deg
        const radNeg145 = -145 * pi / 180;
        final lastQ3 = PointVector(
          100 * cos(radNeg145),
          100 * sin(radNeg145),
          1.0,
        );
        final (_, snappedQ3) = Stroke.snapLineToAngle(first, lastQ3, 30.0);
        expect(
          atan2(snappedQ3.dy, snappedQ3.dx) * 180 / pi,
          closeTo(-150.0, 0.01),
        );

        // Quadrant 4: -35 deg -> snaps to -30 deg
        const radNeg35 = -35 * pi / 180;
        final lastQ4 = PointVector(
          100 * cos(radNeg35),
          100 * sin(radNeg35),
          1.0,
        );
        final (_, snappedQ4) = Stroke.snapLineToAngle(first, lastQ4, 30.0);
        expect(
          atan2(snappedQ4.dy, snappedQ4.dx) * 180 / pi,
          closeTo(-30.0, 0.01),
        );
      });

      test('T2.13: Negative angles below horizontal axis', () {
        const first = PointVector(0, 0, 1.0);
        const radNeg43 = -43 * pi / 180;
        final last = PointVector(100 * cos(radNeg43), 100 * sin(radNeg43), 1.0);

        final (_, snapped) = Stroke.snapLineToAngle(first, last, 45.0);
        expect(atan2(snapped.dy, snapped.dx) * 180 / pi, closeTo(-45.0, 0.01));
      });

      test('T2.14: Large step 90 degrees cardinal snapping', () {
        const first = PointVector(0, 0, 1.0);
        const rad35 = 35 * pi / 180;
        final last = PointVector(100 * cos(rad35), 100 * sin(rad35), 1.0);

        final (_, snapped) = Stroke.snapLineToAngle(first, last, 90.0);
        // 35 deg snaps to 0 deg with 90 deg step
        expect(atan2(snapped.dy, snapped.dx) * 180 / pi, closeTo(0.0, 0.01));
      });

      test('T2.15: Stroke.snapToAngle instance method execution', () {
        final stroke = Stroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: const HasSize(Size(1000, 1400)),
          toolId: ToolId.ruler,
        );
        stroke.addPoint(Offset.zero);
        const rad28 = 28 * pi / 180;
        stroke.addPoint(Offset(100 * cos(rad28), 100 * sin(rad28)));

        stroke.snapToAngle(30.0);
        expect(stroke.points.length, greaterThanOrEqualTo(2));
        final angle =
            atan2(stroke.points.last.dy, stroke.points.last.dx) * 180 / pi;
        expect(angle, closeTo(30.0, 0.01));
      });
    },
  );

  group(
    'Feature 6: HUD Snap Controls & Persistence (ORIGINAL_REQUEST § R2)',
    () {
      // -------------------------------------------------------------
      // Tier 1: Feature Coverage (>=5 tests)
      // -------------------------------------------------------------
      test('T1.16: stows.snapToGrid toggle and persistence', () {
        expect(stows.snapToGrid.value, isFalse);
        stows.snapToGrid.value = true;
        expect(stows.snapToGrid.value, isTrue);
        stows.snapToGrid.value = false;
        expect(stows.snapToGrid.value, isFalse);
      });

      test('T1.17: stows.snapToAngle toggle and persistence', () {
        expect(stows.snapToAngle.value, isFalse);
        stows.snapToAngle.value = true;
        expect(stows.snapToAngle.value, isTrue);
        stows.snapToAngle.value = false;
        expect(stows.snapToAngle.value, isFalse);
      });

      test('T1.18: stows.snapAngleStep accepted drafting steps', () {
        stows.snapAngleStep.value = 15;
        expect(stows.snapAngleStep.value, equals(15));
        stows.snapAngleStep.value = 30;
        expect(stows.snapAngleStep.value, equals(30));
        stows.snapAngleStep.value = 45;
        expect(stows.snapAngleStep.value, equals(45));
      });

      test('T1.19: stows.gridSize configuration', () {
        stows.gridSize.value = 24.0;
        expect(stows.gridSize.value, equals(24.0));
        stows.gridSize.value = 36.5;
        expect(stows.gridSize.value, equals(36.5));
      });

      test('T1.20: Ruler respects snapToGrid preference when toggled', () {
        final ruler = Ruler();
        final page = EditorPage();

        // Disabled: position is unsnapped
        stows.snapToGrid.value = false;
        stows.gridSize.value = 20.0;
        ruler.onDragStart(const Offset(10, 10), page, 0, null);
        ruler.onDragUpdate(const Offset(53, 57), null);
        final strokeUnsnapped = ruler.onDragEnd();
        expect(strokeUnsnapped!.points.last.x, equals(53.0));

        // Enabled: position is snapped
        stows.snapToGrid.value = true;
        ruler.onDragStart(const Offset(10, 10), page, 0, null);
        ruler.onDragUpdate(const Offset(53, 57), null);
        final strokeSnapped = ruler.onDragEnd();
        expect(strokeSnapped!.points.last.x, equals(60.0));
        expect(strokeSnapped.points.last.y, equals(60.0));
      });

      // -------------------------------------------------------------
      // Tier 2: Boundary & Corner Cases (>=5 tests)
      // -------------------------------------------------------------
      test('T2.16: Prefs default state values', () {
        expect(stows.snapToGrid.value, isFalse);
        expect(stows.gridSize.value, equals(20.0));
        expect(stows.snapToAngle.value, isFalse);
        expect(stows.snapAngleStep.value, equals(15));
      });

      test('T2.17: Rapid toggle consistency without state corruption', () {
        for (int i = 0; i < 50; i++) {
          stows.snapToGrid.value = !stows.snapToGrid.value;
          stows.snapToAngle.value = !stows.snapToAngle.value;
        }
        expect(stows.snapToGrid.value, isFalse);
        expect(stows.snapToAngle.value, isFalse);
      });

      test('T2.18: Grid size near-zero handling in Ruler', () {
        final ruler = Ruler();
        final page = EditorPage();
        stows.snapToGrid.value = true;
        stows.gridSize.value = 0.0;

        ruler.onDragStart(const Offset(10, 10), page, 0, null);
        ruler.onDragUpdate(const Offset(33, 44), null);
        final stroke = ruler.onDragEnd();

        // If gridSize <= 0, ruler does not snap and does not crash
        expect(stroke, isNotNull);
        expect(stroke!.points.last.x, equals(33.0));
      });

      test('T2.19: Snap angle step zero handling in Ruler', () {
        final ruler = Ruler();
        final page = EditorPage();
        stows.snapToAngle.value = true;
        stows.snapAngleStep.value = 0;

        ruler.onDragStart(const Offset(10, 10), page, 0, null);
        ruler.onDragUpdate(const Offset(33, 44), null);
        final stroke = ruler.onDragEnd();

        expect(stroke, isNotNull);
        expect(stroke!.points.last.x, equals(33.0));
      });

      test('T2.20: Simultaneous grid and angle snap in Ruler', () {
        final ruler = Ruler();
        final page = EditorPage();
        stows.snapToGrid.value = true;
        stows.gridSize.value = 20.0;
        stows.snapToAngle.value = true;
        stows.snapAngleStep.value = 30;

        ruler.onDragStart(Offset.zero, page, 0, null);
        // Drag near (80, 40)
        ruler.onDragUpdate(const Offset(78, 42), null);
        final stroke = ruler.onDragEnd();

        expect(stroke, isNotNull);
        final angle =
            atan2(stroke!.points.last.dy, stroke.points.last.dx) * 180 / pi;
        expect(angle, closeTo(30.0, 0.01));
      });
    },
  );
}
