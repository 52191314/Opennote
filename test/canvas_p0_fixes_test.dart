/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_circle_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_polygon_stroke.dart';
import 'package:saber/components/canvas/_rectangle_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/canvas_image.dart';
import 'package:saber/components/canvas/hud/protractor_overlay.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/components/canvas/lasso_callout_menu.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/gestures/pen_gesture.dart';
import 'package:saber/data/editor/gestures/tool_gesture.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/circle_to_select_detector.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

class _TestPage implements HasSize {
  @override
  Size get size => const Size(1000, 1400);
  const _TestPage();
}

class _FakeGestureHost implements EditorGestureHost {
  _FakeGestureHost(this.currentTool);

  @override
  final Tool currentTool;
  @override
  final history = EditorHistory();
  @override
  int get lineHeight => 40;
  @override
  double get currentScale => 1.0;

  var createPageCalls = 0;

  @override
  void createPage(int pageIndex) => createPageCalls++;
  @override
  void removeExcessPages() {}
  @override
  void restoreToolAfterErasing() {}
  @override
  void autosaveAfterDelay() {}
  @override
  void deleteSelection(EditorPage page) {}
}

SvgEditorImage _makeTestImage({
  required Rect dstRect,
  required Rect srcRect,
  required Size naturalSize,
  required void Function() onMiscChange,
}) => SvgEditorImage(
  id: 1,
  assetCache: AssetCache(),
  svgString:
      '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100"/>',
  svgFile: null,
  pageIndex: 0,
  pageSize: const Size(500, 700),
  onMoveImage: null,
  onDeleteImage: null,
  onMiscChange: onMiscChange,
  dstRect: dstRect,
  srcRect: srcRect,
  naturalSize: naturalSize,
  newImage: true,
);

void main() {
  FlavorConfig.setup();

  group('P0 #1: Shape serialization & SVG Y-axis inversion', () {
    const page = _TestPage();
    const fill = Color(0x802563EB);

    test('CircleStroke preserves fc, ls, ty and flips Y in toSvgPath', () {
      final original = CircleStroke(
        color: Colors.red,
        pressureEnabled: false,
        options: StrokeOptions(size: 6),
        pageIndex: 0,
        page: page,
        toolId: ToolId.ballpointPen,
        center: const Offset(100, 200),
        radius: 50,
        fillColor: fill,
        lineStyle: LineStyle.dashed,
      );

      final json = original.toJson();
      expect(json['fc'], fill.toARGB32());
      expect(json['ls'], 'dashed');
      expect(json['ty'], ToolId.ballpointPen.id);

      final decoded =
          Stroke.fromJson(json, fileVersion: 19, pageIndex: 0, page: page)
              as CircleStroke;
      expect(decoded.fillColor?.toARGB32(), fill.toARGB32());
      expect(decoded.lineStyle, LineStyle.dashed);
      expect(decoded.toolId, ToolId.ballpointPen);

      expect(original.toSvgPath(), startsWith('M100.0,1200.0 '));
    });

    test('RectangleStroke preserves fc, ls, ty and flips Y in toSvgPath', () {
      final original = RectangleStroke(
        color: Colors.green,
        pressureEnabled: false,
        options: StrokeOptions(size: 4),
        pageIndex: 0,
        page: page,
        toolId: ToolId.ballpointPen,
        rect: const Rect.fromLTRB(10, 100, 110, 300),
        fillColor: fill,
        lineStyle: LineStyle.dotted,
      );

      final json = original.toJson();
      expect(json['fc'], fill.toARGB32());
      expect(json['ls'], 'dotted');
      expect(json['ty'], ToolId.ballpointPen.id);

      final decoded =
          Stroke.fromJson(json, fileVersion: 19, pageIndex: 0, page: page)
              as RectangleStroke;
      expect(decoded.fillColor?.toARGB32(), fill.toARGB32());
      expect(decoded.lineStyle, LineStyle.dotted);
      expect(decoded.toolId, ToolId.ballpointPen);

      expect(
        original.toSvgPath(),
        'M10.0,1300.0 L110.0,1300.0 L110.0,1100.0 L10.0,1100.0 Z',
      );
    });

    test('ArrowStroke, DimensionStroke, PolygonStroke restore fc and ls', () {
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 4),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(10, 20),
        end: const Offset(100, 200),
        fillColor: fill,
        lineStyle: LineStyle.dashed,
      );
      final decodedArrow =
          Stroke.fromJson(
                arrow.toJson(),
                fileVersion: 19,
                pageIndex: 0,
                page: page,
              )
              as ArrowStroke;
      expect(decodedArrow.fillColor?.toARGB32(), fill.toARGB32());
      expect(decodedArrow.lineStyle, LineStyle.dashed);

      final dim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 3),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        start: const Offset(10, 20),
        end: const Offset(110, 20),
        text: '100mm',
        fillColor: fill,
        lineStyle: LineStyle.dotted,
      );
      final decodedDim =
          Stroke.fromJson(
                dim.toJson(),
                fileVersion: 19,
                pageIndex: 0,
                page: page,
              )
              as DimensionStroke;
      expect(decodedDim.fillColor?.toARGB32(), fill.toARGB32());
      expect(decodedDim.lineStyle, LineStyle.dotted);

      final poly = PolygonStroke(
        color: Colors.purple,
        pressureEnabled: false,
        options: StrokeOptions(size: 4),
        pageIndex: 0,
        page: page,
        toolId: ToolId.shapePen,
        vertices: const [Offset(0, 100), Offset(50, 200), Offset(100, 100)],
        fillColor: fill,
        lineStyle: LineStyle.dashed,
      );
      final decodedPoly =
          Stroke.fromJson(
                poly.toJson(),
                fileVersion: 19,
                pageIndex: 0,
                page: page,
              )
              as PolygonStroke;
      expect(decodedPoly.fillColor?.toARGB32(), fill.toARGB32());
      expect(decodedPoly.lineStyle, LineStyle.dashed);
      expect(poly.toSvgPath(), 'M0.0,1300.0 L50.0,1200.0 L100.0,1300.0 Z');
    });
  });

  group('P0 #2: ProtractorOverlay theme contrast', () {
    testWidgets('renders cleanly in light and dark themes and supports drag', (
      tester,
    ) async {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: const Scaffold(body: Stack(children: [ProtractorOverlay()])),
          ),
        );
        expect(find.byType(ProtractorOverlay), findsOneWidget);
        await tester.drag(find.byType(ProtractorOverlay), const Offset(25, 15));
        await tester.pump();
      }
    });
  });

  group('P0 #3: CircleToSelectDetector scale & jitter deadzone', () {
    test('micro-jitter within deadzone does not cancel holdTimer', () async {
      Path? detected;
      final detector = CircleToSelectDetector(
        holdDuration: const Duration(milliseconds: 80),
        onCircleDetected: (path) => detected = path,
      );

      const center = Offset(100, 100);
      const radius = 40.0;
      detector.start(const Offset(140, 100));
      for (int i = 1; i <= 16; i++) {
        final angle = i / 16 * 2 * pi;
        detector.update(
          center + Offset(cos(angle) * radius, sin(angle) * radius),
          scale: 1.0,
        );
      }

      // Simulate 120Hz stylus micro-jitter (<= 6px) while holding still.
      await Future<void>.delayed(const Duration(milliseconds: 30));
      detector.update(const Offset(141, 101), scale: 1.0);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      detector.update(const Offset(139, 99), scale: 1.0);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(detected, isNotNull);
      detector.dispose();
    });

    test(
      'physical-scale coordinates recognize loop at zoomed-out scale',
      () async {
        Path? detected;
        final detector = CircleToSelectDetector(
          holdDuration: const Duration(milliseconds: 40),
          onCircleDetected: (path) => detected = path,
        );

        // At scale 0.25, a 160-unit page circle is 40 physical px (> 20px).
        const center = Offset(400, 400);
        const radius = 80.0;
        detector.start(const Offset(480, 400));
        for (int i = 1; i <= 16; i++) {
          final angle = i / 16 * 2 * pi;
          detector.update(
            center + Offset(cos(angle) * radius, sin(angle) * radius),
            scale: 0.25,
          );
        }
        await Future<void>.delayed(const Duration(milliseconds: 70));

        expect(detected, isNotNull);
        detector.dispose();
      },
    );
  });

  group('P0 #4: EditorCoreInfo.copyWith preserves isInfiniteCanvas', () {
    test('copyWith keeps isInfiniteCanvas true and supports override', () {
      final info = EditorCoreInfo(
        filePath: '/test_infinite',
        isInfiniteCanvas: true,
      );
      final copied = info.copyWith(lineHeight: 60);
      expect(copied.isInfiniteCanvas, true);
      expect(copied.lineHeight, 60);

      final overridden = info.copyWith(isInfiniteCanvas: false);
      expect(overridden.isInfiniteCanvas, false);
    });
  });

  group('P0 #5: CanvasImage infinite-canvas drag & crop-end callback', () {
    testWidgets('infinite canvas drag does not clamp to pageSize', (
      tester,
    ) async {
      var miscChanges = 0;
      final image = _makeTestImage(
        dstRect: const Rect.fromLTWH(20, 20, 100, 100),
        srcRect: const Rect.fromLTWH(0, 0, 100, 100),
        naturalSize: const Size(100, 100),
        onMiscChange: () => miscChanges++,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeferredPointerHandler(
              child: Stack(
                children: [
                  CanvasImage(
                    filePath: '/test',
                    image: image,
                    pageSize: const Size(500, 700),
                    setAsBackground: null,
                    isInfiniteCanvas: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.drag(find.byType(CanvasImage), const Offset(-200, -150));
      await tester.pumpAndSettle();

      expect(image.dstRect.left, lessThan(-100));
      expect(image.dstRect.top, lessThan(-100));
      expect(miscChanges, 0);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('crop-end triggers onMiscChange callback', (tester) async {
      var miscChanges = 0;
      final image = _makeTestImage(
        dstRect: const Rect.fromLTWH(100, 100, 200, 200),
        srcRect: const Rect.fromLTWH(0, 0, 200, 200),
        naturalSize: const Size(200, 200),
        onMiscChange: () => miscChanges++,
      )..cropMode = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeferredPointerHandler(
              child: Stack(
                children: [
                  CanvasImage(
                    filePath: '/test_crop',
                    image: image,
                    pageSize: const Size(500, 700),
                    setAsBackground: null,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drag the bottom-right crop handle inward by (-40, -40).
      await tester.dragFrom(const Offset(300, 300), const Offset(-40, -40));
      await tester.pumpAndSettle();

      expect(miscChanges, 1);
      expect(image.srcRect.width, lessThan(200));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 6));
    });
  });

  group('P0 #6: PenGesture locked layer ghost history prevention', () {
    test('drawing on locked layer does not insert stroke or push history', () {
      final pen = Pen.fountainPen();
      final host = _FakeGestureHost(pen);
      final page = EditorPage();
      page.activeLayer.locked = true;

      final gesture = PenGesture(host, onCircleDetected: (_) {});
      gesture.start(
        GesturePointer(
          page: page,
          pageIndex: 0,
          position: const Offset(10, 10),
        ),
      );
      gesture.update(
        GesturePointer(
          page: page,
          pageIndex: 0,
          position: const Offset(50, 50),
        ),
      );
      gesture.end(
        GesturePointer(
          page: page,
          pageIndex: 0,
          position: const Offset(90, 90),
        ),
      );

      expect(page.strokes, isEmpty);
      expect(host.history.canUndo, false);
      expect(host.createPageCalls, 0);
    });
  });

  group('P0 #7: LassoCalloutMenu onDuplicate wiring', () {
    testWidgets('Duplicate button renders and triggers onDuplicate', (
      tester,
    ) async {
      var duplicated = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LassoCalloutMenu(
                onCut: () {},
                onCopy: () {},
                onDuplicate: () => duplicated = true,
                onDelete: () {},
                onSetColor: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Duplicate'), findsOneWidget);
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();
      expect(duplicated, true);
    });
  });
}
