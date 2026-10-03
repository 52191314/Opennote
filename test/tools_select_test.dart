/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
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

  group('Select tool', () {
    test('selects the right strokes', () async {
      final select = Select.currentSelect;
      final options = StrokeOptions(size: 9);

      // Drag gesture in a 10x10 square shape, on page 0
      select.onDragStart(Offset.zero, 0);
      select.onDragUpdate(const Offset(0, 10));
      select.onDragUpdate(const Offset(10, 10));
      select.onDragUpdate(const Offset(10, 0));

      expect(
        select.selectResult.pageIndex,
        0,
        reason: 'The page index should be 0',
      );

      const page = HasSize(Size(100, 100));

      final strokes = <Stroke>[
        // index 0 is inside
        Stroke(
          color: Stroke.defaultColor,
          pressureEnabled: Stroke.defaultPressureEnabled,
          options: options,
          pageIndex: 0,
          page: page,
          toolId: .fountainPen,
        )..addPoint(const Offset(5, 5)),
        // index > 0 is outside
        Stroke(
          color: Stroke.defaultColor,
          pressureEnabled: Stroke.defaultPressureEnabled,
          options: options,
          pageIndex: 0,
          page: page,
          toolId: .fountainPen,
        )..addPoint(const Offset(10, 10)),
        Stroke(
          color: Stroke.defaultColor,
          pressureEnabled: Stroke.defaultPressureEnabled,
          options: options,
          pageIndex: 0,
          page: page,
          toolId: .fountainPen,
        )..addPoint(const Offset(15, 15)),
      ];

      select.onDragEnd(strokes, const []);

      expect(
        select.selectResult.strokes,
        hasLength(1),
        reason: 'Only one stroke should be selected',
      );
      expect(
        select.selectResult.strokes.first,
        strokes[0],
        reason: 'The first stroke should be selected',
      );
      expect(
        select.selectResult.images,
        isEmpty,
        reason: 'No images should be selected',
      );
    });

    test('selects the right images', () async {
      final select = Select.currentSelect;

      // Drag gesture in a 10x10 square shape, on page 0
      select.onDragStart(Offset.zero, 0);
      select.onDragUpdate(const Offset(0, 10));
      select.onDragUpdate(const Offset(10, 10));
      select.onDragUpdate(const Offset(10, 0));

      expect(
        select.selectResult.pageIndex,
        0,
        reason: 'The page index should be 0',
      );

      final List<EditorImage> images = [
        // index 0 is inside (100% in the selection)
        TestImage(dstRect: const .fromLTWH(0, 0, 10, 10)),
        // index 1 is inside (> 70% in the selection)
        TestImage(dstRect: const .fromLTWH(0, 0, 10 / 0.75, 10 / 0.75)),
        // index 2 is outside (< 70% in the selection)
        TestImage(dstRect: const .fromLTWH(0, 0, 10 / 0.6, 10 / 0.6)),
      ];

      select.onDragEnd(const [], images);

      expect(
        select.selectResult.images,
        hasLength(2),
        reason: 'Two images should be selected',
      );
      expect(
        select.selectResult.images,
        contains(images[0]),
        reason: 'The first image should be selected',
      );
      expect(
        select.selectResult.images,
        contains(images[1]),
        reason: 'The second image should be selected',
      );
      expect(
        select.selectResult.strokes,
        isEmpty,
        reason: 'No strokes should be selected',
      );
    });

    group('getDominantStrokeColor', () {
      test('not done selecting', () {
        final select = Select.currentSelect;
        select.unselect();
        expect(select.getDominantStrokeColor(), isNull);
      });

      test('with no selected strokes', () {
        final select = Select.currentSelect;
        select.selectResult = SelectResult(
          pageIndex: 0,
          strokes: const [],
          images: const [],
          path: Path(),
        );
        expect(select.getDominantStrokeColor(), isNull);
      });

      test('with selected strokes', () {
        final select = Select.currentSelect;
        select.selectResult = SelectResult(
          pageIndex: 0,
          strokes: [
            _strokeWithColor(Colors.red),
            _strokeWithColor(Colors.blue),
            _strokeWithColor(Colors.blue),
            _strokeWithColor(Colors.blue),
            _strokeWithColor(Colors.red),
          ],
          images: const [],
          path: Path(),
        );
        select.doneSelecting = true;
        expect(select.getDominantStrokeColor(), Colors.blue);
      });
    });

    group('Lasso filters onDragEnd', () {
      test('excludes images when lassoSelectImages is false', () async {
        final select = Select.currentSelect;
        stows.lassoSelectImages.value = false;
        stows.lassoSelectHandwriting.value = true;

        select.onDragStart(Offset.zero, 0);
        select.onDragUpdate(const Offset(0, 10));
        select.onDragUpdate(const Offset(10, 10));
        select.onDragUpdate(const Offset(10, 0));

        final testImage = TestImage(dstRect: const Rect.fromLTWH(0, 0, 10, 10));
        select.onDragEnd(const [], [testImage]);

        expect(select.selectResult.images, isEmpty);
      });

      test('excludes strokes when lassoSelectHandwriting is false', () async {
        final select = Select.currentSelect;
        stows.lassoSelectHandwriting.value = false;
        stows.lassoSelectImages.value = true;

        select.onDragStart(Offset.zero, 0);
        select.onDragUpdate(const Offset(0, 10));
        select.onDragUpdate(const Offset(10, 10));
        select.onDragUpdate(const Offset(10, 0));

        const page = HasSize(Size(100, 100));
        final options = StrokeOptions(size: 9);
        final stroke = Stroke(
          color: Stroke.defaultColor,
          pressureEnabled: Stroke.defaultPressureEnabled,
          options: options,
          pageIndex: 0,
          page: page,
          toolId: .fountainPen,
        )..addPoint(const Offset(5, 5));

        select.onDragEnd([stroke], const []);

        expect(select.selectResult.strokes, isEmpty);
      });

      test('excludes text when lassoSelectText is false', () async {
        final select = Select.currentSelect;
        stows.lassoSelectText.value = false;

        select.onDragStart(Offset.zero, 0);
        select.onDragUpdate(const Offset(0, 10));
        select.onDragUpdate(const Offset(10, 10));
        select.onDragUpdate(const Offset(10, 0));

        select.onDragEnd(const [], const [], textRect: const Rect.fromLTWH(0, 0, 10, 10));

        expect(select.selectResult.textSelected, isFalse);
      });

      test('selects text when lassoSelectText is true', () async {
        final select = Select.currentSelect;
        stows.lassoSelectText.value = true;

        select.onDragStart(Offset.zero, 0);
        select.onDragUpdate(const Offset(0, 10));
        select.onDragUpdate(const Offset(10, 10));
        select.onDragUpdate(const Offset(10, 0));

        select.onDragEnd(const [], const [], textRect: const Rect.fromLTWH(0, 0, 10, 10));

        expect(select.selectResult.textSelected, isTrue);
      });

      test('selects both strokes and images when both filters enabled', () async {
        final select = Select.currentSelect;
        stows.lassoSelectHandwriting.value = true;
        stows.lassoSelectImages.value = true;

        select.onDragStart(Offset.zero, 0);
        select.onDragUpdate(const Offset(0, 10));
        select.onDragUpdate(const Offset(10, 10));
        select.onDragUpdate(const Offset(10, 0));

        const page = HasSize(Size(100, 100));
        final options = StrokeOptions(size: 9);
        final stroke = Stroke(
          color: Stroke.defaultColor,
          pressureEnabled: Stroke.defaultPressureEnabled,
          options: options,
          pageIndex: 0,
          page: page,
          toolId: .fountainPen,
        )..addPoint(const Offset(5, 5));
        final image = TestImage(dstRect: const Rect.fromLTWH(0, 0, 10, 10));

        select.onDragEnd([stroke], [image]);

        expect(select.selectResult.strokes, hasLength(1));
        expect(select.selectResult.images, hasLength(1));
      });

      test('underlying image remains stationary when image filter disabled', () async {
        final select = Select.currentSelect;
        stows.lassoSelectImages.value = false;
        stows.lassoSelectHandwriting.value = true;

        select.onDragStart(Offset.zero, 0);
        select.onDragUpdate(const Offset(0, 100));
        select.onDragUpdate(const Offset(100, 100));
        select.onDragUpdate(const Offset(100, 0));

        const page = HasSize(Size(200, 200));
        final options = StrokeOptions(size: 9);
        final annotationStroke = Stroke(
          color: Colors.red,
          pressureEnabled: Stroke.defaultPressureEnabled,
          options: options,
          pageIndex: 0,
          page: page,
          toolId: .fountainPen,
        )..addPoint(const Offset(50, 50));
        const originalImageRect = Rect.fromLTWH(10, 10, 80, 80);
        final backgroundImage = TestImage(dstRect: originalImageRect);

        select.onDragEnd([annotationStroke], [backgroundImage]);

        expect(select.selectResult.strokes, contains(annotationStroke));
        expect(select.selectResult.images, isEmpty);

        // Simulate moving selection: only items in selectResult are moved
        const moveOffset = Offset(20, 30);
        for (final stroke in select.selectResult.strokes) {
          stroke.shift(moveOffset);
        }
        for (final image in select.selectResult.images) {
          image.dstRect = image.dstRect.shift(moveOffset);
        }

        // Image was not selected, so dstRect must remain 100% stationary
        expect(backgroundImage.dstRect, equals(originalImageRect));
      });
    });

    group('Lasso filters tapSelect', () {
      test('ignores image tap when lassoSelectImages is false', () {
        final select = Select.currentSelect;
        stows.lassoSelectImages.value = false;

        final image = TestImage(dstRect: const Rect.fromLTWH(20, 20, 50, 50));
        select.tapSelect(const Offset(30, 30), const [], [image], 0);

        expect(select.selectResult.images, isEmpty);
        expect(select.doneSelecting, isFalse);
      });

      test('selects image tap when lassoSelectImages is true', () {
        final select = Select.currentSelect;
        stows.lassoSelectImages.value = true;

        final image = TestImage(dstRect: const Rect.fromLTWH(20, 20, 50, 50));
        select.tapSelect(const Offset(30, 30), const [], [image], 0);

        expect(select.selectResult.images, contains(image));
        expect(select.doneSelecting, isTrue);
      });

      test('ignores stroke tap when lassoSelectHandwriting is false', () {
        final select = Select.currentSelect;
        stows.lassoSelectHandwriting.value = false;

        const page = HasSize(Size(100, 100));
        final stroke = Stroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(),
          pageIndex: 0,
          page: page,
          toolId: .fountainPen,
        )..addPoint(const Offset(10, 10));

        select.tapSelect(const Offset(10, 10), [stroke], const [], 0);

        expect(select.selectResult.strokes, isEmpty);
        expect(select.doneSelecting, isFalse);
      });

      test('selects stroke tap when lassoSelectHandwriting is true', () {
        final select = Select.currentSelect;
        stows.lassoSelectHandwriting.value = true;

        const page = HasSize(Size(100, 100));
        final stroke = Stroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(),
          pageIndex: 0,
          page: page,
          toolId: .fountainPen,
        )..addPoint(const Offset(10, 10));

        select.tapSelect(const Offset(10, 10), [stroke], const [], 0);

        expect(select.selectResult.strokes, contains(stroke));
        expect(select.doneSelecting, isTrue);
      });

      test('ignores text tap when lassoSelectText is false', () {
        final select = Select.currentSelect;
        stows.lassoSelectText.value = false;

        select.tapSelect(
          const Offset(25, 25),
          const [],
          const [],
          0,
          textRect: const Rect.fromLTWH(10, 10, 50, 50),
        );

        expect(select.selectResult.textSelected, isFalse);
        expect(select.doneSelecting, isFalse);
      });

      test('selects text tap when lassoSelectText is true', () {
        final select = Select.currentSelect;
        stows.lassoSelectText.value = true;

        select.tapSelect(
          const Offset(25, 25),
          const [],
          const [],
          0,
          textRect: const Rect.fromLTWH(10, 10, 50, 50),
        );

        expect(select.selectResult.textSelected, isTrue);
        expect(select.doneSelecting, isTrue);
      });
    });

    group('Lasso filters pruneDisabledFilters', () {
      test('prunes images when image filter toggled off', () {
        final select = Select.currentSelect;
        const page = HasSize(Size(100, 100));
        final stroke = Stroke(
          color: Colors.blue,
          pressureEnabled: false,
          options: StrokeOptions(),
          pageIndex: 0,
          page: page,
          toolId: .fountainPen,
        )..addPoint(const Offset(5, 5));
        final image = TestImage(dstRect: const Rect.fromLTWH(0, 0, 10, 10));

        select.selectResult = SelectResult(
          pageIndex: 0,
          strokes: [stroke],
          images: [image],
          path: Path(),
        );
        select.doneSelecting = true;

        stows.lassoSelectImages.value = false;
        select.pruneDisabledFilters();

        expect(select.selectResult.images, isEmpty);
        expect(select.selectResult.strokes, contains(stroke));
        expect(select.doneSelecting, isTrue);
      });

      test('unselects when all selected items are pruned', () {
        final select = Select.currentSelect;
        final image = TestImage(dstRect: const Rect.fromLTWH(0, 0, 10, 10));

        select.selectResult = SelectResult(
          pageIndex: 0,
          strokes: const [],
          images: [image],
          path: Path(),
        );
        select.doneSelecting = true;

        stows.lassoSelectImages.value = false;
        select.pruneDisabledFilters();

        expect(select.selectResult.isEmpty, isTrue);
        expect(select.doneSelecting, isFalse);
      });
    });
  });
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
        pageSize: const Size(100, 100),
        onMoveImage: null,
        onDeleteImage: null,
        onMiscChange: null,
        assetCache: _assetCache,
      );

  @override
  Future<void> firstLoad() async {
    // do nothing
  }
}

Stroke _strokeWithColor(Color color) {
  return Stroke(
    color: color,
    pressureEnabled: false,
    options: StrokeOptions(),
    pageIndex: 0,
    page: const HasSize(Size.zero),
    toolId: .fountainPen,
  );
}
