/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' show QuillEditor;
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_canvas_painter.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/lasso_callout_menu.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';

import 'utils/test_mock_channel_handlers.dart';

void main() {
  testGoldens('Canvas: redrawing strokes does not rebuild the page widgets', (
    tester,
  ) async {
    final page = await _pumpEditorPage(tester);
    final before = _quillEditor(tester);

    page.redrawStrokes();
    await tester.pump();

    expect(
      _quillEditor(tester),
      same(before),
      reason: 'Only the painter should run when strokes are redrawn',
    );
  });

  testGoldens('Canvas: moving the page text rebuilds the page widgets', (
    tester,
  ) async {
    final page = await _pumpEditorPage(tester);
    final before = _quillEditor(tester);

    page.textContentOffset = const Offset(30, 40);
    page.redrawStrokes();
    await tester.pump();

    expect(_quillEditor(tester), isNot(same(before)));
  });

  testGoldens('Canvas: strokes added or removed after the build are painted', (
    tester,
  ) async {
    final page = await _pumpEditorPage(tester);
    final stroke = _stroke(page);
    expect(_canvasPaint, paintsExactlyCountTimes(#drawPath, 0));

    page.insertStroke(stroke);
    page.redrawStrokes();
    await tester.pump();

    expect(_canvasPaint, paintsExactlyCountTimes(#drawPath, 1));

    page.removeStroke(stroke);
    page.redrawStrokes();
    await tester.pump();

    expect(_canvasPaint, paintsExactlyCountTimes(#drawPath, 0));
  });

  testGoldens('Canvas: the lasso menu follows a selection being dragged', (
    tester,
  ) async {
    final page = await _pumpEditorPage(tester);
    final editorState = tester.state<EditorState>(find.byType(Editor));
    page.insertStroke(_stroke(page));
    editorState.currentTool = Select.currentSelect;
    addTearDown(Select.currentSelect.unselect);
    await tester.pump();

    Offset global(Offset local) => page.renderBox!.localToGlobal(local);
    void pointerDown(Offset position) {
      editorState.dragPageIndex = 0;
      editorState.onDrawStart(ScaleStartDetails(focalPoint: global(position)));
    }

    void pointerMove(Offset position) => editorState.onDrawUpdate(
      ScaleUpdateDetails(focalPoint: global(position)),
    );

    pointerDown(const Offset(60, 150));
    for (final corner in const [
      Offset(260, 150),
      Offset(260, 300),
      Offset(60, 300),
    ]) {
      pointerMove(corner);
    }
    editorState.onDrawEnd(ScaleEndDetails());
    await tester.pump();
    final menu = find.byType(LassoCalloutMenu);
    expect(menu, findsOneWidget);
    final before = tester.getTopLeft(menu);

    pointerDown(const Offset(150, 225));
    pointerMove(const Offset(150, 325));
    await tester.pump();

    final dragOnScreen =
        global(const Offset(150, 325)) - global(const Offset(150, 225));
    expect(
      tester.getTopLeft(menu).dy - before.dy,
      moreOrLessEquals(dragOnScreen.dy, epsilon: 0.5),
      reason: 'The menu should move with the selection before the drag ends',
    );
    editorState.onDrawEnd(ScaleEndDetails());
    await tester.pump();
  });
}

/// The [CustomPaint] that draws the first page's strokes.
final _canvasPaint = find
    .byWidgetPredicate(
      (widget) =>
          widget is CustomPaint && widget.foregroundPainter is CanvasPainter,
    )
    .first;

QuillEditor _quillEditor(WidgetTester tester) =>
    tester.widget<QuillEditor>(find.byType(QuillEditor).first);

/// Opens a new note in the editor and returns its first page.
Future<EditorPage> _pumpEditorPage(WidgetTester tester) async {
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
  return editorState.coreInfo.pages.first;
}

Stroke _stroke(EditorPage page) =>
    Stroke(
        color: Stroke.defaultColor,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: page,
        toolId: .fountainPen,
      )
      ..addPoint(const Offset(100, 200))
      ..addPoint(const Offset(200, 250));
