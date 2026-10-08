/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/editor/selection_clipboard.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/select.dart';
import 'package:sbn/has_size.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(FlavorConfig.setup);

  group('SelectionClipboard.pasteOnto', () {
    test('adds shifted copies of the strokes to the target page', () {
      final original = _stroke(const [Offset(10, 50), Offset(20, 60)]);
      final clipboard = SelectionClipboard.copyOf(_selection([original], []));
      final page = EditorPage();

      final item = _paste(clipboard, page, pageIndex: 2);

      expect(page.strokes, hasLength(1));
      final pasted = page.strokes.single;
      expect(pasted, isNot(same(original)));
      expect(
        pasted.firstPoint,
        const Offset(10, 50) + SelectionClipboard.pasteOffset,
      );
      expect(pasted.pageIndex, 2, reason: 'Pasted onto an empty third page');
      expect(item.pageIndex, 2);
    });

    test('shifts pasted images and gives them a new id and page', () {
      const copiedFrom = Rect.fromLTWH(40, 80, 100, 50);
      final clipboard = SelectionClipboard.copyOf(
        _selection([], [_TestImage(dstRect: copiedFrom)]),
      );
      final page = EditorPage();

      _paste(clipboard, page, pageIndex: 1, firstImageId: 7);

      final pasted = page.images.single;
      expect(pasted.dstRect, copiedFrom.shift(SelectionClipboard.pasteOffset));
      expect(pasted.id, 7);
      expect(pasted.pageIndex, 1);
    });

    test('records the pasted copies so that undo can remove them', () {
      final clipboard = SelectionClipboard.copyOf(
        _selection(
          [
            _stroke(const [Offset(1, 2)]),
          ],
          [_TestImage(dstRect: const Rect.fromLTWH(0, 0, 10, 10))],
        ),
      );
      final page = EditorPage();

      final item = _paste(clipboard, page, pageIndex: 0);

      expect(item.type, EditorHistoryItemType.draw);
      expect(item.strokes.single, same(page.strokes.single));
      expect(item.images.single, same(page.images.single));
      expect(item.strokes.single, isNot(same(clipboard.strokes.single)));
      expect(item.images.single, isNot(same(clipboard.images.single)));
    });

    test('can paste the same clipboard more than once', () {
      final clipboard = SelectionClipboard.copyOf(
        _selection([
          _stroke(const [Offset(1, 2)]),
        ], []),
      );
      final page = EditorPage();

      final first = _paste(clipboard, page, pageIndex: 0);
      final second = _paste(clipboard, page, pageIndex: 0);

      expect(page.strokes, hasLength(2));
      expect(first.strokes.single, isNot(same(second.strokes.single)));
    });

    test('uses the given offset instead of the default', () {
      const copiedFrom = Rect.fromLTWH(40, 80, 100, 50);
      const offset = Offset(25, -25);
      final clipboard = SelectionClipboard.copyOf(
        _selection([], [_TestImage(dstRect: copiedFrom)]),
      );
      final page = EditorPage();

      _paste(clipboard, page, pageIndex: 0, offset: offset);

      expect(page.images.single.dstRect, copiedFrom.shift(offset));
    });
  });

  test('SelectionClipboard.isEmpty reflects its contents', () {
    expect(SelectionClipboard.copyOf(_selection([], [])).isEmpty, isTrue);
    expect(
      SelectionClipboard.copyOf(
        _selection([
          _stroke(const [Offset(1, 2)]),
        ], []),
      ).isEmpty,
      isFalse,
    );
  });
}

EditorHistoryItem _paste(
  SelectionClipboard clipboard,
  EditorPage page, {
  required int pageIndex,
  int firstImageId = 100,
  Offset offset = SelectionClipboard.pasteOffset,
}) {
  var nextImageId = firstImageId;
  return clipboard.pasteOnto(
    page,
    pageIndex: pageIndex,
    takeImageId: () => nextImageId++,
    offset: offset,
  );
}

SelectResult _selection(List<Stroke> strokes, List<EditorImage> images) =>
    SelectResult(pageIndex: 0, strokes: strokes, images: images, path: Path());

Stroke _stroke(List<Offset> points) {
  final stroke = Stroke(
    color: Stroke.defaultColor,
    pressureEnabled: false,
    options: StrokeOptions(),
    pageIndex: 0,
    page: const HasSize(Size(1000, 1400)),
    toolId: .fountainPen,
  );
  points.forEach(stroke.addPoint);
  return stroke;
}

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
