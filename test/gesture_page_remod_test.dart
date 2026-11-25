/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/tool_id.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

Stroke _makeStroke({
  required EditorPage page,
  ToolId toolId = ToolId.fountainPen,
  Color color = Colors.black,
  int pageIndex = 0,
  List<Offset> points = const [Offset(10, 20), Offset(50, 120)],
}) {
  final stroke = Stroke(
    color: color,
    pressureEnabled: false,
    options: StrokeOptions(size: 5),
    pageIndex: pageIndex,
    page: page,
    toolId: toolId,
  );
  for (final p in points) {
    stroke.addPoint(p);
  }
  return stroke;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(FlavorConfig.setup);

  group('CanvasZoomPhysics', () {
    const bounds = BoxConstraints(
      minWidth: 400,
      maxWidth: 400,
      minHeight: 800,
      maxHeight: 800,
    );

    test('minScaleFor distinguishes infinite and paged modes', () {
      expect(
        CanvasZoomPhysics.minScaleFor(isInfiniteCanvas: true),
        CanvasGestureDetector.kInfiniteMinScale,
      );
      expect(
        CanvasZoomPhysics.minScaleFor(isInfiniteCanvas: false),
        CanvasGestureDetector.kPagedMinScale,
      );
    });

    test('shouldSnapZoomToOne snaps only near 1.0 within (0.001, 0.05)', () {
      expect(CanvasZoomPhysics.shouldSnapZoomToOne(1.0), isFalse);
      expect(CanvasZoomPhysics.shouldSnapZoomToOne(1.0005), isFalse);
      expect(CanvasZoomPhysics.shouldSnapZoomToOne(1.02), isTrue);
      expect(CanvasZoomPhysics.shouldSnapZoomToOne(0.97), isTrue);
      expect(CanvasZoomPhysics.shouldSnapZoomToOne(1.06), isFalse);
      expect(CanvasZoomPhysics.shouldSnapZoomToOne(0.94), isFalse);
      expect(CanvasZoomPhysics.shouldSnapZoomToOne(0), isFalse);
      expect(CanvasZoomPhysics.shouldSnapZoomToOne(-1), isFalse);
      expect(CanvasZoomPhysics.shouldSnapZoomToOne(double.nan), isFalse);
      expect(CanvasZoomPhysics.shouldSnapZoomToOne(double.infinity), isFalse);
    });

    test('computeZoomMatrix guards invalid bounds and scales', () {
      expect(
        CanvasZoomPhysics.computeZoomMatrix(
          scaleDelta: 0.2,
          transformation: Matrix4.identity(),
          containerBounds: const BoxConstraints(),
        ),
        isNull,
      );
      expect(
        CanvasZoomPhysics.computeZoomMatrix(
          scaleDelta: 0.2,
          transformation: Matrix4.zero(),
          containerBounds: bounds,
        ),
        isNull,
      );
    });

    test('computeZoomMatrix clamps to min/max and keeps Z scale at 1.0', () {
      final nearMax = Matrix4.identity()..scaleByDouble(9.9, 9.9, 1.0, 1.0);
      final clampedMax = CanvasZoomPhysics.computeZoomMatrix(
        scaleDelta: 0.5,
        transformation: nearMax,
        containerBounds: bounds,
      );
      expect(clampedMax, isNotNull);
      expect(
        clampedMax!.maxScale2D,
        closeTo(CanvasZoomPhysics.kMaxScale, 1e-6),
      );
      expect(clampedMax.storage[10], equals(1.0));

      final atMax = Matrix4.identity()
        ..scaleByDouble(
          CanvasZoomPhysics.kMaxScale,
          CanvasZoomPhysics.kMaxScale,
          1.0,
          1.0,
        );
      expect(
        CanvasZoomPhysics.computeZoomMatrix(
          scaleDelta: 0.1,
          transformation: atMax,
          containerBounds: bounds,
        ),
        isNull,
      );

      final nearMin = Matrix4.identity()..scaleByDouble(0.25, 0.25, 1.0, 1.0);
      final clampedMin = CanvasZoomPhysics.computeZoomMatrix(
        scaleDelta: -0.2,
        transformation: nearMin,
        containerBounds: bounds,
        minScale: CanvasZoomPhysics.kPagedMinScale,
      );
      expect(clampedMin, isNotNull);
      expect(
        clampedMin!.maxScale2D,
        closeTo(CanvasZoomPhysics.kPagedMinScale, 1e-6),
      );
      expect(clampedMin.storage[10], equals(1.0));
    });

    test('computeBoundsAdjustment skips infinite canvas and clamps paged', () {
      final pages = [EditorPage(size: const Size(1000, 1400))];
      final outOfBounds = Matrix4.translationValues(120, 80, 0)
        ..scaleByDouble(2.0, 2.0, 1.0, 1.0);

      final infiniteAdj = CanvasZoomPhysics.computeBoundsAdjustment(
        matrix: outOfBounds,
        containerBounds: bounds,
        pages: pages,
        isInfiniteCanvas: true,
      );
      expect(infiniteAdj.dx, 0.0);
      expect(infiniteAdj.dy, 0.0);

      final pagedAdj = CanvasZoomPhysics.computeBoundsAdjustment(
        matrix: outOfBounds,
        containerBounds: bounds,
        pages: pages,
        isInfiniteCanvas: false,
      );
      expect(pagedAdj.dx, closeTo(-120.0, 1e-6));
      expect(pagedAdj.dy, closeTo(-80.0, 1e-6));

      final constrained = CanvasZoomPhysics.constrainTransformMatrix(
        matrix: outOfBounds,
        containerBounds: bounds,
        pages: pages,
        isInfiniteCanvas: false,
      );
      expect(constrained.getTranslation().x, closeTo(0.0, 1e-6));
      expect(constrained.getTranslation().y, closeTo(0.0, 1e-6));
    });

    test('computeBoundsAdjustment centers horizontally when zoomed out', () {
      final pages = [EditorPage(size: const Size(1000, 1400))];
      final zoomedOut = Matrix4.translationValues(0, 500, 0)
        ..scaleByDouble(0.5, 0.5, 1.0, 1.0);

      final adj = CanvasZoomPhysics.computeBoundsAdjustment(
        matrix: zoomedOut,
        containerBounds: bounds,
        pages: pages,
        isInfiniteCanvas: false,
      );
      // Center for width=400, scale=0.5 is 400 * 0.5 / 2 = 100.
      expect(adj.dx, closeTo(100.0, 1e-6));
      // maxY for height=800, scale=0.5 is 0.5 * 800 * 0.5 = 200 -> dy = -300.
      expect(adj.dy, closeTo(-300.0, 1e-6));
    });
  });

  group('CanvasViewportProjection', () {
    test('getTopOfPage, getPageIndex, and scrollToPage stay consistent', () {
      final pages = [
        EditorPage(size: const Size(1000, 1000)),
        EditorPage(size: const Size(1000, 1400)),
        EditorPage(size: const Size(500, 500)),
      ];

      expect(
        CanvasViewportProjection.getTopOfPage(
          pageIndex: 0,
          pages: pages,
          screenWidth: 500,
        ),
        0,
      );
      // Page 0 fitted width = 500 -> fitted height = 500, plus 16 gap = 516.
      final top1 = CanvasViewportProjection.getTopOfPage(
        pageIndex: 1,
        pages: pages,
        screenWidth: 500,
      );
      expect(top1, closeTo(516.0, 1e-6));

      expect(
        CanvasViewportProjection.getPageIndex(
          scrollY: -10,
          pages: pages,
          screenWidth: 500,
        ),
        0,
      );
      expect(
        CanvasViewportProjection.getPageIndex(
          scrollY: 600,
          pages: pages,
          screenWidth: 500,
        ),
        1,
      );
      expect(
        CanvasViewportProjection.getPageIndex(
          scrollY: 100000,
          pages: pages,
          screenWidth: 500,
        ),
        2,
      );

      final controller = TransformationController();
      addTearDown(controller.dispose);
      CanvasGestureDetector.scrollToPage(
        pageIndex: 1,
        pages: pages,
        screenWidth: 500,
        transformationController: controller,
      );
      expect(controller.value.getTranslation().y, closeTo(-top1 + 50, 1e-6));
    });

    test(
      'axisAlignedBoundingBox and computePageLocalViewport clamp bounds',
      () {
        final quad = Quad.points(
          Vector3(10, 20, 0),
          Vector3(210, 10, 0),
          Vector3(200, 310, 0),
          Vector3(0, 300, 0),
        );
        final aabb = CanvasViewportProjection.axisAlignedBoundingBox(quad);
        expect(aabb, const Rect.fromLTRB(0, 10, 210, 310));

        final local = CanvasViewportProjection.computePageLocalViewport(
          pageSize: const Size(1000, 1400),
          pageWidth: 500,
          topOfPage: 100,
          containerWidth: 700,
          boundingBox: const Rect.fromLTRB(0, 50, 700, 500),
        );
        expect(local, isNotNull);
        expect(local!.left, 0.0);
        expect(local.top, 0.0);
        expect(local.right, 1000.0);
        expect(local.bottom, closeTo(800.0, 1e-6));

        expect(
          CanvasViewportProjection.computePageLocalViewport(
            pageSize: const Size(1000, 1400),
            pageWidth: 500,
            topOfPage: 0,
            containerWidth: 500,
            boundingBox: Rect.zero,
          ),
          isNull,
        );
      },
    );

    test(
      'evaluatePageRebuild defers high-zoom refresh during active gesture',
      () {
        final pages = [EditorPage(size: const Size(1000, 1400))];
        const bounds = BoxConstraints(maxWidth: 400, maxHeight: 800);
        final m1 = Matrix4.translationValues(-100, -100, 0)
          ..scaleByDouble(3.0, 3.0, 1.0, 1.0);
        final m2 = Matrix4.translationValues(-140, -140, 0)
          ..scaleByDouble(3.0, 3.0, 1.0, 1.0);

        final result = CanvasViewportProjection.evaluatePageRebuild(
          oldMatrix: m1,
          newMatrix: m2,
          viewportSize: const Size(400, 800),
          containerBounds: bounds,
          pages: pages,
          isInfiniteCanvas: false,
          isGestureActive: true,
        );
        expect(result.shouldRebuild, isFalse);
        expect(result.markHighZoomRefresh, isTrue);
      },
    );
  });

  group('EditorPage remodularized operations', () {
    test(
      'stroke insertion, sorting, replacement, removal, and layer locking',
      () {
        final page = EditorPage();
        addTearDown(page.dispose);

        final penStroke = _makeStroke(
          page: page,
          toolId: ToolId.fountainPen,
          color: Colors.blue,
        );
        final hlRed = _makeStroke(
          page: page,
          toolId: ToolId.highlighter,
          color: const Color(0xFFFF0000),
        );
        final hlGreen = _makeStroke(
          page: page,
          toolId: ToolId.highlighter,
          color: const Color(0xFF00FF00),
        );

        final v0 = page.strokesVersion;
        page.insertStroke(penStroke);
        page.insertStroke(hlRed);
        page.insertStroke(hlGreen);
        expect(page.strokesVersion, v0 + 3);
        expect(page.strokes.length, 3);

        // Highlighter strokes are sorted by ARGB32 color value.
        final hlStrokes = page.strokes
            .where((s) => s.toolId == ToolId.highlighter)
            .toList();
        expect(hlStrokes, [hlGreen, hlRed]);

        final replacement = _makeStroke(
          page: page,
          toolId: ToolId.fountainPen,
          color: Colors.purple,
        );
        expect(page.replaceStroke(penStroke, replacement), isTrue);
        expect(page.strokes.contains(replacement), isTrue);
        expect(page.strokes.contains(penStroke), isFalse);

        // Locked layer prevents insert and remove.
        page.activeLayer.locked = true;
        final blocked = _makeStroke(page: page);
        page.insertStroke(blocked);
        expect(page.strokes.contains(blocked), isFalse);
        expect(page.removeStroke(replacement), isFalse);

        // Unlocking allows removal.
        page.activeLayer.locked = false;
        expect(page.removeStroke(replacement), isTrue);
        expect(page.strokes.contains(replacement), isFalse);

        // Hidden layer excludes strokes from flattened getter.
        page.activeLayer.visible = false;
        expect(page.strokes, isEmpty);
        page.activeLayer.visible = true;
        expect(page.strokes.length, 2);
      },
    );

    test(
      'textPlacement, previewHeight, updatePageIndex, and cloneForRasterization',
      () {
        final page = EditorPage(size: const Size(1000, 1400));
        addTearDown(page.dispose);

        expect(page.isEmpty, isTrue);
        expect(page.previewHeight(lineHeight: 40), closeTo(140.0, 1e-6));

        final stroke = _makeStroke(
          page: page,
          points: const [Offset(10, 20), Offset(50, 500)],
        );
        page.insertStroke(stroke);
        expect(page.isNotEmpty, isTrue);
        expect(page.previewHeight(lineHeight: 40), greaterThan(500.0));

        page.textPlacement = (
          offset: const Offset(12, 34),
          rotation: 0.5,
          scale: 1.5,
        );
        expect(page.textContentOffset, const Offset(12, 34));
        expect(page.textContentRotation, 0.5);
        expect(page.textContentScale, 1.5);
        expect(page.computeTextContentRect(40), Rect.zero);

        page.quill.controller.document.insert(0, 'Hello\nWorld');
        final textRect = page.computeTextContentRect(40);
        expect(textRect.width, greaterThan(0));
        expect(textRect.height, closeTo(2 * 40 * 1.5, 1e-6));

        page.updatePageIndex(3);
        expect(stroke.pageIndex, 3);

        final cloned = page.cloneForRasterization(rasterizeAllStrokes: true);
        expect(cloned.layers.length, page.layers.length);
        expect(cloned.strokes.length, page.strokes.length);
        cloned.disposeClonedData();
      },
    );

    test(
      'EditorPage JSON round-trip preserves layers, metadata, and legacy format',
      () {
        final page = EditorPage(
          size: const Size(800, 1200),
          bookmarked: true,
          paperPattern: CanvasBackgroundPattern.grid,
          paperColor: const Color(0xFFFFF8DC),
          paperLineHeight: 36,
          paperLineThickness: 2,
          textContentOffset: const Offset(15, 25),
          textContentRotation: 0.25,
          textContentScale: 1.2,
          layers: [
            Layer(name: 'Base', visible: true, locked: false),
            Layer(name: 'Notes', visible: false, locked: true),
          ],
        );
        addTearDown(page.dispose);
        page.layers.first.strokes.add(_makeStroke(page: page));

        final json = page.toJson(OrderedAssetCache());
        final restored = EditorPage.fromJson(
          json,
          inlineAssets: const [],
          readOnly: false,
          fileVersion: EditorCoreInfo.sbnVersion,
          sbnPath: '/remod_test',
          assetCache: AssetCache(),
        );
        addTearDown(restored.dispose);

        expect(restored.size, const Size(800, 1200));
        expect(restored.bookmarked, isTrue);
        expect(restored.paperPattern, CanvasBackgroundPattern.grid);
        expect(restored.paperColor, const Color(0xFFFFF8DC));
        expect(restored.paperLineHeight, 36);
        expect(restored.paperLineThickness, 2);
        expect(restored.textContentOffset, const Offset(15, 25));
        expect(restored.textContentRotation, 0.25);
        expect(restored.textContentScale, 1.2);
        expect(restored.layers.length, 2);
        expect(restored.layers[0].name, 'Base');
        expect(restored.layers[0].strokes.length, 1);
        expect(restored.layers[1].name, 'Notes');
        expect(restored.layers[1].visible, isFalse);
        expect(restored.layers[1].locked, isTrue);

        // Legacy flat-stroke ('s') format deserialization
        final legacy = EditorPage.fromJson(
          {
            'w': 600.0,
            'h': 900.0,
            's': [page.layers.first.strokes.first.toJson()],
          },
          inlineAssets: const [],
          readOnly: false,
          fileVersion: EditorCoreInfo.sbnVersion,
          sbnPath: '/remod_legacy',
          assetCache: AssetCache(),
        );
        addTearDown(legacy.dispose);
        expect(legacy.size, const Size(600, 900));
        expect(legacy.layers.length, 1);
        expect(legacy.strokes.length, 1);

        expect(EditorPageSerialization.parseOffset(null), Offset.zero);
        expect(EditorPageSerialization.parseOffset([1]), Offset.zero);
        expect(
          EditorPageSerialization.parseOffset([4, 8.5]),
          const Offset(4, 8.5),
        );
      },
    );
  });
}
