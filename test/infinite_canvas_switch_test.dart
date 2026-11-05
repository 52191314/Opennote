/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';

import 'utils/test_mock_channel_handlers.dart';

void main() {
  testWidgets('Canvas: switching to infinite canvas preserves attached renderBox and allows drawing', (
    tester,
  ) async {
    final page = await _pumpEditorPage(tester);
    final editorState = tester.state<EditorState>(find.byType(Editor));

    // Access renderBox in paged mode so it's cached
    final initialBox = page.renderBox;
    expect(initialBox, isNotNull);
    expect(initialBox!.attached, isTrue);

    // Switch to infinite canvas
    editorState.setInfiniteCanvas(true);
    await tester.pumpAndSettle();

    // Check page.renderBox
    expect(page.renderBox, isNotNull);
    expect(
      page.renderBox!.attached,
      isTrue,
      reason: 'RenderBox must remain attached after switching to infinite canvas',
    );

    // Now test drawing a stroke after switching to infinite canvas!
    editorState.currentTool = Pen.currentPen;
    final focalPoint = page.renderBox!.localToGlobal(const Offset(100, 100));

    expect(
      editorState.isDrawGesture(ScaleStartDetails(focalPoint: focalPoint, pointerCount: 1)),
      isTrue,
    );

    // Must not throw when starting draw
    expect(
      () => editorState.onDrawStart(ScaleStartDetails(focalPoint: focalPoint, pointerCount: 1)),
      returnsNormally,
    );

    // Must not throw when updating draw
    expect(
      () => editorState.onDrawUpdate(ScaleUpdateDetails(focalPoint: focalPoint + const Offset(10, 10))),
      returnsNormally,
    );

    // Must not throw when ending draw
    expect(
      () => editorState.onDrawEnd(ScaleEndDetails()),
      returnsNormally,
    );
  });
}

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
