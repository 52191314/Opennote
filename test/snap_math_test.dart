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
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:sbn/canvas_background_pattern.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FlavorConfig.setup();
  });

  setUp(() {
    stows.snapToGrid.value = false;
    stows.gridSize.value = 20.0;
    stows.snapToAngle.value = false;
    stows.snapAngleStep.value = 15;
  });

  group('Isometric Grid Vertex Concurrence Math', () {
    test(
      'Vertical and diagonal line families concur at identical lattice vertices',
      () {
        const double l = 40.0;
        final double dx = l * (sqrt(3) / 2);
        final double tan30 = 1 / sqrt(3);

        // Verify for multiple column and row combinations
        for (int col = 0; col < 10; col++) {
          for (int row = 0; row < 10; row++) {
            final xExpected = col * dx;
            final yShift = (col % 2 != 0) ? 0.5 * l : 0.0;
            final yExpected = row * l + yShift;

            // The +30° line passing through this vertex has intercept b = y - tan30 * x
            final b = yExpected - tan30 * xExpected;
            // The -30° line passing through this vertex has intercept c = y + tan30 * x
            final c = yExpected + tan30 * xExpected;

            // In our grid math, b = m * l and c = k * l for integers m and k
            final m = (b / l).round();
            final k = (c / l).round();
            expect((b - m * l).abs(), lessThan(1e-4));
            expect((c - k * l).abs(), lessThan(1e-4));

            // The intersection of y = tan30 * x + m * l and y = -tan30 * x + k * l
            final xIntersect = (k - m) * l * (sqrt(3) / 2);
            final yIntersect = (m + (k - m) / 2) * l;

            expect(xIntersect, closeTo(xExpected, 1e-4));
            expect(yIntersect, closeTo(yExpected, 1e-4));
            expect(k - m, equals(col));
          }
        }
      },
    );

    test(
      'CanvasBackgroundPainter isometric pattern elements stay within bounds',
      () {
        const size = Size(800, 1200);
        const lineHeight = 30;

        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.isometric,
          size: size,
          lineHeight: lineHeight,
        ).toList();

        expect(elements, isNotEmpty);
        for (final e in elements) {
          expect(e.start.dx, inInclusiveRange(0.0, size.width));
          expect(e.start.dy, inInclusiveRange(0.0, size.height));
          expect(e.end.dx, inInclusiveRange(0.0, size.width));
          expect(e.end.dy, inInclusiveRange(0.0, size.height));
        }
      },
    );

    test(
      'CanvasBackgroundPainter isometric vertical lines have spacing L * sqrt(3) / 2',
      () {
        const size = Size(500, 500);
        const lineHeight = 20;
        final expectedDx = lineHeight * (sqrt(3) / 2);

        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.isometric,
          size: size,
          lineHeight: lineHeight,
        ).toList();

        final verticalLines =
            elements
                .where((e) => e.isLine && (e.start.dx - e.end.dx).abs() < 1e-4)
                .map((e) => e.start.dx)
                .toList()
              ..sort();

        expect(verticalLines.length, greaterThan(2));
        for (int i = 0; i < verticalLines.length - 1; i++) {
          final diff = verticalLines[i + 1] - verticalLines[i];
          expect(diff, closeTo(expectedDx, 1e-4));
        }
      },
    );

    test(
      'CanvasBackgroundPainter isometric diagonal lines have slope 1/√3',
      () {
        const size = Size(600, 600);
        const lineHeight = 25;
        final expectedTan30 = 1 / sqrt(3);

        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.isometric,
          size: size,
          lineHeight: lineHeight,
        ).toList();

        final diagonals = elements
            .where((e) => e.isLine && (e.start.dx - e.end.dx).abs() > 1e-4)
            .toList();

        expect(diagonals, isNotEmpty);
        for (final diag in diagonals) {
          final dx = diag.end.dx - diag.start.dx;
          final dy = diag.end.dy - diag.start.dy;
          final slope = (dy / dx).abs();
          expect(slope, closeTo(expectedTan30, 0.02));
        }
      },
    );
  });

  group('Isometric Nearest Vertex Snapping', () {
    test('Exact isometric vertices snap to themselves', () {
      const double l = 40.0;
      final double dx = l * (sqrt(3) / 2);

      for (int col = 0; col < 6; col++) {
        for (int row = 0; row < 6; row++) {
          final yShift = (col % 2 != 0) ? 0.5 * l : 0.0;
          final vertex = Offset(col * dx, row * l + yShift);
          final snapped = Stroke.snapPointToIsometricGrid(vertex, l);

          expect(snapped.dx, closeTo(vertex.dx, 1e-4));
          expect(snapped.dy, closeTo(vertex.dy, 1e-4));
        }
      }
    });

    test('Perturbed points snap to the closest isometric vertex', () {
      const double l = 50.0;
      final double dx = l * (sqrt(3) / 2);

      // Vertex at col 2, row 3: (2 * dx, 3 * l) = (86.6025, 150.0)
      final targetVertex = Offset(2 * dx, 3 * l);
      final perturbedPoint = Offset(
        targetVertex.dx + 2.5,
        targetVertex.dy - 3.0,
      );

      final snapped = Stroke.snapPointToIsometricGrid(perturbedPoint, l);
      expect(snapped.dx, closeTo(targetVertex.dx, 1e-4));
      expect(snapped.dy, closeTo(targetVertex.dy, 1e-4));
    });

    test('Alternating odd column y-shift (0.5 * L) is respected', () {
      const double l = 30.0;
      final double dx = l * (sqrt(3) / 2);

      // Column 1 is odd, so vertices are at y = (row + 0.5) * L
      final oddColVertex = Offset(1 * dx, 2.5 * l);
      final nearOddCol = Offset(1 * dx + 1.0, 2.5 * l - 1.2);

      final snapped = Stroke.snapPointToIsometricGrid(nearOddCol, l);
      expect(snapped.dx, closeTo(oddColVertex.dx, 1e-4));
      expect(snapped.dy, closeTo(oddColVertex.dy, 1e-4));
    });

    test('Negative coordinates snap correctly to isometric grid', () {
      const double l = 20.0;
      final double dx = l * (sqrt(3) / 2);

      final target = Offset(-2 * dx, -3 * l);
      final nearTarget = Offset(target.dx - 1.0, target.dy + 1.0);

      final snapped = Stroke.snapPointToIsometricGrid(nearTarget, l);
      expect(snapped.dx, closeTo(target.dx, 1e-4));
      expect(snapped.dy, closeTo(target.dy, 1e-4));
    });

    test('Invalid or zero line height returns point unchanged', () {
      const point = Offset(37.5, 42.1);
      expect(Stroke.snapPointToIsometricGrid(point, 0.0), equals(point));
      expect(Stroke.snapPointToIsometricGrid(point, -10.0), equals(point));
    });
  });

  group('Angle Snapping (15°, 30°, 45°, and Iso 30°)', () {
    test('Standard angle snap 15 degrees', () {
      const first = PointVector(0, 0, 1.0);
      const rad17 = 17 * pi / 180;
      final last = PointVector(100 * cos(rad17), 100 * sin(rad17), 1.0);

      final (_, snapped) = Stroke.snapLineToAngle(first, last, 15.0);
      final angleDeg = atan2(snapped.dy, snapped.dx) * 180 / pi;
      expect(angleDeg, closeTo(15.0, 1e-4));
    });

    test('Standard angle snap 30 degrees', () {
      const first = PointVector(0, 0, 1.0);
      const rad34 = 34 * pi / 180;
      final last = PointVector(100 * cos(rad34), 100 * sin(rad34), 1.0);

      final (_, snapped) = Stroke.snapLineToAngle(first, last, 30.0);
      final angleDeg = atan2(snapped.dy, snapped.dx) * 180 / pi;
      expect(angleDeg, closeTo(30.0, 1e-4));
    });

    test('Standard angle snap 45 degrees', () {
      const first = PointVector(0, 0, 1.0);
      const rad43 = 43 * pi / 180;
      final last = PointVector(100 * cos(rad43), 100 * sin(rad43), 1.0);

      final (_, snapped) = Stroke.snapLineToAngle(first, last, 45.0);
      final angleDeg = atan2(snapped.dy, snapped.dx) * 180 / pi;
      expect(angleDeg, closeTo(45.0, 1e-4));
    });

    test('3-axis isometric 30° snap constrains to ±30°, ±90°, ±150°', () {
      const first = PointVector(0, 0, 1.0);

      final testCases = <double, double>{
        // input degrees : expected snapped degrees
        25.0: 30.0,
        35.0: 30.0,
        85.0: 90.0,
        95.0: 90.0,
        145.0: 150.0,
        155.0: 150.0,
        -25.0: -30.0,
        -35.0: -30.0,
        -85.0: -90.0,
        -95.0: -90.0,
        -145.0: -150.0,
        -155.0: -150.0,
        // Near horizontal (5°): does NOT snap to 0° in 3-axis isometric; snaps to 30°
        5.0: 30.0,
        -5.0: -30.0,
      };

      for (final entry in testCases.entries) {
        final rad = entry.key * pi / 180;
        final last = PointVector(100 * cos(rad), 100 * sin(rad), 1.0);

        // Test with isIsometric: true
        final (_, snappedIso) = Stroke.snapLineToAngle(
          first,
          last,
          30.0,
          isIsometric: true,
        );
        final angleIso = atan2(snappedIso.dy, snappedIso.dx) * 180 / pi;
        expect(
          angleIso,
          closeTo(entry.value, 0.02),
          reason:
              'Input ${entry.key}° should snap to ${entry.value}° in Iso 30° mode',
        );

        // Test with stepDegrees = -30 (Stows.snapAngleStepIso30)
        final (_, snappedConst) = Stroke.snapLineToAngle(first, last, -30.0);
        final angleConst = atan2(snappedConst.dy, snappedConst.dx) * 180 / pi;
        expect(angleConst, closeTo(entry.value, 0.02));
      }
    });

    test('Angle snap strictly preserves line length', () {
      const first = PointVector(12.3, 45.6, 1.0);
      const last = PointVector(150.7, 98.4, 1.0);
      final originalLen = sqrt(
        pow(last.dx - first.dx, 2) + pow(last.dy - first.dy, 2),
      );

      final (_, snapped) = Stroke.snapLineToAngle(
        first,
        last,
        30.0,
        isIsometric: true,
      );
      final snappedLen = sqrt(
        pow(snapped.dx - first.dx, 2) + pow(snapped.dy - first.dy, 2),
      );
      expect(snappedLen, closeTo(originalLen, 1e-4));
    });
  });

  group('Ruler Tool Snapping Integration', () {
    test('Ruler onDragStart snaps _dragStart when snapToGrid is enabled', () {
      final ruler = Ruler();
      final page = EditorPage();

      stows.snapToGrid.value = true;
      stows.gridSize.value = 25.0;

      // Start drag at (12, 18), update to (53, 72)
      ruler.onDragStart(const Offset(12, 18), page, 0, null);
      ruler.onDragUpdate(const Offset(53, 72), null);
      final stroke = ruler.onDragEnd();

      expect(stroke, isNotNull);
      // First point should be snapped to (0, 25)
      expect(stroke!.points.first.x, equals(0.0));
      expect(stroke.points.first.y, equals(25.0));
      // Last point snapped to (50, 75)
      expect(stroke.points.last.x, equals(50.0));
      expect(stroke.points.last.y, equals(75.0));
    });

    test(
      'Ruler start and end points remain unsnapped when snapToGrid is false',
      () {
        final ruler = Ruler();
        final page = EditorPage();

        stows.snapToGrid.value = false;
        stows.gridSize.value = 20.0;

        ruler.onDragStart(const Offset(12.3, 18.7), page, 0, null);
        ruler.onDragUpdate(const Offset(53.4, 72.8), null);
        final stroke = ruler.onDragEnd();

        expect(stroke, isNotNull);
        expect(stroke!.points.first.x, equals(12.3));
        expect(stroke.points.first.y, equals(18.7));
        expect(stroke.points.last.x, equals(53.4));
        expect(stroke.points.last.y, equals(72.8));
      },
    );

    test(
      'Ruler snaps to page.lineHeight instead of stows.gridSize when available',
      () {
        final ruler = Ruler();
        final page = EditorPage();
        page.lineHeight = 32;

        stows.snapToGrid.value = true;
        stows.gridSize.value =
            20.0; // Stows default, should be overridden by 32

        ruler.onDragStart(const Offset(14, 30), page, 0, null);
        ruler.onDragUpdate(const Offset(70, 95), null);
        final stroke = ruler.onDragEnd();

        expect(stroke, isNotNull);
        // Snapped to 32 px module:
        // Start (14, 30) -> (0, 32)
        expect(stroke!.points.first.x, equals(0.0));
        expect(stroke.points.first.y, equals(32.0));
        // End (70, 95) -> (64, 96)
        expect(stroke.points.last.x, equals(64.0));
        expect(stroke.points.last.y, equals(96.0));
      },
    );

    test('Ruler on isometric page snaps to triangular isometric lattice', () {
      final ruler = Ruler();
      final page = EditorPage();
      page.backgroundPattern = CanvasBackgroundPattern.isometric;
      page.lineHeight = 40;

      stows.snapToGrid.value = true;

      final double dx = 40.0 * (sqrt(3) / 2); // ~34.6410

      // Drag near vertex (2 * dx, 3 * 40) = (69.282, 120.0)
      ruler.onDragStart(const Offset(71.0, 118.0), page, 0, null);
      // Drag near vertex (4 * dx, 5 * 40) = (138.564, 200.0)
      ruler.onDragUpdate(const Offset(140.0, 202.0), null);
      final stroke = ruler.onDragEnd();

      expect(stroke, isNotNull);
      expect(stroke!.points.first.x, closeTo(2 * dx, 1e-4));
      expect(stroke.points.first.y, closeTo(120.0, 1e-4));
      expect(stroke.points.last.x, closeTo(4 * dx, 1e-4));
      expect(stroke.points.last.y, closeTo(200.0, 1e-4));
    });

    test('Ruler simultaneous isometric grid and 30° angle snap', () {
      final ruler = Ruler();
      final page = EditorPage();
      page.backgroundPattern = CanvasBackgroundPattern.isometric;
      page.lineHeight = 30;

      stows.snapToGrid.value = true;
      stows.snapToAngle.value = true;
      stows.snapAngleStep.value = 30;

      ruler.onDragStart(Offset.zero, page, 0, null);
      // Drag near 30°
      const rad28 = 28 * pi / 180;
      ruler.onDragUpdate(Offset(100 * cos(rad28), 100 * sin(rad28)), null);
      final stroke = ruler.onDragEnd();

      expect(stroke, isNotNull);
      final angle =
          atan2(stroke!.points.last.dy, stroke.points.last.dx) * 180 / pi;
      expect(angle, closeTo(30.0, 0.02));
    });
  });

  group('Pen Tool Grid Snap Line Height Coupling', () {
    test('Pen respects page line height when snapToGrid is enabled', () {
      final pen = Pen(
        name: 'Pen',
        sizeMin: 1,
        sizeMax: 10,
        sizeStep: 1,
        icon: Icons.edit,
        options: StrokeOptions(size: 2.0),
        pressureEnabled: false,
        color: Colors.black,
        toolId: .shapePen,
      );
      final page = EditorPage();
      page.lineHeight = 25;

      stows.snapToGrid.value = true;
      stows.gridSize.value = 10.0;

      pen.onDragStart(const Offset(12, 13), page, 0, null);
      pen.onDragUpdate(const Offset(38, 52), null);
      final stroke = pen.onDragEnd();

      expect(stroke, isNotNull);
      // Points should snap to multiples of 25 (page.lineHeight)
      expect(stroke!.points.first.x, equals(0.0));
      expect(stroke.points.first.y, equals(25.0));
      expect(stroke.points.last.x, equals(50.0));
      expect(stroke.points.last.y, equals(50.0));
    });
  });

  group('HUD Preferences and Step Cycling', () {
    test('Angle step cycling through 15, 30, 45, Iso 30', () {
      stows.snapAngleStep.value = 15;
      expect(stows.snapAngleStep.value, equals(15));

      // Simulate tapping HUD angle step button
      int cycle(int cur) {
        if (cur == 15) return 30;
        if (cur == 30) return 45;
        if (cur == 45) return Stows.snapAngleStepIso30;
        return 15;
      }

      stows.snapAngleStep.value = cycle(stows.snapAngleStep.value);
      expect(stows.snapAngleStep.value, equals(30));

      stows.snapAngleStep.value = cycle(stows.snapAngleStep.value);
      expect(stows.snapAngleStep.value, equals(45));

      stows.snapAngleStep.value = cycle(stows.snapAngleStep.value);
      expect(stows.snapAngleStep.value, equals(Stows.snapAngleStepIso30));

      stows.snapAngleStep.value = cycle(stows.snapAngleStep.value);
      expect(stows.snapAngleStep.value, equals(15));
    });
  });
}
