/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/lasso_callout_menu.dart';
import 'package:saber/components/canvas/lasso_screenshot_dialog.dart';
import 'package:saber/components/toolbar/lasso_filter_popup.dart';
import 'package:saber/components/toolbar/selection_bar.dart';
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

  group('Goodnotes Lasso Mechanics & State Invariants', () {
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
  });

  group('LassoCalloutMenu Goodnotes Parity Widget Tests', () {
    testWidgets('renders all Goodnotes action buttons', (tester) async {
      tester.view.physicalSize = const Size(1400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      var cutCalled = false;
      var copyCalled = false;
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
              onDuplicate: () {},
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

    testWidgets('Resize button reflects active state with Done label', (tester) async {
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
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
        0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
        0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
        0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
        0x42, 0x60, 0x82,
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LassoScreenshotDialog(imageBytes: dummyPng),
          ),
        ),
      );

      expect(find.text('Screenshot'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });
  });

  group('SelectionBar Goodnotes Parity Tests', () {
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
  });

  group('LassoFilterPopup Goodnotes UI Wording Tests', () {
    testWidgets('displays LASSO TYPE and INCLUDED IN SELECTION headers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LassoFilterPopup(),
          ),
        ),
      );

      expect(find.text('LASSO TYPE'), findsOneWidget);
      expect(find.text('Freehand'), findsOneWidget);
      expect(find.text('Rectangular'), findsOneWidget);
      expect(find.text('INCLUDED IN SELECTION'), findsOneWidget);
    });
  });
}
