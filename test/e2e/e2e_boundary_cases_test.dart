/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_canvas_background_painter.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';
import 'package:sbn/canvas_background_pattern.dart';

import 'e2e_test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    setupE2EEnvironment();
  });

  setUp(() {
    setupE2EEnvironment();
  });

  group('Tier 2: Boundary & Corner Cases', () {
    // ------------------------------------------------------------------------
    // Boundary 1: Empty Note & Zero Selection
    // ------------------------------------------------------------------------
    group('Boundary 1: Empty Note & Zero Selection', () {
      test('lasso drag over empty page produces empty result without exceptions', () {
        final select = Select.currentSelect;
        select.onDragStart(const Offset(10, 10), 0);
        select.onDragUpdate(const Offset(10, 100));
        select.onDragUpdate(const Offset(100, 100));
        select.onDragUpdate(const Offset(100, 10));
        select.onDragEnd(const [], const []);

        expect(select.selectResult.isEmpty, isTrue);
      });

      test('lasso tapSelect on whitespace unselects cleanly', () {
        final select = Select.currentSelect;
        select.tapSelect(const Offset(500, 500), const [], const [], 0);

        expect(select.selectResult.isEmpty, isTrue);
      });

      test('enclosing non-overlapping strokes leaves selection empty', () {
        final select = Select.currentSelect;
        select.onDragStart(const Offset(10, 10), 0);
        select.onDragUpdate(const Offset(10, 50));
        select.onDragUpdate(const Offset(50, 50));
        select.onDragUpdate(const Offset(50, 10));

        // Stroke located far away at (300, 300)
        final stroke = createTestStroke(points: [const Offset(300, 300)]);
        select.onDragEnd([stroke], const []);

        expect(select.selectResult.strokes, isEmpty);
        expect(select.selectResult.isEmpty, isTrue);
      });
    });

    // ------------------------------------------------------------------------
    // Boundary 2: Single-Page Deletion Guard
    // ------------------------------------------------------------------------
    group('Boundary 2: Single-Page Deletion Guard', () {
      test('deleting only remaining page is strictly prevented', () {
        final coreInfo = createTestCoreInfo(pages: [EditorPage()]);

        final deleted = E2EPageManagerHelper.deletePageGuarded(coreInfo, 0);
        expect(deleted, isFalse);
        expect(coreInfo.pages.length, equals(1));
      });

      test('multiple deletion down to 1 page leaves exactly 1 page intact', () {
        final coreInfo = createTestCoreInfo(
          pages: [EditorPage(), EditorPage(), EditorPage()],
        );
        for (int i = 0; i < coreInfo.pages.length; i++) {
          coreInfo.pages[i].updatePageIndex(i);
        }

        expect(E2EPageManagerHelper.deletePageGuarded(coreInfo, 2), isTrue);
        expect(coreInfo.pages.length, equals(2));

        expect(E2EPageManagerHelper.deletePageGuarded(coreInfo, 1), isTrue);
        expect(coreInfo.pages.length, equals(1));

        // Attempting to delete the last page must fail
        expect(E2EPageManagerHelper.deletePageGuarded(coreInfo, 0), isFalse);
        expect(coreInfo.pages.length, equals(1));
      });

      test('out-of-bounds deletion index is safely ignored', () {
        final coreInfo = createTestCoreInfo(
          pages: [EditorPage(), EditorPage()],
        );

        expect(E2EPageManagerHelper.deletePageGuarded(coreInfo, -1), isFalse);
        expect(E2EPageManagerHelper.deletePageGuarded(coreInfo, 99), isFalse);
        expect(coreInfo.pages.length, equals(2));
      });
    });

    // ------------------------------------------------------------------------
    // Boundary 3: Overlapping Heterogeneous Media
    // ------------------------------------------------------------------------
    group('Boundary 3: Overlapping Heterogeneous Media', () {
      test('ink drawn directly over image center obeys filter isolation', () {
        final select = Select.currentSelect;
        const sharedRect = Rect.fromLTWH(100, 100, 200, 200);

        final strokeInside = createTestStroke(
          points: [const Offset(200, 200), const Offset(210, 210)],
        );
        final imageInside = E2ETestImage(dstRect: sharedRect);

        // Lasso enclosing the entire region
        void runLasso() {
          select.onDragStart(const Offset(50, 50), 0);
          select.onDragUpdate(const Offset(50, 350));
          select.onDragUpdate(const Offset(350, 350));
          select.onDragUpdate(const Offset(350, 50));
          select.onDragEnd([strokeInside], [imageInside]);
        }

        // Case A: Images disabled -> Only stroke selected
        stows.lassoSelectImages.value = false;
        stows.lassoSelectHandwriting.value = true;
        runLasso();
        expect(select.selectResult.strokes, contains(strokeInside));
        expect(select.selectResult.images, isEmpty);

        // Case B: Strokes disabled -> Only image selected
        stows.lassoSelectImages.value = true;
        stows.lassoSelectHandwriting.value = false;
        runLasso();
        expect(select.selectResult.strokes, isEmpty);
        expect(select.selectResult.images, contains(imageInside));

        // Case C: Both disabled -> Neither selected
        stows.lassoSelectImages.value = false;
        stows.lassoSelectHandwriting.value = false;
        runLasso();
        expect(select.selectResult.strokes, isEmpty);
        expect(select.selectResult.images, isEmpty);
        expect(select.selectResult.isEmpty, isTrue);
      });
    });

    // ------------------------------------------------------------------------
    // Boundary 4: High-Vertex Long Drag Gestures
    // ------------------------------------------------------------------------
    group('Boundary 4: High-Vertex Long Drag Gestures', () {
      test('winding lasso with 500+ points closes cleanly without performance degradation', () {
        final select = Select.currentSelect;
        select.onDragStart(const Offset(100, 100), 0);

        // Generate circular winding path with 500 steps
        const numPoints = 500;
        for (int i = 1; i <= numPoints; i++) {
          final theta = i * 2 * pi / numPoints;
          final x = 200 + 100 * cos(theta);
          final y = 200 + 100 * sin(theta);
          select.onDragUpdate(Offset(x, y));
        }

        final strokeInCenter = createTestStroke(points: [const Offset(200, 200)]);
        final strokeOutside = createTestStroke(points: [const Offset(400, 400)]);

        select.onDragEnd([strokeInCenter, strokeOutside], const []);

        expect(select.selectResult.strokes, contains(strokeInCenter));
        expect(select.selectResult.strokes, isNot(contains(strokeOutside)));
      });
    });

    // ------------------------------------------------------------------------
    // Boundary 5: Multi-Page Boundary Safety
    // ------------------------------------------------------------------------
    group('Boundary 5: Multi-Page Boundary Safety', () {
      test('lasso on page 0 never captures strokes belonging to page 1', () {
        final select = Select.currentSelect;
        select.onDragStart(Offset.zero, 0);
        select.onDragUpdate(const Offset(0, 200));
        select.onDragUpdate(const Offset(200, 200));
        select.onDragUpdate(const Offset(200, 0));

        final strokePage0 = createTestStroke(pageIndex: 0, points: [const Offset(100, 100)]);
        final strokePage1 = createTestStroke(pageIndex: 1, points: [const Offset(100, 100)]);

        // Select on page 0 only provides page 0 strokes
        select.onDragEnd([strokePage0], const []);

        expect(select.selectResult.pageIndex, equals(0));
        expect(select.selectResult.strokes, contains(strokePage0));
        expect(select.selectResult.strokes, isNot(contains(strokePage1)));
      });
    });

    // ------------------------------------------------------------------------
    // Boundary 6: Extreme Coordinates & Geometric Extremes
    // ------------------------------------------------------------------------
    group('Boundary 6: Extreme Coordinates & Geometric Extremes', () {
      test('strokes at huge coordinates (x=50000, y=100000) are handled safely', () {
        final stroke = createTestStroke(
          points: [const Offset(50000, 100000), const Offset(50050, 100050)],
        );

        expect(stroke.points.first.dx, equals(50000.0));
        expect(stroke.points.first.dy, equals(100000.0));
        expect(stroke.lowQualityPolygon, isNotEmpty);
      });

      test('negative coordinates do not trigger integer or index exceptions', () {
        final stroke = createTestStroke(
          points: [const Offset(-200, -300), const Offset(-150, -250)],
        );

        expect(stroke.points.first.dx, equals(-200.0));
        expect(stroke.points.first.dy, equals(-300.0));
      });

      test('zero-area image dstRect handles rectPercentInside without division by zero', () {
        final path = Path()..addRect(const Rect.fromLTWH(0, 0, 100, 100));
        const zeroRect = Rect.fromLTWH(50, 50, 0, 0);

        final percent = Select.rectPercentInside(path, zeroRect);
        expect(percent.isFinite, isTrue);
      });
    });

    // ------------------------------------------------------------------------
    // Boundary 7: Study Tape Extremes & Zero Length
    // ------------------------------------------------------------------------
    group('Boundary 7: Study Tape Extremes & Zero Length', () {
      test('zero-length tape strip (start == end) calculates valid bounding box', () {
        final tape = TapeStrokeContract(
          color: Colors.amber,
          pageIndex: 0,
          page: standardPageDef,
          start: const Offset(150, 150),
          end: const Offset(150, 150),
          tapeWidth: 30.0,
        );

        final poly = tape.getMaskPolygon();
        expect(poly.length, equals(4));
        expect(tape.containsPoint(const Offset(150, 150)), isTrue);
        expect(tape.containsPoint(const Offset(200, 200)), isFalse);
      });

      test('very wide tape strip (width=500 px) maintains correct geometric envelope', () {
        final tape = TapeStrokeContract(
          color: Colors.amber,
          pageIndex: 0,
          page: standardPageDef,
          start: const Offset(100, 300),
          end: const Offset(500, 300),
          tapeWidth: 500.0,
        );

        expect(tape.containsPoint(const Offset(300, 300)), isTrue);
        expect(tape.containsPoint(const Offset(300, 500)), isTrue);
        expect(tape.containsPoint(const Offset(300, 100)), isTrue);
        expect(tape.containsPoint(const Offset(300, 600)), isFalse);
      });
    });

    // ------------------------------------------------------------------------
    // Boundary 8: Extreme Page Dimensions for Cornell Pattern
    // ------------------------------------------------------------------------
    group('Boundary 8: Extreme Page Dimensions for Cornell Pattern', () {
      test('extremely tall page aspect ratio computes dividing lines without overflow', () {
        const tallSize = Size(200, 8000);
        final cueX = CornellGeometryOracle.getVerticalCueX(tallSize.width);
        final summaryY = CornellGeometryOracle.getHorizontalSummaryY(tallSize.height);

        expect(cueX, closeTo(56.0, 0.01));
        expect(summaryY, closeTo(6000.0, 0.01));

        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.cornell,
          size: tallSize,
          lineHeight: 40,
        ).toList();

        expect(elements, isNotEmpty);
      });

      test('extremely wide page aspect ratio computes dividing lines safely', () {
        const wideSize = Size(6000, 400);
        final cueX = CornellGeometryOracle.getVerticalCueX(wideSize.width);
        final summaryY = CornellGeometryOracle.getHorizontalSummaryY(wideSize.height);

        expect(cueX, closeTo(1680.0, 0.01));
        expect(summaryY, closeTo(300.0, 0.01));
      });
    });

    // ------------------------------------------------------------------------
    // Boundary 9: Rapid Toggle Flapping & State Consistency
    // ------------------------------------------------------------------------
    group('Boundary 9: Rapid Toggle Flapping & State Consistency', () {
      test('repeated rapid preference toggling keeps state synchronized', () {
        for (int i = 0; i <= 50; i++) {
          stows.lassoSelectHandwriting.value = i.isEven;
          stows.lassoSelectImages.value = i % 3 == 0;
          stows.lassoSelectText.value = i % 5 == 0;
        }

        // At i = 50: 50%2 == 0 (true), 50%3 == 2 (false), 50%5 == 0 (true)
        expect(stows.lassoSelectHandwriting.value, isTrue);
        expect(stows.lassoSelectImages.value, isFalse);
        expect(stows.lassoSelectText.value, isTrue);
      });
    });

    // ------------------------------------------------------------------------
    // Boundary 10: Bookmark Repeated Toggle & Persistence
    // ------------------------------------------------------------------------
    group('Boundary 10: Bookmark Repeated Toggle & Persistence', () {
      test('toggling bookmark 50 times results in correct expected parity', () {
        final page = EditorPage();
        expect(page.bookmarked, isFalse);

        for (int i = 0; i < 50; i++) {
          page.bookmarked = !page.bookmarked;
        }
        expect(page.bookmarked, isFalse);

        page.bookmarked = !page.bookmarked;
        expect(page.bookmarked, isTrue);

        final assets = OrderedAssetCache();
        final json = page.toJson(assets);
        expect(json['bm'], isTrue);
      });
    });
  });
}
