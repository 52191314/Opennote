/// 🤖 Generated wholely or partially with Claude Code (Claude Sonnet 5.5)
library;

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/data/editor/canvas_mode_conversion.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:sbn/tool_id.dart';

Stroke strokeAt(EditorPage page, int pageIndex, Offset at) {
  final stroke = Stroke(
    color: const Color(0xFF000000),
    pressureEnabled: false,
    options: StrokeOptions(size: 4, isComplete: true),
    pageIndex: pageIndex,
    page: page,
    toolId: ToolId.ballpointPen,
  );
  stroke.addPoint(at);
  stroke.addPoint(at + const Offset(40, 10));
  stroke.addPoint(at + const Offset(80, 0));
  return stroke;
}

EditorImage imageAt(
  EditorCoreInfo coreInfo,
  EditorPage page,
  int pageIndex,
  Rect dstRect,
) {
  final image = SvgEditorImage(
    id: coreInfo.nextImageId++,
    svgString: '<svg height="100" width="100"></svg>',
    svgFile: null,
    pageIndex: pageIndex,
    pageSize: page.size,
    onMoveImage: null,
    onDeleteImage: null,
    onMiscChange: null,
    assetCache: coreInfo.assetCache,
  );
  image.dstRect = dstRect;
  return image;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('mergePagesIntoFirst', () {
    test('keeps strokes from later pages, stacked below the first page', () {
      final first = EditorPage(size: const Size(1000, 1400));
      final second = EditorPage(size: const Size(1000, 1400));
      first.insertStroke(strokeAt(first, 0, const Offset(100, 100)));
      final later = strokeAt(second, 1, const Offset(100, 100));
      second.insertStroke(later);
      final pages = [first, second];

      mergePagesIntoFirst(pages);

      expect(pages, [first]);
      expect(first.strokes, hasLength(2));
      expect(later.pageIndex, 0);
      expect(later.page, same(first));
      expect(later.firstPoint!.dy, 100 + 1400 + pageStackGap);
    });

    test('offsets accumulate over several pages of different heights', () {
      final a = EditorPage(size: const Size(1000, 500));
      final b = EditorPage(size: const Size(1000, 700));
      final c = EditorPage(size: const Size(1000, 300));
      final onC = strokeAt(c, 2, const Offset(10, 20));
      c.insertStroke(onC);
      a.insertStroke(strokeAt(a, 0, Offset.zero));
      b.insertStroke(strokeAt(b, 1, Offset.zero));

      mergePagesIntoFirst([a, b, c]);

      expect(onC.firstPoint!.dy, 20 + 500 + pageStackGap + 700 + pageStackGap);
    });

    test('moves images and offsets them like strokes', () {
      final coreInfo = EditorCoreInfo(filePath: '');
      final first = EditorPage(size: const Size(1000, 1400));
      final second = EditorPage(size: const Size(1000, 1400));
      final image = imageAt(
        coreInfo,
        second,
        1,
        const Rect.fromLTWH(50, 60, 200, 200),
      );
      second.images.add(image);

      mergePagesIntoFirst([first, second]);

      expect(first.images, [image]);
      expect(image.pageIndex, 0);
      expect(image.dstRect.top, 60 + 1400 + pageStackGap);
      expect(image.dstRect.left, 50);
    });

    test('turns a later page background image into a regular image', () {
      final coreInfo = EditorCoreInfo(filePath: '');
      final first = EditorPage(size: const Size(1000, 1400));
      final second = EditorPage(size: const Size(1000, 1400));
      final background = imageAt(
        coreInfo,
        second,
        1,
        const Rect.fromLTWH(0, 0, 1000, 1400),
      );
      second.backgroundImage = background;

      mergePagesIntoFirst([first, second]);

      expect(first.images, [background]);
      expect(background.dstRect.top, 1400 + pageStackGap);
    });

    test('appends typed text from later pages', () {
      final first = EditorPage();
      final second = EditorPage();
      first.quill.controller.document.insert(0, 'first page');
      second.quill.controller.document.insert(0, 'second page');

      mergePagesIntoFirst([first, second]);

      final text = first.quill.controller.document.toPlainText();
      expect(text, contains('first page'));
      expect(text, contains('second page'));
      expect(text.indexOf('first page'), lessThan(text.indexOf('second page')));
    });

    test('drops trailing empty pages and leaves a single page alone', () {
      final first = EditorPage();
      first.insertStroke(strokeAt(first, 0, const Offset(5, 5)));
      final pages = [first, EditorPage(), EditorPage()];

      mergePagesIntoFirst(pages);

      expect(pages, [first]);
      expect(first.strokes, hasLength(1));
      expect(first.strokes.single.firstPoint, const Offset(5, 5));

      mergePagesIntoFirst(pages);
      expect(pages, [first]);
    });

    test('creates a page when there are none', () {
      final pages = <EditorPage>[];
      mergePagesIntoFirst(pages);
      expect(pages, hasLength(1));
    });
  });

  group('fitFirstPageToContent', () {
    test('grows the page to contain content right of and below it', () {
      final page = EditorPage(size: const Size(1000, 1400));
      page.insertStroke(strokeAt(page, 0, const Offset(1800, 3000)));

      fitFirstPageToContent(page);

      final bounds = page.strokes.single.highQualityPath.getBounds();
      expect(page.size.width, greaterThanOrEqualTo(bounds.right));
      expect(page.size.height, greaterThanOrEqualTo(bounds.bottom));
    });

    test('shifts content that sits at negative coordinates onto the page', () {
      final page = EditorPage(size: const Size(1000, 1400));
      page.insertStroke(strokeAt(page, 0, const Offset(-300, -500)));
      page.insertStroke(strokeAt(page, 0, const Offset(200, 200)));

      fitFirstPageToContent(page);

      for (final stroke in page.strokes) {
        final bounds = stroke.highQualityPath.getBounds();
        expect(bounds.left, greaterThanOrEqualTo(0));
        expect(bounds.top, greaterThanOrEqualTo(0));
      }
    });

    test('keeps relative positions and does not shrink the page', () {
      final page = EditorPage(size: const Size(1000, 1400));
      final a = strokeAt(page, 0, const Offset(-100, -100));
      final b = strokeAt(page, 0, const Offset(300, 400));
      page.insertStroke(a);
      page.insertStroke(b);
      final dx = b.firstPoint!.dx - a.firstPoint!.dx;
      final dy = b.firstPoint!.dy - a.firstPoint!.dy;

      fitFirstPageToContent(page);

      expect(b.firstPoint!.dx - a.firstPoint!.dx, dx);
      expect(b.firstPoint!.dy - a.firstPoint!.dy, dy);
      expect(page.size.width, greaterThanOrEqualTo(1000));
      expect(page.size.height, greaterThanOrEqualTo(1400));
    });

    test('leaves content that already fits untouched', () {
      final page = EditorPage(size: const Size(1000, 1400));
      final stroke = strokeAt(page, 0, const Offset(100, 100));
      page.insertStroke(stroke);

      fitFirstPageToContent(page);

      expect(stroke.firstPoint, const Offset(100, 100));
      expect(page.size, const Size(1000, 1400));
    });
  });

  test('EditorHistory.clear empties undo and redo', () {
    final history = EditorHistory();
    history.recordChange(
      EditorHistoryItem(type: .draw, pageIndex: 0, strokes: [], images: []),
    );
    expect(history.canUndo, isTrue);

    history.clear();

    expect(history.canUndo, isFalse);
    expect(history.canRedo, isFalse);
  });
}
