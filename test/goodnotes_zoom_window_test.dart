/// 🤖 Generated wholely or partially with Grok 4.7
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/zoom_window_view.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/goodnotes_toolbar.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/editor/zoom_window.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/i18n/strings.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FlavorConfig.setup();
    LocaleSettings.setLocale(AppLocale.en);
    FileManager.documentsDirectory = Directory.systemTemp.path;
  });

  tearDown(() => Pen.currentStroke = null);

  group('Zoom window mapping and resize', () {
    late ZoomWindowController zoom;

    setUp(() {
      zoom = ZoomWindowController()
        ..openForPage(const Rect.fromLTWH(0, 0, 1000, 1400));
    });

    test('maps the window onto the zoom box on the visible page', () {
      expect(zoom.zoomBox.left, greaterThan(zoom.pageBounds.left));
      expect(zoom.zoomBox.top, greaterThan(zoom.pageBounds.top));
      expect(zoom.zoomBox.right, lessThanOrEqualTo(zoom.pageBounds.right));
      expect(zoom.zoomBox.bottom, lessThanOrEqualTo(zoom.pageBounds.bottom));

      expect(
        zoom.pagePointFor(zoom.windowRect.topLeft),
        _nearOffset(zoom.zoomBox.topLeft),
      );
      expect(
        zoom.pagePointFor(zoom.windowRect.bottomRight),
        _nearOffset(zoom.zoomBox.bottomRight),
      );
    });

    test('a smaller zoom box magnifies more', () {
      final spanBefore = zoom.pageDeltaForWindowDelta(
        Offset(zoom.windowRect.width, 0),
      );
      final magnificationBefore = zoom.magnificationX;
      final aspect = zoom.zoomBox.width / zoom.zoomBox.height;

      zoom.resizeCorner(const Offset(-60, -10));

      final spanAfter = zoom.pageDeltaForWindowDelta(
        Offset(zoom.windowRect.width, 0),
      );
      expect(zoom.zoomBox.width / zoom.zoomBox.height, closeTo(aspect, 1e-6));
      expect(zoom.zoomBox.width, lessThan(spanBefore.dx));
      expect(spanAfter.dx, lessThan(spanBefore.dx));
      expect(zoom.magnificationX, greaterThan(magnificationBefore));
      expect(
        zoom.pageDeltaForWindowDelta(const Offset(1, 0)).dx,
        lessThan(spanBefore.dx / zoom.windowRect.width),
      );
    });

    test(
      'corner resize keeps aspect and height resize changes only height',
      () {
        final width = zoom.zoomBox.width;
        final height = zoom.zoomBox.height;
        final aspect = width / height;

        zoom.resizeCorner(const Offset(40, 8));

        expect(zoom.zoomBox.width, greaterThan(width));
        expect(zoom.zoomBox.height, greaterThan(height));
        expect(zoom.zoomBox.width / zoom.zoomBox.height, closeTo(aspect, 1e-6));

        final widened = zoom.zoomBox.width;
        final raised = zoom.zoomBox.height;
        zoom.resizeHeight(28);

        expect(zoom.zoomBox.width, closeTo(widened, 1e-6));
        expect(zoom.zoomBox.height, closeTo(raised + 28, 1e-6));
        expect(
          (zoom.zoomBox.width / zoom.zoomBox.height - aspect).abs(),
          greaterThan(0.01),
        );
      },
    );

    test('moving the window leaves the magnified region unchanged', () {
      final box = zoom.zoomBox;
      final mapped = zoom.pagePointFor(zoom.windowRect.center);
      final window = zoom.windowRect;

      zoom.moveWindowBy(const Offset(30, 10));

      expect(zoom.zoomBox, box);
      expect(zoom.windowRect, window.shift(const Offset(30, 10)));
      expect(zoom.pagePointFor(zoom.windowRect.center), _nearOffset(mapped));

      zoom.moveZoomBoxBy(const Offset(15, 8));

      expect(zoom.windowRect, window.shift(const Offset(30, 10)));
      expect(
        zoom.zoomBox.topLeft,
        _nearOffset(box.topLeft + const Offset(15, 8)),
      );
    });
  });

  group('Zoom window auto-advance', () {
    late ZoomWindowController zoom;

    setUp(() {
      zoom = ZoomWindowController()
        ..openForPage(const Rect.fromLTWH(0, 0, 1000, 1400));
    });

    test('writing in the advance region moves the box forward', () {
      final left = zoom.zoomBox.left;
      final top = zoom.zoomBox.top;
      final window = zoom.windowRect;

      zoom.ingestPointer(
        Offset(window.left + 8, window.center.dy),
        strokeStart: true,
      );
      zoom.ingestPointer(
        Offset(window.right - 8, window.center.dy),
        strokeStart: false,
      );

      expect(zoom.advanceRegion, isNotNull);
      expect(zoom.advanceRegion!.left, closeTo(window.center.dx, 0.001));
      expect(zoom.advanceRegion!.right, closeTo(window.right, 0.001));
      expect(zoom.zoomBox.left, greaterThan(left));
      expect(zoom.zoomBox.top, closeTo(top, 0.001));
    });

    test('passing the right edge drops by the return height', () {
      zoom.returnHeight = 64;
      final slack = zoom.pageBounds.right - zoom.zoomBox.right;
      zoom.moveZoomBoxBy(Offset(slack - 4, 0));
      final lineStart = zoom.lineStartX;
      final top = zoom.zoomBox.top;
      final window = zoom.windowRect;

      zoom.ingestPointer(
        Offset(window.left + 8, window.center.dy),
        strokeStart: true,
      );
      zoom.ingestPointer(
        Offset(window.right - 8, window.center.dy),
        strokeStart: false,
      );

      expect(zoom.zoomBox.left, closeTo(lineStart, 0.001));
      expect(zoom.zoomBox.top, closeTo(top + zoom.returnHeight, 0.001));
    });

    test('auto-advance off stays put and new line uses the return height', () {
      zoom.autoAdvance = false;
      zoom.returnHeight = 40;
      final before = zoom.zoomBox;
      final window = zoom.windowRect;

      zoom.ingestPointer(
        Offset(window.left + 8, window.center.dy),
        strokeStart: true,
      );
      zoom.ingestPointer(
        Offset(window.right - 8, window.center.dy),
        strokeStart: false,
      );
      zoom.endStroke();

      expect(zoom.zoomBox, before);
      expect(zoom.advanceRegion, isNull);

      zoom.newLine();

      expect(zoom.zoomBox.left, closeTo(zoom.lineStartX, 0.001));
      expect(zoom.zoomBox.top, closeTo(before.top + 40, 0.001));
      expect(zoom.zoomBox.width, closeTo(before.width, 0.001));
      expect(zoom.zoomBox.height, closeTo(before.height, 0.001));
    });
  });

  group('Zoom window ink', () {
    test('a zoom stroke is a page stroke and one undo removes it', () {
      final page = EditorPage(size: const Size(1000, 1400));
      final history = EditorHistory();
      final zoom = ZoomWindowController()..openForPage(Offset.zero & page.size);
      final pen = Pen.currentPen;
      final ink = ZoomInk(
        zoom: zoom,
        pen: pen,
        page: page,
        pageIndex: 0,
        history: history,
      );

      final start = zoom.windowRect.topLeft + const Offset(20, 30);
      final next = start + const Offset(18, 3);
      final expectedStart = zoom.pagePointFor(start);
      final expectedNext = zoom.pagePointFor(next);

      final first = ink.commit([start, next]);
      final second = ink.commit([
        start + const Offset(4, 12),
        next + const Offset(4, 12),
      ]);

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(page.strokes, containsAll([first, second]));
      expect(first!.firstPoint, _nearOffset(expectedStart));
      expect(first.rawPoints[1].x, closeTo(expectedNext.dx, 0.001));
      expect(first.rawPoints[1].y, closeTo(expectedNext.dy, 0.001));
      expect(history.peekUndo().type, EditorHistoryItemType.draw);
      expect(history.peekUndo().strokes, [second]);

      final undone = ZoomInk.undoDraw(history, page);

      expect(undone.type, EditorHistoryItemType.draw);
      expect(undone.strokes, [second]);
      expect(page.strokes, [first]);
      expect(page.strokes, isNot(contains(second)));
    });
  });

  testWidgets('toolbar opens and dismisses the zoom window and page box', (
    tester,
  ) async {
    await tester.pumpWidget(const _ZoomHarness());

    expect(find.byKey(ZoomWindowKeys.window), findsNothing);
    expect(find.byKey(ZoomWindowKeys.pageBox), findsNothing);

    await tester.ensureVisible(find.byKey(ZoomWindowKeys.toolbarButton));
    await tester.tap(find.byKey(ZoomWindowKeys.toolbarButton));
    await tester.pump();

    expect(find.byKey(ZoomWindowKeys.window), findsOneWidget);
    expect(find.byKey(ZoomWindowKeys.pageBox), findsOneWidget);
    final box = tester.getRect(find.byKey(ZoomWindowKeys.pageBox));
    expect(box.left, greaterThan(0));
    expect(box.top, greaterThan(0));
    expect(box.width, greaterThan(24));
    expect(box.height, greaterThan(24));

    await tester.tap(find.byKey(ZoomWindowKeys.dismiss));
    await tester.pump();

    expect(find.byKey(ZoomWindowKeys.window), findsNothing);
    expect(find.byKey(ZoomWindowKeys.pageBox), findsNothing);
  });
}

Matcher _nearOffset(Offset expected) {
  return isA<Offset>()
      .having((offset) => offset.dx, 'dx', closeTo(expected.dx, 0.001))
      .having((offset) => offset.dy, 'dy', closeTo(expected.dy, 0.001));
}

class _ZoomHarness extends StatefulWidget {
  const _ZoomHarness();

  @override
  State<_ZoomHarness> createState() => _ZoomHarnessState();
}

class _ZoomHarnessState extends State<_ZoomHarness> {
  final _zoom = ZoomWindowController();
  final _page = EditorPage(size: const Size(1000, 1400));
  final _history = EditorHistory();
  var _open = false;

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            GoodnotesToolbar(
              actions: _toolbarActions(Pen.currentPen),
              zoomWindowOpen: _open,
              onToggleZoomWindow: () {
                setState(() {
                  _open = !_open;
                  if (_open) _zoom.openForPage(Offset.zero & _page.size);
                });
              },
            ),
            Expanded(
              child: ZoomWindowLayer(
                open: _open,
                controller: _zoom,
                page: _page,
                pageIndex: 0,
                history: _history,
                pen: () => Pen.currentPen,
                onDismiss: () => setState(() => _open = false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

EditorToolbarActions _toolbarActions(Tool currentTool) {
  return EditorToolbarActions(
    readOnly: false,
    setTool: (_) {},
    currentTool: currentTool,
    setColor: (_) {},
    quillFocus: ValueNotifier(null),
    textEditing: false,
    toggleTextEditing: () {},
    pickPhoto: () {},
    pickShape: () {},
    paste: () {},
    copySelection: () {},
    pasteSelection: () {},
    duplicateSelection: () {},
    deleteSelection: () {},
  );
}
