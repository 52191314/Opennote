/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/_canvas_background_painter.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:sbn/canvas_background_pattern.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('Infinite Canvas Core Tests', () {
    test('EditorCoreInfo serializes and deserializes isInfiniteCanvas', () {
      final coreInfo = EditorCoreInfo(filePath: '/test_note');
      expect(coreInfo.isInfiniteCanvas, isFalse);

      coreInfo.isInfiniteCanvas = true;
      final (json, _) = coreInfo.toJson();
      expect(json['ic'], isTrue);

      final loaded = EditorCoreInfo.fromJson(
        json,
        filePath: '/test_note',
        onlyFirstPage: false,
      );
      expect(loaded.isInfiniteCanvas, isTrue);
    });

    test(
      'EditorCoreInfo defaults isInfiniteCanvas to false when omitted from json',
      () {
        final json = <String, dynamic>{
          'v': 19,
          'ni': 0,
          'p': 'none',
          'l': 30,
          'lt': 3,
          'z': <dynamic>[],
          'c': 0,
        };

        final loaded = EditorCoreInfo.fromJson(
          json,
          filePath: '/test_note',
          onlyFirstPage: false,
        );
        expect(loaded.isInfiniteCanvas, isFalse);
      },
    );

    test('EditorCoreInfo respects stows.defaultInfiniteCanvas', () {
      stows.defaultInfiniteCanvas.value = true;
      final coreInfo = EditorCoreInfo(filePath: '/test_infinite');
      expect(coreInfo.isInfiniteCanvas, isTrue);

      stows.defaultInfiniteCanvas.value = false;
      final coreInfoPaged = EditorCoreInfo(filePath: '/test_paged');
      expect(coreInfoPaged.isInfiniteCanvas, isFalse);
    });

    test(
      'CanvasBackgroundPainter tiles pattern across negative and positive 2D bounds',
      () {
        const bounds = Rect.fromLTRB(-200, -100, 300, 200);
        const lineHeight = 50;

        final gridElements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.grid,
          size: const Size(1000, 1400),
          lineHeight: lineHeight,
          bounds: bounds,
        ).toList();

        expect(gridElements, isNotEmpty);
        // Horizontal lines should span from bounds.left to bounds.right
        final horizontalLines = gridElements.where(
          (e) =>
              e.isLine && e.start.dx == bounds.left && e.end.dx == bounds.right,
        );
        expect(horizontalLines, isNotEmpty);
        // Vertical lines should span from bounds.top to bounds.bottom
        final verticalLines = gridElements.where(
          (e) =>
              e.isLine && e.start.dy == bounds.top && e.end.dy == bounds.bottom,
        );
        expect(verticalLines, isNotEmpty);

        // Verify negative coordinates exist in horizontal lines
        expect(horizontalLines.any((e) => e.start.dy < 0), isTrue);
        // Verify positive coordinates exist
        expect(horizontalLines.any((e) => e.start.dy > 0), isTrue);
      },
    );

    test('CanvasBackgroundPainter tiles dots pattern across 2D bounds', () {
      const bounds = Rect.fromLTRB(-100, -100, 100, 100);
      const lineHeight = 50;

      final dotElements = CanvasBackgroundPainter.getPatternElements(
        pattern: CanvasBackgroundPattern.dots,
        size: const Size(1000, 1400),
        lineHeight: lineHeight,
        bounds: bounds,
      ).toList();

      expect(dotElements, isNotEmpty);
      expect(dotElements.every((e) => !e.isLine), isTrue);
      // Verify dots cover both negative and positive coordinates
      expect(dotElements.any((e) => e.start.dx < 0 && e.start.dy < 0), isTrue);
      expect(dotElements.any((e) => e.start.dx > 0 && e.start.dy > 0), isTrue);
    });

    test(
      'CanvasBackgroundPainter shouldRepaint returns true when isInfiniteCanvas is true',
      () {
        const painter = CanvasBackgroundPainter(
          invert: false,
          backgroundColor: Color(0xFFFFFFFF),
          lineHeight: 30,
          lineThickness: 2,
          isInfiniteCanvas: true,
        );
        const oldPainter = CanvasBackgroundPainter(
          invert: false,
          backgroundColor: Color(0xFFFFFFFF),
          lineHeight: 30,
          lineThickness: 2,
          isInfiniteCanvas: true,
        );
        expect(painter.shouldRepaint(oldPainter), isTrue);
      },
    );

    test('CanvasBackgroundPainter does not freeze with unclipped canvas bounds', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

      // Verify unclipped canvas sentinel
      final clip = canvas.getLocalClipBounds();
      expect(clip.width, greaterThan(1e8));

      for (final pattern in [
        CanvasBackgroundPattern.grid,
        CanvasBackgroundPattern.dots,
        CanvasBackgroundPattern.lined,
      ]) {
        final painter = CanvasBackgroundPainter(
          invert: false,
          backgroundColor: const Color(0xFFFFFFFF),
          backgroundPattern: pattern,
          lineHeight: 30,
          lineThickness: 2,
          isInfiniteCanvas: true,
        );

        final stopwatch = Stopwatch()..start();
        painter.paint(canvas, const Size(1000, 1400));
        stopwatch.stop();

        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(100),
          reason: 'Pattern $pattern should render safely in < 100ms without freezing',
        );
      }
    });

    test('CanvasBackgroundPainter.getPatternElements safely guards against invalid lineHeight and extreme bounds', () {
      // Guard against zero / negative lineHeight
      final zeroHeightElements = CanvasBackgroundPainter.getPatternElements(
        pattern: CanvasBackgroundPattern.grid,
        size: const Size(1000, 1400),
        lineHeight: 0,
      ).toList();
      expect(zeroHeightElements, isEmpty);

      // Guard against runaway bounds sentinel
      const sentinelBounds = Rect.largest;
      final sentinelElements = CanvasBackgroundPainter.getPatternElements(
        pattern: CanvasBackgroundPattern.dots,
        size: const Size(1000, 1400),
        lineHeight: 30,
        bounds: sentinelBounds,
      ).toList();
      expect(sentinelElements, isEmpty);
    });
  });
}
