/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/gestures/pen_gesture.dart';
import 'package:saber/data/editor/gestures/tool_gesture.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/select.dart';

import 'utils/fake_gesture_host.dart';

const _start = Offset(100, 200);
const _end = Offset(200, 250);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('PenGesture', () {
    late FakeGestureHost host;
    late PenGesture gesture;
    late EditorPage page;

    setUp(() {
      host = FakeGestureHost();
      gesture = PenGesture(host, onCircleDetected: (_) {});
      page = EditorPage();
    });
    tearDown(() => Pen.currentStroke = null);

    /// Draws through [points] and returns whether the note needs saving.
    bool draw(List<Offset> points) {
      GesturePointer at(Offset position) =>
          GesturePointer(page: page, pageIndex: 0, position: position);

      gesture.start(at(points.first));
      for (final point in points.skip(1)) {
        gesture.update(at(point));
      }
      return gesture.end(at(points.last));
    }

    test('adds the stroke to the page and records it', () {
      final saved = draw(const [_start, Offset(130, 240), Offset(170, 210)]);

      expect(saved, isTrue);
      expect(Pen.currentStroke, isNull);
      expect(host.createdPages, [0]);
      final item = host.history.peekUndo();
      expect(item.type, EditorHistoryItemType.draw);
      expect(item.strokes, page.strokes);
      expect(page.strokes, hasLength(1));
    });

    test('shows where the pen is while drawing', () {
      final pen = host.currentTool as Pen;

      gesture.start(GesturePointer(page: page, pageIndex: 0, position: _start));

      expect(page.penPreviewPosition, _start);
      expect(page.penPreviewRadius, pen.options.size / 2);
      expect(page.penPreviewColor, pen.color);
    });

    test('does nothing if the tool is not a pen', () {
      host.currentTool = Select.currentSelect;

      final saved = draw(const [_start, _end]);

      expect(saved, isTrue);
      expect(page.strokes, isEmpty);
      expect(Pen.currentStroke, isNull);
    });

    test('a tap on tape toggles it instead of drawing', () {
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

      draw(const [Offset(150, 120), Offset(151, 121)]);

      expect(tape.isConcealed, isFalse);
      expect(page.strokes, [tape]);
      expect(host.history.canUndo, isFalse);
      expect(host.autosaves, 1);
    });

    group('scribbling', () {
      setUp(() {
        final previous = stows.scribbleToErase.value;
        stows.scribbleToErase.value = true;
        addTearDown(() => stows.scribbleToErase.value = previous);
      });

      final scribble = [
        const Offset(100, 225),
        for (final pass in const [1, -1, 1, -1])
          for (var step = 1; step <= 10; step++)
            Offset(pass == 1 ? 100.0 + step * 10 : 200.0 - step * 10, 225),
      ];

      test('erases the strokes it crosses, once each', () {
        final stroke = _insertStroke(page);

        final saved = draw(scribble);

        expect(saved, isTrue);
        expect(page.strokes, isEmpty);
        final item = host.history.peekUndo();
        expect(item.type, EditorHistoryItemType.erase);
        expect(item.strokes, [stroke]);
        expect(page.eraserCursorPosition, isNull);
      });

      test('over nothing leaves nothing to save', () {
        final saved = draw(scribble);

        expect(saved, isFalse);
        expect(page.strokes, isEmpty);
        expect(host.history.canUndo, isFalse);
      });
    });
  });
}

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
