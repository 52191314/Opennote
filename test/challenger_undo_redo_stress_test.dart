/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

import 'utils/test_mock_channel_handlers.dart';

Stroke createTestStroke({
  required HasSize page,
  int pageIndex = 0,
  ToolId toolId = ToolId.fountainPen,
  Color color = Colors.black,
  List<Offset> points = const [Offset(10, 10), Offset(20, 20)],
}) {
  final stroke = Stroke(
    color: color,
    pressureEnabled: true,
    options: StrokeOptions(size: 2.0),
    pageIndex: pageIndex,
    page: page,
    toolId: toolId,
  );
  for (final pt in points) {
    stroke.points.add(PointVector(pt.dx, pt.dy, 0.5));
  }
  return stroke;
}

void main() {
  setUpAll(() {
    setupMockPathProvider();
    setupMockPrinting();
    FlavorConfig.setup();
  });

  const pageSize = Size(1000, 1400);
  const hasPage = HasSize(pageSize);

  group('Adversarial Group 1: EditorPage.removeStroke & insertStroke Primitives', () {
    test('removeStroke on an empty layers list returns false without throwing', () {
      final page = EditorPage(size: pageSize, layers: []);
      expect(page.layers, isEmpty);

      final stroke = createTestStroke(page: hasPage);
      final removed = page.removeStroke(stroke);

      expect(removed, isFalse);
      expect(page.layers, isEmpty);
      expect(page.strokes, isEmpty);
    });

    test('removeStroke with an unattached alien stroke returns false and leaves page intact', () {
      final stroke1 = createTestStroke(page: hasPage, points: [const Offset(1, 1)]);
      final page = EditorPage(size: pageSize, strokes: [stroke1]);
      expect(page.strokes.length, 1);

      final alienStroke = createTestStroke(page: hasPage, points: [const Offset(99, 99)]);
      final removed = page.removeStroke(alienStroke);

      expect(removed, isFalse);
      expect(page.strokes.length, 1);
      expect(page.strokes.first, same(stroke1));
    });

    test('Double removal of identical stroke returns true then false', () {
      final stroke = createTestStroke(page: hasPage);
      final page = EditorPage(size: pageSize, strokes: [stroke]);
      expect(page.strokes.length, 1);

      expect(page.removeStroke(stroke), isTrue);
      expect(page.strokes, isEmpty);

      expect(page.removeStroke(stroke), isFalse);
      expect(page.strokes, isEmpty);
    });

    test('Multi-layer removal from middle layer leaves neighboring layers and layer indices intact', () {
      final layer0 = Layer(name: 'Background', strokes: [
        createTestStroke(page: hasPage, color: Colors.red),
      ]);
      final strokeTarget = createTestStroke(page: hasPage, color: Colors.green);
      final strokeKeep = createTestStroke(page: hasPage, color: Colors.blue);
      final layer1 = Layer(name: 'Middle', strokes: [strokeTarget, strokeKeep]);
      final layer2 = Layer(name: 'Foreground', strokes: [
        createTestStroke(page: hasPage, color: Colors.yellow),
      ]);

      final page = EditorPage(size: pageSize, layers: [layer0, layer1, layer2]);
      expect(page.layers.length, 3);
      expect(page.strokes.length, 4);

      final removed = page.removeStroke(strokeTarget);
      expect(removed, isTrue);

      expect(page.layers.length, 3);
      expect(page.layers[0].name, 'Background');
      expect(page.layers[0].strokes.length, 1);
      expect(page.layers[1].name, 'Middle');
      expect(page.layers[1].strokes.length, 1);
      expect(page.layers[1].strokes.first, same(strokeKeep));
      expect(page.layers[2].name, 'Foreground');
      expect(page.layers[2].strokes.length, 1);
      expect(page.strokes.length, 3);
    });

    test('removeStroke on hidden layer removes stroke and prevents ghost appearance on unhide', () {
      final hiddenStroke = createTestStroke(page: hasPage, color: Colors.purple);
      final hiddenLayer = Layer(name: 'Hidden', visible: false, strokes: [hiddenStroke]);
      final visibleStroke = createTestStroke(page: hasPage, color: Colors.white);
      final visibleLayer = Layer(name: 'Visible', visible: true, strokes: [visibleStroke]);

      final page = EditorPage(size: pageSize, layers: [hiddenLayer, visibleLayer]);
      expect(page.strokes.length, 1);
      expect(page.strokes.first, same(visibleStroke));

      final removed = page.removeStroke(hiddenStroke);
      expect(removed, isTrue);
      expect(hiddenLayer.strokes, isEmpty);

      hiddenLayer.visible = true;
      expect(page.strokes.length, 1);
      expect(page.strokes.first, same(visibleStroke));
    });

    test('insertStroke on empty layers auto-creates Default layer and places stroke', () {
      final page = EditorPage(size: pageSize, layers: []);
      expect(page.layers, isEmpty);

      final stroke = createTestStroke(page: hasPage);
      page.insertStroke(stroke);

      expect(page.layers.length, 1);
      expect(page.layers.first.name, 'Default');
      expect(page.layers.first.strokes.length, 1);
      expect(page.strokes.length, 1);
      expect(page.strokes.first, same(stroke));
    });

    test('insertStroke correctly sorts highlighters below pens in z-axis by toolId and color', () {
      final page = EditorPage(size: pageSize);
      final pen = createTestStroke(page: hasPage, toolId: ToolId.fountainPen, color: Colors.black);
      final hlRed = createTestStroke(page: hasPage, toolId: ToolId.highlighter, color: Colors.red);
      final hlBlue = createTestStroke(page: hasPage, toolId: ToolId.highlighter, color: Colors.blue);

      page.insertStroke(hlBlue);
      page.insertStroke(pen);
      page.insertStroke(hlRed);

      // In Saber, highlighter toolId.id is 'Highlighter' (capital H), which comes before 'fountainPen'
      // so highlighters are placed at lower z-indices to render underneath pens.
      expect(page.strokes[0].toolId, ToolId.highlighter);
      expect(page.strokes[1].toolId, ToolId.highlighter);
      expect(page.strokes[2].toolId, ToolId.fountainPen);
    });

    test('Degenerate strokes with 0 points, identical duplicate points, or extreme values', () {
      final emptyStroke = createTestStroke(page: hasPage, points: []);
      expect(emptyStroke.isEmpty, isTrue);

      final duplicatePointsStroke = createTestStroke(
        page: hasPage,
        points: List.generate(20, (_) => const Offset(100, 100)),
      );

      final page = EditorPage(size: pageSize);
      page.insertStroke(emptyStroke);
      page.insertStroke(duplicatePointsStroke);

      expect(page.strokes.length, 2);
      expect(page.removeStroke(emptyStroke), isTrue);
      expect(page.removeStroke(duplicatePointsStroke), isTrue);
      expect(page.strokes, isEmpty);
    });
  });

  group('Adversarial Group 2: Multi-Layer High-Scale Stress & Invariance', () {
    test('100 strokes across 10 layers with 50 removals (5 per layer)', () {
      final layers = List.generate(10, (i) => Layer(name: 'Layer $i'));
      final page = EditorPage(size: pageSize, layers: layers);

      final strokesPerLayer = List.generate(10, (_) => <Stroke>[]);
      for (int layerIdx = 0; layerIdx < 10; layerIdx++) {
        page.activeLayerIndex = layerIdx;
        for (int s = 0; s < 10; s++) {
          final stroke = createTestStroke(
            page: hasPage,
            points: [Offset(layerIdx * 10.0 + s, layerIdx * 10.0 + s)],
          );
          strokesPerLayer[layerIdx].add(stroke);
          page.insertStroke(stroke);
        }
      }

      expect(page.strokes.length, 100);
      for (int i = 0; i < 10; i++) {
        expect(page.layers[i].strokes.length, 10);
      }

      // Remove exactly 5 strokes from each layer
      for (int layerIdx = 0; layerIdx < 10; layerIdx++) {
        for (int s = 0; s < 5; s++) {
          final stroke = strokesPerLayer[layerIdx][s];
          expect(page.removeStroke(stroke), isTrue);
        }
      }

      expect(page.strokes.length, 50);
      for (int i = 0; i < 10; i++) {
        expect(page.layers[i].strokes.length, 5);
      }

      // Remaining strokes exist
      for (int layerIdx = 0; layerIdx < 10; layerIdx++) {
        for (int s = 5; s < 10; s++) {
          final stroke = strokesPerLayer[layerIdx][s];
          expect(page.strokes.contains(stroke), isTrue);
        }
      }

      // Re-removing already removed strokes returns false
      for (int layerIdx = 0; layerIdx < 10; layerIdx++) {
        for (int s = 0; s < 5; s++) {
          final stroke = strokesPerLayer[layerIdx][s];
          expect(page.removeStroke(stroke), isFalse);
        }
      }
    });

    test('activeLayerIndex clamping protects against out-of-bounds layer indices', () {
      final page = EditorPage(size: pageSize, layers: [Layer(name: 'Solo')]);
      page.activeLayerIndex = 999;

      final stroke = createTestStroke(page: hasPage);
      page.insertStroke(stroke);

      expect(page.layers.single.strokes.length, 1);
      expect(page.removeStroke(stroke), isTrue);
    });
  });

  group('Adversarial Group 3: Editor History Lifecycle & Undo/Redo Engine Stress', () {
    test('100 sequential draws -> 100 undos -> 100 redoes round-trip consistency', () {
      final history = EditorHistory();
      final page = EditorPage(size: pageSize);
      final strokes = List.generate(
        100,
        (i) => createTestStroke(page: hasPage, points: [Offset(i.toDouble(), 10)]),
      );

      for (final s in strokes) {
        page.insertStroke(s);
        history.recordChange(
          EditorHistoryItem(
            type: EditorHistoryItemType.draw,
            pageIndex: 0,
            strokes: [s],
            images: [],
          ),
        );
      }
      expect(page.strokes.length, 100);
      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);

      for (int i = 99; i >= 0; i--) {
        final item = history.undo();
        history.canRedo = true; // Simulating EditorState.undo() behavior
        for (final s in item.strokes) {
          final removed = page.removeStroke(s);
          expect(removed, isTrue);
        }
      }
      expect(page.strokes, isEmpty);
      expect(history.canUndo, isFalse);
      expect(history.canRedo, isTrue);

      for (int i = 0; i < 100; i++) {
        final item = history.redo();
        for (final s in item.strokes) {
          page.insertStroke(s);
        }
      }
      expect(page.strokes.length, 100);
      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);
    });

    test('Redo stack invalidation on new drawing branch', () {
      final history = EditorHistory();
      final page = EditorPage(size: pageSize);

      final s1 = createTestStroke(page: hasPage, color: Colors.red);
      final s2 = createTestStroke(page: hasPage, color: Colors.green);

      page.insertStroke(s1);
      history.recordChange(EditorHistoryItem(
        type: EditorHistoryItemType.draw,
        pageIndex: 0,
        strokes: [s1],
        images: [],
      ));

      page.insertStroke(s2);
      history.recordChange(EditorHistoryItem(
        type: EditorHistoryItemType.draw,
        pageIndex: 0,
        strokes: [s2],
        images: [],
      ));

      expect(page.strokes.length, 2);

      // Undo s2
      final undone = history.undo();
      history.canRedo = true;
      page.removeStroke(undone.strokes.first);
      expect(page.strokes.length, 1);
      expect(history.canRedo, isTrue);

      // Branch: draw s3
      final s3 = createTestStroke(page: hasPage, color: Colors.blue);
      page.insertStroke(s3);
      history.recordChange(EditorHistoryItem(
        type: EditorHistoryItemType.draw,
        pageIndex: 0,
        strokes: [s3],
        images: [],
      ));

      expect(history.canRedo, isFalse, reason: 'Redo stack must be purged after branching');

      // Undo s3
      final undoneBranch = history.undo();
      page.removeStroke(undoneBranch.strokes.first);
      expect(page.strokes.length, 1);
      expect(page.strokes.first, same(s1));

      // Undo s1
      final undoneRoot = history.undo();
      page.removeStroke(undoneRoot.strokes.first);
      expect(page.strokes, isEmpty);
    });

    test('Batch multi-stroke erase undo and redo (lasso erase)', () {
      final history = EditorHistory();
      final page = EditorPage(size: pageSize);

      final batch = List.generate(
        25,
        (i) => createTestStroke(page: hasPage, points: [Offset(i * 10, i * 10)]),
      );
      for (final s in batch) {
        page.insertStroke(s);
      }
      expect(page.strokes.length, 25);

      // Erase all 25 in a single gesture
      for (final s in batch) {
        page.removeStroke(s);
      }
      expect(page.strokes, isEmpty);

      history.recordChange(EditorHistoryItem(
        type: EditorHistoryItemType.erase,
        pageIndex: 0,
        strokes: batch,
        images: [],
      ));

      // Undo erase: all 25 strokes restored
      final undoneErase = history.undo();
      history.canRedo = true;
      expect(undoneErase.type, EditorHistoryItemType.erase);
      for (final s in undoneErase.strokes) {
        page.insertStroke(s);
      }
      expect(page.strokes.length, 25);

      // Redo erase: all 25 strokes removed again
      final redoneErase = history.redo();
      expect(redoneErase.type, EditorHistoryItemType.erase);
      for (final s in redoneErase.strokes) {
        page.removeStroke(s);
      }
      expect(page.strokes, isEmpty);
    });

    test('Complex interleaved draw/erase/undo/redo simulation cycle', () {
      final history = EditorHistory();
      final page = EditorPage(size: pageSize);
      final activeStrokes = <Stroke>[];

      for (int cycle = 0; cycle < 10; cycle++) {
        // Draw 3 strokes
        final sA = createTestStroke(page: hasPage, points: [Offset(cycle * 1.0, 1)]);
        final sB = createTestStroke(page: hasPage, points: [Offset(cycle * 1.0, 2)]);
        final sC = createTestStroke(page: hasPage, points: [Offset(cycle * 1.0, 3)]);
        for (final s in [sA, sB, sC]) {
          page.insertStroke(s);
          activeStrokes.add(s);
          history.recordChange(EditorHistoryItem(
            type: EditorHistoryItemType.draw,
            pageIndex: 0,
            strokes: [s],
            images: [],
          ));
        }

        // Erase 1 stroke
        final erased = activeStrokes.removeLast();
        page.removeStroke(erased);
        history.recordChange(EditorHistoryItem(
          type: EditorHistoryItemType.erase,
          pageIndex: 0,
          strokes: [erased],
          images: [],
        ));

        // Undo the erase
        final undoErase = history.undo();
        history.canRedo = true;
        for (final s in undoErase.strokes) {
          page.insertStroke(s);
          activeStrokes.add(s);
        }

        // Redo the erase
        final redoErase = history.redo();
        for (final s in redoErase.strokes) {
          page.removeStroke(s);
          activeStrokes.remove(s);
        }
      }

      expect(page.strokes.length, activeStrokes.length);
      expect(page.strokes.length, 20); // 10 cycles * (3 - 1) = 20
    });

    test('Multi-layer activeLayerIndex behavior under undo/redo', () {
      final history = EditorHistory();
      final page = EditorPage(size: pageSize, layers: [
        Layer(name: 'Layer 0'),
        Layer(name: 'Layer 1'),
      ]);

      // Draw S0 on Layer 0
      page.activeLayerIndex = 0;
      final s0 = createTestStroke(page: hasPage, color: Colors.red);
      page.insertStroke(s0);
      history.recordChange(EditorHistoryItem(
        type: EditorHistoryItemType.draw,
        pageIndex: 0,
        strokes: [s0],
        images: [],
      ));

      // Draw S1 on Layer 1
      page.activeLayerIndex = 1;
      final s1 = createTestStroke(page: hasPage, color: Colors.blue);
      page.insertStroke(s1);
      history.recordChange(EditorHistoryItem(
        type: EditorHistoryItemType.draw,
        pageIndex: 0,
        strokes: [s1],
        images: [],
      ));

      expect(page.layers[0].strokes, [s0]);
      expect(page.layers[1].strokes, [s1]);

      // Undo S1
      final itemS1 = history.undo();
      page.removeStroke(itemS1.strokes.single);
      expect(page.layers[1].strokes, isEmpty);

      // Undo S0
      final itemS0 = history.undo();
      page.removeStroke(itemS0.strokes.single);
      expect(page.layers[0].strokes, isEmpty);

      // Redo S0 while activeLayerIndex is 1:
      // In editor.dart, insertStroke places stroke into activeLayer.
      // We verify that removeStroke cleanly operates regardless of which layer contains it.
      final redoS0 = history.redo();
      page.insertStroke(redoS0.strokes.single);
      expect(page.strokes.length, 1);
      expect(page.strokes.single, same(s0));
      expect(page.layers[1].strokes, [s0]);

      // removeStroke successfully finds and deletes S0 from Layer 1
      expect(page.removeStroke(s0), isTrue);
      expect(page.strokes, isEmpty);
    });
  });

  group('Adversarial Group 4: Full Editor Widget UI Stress Test', () {
    testWidgets('Editor: Rapid drawing, undoing, redoing sequence with UI state verification', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      setupMockPathProvider();
      setupMockPrinting();
      FlavorConfig.setup();
      await tester.runAsync(FileManager.init);

      await tester.pumpWidget(
        TranslationProvider(
          child: ScreenshotApp(
            device: GoldenScreenshotDevices.androidPhone.device,
            home: Editor(),
          ),
        ),
      );

      final editorState = tester.state<EditorState>(find.byType(Editor));
      addTearDown(editorState.cancelAutosaveAndMarkSaved);

      IconButton getUndoBtn() => tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.undo),
          matching: find.byType(IconButton),
        ),
      );
      IconButton getRedoBtn() => tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.redo),
          matching: find.byType(IconButton),
        ),
      );

      expect(getUndoBtn().onPressed, isNull);
      expect(getRedoBtn().onPressed, isNull);

      // Draw 5 strokes rapidly
      for (int i = 0; i < 5; i++) {
        await tester.timedDrag(
          find.byType(Editor),
          Offset(30.0 + (i * 15), 20.0),
          const Duration(milliseconds: 50),
        );
        await tester.pump();
      }

      expect(editorState.coreInfo.pages.first.strokes.length, 5);
      expect(getUndoBtn().onPressed, isNotNull);
      expect(getRedoBtn().onPressed, isNull);

      // Undo all 5 strokes
      for (int i = 5; i > 0; i--) {
        expect(editorState.coreInfo.pages.first.strokes.length, i);
        await tester.tap(find.byIcon(Icons.undo));
        await tester.pump();
      }

      expect(editorState.coreInfo.pages.first.strokes.length, 0);
      expect(getUndoBtn().onPressed, isNull);
      expect(getRedoBtn().onPressed, isNotNull);

      // Redo all 5 strokes
      for (int i = 0; i < 5; i++) {
        expect(editorState.coreInfo.pages.first.strokes.length, i);
        await tester.tap(find.byIcon(Icons.redo));
        await tester.pump();
      }

      expect(editorState.coreInfo.pages.first.strokes.length, 5);
      expect(getUndoBtn().onPressed, isNotNull);
      expect(getRedoBtn().onPressed, isNull);

      // Extra undo/redo jitter
      await tester.tap(find.byIcon(Icons.undo));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.undo));
      await tester.pump();
      expect(editorState.coreInfo.pages.first.strokes.length, 3);

      await tester.tap(find.byIcon(Icons.redo));
      await tester.pump();
      expect(editorState.coreInfo.pages.first.strokes.length, 4);

      // Draw a new stroke to invalidate redo
      await tester.timedDrag(
        find.byType(Editor),
        const Offset(100, 100),
        const Duration(milliseconds: 50),
      );
      await tester.pump();
      expect(editorState.coreInfo.pages.first.strokes.length, 5);
      expect(getRedoBtn().onPressed, isNull, reason: 'New draw must invalidate redo');
    });

    testWidgets('Editor: Multi-layer stroke removal and undo through EditorState', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      setupMockPathProvider();
      setupMockPrinting();
      FlavorConfig.setup();
      await tester.runAsync(FileManager.init);

      await tester.pumpWidget(
        TranslationProvider(
          child: ScreenshotApp(
            device: GoldenScreenshotDevices.androidPhone.device,
            home: Editor(),
          ),
        ),
      );

      final editorState = tester.state<EditorState>(find.byType(Editor));
      addTearDown(editorState.cancelAutosaveAndMarkSaved);

      // Add a second layer directly to coreInfo
      editorState.coreInfo.pages.first.layers.add(Layer(name: 'Layer 2'));
      expect(editorState.coreInfo.pages.first.layers.length, 2);

      // Draw on Layer 1 (activeLayerIndex = 0)
      await tester.timedDrag(
        find.byType(Editor),
        const Offset(60, 0),
        const Duration(milliseconds: 60),
      );
      await tester.pump();
      expect(editorState.coreInfo.pages.first.strokes.length, 1);
      expect(editorState.coreInfo.pages.first.layers[0].strokes.length, 1);

      // Switch active layer to Layer 2
      editorState.coreInfo.pages.first.activeLayerIndex = 1;

      // Draw on Layer 2
      await tester.timedDrag(
        find.byType(Editor),
        const Offset(70, 0),
        const Duration(milliseconds: 60),
      );
      await tester.pump();
      expect(editorState.coreInfo.pages.first.strokes.length, 2);
      expect(editorState.coreInfo.pages.first.layers[1].strokes.length, 1);

      // Undo Layer 2 draw
      await tester.tap(find.byIcon(Icons.undo));
      await tester.pump();
      expect(editorState.coreInfo.pages.first.strokes.length, 1);
      expect(editorState.coreInfo.pages.first.layers[1].strokes.length, 0);

      // Undo Layer 1 draw
      await tester.tap(find.byIcon(Icons.undo));
      await tester.pump();
      expect(editorState.coreInfo.pages.first.strokes.length, 0);
      expect(editorState.coreInfo.pages.first.layers[0].strokes.length, 0);

      // Redo Layer 1 draw (on activeLayerIndex = 0)
      editorState.coreInfo.pages.first.activeLayerIndex = 0;
      await tester.tap(find.byIcon(Icons.redo));
      await tester.pump();
      expect(editorState.coreInfo.pages.first.strokes.length, 1);
      expect(editorState.coreInfo.pages.first.layers[0].strokes.length, 1);

      // Redo Layer 2 draw (on activeLayerIndex = 1)
      editorState.coreInfo.pages.first.activeLayerIndex = 1;
      await tester.tap(find.byIcon(Icons.redo));
      await tester.pump();
      expect(editorState.coreInfo.pages.first.strokes.length, 2);
      expect(editorState.coreInfo.pages.first.layers[1].strokes.length, 1);

      // Hide Layer 2
      editorState.coreInfo.pages.first.layers[1].visible = false;
      expect(editorState.coreInfo.pages.first.strokes.length, 1, reason: 'Hidden layer stroke excluded from page.strokes');

      // Undo while Layer 2 is hidden: removeStroke must cleanly delete from hidden layer
      await tester.tap(find.byIcon(Icons.undo));
      await tester.pump();
      expect(editorState.coreInfo.pages.first.layers[1].strokes.length, 0);

      // Unhide Layer 2 and verify stroke was cleanly undone
      editorState.coreInfo.pages.first.layers[1].visible = true;
      expect(editorState.coreInfo.pages.first.strokes.length, 1);
      expect(editorState.coreInfo.pages.first.layers[0].strokes.length, 1);
    });
  });

  group('Adversarial Group 5: Drafting Primitives & Extreme Stress Matrix', () {
    test('ArrowStroke and DimensionStroke undo and redo lifecycle', () {
      final history = EditorHistory();
      final page = EditorPage(size: pageSize);

      final arrow = ArrowStroke(
        color: Colors.red,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasPage,
        toolId: ToolId.shapePen,
        start: const Offset(50, 50),
        end: const Offset(200, 200),
      );

      final dim = DimensionStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 1.5),
        pageIndex: 0,
        page: hasPage,
        toolId: ToolId.shapePen,
        start: const Offset(100, 100),
        end: const Offset(300, 100),
        offset: 20,
        text: '200 mm',
      );

      page.insertStroke(arrow);
      history.recordChange(EditorHistoryItem(
        type: EditorHistoryItemType.draw,
        pageIndex: 0,
        strokes: [arrow],
        images: [],
      ));

      page.insertStroke(dim);
      history.recordChange(EditorHistoryItem(
        type: EditorHistoryItemType.draw,
        pageIndex: 0,
        strokes: [dim],
        images: [],
      ));

      expect(page.strokes.length, 2);

      // Undo dimension stroke
      final undoneDim = history.undo();
      history.canRedo = true;
      expect(page.removeStroke(undoneDim.strokes.single), isTrue);
      expect(page.strokes.length, 1);
      expect(page.strokes.single, same(arrow));

      // Undo arrow stroke
      final undoneArrow = history.undo();
      history.canRedo = true;
      expect(page.removeStroke(undoneArrow.strokes.single), isTrue);
      expect(page.strokes, isEmpty);

      // Redo arrow stroke
      final redoneArrow = history.redo();
      page.insertStroke(redoneArrow.strokes.single);
      expect(page.strokes.length, 1);
      expect(page.strokes.single, same(arrow));

      // Redo dimension stroke
      final redoneDim = history.redo();
      page.insertStroke(redoneDim.strokes.single);
      expect(page.strokes.length, 2);
      expect(page.strokes.contains(arrow), isTrue);
      expect(page.strokes.contains(dim), isTrue);
    });

    test('Undoing when page.layers is completely empty does not crash', () {
      final page = EditorPage(size: pageSize);
      final s = createTestStroke(page: hasPage);
      page.insertStroke(s);

      final history = EditorHistory();
      history.recordChange(EditorHistoryItem(
        type: EditorHistoryItemType.draw,
        pageIndex: 0,
        strokes: [s],
        images: [],
      ));

      // Adversarially empty layers
      page.layers.clear();
      expect(page.layers, isEmpty);

      // Undo draw on empty page layers
      final item = history.undo();
      history.canRedo = true;
      for (final stroke in item.strokes) {
        expect(() => page.removeStroke(stroke), returnsNormally);
        expect(page.removeStroke(stroke), isFalse);
      }
      expect(page.layers, isEmpty);

      // Redo draw restores layer and stroke
      final redoItem = history.redo();
      for (final stroke in redoItem.strokes) {
        page.insertStroke(stroke);
      }
      expect(page.layers.length, 1);
      expect(page.strokes.length, 1);
    });

    test('200-cycle randomized oracle stress harness', () {
      final history = EditorHistory();
      final page = EditorPage(size: pageSize, layers: [
        Layer(name: 'L0'),
        Layer(name: 'L1'),
        Layer(name: 'L2'),
      ]);

      int strokeCounter = 0;
      final activeStrokes = <Stroke>[];

      // Pseudorandom deterministic sequence
      for (int step = 0; step < 200; step++) {
        final op = step % 5;
        switch (op) {
          case 0:
          case 1: // Draw
            page.activeLayerIndex = (step ~/ 5) % 3;
            final stroke = createTestStroke(
              page: hasPage,
              points: [Offset(strokeCounter.toDouble(), strokeCounter.toDouble())],
            );
            strokeCounter++;
            page.insertStroke(stroke);
            activeStrokes.add(stroke);
            history.recordChange(EditorHistoryItem(
              type: EditorHistoryItemType.draw,
              pageIndex: 0,
              strokes: [stroke],
              images: [],
            ));

          case 2: // Erase random active stroke if available
            if (activeStrokes.isNotEmpty) {
              final idx = (step * 7) % activeStrokes.length;
              final strokeToErase = activeStrokes.removeAt(idx);
              final removed = page.removeStroke(strokeToErase);
              expect(removed, isTrue);
              history.recordChange(EditorHistoryItem(
                type: EditorHistoryItemType.erase,
                pageIndex: 0,
                strokes: [strokeToErase],
                images: [],
              ));
            }

          case 3: // Undo
            if (history.canUndo) {
              final item = history.undo();
              history.canRedo = true;
              if (item.type == EditorHistoryItemType.draw) {
                for (final s in item.strokes) {
                  page.removeStroke(s);
                  activeStrokes.remove(s);
                }
              } else if (item.type == EditorHistoryItemType.erase) {
                for (final s in item.strokes) {
                  page.insertStroke(s);
                  activeStrokes.add(s);
                }
              }
            }

          case 4: // Redo
            if (history.canRedo) {
              final item = history.redo();
              if (item.type == EditorHistoryItemType.draw) {
                for (final s in item.strokes) {
                  page.insertStroke(s);
                  activeStrokes.add(s);
                }
              } else if (item.type == EditorHistoryItemType.erase) {
                for (final s in item.strokes) {
                  page.removeStroke(s);
                  activeStrokes.remove(s);
                }
              }
            }
        }

        // State invariant check at each step
        expect(page.layers.length, 3, reason: 'Layer count must remain exactly 3');
        final allLayerStrokes = [for (final l in page.layers) ...l.strokes];
        expect(allLayerStrokes.length, activeStrokes.length,
            reason: 'Total strokes in layers must match active strokes');
      }
    });
  });
}
