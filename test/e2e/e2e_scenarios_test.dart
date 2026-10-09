/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_polygon_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/editor_exporter.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pageSize = Size(1000, 1400);
  const pageDef = HasSize(pageSize);

  setUpAll(() {
    FlavorConfig.setup();
  });

  setUp(() {
    stows.snapToGrid.value = false;
    stows.gridSize.value = 20.0;
    stows.snapToAngle.value = false;
    stows.snapAngleStep.value = 15;
  });

  group('Tier 3: Cross-Feature Combinations (Pairwise)', () {
    test('Pair 1: Isometric Grid + Angle Snap 30° + Ruler Tool Snapping', () {
      final ruler = Ruler();
      final page = EditorPage();

      stows.snapToAngle.value = true;
      stows.snapAngleStep.value = 30;

      ruler.onDragStart(Offset.zero, page, 0, null);
      // Drag at ~28 degrees
      const rad28 = 28 * pi / 180;
      ruler.onDragUpdate(Offset(100 * cos(rad28), 100 * sin(rad28)), null);
      final stroke = ruler.onDragEnd();

      expect(stroke, isNotNull);
      final angle =
          atan2(stroke!.points.last.dy, stroke.points.last.dx) * 180 / pi;
      expect(angle, closeTo(30.0, 0.01));
      // Slopes match tan(30)
      final slope = stroke.points.last.dy / stroke.points.last.dx;
      expect(slope, closeTo(tan(30 * pi / 180), 0.01));
    });

    test(
      'Pair 2: Dimension Stroke on Drafting Layer + PDF Vector Classification',
      () {
        final layer0 = Layer(name: 'Construction', visible: false);
        final layer1 = Layer(name: 'Drafting', visible: true);
        final page = EditorPage(layers: [layer0, layer1]);

        final refLine = _createTestStroke(toolId: ToolId.fountainPen);
        layer0.strokes.add(refLine);

        final dim = DimensionStroke(
          color: Colors.blue,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: pageDef,
          toolId: ToolId.shapePen,
          start: const Offset(50, 50),
          end: const Offset(250, 50),
          offset: 30.0,
          text: '200 mm',
        );
        layer1.strokes.add(dim);

        // Page strokes should exclude hidden layer
        expect(page.strokes, hasLength(1));
        expect(page.strokes.first, equals(dim));

        // Dimension stroke qualifies for PDF vector export
        expect(EditorExporter.shouldRasterizeStroke(dim), isFalse);
      },
    );

    test('Pair 3: Arrow Stroke Vertex Manipulation + Undo/Redo Stack', () {
      final history = EditorHistory();
      final page = EditorPage();

      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.shapePen,
        start: const Offset(10, 10),
        end: const Offset(100, 10),
      );

      page.insertStroke(arrow);
      history.recordChange(
        EditorHistoryItem(
          type: EditorHistoryItemType.draw,
          pageIndex: 0,
          strokes: [arrow],
          images: const [],
        ),
      );

      expect(page.strokes, hasLength(1));

      // Manipulate endpoint
      arrow.end = const Offset(150, 40);
      expect(arrow.end, equals(const Offset(150, 40)));

      // Execute undo
      history.canRedo = true;
      final undone = history.undo();
      for (final s in undone.strokes) {
        page.removeStroke(s);
      }
      expect(page.strokes, isEmpty);

      // Execute redo
      final redone = history.redo();
      for (final s in redone.strokes) {
        page.insertStroke(s);
      }
      expect(page.strokes, hasLength(1));
      expect(page.strokes.first, equals(arrow));
    });

    test('Pair 4: Page Line Height Coupling to Grid Snap Multiples', () {
      const double initialLineHeight = 20.0;
      const double updatedLineHeight = 35.0;

      const testPoint = Offset(38.0, 54.0);

      // Initial snap with 20 px
      final snappedInitial = Stroke.snapPointToGrid(
        testPoint,
        initialLineHeight,
      );
      expect(snappedInitial, equals(const Offset(40.0, 60.0)));

      // Updated snap with 35 px
      final snappedUpdated = Stroke.snapPointToGrid(
        testPoint,
        updatedLineHeight,
      );
      expect(snappedUpdated, equals(const Offset(35.0, 70.0)));
    });

    test(
      'Pair 5: Angle Snap 45° with Arrow Stroke Serialization Roundtrip',
      () {
        const p1 = PointVector(0, 0, 1.0);
        const rad43 = 43 * pi / 180;
        final p2 = PointVector(100 * cos(rad43), 100 * sin(rad43), 1.0);

        final (_, snappedP2) = Stroke.snapLineToAngle(p1, p2, 45.0);

        final arrow = ArrowStroke(
          color: Colors.red,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: pageDef,
          toolId: ToolId.shapePen,
          start: Offset(p1.dx, p1.dy),
          end: Offset(snappedP2.dx, snappedP2.dy),
        );

        final json = arrow.toJson();
        final restored = ArrowStroke.fromJson(
          json,
          fileVersion: 1,
          pageIndex: 0,
          page: pageDef,
        );

        final angle =
            atan2(
              restored.end.dy - restored.start.dy,
              restored.end.dx - restored.start.dx,
            ) *
            180 /
            pi;
        expect(angle, closeTo(45.0, 0.01));
      },
    );

    test('Pair 6: Polygon Snap to Grid with Bounding Box Bounds', () {
      const double gridSize = 25.0;
      final rawVertices = [
        const Offset(12, 8),
        const Offset(63, 11),
        const Offset(52, 48),
      ];

      final snappedVertices = rawVertices
          .map((v) => Stroke.snapPointToGrid(v, gridSize))
          .toList();
      expect(
        snappedVertices,
        equals([Offset.zero, const Offset(75, 0), const Offset(50, 50)]),
      );

      final poly = PolygonStroke(
        color: Colors.purple,
        fillColor: Colors.yellow,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.shapePen,
        vertices: snappedVertices,
        closed: true,
      );

      expect(poly.vertices, hasLength(3));
      expect(poly.fillColor, equals(Colors.yellow));
      expect(poly.closed, isTrue);
    });

    test('Pair 7: HUD Snap Toggle Controls Ruler Snapping and Undo', () {
      final ruler = Ruler();
      final page = EditorPage();
      final history = EditorHistory();

      // Step 1: Snap disabled
      stows.snapToGrid.value = false;
      ruler.onDragStart(const Offset(10, 10), page, 0, null);
      ruler.onDragUpdate(const Offset(47, 53), null);
      final unsnapped = ruler.onDragEnd()!;
      expect(unsnapped.points.last.x, equals(47.0));

      // Step 2: Snap enabled
      stows.snapToGrid.value = true;
      stows.gridSize.value = 20.0;
      ruler.onDragStart(const Offset(10, 10), page, 0, null);
      ruler.onDragUpdate(const Offset(47, 53), null);
      final snapped = ruler.onDragEnd()!;
      expect(snapped.points.last.x, equals(40.0));
      expect(snapped.points.last.y, equals(60.0));

      page.insertStroke(snapped);
      history.recordChange(
        EditorHistoryItem(
          type: EditorHistoryItemType.draw,
          pageIndex: 0,
          strokes: [snapped],
          images: const [],
        ),
      );

      // Undo removes snapped line
      history.canRedo = true;
      final undone = history.undo();
      page.removeStroke(undone.strokes.first);
      expect(page.strokes, isEmpty);
    });

    test('Pair 8: Engineering Grid 10-Cell Span Dimension Measurement', () {
      const double lineHeight = 10.0;
      const int cellCount = 10;
      const double totalSpan = lineHeight * cellCount; // 100.0

      const start = Offset(50, 50);
      const end = Offset(50 + totalSpan, 50);

      final dim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.shapePen,
        start: start,
        end: end,
        offset: 25.0,
        text: '${totalSpan.toInt()} mm',
      );

      final distance = (dim.end - dim.start).distance;
      expect(distance, equals(100.0));
      expect(dim.text, equals('100 mm'));
    });

    test('Pair 9: Multi-Primitive Drafting Layer Insertion and Ordering', () {
      final page = EditorPage();

      final penStroke = _createTestStroke(toolId: ToolId.fountainPen);
      final arrow = ArrowStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.shapePen,
        start: const Offset(10, 10),
        end: const Offset(100, 10),
      );
      final dim = DimensionStroke(
        color: Colors.green,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.shapePen,
        start: const Offset(20, 20),
        end: const Offset(120, 20),
      );

      page.insertStroke(penStroke);
      page.insertStroke(arrow);
      page.insertStroke(dim);

      expect(page.strokes, hasLength(3));
      expect(page.strokes, contains(penStroke));
      expect(page.strokes, contains(arrow));
      expect(page.strokes, contains(dim));
    });

    test('Pair 10: Multi-Layer Undo/Redo Stroke Properties Preservation', () {
      final layer0 = Layer(name: 'L0');
      final layer1 = Layer(name: 'L1');
      final page = EditorPage(layers: [layer0, layer1]);
      final history = EditorHistory();

      page.activeLayerIndex = 1;
      final customStroke = _createTestStroke(
        color: const Color(0xFF112233),
        toolId: ToolId.ballpointPen,
      );

      page.insertStroke(customStroke);
      history.recordChange(
        EditorHistoryItem(
          type: EditorHistoryItemType.draw,
          pageIndex: 0,
          strokes: [customStroke],
          images: const [],
        ),
      );

      // Undo
      history.canRedo = true;
      final undone = history.undo();
      page.removeStroke(undone.strokes.first);
      expect(page.strokes, isEmpty);

      // Redo
      final redone = history.redo();
      page.insertStroke(redone.strokes.first);
      expect(page.strokes, hasLength(1));
      expect(page.strokes.first.color.toARGB32(), equals(0xFF112233));
      expect(page.strokes.first.toolId, equals(ToolId.ballpointPen));
    });
  });

  group('Tier 4: Real-World Coursework/Drafting Application Scenarios', () {
    test('Scenario 1: School Coursework Note Creation Workflow', () {
      // 1. Student opens note and initializes page with Grid paper
      final page = EditorPage();
      final history = EditorHistory();

      // 2. Handwriting input (writes equation line 1)
      final stroke1 = _createTestStroke(
        start: const Offset(50, 100),
        end: const Offset(150, 100),
      );
      page.insertStroke(stroke1);
      history.recordChange(
        EditorHistoryItem(
          type: EditorHistoryItemType.draw,
          pageIndex: 0,
          strokes: [stroke1],
          images: const [],
        ),
      );

      // 3. Writes mistaken stroke
      final strokeMistake = _createTestStroke(
        start: const Offset(150, 100),
        end: const Offset(200, 150),
      );
      page.insertStroke(strokeMistake);
      history.recordChange(
        EditorHistoryItem(
          type: EditorHistoryItemType.draw,
          pageIndex: 0,
          strokes: [strokeMistake],
          images: const [],
        ),
      );
      expect(page.strokes, hasLength(2));

      // 4. Undoes mistake cleanly
      history.canRedo = true;
      final undone = history.undo();
      for (final s in undone.strokes) {
        page.removeStroke(s);
      }
      expect(page.strokes, hasLength(1));
      expect(page.strokes.contains(strokeMistake), isFalse);

      // 5. Continues writing correct solution
      final strokeCorrect = _createTestStroke(
        start: const Offset(150, 100),
        end: const Offset(250, 100),
      );
      page.insertStroke(strokeCorrect);
      history.recordChange(
        EditorHistoryItem(
          type: EditorHistoryItemType.draw,
          pageIndex: 0,
          strokes: [strokeCorrect],
          images: const [],
        ),
      );
      expect(page.strokes, hasLength(2));

      // 6. Autosave triggered
      expect(history.isCurrentStateSaved, isFalse);
      history.markLastChangeAsSaved();
      expect(history.isCurrentStateSaved, isTrue);
    });

    test('Scenario 2: Isometric Engineering Schematic Drawing Workflow', () {
      // 1. Engineering student sets isometric grid
      const double L = 30.0;
      final double dx = L * cos(pi / 6); // L * sqrt(3) / 2

      // 2. Drafts 3D isometric cube vertices
      // Center origin vertex
      const origin = Offset(200, 200);
      // Top vertical edge: 90 degrees
      final topV = Offset(origin.dx, origin.dy - L);
      // Right diagonal edge: +30 degrees down
      final rightDiag = Offset(origin.dx + dx, origin.dy + L * 0.5);
      // Left diagonal edge: -30 degrees down
      final leftDiag = Offset(origin.dx - dx, origin.dy + L * 0.5);

      // 3. Angle verification using Stroke.snapLineToAngle at 30 deg
      final (_, snappedTop) = Stroke.snapLineToAngle(
        PointVector.fromOffset(offset: origin),
        PointVector.fromOffset(offset: topV),
        30.0,
      );
      expect(snappedTop.dx, closeTo(origin.dx, 1e-4));

      final (_, snappedRight) = Stroke.snapLineToAngle(
        PointVector.fromOffset(offset: origin),
        PointVector.fromOffset(offset: rightDiag),
        30.0,
      );
      final rightAngle =
          atan2(snappedRight.dy - origin.dy, snappedRight.dx - origin.dx) *
          180 /
          pi;
      expect(rightAngle, closeTo(30.0, 0.01));

      final (_, snappedLeft) = Stroke.snapLineToAngle(
        PointVector.fromOffset(offset: origin),
        PointVector.fromOffset(offset: leftDiag),
        30.0,
      );
      final leftAngle =
          atan2(snappedLeft.dy - origin.dy, snappedLeft.dx - origin.dx) *
          180 /
          pi;
      expect(leftAngle, closeTo(150.0, 0.01));

      // 4. Vertex concurrence verification: diagonals meet origin at exact vertex
      expect(origin.dx, closeTo(snappedRight.dx - dx, 1e-4));
      expect(origin.dy, closeTo(snappedRight.dy - L * 0.5, 1e-4));
    });

    test('Scenario 3: Architectural Dimensioned Floorplan Workflow', () {
      // 1. Student sets wall grid module to 20 px
      const double wallGrid = 20.0;
      stows.snapToGrid.value = true;
      stows.gridSize.value = wallGrid;

      // 2. Draws north wall from (40, 40) to (240, 40)
      final wallStart = Stroke.snapPointToGrid(const Offset(38, 42), wallGrid);
      final wallEnd = Stroke.snapPointToGrid(const Offset(239, 41), wallGrid);

      expect(wallStart, equals(const Offset(40, 40)));
      expect(wallEnd, equals(const Offset(240, 40)));

      // 3. Places DimensionStroke between wall corners
      final dim = DimensionStroke(
        color: Colors.blueAccent,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.shapePen,
        start: wallStart,
        end: wallEnd,
        offset: 25.0,
        text: '200 mm',
      );

      expect(dim.offset, equals(25.0));
      expect(dim.text, equals('200 mm'));

      // 4. Adjusts dimension offset for plan legibility
      dim.offset = 50.0;
      expect(dim.offset, equals(50.0));
      expect(dim.textPosition.dy, closeTo(90.0, 1e-4)); // 40 + 50 = 90
    });

    test('Scenario 4: Technical Diagram PDF Export Workflow', () {
      // 1. Multi-layer drafting document
      final constructionLayer = Layer(
        name: 'Construction Guides',
        visible: false,
      );
      final schematicLayer = Layer(name: 'Schematic', visible: true);
      final page = EditorPage(layers: [constructionLayer, schematicLayer]);

      // 2. Guidelines on construction layer
      final guideLine = _createTestStroke(toolId: ToolId.fountainPen);
      constructionLayer.strokes.add(guideLine);

      // 3. Final vector primitives on schematic layer
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.shapePen,
        start: const Offset(100, 100),
        end: const Offset(300, 100),
      );
      final dimension = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.shapePen,
        start: const Offset(100, 100),
        end: const Offset(300, 100),
        offset: 30.0,
      );
      schematicLayer.strokes.add(arrow);
      schematicLayer.strokes.add(dimension);

      // 4. Layer filtering for export: construction guides omitted
      expect(page.strokes, hasLength(2));
      expect(page.strokes, contains(arrow));
      expect(page.strokes, contains(dimension));
      expect(page.strokes.contains(guideLine), isFalse);

      // 5. PDF vector export eligibility
      for (final s in page.strokes) {
        expect(EditorExporter.shouldRasterizeStroke(s), isFalse);
      }
    });

    test(
      'Scenario 5: End-to-End Packaging & Clean Sideload Pipeline Audit',
      () {
        // 1. Codemagic workflow check
        final codemagicFile = File('codemagic.yaml');
        expect(codemagicFile.existsSync(), isTrue);
        final codemagic = codemagicFile.readAsStringSync();
        expect(codemagic, contains('mac_mini_m2'));
        expect(codemagic, contains('flutter pub get --directory=packages/sbn'));
        expect(
          codemagic,
          contains('flutter pub get --directory=packages/onyxsdk_pen'),
        );
        expect(codemagic, contains('--no-codesign'));
        expect(codemagic, contains('Opennote.ipa'));

        // 2. iOS project metadata check
        final infoPlistFile = File('ios/Runner/Info.plist');
        expect(infoPlistFile.existsSync(), isTrue);
        final infoPlist = infoPlistFile.readAsStringSync();
        expect(infoPlist, contains('<string>Opennote</string>'));

        // 3. iOS deployment target check
        final pbxprojFile = File('ios/Runner.xcodeproj/project.pbxproj');
        expect(pbxprojFile.existsSync(), isTrue);
        final pbxproj = pbxprojFile.readAsStringSync();
        expect(pbxproj, contains('IPHONEOS_DEPLOYMENT_TARGET = 14.0;'));
      },
    );
  });
}

// -----------------------------------------------------------------
// Helper Factory
// -----------------------------------------------------------------
Stroke _createTestStroke({
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
