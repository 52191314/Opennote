/// 🤖 Generated wholely or partially with Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Modified with Claude Code (Claude Sonnet 5.5)
library;

import 'dart:math';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/scribble_detector.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

/// Screen-space points of a pen going back and forth [passes] times.
///
/// With [horizontal], every pass runs along its own row [spacing] below the
/// last, like a scribble. Otherwise the passes go up and down while
/// advancing [spacing] sideways, like writing a row of narrow letters.
List<Offset> _zigzag({
  required double strokeLength,
  required double spacing,
  required int passes,
  required double step,
  bool horizontal = false,
}) {
  final points = <Offset>[];
  final stepsPerPass = (strokeLength / step).round();
  for (int pass = 0; pass < passes; pass++) {
    final forward = pass.isEven;
    for (int i = 0; i <= stepsPerPass; i++) {
      final along = (forward ? i : stepsPerPass - i) * step;
      final progress = i / stepsPerPass;
      points.add(
        horizontal
            ? Offset(100 + along, 100 + pass * spacing)
            : Offset(100 + (pass + progress) * spacing, 100 + along),
      );
    }
  }
  return points;
}

/// Screen-space points of cursive handwriting that loops back on itself,
/// like a row of the letter l.
List<Offset> _cursiveLoops({required int loops}) {
  Offset at(double t) => Offset(3 * t - 9 * sin(t), 14 * cos(t));

  final points = [at(0)];
  const samples = 4000;
  for (int i = 1; i <= samples; i++) {
    final point = at(2 * pi * loops * i / samples);
    if ((point - points.last).distance >= 2.5) points.add(point);
  }
  return points;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('ScribbleDetector Gesture Tests', () {
    test('Horizontal scribble over 60px is detected as erasing', () {
      final detector = ScribbleDetector();
      detector.start(const Offset(100, 100));

      final points = <Offset>[];
      for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 100));
      for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 103));
      for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 106));
      for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 109));

      for (final pt in points) {
        detector.update(pt, [], 2.0);
      }

      expect(detector.state, ScribbleState.erasing);
    });

    test('Vertical scribble over 80px is detected as erasing', () {
      final detector = ScribbleDetector();
      detector.start(const Offset(100, 100));

      final points = <Offset>[];
      for (double y = 105; y <= 180; y += 5) points.add(Offset(100, y));
      for (double y = 175; y >= 100; y -= 5) points.add(Offset(103, y));
      for (double y = 105; y <= 180; y += 5) points.add(Offset(106, y));
      for (double y = 175; y >= 100; y -= 5) points.add(Offset(109, y));

      for (final pt in points) {
        detector.update(pt, [], 2.0);
      }

      expect(detector.state, ScribbleState.erasing);
    });

    test('Diagonal scribble over 70px is detected as erasing', () {
      final detector = ScribbleDetector();
      detector.start(const Offset(100, 100));

      final points = <Offset>[];
      for (double d = 5; d <= 70; d += 5) points.add(Offset(100 + d, 100 + d));
      for (double d = 65; d >= 0; d -= 5) points.add(Offset(100 + d, 103 + d));
      for (double d = 5; d <= 70; d += 5) points.add(Offset(100 + d, 106 + d));
      for (double d = 65; d >= 0; d -= 5) points.add(Offset(100 + d, 109 + d));

      for (final pt in points) {
        detector.update(pt, [], 2.0);
      }

      expect(detector.state, ScribbleState.erasing);
    });

    test('Handwriting letter "w" is NOT classified as scribble', () {
      final detector = ScribbleDetector();
      detector.start(Offset.zero);

      final points = <Offset>[];
      for (int i = 1; i <= 10; i++) points.add(Offset(i * 1.5, i * 5.0));
      for (int i = 1; i <= 10; i++)
        points.add(Offset(15 + i * 1.5, 50 - i * 3.5));
      for (int i = 1; i <= 10; i++)
        points.add(Offset(30 + i * 1.5, 15 + i * 3.5));
      for (int i = 1; i <= 10; i++)
        points.add(Offset(45 + i * 1.5, 50 - i * 5.0));

      for (final pt in points) {
        detector.update(pt, [], 2.0);
      }

      expect(detector.state, ScribbleState.undetermined);
    });

    test('Handwriting letter "m" is NOT classified as scribble', () {
      final detector = ScribbleDetector();
      detector.start(const Offset(0, 50));

      final points = <Offset>[];
      for (int i = 1; i <= 10; i++) points.add(Offset(i * 1.0, 50 - i * 4.0));
      for (int i = 1; i <= 10; i++)
        points.add(Offset(10 + i * 1.0, 10 + i * 4.0));
      for (int i = 1; i <= 10; i++)
        points.add(Offset(20 + i * 1.0, 50 - i * 4.0));
      for (int i = 1; i <= 10; i++)
        points.add(Offset(30 + i * 1.0, 10 + i * 4.0));

      for (final pt in points) {
        detector.update(pt, [], 2.0);
      }

      expect(detector.state, ScribbleState.undetermined);
    });

    test('Scribble with lead-in stroke IS detected', () {
      final detector = ScribbleDetector();
      detector.start(const Offset(50, 100));

      final points = <Offset>[];
      for (double x = 55; x <= 100; x += 5) points.add(Offset(x, 100));
      for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 100));
      for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 103));
      for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 106));
      for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 109));

      for (final pt in points) {
        detector.update(pt, [], 2.0);
      }

      expect(detector.state, ScribbleState.erasing);
    });

    test('Straight line is NOT classified as scribble', () {
      final detector = ScribbleDetector();
      detector.start(const Offset(100, 100));

      final points = <Offset>[];
      for (double x = 105; x <= 250; x += 5) points.add(Offset(x, 100));

      for (final pt in points) {
        detector.update(pt, [], 2.0);
      }

      expect(detector.state, ScribbleState.undetermined);
    });

    test('Tightly spaced up and down handwriting is NOT a scribble', () {
      final detector = ScribbleDetector();
      final points = _zigzag(
        strokeLength: 32,
        spacing: 7,
        passes: 9,
        step: 2.5,
      );
      detector.start(points.first);

      for (final pt in points.skip(1)) {
        detector.update(pt, [], 2.0);
      }

      expect(detector.state, ScribbleState.undetermined);
    });

    test('Cursive loops are NOT a scribble at any zoom level', () {
      for (final scale in [0.5, 1.0, 2.0, 3.0, 5.0]) {
        final detector = ScribbleDetector();
        final screenPoints = _cursiveLoops(loops: 4);
        final points = [for (final p in screenPoints) p / scale];
        detector.start(points.first);

        for (final pt in points.skip(1)) {
          detector.update(pt, [], 2.0, scale: scale);
        }

        expect(
          detector.state,
          ScribbleState.undetermined,
          reason: 'zoom $scale',
        );
      }
    });

    test('A scribble is detected at any zoom level', () {
      for (final scale in [0.5, 1.0, 3.0, 5.0]) {
        final detector = ScribbleDetector();
        final screenPoints = _zigzag(
          strokeLength: 60,
          spacing: 3,
          passes: 6,
          step: 5,
          horizontal: true,
        );
        final points = [for (final p in screenPoints) p / scale];
        detector.start(points.first);

        for (final pt in points.skip(1)) {
          detector.update(pt, [], 2.0, scale: scale);
        }

        expect(detector.state, ScribbleState.erasing, reason: 'zoom $scale');
      }
    });

    test('Smooth circle is NOT classified as scribble', () {
      final detector = ScribbleDetector();
      detector.start(const Offset(140, 100));

      final points = <Offset>[];
      for (int i = 1; i <= 36; i++) {
        final rad = i * 10 * pi / 180;
        points.add(Offset(100 + 40 * cos(rad), 100 + 40 * sin(rad)));
      }

      for (final pt in points) {
        detector.update(pt, [], 2.0);
      }

      expect(detector.state, ScribbleState.undetermined);
    });
  });

  group('ScribbleDetector Erasing Strokes Tests', () {
    test('Erases underlying stroke when scribbling across it', () {
      final detector = ScribbleDetector();
      detector.start(const Offset(100, 100));

      // Existing stroke positioned horizontally at y=105
      final strokeToErase = Stroke(
        color: const Color(0xFF000000),
        pressureEnabled: false,
        options: StrokeOptions(size: 2),
        pageIndex: 0,
        page: const HasSize(Size(200, 200)),
        toolId: ToolId.ballpointPen,
      );
      for (double x = 90; x <= 170; x += 10) {
        strokeToErase.addPoint(Offset(x, 105));
      }
      final existingStrokes = <Stroke>[strokeToErase];

      final points = <Offset>[];
      for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 100));
      for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 103));
      for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 106));
      for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 109));

      final allErased = <Stroke>[];
      for (final pt in points) {
        final erased = detector.update(pt, existingStrokes, 2.0);
        allErased.addAll(erased);
      }

      expect(detector.state, ScribbleState.erasing);
      expect(allErased, contains(strokeToErase));

      final endErased = detector.end();
      expect(endErased, contains(strokeToErase));
      expect(detector.state, ScribbleState.undetermined);
    });

    test('The eraser reaches as far on screen at any zoom level', () {
      Stroke strokeAtY(double y) {
        final stroke = Stroke(
          color: const Color(0xFF000000),
          pressureEnabled: false,
          options: StrokeOptions(size: 2),
          pageIndex: 0,
          page: const HasSize(Size(400, 400)),
          toolId: ToolId.ballpointPen,
        );
        for (double x = 90; x <= 170; x += 10) {
          stroke.addPoint(Offset(x, y));
        }
        return stroke;
      }

      List<Stroke> erasedAt(double scale) {
        final detector = ScribbleDetector();
        detector.start(const Offset(100, 100));
        final nearby = strokeAtY(125);
        final points = <Offset>[];
        for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 100));
        for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 103));
        for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 106));
        for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 109));
        final erased = <Stroke>[];
        for (final pt in points) {
          erased.addAll(detector.update(pt, [nearby], 2.0, scale: scale));
        }
        return erased;
      }

      expect(erasedAt(1), isNotEmpty, reason: '16 units away is in reach');
      expect(erasedAt(2), isEmpty, reason: 'twice the zoom halves the reach');
    });

    test('Reports a stroke only once however many points cross it', () {
      final detector = ScribbleDetector();
      detector.start(const Offset(100, 100));

      final strokeToErase = Stroke(
        color: const Color(0xFF000000),
        pressureEnabled: false,
        options: StrokeOptions(size: 2),
        pageIndex: 0,
        page: const HasSize(Size(200, 200)),
        toolId: ToolId.ballpointPen,
      );
      for (double x = 90; x <= 170; x += 10) {
        strokeToErase.addPoint(Offset(x, 105));
      }
      final existingStrokes = <Stroke>[strokeToErase];

      final points = <Offset>[];
      for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 100));
      for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 103));
      for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 106));
      for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 109));

      final allErased = <Stroke>[];
      for (final pt in points) {
        allErased.addAll(detector.update(pt, existingStrokes, 2.0));
      }

      expect(allErased, [strokeToErase]);
      expect(detector.end(), [
        strokeToErase,
      ], reason: 'Undo re-inserts every stroke in this list');
    });

    test('Erases underlying EditorImage sticker when scribbling across it', () {
      final detector = ScribbleDetector();
      detector.start(const Offset(100, 100));

      final testPage = EditorPage(size: const Size(600, 800));
      final sticker = StickerImage(
        id: 1,
        assetCache: AssetCache(),
        emoji: '⭐',
        pageIndex: 0,
        pageSize: const Size(600, 800),
        onMoveImage: null,
        onDeleteImage: null,
        onMiscChange: null,
        dstRect: const Rect.fromLTWH(110, 95, 40, 40),
      );
      testPage.images.add(sticker);

      final points = <Offset>[];
      for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 100));
      for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 103));
      for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 106));
      for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 109));

      for (final pt in points) {
        detector.update(pt, [], 2.0, page: testPage, lineHeight: 30);
      }

      expect(detector.state, ScribbleState.erasing);
      expect(testPage.images, isEmpty);
      expect(detector.erasedImages, contains(sticker));

      final endImages = detector.getAndClearErasedImages();
      expect(endImages, contains(sticker));
      expect(detector.erasedImages, isEmpty);
    });

    test('Erases typed text line when scribbling across text content', () {
      final detector = ScribbleDetector();
      detector.start(const Offset(100, 50));

      final testPage = EditorPage(size: const Size(600, 800));
      testPage.quill.controller.document.insert(
        0,
        'First line of text\nSecond line\n',
      );

      final points = <Offset>[];
      for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 50));
      for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 53));
      for (double x = 105; x <= 160; x += 5) points.add(Offset(x, 56));
      for (double x = 155; x >= 100; x -= 5) points.add(Offset(x, 59));

      for (final pt in points) {
        detector.update(pt, [], 2.0, page: testPage, lineHeight: 30);
      }

      expect(detector.state, ScribbleState.erasing);
      expect(detector.erasedText, isTrue);
    });
  });
}
