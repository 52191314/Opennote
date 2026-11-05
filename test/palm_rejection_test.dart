import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/data/tools/palm_rejection.dart';

void main() {
  group('WritingPosture', () {
    test('identifies handedness correctly', () {
      expect(WritingPosture.rightBelow.isRightHanded, isTrue);
      expect(WritingPosture.rightLevel.isRightHanded, isTrue);
      expect(WritingPosture.rightAbove.isRightHanded, isTrue);
      expect(WritingPosture.leftBelow.isRightHanded, isFalse);
      expect(WritingPosture.leftLevel.isRightHanded, isFalse);
      expect(WritingPosture.leftAbove.isRightHanded, isFalse);

      expect(WritingPosture.leftBelow.isLeftHanded, isTrue);
      expect(WritingPosture.leftLevel.isLeftHanded, isTrue);
      expect(WritingPosture.leftAbove.isLeftHanded, isTrue);
    });

    test('identifies vertical placement relative to baseline', () {
      expect(WritingPosture.rightBelow.isHandBelow, isTrue);
      expect(WritingPosture.leftBelow.isHandBelow, isTrue);
      expect(WritingPosture.rightLevel.isHandLevel, isTrue);
      expect(WritingPosture.leftLevel.isHandLevel, isTrue);
      expect(WritingPosture.rightAbove.isHandAbove, isTrue);
      expect(WritingPosture.leftAbove.isHandAbove, isTrue);
    });
  });

  group('PalmRejectionEngine', () {
    late PalmRejectionEngine engine;

    setUp(() {
      engine = PalmRejectionEngine(
        writingPosture: WritingPosture.rightBelow,
        sensitivity: PalmRejectionSensitivity.medium,
      );
    });

    test('stylus is never classified as palm', () {
      const stylusDown = PointerDownEvent(
        pointer: 1,
        position: Offset(200, 200),
        kind: PointerDeviceKind.stylus,
        pressure: 0.5,
      );
      expect(engine.isPalm(stylusDown), isFalse);
      expect(engine.isStylusDown, isTrue);
      expect(engine.lastStylusPosition, equals(const Offset(200, 200)));

      const invertedStylus = PointerDownEvent(
        pointer: 2,
        position: Offset(250, 250),
        kind: PointerDeviceKind.invertedStylus,
      );
      expect(engine.isPalm(invertedStylus), isFalse);
    });

    test('active stylus locks out concurrent touch events', () {
      const stylusDown = PointerDownEvent(
        pointer: 1,
        position: Offset(200, 200),
        kind: PointerDeviceKind.stylus,
      );
      engine.isPalm(stylusDown);
      expect(engine.isStylusDown, isTrue);

      const touchDown = PointerDownEvent(
        pointer: 2,
        position: Offset(280, 320),
        kind: PointerDeviceKind.touch,
      );
      expect(engine.isPalm(touchDown), isTrue);

      const touchMove = PointerMoveEvent(
        pointer: 2,
        position: Offset(282, 322),
        kind: PointerDeviceKind.touch,
      );
      expect(engine.isPalm(touchMove), isTrue);

      const stylusUp = PointerUpEvent(
        pointer: 1,
        position: Offset(205, 205),
        kind: PointerDeviceKind.stylus,
      );
      engine.onPointerUpOrCancel(stylusUp);
      expect(engine.isStylusDown, isFalse);
    });

    test('large contact radius or size is rejected as palm', () {
      const largeRadiusTouch = PointerDownEvent(
        pointer: 10,
        position: Offset(100, 100),
        kind: PointerDeviceKind.touch,
        radiusMajor: 26.0,
      );
      expect(engine.isPalm(largeRadiusTouch), isTrue);

      const largeSizeTouch = PointerDownEvent(
        pointer: 11,
        position: Offset(100, 100),
        kind: PointerDeviceKind.touch,
        size: 0.25,
      );
      expect(engine.isPalm(largeSizeTouch), isTrue);

      const normalFingerTouch = PointerDownEvent(
        pointer: 12,
        position: Offset(100, 100),
        kind: PointerDeviceKind.touch,
        radiusMajor: 12.0,
        size: 0.05,
      );
      expect(engine.isPalm(normalFingerTouch), isFalse);
    });

    test('spatial posture rejection zone works for right-handed below', () {
      // Simulate stylus activity at (200, 200)
      engine.notifyStylusEvent(
        const PointerHoverEvent(
          position: Offset(200, 200),
          kind: PointerDeviceKind.stylus,
        ),
      );

      // Wrist resting below and to the right of stylus (dx = 60, dy = 100)
      const wristContact = PointerDownEvent(
        pointer: 5,
        position: Offset(260, 300),
        kind: PointerDeviceKind.touch,
        radiusMajor: 14.0, // even with normal radius
      );
      expect(engine.isPalm(wristContact), isTrue);

      // Other hand / touch far to the top-left (dx = -120, dy = -120)
      const otherHandTouch = PointerDownEvent(
        pointer: 6,
        position: Offset(80, 80),
        kind: PointerDeviceKind.touch,
        radiusMajor: 12.0,
      );
      expect(engine.isPalm(otherHandTouch), isFalse);
    });

    test('spatial posture rejection zone works for left-handed below', () {
      final leftEngine = PalmRejectionEngine(
        writingPosture: WritingPosture.leftBelow,
        sensitivity: PalmRejectionSensitivity.medium,
      );

      leftEngine.notifyStylusEvent(
        const PointerHoverEvent(
          position: Offset(300, 200),
          kind: PointerDeviceKind.stylus,
        ),
      );

      // Left wrist resting below and to the left (dx = -80, dy = 80)
      const leftWrist = PointerDownEvent(
        pointer: 7,
        position: Offset(220, 280),
        kind: PointerDeviceKind.touch,
        radiusMajor: 14.0,
      );
      expect(leftEngine.isPalm(leftWrist), isTrue);
    });

    test('disabled sensitivity allows all touches through', () {
      final disabledEngine = PalmRejectionEngine(
        sensitivity: PalmRejectionSensitivity.disabled,
      );

      const largeTouch = PointerDownEvent(
        pointer: 8,
        position: Offset(200, 200),
        kind: PointerDeviceKind.touch,
        radiusMajor: 50.0,
        size: 0.8,
      );
      expect(disabledEngine.isPalm(largeTouch), isFalse);
    });
  });
}
