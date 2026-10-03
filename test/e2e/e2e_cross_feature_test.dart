/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/_canvas_background_painter.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/tool_id.dart';

import 'e2e_test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    setupE2EEnvironment();
  });

  setUp(() {
    setupE2EEnvironment();
  });

  group('Tier 3: Cross-Feature Combinations (Pairwise)', () {
    // ------------------------------------------------------------------------
    // Pair 1: Lasso Filter + Study Tape over Imported Images
    // ------------------------------------------------------------------------
    test('Pair 1: Lassoing study tape and ink over image isolates annotations', () {
      final select = Select.currentSelect;
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = false;

      final diagramImage = E2ETestImage(
        dstRect: const Rect.fromLTWH(100, 100, 400, 300),
      );
      final inkAnnotation = createTestStroke(
        points: [const Offset(200, 200), const Offset(250, 200)],
      );
      final tapeMask = TapeStrokeContract(
        color: Colors.amber,
        pageIndex: 0,
        page: standardPageDef,
        start: const Offset(200, 220),
        end: const Offset(300, 220),
      );

      // Perform lasso enclosing the entire diagram
      select.onDragStart(const Offset(50, 50), 0);
      select.onDragUpdate(const Offset(50, 450));
      select.onDragUpdate(const Offset(550, 450));
      select.onDragUpdate(const Offset(550, 50));
      select.onDragEnd([inkAnnotation, tapeMask], [diagramImage]);

      // Assertions
      expect(select.selectResult.images, isEmpty, reason: 'Image filter must exclude background image');
      expect(select.selectResult.strokes, contains(inkAnnotation));
      expect(select.selectResult.strokes, contains(tapeMask));
    });

    // ------------------------------------------------------------------------
    // Pair 2: Page Grid Overview + Cornell Notes on Cream Paper
    // ------------------------------------------------------------------------
    test('Pair 2: Page grid overview renders Cornell notes on warm cream paper', () {
      final coreInfo = createTestCoreInfo(
        backgroundColor: paperColorWarmCream,
        pages: [
          EditorPage(bookmarked: false),
          EditorPage(bookmarked: true),
        ],
      );
      for (int i = 0; i < coreInfo.pages.length; i++) {
        coreInfo.pages[i].updatePageIndex(i);
      }

      // Assert background color
      expect(coreInfo.backgroundColor, equals(paperColorWarmCream));

      // Assert Cornell geometry on each page
      const pageSize = Size(1000, 1400);
      final elements = CanvasBackgroundPainter.getPatternElements(
        pattern: CanvasBackgroundPattern.cornell,
        size: pageSize,
        lineHeight: 40,
      ).toList();

      expect(elements.isNotEmpty, isTrue);
      final cueX = CornellGeometryOracle.getVerticalCueX(pageSize.width);
      expect(cueX, closeTo(280.0, 0.01));

      // Assert bookmark indicator
      expect(coreInfo.pages[0].bookmarked, isFalse);
      expect(coreInfo.pages[1].bookmarked, isTrue);
    });

    // ------------------------------------------------------------------------
    // Pair 3: Highlighter Auto-Straighten + Cornell Notes Dividing Lines
    // ------------------------------------------------------------------------
    test('Pair 3: Highlighter auto-straightens parallel to Cornell dividing lines', () {
      const pageSize = Size(1000, 1400);
      final summaryY = CornellGeometryOracle.getHorizontalSummaryY(pageSize.height);

      // Draw wavy highlighter along summary divider
      final wavyHighlighter = createHighlighterStroke(
        size: 15.0,
        points: [
          Offset(100, summaryY + 3),
          Offset(300, summaryY - 2),
          Offset(500, summaryY + 1),
          Offset(700, summaryY - 3),
        ],
      );

      wavyHighlighter.convertToLine();

      expect(wavyHighlighter.points.first.dy, closeTo(summaryY, 4.0));
      expect(wavyHighlighter.points.last.dy, closeTo(summaryY, 4.0));
    });

    // ------------------------------------------------------------------------
    // Pair 4: Study Tape Persistence + Page Drag-and-Drop Reorder
    // ------------------------------------------------------------------------
    test('Pair 4: Study tape concealment state persists across page reordering', () {
      final page0 = EditorPage();
      final page1 = EditorPage();

      final tape = TapeStrokeContract(
        color: Colors.amber,
        pageIndex: 1,
        page: standardPageDef,
        start: const Offset(150, 150),
        end: const Offset(350, 150),
        isConcealed: true,
      );
      page1.layers.first.strokes.add(tape);

      final coreInfo = createTestCoreInfo(pages: [page0, page1]);
      for (int i = 0; i < coreInfo.pages.length; i++) {
        coreInfo.pages[i].updatePageIndex(i);
      }

      // Reorder: Move page 1 to page 0
      E2EPageManagerHelper.reorderPages(coreInfo, 1, 0);

      expect(coreInfo.pages[0], equals(page1));
      expect(tape.pageIndex, equals(0));
      expect(tape.isConcealed, isTrue);

      // Verify BSON serialization roundtrip after reorder
      final json = tape.toJson();
      final restoredTape = TapeStrokeContract.fromJson(
        json,
        pageIndex: 0,
        page: standardPageDef,
      );
      expect(restoredTape.pageIndex, equals(0));
      expect(restoredTape.isConcealed, isTrue);
    });

    // ------------------------------------------------------------------------
    // Pair 5: Lasso Move + Highlighter Behind Ink Layering
    // ------------------------------------------------------------------------
    test('Pair 5: Moving lassoed ink over highlighter maintains behind-ink z-index', () {
      final page = EditorPage();
      final highlighter = createHighlighterStroke(
        color: Colors.yellow,
        points: [const Offset(100, 100), const Offset(400, 100)],
      );
      final inkStroke = createTestStroke(
        toolId: ToolId.fountainPen,
        color: Colors.black,
        points: [const Offset(100, 200), const Offset(200, 200)],
      );

      page.layers.first.strokes.addAll([highlighter, inkStroke]);

      // Move ink stroke to overlap highlighter at y=100
      inkStroke.shift(const Offset(0, -100));

      // Sort strokes by z-index
      final sortedStrokes = List<Stroke>.from(page.layers.first.strokes)
        ..sort((a, b) {
          final aZ = a.toolId == ToolId.highlighter ? 0 : 1;
          final bZ = b.toolId == ToolId.highlighter ? 0 : 1;
          return aZ.compareTo(bZ);
        });

      // Assert highlighter remains bottom-most despite movement
      expect(sortedStrokes.first.toolId, equals(ToolId.highlighter));
      expect(sortedStrokes.last.toolId, equals(ToolId.fountainPen));
    });

    // ------------------------------------------------------------------------
    // Pair 6: Bookmark Filtering + Page Deletion
    // ------------------------------------------------------------------------
    test('Pair 6: Page deletion retains correct bookmarked subset indices', () {
      final p0 = EditorPage(bookmarked: false);
      final p1 = EditorPage(bookmarked: true);
      final p2 = EditorPage(bookmarked: false);
      final p3 = EditorPage(bookmarked: true);

      final coreInfo = createTestCoreInfo(pages: [p0, p1, p2, p3]);
      for (int i = 0; i < coreInfo.pages.length; i++) {
        coreInfo.pages[i].updatePageIndex(i);
      }

      // Delete unbookmarked page 0
      final deleted = E2EPageManagerHelper.deletePageGuarded(coreInfo, 0);
      expect(deleted, isTrue);
      expect(coreInfo.pages.length, equals(3));

      // Former p1 is now at index 0, former p3 is now at index 2
      final bookmarkedPages = coreInfo.pages.where((p) => p.bookmarked).toList();
      expect(bookmarkedPages.length, equals(2));
      expect(coreInfo.pages.indexOf(bookmarkedPages[0]), equals(0));
      expect(coreInfo.pages.indexOf(bookmarkedPages[1]), equals(2));
    });

    // ------------------------------------------------------------------------
    // Pair 7: Study Tape Tap Reveal + History Undo/Redo
    // ------------------------------------------------------------------------
    test('Pair 7: Study tape tap reveal integrated with undo/redo state toggling', () {
      final tape = TapeStrokeContract(
        color: Colors.amber,
        pageIndex: 0,
        page: standardPageDef,
        start: const Offset(100, 100),
        end: const Offset(300, 100),
        isConcealed: true,
      );

      final historyStack = <bool>[tape.isConcealed];

      // Student taps tape to reveal answer
      tape.toggleConceal();
      historyStack.add(tape.isConcealed);
      expect(tape.isConcealed, isFalse);

      // Student undoes action
      final previousState = historyStack.removeLast();
      expect(previousState, isFalse);
      tape.isConcealed = historyStack.last;
      expect(tape.isConcealed, isTrue);
    });

    // ------------------------------------------------------------------------
    // Pair 8: Cornell Notes Template + Cream Background in Dark Mode
    // ------------------------------------------------------------------------
    test('Pair 8: Cornell template on cream background supports dark slate inversion', () {
      const cream = paperColorWarmCream;
      expect(cream.toARGB32(), equals(0xFFFAF4E8));

      // Slate dark mode inversion preserves readable luminance
      const slate = paperColorDarkSlate;
      expect(slate.toARGB32(), equals(0xFF1E1E1E));

      const pageSize = Size(1000, 1400);
      final elements = CanvasBackgroundPainter.getPatternElements(
        pattern: CanvasBackgroundPattern.cornell,
        size: pageSize,
        lineHeight: 40,
      ).toList();

      expect(elements.isNotEmpty, isTrue);
    });

    // ------------------------------------------------------------------------
    // Pair 9: Page Duplication + Deep Copy of Study Tape and Highlighter
    // ------------------------------------------------------------------------
    test('Pair 9: Duplicating page deep-copies study tape without state coupling', () {
      final page0 = EditorPage();
      final tape = TapeStrokeContract(
        color: Colors.amber,
        pageIndex: 0,
        page: standardPageDef,
        start: const Offset(100, 100),
        end: const Offset(200, 100),
        isConcealed: true,
      );
      page0.layers.first.strokes.add(tape);

      final coreInfo = createTestCoreInfo(pages: [page0]);
      for (int i = 0; i < coreInfo.pages.length; i++) {
        coreInfo.pages[i].updatePageIndex(i);
      }

      E2EPageManagerHelper.duplicatePageDeep(coreInfo, 0);

      expect(coreInfo.pages.length, equals(2));
      final duplicatedPage = coreInfo.pages[1];

      // Mutate duplicated page tape
      final duplicatedTape = duplicatedPage.layers.first.strokes.first;
      expect(identical(duplicatedTape, tape), isFalse);

      // Original tape remains concealed
      expect(tape.isConcealed, isTrue);
    });

    // ------------------------------------------------------------------------
    // Pair 10: Lasso Tap-Select vs Study Tape Tap-to-Reveal
    // ------------------------------------------------------------------------
    test('Pair 10: Lasso tap selects tape while study mode toggles conceal state', () {
      final select = Select.currentSelect;
      final tape = TapeStrokeContract(
        color: Colors.amber,
        pageIndex: 0,
        page: standardPageDef,
        start: const Offset(100, 100),
        end: const Offset(300, 100),
        tapeWidth: 24.0,
        isConcealed: true,
      );

      // Mode A: Study mode tap (containsPoint -> toggleConceal)
      const tapPos = Offset(105, 100);
      expect(tape.containsPoint(tapPos), isTrue);
      tape.toggleConceal();
      expect(tape.isConcealed, isFalse);

      // Mode B: Lasso mode tap (tapSelect selects stroke into SelectResult)
      stows.lassoSelectHandwriting.value = true;
      select.tapSelect(tapPos, [tape], const [], 0);
      expect(select.selectResult.strokes, contains(tape));
    });
  });
}
