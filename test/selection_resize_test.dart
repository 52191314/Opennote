/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/selection_resize.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:sbn/has_size.dart';

const _bounds = Rect.fromLTWH(100, 200, 100, 50);

void main() {
  setUpAll(FlavorConfig.setup);

  group('SelectionResize.pivot', () {
    const pivots = <Offset>[
      Offset(200, 250),
      Offset(150, 250),
      Offset(100, 250),
      Offset(100, 225),
      Offset(100, 200),
      Offset(150, 200),
      Offset(200, 200),
      Offset(200, 225),
    ];
    for (var handle = 0; handle < pivots.length; handle++) {
      test('handle $handle pivots around the opposite side', () {
        final resize = SelectionResize(
          startBounds: _bounds,
          handleIndex: handle,
        );
        expect(resize.pivot, pivots[handle]);
      });
    }
  });

  group('SelectionResize.scaleAt', () {
    test('corner handles scale both axes', () {
      final bottomRight = SelectionResize(startBounds: _bounds, handleIndex: 4);
      expect(bottomRight.scaleAt(const Offset(250, 300)), (x: 1.5, y: 2.0));

      final topLeft = SelectionResize(startBounds: _bounds, handleIndex: 0);
      expect(topLeft.scaleAt(const Offset(150, 225)), (x: 0.5, y: 0.5));
    });

    test('edge handles scale one axis only', () {
      final middleRight = SelectionResize(startBounds: _bounds, handleIndex: 3);
      expect(middleRight.scaleAt(const Offset(300, 999)), (x: 2.0, y: 1.0));

      final topCenter = SelectionResize(startBounds: _bounds, handleIndex: 1);
      expect(topCenter.scaleAt(const Offset(999, 150)), (x: 1.0, y: 2.0));
    });

    test('is clamped so the selection cannot flip or explode', () {
      final bottomRight = SelectionResize(startBounds: _bounds, handleIndex: 4);
      expect(bottomRight.scaleAt(const Offset(-500, -500)), (
        x: SelectionResize.minScale,
        y: SelectionResize.minScale,
      ));
      expect(bottomRight.scaleAt(const Offset(99999, 99999)), (
        x: SelectionResize.maxScale,
        y: SelectionResize.maxScale,
      ));
    });
  });

  group('SelectionResize.stepTo', () {
    test('a drag split into many updates ends where the pointer is', () {
      final resize = SelectionResize(startBounds: _bounds, handleIndex: 4);
      final stroke = _strokeAcross(_bounds);

      for (final x in [210.0, 220.0, 235.0, 250.0]) {
        final step = resize.stepTo(Offset(x, 250));
        stroke.scaleAround(step.x, step.y, resize.pivot);
      }

      expect(stroke.points.first.x, moreOrLessEquals(100));
      expect(
        stroke.points.last.x,
        moreOrLessEquals(250),
        reason: 'The dragged corner should sit under the pointer',
      );
      expect(stroke.points.last.y, moreOrLessEquals(250));
    });

    test('dragging back to the start restores the original size', () {
      final resize = SelectionResize(startBounds: _bounds, handleIndex: 0);
      final stroke = _strokeAcross(_bounds);

      for (final position in const [
        Offset(60, 180),
        Offset(140, 215),
        Offset(100, 200),
      ]) {
        final step = resize.stepTo(position);
        stroke.scaleAround(step.x, step.y, resize.pivot);
      }

      expect(stroke.points.first.x, moreOrLessEquals(100));
      expect(stroke.points.first.y, moreOrLessEquals(200));
      expect(stroke.points.last.x, moreOrLessEquals(200));
      expect(stroke.points.last.y, moreOrLessEquals(250));
    });
  });

  group('scalePathAround', () {
    test('scales the bounds exactly around the pivot', () {
      final path = Path()..addRect(_bounds);

      final scaled = scalePathAround(path, 1.5, 2, _bounds.topLeft);

      expect(scaled.getBounds(), const Rect.fromLTWH(100, 200, 150, 100));
    });

    test('does not drift when applied in many small steps', () {
      var path = Path()
        ..addRRect(RRect.fromRectAndRadius(_bounds, const Radius.circular(4)));

      for (var i = 0; i < 200; i++) {
        path = scalePathAround(path, 1.01, 1.01, _bounds.center);
        path = scalePathAround(path, 1 / 1.01, 1 / 1.01, _bounds.center);
      }

      final bounds = path.getBounds();
      expect(bounds.left, moreOrLessEquals(_bounds.left, epsilon: 0.01));
      expect(bounds.top, moreOrLessEquals(_bounds.top, epsilon: 0.01));
      expect(bounds.right, moreOrLessEquals(_bounds.right, epsilon: 0.01));
      expect(bounds.bottom, moreOrLessEquals(_bounds.bottom, epsilon: 0.01));
    });
  });
}

/// A stroke from the top left to the bottom right corner of [bounds].
Stroke _strokeAcross(Rect bounds) =>
    Stroke(
        color: Stroke.defaultColor,
        pressureEnabled: false,
        options: StrokeOptions(),
        pageIndex: 0,
        page: const HasSize(Size(1000, 1400)),
        toolId: .fountainPen,
      )
      ..addPoint(bounds.topLeft)
      ..addPoint(bounds.bottomRight);
