/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_rect_rotation.dart';
import 'package:saber/components/canvas/_rectangle_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:sbn/has_size.dart';

const _rect = Rect.fromLTWH(100, 200, 80, 40);

void main() {
  setUpAll(FlavorConfig.setup);

  group('RectRotation', () {
    test('a quarter turn swaps the width and height', () {
      final rotated = RectRotation().rotate(_rect, pi / 2, _rect.center);

      _expectRect(
        rotated,
        Rect.fromCenter(center: _rect.center, width: 40, height: 80),
      );
    });

    test('many small turns do not grow the rect', () {
      final rotation = RectRotation();
      var rect = _rect;

      for (var step = 0; step < 36; step++) {
        rect = rotation.rotate(rect, 2 * pi / 36, _rect.center);
      }

      _expectRect(rect, _rect);
    });

    test('the rect follows the centre of rotation', () {
      final rotated = RectRotation().rotate(_rect, pi, Offset.zero);

      _expectRect(
        rotated,
        Rect.fromCenter(center: -_rect.center, width: 80, height: 40),
      );
    });

    test('starts again from the current size if the rect was changed', () {
      final rotation = RectRotation();
      rotation.rotate(_rect, pi / 4, _rect.center);
      const resized = Rect.fromLTWH(0, 0, 10, 30);

      final rotated = rotation.rotate(resized, pi / 2, resized.center);

      _expectRect(
        rotated,
        Rect.fromCenter(center: resized.center, width: 30, height: 10),
      );
    });
  });

  for (final (name, create) in <(String, Stroke Function())>[
    ('RectangleStroke', _rectangle),
    ('TapeStroke', _tape),
  ]) {
    test('$name keeps its size when dragged round a full turn', () {
      final stroke = create();

      for (var step = 0; step < 72; step++) {
        stroke.rotateAround(2 * pi / 72, _rect.center);
      }

      _expectRect(_rectOf(stroke), _rect);
    });

    test('$name swaps width and height after a quarter turn in steps', () {
      final stroke = create();

      for (var step = 0; step < 9; step++) {
        stroke.rotateAround(pi / 18, _rect.center);
      }

      _expectRect(
        _rectOf(stroke),
        Rect.fromCenter(center: _rect.center, width: 40, height: 80),
      );
    });
  }
}

void _expectRect(Rect actual, Rect expected) {
  expect(actual.left, moreOrLessEquals(expected.left, epsilon: 1e-6));
  expect(actual.top, moreOrLessEquals(expected.top, epsilon: 1e-6));
  expect(actual.right, moreOrLessEquals(expected.right, epsilon: 1e-6));
  expect(actual.bottom, moreOrLessEquals(expected.bottom, epsilon: 1e-6));
}

Rect _rectOf(Stroke stroke) => switch (stroke) {
  RectangleStroke() => stroke.rect,
  TapeStroke() => stroke.rect,
  _ => throw ArgumentError('Not a rect stroke: $stroke'),
};

Stroke _rectangle() => RectangleStroke(
  color: Stroke.defaultColor,
  pressureEnabled: false,
  options: StrokeOptions(),
  pageIndex: 0,
  page: const HasSize(Size(1000, 1400)),
  toolId: .shapePen,
  rect: _rect,
);

Stroke _tape() => TapeStroke(
  color: Stroke.defaultColor,
  pressureEnabled: false,
  options: StrokeOptions(),
  pageIndex: 0,
  page: const HasSize(Size(1000, 1400)),
  toolId: .shapePen,
  rect: _rect,
);
