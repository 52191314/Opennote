/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/editor/selection_transform.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/select.dart';
import 'package:sbn/has_size.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(FlavorConfig.setup);

  group('EditorPage.replaceStroke', () {
    test('keeps the layer and stacking order of the replaced stroke', () {
      final below = _stroke(const Offset(1, 1));
      final target = _stroke(const Offset(2, 2));
      final above = _stroke(const Offset(3, 3));
      final replacement = _stroke(const Offset(9, 9));
      final upperLayer = Layer(name: 'Upper', strokes: [below, target, above]);
      final page = EditorPage(
        layers: [
          Layer(name: 'Lower'),
          upperLayer,
        ],
      );

      expect(page.replaceStroke(target, replacement), isTrue);

      expect(upperLayer.strokes, [below, replacement, above]);
    });

    test('returns false when the stroke is not on the page', () {
      final page = EditorPage();

      expect(
        page.replaceStroke(
          _stroke(const Offset(1, 1)),
          _stroke(const Offset(2, 2)),
        ),
        isFalse,
      );
      expect(page.strokes, isEmpty);
    });
  });

  group('SelectionTransform', () {
    test('begin edits copies and leaves the originals untouched', () {
      final original = _stroke(const Offset(10, 20));
      final page = EditorPage(strokes: [original]);
      final selection = _selection([original], []);

      SelectionTransform.begin(page, selection);
      final live = selection.strokes.single;
      live.scaleAround(2, 2, Offset.zero);

      expect(live, isNot(same(original)));
      expect(page.strokes.single, same(live));
      expect(live.points.last.x, moreOrLessEquals(20));
      expect(original.points.last.x, moreOrLessEquals(10));
    });

    test('revert puts the original strokes and image positions back', () {
      const originalRect = Rect.fromLTWH(10, 10, 40, 40);
      final original = _stroke(const Offset(10, 20));
      final image = _TestImage(dstRect: originalRect);
      final page = EditorPage(strokes: [original], images: [image]);
      final selection = _selection([original], [image]);

      final transform = SelectionTransform.begin(page, selection);
      selection.strokes.single.rotateAround(pi / 2, Offset.zero);
      image.dstRect = const Rect.fromLTWH(100, 100, 80, 80);
      final item = transform.finish(pageIndex: 0);

      expect(item.type, EditorHistoryItemType.transform);

      SelectionTransform.revert(item, page);

      expect(page.strokes.single, same(original));
      expect(original.points.last.x, moreOrLessEquals(10));
      expect(original.points.last.y, moreOrLessEquals(20));
      expect(image.dstRect, originalRect);
    });

    test('reverting the reversed item redoes the transform', () {
      final original = _stroke(const Offset(10, 20));
      final image = _TestImage(dstRect: const Rect.fromLTWH(10, 10, 40, 40));
      final page = EditorPage(strokes: [original], images: [image]);
      final selection = _selection([original], [image]);

      final transform = SelectionTransform.begin(page, selection);
      final transformed = selection.strokes.single
        ..scaleAround(3, 3, Offset.zero);
      const movedRect = Rect.fromLTWH(100, 100, 80, 80);
      image.dstRect = movedRect;
      final item = transform.finish(pageIndex: 0);

      SelectionTransform.revert(item, page);
      SelectionTransform.revert(SelectionTransform.reversed(item), page);

      expect(page.strokes.single, same(transformed));
      expect(transformed.points.last.x, moreOrLessEquals(30));
      expect(image.dstRect, movedRect);
    });

    test('undoing an earlier draw still finds the stroke after a revert', () {
      final original = _stroke(const Offset(10, 20));
      final page = EditorPage(strokes: [original]);
      final selection = _selection([original], []);

      final transform = SelectionTransform.begin(page, selection);
      selection.strokes.single.scaleAround(2, 2, Offset.zero);
      SelectionTransform.revert(transform.finish(pageIndex: 0), page);

      expect(
        page.removeStroke(original),
        isTrue,
        reason: 'History items recorded before the transform refer to it',
      );
    });
  });
}

SelectResult _selection(List<Stroke> strokes, List<EditorImage> images) =>
    SelectResult(
      pageIndex: 0,
      strokes: List.of(strokes),
      images: List.of(images),
      path: Path(),
    );

/// A stroke from the origin to [end].
Stroke _stroke(Offset end) =>
    Stroke(
        color: Stroke.defaultColor,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: const HasSize(Size(1000, 1400)),
        toolId: .fountainPen,
      )
      ..addPoint(Offset.zero)
      ..addPoint(end);

// ignore: missing_override_of_must_be_overridden
class _TestImage extends PngEditorImage {
  static final _assetCache = AssetCache();

  _TestImage({required super.dstRect})
    : super(
        id: -1,
        extension: '.png',
        imageProvider: null,
        pageIndex: 0,
        pageSize: const Size(1000, 1400),
        onMoveImage: null,
        onDeleteImage: null,
        onMiscChange: null,
        assetCache: _assetCache,
      );

  @override
  Future<void> firstLoad() async {}
}
