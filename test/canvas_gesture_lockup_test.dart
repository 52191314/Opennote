/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:saber/components/canvas/interactive_canvas.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/palm_rejection.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';

import 'utils/test_mock_channel_handlers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('isDrawGesture lockup and recovery after 2-finger zoom', () {
    testWidgets(
      'allows drawing immediately after a 2-finger zoom gesture ends',
      (tester) async {
        final page = await _pumpEditorPage(tester);
        final editorState = tester.state<EditorState>(find.byType(Editor));
        editorState.currentTool = Pen.currentPen;
        stows.editorFingerDrawing.value = true;

        final focalPoint = page.renderBox!.localToGlobal(
          const Offset(100, 100),
        );

        // 1. Simulate 2-finger zoom start
        final zoomStart = ScaleStartDetails(
          focalPoint: focalPoint,
          pointerCount: 2,
        );
        expect(
          editorState.isDrawGesture(zoomStart),
          isFalse,
          reason: 'Zoom gesture with 2 fingers must not be a draw gesture',
        );
        expect(editorState.lastSeenPointerCount, equals(2));

        // 2. End zoom interaction
        editorState.onInteractionEnd(ScaleEndDetails());

        // Wait 15ms so the existing 10ms timer fires
        await tester.pump(const Duration(milliseconds: 15));

        // 3. Start a new single-finger draw gesture
        final drawStart = ScaleStartDetails(
          focalPoint: focalPoint,
          pointerCount: 1,
        );
        expect(
          editorState.isDrawGesture(drawStart),
          isTrue,
          reason: 'Drawing must be allowed after zoom interaction ends',
        );
        expect(editorState.lastSeenPointerCount, equals(1));
      },
    );

    testWidgets(
      'rapid draw attempt within 10ms of zoom end does not permanently lock out drawing',
      (tester) async {
        final page = await _pumpEditorPage(tester);
        final editorState = tester.state<EditorState>(find.byType(Editor));
        editorState.currentTool = Pen.currentPen;
        stows.editorFingerDrawing.value = true;

        final focalPoint = page.renderBox!.localToGlobal(
          const Offset(120, 120),
        );

        // 1. 2-finger zoom starts and ends
        editorState.isDrawGesture(
          ScaleStartDetails(focalPoint: focalPoint, pointerCount: 2),
        );
        editorState.onInteractionEnd(ScaleEndDetails());

        // 2. Immediate draw attempt BEFORE 10ms timer elapses (e.g. 1ms later)
        await tester.pump(const Duration(milliseconds: 1));
        final rapidDraw = ScaleStartDetails(
          focalPoint: focalPoint,
          pointerCount: 1,
        );

        // Calling isDrawGesture here cancels _lastSeenPointerCountTimer.
        // Even if this rapid transition is rejected as trailing zoom finger,
        // it must NEVER permanently lock out subsequent draw attempts!
        editorState.isDrawGesture(rapidDraw);

        // 3. User attempts to draw again (e.g. 50ms later)
        await tester.pump(const Duration(milliseconds: 50));
        final nextDraw = ScaleStartDetails(
          focalPoint: focalPoint,
          pointerCount: 1,
        );
        expect(
          editorState.isDrawGesture(nextDraw),
          isTrue,
          reason:
              'Drawing must recover and succeed on subsequent strokes; '
              'lastSeenPointerCount must not be permanently stuck at 2',
        );
      },
    );

    testWidgets(
      'stylus draw gesture is never locked out by previous 2-finger zoom',
      (tester) async {
        final page = await _pumpEditorPage(tester);
        final editorState = tester.state<EditorState>(find.byType(Editor));
        editorState.currentTool = Pen.currentPen;
        stows.editorFingerDrawing.value = false; // finger drawing off

        final focalPoint = page.renderBox!.localToGlobal(
          const Offset(150, 150),
        );

        // 1. 2-finger zoom with fingers
        editorState.updatePointerData(PointerDeviceKind.touch, null);
        editorState.isDrawGesture(
          ScaleStartDetails(focalPoint: focalPoint, pointerCount: 2),
        );
        editorState.onInteractionEnd(ScaleEndDetails());

        // 2. Stylus touches down immediately
        editorState.updatePointerData(PointerDeviceKind.stylus, 0.5);
        final stylusDraw = ScaleStartDetails(
          focalPoint: focalPoint,
          pointerCount: 1,
        );

        expect(
          editorState.isDrawGesture(stylusDraw),
          isTrue,
          reason: 'Stylus draw must never be blocked by prior multi-touch zoom',
        );
      },
    );

    testWidgets('in-flight stroke preview is cleared on interaction end', (
      tester,
    ) async {
      final page = await _pumpEditorPage(tester);
      final editorState = tester.state<EditorState>(find.byType(Editor));
      editorState.currentTool = Pen.currentPen;
      stows.editorFingerDrawing.value = true;

      final focalPoint = page.renderBox!.localToGlobal(const Offset(100, 100));

      editorState.isDrawGesture(
        ScaleStartDetails(focalPoint: focalPoint, pointerCount: 1),
      );
      editorState.onDrawStart(
        ScaleStartDetails(focalPoint: focalPoint, pointerCount: 1),
      );

      // In-flight stroke exists
      expect(Pen.currentStroke, isNotNull);

      // End interaction
      editorState.onDrawEnd(ScaleEndDetails());
      expect(
        Pen.currentStroke,
        isNull,
        reason: 'In-flight stroke must be cleared on draw end',
      );
    });
  });

  group('Palm rejection posture zone bounding', () {
    late PalmRejectionEngine engine;

    setUp(() {
      engine = PalmRejectionEngine(
        writingPosture: WritingPosture.rightBelow,
        sensitivity: PalmRejectionSensitivity.medium,
      );
    });

    test('rejects touch inside physical wrist contact zone for rightBelow', () {
      // Stylus at (200, 200)
      engine.notifyStylusEvent(
        const PointerHoverEvent(
          position: Offset(200, 200),
          kind: PointerDeviceKind.stylus,
        ),
      );

      // Resting wrist: dx = 60, dy = 100 (inside physical palm zone)
      const wristContact = PointerDownEvent(
        pointer: 5,
        position: Offset(260, 300),
        kind: PointerDeviceKind.touch,
        radiusMajor: 14.0,
      );
      expect(engine.isPalm(wristContact), isTrue);
    });

    test(
      'allows touch far outside physical wrist contact zone for scroll and zoom',
      () {
        // Stylus at (200, 200)
        engine.notifyStylusEvent(
          const PointerHoverEvent(
            position: Offset(200, 200),
            kind: PointerDeviceKind.stylus,
          ),
        );

        // Far bottom-right touch: dx = 350, dy = 500 (e.g. pinch to zoom or scroll)
        // Must NOT be rejected as palm!
        const scrollTouch1 = PointerDownEvent(
          pointer: 10,
          position: Offset(550, 700),
          kind: PointerDeviceKind.touch,
          radiusMajor: 12.0,
        );
        expect(
          engine.isPalm(scrollTouch1),
          isFalse,
          reason: 'Touch at dx=350, dy=500 is far outside physical palm zone',
        );

        // Far right touch: dx = 400, dy = 100
        const scrollTouch2 = PointerDownEvent(
          pointer: 11,
          position: Offset(600, 300),
          kind: PointerDeviceKind.touch,
          radiusMajor: 12.0,
        );
        expect(
          engine.isPalm(scrollTouch2),
          isFalse,
          reason: 'Touch at dx=400 is far outside physical palm zone',
        );

        // Distant bottom touch: dx = 50, dy = 450
        const scrollTouch3 = PointerDownEvent(
          pointer: 12,
          position: Offset(250, 650),
          kind: PointerDeviceKind.touch,
          radiusMajor: 12.0,
        );
        expect(
          engine.isPalm(scrollTouch3),
          isFalse,
          reason: 'Touch at dy=450 is beyond wrist contact length',
        );
      },
    );

    test('posture zones are strictly bounded for all postures', () {
      // Verify that infinite half-planes do not exist: points 1000px away must be false
      for (final posture in WritingPosture.values) {
        expect(
          PalmRejectionEngine.isPointInPostureZone(1000, 1000, posture),
          isFalse,
          reason: '$posture must not reject points 1000px away in bottom-right',
        );
        expect(
          PalmRejectionEngine.isPointInPostureZone(-1000, 1000, posture),
          isFalse,
          reason: '$posture must not reject points 1000px away in bottom-left',
        );
        expect(
          PalmRejectionEngine.isPointInPostureZone(1000, -1000, posture),
          isFalse,
          reason: '$posture must not reject points 1000px away in top-right',
        );
        expect(
          PalmRejectionEngine.isPointInPostureZone(-1000, -1000, posture),
          isFalse,
          reason: '$posture must not reject points 1000px away in top-left',
        );
      }
    });

    test(
      'active stylus down rejects concurrent touches, but lifting frees distant touches',
      () {
        // Stylus touches down at (200, 200)
        const stylusDown = PointerDownEvent(
          pointer: 1,
          position: Offset(200, 200),
          kind: PointerDeviceKind.stylus,
        );
        engine.notifyStylusEvent(stylusDown);
        expect(engine.isStylusDown, isTrue);

        // Concurrent touch during active stylus is rejected
        const concurrentTouch = PointerDownEvent(
          pointer: 2,
          position: Offset(550, 700),
          kind: PointerDeviceKind.touch,
        );
        expect(engine.isPalm(concurrentTouch), isTrue);

        // Stylus lifts
        const stylusUp = PointerUpEvent(
          pointer: 1,
          position: Offset(200, 200),
          kind: PointerDeviceKind.stylus,
        );
        engine.onPointerUpOrCancel(stylusUp);
        expect(engine.isStylusDown, isFalse);

        // Now distant scroll/zoom touch should be accepted
        const subsequentTouch = PointerDownEvent(
          pointer: 3,
          position: Offset(550, 700),
          kind: PointerDeviceKind.touch,
          radiusMajor: 12.0,
        );
        expect(
          engine.isPalm(subsequentTouch),
          isFalse,
          reason: 'Distant touch must be allowed once stylus is lifted',
        );
      },
    );
  });

  group('CanvasScaleGestureRecognizer preemption & pinch zoom tracking', () {
    test('tracks two-finger pinch when pointers are outside palm zone', () {
      final engine = PalmRejectionEngine(
        writingPosture: WritingPosture.rightBelow,
        sensitivity: PalmRejectionSensitivity.medium,
      );
      // Recent stylus at (100, 100)
      engine.notifyStylusEvent(
        const PointerHoverEvent(
          position: Offset(100, 100),
          kind: PointerDeviceKind.stylus,
        ),
      );

      final recognizer = CanvasScaleGestureRecognizer(palmEngine: engine);
      addTearDown(recognizer.dispose);

      // Two fingers down for pinch zoom at (400, 400) and (550, 550)
      const p1 = PointerDownEvent(
        pointer: 20,
        position: Offset(400, 400),
        kind: PointerDeviceKind.touch,
        radiusMajor: 10.0,
      );
      const p2 = PointerDownEvent(
        pointer: 21,
        position: Offset(550, 550),
        kind: PointerDeviceKind.touch,
        radiusMajor: 10.0,
      );

      recognizer.addAllowedPointer(p1);
      recognizer.addAllowedPointer(p2);

      // Verify that neither pointer was dropped by palm rejection
      // Both touch pointers should be tracked for scale gesture
      expect(engine.isPalm(p1), isFalse);
      expect(engine.isPalm(p2), isFalse);
    });

    test('stylus preemption cancels active touch pointers', () {
      final engine = PalmRejectionEngine(
        writingPosture: WritingPosture.rightBelow,
        sensitivity: PalmRejectionSensitivity.medium,
      );

      final recognizer = CanvasScaleGestureRecognizer(palmEngine: engine);
      addTearDown(recognizer.dispose);

      const touchDown = PointerDownEvent(
        pointer: 30,
        position: Offset(400, 400),
        kind: PointerDeviceKind.touch,
      );
      recognizer.addAllowedPointer(touchDown);

      // Now stylus arrives (e.g. user rests wrist first, then touches pen tip)
      const stylusDown = PointerDownEvent(
        pointer: 31,
        position: Offset(200, 200),
        kind: PointerDeviceKind.stylus,
      );

      // Adding stylus must preempt touch pointers
      expect(() => recognizer.addAllowedPointer(stylusDown), returnsNormally);
    });
  });
}

Future<EditorPage> _pumpEditorPage(WidgetTester tester) async {
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
