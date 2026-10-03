/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';

import 'package:bson/bson.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/arrow.dart';
import 'package:saber/data/tools/dimension.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/select.dart';
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
    Pen.currentStroke = null;
  });

  group('1. ToolId Definitions for Drafting Primitives', () {
    test('ToolId.arrow and ToolId.dimension are defined with proper identifiers', () {
      expect(ToolId.arrow.id, equals('ArrowTool'));
      expect(ToolId.dimension.id, equals('DimensionTool'));
    });

    test('ToolId.parsePenType resolves ArrowTool and DimensionTool identifiers', () {
      expect(ToolId.parsePenType('ArrowTool', fallback: ToolId.fountainPen), equals(ToolId.arrow));
      expect(ToolId.parsePenType('DimensionTool', fallback: ToolId.fountainPen), equals(ToolId.dimension));
    });

    test('ToolId.codec encodes and decodes drafting tool identifiers', () {
      final encodedArrow = ToolId.codec.encoder.convert(ToolId.arrow);
      final decodedArrow = ToolId.codec.decoder.convert(encodedArrow);
      expect(decodedArrow, equals(ToolId.arrow));

      final encodedDim = ToolId.codec.encoder.convert(ToolId.dimension);
      final decodedDim = ToolId.codec.decoder.convert(encodedDim);
      expect(decodedDim, equals(ToolId.dimension));
    });
  });

  group('2. ArrowTool Interactive Construction & Snapping', () {
    test('ArrowTool instantiation has expected defaults', () {
      final tool = ArrowTool();
      expect(tool.name, equals('Arrow'));
      expect(tool.toolId, equals(ToolId.arrow));
      expect(tool.arrowheadStyle, equals(ArrowheadStyle.single));
      expect(tool.pressureEnabled, isFalse);
    });

    test('ArrowTool custom arrowheadStyle option is respected', () {
      final doubleHeadTool = ArrowTool(arrowheadStyle: ArrowheadStyle.double);
      expect(doubleHeadTool.arrowheadStyle, equals(ArrowheadStyle.double));

      final noneHeadTool = ArrowTool(arrowheadStyle: ArrowheadStyle.none);
      expect(noneHeadTool.arrowheadStyle, equals(ArrowheadStyle.none));
    });

    test('ArrowTool drag interaction creates and returns ArrowStroke', () {
      final tool = ArrowTool();
      final page = EditorPage();

      tool.onDragStart(const Offset(50, 100), page, 0, null);
      expect(Pen.currentStroke, isA<ArrowStroke>());
      final activeArrow = Pen.currentStroke as ArrowStroke;
      expect(activeArrow.start, equals(const Offset(50, 100)));
      expect(activeArrow.end, equals(const Offset(50, 100)));

      tool.onDragUpdate(const Offset(250, 100), null);
      expect(activeArrow.end, equals(const Offset(250, 100)));

      final finishedStroke = tool.onDragEnd();
      expect(finishedStroke, isA<ArrowStroke>());
      expect(Pen.currentStroke, isNull);

      final arrow = finishedStroke as ArrowStroke;
      expect(arrow.start, equals(const Offset(50, 100)));
      expect(arrow.end, equals(const Offset(250, 100)));
      expect(arrow.options.isComplete, isTrue);
    });

    test('ArrowTool zero-length drag is discarded', () {
      final tool = ArrowTool();
      final page = EditorPage();

      tool.onDragStart(const Offset(100, 100), page, 0, null);
      tool.onDragUpdate(const Offset(100, 100), null);
      final finishedStroke = tool.onDragEnd();
      expect(finishedStroke, isNull);
      expect(Pen.currentStroke, isNull);
    });

    test('ArrowTool respects grid snapping', () {
      final tool = ArrowTool();
      final page = EditorPage();
      stows.snapToGrid.value = true;
      stows.gridSize.value = 25.0;

      // Start drag near (25, 50)
      tool.onDragStart(const Offset(24, 52), page, 0, null);
      final activeArrow = Pen.currentStroke as ArrowStroke;
      expect(activeArrow.start, equals(const Offset(25, 50)));

      // Update drag near (100, 150)
      tool.onDragUpdate(const Offset(103, 148), null);
      expect(activeArrow.end, equals(const Offset(100, 150)));

      final finished = tool.onDragEnd() as ArrowStroke;
      expect(finished.start, equals(const Offset(25, 50)));
      expect(finished.end, equals(const Offset(100, 150)));
    });

    test('ArrowTool respects angle snapping (45 degrees)', () {
      final tool = ArrowTool();
      final page = EditorPage();
      stows.snapToAngle.value = true;
      stows.snapAngleStep.value = 45;

      tool.onDragStart(Offset.zero, page, 0, null);

      // Drag at ~42 degrees
      const rad42 = 42 * pi / 180;
      tool.onDragUpdate(Offset(100 * cos(rad42), 100 * sin(rad42)), null);

      final finished = tool.onDragEnd() as ArrowStroke;
      final angle = atan2(finished.end.dy, finished.end.dx) * 180 / pi;
      expect(angle, closeTo(45.0, 0.01));
    });
  });

  group('3. DimensionTool Interactive Construction & Live Readouts', () {
    test('DimensionTool instantiation has expected defaults', () {
      final tool = DimensionTool();
      expect(tool.name, equals('Dimension'));
      expect(tool.toolId, equals(ToolId.dimension));
      expect(tool.defaultOffset, equals(30.0));
      expect(tool.pressureEnabled, isFalse);
    });

    test('DimensionTool drag interaction updates live Euclidean distance label', () {
      final tool = DimensionTool();
      final page = EditorPage();

      tool.onDragStart(const Offset(100, 100), page, 0, null);
      expect(Pen.currentStroke, isA<DimensionStroke>());
      final activeDim = Pen.currentStroke as DimensionStroke;
      expect(activeDim.text, equals('0.0 px'));

      // Drag horizontally 150 px: distance = 150.0
      tool.onDragUpdate(const Offset(250, 100), null);
      expect(activeDim.end, equals(const Offset(250, 100)));
      expect(activeDim.text, equals('150.0 px'));

      // Drag 3-4-5 triangle: dx = 30, dy = 40 => distance = 50.0
      tool.onDragUpdate(const Offset(130, 140), null);
      expect(activeDim.text, equals('50.0 px'));

      final finished = tool.onDragEnd() as DimensionStroke;
      expect(finished.start, equals(const Offset(100, 100)));
      expect(finished.end, equals(const Offset(130, 140)));
      expect(finished.text, equals('50.0 px'));
      expect(finished.options.isComplete, isTrue);
    });

    test('DimensionTool zero-length drag is discarded', () {
      final tool = DimensionTool();
      final page = EditorPage();

      tool.onDragStart(const Offset(50, 50), page, 0, null);
      tool.onDragUpdate(const Offset(50, 50), null);
      final finished = tool.onDragEnd();
      expect(finished, isNull);
    });

    test('DimensionTool respects grid snapping and angle snapping', () {
      final tool = DimensionTool();
      final page = EditorPage();
      stows.snapToGrid.value = true;
      stows.gridSize.value = 20.0;
      stows.snapToAngle.value = true;
      stows.snapAngleStep.value = 30;

      tool.onDragStart(const Offset(19, 21), page, 0, null);
      final active = Pen.currentStroke as DimensionStroke;
      expect(active.start, equals(const Offset(20, 20)));

      // Drag near 30 degrees
      const rad29 = 29 * pi / 180;
      tool.onDragUpdate(Offset(20 + 100 * cos(rad29), 20 + 100 * sin(rad29)), null);

      final finished = tool.onDragEnd() as DimensionStroke;
      final angle = atan2(finished.end.dy - finished.start.dy, finished.end.dx - finished.start.dx) * 180 / pi;
      expect(angle, closeTo(30.0, 0.05));
    });
  });

  group('4. DimensionStroke JSON Collision Fix (Defect 1)', () {
    test('DimensionStroke writes txt and t keys in toJson without colliding with StrokeOptions', () {
      final dim = DimensionStroke(
        color: Colors.green,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.dimension,
        start: const Offset(10, 10),
        end: const Offset(110, 10),
        text: '100.0 px',
      );

      final json = dim.toJson();
      expect(json['shape'], equals('dimension'));
      expect(json['txt'], equals('100.0 px'));
      expect(json['t'], equals('100.0 px'));

      // StrokeOptions.fromJson must NOT crash with type mismatch
      final restored = DimensionStroke.fromJson(json, fileVersion: 1, pageIndex: 0, page: pageDef);
      expect(restored.text, equals('100.0 px'));
      expect(restored.start, equals(dim.start));
      expect(restored.end, equals(dim.end));
    });

    test('DimensionStroke fromJson falls back gracefully to legacy t key', () {
      final legacyJson = {
        'shape': 'dimension',
        'i': 0,
        'ty': 'DimensionTool',
        'pe': false,
        'c': Colors.blue.toARGB32(),
        'sx': 20.0,
        'sy': 30.0,
        'ex': 120.0,
        'ey': 30.0,
        'o': 25.0,
        't': 'Legacy Label',
        'hl': 10.0,
        'ha': 0.4,
      };

      // Ensure parsing legacy JSON without 'txt' does not throw type error
      final restored = DimensionStroke.fromJson(legacyJson, fileVersion: 1, pageIndex: 0, page: pageDef);
      expect(restored.text, equals('Legacy Label'));
      expect(restored.offset, equals(25.0));
      expect(restored.toolId, equals(ToolId.dimension));
    });

    test('DimensionStroke with empty text omits txt and t keys', () {
      final dim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.dimension,
        start: Offset.zero,
        end: const Offset(100, 0),
        text: '',
      );

      final json = dim.toJson();
      expect(json.containsKey('txt'), isFalse);
      expect(json.containsKey('t'), isFalse);

      final restored = DimensionStroke.fromJson(json, fileVersion: 1, pageIndex: 0, page: pageDef);
      expect(restored.text, isEmpty);
    });

    test('Integer coordinates from BSON are deserialized safely into double Offsets', () {
      final bsonLikeJson = {
        'shape': 'dimension',
        'i': 0,
        'ty': 'DimensionTool',
        'pe': false,
        'c': 0xFF000000,
        'sx': 10, // integer
        'sy': 20, // integer
        'ex': 110, // integer
        'ey': 120, // integer
        'o': 30, // integer
        'txt': 'Int Coord Text',
      };

      final restored = DimensionStroke.fromJson(bsonLikeJson, fileVersion: 1, pageIndex: 0, page: pageDef);
      expect(restored.start, equals(const Offset(10.0, 20.0)));
      expect(restored.end, equals(const Offset(110.0, 120.0)));
      expect(restored.offset, equals(30.0));
    });
  });

  group('5. Drafting Primitives Geometry & Polygons', () {
    test('DimensionStroke computeVectors returns correct unit and perpendicular vectors', () {
      final dim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.dimension,
        start: Offset.zero,
        end: const Offset(100, 0),
        offset: 30.0,
      );

      final (unitDir, perp) = dim.computeVectors();
      expect(unitDir, equals(const Offset(1.0, 0.0)));
      expect(perp, equals(const Offset(0.0, 1.0)));
    });

    test('DimensionStroke getPolygon encloses measured points, dimension line, and text position', () {
      final dim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.dimension,
        start: const Offset(10, 20),
        end: const Offset(110, 20),
        offset: 30.0,
      );

      final poly = dim.getPolygon(quality: StrokeQuality.high);
      expect(poly, contains(dim.start));
      expect(poly, contains(dim.end));
      expect(poly, contains(dim.textPosition));
      expect(poly.length, greaterThanOrEqualTo(5));
    });

    test('ArrowStroke toSvgPath and getPath produce non-empty paths for valid arrows', () {
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 3.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.arrow,
        start: Offset.zero,
        end: const Offset(100, 50),
        arrowheadStyle: ArrowheadStyle.double,
      );

      final path = arrow.getPath(arrow.getPolygon(quality: StrokeQuality.high));
      expect(path, isNotNull);

      final svg = arrow.toSvgPath();
      expect(svg, isNotEmpty);
      expect(svg, contains('M'));
      expect(svg, contains('L'));
    });
  });

  group('6. Select Tool Hit-Testing & Vertex Handles', () {
    test('Select hit-tests ArrowStroke along its shaft', () {
      final select = Select.currentSelect;
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.arrow,
        start: const Offset(50, 50),
        end: const Offset(250, 50),
      );

      // Tap in the middle of shaft at (150, 53) — within 15px tapRadius
      select.tapSelect(const Offset(150, 53), [arrow], [], 0);
      expect(select.selectResult.strokes, hasLength(1));
      expect(select.selectResult.strokes.first, equals(arrow));

      // Tap far away at (150, 100) — misses
      select.tapSelect(const Offset(150, 100), [arrow], [], 0);
      expect(select.selectResult.strokes, isEmpty);
    });

    test('Select hit-tests DimensionStroke along offset line, extension lines, and text', () {
      final select = Select.currentSelect;
      final dim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.dimension,
        start: const Offset(50, 50),
        end: const Offset(250, 50),
        offset: 40.0,
        text: '200 mm',
      );

      // Tap near dimension line at (150, 92) (offset line is at y = 90)
      select.tapSelect(const Offset(150, 92), [dim], [], 0);
      expect(select.selectResult.strokes, hasLength(1));
      expect(select.selectResult.strokes.first, equals(dim));

      // Tap near extension line at (50, 70)
      select.tapSelect(const Offset(51, 70), [dim], [], 0);
      expect(select.selectResult.strokes, hasLength(1));

      // Tap far away misses
      select.tapSelect(const Offset(500, 500), [dim], [], 0);
      expect(select.selectResult.strokes, isEmpty);
    });

    test('SelectResult.vertexHandles returns correct vertices for ArrowStroke', () {
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.arrow,
        start: const Offset(20, 30),
        end: const Offset(120, 80),
      );

      final result = SelectResult(
        pageIndex: 0,
        strokes: [arrow],
        images: [],
        path: Path(),
      );

      final handles = result.vertexHandles;
      expect(handles, hasLength(2));
      expect(handles[0], equals(const Offset(20, 30)));
      expect(handles[1], equals(const Offset(120, 80)));
    });

    test('SelectResult.vertexHandles returns start, end, and textPosition for DimensionStroke', () {
      final dim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.dimension,
        start: Offset.zero,
        end: const Offset(100, 0),
        offset: 20.0,
      );

      final result = SelectResult(
        pageIndex: 0,
        strokes: [dim],
        images: [],
        path: Path(),
      );

      final handles = result.vertexHandles;
      expect(handles, hasLength(3));
      expect(handles[0], equals(dim.start));
      expect(handles[1], equals(dim.end));
      expect(handles[2], equals(dim.textPosition));
      expect(handles[2].dy, closeTo(20.0, 1e-4));
    });
  });

  group('7. Endpoint Vertex Drag Manipulation & History Integration', () {
    test('Dragging DimensionStroke offset handle recalculates perpendicular offset', () {
      final dim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.dimension,
        start: const Offset(0, 50),
        end: const Offset(100, 50),
        offset: 20.0,
      );

      // Horizontal line from (0, 50) to (100, 50): dir = (100, 0), perp = (0, 1)
      // New drag position at (50, 110) => new offset should be 110 - 50 = 60
      const dragPos = Offset(50, 110);
      final dir = dim.end - dim.start;
      final length = dir.distance;
      final perp = Offset(-dir.dy / length, dir.dx / length);
      final calculatedOffset = (dragPos.dx - dim.start.dx) * perp.dx +
          (dragPos.dy - dim.start.dy) * perp.dy;

      dim.offset = calculatedOffset;
      expect(dim.offset, closeTo(60.0, 1e-4));
      expect(dim.textPosition.dy, closeTo(110.0, 1e-4));
    });

    test('Drafting strokes cleanly integrate with EditorHistory undo/redo', () {
      final history = EditorHistory();
      final page = EditorPage();

      final arrow = ArrowStroke(
        color: Colors.red,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.arrow,
        start: const Offset(10, 10),
        end: const Offset(100, 10),
      );

      final dim = DimensionStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.dimension,
        start: const Offset(10, 50),
        end: const Offset(100, 50),
        text: '90 px',
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

      expect(page.strokes, hasLength(2));

      // Undo dimension
      history.canRedo = true;
      final undoneDim = history.undo();
      for (final s in undoneDim.strokes) {
        page.removeStroke(s);
      }
      expect(page.strokes, hasLength(1));
      expect(page.strokes.first, equals(arrow));

      // Undo arrow
      final undoneArrow = history.undo();
      for (final s in undoneArrow.strokes) {
        page.removeStroke(s);
      }
      expect(page.strokes, isEmpty);

      // Redo arrow
      final redoneArrow = history.redo();
      for (final s in redoneArrow.strokes) {
        page.insertStroke(s);
      }
      expect(page.strokes, hasLength(1));
      expect(page.strokes.first, equals(arrow));

      // Redo dimension
      final redoneDim = history.redo();
      for (final s in redoneDim.strokes) {
        page.insertStroke(s);
      }
      expect(page.strokes, hasLength(2));
      expect(page.strokes.contains(dim), isTrue);
    });
  });

  group('8. BSON (.sbn2) Persistence Roundtrip for Drafting Strokes', () {
    test('BSON serializes and restores ArrowStroke and DimensionStroke', () {
      final arrow = ArrowStroke(
        color: const Color(0xFF112233),
        pressureEnabled: false,
        options: StrokeOptions(size: 3.5),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.arrow,
        start: const Offset(45.5, 60.0),
        end: const Offset(200.0, 150.0),
        arrowheadStyle: ArrowheadStyle.double,
        headLength: 15.0,
        headAngle: 0.55,
      );

      final dim = DimensionStroke(
        color: const Color(0xFF445566),
        pressureEnabled: false,
        options: StrokeOptions(size: 2.5),
        pageIndex: 0,
        page: pageDef,
        toolId: ToolId.dimension,
        start: const Offset(50.0, 75.0),
        end: const Offset(350.0, 75.0),
        offset: 35.0,
        text: '300.0 mm',
        headLength: 12.0,
        headAngle: 0.45,
      );

      // Serialize strokes to BSON binary
      final arrowBson = BsonCodec.serialize(arrow.toJson());
      final dimBson = BsonCodec.serialize(dim.toJson());

      // Deserialize BSON binary
      final restoredArrowJson = BsonCodec.deserialize(arrowBson);
      final restoredDimJson = BsonCodec.deserialize(dimBson);

      final restoredArrow = Stroke.fromJson(
        restoredArrowJson,
        fileVersion: 13,
        pageIndex: 0,
        page: pageDef,
      ) as ArrowStroke;

      final restoredDim = Stroke.fromJson(
        restoredDimJson,
        fileVersion: 13,
        pageIndex: 0,
        page: pageDef,
      ) as DimensionStroke;

      expect(restoredArrow.start, equals(arrow.start));
      expect(restoredArrow.end, equals(arrow.end));
      expect(restoredArrow.arrowheadStyle, equals(arrow.arrowheadStyle));
      expect(restoredArrow.color.toARGB32(), equals(arrow.color.toARGB32()));

      expect(restoredDim.start, equals(dim.start));
      expect(restoredDim.end, equals(dim.end));
      expect(restoredDim.offset, equals(dim.offset));
      expect(restoredDim.text, equals('300.0 mm'));
      expect(restoredDim.color.toARGB32(), equals(dim.color.toARGB32()));
    });
  });
}
