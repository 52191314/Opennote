/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/circle_to_select_detector.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('Goodnotes Circle-to-Select Detector Tests', () {
    test('Triggers circle-to-select when a closed loop is held', () async {
      bool detected = false;
      Path? detectedPath;

      final detector = CircleToSelectDetector(
        holdDuration: const Duration(milliseconds: 50),
        onCircleDetected: (path) {
          detected = true;
          detectedPath = path;
        },
      );

      // Draw a circle of radius 40 around (100, 100) with 20 points
      const center = Offset(100, 100);
      const radius = 40.0;
      final start = center + const Offset(radius, 0);
      detector.start(start);

      for (int i = 1; i <= 20; i++) {
        final angle = (i / 20.0) * 2 * pi;
        final pt = center + Offset(cos(angle) * radius, sin(angle) * radius);
        detector.update(pt);
      }

      // Wait for the hold duration
      await Future.delayed(const Duration(milliseconds: 80));

      expect(detected, isTrue);
      expect(detectedPath, isNotNull);
      expect(detectedPath!.getBounds().width, closeTo(80, 2));
      expect(detectedPath!.getBounds().height, closeTo(80, 2));

      detector.dispose();
    });

    test('Does not trigger when stroke is an open line', () async {
      bool detected = false;

      final detector = CircleToSelectDetector(
        holdDuration: const Duration(milliseconds: 50),
        onCircleDetected: (_) {
          detected = true;
        },
      );

      detector.start(Offset.zero);
      for (int i = 1; i <= 15; i++) {
        detector.update(Offset(i * 10.0, i * 10.0));
      }

      await Future.delayed(const Duration(milliseconds: 80));
      expect(detected, isFalse);

      detector.dispose();
    });
  });

  group('Goodnotes Eraser Highlighter-Only Tests', () {
    test(
      'Erases only highlighters when eraserEraseHighlighterOnly is true',
      () {
        final eraser = Eraser(size: 15);
        const pos = Offset(50, 50);

        final penStroke = Stroke(
          color: const Color(0xFF000000),
          pressureEnabled: false,
          options: StrokeOptions(size: 2),
          pageIndex: 0,
          page: const HasSize(Size(100, 100)),
          toolId: .ballpointPen,
        )..addPoint(pos);

        final highlighterStroke = Stroke(
          color: const Color(0xFFFFF176),
          pressureEnabled: false,
          options: StrokeOptions(size: 10),
          pageIndex: 0,
          page: const HasSize(Size(100, 100)),
          toolId: ToolId.highlighter,
        )..addPoint(pos);

        final allStrokes = <Stroke>[penStroke, highlighterStroke];

        // Test with highlighter only = false
        stows.eraserEraseHighlighterOnly.value = false;
        final erasedBoth = eraser.checkForOverlappingStrokes(pos, allStrokes);
        expect(erasedBoth.length, equals(2));
        eraser.onDragEnd();

        // Test with highlighter only = true
        stows.eraserEraseHighlighterOnly.value = true;
        final erasedHighlighterOnly = eraser.checkForOverlappingStrokes(
          pos,
          allStrokes,
        );
        expect(erasedHighlighterOnly.length, equals(1));
        expect(erasedHighlighterOnly.first.toolId, equals(ToolId.highlighter));
        eraser.onDragEnd();

        // Reset pref
        stows.eraserEraseHighlighterOnly.value = false;
      },
    );
  });

  group('Goodnotes Prefs Default Values', () {
    test('Default quick colors for pen are Black, Blue, and Red', () {
      final penColors = stows.quickColorsPen.value;
      expect(penColors.length, equals(3));
      expect(penColors[0], equals(0xFF000000)); // Black
      expect(penColors[1], equals(0xFF1976D2)); // Blue
      expect(penColors[2], equals(0xFFD32F2F)); // Red
    });

    test(
      'Default quick colors for highlighter are Yellow, Green, and Pink',
      () {
        final highlighterColors = stows.quickColorsHighlighter.value;
        expect(highlighterColors.length, equals(3));
        expect(highlighterColors[0], equals(0xFFFFF176)); // Yellow
        expect(highlighterColors[1], equals(0xFFA5D6A7)); // Green
        expect(highlighterColors[2], equals(0xFFF48FB1)); // Pink
      },
    );

    test(
      'Circle-to-select, two-finger tap undo, and scribble to erase are enabled by default',
      () {
        expect(stows.circleToSelect.value, isTrue);
        expect(stows.twoFingerTapUndo.value, isTrue);
        expect(stows.scribbleToErase.value, isTrue);
      },
    );
  });
}
