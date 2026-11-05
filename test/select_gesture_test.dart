/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/gestures/select_gesture.dart';
import 'package:saber/data/editor/gestures/tool_gesture.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/editor/selection_handles.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';

import 'utils/fake_gesture_host.dart';

const _start = Offset(100, 200);
const _end = Offset(200, 250);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('SelectGesture', () {
    late FakeGestureHost host;
    late SelectGesture gesture;
    late EditorPage page;
    late Stroke stroke;

    setUp(() {
      host = FakeGestureHost();
      gesture = SelectGesture(host);
      page = EditorPage();
      stroke = _insertStroke(page);
    });
    tearDown(Select.currentSelect.unselect);

    GesturePointer at(
      Offset position, {
      Offset delta = Offset.zero,
      Offset moved = Offset.zero,
    }) => GesturePointer(
      page: page,
      pageIndex: 0,
      position: position,
      delta: delta,
      moved: moved,
    );

    Rect selectStroke() {
      final select = Select.currentSelect..selectStrokes([stroke], 0);
      page.placeSelectionHandles(select.selectResult);
      return select.selectResult.path.getBounds();
    }

    test('dragging a resize handle scales the selection', () {
      final bounds = selectStroke();
      final target = bounds.bottomRight + Offset(bounds.width, bounds.height);

      expect(
        gesture.start(at(bounds.bottomRight)),
        isFalse,
        reason: 'Grabbing a handle is not an ordinary drag',
      );
      gesture.update(at(target));
      expect(gesture.end(at(target)), isTrue);

      final resized = page.strokes.single;
      expect(resized, isNot(same(stroke)), reason: 'The original is kept');
      _expectLastPoint(resized, bounds.topLeft + (_end - bounds.topLeft) * 2);
      expect(host.history.peekUndo().type, EditorHistoryItemType.transform);
    });

    test('dragging the rotation handle turns the selection', () {
      final bounds = selectStroke();
      final handle = page.selectionRotationHandleCenter!;

      expect(gesture.start(at(handle)), isFalse);
      gesture.update(at(handle));
      gesture.update(at(bounds.center + const Offset(80, 5)));
      expect(gesture.end(at(handle)), isTrue);

      final rotatedEnd = page.strokes.single.lastPoint!;
      expect((rotatedEnd - _end).distance, greaterThan(10));
      expect(host.history.peekUndo().type, EditorHistoryItemType.transform);
    });

    test('touching a handle without dragging records nothing', () {
      final bounds = selectStroke();

      gesture.start(at(bounds.bottomRight));
      gesture.end(at(bounds.bottomRight));

      expect(host.history.canUndo, isFalse);
      expect(page.strokes.single, same(stroke));
    });

    test('releaseHandle lets go of a grabbed handle', () {
      final bounds = selectStroke();

      gesture.start(at(bounds.bottomRight));
      gesture.releaseHandle();
      gesture.update(at(bounds.bottomRight, delta: const Offset(30, 40)));

      _expectLastPoint(page.strokes.single, _end + const Offset(30, 40));
    });

    test('dragging inside the selection moves it', () {
      final bounds = selectStroke();
      const moved = Offset(30, 40);

      expect(gesture.start(at(bounds.center)), isTrue);
      gesture.update(at(bounds.center + moved, delta: moved));
      expect(gesture.end(at(bounds.center + moved, moved: moved)), isTrue);

      _expectLastPoint(stroke, _end + moved);
      final item = host.history.peekUndo();
      expect(item.type, EditorHistoryItemType.move);
      expect(item.offset, const Rect.fromLTRB(30, 40, 30, 40));
      expect(item.strokes, [stroke]);
    });

    test('touching outside the selection starts a new lasso', () {
      selectStroke();

      expect(gesture.start(at(const Offset(400, 500))), isTrue);

      expect(Select.currentSelect.doneSelecting, isFalse);
      expect(page.selectionResizeHandles, isNull);
    });

    test('starting a lasso leaves redo available', () {
      host.history
        ..recordChange(
          EditorHistoryItem(
            type: .draw,
            pageIndex: 0,
            strokes: [stroke],
            images: [],
          ),
        )
        ..undo()
        ..canRedo = false;

      gesture.start(at(const Offset(400, 500)));

      expect(host.history.canRedo, isTrue);
    });

    test('lifting without moving selects what was tapped', () {
      gesture.start(at(_start));

      expect(gesture.end(at(_start)), isFalse, reason: 'Nothing to save');

      expect(Select.currentSelect.selectResult.strokes, [stroke]);
      expect(page.selectionResizeHandles, hasLength(8));
    });

    test('lassoing a stroke selects it', () {
      const corners = [Offset(220, 180), Offset(220, 270), Offset(80, 270)];
      addTearDown(_useLasso());

      gesture.start(at(const Offset(80, 180)));
      for (final corner in corners) {
        gesture.update(at(corner));
      }
      final saved = gesture.end(at(corners.last, moved: const Offset(0, 90)));

      expect(saved, isFalse);
      expect(Select.currentSelect.selectResult.strokes, [stroke]);
      expect(host.history.canUndo, isFalse);
    });

    test('touching the delete button asks the editor to delete', () {
      final bounds = selectStroke();
      page.selectionDeleteButtonRect = Rect.fromCircle(
        center: bounds.topRight,
        radius: 10,
      );

      expect(gesture.start(at(bounds.topRight)), isFalse);

      expect(host.deletedFrom, [page]);
    });
  });
}

/// Switches the Select tool to freeform lasso mode,
/// and returns a callback that switches it back.
VoidCallback _useLasso() {
  final previous = stows.selectionRectMode.value;
  stows.selectionRectMode.value = false;
  return () => stows.selectionRectMode.value = previous;
}

void _expectLastPoint(Stroke stroke, Offset expected) {
  final actual = stroke.lastPoint!;
  expect(actual.dx, moreOrLessEquals(expected.dx, epsilon: 1e-6));
  expect(actual.dy, moreOrLessEquals(expected.dy, epsilon: 1e-6));
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
