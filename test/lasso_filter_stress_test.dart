/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/components/theming/adaptive_switch_list_tile.dart';
import 'package:saber/components/toolbar/lasso_filter_popup.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

void main() {
  setUpAll(() {
    FlavorConfig.setup();
  });

  setUp(() {
    stows.lassoSelectHandwriting.value = true;
    stows.lassoSelectImages.value = true;
    stows.lassoSelectText.value = true;
    stows.lassoSelectTape.value = true;
    stows.selectionRectMode.value = false;
    Select.currentSelect.unselect();
  });

  tearDown(() {
    stows.lassoSelectHandwriting.value = true;
    stows.lassoSelectImages.value = true;
    stows.lassoSelectText.value = true;
    stows.lassoSelectTape.value = true;
    stows.selectionRectMode.value = false;
    Select.currentSelect.unselect();
  });

  group('Empirical Stress: Handwriting-Only Lasso Over Media', () {
    test('handwriting-only lasso over image leaves image strictly stationary after selection shift', () {
      final select = Select.currentSelect;
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = false;

      // Draw a lasso polygon covering (0,0) to (100,100)
      select.onDragStart(Offset.zero, 0);
      select.onDragUpdate(const Offset(0, 100));
      select.onDragUpdate(const Offset(100, 100));
      select.onDragUpdate(const Offset(100, 0));

      const page = HasSize(Size(200, 200));
      final stroke = Stroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(size: 5),
        pageIndex: 0,
        page: page,
        toolId: ToolId.fountainPen,
      )..addPoint(const Offset(40, 40));

      const originalImageRect = Rect.fromLTWH(10, 10, 80, 80);
      final image = StressTestImage(dstRect: originalImageRect);

      select.onDragEnd([stroke], [image]);

      // Assert selection results
      expect(select.selectResult.strokes, contains(stroke));
      expect(select.selectResult.images, isEmpty);
      expect(select.selectResult.textSelected, isFalse);

      // Perform selection shift (mirroring editor.dart lines 969-974)
      const shiftVector = Offset(25.5, -42.25);
      for (final s in select.selectResult.strokes) {
        s.shift(shiftVector);
      }
      for (final img in select.selectResult.images) {
        img.dstRect = img.dstRect.shift(shiftVector);
      }

      // Stroke must have moved
      expect(stroke.points.first.x, closeTo(40 + shiftVector.dx, 0.001));
      expect(stroke.points.first.y, closeTo(40 + shiftVector.dy, 0.001));

      // Image dstRect MUST remain 100% unchanged
      expect(image.dstRect, equals(originalImageRect));
      expect(image.dstRect.left, equals(10.0));
      expect(image.dstRect.top, equals(10.0));
      expect(image.dstRect.width, equals(80.0));
      expect(image.dstRect.height, equals(80.0));
    });

    test('multi-stroke handwriting over multi-image canvas isolates image positions through cumulative shifts', () {
      final select = Select.currentSelect;
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = false;

      select.onDragStart(Offset.zero, 0);
      select.onDragUpdate(const Offset(0, 120));
      select.onDragUpdate(const Offset(120, 120));
      select.onDragUpdate(const Offset(120, 0));

      const page = HasSize(Size(200, 200));
      final stroke1 = Stroke(
        color: Colors.red,
        pressureEnabled: false,
        options: StrokeOptions(size: 4),
        pageIndex: 0,
        page: page,
        toolId: ToolId.fountainPen,
      )..addPoint(const Offset(20, 20));

      final stroke2 = Stroke(
        color: Colors.green,
        pressureEnabled: false,
        options: StrokeOptions(size: 4),
        pageIndex: 0,
        page: page,
        toolId: ToolId.highlighter,
      )..addPoint(const Offset(50, 50));

      const imgRect1 = Rect.fromLTWH(5, 5, 40, 40);
      const imgRect2 = Rect.fromLTWH(45, 45, 50, 50);
      final img1 = StressTestImage(dstRect: imgRect1);
      final img2 = StressTestImage(dstRect: imgRect2);

      select.onDragEnd([stroke1, stroke2], [img1, img2]);

      expect(select.selectResult.strokes.length, equals(2));
      expect(select.selectResult.images, isEmpty);

      // Simulate 5 successive drag-shift frames
      const frameDelta = Offset(3.0, 7.0);
      for (int frame = 0; frame < 5; frame++) {
        for (final s in select.selectResult.strokes) {
          s.shift(frameDelta);
        }
        for (final img in select.selectResult.images) {
          img.dstRect = img.dstRect.shift(frameDelta);
        }
      }

      // Both images remain strictly stationary
      expect(img1.dstRect, equals(imgRect1));
      expect(img2.dstRect, equals(imgRect2));

      // Both strokes shifted by cumulative Offset(15.0, 35.0)
      expect(stroke1.points.first.x, closeTo(20 + 15.0, 0.001));
      expect(stroke1.points.first.y, closeTo(20 + 35.0, 0.001));
      expect(stroke2.points.first.x, closeTo(50 + 15.0, 0.001));
      expect(stroke2.points.first.y, closeTo(50 + 35.0, 0.001));
    });
  });

  group('Empirical Stress: Image-Only Lasso Over Handwriting', () {
    test('image-only lasso over handwriting leaves stroke coordinates strictly stationary after selection shift', () {
      final select = Select.currentSelect;
      stows.lassoSelectHandwriting.value = false;
      stows.lassoSelectImages.value = true;
      stows.lassoSelectText.value = false;

      select.onDragStart(Offset.zero, 0);
      select.onDragUpdate(const Offset(0, 100));
      select.onDragUpdate(const Offset(100, 100));
      select.onDragUpdate(const Offset(100, 0));

      const page = HasSize(Size(200, 200));
      final stroke = Stroke(
        color: Colors.purple,
        pressureEnabled: false,
        options: StrokeOptions(size: 6),
        pageIndex: 0,
        page: page,
        toolId: ToolId.fountainPen,
      )..addPoint(const Offset(35, 35));

      const initialImageRect = Rect.fromLTWH(15, 15, 70, 70);
      final image = StressTestImage(dstRect: initialImageRect);

      select.onDragEnd([stroke], [image]);

      // Assert selection results: only image selected
      expect(select.selectResult.images, contains(image));
      expect(select.selectResult.strokes, isEmpty);
      expect(select.selectResult.textSelected, isFalse);

      // Perform selection shift
      const shiftVector = Offset(60, -25);
      for (final s in select.selectResult.strokes) {
        s.shift(shiftVector);
      }
      for (final img in select.selectResult.images) {
        img.dstRect = img.dstRect.shift(shiftVector);
      }

      // Image moved
      expect(image.dstRect, equals(initialImageRect.shift(shiftVector)));

      // Stroke coordinates strictly stationary
      expect(stroke.points.first.x, equals(35.0));
      expect(stroke.points.first.y, equals(35.0));
    });

    test('multiple images move while multiple strokes remain untouched', () {
      final select = Select.currentSelect;
      stows.lassoSelectHandwriting.value = false;
      stows.lassoSelectImages.value = true;
      stows.lassoSelectText.value = false;

      select.onDragStart(Offset.zero, 0);
      select.onDragUpdate(const Offset(0, 150));
      select.onDragUpdate(const Offset(150, 150));
      select.onDragUpdate(const Offset(150, 0));

      const page = HasSize(Size(200, 200));
      final strokes = List.generate(
        3,
        (i) => Stroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(),
          pageIndex: 0,
          page: page,
          toolId: ToolId.fountainPen,
        )..addPoint(Offset(20.0 + i * 20.0, 20.0 + i * 20.0)),
      );

      final img1 = StressTestImage(dstRect: const Rect.fromLTWH(10, 10, 40, 40));
      final img2 = StressTestImage(dstRect: const Rect.fromLTWH(60, 60, 50, 50));

      select.onDragEnd(strokes, [img1, img2]);

      expect(select.selectResult.images.length, equals(2));
      expect(select.selectResult.strokes, isEmpty);

      const shift = Offset(-18.5, 33.2);
      for (final img in select.selectResult.images) {
        img.dstRect = img.dstRect.shift(shift);
      }

      // Strokes remain untouched
      for (int i = 0; i < strokes.length; i++) {
        expect(strokes[i].points.first.x, equals(20.0 + i * 20.0));
        expect(strokes[i].points.first.y, equals(20.0 + i * 20.0));
      }

      // Images shifted
      expect(img1.dstRect.left, closeTo(10 - 18.5, 0.001));
      expect(img2.dstRect.left, closeTo(60 - 18.5, 0.001));
    });
  });

  group('Empirical Stress: Text-Only Lasso Over Strokes and Images', () {
    test('text-only lasso over strokes and images selects only text without touching strokes or images', () {
      final select = Select.currentSelect;
      stows.lassoSelectHandwriting.value = false;
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = true;

      select.onDragStart(Offset.zero, 0);
      select.onDragUpdate(const Offset(0, 100));
      select.onDragUpdate(const Offset(100, 100));
      select.onDragUpdate(const Offset(100, 0));

      const page = HasSize(Size(200, 200));
      final stroke = Stroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: page,
        toolId: ToolId.fountainPen,
      )..addPoint(const Offset(50, 50));
      final image = StressTestImage(dstRect: const Rect.fromLTWH(20, 20, 60, 60));
      const textRect = Rect.fromLTWH(15, 15, 70, 70);

      select.onDragEnd([stroke], [image], textRect: textRect);

      expect(select.selectResult.textSelected, isTrue);
      expect(select.selectResult.strokes, isEmpty);
      expect(select.selectResult.images, isEmpty);

      // Moving selection affects neither strokes nor images
      const shift = Offset(10, 10);
      for (final s in select.selectResult.strokes) {
        s.shift(shift);
      }
      for (final img in select.selectResult.images) {
        img.dstRect = img.dstRect.shift(shift);
      }

      expect(stroke.points.first.x, equals(50.0));
      expect(image.dstRect, equals(const Rect.fromLTWH(20, 20, 60, 60)));
    });
  });

  group('Empirical Stress: Tap-Select Behavior Across Filter Combinations', () {
    const page = HasSize(Size(200, 200));

    test('co-located stroke, image, and text respects toggle truth table', () {
      final select = Select.currentSelect;
      const tapPoint = Offset(50, 50);

      final stroke = Stroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: page,
        toolId: ToolId.fountainPen,
      )..addPoint(tapPoint);

      final image = StressTestImage(dstRect: const Rect.fromLTWH(30, 30, 40, 40));
      const textRect = Rect.fromLTWH(20, 20, 60, 60);

      // 1. All enabled -> stroke takes precedence
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = true;
      stows.lassoSelectText.value = true;
      select.tapSelect(tapPoint, [stroke], [image], 0, textRect: textRect);
      expect(select.selectResult.strokes, contains(stroke));
      expect(select.selectResult.images, isEmpty);
      expect(select.selectResult.textSelected, isFalse);
      expect(select.doneSelecting, isTrue);

      // 2. Handwriting disabled, Image enabled -> image selected
      stows.lassoSelectHandwriting.value = false;
      stows.lassoSelectImages.value = true;
      stows.lassoSelectText.value = true;
      select.tapSelect(tapPoint, [stroke], [image], 0, textRect: textRect);
      expect(select.selectResult.strokes, isEmpty);
      expect(select.selectResult.images, contains(image));
      expect(select.selectResult.textSelected, isFalse);
      expect(select.doneSelecting, isTrue);

      // 3. Handwriting & Image disabled, Text enabled -> text selected
      stows.lassoSelectHandwriting.value = false;
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = true;
      select.tapSelect(tapPoint, [stroke], [image], 0, textRect: textRect);
      expect(select.selectResult.strokes, isEmpty);
      expect(select.selectResult.images, isEmpty);
      expect(select.selectResult.textSelected, isTrue);
      expect(select.doneSelecting, isTrue);

      // 4. Handwriting & Text enabled, Image disabled -> stroke selected
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = true;
      select.tapSelect(tapPoint, [stroke], [image], 0, textRect: textRect);
      expect(select.selectResult.strokes, contains(stroke));
      expect(select.selectResult.images, isEmpty);
      expect(select.selectResult.textSelected, isFalse);
      expect(select.doneSelecting, isTrue);
    });

    test('tap on image without stroke falls back to text when image filter is off', () {
      final select = Select.currentSelect;
      const tapPoint = Offset(45, 45);

      final image = StressTestImage(dstRect: const Rect.fromLTWH(30, 30, 30, 30));
      const textRect = Rect.fromLTWH(10, 10, 80, 80);

      // Images disabled, text enabled
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = true;

      select.tapSelect(tapPoint, const [], [image], 0, textRect: textRect);
      expect(select.selectResult.images, isEmpty);
      expect(select.selectResult.textSelected, isTrue);
      expect(select.doneSelecting, isTrue);

      // Both images and text disabled -> unselect
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = false;
      stows.lassoSelectHandwriting.value = true;

      select.tapSelect(tapPoint, const [], [image], 0, textRect: textRect);
      expect(select.selectResult.isEmpty, isTrue);
      expect(select.doneSelecting, isFalse);
    });

    test('tap on ArrowStroke respects handwriting filter toggle', () {
      final select = Select.currentSelect;
      const p1 = Offset(10, 10);
      const p2 = Offset(90, 90);

      final arrow = ArrowStroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: page,
        toolId: ToolId.arrow,
        start: p1,
        end: p2,
      );

      final image = StressTestImage(dstRect: const Rect.fromLTWH(0, 0, 100, 100));

      // With handwriting enabled, tapping on arrow segment selects arrow
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = true;
      select.tapSelect(const Offset(50, 50), [arrow], [image], 0);
      expect(select.selectResult.strokes, contains(arrow));
      expect(select.selectResult.images, isEmpty);

      // With handwriting disabled, tapping on arrow segment selects underlying image
      stows.lassoSelectHandwriting.value = false;
      stows.lassoSelectImages.value = true;
      select.tapSelect(const Offset(50, 50), [arrow], [image], 0);
      expect(select.selectResult.strokes, isEmpty);
      expect(select.selectResult.images, contains(image));
    });
  });

  group('Empirical Stress: Toggle-Off Safety Guard (Widget & Invariant)', () {
    testWidgets('guard prevents disabling the last active toggle across all single-active permutations', (tester) async {
      // Permutation 1: only Handwriting is true
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = false;
      stows.lassoSelectTape.value = false;

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LassoFilterPopup())),
      );
      final hwTile = find.widgetWithText(AdaptiveSwitchListTile, 'Handwriting');
      await tester.tap(hwTile);
      await tester.pumpAndSettle();
      expect(stows.lassoSelectHandwriting.value, isTrue, reason: 'Handwriting must not be disabled when it is the sole active filter');

      // Permutation 2: only Images is true
      stows.lassoSelectHandwriting.value = false;
      stows.lassoSelectImages.value = true;
      stows.lassoSelectText.value = false;
      stows.lassoSelectTape.value = false;

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LassoFilterPopup())),
      );
      final imgTile = find.widgetWithText(AdaptiveSwitchListTile, 'Images');
      await tester.tap(imgTile);
      await tester.pumpAndSettle();
      expect(stows.lassoSelectImages.value, isTrue, reason: 'Images must not be disabled when it is the sole active filter');

      // Permutation 3: only Text is true
      stows.lassoSelectHandwriting.value = false;
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = true;
      stows.lassoSelectTape.value = false;

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LassoFilterPopup())),
      );
      final txtTile = find.widgetWithText(AdaptiveSwitchListTile, 'Text Boxes');
      await tester.tap(txtTile);
      await tester.pumpAndSettle();
      expect(stows.lassoSelectText.value, isTrue, reason: 'Text Boxes must not be disabled when it is the sole active filter');

      // Permutation 4: only Study Tape is true
      stows.lassoSelectHandwriting.value = false;
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = false;
      stows.lassoSelectTape.value = true;

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LassoFilterPopup())),
      );
      final tapeTile = find.widgetWithText(AdaptiveSwitchListTile, 'Study Tape');
      await tester.ensureVisible(tapeTile);
      await tester.tap(tapeTile);
      await tester.pumpAndSettle();
      expect(stows.lassoSelectTape.value, isTrue, reason: 'Study Tape must not be disabled when it is the sole active filter');
    });

    testWidgets('sequential toggling sequence 4 -> 3 -> 2 -> 1 blocks at 1', (tester) async {
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = true;
      stows.lassoSelectText.value = true;
      stows.lassoSelectTape.value = true;

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LassoFilterPopup())),
      );

      // Disable handwriting (4 -> 3)
      await tester.tap(find.widgetWithText(AdaptiveSwitchListTile, 'Handwriting'));
      await tester.pumpAndSettle();
      expect(stows.lassoSelectHandwriting.value, isFalse);

      // Disable text (3 -> 2)
      await tester.tap(find.widgetWithText(AdaptiveSwitchListTile, 'Text Boxes'));
      await tester.pumpAndSettle();
      expect(stows.lassoSelectText.value, isFalse);

      // Disable study tape (2 -> 1)
      final tapeFinder = find.widgetWithText(AdaptiveSwitchListTile, 'Study Tape');
      await tester.ensureVisible(tapeFinder);
      await tester.tap(tapeFinder);
      await tester.pumpAndSettle();
      expect(stows.lassoSelectTape.value, isFalse);
      expect(stows.lassoSelectImages.value, isTrue);

      // Attempt to disable images (1 -> 0) -> MUST FAIL / BE BLOCKED
      await tester.tap(find.widgetWithText(AdaptiveSwitchListTile, 'Images'));
      await tester.pumpAndSettle();
      expect(stows.lassoSelectImages.value, isTrue);
    });
  });

  group('Empirical Stress: Dynamic Selection Pruning (pruneDisabledFilters)', () {
    const page = HasSize(Size(200, 200));

    test('prunes handwriting while preserving images and text', () {
      final select = Select.currentSelect;
      final stroke = Stroke(
        color: Colors.blue,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: page,
        toolId: ToolId.fountainPen,
      )..addPoint(const Offset(10, 10));
      final image = StressTestImage(dstRect: const Rect.fromLTWH(0, 0, 50, 50));

      select.selectResult = SelectResult(
        pageIndex: 0,
        strokes: [stroke],
        images: [image],
        textSelected: true,
        path: Path(),
      );
      select.doneSelecting = true;

      // Flip handwriting off
      stows.lassoSelectHandwriting.value = false;
      select.pruneDisabledFilters();

      expect(select.selectResult.strokes, isEmpty);
      expect(select.selectResult.images, contains(image));
      expect(select.selectResult.textSelected, isTrue);
      expect(select.doneSelecting, isTrue);
    });

    test('prunes images, resets cropMode, preserves stroke', () {
      final select = Select.currentSelect;
      final stroke = Stroke(
        color: Colors.red,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: page,
        toolId: ToolId.fountainPen,
      )..addPoint(const Offset(10, 10));
      final image = StressTestImage(dstRect: const Rect.fromLTWH(0, 0, 50, 50))..cropMode = true;

      select.selectResult = SelectResult(
        pageIndex: 0,
        strokes: [stroke],
        images: [image],
        path: Path(),
      );
      select.doneSelecting = true;

      // Flip images off
      stows.lassoSelectImages.value = false;
      select.pruneDisabledFilters();

      expect(select.selectResult.images, isEmpty);
      expect(image.cropMode, isFalse, reason: 'cropMode must be cleared when image is pruned');
      expect(select.selectResult.strokes, contains(stroke));
      expect(select.doneSelecting, isTrue);
    });

    test('pruning all elements calls unselect resetting doneSelecting and pageIndex', () {
      final select = Select.currentSelect;
      final image = StressTestImage(dstRect: const Rect.fromLTWH(0, 0, 50, 50));

      select.selectResult = SelectResult(
        pageIndex: 3,
        strokes: const [],
        images: [image],
        path: Path(),
      );
      select.doneSelecting = true;

      stows.lassoSelectImages.value = false;
      select.pruneDisabledFilters();

      expect(select.selectResult.isEmpty, isTrue);
      expect(select.doneSelecting, isFalse);
      expect(select.selectResult.pageIndex, equals(-1));
    });

    test('pruneDisabledFilters is no-op when doneSelecting is false', () {
      final select = Select.currentSelect;
      select.doneSelecting = false;
      select.selectResult = SelectResult(
        pageIndex: 1,
        strokes: const [],
        images: const [],
        path: Path(),
      );

      stows.lassoSelectHandwriting.value = false;
      expect(() => select.pruneDisabledFilters(), returnsNormally);
      expect(select.doneSelecting, isFalse);
    });

    testWidgets('LassoFilterPopup dynamically prunes multi-selection upon switch tap', (tester) async {
      final select = Select.currentSelect;
      final stroke = Stroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: page,
        toolId: ToolId.fountainPen,
      )..addPoint(const Offset(5, 5));
      final image = StressTestImage(dstRect: const Rect.fromLTWH(0, 0, 20, 20));

      select.selectResult = SelectResult(
        pageIndex: 0,
        strokes: [stroke],
        images: [image],
        path: Path(),
      );
      select.doneSelecting = true;

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LassoFilterPopup())),
      );

      // Tap Handwriting tile in popup
      final hwTile = find.widgetWithText(AdaptiveSwitchListTile, 'Handwriting');
      await tester.tap(hwTile);
      await tester.pumpAndSettle();

      // Verify that strokes are pruned in real time while images remain
      expect(stows.lassoSelectHandwriting.value, isFalse);
      expect(select.selectResult.strokes, isEmpty);
      expect(select.selectResult.images, contains(image));
      expect(select.doneSelecting, isTrue);
    });
  });

  group('Empirical Stress: Rectangle Selection Mode with Filters', () {
    test('rectangle selection mode obeys filter stows', () {
      final select = Select.currentSelect;
      stows.selectionRectMode.value = true;
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = false;

      // Drag rectangle from (0,0) to (100,100)
      select.onDragStart(Offset.zero, 0);
      select.onDragUpdate(const Offset(100, 100));

      const page = HasSize(Size(200, 200));
      final stroke = Stroke(
        color: Colors.black,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: page,
        toolId: ToolId.fountainPen,
      )..addPoint(const Offset(50, 50));
      final image = StressTestImage(dstRect: const Rect.fromLTWH(20, 20, 40, 40));

      select.onDragEnd([stroke], [image]);

      expect(select.selectResult.strokes, contains(stroke));
      expect(select.selectResult.images, isEmpty);
    });
  });
}

// ignore: missing_override_of_must_be_overridden
class StressTestImage extends PngEditorImage {
  static final _assetCache = AssetCache();

  StressTestImage({required super.dstRect})
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
  Future<void> firstLoad() async {
    // no-op for tests
  }
}
