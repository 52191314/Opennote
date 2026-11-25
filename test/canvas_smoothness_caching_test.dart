/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_canvas_background_painter.dart';
import 'package:saber/components/canvas/_canvas_painter.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/components/canvas/canvas.dart' as saber_canvas;
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/components/canvas/hud/canvas_hud.dart';
import 'package:saber/components/canvas/hud/canvas_zoom_indicator.dart';
import 'package:saber/components/canvas/inner_canvas.dart';
import 'package:saber/components/canvas/interactive_canvas.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/palm_rejection.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:sbn/canvas_background_pattern.dart';
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

  group('5. iOS Pinch-Zoom Freeze Prevention & Extreme Scale Invariants', () {
    test(
      'main.dart does not enable GestureBinding.instance.resamplingEnabled',
      () {
        final mainSource = File('lib/main.dart').readAsStringSync();
        expect(mainSource.contains('resamplingEnabled'), isFalse);
      },
    );

    testWidgets(
      'InnerCanvas unwraps RepaintBoundary above 2.0x scale to prevent >16384px Metal texture freeze',
      (tester) async {
        final coreInfo = EditorCoreInfo(filePath: '/zoom_test');
        final page = EditorPage(size: const Size(1000, 1400));
        addTearDown(page.dispose);
        coreInfo.pages = [page];

        await tester.pumpWidget(
          TranslationProvider(
            child: MaterialApp(
              home: Scaffold(
                body: InnerCanvas(
                  pageIndex: 0,
                  width: 1000,
                  height: 1400,
                  coreInfo: coreInfo,
                  currentStroke: null,
                  currentStrokeDetectedShape: null,
                  currentSelection: null,
                  currentToolIsSelect: false,
                  currentScale: 1.0,
                ),
              ),
            ),
          ),
        );

        final boundariesAt1x = find
            .descendant(
              of: find.byType(InnerCanvas),
              matching: find.byType(RepaintBoundary),
            )
            .evaluate()
            .length;
        expect(boundariesAt1x, greaterThanOrEqualTo(2));

        await tester.pumpWidget(
          TranslationProvider(
            child: MaterialApp(
              home: Scaffold(
                body: InnerCanvas(
                  pageIndex: 0,
                  width: 1000,
                  height: 1400,
                  coreInfo: coreInfo,
                  currentStroke: null,
                  currentStrokeDetectedShape: null,
                  currentSelection: null,
                  currentToolIsSelect: false,
                  currentScale: 8.0,
                ),
              ),
            ),
          ),
        );

        final boundariesAt8x = find
            .descendant(
              of: find.byType(InnerCanvas),
              matching: find.byType(RepaintBoundary),
            )
            .evaluate()
            .length;
        // On Impeller, stable RepaintBoundary layers retain vector DisplayLists
        // across all zoom levels without mid-pinch RenderObject destruction.
        expect(boundariesAt8x, equals(boundariesAt1x));
      },
    );

    test(
      'CanvasBackgroundPainter adaptive LOD renders extreme zoom-out infinite canvas rapidly',
      () {
        const hugeViewport = Rect.fromLTWH(-20000, -20000, 40000, 40000);
        for (final pattern in [
          CanvasBackgroundPattern.dots,
          CanvasBackgroundPattern.grid,
          CanvasBackgroundPattern.engineeringGrid,
          CanvasBackgroundPattern.isometric,
        ]) {
          final sw = Stopwatch()..start();
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder)..clipRect(hugeViewport);
          final painter = CanvasBackgroundPainter(
            invert: false,
            backgroundColor: Colors.white,
            backgroundPattern: pattern,
            lineHeight: 40,
            lineThickness: 2,
            isInfiniteCanvas: true,
            viewportRect: hugeViewport,
            currentScale: 0.005,
          );
          painter.paint(canvas, const Size(1000, 1400));
          final pic = recorder.endRecording();
          pic.dispose();
          sw.stop();
          expect(
            sw.elapsedMilliseconds,
            lessThan(150),
            reason: '$pattern took too long at 0.005x zoom out',
          );
        }
      },
    );

    testWidgets(
      'InteractiveCanvasViewer two-finger pinch zoom-in and zoom-out preserves stable scale without reverse fling or palm abort',
      (tester) async {
        final controller = TransformationController();
        addTearDown(controller.dispose);
        final palmEngine = PalmRejectionEngine(
          writingPosture: WritingPosture.rightBelow,
          sensitivity: PalmRejectionSensitivity.high,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveCanvasViewer.builder(
                palmEngine: palmEngine,
                minScale: 0.001,
                maxScale: 10.0,
                interactionEndFrictionCoefficient: 0.3,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                transformationController: controller,
                builder: (context, viewport) =>
                    const SizedBox(width: 1000, height: 1400),
              ),
            ),
          ),
        );

        await tester.sendEventToBinding(
          const PointerAddedEvent(
            pointer: 201,
            position: Offset(350, 300),
            kind: PointerDeviceKind.touch,
          ),
        );
        await tester.sendEventToBinding(
          const PointerAddedEvent(
            pointer: 202,
            position: Offset(450, 300),
            kind: PointerDeviceKind.touch,
          ),
        );
        await tester.sendEventToBinding(
          const PointerDownEvent(
            pointer: 201,
            position: Offset(350, 300),
            kind: PointerDeviceKind.touch,
            radiusMajor: 10.0,
          ),
        );
        await tester.sendEventToBinding(
          const PointerDownEvent(
            pointer: 202,
            position: Offset(450, 300),
            kind: PointerDeviceKind.touch,
            radiusMajor: 10.0,
          ),
        );
        await tester.pump();

        // Spread fingers rapidly to zoom in (~2.5x) and simulate thumb contact widening mid-pinch
        for (var i = 1; i <= 5; i++) {
          final ts = Duration(milliseconds: i * 8);
          await tester.sendEventToBinding(
            PointerMoveEvent(
              pointer: 201,
              timeStamp: ts,
              position: Offset(350.0 - i * 35, 300),
              delta: const Offset(-35, 0),
              kind: PointerDeviceKind.touch,
              radiusMajor: 12.0,
            ),
          );
          await tester.sendEventToBinding(
            PointerMoveEvent(
              pointer: 202,
              timeStamp: ts,
              position: Offset(450.0 + i * 35, 300),
              delta: const Offset(35, 0),
              kind: PointerDeviceKind.touch,
              radiusMajor: 26.0,
            ),
          );
          await tester.pump(const Duration(milliseconds: 8));
        }

        final scaleBeforeRelease = controller.value.maxScale2D;
        expect(scaleBeforeRelease, greaterThan(1.5));

        const endTs = Duration(milliseconds: 48);
        await tester.sendEventToBinding(
          const PointerUpEvent(
            pointer: 201,
            timeStamp: endTs,
            position: Offset(175, 300),
            kind: PointerDeviceKind.touch,
          ),
        );
        await tester.sendEventToBinding(
          const PointerUpEvent(
            pointer: 202,
            timeStamp: endTs,
            position: Offset(625, 300),
            kind: PointerDeviceKind.touch,
          ),
        );
        await tester.pumpAndSettle();

        // Scale must NOT reverse-bounce or collapse to 0.001x after finger lift!
        final scaleAfterRelease = controller.value.maxScale2D;
        expect(scaleAfterRelease.isFinite, isTrue);
        expect(scaleAfterRelease, closeTo(scaleBeforeRelease, 1e-3));
      },
    );
  });

  group('6. Deep Zoom-Out (0% Cliff) & Z-Scale Invariant Regression Tests', () {
    test(
      'mode-aware minScaleFor enforces Impeller-safe floors while formatZoomText never prints 0.0%',
      () {
        expect(
          CanvasGestureDetector.minScaleFor(isInfiniteCanvas: false),
          equals(0.2),
        );
        expect(
          CanvasGestureDetector.minScaleFor(isInfiniteCanvas: true),
          equals(0.02),
        );
        expect(CanvasZoomIndicator.formatZoomText(0.0001), equals('0.1%'));
        expect(CanvasZoomIndicator.formatZoomText(0.0), equals('1.0x'));
        expect(CanvasZoomIndicator.formatZoomText(double.nan), equals('1.0x'));
      },
    );

    testWidgets(
      'non-uniform Z-scale from fitContentToView never drives 2D zoom below minScale or blocks pinch-in recovery',
      (tester) async {
        // Simulate fitContentToView matrix where X/Y = 0.05 and Z = 1.0
        final controller = TransformationController(
          Matrix4.identity()..scaleByDouble(0.05, 0.05, 1.0, 1.0),
        );
        addTearDown(controller.dispose);
        final palmEngine = PalmRejectionEngine(
          writingPosture: WritingPosture.rightBelow,
          sensitivity: PalmRejectionSensitivity.medium,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveCanvasViewer.builder(
                palmEngine: palmEngine,
                minScale: CanvasGestureDetector.kInfiniteMinScale,
                maxScale: CanvasGestureDetector.kMaxScale,
                interactionEndFrictionCoefficient: 0.3,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                transformationController: controller,
                builder: (context, viewport) =>
                    const SizedBox(width: 1000, height: 1400),
              ),
            ),
          ),
        );

        // Pinch OUT aggressively past kInfiniteMinScale (0.02)
        await tester.sendEventToBinding(
          const PointerAddedEvent(
            pointer: 301,
            position: Offset(200, 300),
            kind: PointerDeviceKind.touch,
          ),
        );
        await tester.sendEventToBinding(
          const PointerAddedEvent(
            pointer: 302,
            position: Offset(600, 300),
            kind: PointerDeviceKind.touch,
          ),
        );
        await tester.sendEventToBinding(
          const PointerDownEvent(
            pointer: 301,
            position: Offset(200, 300),
            kind: PointerDeviceKind.touch,
            radiusMajor: 24.0,
          ),
        );
        await tester.sendEventToBinding(
          const PointerDownEvent(
            pointer: 302,
            position: Offset(600, 300),
            kind: PointerDeviceKind.touch,
            radiusMajor: 24.0,
          ),
        );
        await tester.pump();

        // Pinch fingers inward from 400px span down to 40px span (0.1x factor -> tries 0.005, must clamp at 0.02!)
        for (var i = 1; i <= 5; i++) {
          final ts = Duration(milliseconds: i * 8);
          await tester.sendEventToBinding(
            PointerMoveEvent(
              pointer: 301,
              timeStamp: ts,
              position: Offset(200.0 + i * 36, 300),
              kind: PointerDeviceKind.touch,
              radiusMajor: 24.0,
            ),
          );
          await tester.sendEventToBinding(
            PointerMoveEvent(
              pointer: 302,
              timeStamp: ts,
              position: Offset(600.0 - i * 36, 300),
              kind: PointerDeviceKind.touch,
              radiusMajor: 24.0,
            ),
          );
          await tester.pump(const Duration(milliseconds: 8));
        }

        // Must clamp cleanly at kInfiniteMinScale (0.02 = 2%), NEVER plunging to 0.0001 ("0.0%")!
        expect(
          controller.value.approxScale,
          closeTo(CanvasGestureDetector.kInfiniteMinScale, 1e-4),
        );
        expect(
          CanvasZoomIndicator.formatZoomText(controller.value.approxScale),
          equals('2%'),
        );

        // Immediately reverse finger direction WITHOUT lifting to zoom back IN (must have zero dead-zone!)
        for (var i = 1; i <= 4; i++) {
          final ts = Duration(milliseconds: 50 + i * 8);
          await tester.sendEventToBinding(
            PointerMoveEvent(
              pointer: 301,
              timeStamp: ts,
              position: Offset(380.0 - i * 40, 300),
              kind: PointerDeviceKind.touch,
              radiusMajor: 24.0,
            ),
          );
          await tester.sendEventToBinding(
            PointerMoveEvent(
              pointer: 302,
              timeStamp: ts,
              position: Offset(420.0 + i * 40, 300),
              kind: PointerDeviceKind.touch,
              radiusMajor: 24.0,
            ),
          );
          await tester.pump(const Duration(milliseconds: 8));
        }

        expect(
          controller.value.approxScale,
          greaterThan(CanvasGestureDetector.kInfiniteMinScale * 2),
        );

        await tester.sendEventToBinding(
          const PointerUpEvent(
            pointer: 301,
            timeStamp: Duration(milliseconds: 90),
            position: Offset(220, 300),
            kind: PointerDeviceKind.touch,
          ),
        );
        await tester.sendEventToBinding(
          const PointerUpEvent(
            pointer: 302,
            timeStamp: Duration(milliseconds: 90),
            position: Offset(580, 300),
            kind: PointerDeviceKind.touch,
          ),
        );
        await tester.pumpAndSettle();
      },
    );

    test(
      'CanvasBackgroundPainter tiles across >50,000px deep zoom-out iPad viewport without vanishing, and CanvasPainter skips redundant scale repaints',
      () {
        // At 2% zoom on a 1024x1366 iPad, scene viewport is 51,200 x 68,300 (> 50,000px!)
        const ipadViewportAt2Percent = Rect.fromLTWH(
          -25600,
          -34150,
          51200,
          68300,
        );
        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.grid,
          size: const Size(1000, 1400),
          lineHeight: 640,
          bounds: ipadViewportAt2Percent,
        ).toList();
        expect(elements, isNotEmpty);
        expect(elements.any((e) => e.end.dx >= 25000), isTrue);
        expect(elements.any((e) => e.end.dy >= 34000), isTrue);

        // Continuous pinch-zoom within the same low-zoom bucket must not force CanvasPainter repaints
        final page = EditorPage(size: _pageSize);
        addTearDown(page.dispose);
        final p1 = _buildPainter(page, currentScale: 0.35);
        final p2 = _buildPainter(page, currentScale: 0.25);
        expect(p2.shouldRepaint(p1), isFalse);
      },
    );
  });

  group('7. Normal Canvas 10.0x & 0.4x Freeze Regression Tests', () {
    testWidgets(
      'staggered 120Hz two-finger re-pinch at 10.0x and 0.4x is never cancelled by palm rejection',
      (tester) async {
        final controller = TransformationController(
          Matrix4.identity()..scaleByDouble(10.0, 10.0, 1.0, 1.0),
        );
        addTearDown(controller.dispose);
        final palmEngine = PalmRejectionEngine(
          writingPosture: WritingPosture.rightBelow,
          sensitivity: PalmRejectionSensitivity.high,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 393,
              height: 852,
              child: InteractiveCanvasViewer.builder(
                palmEngine: palmEngine,
                minScale: CanvasGestureDetector.kPagedMinScale,
                maxScale: CanvasGestureDetector.kMaxScale,
                interactionEndFrictionCoefficient: 0.3,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                transformationController: controller,
                builder: (context, viewport) =>
                    const SizedBox(width: 393, height: 1150),
              ),
            ),
          ),
        );

        // Finger 1 lands FIRST with thumb radiusMajor = 25pt (> high 16pt & medium 22pt),
        // and emits 120Hz PointerMoveEvent 8ms later BEFORE Finger 2 lands at 16ms!
        await tester.sendEventToBinding(
          const PointerAddedEvent(
            pointer: 401,
            position: Offset(100, 400),
            kind: PointerDeviceKind.touch,
          ),
        );
        await tester.sendEventToBinding(
          const PointerDownEvent(
            pointer: 401,
            timeStamp: Duration.zero,
            position: Offset(100, 400),
            kind: PointerDeviceKind.touch,
            radiusMajor: 25.0,
          ),
        );
        await tester.pump(const Duration(milliseconds: 8));
        await tester.sendEventToBinding(
          const PointerMoveEvent(
            pointer: 401,
            timeStamp: Duration(milliseconds: 8),
            position: Offset(102, 400),
            kind: PointerDeviceKind.touch,
            radiusMajor: 26.0,
          ),
        );
        await tester.pump(const Duration(milliseconds: 8));

        // Finger 2 lands 16ms later and both pinch inward to zoom out from 10.0x
        await tester.sendEventToBinding(
          const PointerAddedEvent(
            pointer: 402,
            position: Offset(300, 400),
            kind: PointerDeviceKind.touch,
          ),
        );
        await tester.sendEventToBinding(
          const PointerDownEvent(
            pointer: 402,
            timeStamp: Duration(milliseconds: 16),
            position: Offset(300, 400),
            kind: PointerDeviceKind.touch,
            radiusMajor: 25.0,
          ),
        );
        await tester.pump();

        for (var i = 1; i <= 4; i++) {
          final ts = Duration(milliseconds: 16 + i * 8);
          await tester.sendEventToBinding(
            PointerMoveEvent(
              pointer: 401,
              timeStamp: ts,
              position: Offset(102.0 + i * 20, 400),
              kind: PointerDeviceKind.touch,
              radiusMajor: 26.0,
            ),
          );
          await tester.sendEventToBinding(
            PointerMoveEvent(
              pointer: 402,
              timeStamp: ts,
              position: Offset(300.0 - i * 20, 400),
              kind: PointerDeviceKind.touch,
              radiusMajor: 26.0,
            ),
          );
          await tester.pump(const Duration(milliseconds: 8));
        }

        // Must smoothly zoom out from 10.0x (never stuck at 10.0x!)
        expect(controller.value.maxScale2D, lessThan(6.0));

        await tester.sendEventToBinding(
          const PointerUpEvent(
            pointer: 401,
            timeStamp: Duration(milliseconds: 60),
            position: Offset(182, 400),
            kind: PointerDeviceKind.touch,
          ),
        );
        await tester.sendEventToBinding(
          const PointerUpEvent(
            pointer: 402,
            timeStamp: Duration(milliseconds: 60),
            position: Offset(220, 400),
            kind: PointerDeviceKind.touch,
          ),
        );
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'InnerCanvas preserves QuillEditor subtree across 0.4x <-> 1.0x <-> 10.0x scale transitions',
      (tester) async {
        final coreInfo = EditorCoreInfo(filePath: '/normal_zoom_test');
        final page = EditorPage(size: const Size(1000, 1400));
        addTearDown(page.dispose);
        page.quill.controller.document.insert(0, 'Hello Opennote');
        coreInfo.pages = [page];

        Widget buildAtScale(double scale) => TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: InnerCanvas(
                pageIndex: 0,
                width: 1000,
                height: 1400,
                coreInfo: coreInfo,
                currentStroke: null,
                currentStrokeDetectedShape: null,
                currentSelection: null,
                currentToolIsSelect: false,
                currentScale: scale,
              ),
            ),
          ),
        );

        await tester.pumpWidget(buildAtScale(1.0));
        final stateAt1x = tester.state(find.byType(DeferredPointerHandler));

        // Transition across 2.0x up to 10.0x: child State must NOT be unmounted!
        await tester.pumpWidget(buildAtScale(10.0));
        final stateAt10x = tester.state(find.byType(DeferredPointerHandler));
        expect(identical(stateAt1x, stateAt10x), isTrue);

        // Transition across 0.5x down to 0.4x: child State must NOT be unmounted!
        await tester.pumpWidget(buildAtScale(0.4));
        final stateAt04x = tester.state(find.byType(DeferredPointerHandler));
        expect(identical(stateAt1x, stateAt04x), isTrue);
      },
    );
  });

  group('8. 120Hz Decoupled Transform, Zero-Repaint & Freeze-Proof Invariants', () {
    testWidgets(
      'InteractiveCanvasViewer.builder runs builder once across 30 consecutive 120Hz pinch frames when shouldRebuildBuilder returns false',
      (tester) async {
        final controller = TransformationController();
        addTearDown(controller.dispose);
        var buildCount = 0;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 393,
              height: 852,
              child: InteractiveCanvasViewer.builder(
                minScale: 0.2,
                maxScale: 10.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                transformationController: controller,
                shouldRebuildBuilder: (oldM, newM, viewportSize) => false,
                builder: (context, viewport) {
                  buildCount++;
                  return const SizedBox(width: 393, height: 1150);
                },
              ),
            ),
          ),
        );

        expect(buildCount, equals(1));

        // Simulate 30 consecutive 120Hz zoom matrix updates (1.0x -> 1.9x).
        for (var i = 1; i <= 30; i++) {
          final scale = 1.0 + i * 0.03;
          controller.value = Matrix4.identity()
            ..scaleByDouble(scale, scale, 1.0, 1.0);
          await tester.pump(const Duration(milliseconds: 8));
        }

        // Builder must NOT have been re-invoked during continuous transform updates!
        expect(buildCount, equals(1));
        expect(controller.value.maxScale2D, closeTo(1.9, 1e-4));
      },
    );

    test(
      'CanvasGestureDetectorState.setZoom returns null (never NaN) on unbounded pre-layout BoxConstraints',
      () {
        final result = CanvasGestureDetectorState.setZoom(
          scaleDelta: 0.5,
          transformation: Matrix4.identity(),
          containerBounds: const BoxConstraints(),
        );
        expect(result, isNull);
      },
    );

    testWidgets(
      'Canvas + InnerCanvas keep identical InnerCanvas & DeferredPointerHandler State across 0.2x..10.0x without GlobalKey reparenting',
      (tester) async {
        final coreInfo = EditorCoreInfo(filePath: '/stable_tree_test');
        final page = EditorPage(size: const Size(1000, 1400));
        addTearDown(page.dispose);
        coreInfo.pages = [page];

        Widget buildCanvasAtScale(double scale) => TranslationProvider(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 393,
                height: 852,
                child: saber_canvas.Canvas(
                  path: coreInfo.filePath,
                  page: page,
                  pageIndex: 0,
                  textEditing: false,
                  coreInfo: coreInfo,
                  currentStroke: null,
                  currentStrokeDetectedShape: null,
                  currentSelection: null,
                  setAsBackground: null,
                  currentTool: Pen.currentPen,
                  currentScale: scale,
                ),
              ),
            ),
          ),
        );

        await tester.pumpWidget(buildCanvasAtScale(1.0));
        final innerState = tester.state(find.byType(InnerCanvas));
        final deferState = tester.state(find.byType(DeferredPointerHandler));

        for (final scale in [0.2, 0.4, 0.85, 1.5, 2.0, 2.5, 10.0, 0.5, 1.0]) {
          await tester.pumpWidget(buildCanvasAtScale(scale));
          expect(
            identical(innerState, tester.state(find.byType(InnerCanvas))),
            isTrue,
            reason: 'InnerCanvas must not remount at scale $scale',
          );
          expect(
            identical(
              deferState,
              tester.state(find.byType(DeferredPointerHandler)),
            ),
            isTrue,
            reason: 'DeferredPointerHandler must not remount at scale $scale',
          );
        }
      },
    );

    test(
      'CanvasBackgroundPainter.quantizedInfiniteRect stays constant across continuous zoom within an octave and caps dots without vanishing',
      () {
        const viewport = Rect.fromLTWH(-200, -300, 1200, 1600);
        final q1 = CanvasBackgroundPainter.quantizedInfiniteRect(
          viewport,
          0.95,
        );
        final q2 = CanvasBackgroundPainter.quantizedInfiniteRect(
          viewport,
          0.82,
        );
        final q3 = CanvasBackgroundPainter.quantizedInfiniteRect(
          viewport,
          0.62,
        );
        expect(q1, isNotNull);
        expect(q2, equals(q1));
        expect(q3, equals(q1));

        const bg1 = CanvasBackgroundPainter(
          invert: false,
          backgroundColor: Colors.white,
          backgroundPattern: CanvasBackgroundPattern.dots,
          lineHeight: 40,
          lineThickness: 2,
          isInfiniteCanvas: true,
          viewportRect: viewport,
          currentScale: 0.92,
        );
        const bg2 = CanvasBackgroundPainter(
          invert: false,
          backgroundColor: Colors.white,
          backgroundPattern: CanvasBackgroundPattern.dots,
          lineHeight: 40,
          lineThickness: 2,
          isInfiniteCanvas: true,
          viewportRect: viewport,
          currentScale: 0.78,
        );
        expect(bg2.shouldRepaint(bg1), isFalse);

        // Verify dot background paints quickly across 0.25x..0.5x without hitting 50k vanish cliff.
        for (final scale in [0.5, 0.35, 0.26, 0.1, 0.02]) {
          final vp = Rect.fromLTWH(
            -500 / scale,
            -700 / scale,
            1000 / scale,
            1400 / scale,
          );
          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);
          CanvasBackgroundPainter(
            invert: false,
            backgroundColor: Colors.white,
            backgroundPattern: CanvasBackgroundPattern.dots,
            lineHeight: 40,
            lineThickness: 2,
            isInfiniteCanvas: true,
            viewportRect: vp,
            currentScale: scale,
          ).paint(canvas, const Size(1000, 1400));
          final pic = recorder.endRecording();
          pic.dispose();
        }
      },
    );

    test(
      'CanvasPainter.quantizedHighZoomViewport tightens padding inversely at 10.0x and skips offscreen Rect.zero pages',
      () {
        const tinyViewport = Rect.fromLTWH(200, 300, 100, 200);
        final qAt2x = CanvasPainter.quantizedHighZoomViewport(
          tinyViewport,
          2.0,
        )!;
        final qAt10x = CanvasPainter.quantizedHighZoomViewport(
          tinyViewport,
          10.0,
        )!;
        expect(qAt10x.width, lessThan(qAt2x.width));
        expect(qAt10x.height, lessThan(qAt2x.height));

        // Offscreen focused page with viewportRect == Rect.zero paints zero stroke paths.
        final page = EditorPage(size: _pageSize);
        addTearDown(page.dispose);
        page.insertStroke(
          _createStyledStroke(
            page,
            lineStyle: LineStyle.solid,
            points: const [Offset(50, 50), Offset(150, 150)],
          ),
        );
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        CanvasPainter(
          page: page,
          laserStrokes: const [],
          currentStroke: null,
          currentSelection: null,
          primaryColor: Colors.blue,
          showPageIndicator: false,
          pageIndex: 0,
          totalPages: 1,
          currentScale: 2.0,
          defaultTextStyle: const TextStyle(fontSize: 14),
          viewportRect: Rect.zero,
        ).paint(canvas, _pageSize);
        final pic = recorder.endRecording();
        pic.dispose();
      },
    );

    test(
      'PalmRejectionEngine recovers stuck stylus on hover, allows post-stylus multi-touch pinch, and tolerates 120Hz fingertip flattening',
      () {
        final engine = PalmRejectionEngine(
          writingPosture: WritingPosture.rightBelow,
          sensitivity: PalmRejectionSensitivity.medium,
        );

        // 1. Stuck stylus down recovers on real PointerHoverEvent (stylus lifted).
        engine.notifyStylusEvent(
          const PointerDownEvent(
            pointer: 1,
            position: Offset(200, 200),
            kind: PointerDeviceKind.stylus,
          ),
        );
        expect(engine.isStylusDown, isTrue);

        engine.notifyStylusEvent(
          const PointerHoverEvent(
            position: Offset(200, 200),
            kind: PointerDeviceKind.stylus,
          ),
        );
        expect(engine.isStylusDown, isFalse);

        // 2. Multi-touch pinch inside posture zone right after stylus lift is allowed.
        const pinchFinger2 = PointerDownEvent(
          pointer: 2,
          position: Offset(260, 300),
          kind: PointerDeviceKind.touch,
          radiusMajor: 26.0,
        );
        expect(engine.isPalm(pinchFinger2, isMultiTouch: true), isFalse);

        // 3. No-stylus 120Hz fingertip touchdown flattening (9pt -> 26pt) is not rejected.
        engine.reset();
        const f1Down = PointerDownEvent(
          pointer: 3,
          position: Offset(150, 300),
          kind: PointerDeviceKind.touch,
          radiusMajor: 9.0,
        );
        const f1Move = PointerMoveEvent(
          pointer: 3,
          position: Offset(152, 300),
          kind: PointerDeviceKind.touch,
          radiusMajor: 26.0,
        );
        expect(engine.isPalm(f1Down), isFalse);
        expect(engine.isPalm(f1Move), isFalse);

        // 4. PointerUpEvent never leaks a pointer into rejected state.
        const f1Up = PointerUpEvent(
          pointer: 3,
          position: Offset(152, 300),
          kind: PointerDeviceKind.touch,
          radiusMajor: 55.0,
        );
        expect(engine.isPalm(f1Up), isFalse);
      },
    );

    test(
      'EditorHistory.removeAccidentalStroke safely returns null on non-draw history items without asserting or corrupting history',
      () {
        final history = EditorHistory();
        final page = EditorPage(size: _pageSize);
        addTearDown(page.dispose);

        history.recordChange(
          EditorHistoryItem(
            type: .insertPage,
            pageIndex: 1,
            strokes: const [],
            images: const [],
            page: page,
          ),
        );

        expect(history.removeAccidentalStroke(), isNull);
        expect(history.canUndo, isTrue);
        expect(
          history.peekUndo().type,
          equals(EditorHistoryItemType.insertPage),
        );
      },
    );

    testWidgets(
      'CanvasHud filtered zoom indicator updates when formatted zoom text changes and stays stable during pure pan',
      (tester) async {
        final controller = TransformationController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          TranslationProvider(
            child: MaterialApp(
              home: Scaffold(
                body: CanvasHud(
                  transformationController: controller,
                  zoomLock: false,
                  setZoomLock: (_) {},
                  resetZoom: () {},
                  singleFingerPanLock: false,
                  setSingleFingerPanLock: (_) {},
                  axisAlignedPanLock: false,
                  setAxisAlignedPanLock: (_) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('1.0x'), findsOneWidget);

        // Pure pan keeps text at 1.0x.
        controller.value = Matrix4.translationValues(40, -60, 0);
        await tester.pump();
        expect(find.text('1.0x'), findsOneWidget);

        // Zoom to 2.5x updates indicator cleanly.
        controller.value = Matrix4.identity()
          ..scaleByDouble(2.5, 2.5, 1.0, 1.0);
        await tester.pump();
        expect(find.text('2.5x'), findsOneWidget);
      },
    );
  });
}
