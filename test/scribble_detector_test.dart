/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'dart:math';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/scribble_detector.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

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
      for (int i = 1; i <= 10; i++) points.add(Offset(15 + i * 1.5, 50 - i * 3.5));
      for (int i = 1; i <= 10; i++) points.add(Offset(30 + i * 1.5, 15 + i * 3.5));
      for (int i = 1; i <= 10; i++) points.add(Offset(45 + i * 1.5, 50 - i * 5.0));

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
      for (int i = 1; i <= 10; i++) points.add(Offset(10 + i * 1.0, 10 + i * 4.0));
      for (int i = 1; i <= 10; i++) points.add(Offset(20 + i * 1.0, 50 - i * 4.0));
      for (int i = 1; i <= 10; i++) points.add(Offset(30 + i * 1.0, 10 + i * 4.0));

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
  });
}
