/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/components/theming/adaptive_switch_list_tile.dart';
import 'package:saber/components/toolbar/lasso_filter_popup.dart';
import 'package:saber/components/toolbar/selection_bar.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';
import 'package:sbn/has_size.dart';

void main() {
  setUpAll(() {
    FlavorConfig.setup();
  });

  setUp(() {
    stows.lassoSelectHandwriting.value = true;
    stows.lassoSelectImages.value = true;
    stows.lassoSelectText.value = true;
    stows.selectionRectMode.value = false;
    Select.currentSelect.unselect();
  });

  tearDown(() {
    stows.lassoSelectHandwriting.value = true;
    stows.lassoSelectImages.value = true;
    stows.lassoSelectText.value = true;
    stows.selectionRectMode.value = false;
    Select.currentSelect.unselect();
  });

  group(
    'CHALLENGER EDGE CASE 1: Empty selection behavior when items match disabled filters',
    () {
      test(
        'onDragEnd: drag enclosing ONLY strokes when handwriting filter disabled yields empty selection',
        () {
          final select = Select.currentSelect;
          stows.lassoSelectHandwriting.value = false;
          stows.lassoSelectImages.value = true;
          stows.lassoSelectText.value = true;

          const page = HasSize(Size(200, 200));
          final stroke1 = _createStroke(const Offset(25, 25), page);
          final stroke2 = _createStroke(const Offset(35, 35), page);

          select.onDragStart(const Offset(10, 10), 0);
          select.onDragUpdate(const Offset(10, 80));
          select.onDragUpdate(const Offset(80, 80));
          select.onDragUpdate(const Offset(80, 10));
          select.onDragEnd([stroke1, stroke2], const [], textRect: Rect.zero);

          expect(
            select.selectResult.strokes,
            isEmpty,
            reason: 'Strokes must be excluded by filter',
          );
          expect(select.selectResult.images, isEmpty);
          expect(select.selectResult.textSelected, isFalse);
          expect(
            select.selectResult.isEmpty,
            isTrue,
            reason: 'Result must be completely empty',
          );
        },
      );

      test(
        'onDragEnd: drag enclosing ONLY images when image filter disabled yields empty selection',
        () {
          final select = Select.currentSelect;
          stows.lassoSelectImages.value = false;
          stows.lassoSelectHandwriting.value = true;
          stows.lassoSelectText.value = true;

          final image = _createTestImage(const Rect.fromLTWH(30, 30, 40, 40));

          select.onDragStart(const Offset(10, 10), 0);
          select.onDragUpdate(const Offset(10, 90));
          select.onDragUpdate(const Offset(90, 90));
          select.onDragUpdate(const Offset(90, 10));
          select.onDragEnd(const [], [image], textRect: Rect.zero);

          expect(
            select.selectResult.images,
            isEmpty,
            reason: 'Image must be excluded by filter',
          );
          expect(select.selectResult.strokes, isEmpty);
          expect(select.selectResult.textSelected, isFalse);
          expect(select.selectResult.isEmpty, isTrue);
        },
      );

      test(
        'onDragEnd: drag enclosing ONLY text when text filter disabled yields empty selection',
        () {
          final select = Select.currentSelect;
          stows.lassoSelectText.value = false;
          stows.lassoSelectHandwriting.value = true;
          stows.lassoSelectImages.value = true;

          const textRect = Rect.fromLTWH(20, 20, 50, 30);

          select.onDragStart(const Offset(10, 10), 0);
          select.onDragUpdate(const Offset(10, 80));
          select.onDragUpdate(const Offset(80, 80));
          select.onDragUpdate(const Offset(80, 10));
          select.onDragEnd(const [], const [], textRect: textRect);

          expect(
            select.selectResult.textSelected,
            isFalse,
            reason: 'Text must be excluded by filter',
          );
          expect(select.selectResult.isEmpty, isTrue);
        },
      );

      test(
        'tapSelect: tapping stroke when handwriting disabled calls unselect cleanly',
        () {
          final select = Select.currentSelect;
          stows.lassoSelectHandwriting.value = false;

          const page = HasSize(Size(200, 200));
          final stroke = _createStroke(const Offset(50, 50), page);

          select.tapSelect(const Offset(50, 50), [stroke], const [], 0);

          expect(
            select.doneSelecting,
            isFalse,
            reason: 'Must be unselected when target is filtered out',
          );
          expect(select.selectResult.isEmpty, isTrue);
          expect(select.selectResult.pageIndex, equals(-1));
        },
      );

      test(
        'tapSelect: tapping image when image filter disabled calls unselect cleanly',
        () {
          final select = Select.currentSelect;
          stows.lassoSelectImages.value = false;

          final image = _createTestImage(const Rect.fromLTWH(40, 40, 50, 50));

          select.tapSelect(const Offset(50, 50), const [], [image], 0);

          expect(select.doneSelecting, isFalse);
          expect(select.selectResult.isEmpty, isTrue);
          expect(select.selectResult.pageIndex, equals(-1));
        },
      );

      test(
        'tapSelect: tapping text when text filter disabled calls unselect cleanly',
        () {
          final select = Select.currentSelect;
          stows.lassoSelectText.value = false;

          select.tapSelect(
            const Offset(50, 50),
            const [],
            const [],
            0,
            textRect: const Rect.fromLTWH(30, 30, 40, 40),
          );

          expect(select.doneSelecting, isFalse);
          expect(select.selectResult.isEmpty, isTrue);
          expect(select.selectResult.pageIndex, equals(-1));
        },
      );

      test(
        'pruneDisabledFilters: resets image cropMode and unselects when images pruned',
        () {
          final select = Select.currentSelect;
          final image = _createTestImage(const Rect.fromLTWH(10, 10, 50, 50));
          image.cropMode = true;

          select.selectResult = SelectResult(
            pageIndex: 0,
            strokes: const [],
            images: [image],
            path: Path(),
          );
          select.doneSelecting = true;

          stows.lassoSelectImages.value = false;
          select.pruneDisabledFilters();

          expect(
            image.cropMode,
            isFalse,
            reason: 'cropMode must be cleared when image is pruned',
          );
          expect(select.selectResult.isEmpty, isTrue);
          expect(select.doneSelecting, isFalse);
          expect(select.selectResult.pageIndex, equals(-1));
        },
      );

      test('pruneDisabledFilters: no-op when doneSelecting is false', () {
        final select = Select.currentSelect;
        select.doneSelecting = false;
        stows.lassoSelectHandwriting.value = false;

        // Should not throw or crash
        select.pruneDisabledFilters();
        expect(select.doneSelecting, isFalse);
      });
    },
  );

  group('CHALLENGER EDGE CASE 2: Rapid toggling and reactive stow listeners', () {
    test(
      'rapid toggling: reactive stow listeners receive correct sequential notifications',
      () {
        final handwritingEvents = <bool>[];
        final imageEvents = <bool>[];
        final textEvents = <bool>[];

        void onHw() =>
            handwritingEvents.add(stows.lassoSelectHandwriting.value);
        void onImg() => imageEvents.add(stows.lassoSelectImages.value);
        void onTxt() => textEvents.add(stows.lassoSelectText.value);

        stows.lassoSelectHandwriting.addListener(onHw);
        stows.lassoSelectImages.addListener(onImg);
        stows.lassoSelectText.addListener(onTxt);

        try {
          for (int i = 0; i < 50; i++) {
            stows.lassoSelectHandwriting.value =
                !stows.lassoSelectHandwriting.value;
            stows.lassoSelectImages.value = !stows.lassoSelectImages.value;
            stows.lassoSelectText.value = !stows.lassoSelectText.value;
          }

          expect(handwritingEvents.length, equals(50));
          expect(imageEvents.length, equals(50));
          expect(textEvents.length, equals(50));
        } finally {
          stows.lassoSelectHandwriting.removeListener(onHw);
          stows.lassoSelectImages.removeListener(onImg);
          stows.lassoSelectText.removeListener(onTxt);
        }
      },
    );

    test(
      'stress test: invariant activeCount >= 1 holds across 500 randomized toggle attempts',
      () {
        final rng = Random(42);

        bool simulateToggle(String target, bool desiredValue) {
          if (!desiredValue) {
            final count =
                (stows.lassoSelectHandwriting.value ? 1 : 0) +
                (stows.lassoSelectImages.value ? 1 : 0) +
                (stows.lassoSelectText.value ? 1 : 0);
            if (count <= 1) return false; // Invariant enforced
          }
          switch (target) {
            case 'hw':
              stows.lassoSelectHandwriting.value = desiredValue;
            case 'img':
              stows.lassoSelectImages.value = desiredValue;
            case 'txt':
              stows.lassoSelectText.value = desiredValue;
          }
          return true;
        }

        for (int i = 0; i < 500; i++) {
          final targets = ['hw', 'img', 'txt'];
          final choice = targets[rng.nextInt(3)];
          final desired = rng.nextBool();

          simulateToggle(choice, desired);

          final active =
              (stows.lassoSelectHandwriting.value ? 1 : 0) +
              (stows.lassoSelectImages.value ? 1 : 0) +
              (stows.lassoSelectText.value ? 1 : 0);
          expect(
            active,
            greaterThanOrEqualTo(1),
            reason: 'Invariant broken at iteration $i',
          );
        }
      },
    );

    testWidgets(
      'LassoFilterPopup: rapid sequential user taps in UI preserve invariant',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: LassoFilterPopup())),
        );

        final hwTile = find.widgetWithText(
          AdaptiveSwitchListTile,
          'Handwriting',
        );
        final imgTile = find.widgetWithText(AdaptiveSwitchListTile, 'Images');
        final txtTile = find.widgetWithText(
          AdaptiveSwitchListTile,
          'Text Boxes',
        );
        final tapeTile = find.widgetWithText(
          AdaptiveSwitchListTile,
          'Study Tape',
        );
        if (tapeTile.evaluate().isNotEmpty) {
          await tester.ensureVisible(tapeTile);
          await tester.tap(tapeTile);
          await tester.pumpAndSettle();
        }

        // Turn off HW (2 active: img, txt)
        await tester.ensureVisible(hwTile);
        await tester.tap(hwTile);
        await tester.pump();
        expect(stows.lassoSelectHandwriting.value, isFalse);

        // Turn off Img (1 active: txt)
        await tester.tap(imgTile);
        await tester.pump();
        expect(stows.lassoSelectImages.value, isFalse);

        // Attempt to turn off Txt (MUST BE BLOCKED)
        await tester.tap(txtTile);
        await tester.pump();
        expect(
          stows.lassoSelectText.value,
          isTrue,
          reason: 'Last toggle must not be disabled',
        );

        // Rapidly tap all three in succession
        await tester.tap(txtTile);
        await tester.tap(txtTile);
        await tester.tap(hwTile); // Turns HW back on (now 2 active: txt, hw)
        await tester.pump();
        expect(stows.lassoSelectHandwriting.value, isTrue);

        await tester.tap(txtTile); // Turns Txt off (now 1 active: hw)
        await tester.pump();
        expect(stows.lassoSelectText.value, isFalse);

        await tester.tap(hwTile); // Attempt to turn HW off (MUST BE BLOCKED)
        await tester.pump();
        expect(stows.lassoSelectHandwriting.value, isTrue);
      },
    );
  });

  group(
    'CHALLENGER EDGE CASE 3: Rectangular selection mode vs freeform lasso mode with filters',
    () {
      test(
        'rectangular selection mode: filters exclude strokes and images correctly',
        () {
          final select = Select.currentSelect;
          stows.selectionRectMode.value = true;
          stows.lassoSelectHandwriting.value = true;
          stows.lassoSelectImages.value = false;

          const page = HasSize(Size(200, 200));
          final stroke = _createStroke(const Offset(30, 30), page);
          final image = _createTestImage(const Rect.fromLTWH(40, 40, 20, 20));

          // Drag rectangle from (10, 10) to (80, 80)
          select.onDragStart(const Offset(10, 10), 0);
          select.onDragUpdate(const Offset(80, 80));
          select.onDragEnd([stroke], [image], textRect: Rect.zero);

          expect(
            select.selectResult.strokes,
            contains(stroke),
            reason: 'Stroke is inside rectangle',
          );
          expect(
            select.selectResult.images,
            isEmpty,
            reason: 'Image is inside rect but excluded by filter',
          );
        },
      );

      test(
        'rectangular selection mode: filters include image but exclude strokes',
        () {
          final select = Select.currentSelect;
          stows.selectionRectMode.value = true;
          stows.lassoSelectHandwriting.value = false;
          stows.lassoSelectImages.value = true;

          const page = HasSize(Size(200, 200));
          final stroke = _createStroke(const Offset(30, 30), page);
          final image = _createTestImage(const Rect.fromLTWH(40, 40, 20, 20));

          select.onDragStart(const Offset(10, 10), 0);
          select.onDragUpdate(const Offset(80, 80));
          select.onDragEnd([stroke], [image], textRect: Rect.zero);

          expect(
            select.selectResult.strokes,
            isEmpty,
            reason: 'Strokes excluded by filter',
          );
          expect(
            select.selectResult.images,
            contains(image),
            reason: 'Image included by filter',
          );
        },
      );

      test(
        'freeform lasso mode: filters behave identically to rectangular mode',
        () {
          final select = Select.currentSelect;
          stows.selectionRectMode.value = false; // Freeform lasso
          stows.lassoSelectHandwriting.value = false;
          stows.lassoSelectImages.value = true;

          const page = HasSize(Size(200, 200));
          final stroke = _createStroke(const Offset(30, 30), page);
          final image = _createTestImage(const Rect.fromLTWH(40, 40, 20, 20));

          select.onDragStart(const Offset(10, 10), 0);
          select.onDragUpdate(const Offset(10, 80));
          select.onDragUpdate(const Offset(80, 80));
          select.onDragUpdate(const Offset(80, 10));
          select.onDragEnd([stroke], [image], textRect: Rect.zero);

          expect(select.selectResult.strokes, isEmpty);
          expect(select.selectResult.images, contains(image));
        },
      );

      test('mode switching does not leak state across gestures', () {
        final select = Select.currentSelect;
        const page = HasSize(Size(200, 200));
        final stroke = _createStroke(const Offset(30, 30), page);

        // 1. Rectangular gesture
        stows.selectionRectMode.value = true;
        select.onDragStart(const Offset(10, 10), 0);
        select.onDragUpdate(const Offset(50, 50));
        select.onDragEnd([stroke], const []);
        expect(select.selectResult.strokes, contains(stroke));

        select.unselect();

        // 2. Freeform gesture
        stows.selectionRectMode.value = false;
        select.onDragStart(const Offset(10, 10), 0);
        select.onDragUpdate(const Offset(10, 50));
        select.onDragUpdate(const Offset(50, 50));
        select.onDragUpdate(const Offset(50, 10));
        select.onDragEnd([stroke], const []);
        expect(select.selectResult.strokes, contains(stroke));
      });

      test(
        'rectangular selection: stationary image invariance when dragged and shifted',
        () {
          final select = Select.currentSelect;
          stows.selectionRectMode.value = true;
          stows.lassoSelectHandwriting.value = true;
          stows.lassoSelectImages.value = false;

          const page = HasSize(Size(300, 300));
          final stroke = _createStroke(const Offset(50, 50), page);
          const originalImageRect = Rect.fromLTWH(20, 20, 100, 100);
          final image = _createTestImage(originalImageRect);

          select.onDragStart(const Offset(10, 10), 0);
          select.onDragUpdate(const Offset(150, 150));
          select.onDragEnd([stroke], [image]);

          expect(select.selectResult.strokes, contains(stroke));
          expect(select.selectResult.images, isEmpty);

          // Simulate canvas translation
          const moveDelta = Offset(40, 60);
          for (final s in select.selectResult.strokes) {
            s.shift(moveDelta);
          }
          for (final img in select.selectResult.images) {
            img.dstRect = img.dstRect.shift(moveDelta);
          }

          // Background image must NOT move at all
          expect(image.dstRect, equals(originalImageRect));
        },
      );
    },
  );

  group(
    'CHALLENGER EDGE CASE 4: SelectionBar mode toggling and filter ingress',
    () {
      testWidgets('SelectionBar toggles rect mode and opens LassoFilterPopup', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionBar(
                copySelection: () {},
                pasteSelection: () {},
                duplicateSelection: () {},
                deleteSelection: () {},
              ),
            ),
          ),
        );

        expect(stows.selectionRectMode.value, isFalse);

        // Find rect/lasso mode button
        final modeButton = find.byTooltip('Lasso Select');
        expect(modeButton, findsOneWidget);

        // Tap to switch to Rect Select
        await tester.tap(modeButton);
        await tester.pumpAndSettle();
        expect(stows.selectionRectMode.value, isTrue);
        expect(find.byTooltip('Rect Select'), findsOneWidget);

        // Tap again to switch back to Lasso Select
        await tester.tap(find.byTooltip('Rect Select'));
        await tester.pumpAndSettle();
        expect(stows.selectionRectMode.value, isFalse);

        // Tap Lasso Filters button to open dialog
        final filterButton = find.byTooltip('Lasso Filters');
        expect(filterButton, findsOneWidget);
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        expect(find.byType(LassoFilterPopup), findsOneWidget);
        expect(find.text('Lasso Options'), findsOneWidget);
      });
    },
  );
}

Stroke _createStroke(Offset point, HasSize page) {
  return Stroke(
    color: Colors.black,
    pressureEnabled: false,
    options: StrokeOptions(size: 8),
    pageIndex: 0,
    page: page,
    toolId: .fountainPen,
  )..addPoint(point);
}

TestImage _createTestImage(Rect rect) {
  return TestImage(dstRect: rect);
}

// ignore: missing_override_of_must_be_overridden
class TestImage extends PngEditorImage {
  static final _assetCache = AssetCache();

  TestImage({required super.dstRect})
    : super(
        id: -1,
        extension: '.png',
        imageProvider: null,
        pageIndex: 0,
        pageSize: const Size(200, 200),
        onMoveImage: null,
        onDeleteImage: null,
        onMiscChange: null,
        assetCache: _assetCache,
      );

  @override
  Future<void> firstLoad() async {}
}
