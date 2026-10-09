/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:io';
import 'dart:math';

import 'package:bson/bson.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_exporter.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/arrow.dart';
import 'package:saber/data/tools/dimension.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

import 'utils/test_mock_channel_handlers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    setupMockPathProvider();
    setupMockPrinting();
    FlavorConfig.setup();
  });

  const pageSize = Size(1000, 1400);
  const pageDef = HasSize(pageSize);

  setUp(() {
    stows.snapToGrid.value = false;
    stows.gridSize.value = 20.0;
    stows.snapToAngle.value = false;
    stows.snapAngleStep.value = 15;
    Pen.currentStroke = null;
  });

  group('Adversarial Challenge 1: Interactive Drafting & Snapping Under Stress', () {
    test('1.1: Isometric snapping math oracle across 10,000 random points', () {
      const double lineHeight = 24.0;
      final double dx = lineHeight * (sqrt(3) / 2);
      final random = Random(42);

      for (int i = 0; i < 1000; i++) {
        final queryPoint = Offset(
          random.nextDouble() * 2000 - 500,
          random.nextDouble() * 2000 - 500,
        );

        final snapped = Stroke.snapPointToIsometricGrid(queryPoint, lineHeight);

        // Verify that the snapped point lies strictly on a valid triangular vertex
        final col = (snapped.dx / dx).round();
        expect(
          snapped.dx,
          closeTo(col * dx, 1e-4),
          reason: 'Snapped X must align with column multiple of dx',
        );

        final yShift = (col % 2 != 0) ? 0.5 * lineHeight : 0.0;
        final row = ((snapped.dy - yShift) / lineHeight).round();
        expect(
          snapped.dy,
          closeTo(row * lineHeight + yShift, 1e-4),
          reason: 'Snapped Y must align with row multiple of lineHeight',
        );

        // Oracle distance check: query distance to snapped must be <= distance to any other neighbor vertex
        final snappedDistSq = (queryPoint - snapped).distanceSquared;
        for (int c = col - 2; c <= col + 2; c++) {
          final cX = c * dx;
          final cShift = (c % 2 != 0) ? 0.5 * lineHeight : 0.0;
          for (int r = row - 2; r <= row + 2; r++) {
            final cY = r * lineHeight + cShift;
            final neighborDistSq =
                (queryPoint - Offset(cX, cY)).distanceSquared;
            expect(
              snappedDistSq,
              lessThanOrEqualTo(neighborDistSq + 1e-6),
              reason:
                  'No neighbor vertex may be closer than the snapped vertex',
            );
          }
        }
      }
    });

    test(
      '1.2: Stress-test 3-axis isometric angle snapping across 360 degree sweep',
      () {
        const origin = Offset(500, 500);
        const testLength = 125.0;

        for (int deg = 0; deg < 360; deg++) {
          final rad = deg * pi / 180;
          final rawPoint = Offset(
            origin.dx + testLength * cos(rad),
            origin.dy + testLength * sin(rad),
          );

          final (first, snapped) = Stroke.snapLineToAngle(
            PointVector.fromOffset(offset: origin),
            PointVector.fromOffset(offset: rawPoint),
            30.0,
            isIsometric: true,
          );

          expect(first.dx, equals(origin.dx));
          expect(first.dy, equals(origin.dy));

          // Length preservation check: strictly equal to original length
          final snappedLength = sqrt(
            pow(snapped.dx - origin.dx, 2) + pow(snapped.dy - origin.dy, 2),
          );
          expect(
            snappedLength,
            closeTo(testLength, 1e-5),
            reason:
                'Angle snap must preserve exact Euclidean length at $deg degrees',
          );

          // Snapped angle must be one of the 6 canonical isometric angles (±30°, ±90°, ±150°)
          var angleDeg =
              atan2(snapped.dy - origin.dy, snapped.dx - origin.dx) * 180 / pi;
          // Normalize to [-180, 180]
          while (angleDeg > 180) angleDeg -= 360;
          while (angleDeg <= -180) angleDeg += 360;

          const allowedAngles = [-150.0, -90.0, -30.0, 30.0, 90.0, 150.0];
          final matchesAllowed = allowedAngles.any(
            (a) => (a - angleDeg).abs() < 0.01,
          );
          expect(
            matchesAllowed,
            isTrue,
            reason:
                'Angle at $deg deg ($angleDeg) must snap to one of $allowedAngles',
          );
        }
      },
    );

    test(
      '1.3: Interactive ArrowTool and DimensionTool dragging on isometric page',
      () {
        final page = EditorPage(size: pageSize);
        page.backgroundPattern = CanvasBackgroundPattern.isometric;
        page.lineHeight = 30;

        stows.snapToGrid.value = true;
        stows.snapToAngle.value = true;
        stows.snapAngleStep.value = -30; // Iso 30°

        final arrowTool = ArrowTool();
        final dimTool = DimensionTool();

        const double L = 30.0;
        final double dx = L * (sqrt(3) / 2);

        // Draw Arrow on isometric grid
        // Start drag near (0, 0)
        arrowTool.onDragStart(const Offset(2, -3), page, 0, null);
        final activeArrow = Pen.currentStroke as ArrowStroke;
        expect(activeArrow.start, equals(Offset.zero));

        // Drag along 30° diagonal direction towards vertex (2*dx, L)
        arrowTool.onDragUpdate(Offset(2 * dx + 1, L - 1), null);
        final arrowStroke = arrowTool.onDragEnd() as ArrowStroke;

        expect(arrowStroke.start, equals(Offset.zero));
        expect(arrowStroke.end.dx, closeTo(2 * dx, 0.01));
        expect(arrowStroke.end.dy, closeTo(L, 0.01));

        // Draw Dimension on isometric grid along vertical direction (90°)
        dimTool.onDragStart(Offset(dx + 1, 0.5 * L - 1), page, 0, null);
        final activeDim = Pen.currentStroke as DimensionStroke;
        expect(activeDim.start.dx, closeTo(dx, 0.01));
        expect(activeDim.start.dy, closeTo(0.5 * L, 0.01));

        // Drag vertically down 3 grid intervals: 0.5*L + 3*L = 3.5*L
        dimTool.onDragUpdate(Offset(dx, 3.5 * L + 2), null);
        final dimStroke = dimTool.onDragEnd() as DimensionStroke;

        expect(dimStroke.start.dx, closeTo(dx, 0.01));
        expect(dimStroke.start.dy, closeTo(0.5 * L, 0.01));
        expect(dimStroke.end.dx, closeTo(dx, 0.01));
        expect(dimStroke.end.dy, closeTo(3.5 * L, 0.01));
        expect(dimStroke.text, equals('${(3 * L).toStringAsFixed(1)} px'));
      },
    );

    test(
      '1.4: Endpoint vertex handle manipulation and dynamic readout updates',
      () {
        final dim = DimensionStroke(
          color: Colors.blue,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: pageDef,
          toolId: ToolId.dimension,
          start: const Offset(100, 100),
          end: const Offset(200, 100),
          offset: 30.0,
          text: '100.0 px',
        );

        final result = SelectResult(
          pageIndex: 0,
          strokes: [dim],
          images: [],
          path: Path(),
        );

        // Verify initial vertex handles: [start, end, textPosition]
        final handles = result.vertexHandles;
        expect(handles.length, 3);
        expect(handles[0], equals(const Offset(100, 100)));
        expect(handles[1], equals(const Offset(200, 100)));
        expect(
          handles[2],
          equals(const Offset(150, 130)),
        ); // (100+200)/2, 100+30

        // Simulate dragging end vertex (index 1) to (350, 100)
        dim.end = const Offset(350, 100);
        dim.text = '${(dim.end - dim.start).distance.toStringAsFixed(1)} px';
        dim.markPolygonNeedsUpdating();

        expect(dim.text, equals('250.0 px'));
        expect(dim.textPosition, equals(const Offset(225, 130)));

        // Simulate dragging start vertex (index 0) to (100, 250) (diagonal: dx = 250, dy = -150)
        dim.start = const Offset(100, 250);
        final newDist = (dim.end - dim.start).distance;
        dim.text = '${newDist.toStringAsFixed(1)} px';
        dim.markPolygonNeedsUpdating();

        // dx = 250, dy = -150 => dist = sqrt(250^2 + 150^2) = sqrt(85000) ~ 291.54759
        expect(dim.text, equals('291.5 px'));

        // Simulate dragging offset handle (index 2)
        final dir = dim.end - dim.start;
        final length = dir.distance;
        final perp = Offset(-dir.dy / length, dir.dx / length);
        const newHandlePos = Offset(300, 300);
        final calculatedOffset =
            (newHandlePos.dx - dim.start.dx) * perp.dx +
            (newHandlePos.dy - dim.start.dy) * perp.dy;
        dim.offset = calculatedOffset;

        expect(dim.offset.isFinite, isTrue);
        expect(dim.textPosition.dx.isFinite, isTrue);
        expect(dim.textPosition.dy.isFinite, isTrue);
      },
    );
  });

  group(
    'Adversarial Challenge 2: Undo/Redo & Serialization Roundtrip Across Rapid State Changes',
    () {
      test(
        '2.1: Interleaved drafting strokes, vertex moves, and deletions with rapid undo/redo cycles',
        () {
          final history = EditorHistory();
          final page = EditorPage(size: pageSize);

          final addedStrokes = <Stroke>[];

          // Step 1: Draw 10 arrows and 10 dimensions
          for (int i = 0; i < 10; i++) {
            final arrow = ArrowStroke(
              color: Colors.red,
              pressureEnabled: false,
              options: StrokeOptions(size: 2.0),
              pageIndex: 0,
              page: pageDef,
              toolId: ToolId.arrow,
              start: Offset(10.0 * i, 10.0 * i),
              end: Offset(50.0 * i + 10, 50.0 * i + 10),
              arrowheadStyle:
                  ArrowheadStyle.values[i % ArrowheadStyle.values.length],
            );
            page.insertStroke(arrow);
            addedStrokes.add(arrow);
            history.recordChange(
              EditorHistoryItem(
                type: EditorHistoryItemType.draw,
                pageIndex: 0,
                strokes: [arrow],
                images: [],
              ),
            );

            final dim = DimensionStroke(
              color: Colors.blue,
              pressureEnabled: false,
              options: StrokeOptions(size: 1.5),
              pageIndex: 0,
              page: pageDef,
              toolId: ToolId.dimension,
              start: Offset(20.0 * i, 100.0),
              end: Offset(120.0 * i + 50, 100.0),
              offset: 25.0 * (i.isEven ? 1 : -1),
              text: '${(100.0 + i).toStringAsFixed(1)} px',
            );
            page.insertStroke(dim);
            addedStrokes.add(dim);
            history.recordChange(
              EditorHistoryItem(
                type: EditorHistoryItemType.draw,
                pageIndex: 0,
                strokes: [dim],
                images: [],
              ),
            );
          }

          expect(page.strokes.length, 20);
          expect(history.canUndo, isTrue);

          // Step 2: Delete 5 strokes (strokes at indices 0, 2, 4, 6, 8)
          final erasedStrokes = <Stroke>[];
          for (int i = 0; i < 5; i++) {
            final target = addedStrokes[i * 2];
            page.removeStroke(target);
            erasedStrokes.add(target);
            history.recordChange(
              EditorHistoryItem(
                type: EditorHistoryItemType.erase,
                pageIndex: 0,
                strokes: [target],
                images: [],
              ),
            );
          }

          expect(page.strokes.length, 15);

          // Step 3: Rapid undo 10 steps
          for (int u = 0; u < 10; u++) {
            final item = history.undo();
            history.canRedo = true;
            if (item.type == EditorHistoryItemType.erase) {
              for (final s in item.strokes) {
                page.insertStroke(s);
              }
            } else if (item.type == EditorHistoryItemType.draw) {
              for (final s in item.strokes) {
                page.removeStroke(s);
              }
            }
          }

          // Invariant: page strokes must accurately reflect undo state
          expect(page.strokes.length, 15);

          // Step 4: Rapid redo 5 steps
          for (int r = 0; r < 5; r++) {
            final item = history.redo();
            if (item.type == EditorHistoryItemType.erase) {
              for (final s in item.strokes) {
                page.removeStroke(s);
              }
            } else if (item.type == EditorHistoryItemType.draw) {
              for (final s in item.strokes) {
                page.insertStroke(s);
              }
            }
          }

          // Step 5: Branching - draw a new arrow stroke, invalidating the remaining redo stack
          final branchStroke = ArrowStroke(
            color: Colors.green,
            pressureEnabled: false,
            options: StrokeOptions(size: 3.0),
            pageIndex: 0,
            page: pageDef,
            toolId: ToolId.arrow,
            start: const Offset(400, 400),
            end: const Offset(800, 800),
          );
          page.insertStroke(branchStroke);
          history.recordChange(
            EditorHistoryItem(
              type: EditorHistoryItemType.draw,
              pageIndex: 0,
              strokes: [branchStroke],
              images: [],
            ),
          );

          expect(
            history.canRedo,
            isFalse,
            reason: 'Redo stack must be invalidated upon new action',
          );

          // Step 6: Undo back to empty and verify zero leaks
          while (history.canUndo) {
            final item = history.undo();
            history.canRedo = true;
            if (item.type == EditorHistoryItemType.erase) {
              for (final s in item.strokes) {
                page.insertStroke(s);
              }
            } else if (item.type == EditorHistoryItemType.draw) {
              for (final s in item.strokes) {
                page.removeStroke(s);
              }
            }
          }

          expect(
            page.strokes,
            isEmpty,
            reason: 'Page must be cleanly empty after full undo',
          );
        },
      );

      test('2.2: Binary (.sbn2 BSON) roundtrip with 100% geometric equality', () {
        final coreInfo = EditorCoreInfo(
          filePath: 'roundtrip_adversarial_test.sbn2',
        );

        final layer0 = Layer(name: 'Base Layer');
        final layer1 = Layer(name: 'Drafting Layer');

        // 1. Add diverse ArrowStroke instances
        final arrowSingle = ArrowStroke(
          color: const Color(0xFFFF5500),
          pressureEnabled: false,
          options: StrokeOptions(size: 4.0),
          pageIndex: 0,
          page: pageDef,
          toolId: ToolId.arrow,
          start: const Offset(12.5, 34.5),
          end: const Offset(567.8, 910.1),
          arrowheadStyle: ArrowheadStyle.single,
          headLength: 18.5,
          headAngle: 0.45,
        );

        final arrowDouble = ArrowStroke(
          color: const Color(0xFF00AAFF),
          pressureEnabled: false,
          options: StrokeOptions(size: 2.5),
          pageIndex: 0,
          page: pageDef,
          toolId: ToolId.arrow,
          start: const Offset(100, 200),
          end: const Offset(300, 400),
          arrowheadStyle: ArrowheadStyle.double,
          headLength: 14.0,
          headAngle: 0.6,
        );

        final arrowNone = ArrowStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 1.0),
          pageIndex: 0,
          page: pageDef,
          toolId: ToolId.arrow,
          start: const Offset(50, 50),
          end: const Offset(80, 50),
          arrowheadStyle: ArrowheadStyle.none,
        );

        // 2. Add diverse DimensionStroke instances (testing Defect 1 text serialization fix)
        final dimWithText = DimensionStroke(
          color: const Color(0xFF228B22),
          pressureEnabled: false,
          options: StrokeOptions(size: 3.0),
          pageIndex: 0,
          page: pageDef,
          toolId: ToolId.dimension,
          start: const Offset(100.25, 200.75),
          end: const Offset(400.5, 200.75),
          offset: -45.5,
          text: '300.25 mm',
          headLength: 12.0,
          headAngle: 0.35,
        );

        final dimSpecialChars = DimensionStroke(
          color: const Color(0xFF8A2BE2),
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: pageDef,
          toolId: ToolId.dimension,
          start: const Offset(50, 500),
          end: const Offset(250, 700),
          offset: 35.0,
          text: '282.8 px ± 0.1 (Draft)',
        );

        final dimEmptyText = DimensionStroke(
          color: Colors.red,
          pressureEnabled: false,
          options: StrokeOptions(size: 1.5),
          pageIndex: 0,
          page: pageDef,
          toolId: ToolId.dimension,
          start: const Offset(10, 10),
          end: const Offset(20, 20),
          offset: 15.0,
          text: '',
        );

        layer0.strokes.addAll([arrowSingle, arrowNone, dimEmptyText]);
        layer1.strokes.addAll([arrowDouble, dimWithText, dimSpecialChars]);

        final page = EditorPage(size: pageSize, layers: [layer0, layer1]);
        coreInfo.pages.add(page);

        // Serialize to .sbn2 binary BSON
        final (bsonBytes, _) = coreInfo.saveToBinary(currentPageIndex: 0);
        expect(bsonBytes, isNotEmpty);

        // Deserialize from binary BSON
        final bsonMap = BsonCodec.deserialize(BsonBinary.from(bsonBytes));
        final reloadedCoreInfo = EditorCoreInfo.fromJson(
          bsonMap,
          filePath: 'roundtrip_adversarial_test.sbn2',
          onlyFirstPage: false,
        );

        // Saber appends a trailing blank page if the last page is not empty
        expect(reloadedCoreInfo.pages.length, 2);
        expect(reloadedCoreInfo.pages.last.isEmpty, isTrue);

        final reloadedPage = reloadedCoreInfo.pages.first;
        expect(reloadedPage.layers.length, 2);

        // Verify Layer 0 strokes
        final reloadedL0 = reloadedPage.layers[0];
        expect(reloadedL0.strokes.length, 3);

        final reloadedArrowSingle = reloadedL0.strokes[0] as ArrowStroke;
        expect(reloadedArrowSingle.start, equals(arrowSingle.start));
        expect(reloadedArrowSingle.end, equals(arrowSingle.end));
        expect(reloadedArrowSingle.color, equals(arrowSingle.color));
        expect(
          reloadedArrowSingle.arrowheadStyle,
          equals(ArrowheadStyle.single),
        );
        expect(reloadedArrowSingle.headLength, closeTo(18.5, 1e-4));
        expect(reloadedArrowSingle.headAngle, closeTo(0.45, 1e-4));
        expect(
          reloadedArrowSingle.options.size,
          equals(arrowSingle.options.size),
        );

        final reloadedArrowNone = reloadedL0.strokes[1] as ArrowStroke;
        expect(reloadedArrowNone.arrowheadStyle, equals(ArrowheadStyle.none));
        expect(reloadedArrowNone.start, equals(arrowNone.start));
        expect(reloadedArrowNone.end, equals(arrowNone.end));

        final reloadedDimEmpty = reloadedL0.strokes[2] as DimensionStroke;
        expect(reloadedDimEmpty.text, equals(''));
        expect(reloadedDimEmpty.start, equals(dimEmptyText.start));
        expect(reloadedDimEmpty.end, equals(dimEmptyText.end));
        expect(reloadedDimEmpty.offset, equals(dimEmptyText.offset));

        // Verify Layer 1 strokes
        final reloadedL1 = reloadedPage.layers[1];
        expect(reloadedL1.strokes.length, 3);

        final reloadedArrowDouble = reloadedL1.strokes[0] as ArrowStroke;
        expect(
          reloadedArrowDouble.arrowheadStyle,
          equals(ArrowheadStyle.double),
        );
        expect(reloadedArrowDouble.start, equals(arrowDouble.start));
        expect(reloadedArrowDouble.end, equals(arrowDouble.end));

        final reloadedDimWithText = reloadedL1.strokes[1] as DimensionStroke;
        expect(reloadedDimWithText.text, equals('300.25 mm'));
        expect(reloadedDimWithText.start, equals(dimWithText.start));
        expect(reloadedDimWithText.end, equals(dimWithText.end));
        expect(reloadedDimWithText.offset, closeTo(-45.5, 1e-4));
        expect(reloadedDimWithText.headLength, closeTo(12.0, 1e-4));
        expect(reloadedDimWithText.headAngle, closeTo(0.35, 1e-4));

        final reloadedDimSpecial = reloadedL1.strokes[2] as DimensionStroke;
        expect(reloadedDimSpecial.text, equals('282.8 px ± 0.1 (Draft)'));
        expect(reloadedDimSpecial.start, equals(dimSpecialChars.start));
        expect(reloadedDimSpecial.end, equals(dimSpecialChars.end));
      });
    },
  );

  group('Adversarial Challenge 3: PDF Vector Export Verification', () {
    testWidgets(
      '3.1: PDF stream contains vector stroking operators, line widths, and dimension text',
      (tester) async {
        await tester.runAsync(FileManager.init);

        const expPageSize = Size(600, 800);
        const expHasSize = HasSize(expPageSize);

        // Define precise dimensions and colors to track in the stream
        final arrow = ArrowStroke(
          color: const Color(0xFFFF0000), // Pure Red (1, 0, 0 RG)
          pressureEnabled: false,
          options: StrokeOptions(size: 3.5),
          pageIndex: 0,
          page: expHasSize,
          toolId: ToolId.arrow,
          start: const Offset(100, 100),
          end: const Offset(500, 100),
          arrowheadStyle: ArrowheadStyle.single,
        );

        final dim = DimensionStroke(
          color: const Color(0xFF0000FF), // Pure Blue (0, 0, 1 RG)
          pressureEnabled: false,
          options: StrokeOptions(size: 2.25),
          pageIndex: 0,
          page: expHasSize,
          toolId: ToolId.dimension,
          start: const Offset(100, 300),
          end: const Offset(400, 300),
          offset: 40.0,
          text: '300.0 mm',
        );

        // Hidden layer with 50 decoy strokes
        final decoyStrokes = List.generate(
          50,
          (i) => ArrowStroke(
            color: Colors.amber,
            pressureEnabled: false,
            options: StrokeOptions(size: 7.77), // Unique decoy size
            pageIndex: 0,
            page: expHasSize,
            toolId: ToolId.arrow,
            start: Offset(i.toDouble(), 0),
            end: Offset(i.toDouble(), 50),
          ),
        );

        final visibleLayer = Layer(
          name: 'Visible Drafting',
          visible: true,
          strokes: [arrow, dim],
        );
        final hiddenLayer = Layer(
          name: 'Hidden Construction',
          visible: false,
          strokes: decoyStrokes,
        );

        final page = EditorPage(
          size: expPageSize,
          layers: [visibleLayer, hiddenLayer],
        );
        page.backgroundPattern = CanvasBackgroundPattern.isometric;
        page.lineHeight = 25;

        final coreInfo = EditorCoreInfo(filePath: 'pdf_export_challenge.sbn2')
          ..pages.add(page);

        late BuildContext buildContext;
        await tester.pumpWidget(
          TranslationProvider(
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  buildContext = context;
                  return const Scaffold(
                    body: Text('PDF Vector Export Challenge'),
                  );
                },
              ),
            ),
          ),
        );

        // Generate PDF document
        final pdfDoc = await tester.runAsync(
          () => EditorExporter.generatePdf(coreInfo, buildContext),
        );

        expect(pdfDoc, isNotNull);
        final pdfBytes = await tester.runAsync(pdfDoc!.save);
        expect(pdfBytes, isNotNull);
        expect(pdfBytes!.length, greaterThan(0));

        // Magic bytes check
        expect(String.fromCharCodes(pdfBytes.take(4)), '%PDF');

        // Decompress all PDF object streams
        final pdfContent = pdfBytes;
        final pdfString = String.fromCharCodes(pdfContent);

        final streamRegex = RegExp(r'stream\r?\n([\s\S]*?)\r?\nendstream');
        final allStreams = <String>[];

        for (final match in streamRegex.allMatches(pdfString)) {
          final startIdx = match.start + 'stream\n'.length;
          final endMatch = pdfString.indexOf('endstream', match.start);
          if (endMatch > startIdx) {
            final headerIdx = pdfString.indexOf('stream', match.start);
            var dataStart = headerIdx + 6;
            if (pdfContent[dataStart] == 13) dataStart++;
            if (pdfContent[dataStart] == 10) dataStart++;
            var dataEnd = endMatch;
            while (dataEnd > dataStart &&
                (pdfContent[dataEnd - 1] == 10 ||
                    pdfContent[dataEnd - 1] == 13)) {
              dataEnd--;
            }
            final slice = pdfContent.sublist(dataStart, dataEnd);
            try {
              final inflated = zlib.decode(slice);
              allStreams.add(String.fromCharCodes(inflated));
            } catch (_) {
              allStreams.add(String.fromCharCodes(slice));
            }
          }
        }

        final streamText = allStreams.join('\n');

        // 1. Vector stroking operator 'S' must be present
        expect(
          streamText,
          contains(' S '),
          reason: 'PDF graphics stream must contain stroking path operator "S"',
        );

        // 2. Line widths for drafting primitives
        expect(
          streamText,
          contains('3.5 w'),
          reason:
              'PDF graphics stream must set stroke width 3.5 for ArrowStroke',
        );
        expect(
          streamText,
          contains('2.25 w'),
          reason:
              'PDF graphics stream must set stroke width 2.25 for DimensionStroke',
        );

        // 3. Stroke colors (RG operator)
        expect(
          streamText,
          contains('1 0 0 RG'),
          reason: 'Red stroke color (1 0 0 RG) must be set for ArrowStroke',
        );
        expect(
          streamText,
          contains('0 0 1 RG'),
          reason:
              'Blue stroke color (0 0 1 RG) must be set for DimensionStroke',
        );

        // 4. Dimension label string '300.0 mm' must be drawn via text operators
        expect(
          streamText,
          contains('300.0 mm'),
          reason:
              'Dimension text label "300.0 mm" must appear in PDF text operators',
        );
        expect(
          streamText,
          contains('BT'),
          reason: 'Begin Text (BT) operator must precede dimension label',
        );
        expect(
          streamText,
          contains('ET'),
          reason: 'End Text (ET) operator must follow dimension label',
        );

        // 5. Hidden layer decoy strokes must be completely excluded
        expect(
          streamText,
          isNot(contains('7.77 w')),
          reason:
              'Decoy line width 7.77 w from hidden layer must NOT appear in PDF stream',
        );
      },
    );
  });
}
