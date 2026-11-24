/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/components/canvas/hud/canvas_zoom_indicator.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';

void main() {
  const containerBounds = BoxConstraints(
    minWidth: 100,
    maxWidth: 100,
    minHeight: 200,
    maxHeight: 200,
  );

  test('Zoom in with Ctrl +', () {
    final oldMatrix = Matrix4.identity();
    final newMatrix = CanvasGestureDetectorState.setZoom(
      scaleDelta: 0.1,
      transformation: oldMatrix,
      containerBounds: containerBounds,
    );
    expect(newMatrix, isNotNull);
    final scale = newMatrix!.approxScale;
    expect(scale, 1.1);
    final translation = newMatrix.getTranslation();
    expect(translation.x, moreOrLessEquals(-5));
    expect(translation.y, moreOrLessEquals(-10));
  });

  test('Zoom out with Ctrl -', () {
    final oldMatrix = Matrix4.identity();
    final newMatrix = CanvasGestureDetectorState.setZoom(
      scaleDelta: -0.1,
      transformation: oldMatrix,
      containerBounds: containerBounds,
    );
    expect(newMatrix, isNotNull);
    final scale = newMatrix!.approxScale;
    expect(scale, 0.9);
    final translation = newMatrix.getTranslation();
    expect(translation.x, moreOrLessEquals(5));
    expect(translation.y, moreOrLessEquals(10));
  });

  test('Zoom in with Ctrl + and translation', () {
    final oldMatrix = Matrix4.translationValues(100, 100, 0);
    final newMatrix = CanvasGestureDetectorState.setZoom(
      scaleDelta: 0.1,
      transformation: oldMatrix,
      containerBounds: containerBounds,
    );
    expect(newMatrix, isNotNull);
    final scale = newMatrix!.approxScale;
    expect(scale, 1.1);
    final translation = newMatrix.getTranslation();
    expect(translation.x, moreOrLessEquals(105));
    expect(translation.y, moreOrLessEquals(100));
  });

  test('Zoom in with Ctrl + above max zoom', () {
    final oldMatrix = Matrix4.identity()
      ..scaleByDouble(
        CanvasGestureDetector.kMaxScale,
        CanvasGestureDetector.kMaxScale,
        CanvasGestureDetector.kMaxScale,
        1,
      );
    final newMatrix = CanvasGestureDetectorState.setZoom(
      scaleDelta: 0.1,
      transformation: oldMatrix,
      containerBounds: containerBounds,
    );
    expect(newMatrix, isNull);
  });

  test('Zoom out with Ctrl - below min zoom', () {
    final oldMatrix = Matrix4.identity()
      ..scaleByDouble(
        CanvasGestureDetector.kMinScale,
        CanvasGestureDetector.kMinScale,
        CanvasGestureDetector.kMinScale,
        1,
      );
    final newMatrix = CanvasGestureDetectorState.setZoom(
      scaleDelta: -0.1,
      transformation: oldMatrix,
      containerBounds: containerBounds,
    );
    expect(newMatrix, isNull);
  });

  test('Infinite zoom out allows scaling past 0.3 down to kMinScale', () {
    expect(CanvasGestureDetector.kMinScale, equals(0.001));

    // Scaling from 0.3 down with delta -0.1 yields 0.2 (previously blocked by 0.3 cap)
    final matrixAt0_3 = Matrix4.identity()..scaleByDouble(0.3, 0.3, 0.3, 1);
    final matrixAt0_2 = CanvasGestureDetectorState.setZoom(
      scaleDelta: -0.1,
      transformation: matrixAt0_3,
      containerBounds: containerBounds,
    );
    expect(matrixAt0_2, isNotNull);
    expect(matrixAt0_2!.approxScale, moreOrLessEquals(0.2));

    // Scaling down from 0.05 smoothly clamps to kMinScale rather than null
    final matrixAt0_05 = Matrix4.identity()..scaleByDouble(0.05, 0.05, 0.05, 1);
    final matrixAtMin = CanvasGestureDetectorState.setZoom(
      scaleDelta: -0.1,
      transformation: matrixAt0_05,
      containerBounds: containerBounds,
    );
    expect(matrixAtMin, isNotNull);
    expect(
      matrixAtMin!.approxScale,
      moreOrLessEquals(CanvasGestureDetector.kMinScale),
    );
  });

  test(
    'CanvasZoomIndicator text formatting adapts cleanly for zoom levels',
    () {
      expect(CanvasZoomIndicator.formatZoomText(1.0), equals('1.0x'));
      expect(CanvasZoomIndicator.formatZoomText(2.5), equals('2.5x'));
      expect(CanvasZoomIndicator.formatZoomText(0.5), equals('0.5x'));
      expect(CanvasZoomIndicator.formatZoomText(0.1), equals('0.1x'));
      expect(CanvasZoomIndicator.formatZoomText(0.08), equals('8%'));
      expect(CanvasZoomIndicator.formatZoomText(0.05), equals('5%'));
      expect(CanvasZoomIndicator.formatZoomText(0.01), equals('1%'));
      expect(CanvasZoomIndicator.formatZoomText(0.005), equals('0.5%'));
      expect(CanvasZoomIndicator.formatZoomText(0.001), equals('0.1%'));
    },
  );
}
