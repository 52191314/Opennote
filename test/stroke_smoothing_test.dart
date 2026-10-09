/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/shape_pen.dart';
import 'package:sbn/tool_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('Stroke Smoothing and Snapping Tests', () {
    setUp(() {
      stows.snapToGrid.value = true;
      stows.gridSize.value = 50.0;
    });

    test('Non-ShapePen does NOT quantize intermediate drag points to grid', () {
      final page = EditorPage(size: const Size(1000, 1000));
      final pen = Pen.fountainPen();

      // Start drag at arbitrary point (13.7, 24.3)
      pen.onDragStart(const Offset(13.7, 24.3), page, 0, 0.5);

      // intermediate point not on 50px grid
      pen.onDragUpdate(const Offset(17.4, 29.8), 0.5);

      final currentStroke = Pen.currentStroke;
      expect(currentStroke, isNotNull);
      final lastPoint = currentStroke!.points.last;
      // Must preserve the precise coordinate rather than snapping to (0, 50)
      expect(lastPoint.x, closeTo(17.4, 0.001));
      expect(lastPoint.y, closeTo(29.8, 0.001));

      pen.onDragEnd();
    });

    test(
      'ShapePen DOES quantize intermediate drag points when snapToGrid is enabled',
      () {
        final page = EditorPage(size: const Size(1000, 1000));
        final shapePen = ShapePen();

        shapePen.onDragStart(const Offset(10, 10), page, 0, null);
        shapePen.onDragUpdate(const Offset(48, 52), null);

        final currentStroke = Pen.currentStroke;
        expect(currentStroke, isNotNull);
        final lastPoint = currentStroke!.points.last;
        // 48 and 52 snap to 50 on a 50px grid
        expect(lastPoint.x, equals(50.0));
        expect(lastPoint.y, equals(50.0));

        shapePen.onDragEnd();
      },
    );

    test(
      'getPath uses smooth quadratic beziers for in-flight uncompleted strokes with >= 3 points',
      () {
        final testPage = EditorPage(size: const Size(500, 500));
        final stroke = Stroke(
          color: const Color(0xFF000000),
          pressureEnabled: false,
          options: StrokeOptions(size: 8, isComplete: false),
          pageIndex: 0,
          page: testPage,
          toolId: ToolId.ballpointPen,
        );

        stroke.addPoint(const Offset(10, 10));
        stroke.addPoint(const Offset(50, 80));
        stroke.addPoint(const Offset(90, 20));
        stroke.addPoint(const Offset(140, 100));

        final path = stroke.highQualityPath;
        // Path must be generated and valid
        expect(path, isNotNull);
        expect(path.getBounds().isEmpty, isFalse);
      },
    );

    test('lowQualityPath uses smooth: true', () {
      final testPage = EditorPage(size: const Size(500, 500));
      final stroke = Stroke(
        color: const Color(0xFF000000),
        pressureEnabled: false,
        options: StrokeOptions(size: 8, isComplete: true),
        pageIndex: 0,
        page: testPage,
        toolId: ToolId.ballpointPen,
      );

      for (double i = 0; i <= 100; i += 5) {
        stroke.addPoint(Offset(i, i * i / 100));
      }

      final lowPath = stroke.lowQualityPath;
      expect(lowPath, isNotNull);
      expect(lowPath.getBounds().isEmpty, isFalse);
    });
  });
}
