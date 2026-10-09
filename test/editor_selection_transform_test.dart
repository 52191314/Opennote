/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';

import 'utils/test_mock_channel_handlers.dart';

const _start = Offset(100, 200);
const _end = Offset(200, 250);

void main() {
  testGoldens('Editor: resizing a selection follows the pointer and undoes', (
    tester,
  ) async {
    final editorState = await _pumpEditor(tester);
    final page = editorState.coreInfo.pages.first;
    final bounds = await _selectNewStroke(tester, editorState, page);
    page.selectionResizeHandles = [
      bounds.topLeft,
      bounds.topCenter,
      bounds.topRight,
      bounds.centerRight,
      bounds.bottomRight,
      bounds.bottomCenter,
      bounds.bottomLeft,
      bounds.centerLeft,
    ];

    await _drag(
      tester,
      editorState,
      page,
      from: bounds.bottomRight,
      to: [
        bounds.bottomRight + const Offset(20, 10),
        bounds.bottomRight + const Offset(40, 20),
        bounds.bottomRight + const Offset(60, 30),
        bounds.bottomRight + Offset(bounds.width, bounds.height),
      ],
    );

    final doubled = Offset(
      bounds.left + (_end.dx - bounds.left) * 2,
      bounds.top + (_end.dy - bounds.top) * 2,
    );
    expect(
      page.strokes.single.points.last.x,
      moreOrLessEquals(doubled.dx),
      reason: 'Dragging the handle by the bounds size should double the width',
    );
    expect(page.strokes.single.points.last.y, moreOrLessEquals(doubled.dy));

    editorState.undo();
    await tester.pump();

    expect(
      page.strokes,
      hasLength(1),
      reason: 'Undoing a resize should not delete the stroke',
    );
    expect(page.strokes.single.points.last.x, moreOrLessEquals(_end.dx));
    expect(page.strokes.single.points.last.y, moreOrLessEquals(_end.dy));

    editorState.redo();
    await tester.pump();

    expect(page.strokes, hasLength(1));
    expect(page.strokes.single.points.last.x, moreOrLessEquals(doubled.dx));
  });

  testGoldens('Editor: rotating a selection can be undone and redone', (
    tester,
  ) async {
    final editorState = await _pumpEditor(tester);
    final page = editorState.coreInfo.pages.first;
    final bounds = await _selectNewStroke(tester, editorState, page);
    final handle = bounds.topCenter - const Offset(0, 20);
    page.selectionRotationHandleCenter = handle;

    await _drag(
      tester,
      editorState,
      page,
      from: handle,
      to: [
        handle,
        bounds.center + const Offset(60, -60),
        bounds.center + const Offset(80, 5),
      ],
    );

    final rotatedEnd = page.strokes.single.points.last;
    expect(
      (Offset(rotatedEnd.x, rotatedEnd.y) - _end).distance,
      greaterThan(10),
      reason: 'The stroke should have rotated',
    );

    editorState.undo();
    await tester.pump();

    expect(
      page.strokes,
      hasLength(1),
      reason: 'Undoing a rotation should not delete the stroke',
    );
    expect(page.strokes.single.points.last.x, moreOrLessEquals(_end.dx));
    expect(page.strokes.single.points.last.y, moreOrLessEquals(_end.dy));

    editorState.redo();
    await tester.pump();

    expect(page.strokes.single.points.last.x, moreOrLessEquals(rotatedEnd.x));
    expect(page.strokes.single.points.last.y, moreOrLessEquals(rotatedEnd.y));
  });

  testGoldens('Editor: moving selected page text can be undone and redone', (
    tester,
  ) async {
    final editorState = await _pumpEditor(tester);
    final page = editorState.coreInfo.pages.first;
    final select = Select.currentSelect;
    editorState.currentTool = select;
    select.selectResult = SelectResult(
      pageIndex: 0,
      strokes: [],
      images: [],
      path: Path()..addRect(const Rect.fromLTWH(50, 50, 200, 100)),
      textSelected: true,
    );
    select.doneSelecting = true;

    await _drag(
      tester,
      editorState,
      page,
      from: const Offset(100, 100),
      to: const [Offset(110, 110), Offset(130, 140)],
    );

    _expectOffset(page.textContentOffset, const Offset(30, 40));

    editorState.undo();
    await tester.pump();

    _expectOffset(page.textContentOffset, Offset.zero);

    editorState.redo();
    await tester.pump();

    _expectOffset(page.textContentOffset, const Offset(30, 40));
  });

  testGoldens('Editor: touching a handle without dragging records nothing', (
    tester,
  ) async {
    final editorState = await _pumpEditor(tester);
    final page = editorState.coreInfo.pages.first;
    final bounds = await _selectNewStroke(tester, editorState, page);
    final handle = bounds.topCenter - const Offset(0, 20);
    page.selectionRotationHandleCenter = handle;

    await _drag(tester, editorState, page, from: handle, to: const []);

    expect(editorState.history.canUndo, isFalse);
    expect(page.strokes.single.points.last.x, moreOrLessEquals(_end.dx));
  });
}

void _expectOffset(Offset actual, Offset expected) {
  expect(actual.dx, moreOrLessEquals(expected.dx, epsilon: 1e-6));
  expect(actual.dy, moreOrLessEquals(expected.dy, epsilon: 1e-6));
}

Future<EditorState> _pumpEditor(WidgetTester tester) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupMockPathProvider();
  setupMockPrinting();
  FlavorConfig.setup();
  await tester.runAsync(FileManager.init);

  await tester.pumpWidget(
    TranslationProvider(
      child: ScreenshotApp(
        device: GoldenScreenshotDevices.androidPhone.device,
        home: Editor(),
      ),
    ),
  );

  await tester.pump();

  final editorState = tester.state<EditorState>(find.byType(Editor));
  addTearDown(editorState.cancelAutosaveAndMarkSaved);
  addTearDown(Select.currentSelect.unselect);
  return editorState;
}

/// Adds a stroke from [_start] to [_end] to [page] and selects it with the
/// Select tool. Returns the bounds of the selection.
Future<Rect> _selectNewStroke(
  WidgetTester tester,
  EditorState editorState,
  EditorPage page,
) async {
  final stroke =
      Stroke(
          color: Stroke.defaultColor,
          pressureEnabled: false,
          options: StrokeOptions(),
          pageIndex: 0,
          page: page,
          toolId: .fountainPen,
        )
        ..addPoint(_start)
        ..addPoint(_end);
  page.insertStroke(stroke);
  await tester.pump();

  final select = Select.currentSelect;
  editorState.currentTool = select;
  select.selectStrokes([stroke], 0);
  return select.selectResult.path.getBounds();
}

/// Puts the pointer down at [from] on [page], moves it through each of [to]
/// in turn, then lifts it. Positions are in page coordinates.
Future<void> _drag(
  WidgetTester tester,
  EditorState editorState,
  EditorPage page, {
  required Offset from,
  required List<Offset> to,
}) async {
  Offset global(Offset local) => page.renderBox!.localToGlobal(local);

  editorState.dragPageIndex = 0;
  editorState.onDrawStart(ScaleStartDetails(focalPoint: global(from)));
  for (final position in to) {
    editorState.onDrawUpdate(ScaleUpdateDetails(focalPoint: global(position)));
  }
  editorState.onDrawEnd(ScaleEndDetails());
  await tester.pump();
}
