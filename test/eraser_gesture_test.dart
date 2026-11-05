/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/gestures/eraser_gesture.dart';
import 'package:saber/data/editor/gestures/laser_gesture.dart';
import 'package:saber/data/editor/gestures/tool_gesture.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/eraser.dart';

import 'utils/fake_gesture_host.dart';

const _start = Offset(100, 200);
const _end = Offset(200, 250);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  late EditorPage page;
  setUp(() => page = EditorPage());

  GesturePointer at(Offset position) =>
      GesturePointer(page: page, pageIndex: 0, position: position);

  group('EraserGesture', () {
    late FakeGestureHost host;
    late EraserGesture gesture;

    setUp(() {
      host = FakeGestureHost()..currentTool = Eraser();
      gesture = EraserGesture(host);
    });

    test('erases the strokes it crosses and records them', () {
      final stroke = _insertStroke(page);

      gesture.start(at(const Offset(50, 50)));
      expect(page.strokes, [stroke], reason: 'Not touched yet');
      gesture.update(at(_start));
      final saved = gesture.end(at(_start));

      expect(saved, isTrue);
      expect(page.strokes, isEmpty);
      final item = host.history.peekUndo();
      expect(item.type, EditorHistoryItemType.erase);
      expect(item.strokes, [stroke]);
    });

    test('shows the eraser cursor where the pointer is', () {
      gesture.start(at(_start));

      expect(page.eraserCursorPosition, _start);
      expect(page.eraserCursorRadius, Eraser().size / 2);
    });

    test('records nothing when it crosses no strokes', () {
      gesture.start(at(_start));
      gesture.update(at(_end));
      gesture.end(at(_end));

      expect(host.history.canUndo, isFalse);
    });

    test('lets the editor tidy pages and hand the tool back', () {
      gesture.start(at(_start));
      gesture.update(at(_end));
      gesture.end(at(_end));

      expect(host.excessPageRemovals, 2);
      expect(host.toolRestores, 1);
    });
  });

  group('LaserGesture', () {
    setUp(() {
      final previous = stows.laserPointerMode.value;
      stows.laserPointerMode.value = 'spotlight';
      addTearDown(() => stows.laserPointerMode.value = previous);
    });

    test('moves the spotlight and saves nothing', () {
      const gesture = LaserGesture();

      gesture.start(at(_start));
      expect(page.laserSpotlightPosition, _start);
      gesture.update(at(_end));
      expect(page.laserSpotlightPosition, _end);
      final saved = gesture.end(at(_end));

      expect(saved, isFalse);
      expect(page.laserSpotlightPosition, isNull);
      expect(page.laserStrokes, isEmpty);
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
