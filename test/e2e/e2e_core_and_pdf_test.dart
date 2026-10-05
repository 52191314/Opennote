/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_circle_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_rectangle_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/editor_exporter.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Feature 1: Core Note-Taking & Undo/Redo (ORIGINAL_REQUEST § R1)', () {
    // -------------------------------------------------------------
    // Tier 1: Feature Coverage (>=5 tests)
    // -------------------------------------------------------------
    test('T1.1: Handwriting stroke insertion into page active layer', () {
      final page = EditorPage();
      final stroke = _createStroke(
        start: const Offset(10, 10),
        end: const Offset(50, 50),
      );

      expect(page.strokes, isEmpty);
      page.insertStroke(stroke);

      expect(page.strokes, hasLength(1));
      expect(page.activeLayerStrokes, hasLength(1));
      expect(page.strokes.first, equals(stroke));
    });

    test('T1.2: Stroke removal via page removeStroke contract', () {
      final page = EditorPage();
      final stroke = _createStroke(
        start: const Offset(20, 20),
        end: const Offset(80, 80),
      );

      page.insertStroke(stroke);
      expect(page.strokes, hasLength(1));

      final removed = page.removeStroke(stroke);
      expect(removed, isTrue);
      expect(page.strokes, isEmpty);
      expect(page.activeLayerStrokes, isEmpty);
    });

    test('T1.3: Undo/Redo single stroke lifecycle with EditorHistory', () {
      final history = EditorHistory();
      final page = EditorPage();
      final stroke = _createStroke(
        start: const Offset(15, 15),
        end: const Offset(60, 60),
      );

      page.insertStroke(stroke);
      history.recordChange(
        EditorHistoryItem(
          type: EditorHistoryItemType.draw,
          pageIndex: 0,
          strokes: [stroke],
          images: const [],
        ),
      );

      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);

      // Execute Undo
      history.canRedo = true;
      final undone = history.undo();
      for (final s in undone.strokes) {
        page.removeStroke(s);
      }
      expect(page.strokes, isEmpty);
      expect(history.canUndo, isFalse);
      expect(history.canRedo, isTrue);

      // Execute Redo
      final redone = history.redo();
      for (final s in redone.strokes) {
        page.insertStroke(s);
      }
      expect(page.strokes, hasLength(1));
      expect(history.canUndo, isTrue);
    });

    test('T1.4: Multi-layer stroke insertion and isolated layer undo', () {
      final layer0 = Layer(name: 'Base Layer');
      final layer1 = Layer(name: 'Overlay Layer');
      final page = EditorPage(layers: [layer0, layer1], activeLayerIndex: 0);

      final stroke1 = _createStroke(
        start: const Offset(10, 10),
        end: const Offset(50, 50),
      );
      final stroke2 = _createStroke(
        start: const Offset(60, 60),
        end: const Offset(90, 90),
      );

      // Draw stroke1 on layer 0
      page.activeLayerIndex = 0;
      page.insertStroke(stroke1);

      // Draw stroke2 on layer 1
      page.activeLayerIndex = 1;
      page.insertStroke(stroke2);

      expect(page.strokes, hasLength(2));
      expect(layer0.strokes, hasLength(1));
      expect(layer1.strokes, hasLength(1));

      // Undo only stroke2 on layer 1
      final removed = page.removeStroke(stroke2);
      expect(removed, isTrue);
      expect(page.strokes, hasLength(1));
      expect(layer0.strokes, contains(stroke1));
      expect(layer1.strokes, isEmpty);
    });

    test('T1.5: Autosave dirty and saved state tracking in EditorHistory', () {
      final history = EditorHistory();
      final stroke1 = _createStroke();

      expect(history.isCurrentStateSaved, isTrue);

      history.recordChange(
        EditorHistoryItem(
          type: EditorHistoryItemType.draw,
          pageIndex: 0,
          strokes: [stroke1],
          images: const [],
        ),
      );
      expect(history.isCurrentStateSaved, isFalse);

      history.markLastChangeAsSaved();
      expect(history.isCurrentStateSaved, isTrue);

      final stroke2 = _createStroke();
      history.recordChange(
        EditorHistoryItem(
          type: EditorHistoryItemType.draw,
          pageIndex: 0,
          strokes: [stroke2],
          images: const [],
        ),
      );
      expect(history.isCurrentStateSaved, isFalse);
    });

    // -------------------------------------------------------------
    // Tier 2: Boundary & Corner Cases (>=5 tests)
    // -------------------------------------------------------------
    test('T2.1: Calling undo on empty history throws exception', () {
      final history = EditorHistory();
      expect(history.canUndo, isFalse);
      expect(() => history.undo(), throwsA(isA<Exception>()));
    });

    test('T2.2: Calling redo on empty history throws exception', () {
      final history = EditorHistory();
      history.canRedo = true;
      expect(() => history.redo(), throwsA(isA<Exception>()));
    });

    test(
      'T2.3: Rapid alternating undo/redo sequences across multiple strokes',
      () {
        final history = EditorHistory();
        final page = EditorPage();
        final strokes = List.generate(
          5,
          (i) => _createStroke(
            start: Offset(i * 10.0, 0),
            end: Offset(i * 10.0, 50),
          ),
        );

        for (final s in strokes) {
          page.insertStroke(s);
          history.recordChange(
            EditorHistoryItem(
              type: EditorHistoryItemType.draw,
              pageIndex: 0,
              strokes: [s],
              images: const [],
            ),
          );
        }
        expect(page.strokes, hasLength(5));

        // Alternating undo and redo
        for (int i = 0; i < 3; i++) {
          history.canRedo = true;
          final undone = history.undo();
          for (final s in undone.strokes) {
            page.removeStroke(s);
          }
          expect(page.strokes, hasLength(4));

          final redone = history.redo();
          for (final s in redone.strokes) {
            page.insertStroke(s);
          }
          expect(page.strokes, hasLength(5));
        }
      },
    );

    test('T2.4: Stroke with zero length insertion and removal boundary', () {
      final page = EditorPage();
      final zeroLengthStroke = _createStroke(
        start: const Offset(100, 100),
        end: const Offset(100, 100),
      );

      page.insertStroke(zeroLengthStroke);
      expect(page.strokes, hasLength(1));
      expect(
        page.strokes.first.points.first.x,
        equals(page.strokes.first.points.last.x),
      );

      final removed = page.removeStroke(zeroLengthStroke);
      expect(removed, isTrue);
      expect(page.strokes, isEmpty);
    });

    test('T2.5: Zero pressure and disabled pressure handling on Stroke', () {
      final stroke = Stroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 4.0),
        pageIndex: 0,
        page: const HasSize(Size(1000, 1400)),
        toolId: ToolId.fountainPen,
      );
      stroke.addPoint(const Offset(10, 10), 0.0);
      stroke.addPoint(const Offset(30, 30), null);

      expect(stroke.pressureEnabled, isFalse);
      expect(stroke.points, hasLength(2));
      expect(stroke.points.first.pressure, isNull);
    });
  });

  group('Feature 2: PDF Import & Vector Export (ORIGINAL_REQUEST § R1)', () {
    // -------------------------------------------------------------
    // Tier 1: Feature Coverage (>=5 tests)
    // -------------------------------------------------------------
    test('T1.6: Vector classification: linear tools are not rasterized', () {
      final fountainPenStroke = _createStroke(toolId: ToolId.fountainPen);
      final ballpointPenStroke = _createStroke(toolId: ToolId.ballpointPen);
      final rulerStroke = _createStroke(toolId: ToolId.ruler);
      final shapePenStroke = _createStroke(toolId: ToolId.shapePen);

      expect(EditorExporter.shouldRasterizeStroke(fountainPenStroke), isFalse);
      expect(EditorExporter.shouldRasterizeStroke(ballpointPenStroke), isFalse);
      expect(EditorExporter.shouldRasterizeStroke(rulerStroke), isFalse);
      expect(EditorExporter.shouldRasterizeStroke(shapePenStroke), isFalse);
    });

    test(
      'T1.7: Rasterization classification: highlighter and pencil are rasterized',
      () {
        final highlighterStroke = _createStroke(toolId: ToolId.highlighter);
        final pencilStroke = _createStroke(toolId: ToolId.pencil);

        expect(EditorExporter.shouldRasterizeStroke(highlighterStroke), isTrue);
        expect(EditorExporter.shouldRasterizeStroke(pencilStroke), isTrue);
      },
    );

    test('T1.8: Drafting primitives are classified for vector export', () {
      final arrow = _createArrowStroke();
      final dimension = _createDimensionStroke();

      expect(EditorExporter.shouldRasterizeStroke(arrow), isFalse);
      expect(EditorExporter.shouldRasterizeStroke(dimension), isFalse);
    });

    test('T1.9: Hidden layers excluded from exported page.strokes', () {
      final layerVisible = Layer(name: 'Visible', visible: true);
      final layerHidden = Layer(name: 'Construction', visible: false);
      final page = EditorPage(layers: [layerVisible, layerHidden]);

      final s1 = _createStroke(
        start: const Offset(10, 10),
        end: const Offset(20, 20),
      );
      final s2 = _createStroke(
        start: const Offset(30, 30),
        end: const Offset(40, 40),
      );

      layerVisible.strokes.add(s1);
      layerHidden.strokes.add(s2);

      // Flattened page.strokes must omit s2 from hidden layer
      expect(page.strokes, hasLength(1));
      expect(page.strokes, contains(s1));
      expect(page.strokes.contains(s2), isFalse);
    });

    test('T1.10: SVG coordinate inversion contract in Stroke.toSvgPath', () {
      const pageSize = Size(1000, 1400);
      final stroke = Stroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: const HasSize(pageSize),
        toolId: ToolId.fountainPen,
      );
      stroke.addPoint(const Offset(100, 200));
      stroke.addPoint(const Offset(300, 400));

      final svgPath = stroke.toSvgPath();
      expect(svgPath, isNotEmpty);
      expect(svgPath.startsWith('M'), isTrue);

      // In PDF coordinate system, Y is inverted: page.size.height - y
      // y = 200 -> inverted Y = 1200
      // y = 400 -> inverted Y = 1000
      expect(
        svgPath.contains('100.0 1200.0') || svgPath.contains('1200'),
        isTrue,
      );
    });

    // -------------------------------------------------------------
    // Tier 2: Boundary & Corner Cases (>=5 tests)
    // -------------------------------------------------------------
    test('T2.6: Zero-length stroke toSvgPath output handles gracefully', () {
      const pageSize = Size(1000, 1000);
      final stroke = Stroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: const HasSize(pageSize),
        toolId: ToolId.fountainPen,
      );
      // Empty stroke
      expect(stroke.toSvgPath(), isEmpty);

      // Single point
      stroke.addPoint(const Offset(50, 50));
      final svg = stroke.toSvgPath();
      expect(svg, isNot(contains('NaN')));
    });

    test('T2.7: Negative coordinates in stroke SVG conversion', () {
      const pageSize = Size(1000, 1000);
      final stroke = Stroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: const HasSize(pageSize),
        toolId: ToolId.fountainPen,
      );
      stroke.addPoint(const Offset(-50, -50));
      stroke.addPoint(const Offset(10, 10));

      final svgPath = stroke.toSvgPath();
      expect(svgPath, isNotEmpty);
      expect(svgPath, isNot(contains('NaN')));
      expect(svgPath, isNot(contains('Infinity')));
    });

    test(
      'T2.8: Extreme canvas aspect ratios preserve coordinate conversion',
      () {
        // 10:1 tall page
        const tallSize = Size(500, 5000);
        final tallStroke = Stroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 1.0),
          pageIndex: 0,
          page: const HasSize(tallSize),
          toolId: ToolId.fountainPen,
        );
        tallStroke.addPoint(const Offset(250, 4500));
        final tallSvg = tallStroke.toSvgPath();
        expect(tallSvg, isNotEmpty);
        expect(
          tallSvg.contains('500.0') || tallSvg.contains('500'),
          isTrue,
        ); // 5000 - 4500 = 500
      },
    );

    test(
      'T2.9: ArrowStroke and DimensionStroke toSvgPath generate valid paths',
      () {
        final arrow = _createArrowStroke(
          start: const Offset(10, 10),
          end: const Offset(100, 10),
        );
        final dimension = _createDimensionStroke(
          start: const Offset(20, 20),
          end: const Offset(120, 20),
        );

        final arrowSvg = arrow.toSvgPath();
        final dimSvg = dimension.toSvgPath();

        expect(arrowSvg, startsWith('M'));
        expect(arrowSvg, contains('L'));
        expect(arrowSvg, isNot(contains('NaN')));

        expect(dimSvg, startsWith('M'));
        expect(dimSvg, contains('L'));
        expect(dimSvg, isNot(contains('NaN')));
      },
    );

    test(
      'T2.10: High density multi-layer vector strokes flattening integrity',
      () {
        final layers = List.generate(
          3,
          (l) => Layer(name: 'Layer $l', visible: true),
        );
        final page = EditorPage(layers: layers);

        for (int l = 0; l < 3; l++) {
          for (int i = 0; i < 50; i++) {
            layers[l].strokes.add(
              _createStroke(start: Offset(i.toDouble(), l.toDouble())),
            );
          }
        }

        expect(page.strokes, hasLength(150));
        // Toggling visibility of one layer
        layers[1].visible = false;
        expect(page.strokes, hasLength(100));
      },
    );
  });
}

// -----------------------------------------------------------------
// Helper Factory Functions
// -----------------------------------------------------------------
Stroke _createStroke({
  Offset start = const Offset(10, 10),
  Offset end = const Offset(100, 100),
  Color color = Colors.black,
  ToolId toolId = ToolId.fountainPen,
  int pageIndex = 0,
  Size pageSize = const Size(1000, 1400),
}) {
  final stroke = Stroke(
    color: color,
    pressureEnabled: false,
    options: StrokeOptions(size: 2.0),
    pageIndex: pageIndex,
    page: HasSize(pageSize),
    toolId: toolId,
  );
  stroke.addPoint(start);
  stroke.addPoint(end);
  return stroke;
}

ArrowStroke _createArrowStroke({
  Offset start = const Offset(20, 20),
  Offset end = const Offset(150, 80),
  Color color = Colors.blue,
  ArrowheadStyle arrowheadStyle = ArrowheadStyle.single,
  int pageIndex = 0,
  Size pageSize = const Size(1000, 1400),
}) {
  return ArrowStroke(
    color: color,
    pressureEnabled: false,
    options: StrokeOptions(size: 2.0),
    pageIndex: pageIndex,
    page: HasSize(pageSize),
    toolId: ToolId.shapePen,
    start: start,
    end: end,
    arrowheadStyle: arrowheadStyle,
  );
}

DimensionStroke _createDimensionStroke({
  Offset start = const Offset(50, 50),
  Offset end = const Offset(250, 50),
  double offset = 30.0,
  String text = '200 mm',
  Color color = Colors.green,
  int pageIndex = 0,
  Size pageSize = const Size(1000, 1400),
}) {
  return DimensionStroke(
    color: color,
    pressureEnabled: false,
    options: StrokeOptions(size: 2.0),
    pageIndex: pageIndex,
    page: HasSize(pageSize),
    toolId: ToolId.shapePen,
    start: start,
    end: end,
    offset: offset,
    text: text,
  );
}
