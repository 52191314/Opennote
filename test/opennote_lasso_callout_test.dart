/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/lasso_callout_menu.dart';
import 'package:saber/components/canvas/lasso_screenshot_dialog.dart';
import 'package:saber/components/toolbar/lasso_filter_popup.dart';
import 'package:saber/components/toolbar/selection_bar.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/select.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FlavorConfig.setup();
  });

  setUp(() {
    Select.currentSelect.unselect();
  });

  group('Opennote Lasso Mechanics & State Invariants', () {
    test('Default selection has isResizeActive = false (clean contour)', () {
      final select = Select.currentSelect;
      expect(select.isResizeActive, isFalse);

      select.isResizeActive = true;
      expect(select.isResizeActive, isTrue);

      select.unselect();
      expect(select.isResizeActive, isFalse);
    });

    test('onDragStart resets isResizeActive to false', () {
      final select = Select.currentSelect;
      select.isResizeActive = true;
      select.onDragStart(const Offset(10, 10), 0);
      expect(select.isResizeActive, isFalse);
    });

    test('selectStrokes sets isResizeActive = true for immediate resizing', () {
      final select = Select.currentSelect;
      expect(select.isResizeActive, isFalse);

      final page = EditorPage(size: const Size(1000, 1400));
      final stroke =
          Stroke(
              color: Colors.black,
              pressureEnabled: false,
              options: StrokeOptions(),
              pageIndex: 0,
              page: page,
              toolId: .fountainPen,
            )
            ..addPoint(const Offset(10, 10))
            ..addPoint(const Offset(20, 20));
      select.selectStrokes([stroke], 0);
      expect(select.isResizeActive, isTrue);

      select.unselect();
      expect(select.isResizeActive, isFalse);
    });

    test(
      'onDragStart initializes path at start position and does not connect to (0, 0)',
      () {
        final select = Select.currentSelect;
        select.onDragStart(const Offset(300, 400), 0);
        select.onDragUpdate(const Offset(350, 400));
        select.onDragUpdate(const Offset(350, 450));
        select.onDragUpdate(const Offset(300, 450));
        select.onDragEnd(const [], const []);

        final bounds = select.selectResult.path.getBounds();
        expect(bounds.left, greaterThanOrEqualTo(290));
        expect(bounds.top, greaterThanOrEqualTo(390));
        expect(bounds.contains(Offset.zero), isFalse);
      },
    );

    test(
      'computeTextContentRect returns Rect.zero for empty or whitespace-only document',
      () {
        final page = EditorPage(size: const Size(1000, 1400));
        expect(page.computeTextContentRect(30.0), equals(Rect.zero));

        page.quill.controller.document.insert(0, '\n   \n\n');
        expect(page.computeTextContentRect(30.0), equals(Rect.zero));

        page.quill.controller.document.insert(0, 'Hello world');
        final rect = page.computeTextContentRect(30.0);
        expect(rect, isNot(equals(Rect.zero)));
        expect(rect.width, greaterThan(0));
      },
    );
  });

  group('LassoCalloutMenu Widget Tests', () {
    testWidgets('renders all action buttons', (tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var cutCalled = false;
      var copyCalled = false;
      var duplicateCalled = false;
      var deleteCalled = false;
      var resizeToggled = false;
      var screenshotCalled = false;
      var elementCalled = false;
      var smoothenCalled = false;
      var frontCalled = false;
      var backCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LassoCalloutMenu(
              onCut: () => cutCalled = true,
              onCopy: () => copyCalled = true,
              onDuplicate: () => duplicateCalled = true,
              onDelete: () => deleteCalled = true,
              onSetColor: (_) {},
              isResizeActive: false,
              onToggleResize: () => resizeToggled = true,
              onTakeScreenshot: () => screenshotCalled = true,
              onAddToElements: () => elementCalled = true,
              onBringToFront: () => frontCalled = true,
              onSendToBack: () => backCalled = true,
              onSmoothen: () => smoothenCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Cut'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Duplicate'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Resize'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Screenshot'), findsOneWidget);
      expect(find.text('Element'), findsOneWidget);
      expect(find.text('Arrange'), findsOneWidget);
      expect(find.text('Smoothen'), findsOneWidget);

      // Tap Cut
      await tester.tap(find.text('Cut'));
      expect(cutCalled, isTrue);

      // Tap Copy
      await tester.tap(find.text('Copy'));
      expect(copyCalled, isTrue);

      // Tap Duplicate
      await tester.tap(find.text('Duplicate'));
      expect(duplicateCalled, isTrue);

      // Tap Delete
      await tester.tap(find.text('Delete'));
      expect(deleteCalled, isTrue);

      // Tap Resize
      await tester.tap(find.text('Resize'));
      expect(resizeToggled, isTrue);

      // Tap Screenshot
      await tester.tap(find.text('Screenshot'));
      expect(screenshotCalled, isTrue);

      // Tap Element
      await tester.tap(find.text('Element'));
      expect(elementCalled, isTrue);

      // Tap Smoothen
      await tester.tap(find.text('Smoothen'));
      expect(smoothenCalled, isTrue);

      // Tap Arrange -> reveals Front & Back
      await tester.tap(find.text('Arrange'));
      await tester.pumpAndSettle();
      expect(find.text('Front'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      await tester.tap(find.text('Front'));
      expect(frontCalled, isTrue);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Arrange'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back'));
      expect(backCalled, isTrue);
    });

    testWidgets('Resize button reflects active state with Done label', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LassoCalloutMenu(
              onCut: () {},
              onCopy: () {},
              onDuplicate: () {},
              onDelete: () {},
              onSetColor: (_) {},
              isResizeActive: true,
              onToggleResize: () {},
            ),
          ),
        ),
      );

      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('Color button opens quick palette swatches', (tester) async {
      Color? pickedColor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LassoCalloutMenu(
              onCut: () {},
              onCopy: () {},
              onDuplicate: () {},
              onDelete: () {},
              onSetColor: (c) => pickedColor = c,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Color'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      // Tap quick color swatch
      await tester.tap(find.byType(InkResponse).first);
      expect(pickedColor, isNotNull);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Color'), findsOneWidget);
    });
  });

  group('LassoScreenshotDialog Widget Tests', () {
    testWidgets('renders dialog preview and actions', (tester) async {
      // 10x10 transparent PNG header bytes
      final dummyPng = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0A,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x63,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82,
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LassoScreenshotDialog(imageBytes: dummyPng)),
        ),
      );

      expect(find.text('Screenshot'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });
  });

  group('SelectionBar Widget Tests', () {
    testWidgets('renders resize and screenshot toolbar icons', (tester) async {
      var resizeCalled = false;
      var screenshotCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionBar(
              copySelection: () {},
              pasteSelection: () {},
              duplicateSelection: () {},
              deleteSelection: () {},
              toggleResize: () => resizeCalled = true,
              isResizeActive: false,
              takeScreenshot: () => screenshotCalled = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.open_in_full_rounded), findsOneWidget);
      expect(find.byIcon(Icons.crop_free_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.open_in_full_rounded));
      expect(resizeCalled, isTrue);

      await tester.tap(find.byIcon(Icons.crop_free_rounded));
      expect(screenshotCalled, isTrue);
    });

    testWidgets('renders cut and color toolbar buttons and handles actions', (
      tester,
    ) async {
      var cutCalled = false;
      Color? selectedColor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionBar(
              cutSelection: () => cutCalled = true,
              copySelection: () {},
              pasteSelection: () {},
              duplicateSelection: () {},
              deleteSelection: () {},
              onSetColor: (c) => selectedColor = c,
            ),
          ),
        ),
      );

      // Verify Cut button is present and functional
      expect(find.byIcon(Icons.content_cut), findsOneWidget);
      await tester.tap(find.byIcon(Icons.content_cut));
      expect(cutCalled, isTrue);

      // Verify Color button is present and opens popup menu with colors
      expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.palette_outlined));
      await tester.pumpAndSettle();

      // Quick colors should be visible in popup menu
      expect(find.text('Black'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Red'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Yellow'), findsOneWidget);
      expect(find.text('Purple'), findsOneWidget);
      expect(find.text('Orange'), findsOneWidget);

      // Selecting Blue
      await tester.tap(find.text('Blue'));
      await tester.pumpAndSettle();
      expect(selectedColor, equals(const Color(0xFF1976D2)));
    });
  });

  group('LassoFilterPopup UI Wording Tests', () {
    testWidgets('displays LASSO TYPE and INCLUDED IN SELECTION headers', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LassoFilterPopup())),
      );

      expect(find.text('LASSO TYPE'), findsOneWidget);
      expect(find.text('Freehand'), findsOneWidget);
      expect(find.text('Rectangular'), findsOneWidget);
      expect(find.text('INCLUDED IN SELECTION'), findsOneWidget);
    });
  });
}
