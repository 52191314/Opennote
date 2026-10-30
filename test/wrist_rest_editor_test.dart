import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/palm_rejection.dart';
import 'package:saber/pages/editor/editor.dart';

import 'utils/test_mock_channel_handlers.dart';

void main() {
  group('Wrist Rest & Palm Rejection in Editor', () {
    FlavorConfig.setup();
    FileManager.documentsDirectory =
        '$tmpDir/wrist_rest_test/'
        '${FileManager.appRootDirectoryPrefix}';

    setUp(() {
      stows.editorFingerDrawing.value = false;
      stows.palmRejectionSensitivity.value = PalmRejectionSensitivity.medium;
      stows.writingPosture.value = WritingPosture.rightBelow;
    });

    testWidgets(
      'Drawing with stylus while resting wrist produces a clean stroke',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: Editor(path: '/wrist-rest-test')),
        );
        await tester.pump();
        final editorState = tester.state<EditorState>(find.byType(Editor));
        final page = editorState.coreInfo.pages.first;
        expect(page.strokes, isEmpty);

        final center = tester.getCenter(find.byType(Editor));

        // 1. User rests wrist on screen below and to the right of writing point
        final wristPos = center + const Offset(60, 100);
        final wristGesture = await tester.createGesture(
          kind: PointerDeviceKind.touch,
        );
        await wristGesture.down(wristPos);
        await tester.pump();

        // 2. User touches stylus down at writing point
        final stylusGesture = await tester.createGesture(
          kind: PointerDeviceKind.stylus,
        );
        await stylusGesture.down(center);
        await tester.pump();

        // 3. User writes with stylus while wrist moves slightly (natural hand shift)
        for (var i = 1; i <= 5; ++i) {
          await stylusGesture.moveTo(center + Offset(i * 10, i * 5));
          await wristGesture.moveTo(wristPos + Offset(i * 2, i * 1));
          await tester.pump();
        }

        // 4. Stylus lifts
        await stylusGesture.up();
        await tester.pump();

        // 5. Wrist lifts
        await wristGesture.up();
        await tester.pump();

        // Should have recorded exactly 1 stroke from the stylus
        expect(page.strokes, hasLength(1));
        final stroke = page.strokes.first;
        expect(
          (stroke.firstPoint! - page.renderBox!.globalToLocal(center)).distance,
          lessThan(2.0),
        );
      },
    );

    testWidgets('Resting wrist does not trigger accidental two-finger undo', (
      tester,
    ) async {
      stows.twoFingerTapUndo.value = true;

      await tester.pumpWidget(
        MaterialApp(home: Editor(path: '/undo-rejection-test')),
      );
      await tester.pump();
      final editorState = tester.state<EditorState>(find.byType(Editor));
      final page = editorState.coreInfo.pages.first;

      // Draw an initial stroke with stylus
      final center = tester.getCenter(find.byType(Editor));
      final stylus = await tester.createGesture(kind: PointerDeviceKind.stylus);
      await stylus.down(center);
      await stylus.moveTo(center + const Offset(30, 30));
      await stylus.up();
      await tester.pump();

      expect(page.strokes, hasLength(1));

      // Now resting palm produces 2 touch contacts with large radius
      final palmPos1 = center + const Offset(50, 80);
      final palmPos2 = center + const Offset(70, 90);
      final touch1 = await tester.createGesture(kind: PointerDeviceKind.touch);
      final touch2 = await tester.createGesture(kind: PointerDeviceKind.touch);

      await touch1.down(palmPos1);
      await touch2.down(palmPos2);
      await tester.pump(const Duration(milliseconds: 50));
      await touch1.up();
      await touch2.up();
      await tester.pump();

      // Stroke must NOT have been undone!
      expect(page.strokes, hasLength(1));
    });
  });
}
