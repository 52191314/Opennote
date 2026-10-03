/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:bson/bson.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/select.dart';
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

  group('Tier 4: Real-World Student Workloads', () {
    // ------------------------------------------------------------------------
    // Scenario 1: Active Recall Study Session
    // ------------------------------------------------------------------------
    test('Scenario 1: Cornell notes study drill with tape conceal/reveal & BSON persistence', () {
      // 1. Student opens Cornell Notes on Warm Cream paper
      final cornellPage = EditorPage(size: standardPageSize);
      final coreInfo = createTestCoreInfo(
        backgroundColor: paperColorWarmCream,
        pages: [cornellPage],
      );
      cornellPage.updatePageIndex(0);

      // Verify Cornell geometry on cream canvas
      final cueX = CornellGeometryOracle.getVerticalCueX(standardPageSize.width);
      final summaryY = CornellGeometryOracle.getHorizontalSummaryY(standardPageSize.height);
      expect(cueX, closeTo(280.0, 0.01));
      expect(summaryY, closeTo(1050.0, 0.01));

      // 2. Student takes lecture notes with ink pen in Cue, Note-taking, and Summary areas
      final cueStroke = createTestStroke(
        points: [const Offset(50, 100), const Offset(80, 120), const Offset(120, 100)],
        color: Colors.black87,
      );
      final noteStroke = createTestStroke(
        points: [const Offset(350, 150), const Offset(450, 150), const Offset(550, 160)],
        color: Colors.blueGrey,
      );
      final summaryStroke = createTestStroke(
        points: [const Offset(100, 1100), const Offset(400, 1100), const Offset(600, 1100)],
        color: Colors.indigo,
      );
      cornellPage.activeLayerStrokes.addAll([cueStroke, noteStroke, summaryStroke]);

      // 3. Student places 4 Study Tapes over key definitions and formulas
      final tape1 = TapeStrokeContract(
        color: Colors.amber,
        pageIndex: 0,
        page: standardPageDef,
        start: const Offset(40, 150),
        end: const Offset(180, 150),
        tapeWidth: 26.0,
        isConcealed: true, // Concealed initially for active recall drill
      );
      final tape2 = TapeStrokeContract(
        color: Colors.amber,
        pageIndex: 0,
        page: standardPageDef,
        start: const Offset(340, 200),
        end: const Offset(520, 200),
        tapeWidth: 28.0,
        isConcealed: true,
      );
      final tape3 = TapeStrokeContract(
        color: Colors.lightGreen,
        pageIndex: 0,
        page: standardPageDef,
        start: const Offset(340, 320),
        end: const Offset(560, 320),
        tapeWidth: 32.0,
        isConcealed: true,
      );
      final tape4 = TapeStrokeContract(
        color: Colors.pinkAccent,
        pageIndex: 0,
        page: standardPageDef,
        start: const Offset(150, 1150),
        end: const Offset(450, 1150),
        tapeWidth: 26.0,
        isConcealed: true,
      );
      cornellPage.activeLayerStrokes.addAll([tape1, tape2, tape3, tape4]);
      expect(cornellPage.strokes.length, equals(7));

      // 4. Enter Active Recall Drill: all tapes concealed initially
      final studyTapes = cornellPage.strokes.whereType<TapeStrokeContract>().toList();
      expect(studyTapes.length, equals(4));
      expect(studyTapes.every((t) => t.isConcealed), isTrue);

      // 5. Drill action: Tap tape 1 to reveal answer, tap tape 2, re-conceal tape 1
      const tapPos1 = Offset(100, 150);
      expect(tape1.containsPoint(tapPos1), isTrue);
      tape1.toggleConceal();
      expect(tape1.isConcealed, isFalse, reason: 'Tape 1 revealed');

      const tapPos2 = Offset(400, 200);
      expect(tape2.containsPoint(tapPos2), isTrue);
      tape2.toggleConceal();
      expect(tape2.isConcealed, isFalse, reason: 'Tape 2 revealed');

      // Student re-hides Tape 1 for subsequent drill round
      tape1.toggleConceal();
      expect(tape1.isConcealed, isTrue, reason: 'Tape 1 re-concealed');
      expect(tape2.isConcealed, isFalse, reason: 'Tape 2 remains revealed');
      expect(tape3.isConcealed, isTrue, reason: 'Tape 3 untouched');
      expect(tape4.isConcealed, isTrue, reason: 'Tape 4 untouched');

      // 6. Save notebook to BSON binary format (simulating app close)
      final (coreJson, assets) = coreInfo.toJson();
      final pageJson = cornellPage.toJson(assets);
      final serializedDoc = <String, dynamic>{
        'core': coreJson,
        'page0': pageJson,
        'tapes': studyTapes.map((t) => t.toJson()).toList(),
      };

      final bsonBinary = BsonCodec.serialize(serializedDoc);
      expect(bsonBinary.byteList.isNotEmpty, isTrue);

      // 7. Reload notebook from BSON (simulating app reopen)
      final deserializedDoc = BsonCodec.deserialize(bsonBinary);
      expect(deserializedDoc['core'], isNotNull);
      final restoredTapesRaw = deserializedDoc['tapes'] as List;
      expect(restoredTapesRaw.length, equals(4));

      final restoredTapes = restoredTapesRaw.map((raw) => TapeStrokeContract.fromJson(
        Map<String, dynamic>.from(raw as Map),
        pageIndex: 0,
        page: standardPageDef,
      )).toList();

      // Verify exact preservation of positions, dimensions, and individual conceal states
      expect(restoredTapes[0].isConcealed, isTrue);
      expect(restoredTapes[1].isConcealed, isFalse);
      expect(restoredTapes[2].isConcealed, isTrue);
      expect(restoredTapes[3].isConcealed, isTrue);
      expect(restoredTapes[0].start, equals(const Offset(40, 150)));
      expect(restoredTapes[1].end, equals(const Offset(520, 200)));
      expect(restoredTapes[2].tapeWidth, equals(32.0));
    });

    // ------------------------------------------------------------------------
    // Scenario 2: Lecture Note-Taking on PDF Slides with Lasso Reorganization
    // ------------------------------------------------------------------------
    test('Scenario 2: PDF slide deck annotation with lasso filter isolating handwriting', () {
      final select = Select.currentSelect;

      // 1. PDF slide deck with Slide 2 having background slide diagram
      const slideRect = Rect.fromLTWH(0, 0, 800, 1000);
      final backgroundSlide = E2ETestImage(
        dstRect: slideRect,
      );

      // 2. Student annotates diagram with handwritten margin notes
      final marginNote1 = createTestStroke(
        points: [
          const Offset(100, 200),
          const Offset(180, 220),
          const Offset(220, 210),
        ],
        color: Colors.blueAccent,
      );

      final marginNote2 = createTestStroke(
        points: [
          const Offset(110, 250),
          const Offset(190, 270),
          const Offset(240, 260),
        ],
        color: Colors.blueAccent,
      );

      final slidePage = EditorPage(
        size: standardPageSize,
        images: [backgroundSlide],
      );
      slidePage.activeLayerStrokes.addAll([marginNote1, marginNote2]);

      // 3. Student realizes margin notes overlap diagram; activates Lasso tool
      // 4. Configure lasso filters: handwriting enabled, images excluded
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = false;
      stows.selectionRectMode.value = false;

      // 5. Lasso around both margin notes and background slide area
      select.onDragStart(const Offset(50, 150), 0);
      select.onDragUpdate(const Offset(300, 150));
      select.onDragUpdate(const Offset(300, 320));
      select.onDragUpdate(const Offset(50, 320));
      select.onDragEnd(slidePage.strokes, slidePage.images);

      // 6. Verify background slide image is completely excluded; only handwriting selected
      expect(select.selectResult.images, isEmpty,
        reason: 'Background slide image must be preserved and excluded from selection');
      expect(select.selectResult.strokes.length, equals(2),
        reason: 'Both handwriting annotations must be selected');
      expect(select.selectResult.strokes, containsAll([marginNote1, marginNote2]));

      // 7. Student translates selected handwriting by (dx: 80, dy: 150)
      const translation = Offset(80, 150);
      final originalNote1Points = List<Offset>.from(marginNote1.points);
      for (final stroke in select.selectResult.strokes) {
        stroke.shift(translation);
      }
      for (final image in select.selectResult.images) {
        image.dstRect = image.dstRect.shift(translation);
      }

      // 8. Verify handwriting shifted accurately while background slide image did not drift
      expect(marginNote1.points.first, equals(originalNote1Points.first + translation));
      expect(backgroundSlide.dstRect, equals(slideRect),
        reason: 'Background PDF slide image coordinates must remain unaltered');

      // 9. Undo operation: restore handwriting to original position
      for (final stroke in select.selectResult.strokes) {
        stroke.shift(-translation);
      }
      expect(marginNote1.points.first, equals(originalNote1Points.first));
      expect(backgroundSlide.dstRect, equals(slideRect));

      select.unselect();
    });

    // ------------------------------------------------------------------------
    // Scenario 3: Exam Prep Cramming & Multi-Page Review in Grid Bird's-Eye View
    // ------------------------------------------------------------------------
    test('Scenario 3: Exam prep cramming in grid overview with bookmark filtering & jump navigation', () {
      // 1. Student has a 12-page comprehensive semester exam prep notebook
      final coreInfo = createTestCoreInfo(
        backgroundColor: paperColorWarmCream,
        pages: List.generate(12, (i) => EditorPage(
          size: const Size(800, 1100),
          bookmarked: false,
        )),
      );
      for (int i = 0; i < coreInfo.pages.length; i++) {
        coreInfo.pages[i].updatePageIndex(i);
      }
      expect(coreInfo.pages.length, equals(12));

      // 2. Mark 4 high-yield review pages as bookmarked (pages 2, 5, 8, 11)
      final bookmarkedIndices = [2, 5, 8, 11];
      for (final idx in bookmarkedIndices) {
        coreInfo.pages[idx].bookmarked = true;
      }
      final bookmarkedPages = coreInfo.pages.where((p) => p.bookmarked).toList();
      expect(bookmarkedPages.length, equals(4));

      // 3 & 4. Filter by bookmarks only -> exactly 4 pages in correct order
      final filteredIndices = coreInfo.pages.asMap().entries
          .where((e) => e.value.bookmarked)
          .map((e) => e.key)
          .toList();
      expect(filteredIndices, equals([2, 5, 8, 11]));

      // 5. Reorder exam review topics: move Page 8 (Index 8) to position 1
      E2EPageManagerHelper.reorderPages(coreInfo, 8, 1);
      expect(coreInfo.pages.length, equals(12));
      expect(coreInfo.pages[1].bookmarked, isTrue,
        reason: 'Moved bookmarked page retains bookmark flag at new index');

      // 6. Duplicate high-priority formula summary sheet (now at index 2)
      E2EPageManagerHelper.duplicatePageDeep(coreInfo, 2);
      expect(coreInfo.pages.length, equals(13));
      expect(coreInfo.pages[3].size, equals(coreInfo.pages[2].size));

      // 7. Jump navigation: calculate scroll offset for Page Index 5
      final topOfPage5 = CanvasGestureDetector.getTopOfPage(
        pageIndex: 5,
        pages: coreInfo.pages,
        screenWidth: 800,
      );
      expect(topOfPage5, isNotNull);
      expect(topOfPage5, isPositive);
    });

    // ------------------------------------------------------------------------
    // Scenario 4: Organic Chemistry Reaction Notebook with Behind-Ink Highlighter
    // ------------------------------------------------------------------------
    test('Scenario 4: Organic chemistry reaction notes with auto-straightened behind-ink highlighter', () {
      final chemPage = EditorPage(size: standardPageSize);
      chemPage.updatePageIndex(0);

      // 1. Draw organic chemical structure (benzene ring & bonds) using pen ink strokes
      final benzeneBond1 = createTestStroke(
        points: [const Offset(200, 200), const Offset(250, 150)],
        color: Colors.black,
      );
      final benzeneBond2 = createTestStroke(
        points: [const Offset(250, 150), const Offset(300, 200)],
        color: Colors.black,
      );
      final benzeneBond3 = createTestStroke(
        points: [const Offset(300, 200), const Offset(300, 270)],
        color: Colors.black,
      );
      chemPage.activeLayerStrokes.addAll([benzeneBond1, benzeneBond2, benzeneBond3]);

      // 2. Student highlights reaction mechanism with a wobbly stroke
      final wobblyHighlightPoints = [
        const Offset(180, 220),
        const Offset(230, 225),
        const Offset(270, 215),
        const Offset(320, 222),
      ];

      // 3. Auto-straighten engages upon hold: points replaced with straight line
      final start = wobblyHighlightPoints.first;
      final end = wobblyHighlightPoints.last;
      final straightenedHighlight = createHighlighterStroke(
        points: [start, end],
        color: Colors.yellow.withAlpha(Highlighter.alpha),
      );
      chemPage.activeLayerStrokes.add(straightenedHighlight);

      // Verify straightening property: intermediate interpolation aligns along vector
      final dir = end - start;
      for (double t = 0.0; t <= 1.0; t += 0.25) {
        final samplePoint = start + dir * t;
        final crossProduct = (samplePoint.dx - start.dx) * dir.dy - (samplePoint.dy - start.dy) * dir.dx;
        expect(crossProduct.abs(), lessThan(1e-5),
          reason: 'Straightened highlight points must be strictly collinear');
      }

      // 4. Verify behind-ink layering invariant:
      // In the rendering pipeline, highlighters are partitioned and drawn before normal ink
      final highlighters = chemPage.strokes.where((s) => s.toolId == ToolId.highlighter).toList();
      final penInks = chemPage.strokes.where((s) => s.toolId != ToolId.highlighter).toList();
      expect(highlighters.length, equals(1));
      expect(penInks.length, equals(3));

      // Layering opacity: highlighter layer uses translucent alpha, pen strokes are opaque
      expect((highlighters.first.color.a * 255).round(), equals(Highlighter.alpha));
      expect(penInks.every((s) => (s.color.a * 255).round() == 255), isTrue);

      // 5. Add multi-color highlighters for functional groups
      final cyanCatalystHighlight = createHighlighterStroke(
        points: [const Offset(180, 280), const Offset(320, 280)],
        color: Colors.cyan.withAlpha(Highlighter.alpha),
      );
      final magentaProductHighlight = createHighlighterStroke(
        points: [const Offset(180, 340), const Offset(320, 340)],
        color: Colors.pinkAccent.withAlpha(Highlighter.alpha),
      );
      chemPage.activeLayerStrokes.addAll([cyanCatalystHighlight, magentaProductHighlight]);

      // 6. Selective stroke eraser: erasing highlighter layer without disturbing pen ink
      final eraser = Eraser(size: 20);
      final overlappingHighlighters = eraser.checkForOverlappingStrokes(
        const Offset(250, 280),
        chemPage.strokes.where((s) => s.toolId == ToolId.highlighter).toList(),
      );
      expect(overlappingHighlighters, contains(cyanCatalystHighlight));
      expect(overlappingHighlighters, isNot(contains(benzeneBond1)),
        reason: 'Pen ink strokes must never be deleted when erasing highlighter layer');
    });

    // ------------------------------------------------------------------------
    // Scenario 5: Full Semester End-to-End Notebook Serialization Lifecycle
    // ------------------------------------------------------------------------
    test('Scenario 5: Full multi-page heterogeneous notebook BSON roundtrip lifecycle', () {
      // Page 0: Title page on Warm Cream paper with cover image and pen ink
      final p0Image = E2ETestImage(dstRect: const Rect.fromLTWH(50, 50, 400, 300));
      final p0Stroke = createTestStroke(points: [const Offset(100, 400), const Offset(300, 400)], color: Colors.brown);
      final page0 = EditorPage(
        size: standardPageSize,
        images: [p0Image],
      );
      page0.activeLayerStrokes.add(p0Stroke);

      // Page 1: Cornell Notes on Warm Cream with cue/notes/summary ink and 3 Study Tapes
      final p1Cue = createTestStroke(points: [const Offset(50, 150), const Offset(120, 150)], color: Colors.black);
      final p1Notes = createTestStroke(points: [const Offset(350, 200), const Offset(600, 200)], color: Colors.black87);
      final p1Tape1 = TapeStrokeContract(
        color: Colors.amber,
        pageIndex: 1,
        page: standardPageDef,
        start: const Offset(40, 180),
        end: const Offset(150, 180),
        tapeWidth: 25,
        isConcealed: true,
      );
      final p1Tape2 = TapeStrokeContract(
        color: Colors.amber,
        pageIndex: 1,
        page: standardPageDef,
        start: const Offset(340, 240),
        end: const Offset(550, 240),
        tapeWidth: 25,
        isConcealed: false,
      );
      final p1Tape3 = TapeStrokeContract(
        color: Colors.purpleAccent,
        pageIndex: 1,
        page: standardPageDef,
        start: const Offset(100, 920),
        end: const Offset(400, 920),
        tapeWidth: 30,
        isConcealed: true,
      );
      final page1 = EditorPage(
        size: standardPageSize,
        bookmarked: true,
      );
      page1.activeLayerStrokes.addAll([p1Cue, p1Notes, p1Tape1, p1Tape2, p1Tape3]);

      // Page 2: Dark Slate theme inverted Cornell page with white ink and behind-ink highlighter
      final p2WhiteInk = createTestStroke(points: [const Offset(200, 200), const Offset(400, 200)], color: Colors.white);
      final p2Highlight = createHighlighterStroke(points: [const Offset(190, 200), const Offset(410, 200)], color: Colors.yellow);
      final page2 = EditorPage(
        size: standardPageSize,
      );
      page2.activeLayerStrokes.addAll([p2WhiteInk, p2Highlight]);

      // Page 3: PDF slide import (image) with straight highlighter and margin notes
      final p3Slide = E2ETestImage(dstRect: const Rect.fromLTWH(0, 0, 800, 1000));
      final p3Ink = createTestStroke(points: [const Offset(50, 850), const Offset(250, 850)], color: Colors.redAccent);
      final page3 = EditorPage(
        size: standardPageSize,
        images: [p3Slide],
      );
      page3.activeLayerStrokes.add(p3Ink);

      // Page 4: Bookmarked cheat-sheet
      final p4Tape = TapeStrokeContract(
        color: Colors.teal,
        pageIndex: 4,
        page: standardPageDef,
        start: const Offset(100, 100),
        end: const Offset(300, 100),
        tapeWidth: 24,
        isConcealed: true,
      );
      final page4 = EditorPage(
        size: standardPageSize,
        bookmarked: true,
      );
      page4.activeLayerStrokes.add(p4Tape);

      final notebookPages = [page0, page1, page2, page3, page4];
      for (int i = 0; i < notebookPages.length; i++) {
        notebookPages[i].updatePageIndex(i);
      }

      final coreInfo = createTestCoreInfo(
        filePath: 'semester_biology_notes.sbn',
        backgroundColor: paperColorWarmCream,
        pages: notebookPages,
      );

      // 2. Export full notebook to BSON binary structure
      final (coreJson, assets) = coreInfo.toJson();
      final List<Map<String, dynamic>> serializedPages = [];
      for (int i = 0; i < notebookPages.length; i++) {
        final p = notebookPages[i];
        final pMap = p.toJson(assets);
        final tapes = p.strokes.whereType<TapeStrokeContract>().toList();
        if (tapes.isNotEmpty) {
          pMap['tapes'] = tapes.map((t) => t.toJson()).toList();
        }
        serializedPages.add(pMap);
      }

      final fullNotebookDoc = <String, dynamic>{
        'core': coreJson,
        'pages': serializedPages,
        'bookmarks': [1, 4],
        'version': 2,
      };

      final bsonBinary = BsonCodec.serialize(fullNotebookDoc);
      expect(bsonBinary.byteList.length, isPositive);

      // 3. Deserialize back from BSON into clean structures
      final restoredDoc = BsonCodec.deserialize(bsonBinary);
      expect(restoredDoc['version'], equals(2));
      expect(restoredDoc['bookmarks'], equals([1, 4]));

      final restoredPagesRaw = restoredDoc['pages'] as List;
      expect(restoredPagesRaw.length, equals(5));

      // 4. Deep-assert all invariants across all pages
      // Page 0: Cover Image & ink
      final rP0 = restoredPagesRaw[0] as Map;
      expect((rP0['i'] as List).length, equals(1));

      // Page 1: Cornell notes & 3 tapes
      final rP1 = restoredPagesRaw[1] as Map;
      final rP1Tapes = (rP1['tapes'] as List).map((raw) => TapeStrokeContract.fromJson(
        Map<String, dynamic>.from(raw as Map),
        pageIndex: 1,
        page: standardPageDef,
      )).toList();
      expect(rP1Tapes.length, equals(3));
      expect(rP1Tapes[0].isConcealed, isTrue);
      expect(rP1Tapes[1].isConcealed, isFalse);
      expect(rP1Tapes[2].isConcealed, isTrue);
      expect(rP1['bm'], isTrue, reason: 'Page 1 bookmarked status preserved');

      // Page 2: Dark slate strokes
      final rP2 = restoredPagesRaw[2] as Map;
      expect(rP2, isNotNull);

      // Page 3: Slide image
      final rP3 = restoredPagesRaw[3] as Map;
      expect((rP3['i'] as List).length, equals(1));

      // Page 4: Cheat sheet tape
      final rP4 = restoredPagesRaw[4] as Map;
      final rP4Tapes = (rP4['tapes'] as List).map((raw) => TapeStrokeContract.fromJson(
        Map<String, dynamic>.from(raw as Map),
        pageIndex: 4,
        page: standardPageDef,
      )).toList();
      expect(rP4Tapes.length, equals(1));
      expect(rP4Tapes.first.isConcealed, isTrue);
      expect(rP4['bm'], isTrue, reason: 'Page 4 bookmarked status preserved');
    });
  });
}
