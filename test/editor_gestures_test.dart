/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';

import 'utils/test_mock_channel_handlers.dart';

const _start = Offset(100, 200);
const _end = Offset(200, 250);

void main() {
  group('Pen gesture', () {
    testGoldens('draws a stroke that undo removes', (tester) async {
      final editorState = await _pumpEditor(tester);
      final page = editorState.coreInfo.pages.first;
      editorState.currentTool = Pen.currentPen;

      _drag(
        editorState,
        page,
        from: _start,
        to: const [Offset(130, 240), Offset(170, 210), _end],
      );
      await tester.pump();

      expect(page.strokes, hasLength(1));
      expect(Pen.currentStroke, isNull);

      editorState.undo();
      await tester.pump();

      expect(page.strokes, isEmpty);
    });

    testGoldens('tapping tape toggles it instead of drawing', (tester) async {
      final editorState = await _pumpEditor(tester);
      final page = editorState.coreInfo.pages.first;
      final tape = TapeStroke(
        color: Stroke.defaultColor,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: page,
        toolId: .studyTape,
        rect: const Rect.fromLTWH(100, 100, 200, 40),
      );
      page.insertStroke(tape);
      editorState.currentTool = Pen.currentPen;

      _drag(
        editorState,
        page,
        from: const Offset(150, 120),
        to: const [Offset(151, 121)],
      );
      await tester.pump();

      expect(tape.isConcealed, isFalse);
      expect(page.strokes, [tape], reason: 'The tap should not leave a dot');
      expect(editorState.history.canUndo, isFalse);
    });

    testGoldens('scribbling over a stroke erases it', (tester) async {
      final previous = stows.scribbleToErase.value;
      stows.scribbleToErase.value = true;
      addTearDown(() => stows.scribbleToErase.value = previous);

      final editorState = await _pumpEditor(tester);
      final page = editorState.coreInfo.pages.first;
      final stroke = _insertStroke(page);
      editorState.currentTool = Pen.currentPen;

      _drag(
        editorState,
        page,
        from: const Offset(100, 225),
        to: [
          for (final pass in const [1, -1, 1, -1])
            for (var step = 1; step <= 10; step++)
              Offset(pass == 1 ? 100.0 + step * 10 : 200.0 - step * 10, 225),
        ],
      );
      await tester.pump();

      expect(page.strokes, isEmpty, reason: 'Nothing is drawn or left behind');
      expect(Pen.currentStroke, isNull);

      editorState.undo();
      await tester.pump();

      expect(page.strokes, [stroke]);
    });
  });

  group('Ruler gesture', () {
    testGoldens('draws a two-point line that undo removes', (tester) async {
      final editorState = await _pumpEditor(tester);
      final page = editorState.coreInfo.pages.first;
      editorState.currentTool = Ruler();

      _drag(
        editorState,
        page,
        from: _start,
        to: const [Offset(130, 240), Offset(170, 210), _end],
      );
      await tester.pump();

      expect(page.strokes.single.length, 2);

      editorState.undo();
      await tester.pump();

      expect(page.strokes, isEmpty);
    });
  });

  group('Eraser gesture', () {
    testGoldens('erases the strokes it crosses and undo restores them', (
      tester,
    ) async {
      final editorState = await _pumpEditor(tester);
      final page = editorState.coreInfo.pages.first;
      final stroke = _insertStroke(page);
      editorState.currentTool = Eraser();

      _drag(
        editorState,
        page,
        from: _start,
        to: const [Offset(150, 225), _end],
      );
      await tester.pump();

      expect(page.strokes, isEmpty);

      editorState.undo();
      await tester.pump();

      expect(page.strokes, [stroke]);
    });
  });

  group('Select gesture', () {
    testGoldens('dragging a selection moves it and undoes', (tester) async {
      final editorState = await _pumpEditor(tester);
      final page = editorState.coreInfo.pages.first;
      final stroke = _insertStroke(page);
      final bounds = _select(editorState, [stroke]);

      _drag(
        editorState,
        page,
        from: bounds.center,
        to: [
          bounds.center + const Offset(10, 10),
          bounds.center + const Offset(30, 40),
        ],
      );
      await tester.pump();

      _expectLastPoint(page.strokes.single, _end + const Offset(30, 40));
      _expectOffset(
        Select.currentSelect.selectResult.path.getBounds().center,
        bounds.center + const Offset(30, 40),
      );

      editorState.undo();
      await tester.pump();

      _expectLastPoint(page.strokes.single, _end);

      editorState.redo();
      await tester.pump();

      _expectLastPoint(page.strokes.single, _end + const Offset(30, 40));
    });

    testGoldens('tapping a stroke selects it and shows handles', (
      tester,
    ) async {
      final editorState = await _pumpEditor(tester);
      final page = editorState.coreInfo.pages.first;
      final stroke = _insertStroke(page);
      editorState.currentTool = Select.currentSelect;

      _drag(editorState, page, from: _start, to: const []);

      final select = Select.currentSelect;
      expect(select.doneSelecting, isTrue);
      expect(select.selectResult.strokes, [stroke]);
      expect(page.selectionResizeHandles, hasLength(8));
      expect(page.selectionRotationHandleCenter, isNotNull);
      expect(editorState.history.canUndo, isFalse);
      await tester.pump();
    });

    testGoldens('tapping empty space selects nothing', (tester) async {
      final editorState = await _pumpEditor(tester);
      final page = editorState.coreInfo.pages.first;
      _insertStroke(page);
      editorState.currentTool = Select.currentSelect;

      _drag(editorState, page, from: const Offset(300, 400), to: const []);

      final select = Select.currentSelect;
      expect(select.doneSelecting, isFalse);
      expect(select.selectResult.isEmpty, isTrue);
      expect(page.selectionResizeHandles, isNull);
      await tester.pump();
    });

    testGoldens('double-tapping a selection starts it afresh', (tester) async {
      final editorState = await _pumpEditor(tester);
      final page = editorState.coreInfo.pages.first;
      final stroke = _insertStroke(page);
      final select = Select.currentSelect;
      editorState.currentTool = select;

      _drag(editorState, page, from: _start, to: const []);
      select.isResizeActive = true;
      _drag(editorState, page, from: _start, to: const []);

      expect(select.isResizeActive, isFalse);
      expect(select.selectResult.strokes, [stroke]);
      await tester.pump();
    });

    testGoldens('tapping elsewhere inside a selection keeps it', (
      tester,
    ) async {
      final editorState = await _pumpEditor(tester);
      final page = editorState.coreInfo.pages.first;
      final stroke = _insertStroke(page);
      final select = Select.currentSelect;
      editorState.currentTool = select;

      _drag(editorState, page, from: _start, to: const []);
      select.isResizeActive = true;
      _drag(editorState, page, from: _end, to: const []);

      expect(select.isResizeActive, isTrue);
      expect(select.selectResult.strokes, [stroke]);
      expect(editorState.history.canUndo, isFalse);
      await tester.pump();
    });

    testGoldens('dragging a lasso around a stroke selects it', (tester) async {
      final previous = stows.selectionRectMode.value;
      stows.selectionRectMode.value = false;
      addTearDown(() => stows.selectionRectMode.value = previous);

      final editorState = await _pumpEditor(tester);
      final page = editorState.coreInfo.pages.first;
      final stroke = _insertStroke(page);
      editorState.currentTool = Select.currentSelect;

      _drag(
        editorState,
        page,
        from: const Offset(80, 180),
        to: const [Offset(220, 180), Offset(220, 270), Offset(80, 270)],
      );

      final select = Select.currentSelect;
      expect(select.doneSelecting, isTrue);
      expect(select.selectResult.strokes, [stroke]);
      expect(page.selectionResizeHandles, hasLength(8));
      expect(editorState.history.canUndo, isFalse);
      await tester.pump();
    });

    testGoldens('dragging an arrow vertex moves that end and undoes', (
      tester,
    ) async {
      final editorState = await _pumpEditor(tester);
      final page = editorState.coreInfo.pages.first;
      final arrow = ArrowStroke(
        color: Stroke.defaultColor,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: page,
        toolId: .arrow,
        start: _start,
        end: _end,
      );
      page.insertStroke(arrow);
      _select(editorState, [arrow]);
      page.selectionVertexHandles = [_start, _end];
      const target = Offset(260, 300);

      _drag(
        editorState,
        page,
        from: _end,
        to: const [Offset(230, 280), target],
      );

      expect(
        page.selectionResizeHandles,
        hasLength(8),
        reason: 'Handles should be placed around the reshaped arrow',
      );
      await tester.pump();

      final reshaped = page.strokes.single as ArrowStroke;
      _expectOffset(reshaped.start, _start);
      _expectOffset(reshaped.end, target);

      editorState.undo();
      await tester.pump();

      _expectOffset((page.strokes.single as ArrowStroke).end, _end);
    });
  });
}

void _expectLastPoint(Stroke stroke, Offset expected) =>
    _expectOffset(Offset(stroke.points.last.x, stroke.points.last.y), expected);

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

/// Adds a stroke running from [_start] to [_end] to [page].
Stroke _insertStroke(EditorPage page) {
  final stroke = Stroke(
    color: Stroke.defaultColor,
    pressureEnabled: false,
    options: StrokeOptions(),
    pageIndex: 0,
    page: page,
    toolId: .fountainPen,
  );
  for (var step = 0; step <= 10; step++) {
    stroke.addPoint(Offset.lerp(_start, _end, step / 10)!);
  }
  page.insertStroke(stroke);
  return stroke;
}

/// Selects [strokes] with the Select tool and returns the selection's bounds.
Rect _select(EditorState editorState, List<Stroke> strokes) {
  final select = Select.currentSelect;
  editorState.currentTool = select;
  select.selectStrokes(strokes, 0);
  return select.selectResult.path.getBounds();
}

/// Puts the pointer down at [from] on [page], moves it through each of [to]
/// in turn, then lifts it. Positions are in page coordinates.
void _drag(
  EditorState editorState,
  EditorPage page, {
  required Offset from,
  required List<Offset> to,
}) {
  Offset global(Offset local) => page.renderBox!.localToGlobal(local);

  editorState.dragPageIndex = 0;
  editorState.onDrawStart(ScaleStartDetails(focalPoint: global(from)));
  for (final position in to) {
    editorState.onDrawUpdate(ScaleUpdateDetails(focalPoint: global(position)));
  }
  editorState.onDrawEnd(ScaleEndDetails());
}
