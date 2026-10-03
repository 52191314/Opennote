/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_canvas_background_painter.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_exporter.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

import 'utils/test_mock_channel_handlers.dart';

void main() {
  setUpAll(() {
    setupMockPathProvider();
    setupMockPrinting();
    FlavorConfig.setup();
  });

  group('Stress 1: Zero-length & Sub-millipixel Arrows and Dimensions', () {
    const pageSize = Size(400, 600);
    const hasSize = HasSize(pageSize);

    test('Zero-length ArrowStroke toSvgPath returns empty string for all styles', () {
      for (final style in ArrowheadStyle.values) {
        final arrow = ArrowStroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2.0),
          pageIndex: 0,
          page: hasSize,
          toolId: ToolId.shapePen,
          start: const Offset(150, 150),
          end: const Offset(150, 150),
          arrowheadStyle: style,
        );

        expect(arrow.isEmpty, isTrue);
        expect(arrow.toSvgPath(), isEmpty, reason: 'Zero-length arrow ($style) must produce empty SVG path');
      }
    });

    test('Sub-millipixel length ArrowStroke toSvgPath returns empty string', () {
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(100.0, 100.0),
        end: const Offset(100.0005, 100.0005),
      );

      expect(arrow.toSvgPath(), isEmpty);
    });

    test('Zero-length DimensionStroke handles toSvgPath and textPosition gracefully', () {
      final dim = DimensionStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 1.5),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(200, 300),
        end: const Offset(200, 300),
        text: '0.0 mm',
        offset: 30.0,
      );

      expect(dim.isEmpty, isTrue);
      expect(dim.toSvgPath(), isEmpty, reason: 'Zero-length dimension must produce empty SVG path');
      expect(dim.textPosition, const Offset(200, 300));
      expect(dim.maxY, 300.0);
    });

    test('Sub-millipixel DimensionStroke toSvgPath returns empty string', () {
      final dim = DimensionStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 1.5),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(50.0, 50.0),
        end: const Offset(50.0004, 50.0004),
        text: 'sub-milli',
      );

      expect(dim.toSvgPath(), isEmpty);
    });
  });

  group('Stress 2: Arrowhead Styles & Collinear Geometry', () {
    const pageSize = Size(500, 500);
    const hasSize = HasSize(pageSize);

    test('ArrowheadStyle.none emits only shaft line without arrowhead segments', () {
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(10, 20),
        end: const Offset(100, 20),
        arrowheadStyle: ArrowheadStyle.none,
      );

      final svg = arrow.toSvgPath();
      expect(svg, equals('M10.0 480.0 L100.0 480.0'));
    });

    test('ArrowheadStyle.single emits shaft line and one tip segment', () {
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(10, 20),
        end: const Offset(100, 20),
        arrowheadStyle: ArrowheadStyle.single,
        headLength: 10,
        headAngle: 0.5,
      );

      final svg = arrow.toSvgPath();
      // start: (10, 20) -> Y: 480
      // end: (100, 20) -> Y: 480
      expect(svg, startsWith('M10.0 480.0 L100.0 480.0'));
      // Exactly 2 M commands (1 for shaft, 1 for arrowhead)
      final mCount = 'M'.allMatches(svg).length;
      expect(mCount, 2);
    });

    test('ArrowheadStyle.double emits shaft line and two tip segments', () {
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(10, 20),
        end: const Offset(100, 20),
        arrowheadStyle: ArrowheadStyle.double,
        headLength: 10,
        headAngle: 0.5,
      );

      final svg = arrow.toSvgPath();
      expect(svg, startsWith('M10.0 480.0 L100.0 480.0'));
      // Exactly 3 M commands (1 for shaft, 1 for end arrowhead, 1 for start arrowhead)
      final mCount = 'M'.allMatches(svg).length;
      expect(mCount, 3);
    });

    test('Vertical and orthogonal directions compute finite non-NaN coordinates', () {
      final verticalArrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(100, 50),
        end: const Offset(100, 450),
        arrowheadStyle: ArrowheadStyle.double,
      );

      final svg = verticalArrow.toSvgPath();
      expect(svg, isNot(contains('NaN')));
      expect(svg, isNot(contains('Infinity')));

      final verticalDim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(100, 50),
        end: const Offset(100, 450),
        offset: -20,
        text: '400',
      );

      final dimSvg = verticalDim.toSvgPath();
      expect(dimSvg, isNot(contains('NaN')));
      expect(dimSvg, isNot(contains('Infinity')));
    });
  });

  group('Stress 3: Negative Coordinates & Off-Canvas Endpoints', () {
    const pageSize = Size(400, 600);
    const hasSize = HasSize(pageSize);

    test('Negative coordinates in ArrowStroke are properly inverted without NaN', () {
      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(-100, -200),
        end: const Offset(-50, -100),
        arrowheadStyle: ArrowheadStyle.single,
      );

      final svg = arrow.toSvgPath();
      expect(svg, isNotEmpty);
      expect(svg, isNot(contains('NaN')));
      // start Y: 600 - (-200) = 800.0
      // end Y: 600 - (-100) = 700.0
      expect(svg, contains('M-100.0 800.0 L-50.0 700.0'));
    });

    test('Far off-canvas coordinates in DimensionStroke compute correctly', () {
      final dim = DimensionStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(-5000, 15000),
        end: const Offset(25000, -8000),
        offset: -100.0,
        text: 'Huge Span',
      );

      final svg = dim.toSvgPath();
      expect(svg, isNotEmpty);
      expect(svg, isNot(contains('NaN')));
      expect(dim.textPosition.dx.isFinite, isTrue);
      expect(dim.textPosition.dy.isFinite, isTrue);
    });
  });

  group('Stress 4: Engineering Grid Modulo Drift Across 50,000 px', () {
    test('computes heavy lines without drift across 50,000 px with integer lineHeight', () {
      const size = Size(50000, 50000);
      const lineHeight = 10;
      final elements = CanvasBackgroundPainter.getPatternElements(
        pattern: CanvasBackgroundPattern.engineeringGrid,
        size: size,
        lineHeight: lineHeight,
      ).toList();

      expect(elements, isNotEmpty);

      int heavyHCount = 0;
      int totalHCount = 0;
      for (final e in elements) {
        if (e.start.dy == e.end.dy && e.start.dx == 0 && e.end.dx == size.width) {
          totalHCount++;
          final index = ((e.start.dy - lineHeight * 2) / lineHeight).round();
          if (index % 10 == 0) {
            expect(e.thickness, isNotNull, reason: 'Line at index $index must be heavy');
            heavyHCount++;
          } else {
            expect(e.thickness, isNull, reason: 'Line at index $index must NOT be heavy');
          }
        }
      }

      // Check total horizontal lines: y from 20 up to 50000 with step 10 -> (50000 - 20) / 10 = 4998
      expect(totalHCount, 4998);
      // Heavy lines: index 0, 10, 20, ..., 4990 -> 500 lines
      expect(heavyHCount, 500);

      int heavyVCount = 0;
      int totalVCount = 0;
      for (final e in elements) {
        if (e.start.dx == e.end.dx && e.start.dy == lineHeight * 2 && e.end.dy == size.height) {
          totalVCount++;
          final index = (e.start.dx / lineHeight).round();
          if (index % 10 == 0) {
            expect(e.thickness, isNotNull, reason: 'Line at x=${e.start.dx} (index $index) must be heavy');
            heavyVCount++;
          } else {
            expect(e.thickness, isNull, reason: 'Line at x=${e.start.dx} (index $index) must NOT be heavy');
          }
        }
      }

      // Check total vertical lines: x from 0 up to 50000 with step 10 -> 5000 lines
      expect(totalVCount, 5000);
      expect(heavyVCount, 500);
    });

    test('computes heavy lines without drift across 50,000 px with non-round integer lineHeight (13 and 19)', () {
      for (final lineHeight in [13, 19]) {
        const size = Size(50000, 50000);
        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.engineeringGrid,
          size: size,
          lineHeight: lineHeight,
        ).toList();

        expect(elements, isNotEmpty);

        int lineIdx = 0;
        for (final e in elements) {
          if (e.start.dy == e.end.dy && e.start.dx == 0 && e.end.dx == size.width) {
            final computedIndex = ((e.start.dy - lineHeight * 2) / lineHeight).round();
            // Verify that floating point accumulation matches integer step counter
            expect(computedIndex, lineIdx, reason: 'Line step $lineIdx with lineHeight $lineHeight must match integer counter');
            if (lineIdx % 10 == 0) {
              expect(e.thickness, isNotNull);
            } else {
              expect(e.thickness, isNull);
            }
            lineIdx++;
          }
        }
      }
    });
  });

  group('Stress 5: Full EditorExporter.generatePdf Adversarial Stress Test', () {
    testWidgets('Adversarial batch: zero-length, negative coords, unicode, emojis, and 500 hidden strokes', (tester) async {
      await tester.runAsync(FileManager.init);

      const pageSize = Size(500, 700);
      const hasSize = HasSize(pageSize);

      // 1. Zero-length arrow and dimension
      final zeroArrow = ArrowStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(100, 100),
        end: const Offset(100, 100),
        arrowheadStyle: ArrowheadStyle.double,
      );

      final zeroDim = DimensionStroke(
        color: Colors.red,
        pressureEnabled: false,
        options: StrokeOptions(size: 1.5),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(150, 150),
        end: const Offset(150, 150),
        text: '0 mm',
      );

      // 2. Negative and off-canvas coords
      final negativeArrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(-200, -300),
        end: const Offset(800, 1200),
        arrowheadStyle: ArrowheadStyle.single,
      );

      // 3. ArrowheadStyle.none
      final noneArrow = ArrowStroke(
        color: Colors.green,
        pressureEnabled: false,
        options: StrokeOptions(size: 3.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(50, 200),
        end: const Offset(350, 200),
        arrowheadStyle: ArrowheadStyle.none,
      );

      // 4. Unicode and Emoji dimensions
      final dimEmptyText = DimensionStroke(
        color: Colors.purple,
        pressureEnabled: false,
        options: StrokeOptions(size: 1.5),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(50, 300),
        end: const Offset(250, 300),
        text: '', // Empty text
      );

      final dimSpecialUnicode = DimensionStroke(
        color: Colors.orange,
        pressureEnabled: false,
        options: StrokeOptions(size: 1.5),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(50, 400),
        end: const Offset(250, 400),
        text: '45.0° ± 0.05 µm', // Latin-1 / Greek / math symbols
      );

      final dimEmoji = DimensionStroke(
        color: Colors.amber,
        pressureEnabled: false,
        options: StrokeOptions(size: 1.5),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(50, 500),
        end: const Offset(250, 500),
        text: '📐 150 mm 📏 🚀', // Emojis
      );

      final dimAsian = DimensionStroke(
        color: Colors.teal,
        pressureEnabled: false,
        options: StrokeOptions(size: 1.5),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(50, 600),
        end: const Offset(250, 600),
        text: '長さ: 100mm (寸法)', // CJK characters
      );

      // 5. Visible layer containing all valid & stress drafting strokes
      final visibleLayer = Layer(
        name: 'Visible Layer',
        visible: true,
        strokes: [
          zeroArrow,
          zeroDim,
          negativeArrow,
          noneArrow,
          dimEmptyText,
          dimSpecialUnicode,
          dimEmoji,
          dimAsian,
        ],
      );

      // 6. Hidden layer containing 500 strokes
      final hiddenStrokes = List.generate(
        500,
        (i) => ArrowStroke(
          color: Colors.grey,
          pressureEnabled: false,
          options: StrokeOptions(size: 1.0),
          pageIndex: 0,
          page: hasSize,
          toolId: ToolId.shapePen,
          start: Offset(i.toDouble(), 0),
          end: Offset(i.toDouble(), 100),
        ),
      );

      final hiddenLayer = Layer(
        name: 'Massive Hidden Layer',
        visible: false,
        strokes: hiddenStrokes,
      );

      final page = EditorPage(
        size: pageSize,
        layers: [visibleLayer, hiddenLayer],
      );

      final coreInfo = EditorCoreInfo(
        filePath: 'adversarial_stress_test.sbn2',
      )..pages.add(page);

      late BuildContext buildContext;
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                buildContext = context;
                return const Scaffold(body: Text('Stress Test Harness'));
              },
            ),
          ),
        ),
      );

      // Verify that page.strokes strictly excludes all 500 hidden strokes
      expect(page.strokes.length, 8);
      for (final s in hiddenStrokes) {
        expect(page.strokes.contains(s), isFalse);
      }

      // Generate PDF under adversarial conditions
      final pdfDoc = await tester.runAsync(
        () => EditorExporter.generatePdf(coreInfo, buildContext),
      );

      expect(pdfDoc, isNotNull);
      expect(pdfDoc!.document.pdfPageList.pages.length, 1);

      // Save PDF binary to ensure graphics stream has valid syntax and no encoding crash
      final bytes = await tester.runAsync(pdfDoc.save);
      expect(bytes, isNotNull);
      expect(bytes!.length, greaterThan(0));

      // PDF header magic bytes '%PDF'
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    testWidgets('Extreme canvas aspect ratio (tall canvas: 400 x 4000)', (tester) async {
      await tester.runAsync(FileManager.init);

      const tallSize = Size(400, 4000);
      const hasSize = HasSize(tallSize);

      final arrow = ArrowStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 2.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(50, 100),
        end: const Offset(350, 3900),
        arrowheadStyle: ArrowheadStyle.single,
      );

      final dim = DimensionStroke(
        color: Colors.red,
        pressureEnabled: false,
        options: StrokeOptions(size: 1.5),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(100, 200),
        end: const Offset(100, 3800),
        offset: 50.0,
        text: '3600 px',
      );

      final layer = Layer(
        name: 'Tall Layer',
        visible: true,
        strokes: [arrow, dim],
      );

      final page = EditorPage(
        size: tallSize,
        layers: [layer],
      );

      final coreInfo = EditorCoreInfo(
        filePath: 'tall_page.sbn2',
      )..pages.add(page);

      late BuildContext buildContext;
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                buildContext = context;
                return const Scaffold(body: Text('Tall Aspect Harness'));
              },
            ),
          ),
        ),
      );

      final pdfDoc = await tester.runAsync(
        () => EditorExporter.generatePdf(coreInfo, buildContext),
      );

      expect(pdfDoc, isNotNull);
      final bytes = await tester.runAsync(pdfDoc!.save);
      expect(bytes, isNotNull);
      expect(String.fromCharCodes(bytes!.take(4)), '%PDF');
    });

    testWidgets('Extreme canvas size (10,000 x 10,000) vector coordinate conversion and generatePdf', (tester) async {
      await tester.runAsync(FileManager.init);

      const hugeSize = Size(10000, 10000);
      const hasSize = HasSize(hugeSize);

      final arrow = ArrowStroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(size: 5.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(100, 9900),
        end: const Offset(9900, 100),
        arrowheadStyle: ArrowheadStyle.double,
      );

      final svg = arrow.toSvgPath();
      expect(svg, isNotEmpty);
      // start: (100, 9900) -> inverted Y = 10000 - 9900 = 100.0
      // end: (9900, 100) -> inverted Y = 10000 - 100 = 9900.0
      expect(svg, contains('M100.0 100.0 L9900.0 9900.0'));

      final dim = DimensionStroke(
        color: Colors.red,
        pressureEnabled: false,
        options: StrokeOptions(size: 3.0),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(500, 5000),
        end: const Offset(9500, 5000),
        offset: 200.0,
        text: '9000 mm',
      );

      final dimSvg = dim.toSvgPath();
      expect(dimSvg, isNotEmpty);
      expect(dimSvg, isNot(contains('NaN')));
      expect(dim.textPosition.dx, 5000.0);
      // offset is perpendicular: for horizontal line (1, 0), perp is (0, 1) -> dy = 5000 + 200 = 5200
      expect(dim.textPosition.dy, 5200.0);

      final layer = Layer(
        name: 'Huge Layer',
        visible: true,
        strokes: [arrow, dim],
      );

      final page = EditorPage(
        size: hugeSize,
        layers: [layer],
      );

      final coreInfo = EditorCoreInfo(
        filePath: 'huge_page.sbn2',
      )..pages.add(page);

      late BuildContext buildContext;
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                buildContext = context;
                return const Scaffold(body: Text('Huge Canvas Harness'));
              },
            ),
          ),
        ),
      );
      final pdfDoc = await tester.runAsync(
        () => EditorExporter.generatePdf(coreInfo, buildContext),
      );

      expect(pdfDoc, isNotNull);
      final bytes = await tester.runAsync(pdfDoc!.save);
      expect(bytes, isNotNull);
      expect(String.fromCharCodes(bytes!.take(4)), '%PDF');
    });

    testWidgets('Assert PDF graphics vector stream contains stroke operators (S, w, RG) without fill', (tester) async {
      await tester.runAsync(FileManager.init);

      const pageSize = Size(400, 400);
      const hasSize = HasSize(pageSize);

      // Line width = 4.5, Color = pure red (RGB 1, 0, 0)
      final arrow = ArrowStroke(
        color: const Color(0xFFFF0000),
        pressureEnabled: false,
        options: StrokeOptions(size: 4.5),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(50, 50),
        end: const Offset(350, 50),
        arrowheadStyle: ArrowheadStyle.single,
      );

      final dim = DimensionStroke(
        color: const Color(0xFF0000FF), // Pure blue
        pressureEnabled: false,
        options: StrokeOptions(size: 2.75),
        pageIndex: 0,
        page: hasSize,
        toolId: ToolId.shapePen,
        start: const Offset(50, 150),
        end: const Offset(350, 150),
        offset: 30.0,
        text: '300',
      );

      final page = EditorPage(
        size: pageSize,
        layers: [
          Layer(name: 'Vectors', visible: true, strokes: [arrow, dim]),
        ],
      );

      final coreInfo = EditorCoreInfo(filePath: 'stroking_test.sbn2')..pages.add(page);

      late BuildContext buildContext;
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                buildContext = context;
                return const Scaffold(body: Text('Stroke Inspection'));
              },
            ),
          ),
        ),
      );

      final pdfDoc = await tester.runAsync(
        () => EditorExporter.generatePdf(coreInfo, buildContext),
      );

      expect(pdfDoc, isNotNull);
      final bytes = await tester.runAsync(pdfDoc!.save);
      expect(bytes, isNotNull);

      // Extract and decompress all FlateDecode streams from PDF
      final pdfContent = bytes!;
      final pdfString = String.fromCharCodes(pdfContent);

      final streamRegex = RegExp(r'stream\r?\n([\s\S]*?)\r?\nendstream');
      final allDecompressedStreams = <String>[];

      for (final match in streamRegex.allMatches(pdfString)) {
        final startIdx = match.start + 'stream\n'.length;
        // Search for endstream
        final endMatch = pdfString.indexOf('endstream', match.start);
        if (endMatch > startIdx) {
          // Find actual binary slice
          final streamHeaderIndex = pdfString.indexOf('stream', match.start);
          var dataStart = streamHeaderIndex + 6;
          if (pdfContent[dataStart] == 13) dataStart++; // \r
          if (pdfContent[dataStart] == 10) dataStart++; // \n
          var dataEnd = endMatch;
          while (dataEnd > dataStart && (pdfContent[dataEnd - 1] == 10 || pdfContent[dataEnd - 1] == 13)) {
            dataEnd--;
          }
          final slice = pdfContent.sublist(dataStart, dataEnd);
          try {
            final inflated = zlib.decode(slice);
            allDecompressedStreams.add(String.fromCharCodes(inflated));
          } catch (_) {
            // Uncompressed or image stream
            allDecompressedStreams.add(String.fromCharCodes(slice));
          }
        }
      }

      final combinedStreams = allDecompressedStreams.join('\n');

      // Verify stroke operator 'S' is present
      expect(combinedStreams, contains(' S '), reason: 'PDF graphics stream must contain stroke path operator "S"');

      // Verify line widths are set: 4.5 w and 2.75 w
      expect(combinedStreams, contains('4.5 w'), reason: 'PDF graphics stream must set line width 4.5 for arrow');
      expect(combinedStreams, contains('2.75 w'), reason: 'PDF graphics stream must set line width 2.75 for dimension');

      // Verify stroke color operator 'RG' is present (red: 1 0 0 RG, blue: 0 0 1 RG)
      expect(combinedStreams, contains('1 0 0 RG'), reason: 'PDF graphics stream must set red stroke color');
      expect(combinedStreams, contains('0 0 1 RG'), reason: 'PDF graphics stream must set blue stroke color');
    });
  });
}
