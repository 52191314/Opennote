/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/components/toolbar/eraser_size_popup.dart';
import 'package:saber/components/toolbar/selection_bar.dart';
import 'package:saber/components/toolbar/tape_options_popup.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/sync/crdt/crdt_document.dart';
import 'package:saber/data/sync/crdt/crdt_state_vector.dart';
import 'package:saber/data/tools/arrow.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/study_tape.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

void main() {
  setUpAll(() {
    FlavorConfig.setup();
  });

  group('Feature 1: Tape / Study Masking Tool & Patterns', () {
    const page = HasSize(Size(800, 1000));

    test(
      'TapeStroke serializes and deserializes pattern correctly across all styles',
      () {
        for (final pattern in TapePattern.values) {
          final stroke = TapeStroke(
            color: const Color(0xFFFFD54F),
            pressureEnabled: false,
            options: StrokeOptions(size: 24),
            pageIndex: 0,
            page: page,
            toolId: ToolId.studyTape,
            rect: const Rect.fromLTWH(50, 100, 200, 30),
            isConcealed: true,
            pattern: pattern,
          );

          final json = stroke.toJson();
          expect(json['shape'], equals('tape'));
          expect(json['tp'], equals(pattern.name));
          expect(json['c_state'], isTrue);

          final deserialized = TapeStroke.fromJson(
            json,
            fileVersion: 19,
            pageIndex: 0,
            page: page,
          );

          expect(deserialized.pattern, equals(pattern));
          expect(deserialized.rect, equals(stroke.rect));
          expect(deserialized.isConcealed, isTrue);
        }
      },
    );

    test('TapeStroke toggleConceal flips state', () {
      final stroke = TapeStroke(
        color: const Color(0xFFFFD54F),
        pressureEnabled: false,
        options: StrokeOptions(size: 24),
        pageIndex: 0,
        page: page,
        toolId: ToolId.studyTape,
        rect: const Rect.fromLTWH(10, 20, 100, 40),
        isConcealed: true,
      );

      expect(stroke.isConcealed, isTrue);
      stroke.toggleConceal();
      expect(stroke.isConcealed, isFalse);
      stroke.toggleConceal();
      expect(stroke.isConcealed, isTrue);
    });

    test('StudyTapeTool creates stroke with configured pattern', () {
      final editorPage = EditorPage(size: const Size(800, 1000));

      final tool = StudyTapeTool(pattern: TapePattern.stripes);
      tool.onDragStart(const Offset(100, 100), editorPage, 0, null);

      expect(Pen.currentStroke, isA<TapeStroke>());
      final stroke = Pen.currentStroke as TapeStroke;
      expect(stroke.pattern, equals(TapePattern.stripes));

      tool.onDragUpdate(const Offset(250, 100), null);
      final finished = tool.onDragEnd();

      expect(finished, isA<TapeStroke>());
      expect((finished as TapeStroke).pattern, equals(TapePattern.stripes));
      expect(Pen.currentStroke, isNull);
    });

    testWidgets('TapeOptionsPopup updates pattern and color on StudyTapeTool', (
      tester,
    ) async {
      final tool = StudyTapeTool(pattern: TapePattern.solid);
      bool revealTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapeOptionsPopup(
              currentTapeTool: tool,
              onRevealAll: () => revealTriggered = true,
              onConcealAll: () {},
            ),
          ),
        ),
      );

      // Tap 'Stripes' segment
      await tester.tap(find.text('Stripes'));
      await tester.pumpAndSettle();
      expect(tool.pattern, equals(TapePattern.stripes));
      expect(stows.studyTapePattern.value, equals('stripes'));

      // Tap 'Reveal All'
      await tester.tap(find.text('Reveal All'));
      await tester.pumpAndSettle();
      expect(revealTriggered, isTrue);
    });

    testWidgets('TapeOptionsPopup Conceal All button invokes callback', (
      tester,
    ) async {
      final tool = StudyTapeTool(pattern: TapePattern.solid);
      bool concealTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapeOptionsPopup(
              currentTapeTool: tool,
              onConcealAll: () => concealTriggered = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Conceal All'));
      await tester.pumpAndSettle();
      expect(concealTriggered, isTrue);
    });
  });

  group('Feature 2: Connector Lines (Straight, Elbow, Curved)', () {
    const page = HasSize(Size(1000, 1000));

    test('ArrowStroke serializes and deserializes connector styles', () {
      for (final style in ConnectorStyle.values) {
        final stroke = ArrowStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 4),
          pageIndex: 0,
          page: page,
          toolId: ToolId.arrow,
          start: const Offset(100, 100),
          end: const Offset(300, 400),
          connectorStyle: style,
        );

        final json = stroke.toJson();
        expect(json['shape'], equals('arrow'));
        expect(json['cnt'], equals(style.name));

        final restored = ArrowStroke.fromJson(
          json,
          fileVersion: 19,
          pageIndex: 0,
          page: page,
        );

        expect(restored.connectorStyle, equals(style));
        expect(restored.start, equals(stroke.start));
        expect(restored.end, equals(stroke.end));
      }
    });

    test(
      'Elbow and Curved connectors generate valid non-empty paths and polygons',
      () {
        final straight = ArrowStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 4),
          pageIndex: 0,
          page: page,
          toolId: ToolId.arrow,
          start: const Offset(50, 50),
          end: const Offset(200, 250),
          connectorStyle: ConnectorStyle.straight,
        );

        final elbow = ArrowStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 4),
          pageIndex: 0,
          page: page,
          toolId: ToolId.arrow,
          start: const Offset(50, 50),
          end: const Offset(200, 250),
          connectorStyle: ConnectorStyle.elbow,
        );

        final curved = ArrowStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 4),
          pageIndex: 0,
          page: page,
          toolId: ToolId.arrow,
          start: const Offset(50, 50),
          end: const Offset(200, 250),
          connectorStyle: ConnectorStyle.curved,
        );

        final straightPath = straight.getPath([]);
        final elbowPath = elbow.getPath([]);
        final curvedPath = curved.getPath([]);

        expect(straightPath.computeMetrics().isNotEmpty, isTrue);
        expect(elbowPath.computeMetrics().isNotEmpty, isTrue);
        expect(curvedPath.computeMetrics().isNotEmpty, isTrue);

        final straightPoly = straight.getPolygon(quality: StrokeQuality.high);
        final elbowPoly = elbow.getPolygon(quality: StrokeQuality.high);
        final curvedPoly = curved.getPolygon(quality: StrokeQuality.high);

        expect(straightPoly.length, greaterThanOrEqualTo(2));
        expect(elbowPoly.length, greaterThan(straightPoly.length));
        expect(curvedPoly.length, greaterThan(elbowPoly.length));

        // Verify SVG generation contains distinct SVG commands
        expect(straight.toSvgPath(), contains('M'));
        expect(elbow.toSvgPath(), contains('L'));
        expect(curved.toSvgPath(), contains('C'));
      },
    );

    test('ArrowTool creates strokes with requested connectorStyle', () {
      final editorPage = EditorPage(size: const Size(800, 1000));

      final tool = ArrowTool(connectorStyle: ConnectorStyle.curved);
      expect(tool.name, equals('Curved Connector'));

      tool.onDragStart(const Offset(10, 10), editorPage, 0, null);
      expect(Pen.currentStroke, isA<ArrowStroke>());
      final stroke = Pen.currentStroke as ArrowStroke;
      expect(stroke.connectorStyle, equals(ConnectorStyle.curved));

      tool.onDragUpdate(const Offset(100, 150), null);
      final finished = tool.onDragEnd();
      expect(finished, isA<ArrowStroke>());
      expect(
        (finished as ArrowStroke).connectorStyle,
        equals(ConnectorStyle.curved),
      );
    });
  });

  group('Feature 3: Rectangular Lasso & Study Tape Filter', () {
    const page = HasSize(Size(1000, 1000));

    setUp(() {
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = true;
      stows.lassoSelectText.value = true;
      stows.lassoSelectTape.value = true;
      stows.selectionRectMode.value = false;
      Select.currentSelect.unselect();
    });

    test('Lasso isolates TapeStroke when handwriting filter is disabled', () {
      final select = Select.currentSelect;
      stows.lassoSelectHandwriting.value = false;
      stows.lassoSelectTape.value = true;

      final hwStroke = Stroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 5),
        pageIndex: 0,
        page: page,
        toolId: ToolId.fountainPen,
      )..addPoint(const Offset(50, 50));

      final tapeStroke = TapeStroke(
        color: Colors.amber,
        pressureEnabled: false,
        options: StrokeOptions(size: 20),
        pageIndex: 0,
        page: page,
        toolId: ToolId.studyTape,
        rect: const Rect.fromLTWH(30, 30, 80, 40),
      );

      select.onDragStart(Offset.zero, 0);
      select.onDragUpdate(const Offset(0, 150));
      select.onDragUpdate(const Offset(150, 150));
      select.onDragUpdate(const Offset(150, 0));
      select.onDragEnd([hwStroke, tapeStroke], []);

      expect(select.selectResult.strokes, contains(tapeStroke));
      expect(select.selectResult.strokes, isNot(contains(hwStroke)));
    });

    test('Lasso isolates Handwriting when tape filter is disabled', () {
      final select = Select.currentSelect;
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectTape.value = false;

      final hwStroke = Stroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 5),
        pageIndex: 0,
        page: page,
        toolId: ToolId.fountainPen,
      )..addPoint(const Offset(50, 50));

      final tapeStroke = TapeStroke(
        color: Colors.amber,
        pressureEnabled: false,
        options: StrokeOptions(size: 20),
        pageIndex: 0,
        page: page,
        toolId: ToolId.studyTape,
        rect: const Rect.fromLTWH(30, 30, 80, 40),
      );

      select.onDragStart(Offset.zero, 0);
      select.onDragUpdate(const Offset(0, 150));
      select.onDragUpdate(const Offset(150, 150));
      select.onDragUpdate(const Offset(150, 0));
      select.onDragEnd([hwStroke, tapeStroke], []);

      expect(select.selectResult.strokes, contains(hwStroke));
      expect(select.selectResult.strokes, isNot(contains(tapeStroke)));
    });

    test('Rectangle mode creates rectangular selection path', () {
      final select = Select.currentSelect;
      stows.selectionRectMode.value = true;

      select.onDragStart(const Offset(10, 10), 0);
      select.onDragUpdate(const Offset(100, 80));

      expect(
        select.selectResult.path.getBounds(),
        equals(const Rect.fromLTRB(10, 10, 100, 80)),
      );
    });
  });

  group('Feature 4: CRDT Real-Time Sync Architecture (Yjs CRDT Foundation)', () {
    test('CrdtStateVector tracks, increments, and merges vector clocks', () {
      final v1 = CrdtStateVector();
      v1.setClock('clientA', 3);
      v1.setClock('clientB', 5);

      final v2 = CrdtStateVector();
      v2.setClock('clientA', 7);
      v2.setClock('clientC', 2);

      v1.merge(v2);

      expect(v1.getClock('clientA'), equals(7));
      expect(v1.getClock('clientB'), equals(5));
      expect(v1.getClock('clientC'), equals(2));
      expect(v1.hasSeen('clientA', 6), isTrue);
      expect(v1.hasSeen('clientA', 8), isFalse);
    });

    test(
      'Two CrdtDocuments converge deterministically after concurrent additions',
      () {
        final docA = CrdtDocument(replicaId: 'device_A');
        final docB = CrdtDocument(replicaId: 'device_B');

        docA.addStroke(
          strokeId: 'stroke_1',
          pageIndex: 0,
          strokeJson: {'shape': 'tape', 'c': 0xFF0000},
        );
        docA.addStroke(
          strokeId: 'stroke_2',
          pageIndex: 0,
          strokeJson: {'shape': 'tape', 'c': 0x00FF00},
        );

        docB.addStroke(
          strokeId: 'stroke_3',
          pageIndex: 0,
          strokeJson: {'shape': 'tape', 'c': 0x0000FF},
        );

        expect(docA.strokeCount, equals(2));
        expect(docB.strokeCount, equals(1));

        // Bidirectional sync
        docA.syncWith(docB);

        expect(docA.strokeCount, equals(3));
        expect(docB.strokeCount, equals(3));
        expect(
          docA.activeStrokeIds.toSet(),
          equals(docB.activeStrokeIds.toSet()),
        );
      },
    );

    test(
      'Tombstone prevents deleted stroke from resurrecting during late sync',
      () {
        final docA = CrdtDocument(replicaId: 'device_A');
        final docB = CrdtDocument(replicaId: 'device_B');

        // A creates a stroke
        docA.addStroke(
          strokeId: 'stroke_temp',
          pageIndex: 0,
          strokeJson: {'shape': 'tape'},
        );

        // Initial sync: B learns about stroke_temp
        docA.syncWith(docB);
        expect(docB.strokeCount, equals(1));

        // A erases the stroke while B is offline
        docA.deleteStroke('stroke_temp');
        expect(docA.strokeCount, equals(0));

        // B edits the stroke while offline
        docB.updateStroke(strokeId: 'stroke_temp', patch: {'c_state': false});

        // Now sync again: deletion tombstone must prevail
        docA.syncWith(docB);

        expect(docA.strokeCount, equals(0));
        expect(docB.strokeCount, equals(0));
      },
    );

    test('Delta encoding only transmits unobserved operations', () {
      final docA = CrdtDocument(replicaId: 'device_A');
      final vectorB = CrdtStateVector({'device_A': 1});

      docA.addStroke(strokeId: 's1', pageIndex: 0, strokeJson: {}); // clock 1
      docA.addStroke(strokeId: 's2', pageIndex: 0, strokeJson: {}); // clock 2
      docA.addStroke(strokeId: 's3', pageIndex: 0, strokeJson: {}); // clock 3

      final delta = docA.encodeDelta(vectorB);

      // Vector B already saw clock 1, so delta must contain only clocks 2 and 3
      expect(delta.operations.length, equals(2));
      expect(delta.operations.map((o) => o.clock), equals([2, 3]));
    });
  });

  group('Feature 5: Goodnotes Eraser Mechanics & Filtering', () {
    const page = HasSize(Size(800, 1000));

    test(
      'Erase Tape Only filter selectively erases tape strokes while preserving ink',
      () {
        final penStroke =
            Stroke(
                color: Colors.black,
                pressureEnabled: false,
                options: StrokeOptions(size: 5),
                pageIndex: 0,
                page: page,
                toolId: ToolId.fountainPen,
              )
              ..addPoint(const Offset(50, 50), null)
              ..addPoint(const Offset(55, 55), null)
              ..addPoint(const Offset(60, 60), null);

        final tapeStroke = TapeStroke(
          color: const Color(0xFFFFD54F),
          pressureEnabled: false,
          options: StrokeOptions(size: 24),
          pageIndex: 0,
          page: page,
          toolId: ToolId.studyTape,
          rect: const Rect.fromLTWH(40, 40, 100, 30),
        );

        final highlighterStroke =
            Stroke(
                color: Colors.yellow,
                pressureEnabled: false,
                options: StrokeOptions(size: 20),
                pageIndex: 0,
                page: page,
                toolId: ToolId.highlighter,
              )
              ..addPoint(const Offset(50, 50), null)
              ..addPoint(const Offset(55, 55), null)
              ..addPoint(const Offset(60, 60), null);

        final strokes = [penStroke, tapeStroke, highlighterStroke];

        // 1. With eraserEraseTapeOnly = true
        stows.eraserEraseTapeOnly.value = true;
        stows.eraserEraseHighlighterOnly.value = false;
        stows.eraserMode.value = 'object';

        final eraser = Eraser(size: 20);
        final erasedTapeOnly = eraser.checkForOverlappingStrokes(
          const Offset(55, 55),
          strokes,
        );

        expect(erasedTapeOnly, contains(tapeStroke));
        expect(erasedTapeOnly, isNot(contains(penStroke)));
        expect(erasedTapeOnly, isNot(contains(highlighterStroke)));

        // 2. With eraserEraseHighlighterOnly = true
        stows.eraserEraseTapeOnly.value = false;
        stows.eraserEraseHighlighterOnly.value = true;

        final eraser2 = Eraser(size: 20);
        final erasedHighlighterOnly = eraser2.checkForOverlappingStrokes(
          const Offset(55, 55),
          strokes,
        );

        expect(erasedHighlighterOnly, contains(highlighterStroke));
        expect(erasedHighlighterOnly, isNot(contains(penStroke)));
        expect(erasedHighlighterOnly, isNot(contains(tapeStroke)));

        // Reset
        stows.eraserEraseTapeOnly.value = false;
        stows.eraserEraseHighlighterOnly.value = false;
      },
    );

    test('Precision eraser mode uses tighter contact threshold', () {
      final stroke =
          Stroke(
              color: Colors.black,
              pressureEnabled: false,
              options: StrokeOptions(size: 5),
              pageIndex: 0,
              page: page,
              toolId: ToolId.fountainPen,
            )
            ..addPoint(const Offset(100, 100), null)
            ..addPoint(const Offset(105, 105), null)
            ..addPoint(const Offset(110, 110), null);

      final strokes = [stroke];

      // Point at distance ~17.7 from (105, 105) (sqrDist = 25 + 289 = 314)
      // Object mode: 314 <= 400 -> erased!
      // Precision mode: 314 > 100 -> NOT erased!
      const testPos = Offset(100, 122);

      // Object mode with size 20: effective radius 20, sqrDistance <= 400 -> erased!
      stows.eraserMode.value = 'object';
      final eraserObject = Eraser(size: 20);
      final erasedObj = eraserObject.checkForOverlappingStrokes(
        testPos,
        strokes,
      );
      expect(erasedObj, isNotEmpty);

      // Precision mode with size 20: effectiveSqrSize = 400 * 0.25 = 100 < 314 -> NOT erased!
      stows.eraserMode.value = 'precision';
      final eraserPrecision = Eraser(size: 20);
      final erasedPrec = eraserPrecision.checkForOverlappingStrokes(
        testPos,
        strokes,
      );
      expect(erasedPrec, isEmpty);

      // Reset
      stows.eraserMode.value = 'object';
    });

    testWidgets('EraserSizePopup renders eraser styles and toggles tape only', (
      tester,
    ) async {
      stows.eraserEraseTapeOnly.value = false;
      stows.disableEraserAfterUse.value = false;
      stows.eraserMode.value = 'object';

      bool cleared = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EraserSizePopup(onClearPage: () => cleared = true),
          ),
        ),
      );

      // Verify SegmentedButton for Eraser Style
      expect(find.text('Eraser Style'), findsOneWidget);
      expect(find.text('Object'), findsOneWidget);
      expect(find.text('Precision'), findsOneWidget);

      // Switch to Precision style
      await tester.tap(find.text('Precision'));
      await tester.pumpAndSettle();
      expect(stows.eraserMode.value, equals('precision'));

      // Verify Erase Tape Only toggle
      expect(find.text('Erase Tape Only'), findsOneWidget);
      await tester.ensureVisible(find.text('Erase Tape Only'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Erase Tape Only'));
      await tester.pumpAndSettle();
      expect(stows.eraserEraseTapeOnly.value, isTrue);

      // Verify Clear Page button exists and triggers callback
      expect(find.text('Clear Page'), findsOneWidget);
      await tester.ensureVisible(find.text('Clear Page'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear Page'));
      await tester.pumpAndSettle();
      expect(cleared, isTrue);
    });
  });

  group('Feature 6: Goodnotes Straight Line Highlighter & Selection Actions', () {
    const page = HasSize(Size(800, 1000));

    test('Highlighter Draw in Straight Line snaps horizontal drag', () {
      final editorPage = EditorPage(size: const Size(800, 1000));
      final highlighter = Highlighter();

      // Enable straight line mode
      stows.highlighterDrawInStraightLine.value = true;

      highlighter.onDragStart(const Offset(50, 100), editorPage, 0, null);
      expect(Pen.currentStroke, isNotNull);

      // Drag mostly horizontally with some vertical wobble (dy = 10, dx = 200)
      highlighter.onDragUpdate(const Offset(250, 110), null);

      final stroke = Pen.currentStroke!;
      // Points should be snapped to horizontal (start.dy = 100)
      expect(stroke.firstPoint?.dy, equals(100.0));
      expect(stroke.lastPoint?.dy, equals(100.0));
      expect(stroke.lastPoint?.dx, equals(250.0));

      final finished = highlighter.onDragEnd();
      expect(finished, isNotNull);

      // Reset
      stows.highlighterDrawInStraightLine.value = false;
    });

    test('Stroke.smoothen beautifies raw points via Laplacian smoothing', () {
      final stroke = Stroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 5),
        pageIndex: 0,
        page: page,
        toolId: ToolId.fountainPen,
      );

      // Add jagged sawtooth points: (0, 0), (10, 20), (20, 0), (30, 20), (40, 0)
      stroke.addPoint(Offset.zero, null);
      stroke.addPoint(const Offset(10, 20), null);
      stroke.addPoint(const Offset(20, 0), null);
      stroke.addPoint(const Offset(30, 20), null);
      stroke.addPoint(const Offset(40, 0), null);

      expect(stroke.points[1].y, equals(20.0));

      // Apply smoothing
      stroke.smoothen(iterations: 2);

      // The peak at index 1 should be smoothed down towards the baseline
      expect(stroke.points[1].y, lessThan(20.0));
      expect(stroke.points[1].y, greaterThan(0.0));
    });

    testWidgets(
      'SelectionBar displays Bring to Front, Send to Back, and Smoothen buttons',
      (tester) async {
        bool broughtToFront = false;
        bool sentToBack = false;
        bool smoothed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionBar(
                copySelection: () {},
                pasteSelection: () {},
                duplicateSelection: () {},
                deleteSelection: () {},
                bringToFront: () => broughtToFront = true,
                sendToBack: () => sentToBack = true,
                smoothen: () => smoothed = true,
              ),
            ),
          ),
        );

        expect(find.byTooltip('Bring to Front'), findsOneWidget);
        expect(find.byTooltip('Send to Back'), findsOneWidget);
        expect(find.byTooltip('Smoothen Handwriting'), findsOneWidget);

        await tester.tap(find.byTooltip('Bring to Front'));
        expect(broughtToFront, isTrue);

        await tester.tap(find.byTooltip('Send to Back'));
        expect(sentToBack, isTrue);

        await tester.tap(find.byTooltip('Smoothen Handwriting'));
        expect(smoothed, isTrue);
      },
    );
  });
}
