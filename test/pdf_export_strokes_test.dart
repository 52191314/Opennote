/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_canvas_background_painter.dart';
import 'package:saber/components/canvas/_circle_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_rectangle_stroke.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_exporter.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/has_size.dart';

import 'utils/test_mock_channel_handlers.dart';

void main() {
  group('ArrowStroke.toSvgPath Y-inversion', () {
    const pageSize = Size(200, 400);
    const hasSize = HasSize(pageSize);

    test('inverts Y coordinates for arrow start and end', () {
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: .shapePen,
        start: const Offset(10, 50),
        end: const Offset(100, 150),
        arrowheadStyle: ArrowheadStyle.single,
      );

      final svg = arrow.toSvgPath();
      expect(svg, isNotEmpty);

      // start (10, 50) -> Y is 400 - 50 = 350
      // end (100, 150) -> Y is 400 - 150 = 250
      expect(svg, contains('M10.0 350.0 L100.0 250.0'));

      // Parse all points in the SVG path to verify all Y coordinates are within [0, 400]
      // and accurately inverted
      final parts = svg.split(RegExp(r'[ML]')).where((s) => s.trim().isNotEmpty);
      for (final part in parts) {
        final coords = part.trim().split(' ').map(double.parse).toList();
        expect(coords.length, 2);
        expect(coords[0], inInclusiveRange(0.0, 200.0));
        expect(coords[1], inInclusiveRange(0.0, 400.0));
      }
    });

    test('inverts Y coordinates for double arrowhead', () {
      final arrow = ArrowStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: .shapePen,
        start: const Offset(50, 100),
        end: const Offset(150, 100),
        arrowheadStyle: ArrowheadStyle.double,
      );

      final svg = arrow.toSvgPath();
      // Y = 100 -> inverted Y = 300
      expect(svg, contains('M50.0 300.0 L150.0 300.0'));
    });
  });

  group('DimensionStroke.toSvgPath Y-inversion', () {
    const pageSize = Size(300, 500);
    const hasSize = HasSize(pageSize);

    test('inverts Y coordinates for dimension line and extension lines', () {
      final dim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 1.5),
        pageIndex: 0,
        page: hasSize,
        toolId: .shapePen,
        start: const Offset(20, 100),
        end: const Offset(200, 100),
        offset: 30,
        text: '180 px',
      );

      final svg = dim.toSvgPath();
      expect(svg, isNotEmpty);

      // start (20, 100) -> inverted Y = 500 - 100 = 400
      // end (200, 100) -> inverted Y = 500 - 100 = 400
      // dimStart and dimEnd have offset: perp * offset = (0, 1) * 30 -> dy = 130 -> inverted Y = 370
      expect(svg, contains('M20.0 400.0 L20.0 370.0'));
      expect(svg, contains('M200.0 400.0 L200.0 370.0'));
      expect(svg, contains('M20.0 370.0 L200.0 370.0'));

      // All points should have inverted Y coordinates within [0, 500]
      final parts = svg.split(RegExp(r'[ML]')).where((s) => s.trim().isNotEmpty);
      for (final part in parts) {
        final coords = part.trim().split(' ').map(double.parse).toList();
        expect(coords.length, 2);
        expect(coords[0], inInclusiveRange(0.0, 300.0));
        expect(coords[1], inInclusiveRange(0.0, 500.0));
      }
    });
  });

  group('Engineering grid integer line index modulo', () {
    test('computes heavy lines without modulo drift', () {
      const size = Size(500, 500);
      const lineHeight = 10;
      final elements = CanvasBackgroundPainter.getPatternElements(
        pattern: CanvasBackgroundPattern.engineeringGrid,
        size: size,
        lineHeight: lineHeight,
      ).toList();

      expect(elements, isNotEmpty);

      // Filter horizontal lines
      final horizontalLines = elements.where(
        (e) => e.start.dy == e.end.dy && e.start.dx == 0 && e.end.dx == size.width,
      ).toList();

      for (final line in horizontalLines) {
        final lineIndex = ((line.start.dy - lineHeight * 2) / lineHeight).round();
        if (lineIndex % 10 == 0) {
          expect(
            line.thickness,
            isNotNull,
            reason: 'Horizontal line at y=${line.start.dy} (index $lineIndex) must be heavy',
          );
        } else {
          expect(
            line.thickness,
            isNull,
            reason: 'Horizontal line at y=${line.start.dy} (index $lineIndex) must NOT be heavy',
          );
        }
      }

      // Filter vertical lines
      final verticalLines = elements.where(
        (e) => e.start.dx == e.end.dx && e.start.dy == lineHeight * 2 && e.end.dy == size.height,
      ).toList();

      for (final line in verticalLines) {
        final lineIndex = (line.start.dx / lineHeight).round();
        if (lineIndex % 10 == 0) {
          expect(
            line.thickness,
            isNotNull,
            reason: 'Vertical line at x=${line.start.dx} (index $lineIndex) must be heavy',
          );
        } else {
          expect(
            line.thickness,
            isNull,
            reason: 'Vertical line at x=${line.start.dx} (index $lineIndex) must NOT be heavy',
          );
        }
      }
    });
  });

  group('PDF Vector Export for Linear Strokes & Layer Visibility', () {
    testWidgets('exports ArrowStroke and DimensionStroke and excludes hidden layers', (tester) async {
      setupMockPathProvider();
      setupMockPrinting();
      FlavorConfig.setup();
      await tester.runAsync(FileManager.init);

      const pageSize = Size(400, 600);
      const hasSize = HasSize(pageSize);

      final arrow = ArrowStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: .shapePen,
        start: const Offset(50, 100),
        end: const Offset(250, 300),
        arrowheadStyle: ArrowheadStyle.single,
      );

      final dimension = DimensionStroke(
        color: Colors.red,
        pressureEnabled: false,
        options: StrokeOptions(size: 1.5),
        pageIndex: 0,
        page: hasSize,
        toolId: .shapePen,
        start: const Offset(60, 200),
        end: const Offset(260, 200),
        offset: 40.0,
        text: '200 px',
      );

      final rect = RectangleStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 1.0),
        pageIndex: 0,
        page: hasSize,
        toolId: .shapePen,
        rect: const Rect.fromLTWH(50, 50, 100, 80),
      );

      final hiddenCircle = CircleStroke(
        color: Colors.green,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: .shapePen,
        center: const Offset(150, 150),
        radius: 40.0,
      );

      final visibleLayer = Layer(
        name: 'Visible Drafting',
        visible: true,
        strokes: [arrow, dimension, rect],
      );

      final hiddenLayer = Layer(
        name: 'Hidden Layer',
        visible: false,
        strokes: [hiddenCircle],
      );

      final testPage = EditorPage(
        size: pageSize,
        layers: [visibleLayer, hiddenLayer],
      );

      final coreInfo = EditorCoreInfo(
        filePath: 'test_drafting.sbn2',
      )..pages.add(testPage);

      late BuildContext buildContext;
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                buildContext = context;
                return const Scaffold(body: Text('PDF Export Test'));
              },
            ),
          ),
        ),
      );

      // Verify that hidden layer strokes are excluded from page.strokes
      expect(testPage.strokes, contains(arrow));
      expect(testPage.strokes, contains(dimension));
      expect(testPage.strokes, contains(rect));
      expect(testPage.strokes, isNot(contains(hiddenCircle)));

      // Generate PDF
      final pdfDoc = await tester.runAsync(
        () => EditorExporter.generatePdf(coreInfo, buildContext),
      );

      expect(pdfDoc, isNotNull);
      expect(pdfDoc!.document.pdfPageList.pages.length, 1);

      // Save PDF to verify valid binary generation without crashing
      final bytes = await tester.runAsync(pdfDoc.save);
      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(0));

      // PDF header magic bytes '%PDF'
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
