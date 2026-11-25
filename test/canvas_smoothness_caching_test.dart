/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_canvas_painter.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:sbn/tool_id.dart';

const _viewportRect = Rect.fromLTWH(0, 0, 800, 1000);
const _pageSize = Size(800, 1000);

CanvasPainter _buildPainter(
  EditorPage page, {
  Stroke? currentStroke,
  bool invert = false,
  double currentScale = 1.0,
}) {
  return CanvasPainter(
    page: page,
    laserStrokes: const [],
    currentStroke: currentStroke,
    currentSelection: null,
    primaryColor: Colors.blue,
    showPageIndicator: false,
    pageIndex: 0,
    totalPages: 1,
    currentScale: currentScale,
    defaultTextStyle: const TextStyle(fontSize: 14),
    invert: invert,
  );
}

ui.Picture _paintBoundedFrame(
  EditorPage page, {
  Stroke? currentStroke,
  bool invert = false,
  double currentScale = 1.0,
}) {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..clipRect(_viewportRect);
  final painter = _buildPainter(
    page,
    currentStroke: currentStroke,
    invert: invert,
    currentScale: currentScale,
  );
  painter.paint(canvas, _pageSize);
  return recorder.endRecording();
}

Future<int> _countNonTransparentPixels(
  ui.Picture picture, {
  int width = 200,
  int height = 200,
}) async {
  final image = await picture.toImage(width, height);
  try {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return 0;
    final bytes = byteData.buffer.asUint8List();
    var count = 0;
    for (var i = 3; i < bytes.length; i += 4) {
      if (bytes[i] > 0) count++;
    }
    return count;
  } finally {
    image.dispose();
  }
}

Stroke _createStyledStroke(
  EditorPage page, {
  required LineStyle lineStyle,
  required List<Offset> points,
  Color color = Colors.indigo,
  double size = 4.0,
}) {
  final stroke = Stroke(
    color: color,
    pressureEnabled: false,
    options: StrokeOptions(size: size, isComplete: true),
    pageIndex: 0,
    page: page,
    toolId: ToolId.fountainPen,
    lineStyle: lineStyle,
  );
  for (final pt in points) {
    stroke.addPoint(pt);
  }
  return stroke;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(FlavorConfig.setup);

  group('1. Dashed & Dotted Stroke Caching & Transform Invariants', () {
    test(
      'paints LineStyle.dashed and LineStyle.dotted across multiple frames '
      'and updates boundingBox on shift, scaleAround, and rotateAround',
      () async {
        final page = EditorPage(size: _pageSize);
        addTearDown(page.dispose);

        final dashed = _createStyledStroke(
          page,
          lineStyle: LineStyle.dashed,
          points: const [Offset(20, 40), Offset(90, 40), Offset(160, 40)],
        );
        final dotted = _createStyledStroke(
          page,
          lineStyle: LineStyle.dotted,
          points: const [Offset(20, 90), Offset(90, 110), Offset(160, 90)],
        );

        page.insertStroke(dashed);
        page.insertStroke(dotted);

        final initialBounds = dashed.boundingBox;
        expect(initialBounds.isEmpty, isFalse);

        // Paint multiple consecutive frames to exercise cold + warm caches.
        var firstFramePixels = 0;
        for (var frame = 0; frame < 4; frame++) {
          final picture = _paintBoundedFrame(page);
          if (frame == 0) {
            firstFramePixels = await _countNonTransparentPixels(picture);
            expect(firstFramePixels, greaterThan(0));
          } else if (frame == 3) {
            final warmPixels = await _countNonTransparentPixels(picture);
            expect(warmPixels, equals(firstFramePixels));
          }
          picture.dispose();
        }

        // Shift and verify boundingBox + multi-frame repaint.
        const delta = Offset(30, 25);
        dashed.shift(delta);
        dotted.shift(delta);
        page.redrawStrokes();

        final shiftedBounds = dashed.boundingBox;
        expect(
          shiftedBounds.left,
          closeTo(initialBounds.left + delta.dx, 1e-4),
        );
        expect(shiftedBounds.top, closeTo(initialBounds.top + delta.dy, 1e-4));

        for (var frame = 0; frame < 3; frame++) {
          final picture = _paintBoundedFrame(page);
          picture.dispose();
        }

        // Scale around center and verify boundingBox expands + repaints cleanly.
        final preScaleWidth = dashed.boundingBox.width;
        dashed.scaleAround(1.5, 1.5, dashed.boundingBox.center);
        dotted.scaleAround(1.25, 1.25, dotted.boundingBox.center);
        page.redrawStrokes();

        expect(dashed.boundingBox.width, greaterThan(preScaleWidth));

        for (var frame = 0; frame < 3; frame++) {
          final picture = _paintBoundedFrame(page);
          picture.dispose();
        }

        // Rotate 90 degrees around center: horizontal dashed line becomes tall.
        final preRotateBounds = dashed.boundingBox;
        expect(preRotateBounds.width, greaterThan(preRotateBounds.height));

        dashed.rotateAround(pi / 2, preRotateBounds.center);
        dotted.rotateAround(pi / 4, dotted.boundingBox.center);
        page.redrawStrokes();

        final rotatedBounds = dashed.boundingBox;
        expect(rotatedBounds.height, greaterThan(rotatedBounds.width));

        for (var frame = 0; frame < 3; frame++) {
          final picture = _paintBoundedFrame(page);
          picture.dispose();
        }
      },
    );

    test('paints in-flight currentStroke with dashed and dotted styles', () {
      final page = EditorPage(size: _pageSize);
      addTearDown(page.dispose);

      for (final style in [LineStyle.dashed, LineStyle.dotted]) {
        final active = Stroke(
          color: Colors.teal,
          pressureEnabled: false,
          options: StrokeOptions(size: 3.5),
          pageIndex: 0,
          page: page,
          toolId: ToolId.fountainPen,
          lineStyle: style,
        );

        for (var step = 0; step < 6; step++) {
          active.addPoint(Offset(30 + step * 18.0, 60 + step * 6.0));
          final picture = _paintBoundedFrame(page, currentStroke: active);
          picture.dispose();
        }
      }
    });
  });

  group('2. TapeStroke Pattern & Conceal/Transform Smoothness', () {
    test(
      'renders all TapePattern variants in concealed and revealed states '
      'and after shift, scaleAround, rotateAround, and toggleConceal',
      () async {
        for (final pattern in TapePattern.values) {
          final page = EditorPage(size: _pageSize);

          final tape = TapeStroke(
            color: const Color(0xFFFFD54F),
            pressureEnabled: false,
            options: StrokeOptions(size: 24),
            pageIndex: 0,
            page: page,
            toolId: ToolId.studyTape,
            rect: const Rect.fromLTWH(20, 30, 120, 32),
            isConcealed: true,
            pattern: pattern,
          );
          page.insertStroke(tape);

          // Concealed multi-frame render.
          for (var frame = 0; frame < 3; frame++) {
            final picture = _paintBoundedFrame(page);
            if (frame == 0) {
              expect(await _countNonTransparentPixels(picture), greaterThan(0));
            }
            picture.dispose();
          }

          // Toggle to revealed (isConcealed = false) and render multiple frames.
          tape.toggleConceal();
          expect(tape.isConcealed, isFalse);
          page.redrawStrokes();

          for (var frame = 0; frame < 3; frame++) {
            final picture = _paintBoundedFrame(page);
            if (frame == 0) {
              expect(await _countNonTransparentPixels(picture), greaterThan(0));
            }
            picture.dispose();
          }

          // Toggle back to concealed, shift, scale, and rotate.
          tape.toggleConceal();
          expect(tape.isConcealed, isTrue);

          const offset = Offset(25, 40);
          final beforeShift = tape.boundingBox;
          tape.shift(offset);
          expect(tape.boundingBox, equals(beforeShift.shift(offset)));

          tape.scaleAround(1.2, 1.3, tape.rect.center);
          tape.rotateAround(pi / 2, tape.rect.center);
          page.redrawStrokes();

          for (var frame = 0; frame < 2; frame++) {
            final picture = _paintBoundedFrame(page);
            picture.dispose();
          }

          page.dispose();
        }
      },
    );
  });

  group('3. DimensionStroke Text Layout Caching & Transform Smoothness', () {
    test('paints DimensionStroke with measurement text across multiple frames, '
        'in dark-mode inversion, and after shift/scale/rotate', () async {
      final page = EditorPage(size: _pageSize);
      addTearDown(page.dispose);

      final dim = DimensionStroke(
        color: Colors.deepOrange,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.5),
        pageIndex: 0,
        page: page,
        toolId: ToolId.dimension,
        start: const Offset(30, 50),
        end: const Offset(150, 50),
        offset: 28.0,
        text: '120.0 mm',
      );
      page.insertStroke(dim);

      final initialTextPos = dim.textPosition;
      final initialBounds = dim.boundingBox;

      // Multi-frame render in light and inverted dark mode.
      for (var frame = 0; frame < 4; frame++) {
        final picture = _paintBoundedFrame(page);
        if (frame == 0) {
          expect(await _countNonTransparentPixels(picture), greaterThan(0));
        }
        picture.dispose();
      }
      for (var frame = 0; frame < 2; frame++) {
        final invertedPicture = _paintBoundedFrame(page, invert: true);
        invertedPicture.dispose();
      }

      // Shift and verify textPosition + boundingBox update cleanly.
      const shiftDelta = Offset(35, 20);
      dim.shift(shiftDelta);
      page.redrawStrokes();

      expect(dim.textPosition.dx, closeTo(initialTextPos.dx + 35, 1e-4));
      expect(dim.textPosition.dy, closeTo(initialTextPos.dy + 20, 1e-4));
      expect(dim.boundingBox.left, closeTo(initialBounds.left + 35, 1e-4));
      expect(dim.boundingBox.top, closeTo(initialBounds.top + 20, 1e-4));

      for (var frame = 0; frame < 3; frame++) {
        final picture = _paintBoundedFrame(page);
        picture.dispose();
      }

      // Update measurement label & render in-flight currentStroke as well.
      dim.text = '180.0 mm';
      dim.scaleAround(1.5, 1.5, dim.start);
      dim.rotateAround(pi / 6, dim.start);
      page.redrawStrokes();

      for (var frame = 0; frame < 3; frame++) {
        final picture = _paintBoundedFrame(page, currentStroke: dim);
        picture.dispose();
      }
    });
  });

  group('4. 120Hz In-Flight Stroke Page Reuse & Dispose Cleanup', () {
    test(
      'reuses committed highlighter + pen strokes smoothly across simulated '
      '120Hz in-flight frames on bounded Canvas and cleans up on page.dispose',
      () async {
        final page = EditorPage(size: _pageSize);

        // Populate page with committed multi-color highlighters + pen strokes.
        final yellowHighlighter =
            Stroke(
                color: Colors.yellow.withAlpha(Highlighter.alpha),
                pressureEnabled: false,
                options: StrokeOptions(size: 24, isComplete: true),
                pageIndex: 0,
                page: page,
                toolId: ToolId.highlighter,
              )
              ..addPoint(const Offset(20, 40))
              ..addPoint(const Offset(160, 40));

        final greenHighlighter =
            Stroke(
                color: Colors.lightGreenAccent.withAlpha(Highlighter.alpha),
                pressureEnabled: false,
                options: StrokeOptions(size: 24, isComplete: true),
                pageIndex: 0,
                page: page,
                toolId: ToolId.highlighter,
              )
              ..addPoint(const Offset(20, 80))
              ..addPoint(const Offset(160, 80));

        final committedPen =
            Stroke(
                color: Colors.black,
                pressureEnabled: true,
                options: StrokeOptions(size: 4, isComplete: true),
                pageIndex: 0,
                page: page,
                toolId: ToolId.fountainPen,
              )
              ..addPoint(const Offset(25, 35), 0.5)
              ..addPoint(const Offset(95, 65), 0.7)
              ..addPoint(const Offset(155, 45), 0.6);

        page.insertStroke(yellowHighlighter);
        page.insertStroke(greenHighlighter);
        page.insertStroke(committedPen);

        final committedVersion = page.strokesVersion;

        // Idle painters with identical strokesVersion and no currentStroke
        // must not request redundant repaints.
        final idleA = _buildPainter(page);
        final idleB = _buildPainter(page);
        expect(idleB.shouldRepaint(idleA), isFalse);

        // Simulate 24 frames of 120Hz stylus input for an in-flight pen stroke.
        final inFlightPen = Stroke(
          color: Colors.blueAccent,
          pressureEnabled: true,
          options: StrokeOptions(size: 3.5),
          pageIndex: 0,
          page: page,
          toolId: ToolId.fountainPen,
        );

        var previousPainter = idleA;
        for (var frame = 0; frame < 24; frame++) {
          inFlightPen.addPoint(
            Offset(30 + frame * 6.0, 120 + sin(frame * 0.25) * 15.0),
            0.55,
          );

          final activePainter = _buildPainter(page, currentStroke: inFlightPen);
          expect(activePainter.shouldRepaint(previousPainter), isTrue);
          expect(page.strokesVersion, equals(committedVersion));

          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder)..clipRect(_viewportRect);
          activePainter.paint(canvas, _pageSize);
          final picture = recorder.endRecording();
          if (frame == 0 || frame == 23) {
            expect(await _countNonTransparentPixels(picture), greaterThan(0));
          }
          picture.dispose();
          previousPainter = activePainter;
        }

        // Simulate in-flight highlighter stroke (drawn between highlighter
        // and non-highlighter layers).
        final inFlightHighlighter = Stroke(
          color: Colors.pinkAccent.withAlpha(Highlighter.alpha),
          pressureEnabled: false,
          options: StrokeOptions(size: 20),
          pageIndex: 0,
          page: page,
          toolId: ToolId.highlighter,
        );
        for (var frame = 0; frame < 8; frame++) {
          inFlightHighlighter.addPoint(Offset(30 + frame * 15.0, 150));
          final picture = _paintBoundedFrame(
            page,
            currentStroke: inFlightHighlighter,
          );
          picture.dispose();
        }

        // Commit in-flight stroke, verify strokesVersion advances & paints.
        inFlightPen.options.isComplete = true;
        page.insertStroke(inFlightPen);
        expect(page.strokesVersion, isNot(equals(committedVersion)));

        final postCommitPicture = _paintBoundedFrame(page);
        expect(
          await _countNonTransparentPixels(postCommitPicture),
          greaterThan(0),
        );
        postCommitPicture.dispose();

        // Remove a stroke and paint at zoomed-out scale (< 0.5) as well.
        expect(page.removeStroke(greenHighlighter), isTrue);
        final zoomedOutPicture = _paintBoundedFrame(page, currentScale: 0.35);
        zoomedOutPicture.dispose();

        // Verify page.dispose() releases resources cleanly without throwing.
        page.isRendered = true;
        page.dispose();
        expect(page.isRendered, isFalse);
      },
    );
  });
}
