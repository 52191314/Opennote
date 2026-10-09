/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/editor/selection_handles.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/select.dart';

const _bounds = Rect.fromLTRB(100, 200, 300, 260);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('SelectionHandles', () {
    tearDown(Select.currentSelect.unselect);

    test('places the resize handles clockwise from the top left', () {
      final page = EditorPage();

      page.placeSelectionHandles(_selection(strokes: []));

      expect(page.selectionResizeHandles, const [
        Offset(100, 200),
        Offset(200, 200),
        Offset(300, 200),
        Offset(300, 230),
        Offset(300, 260),
        Offset(200, 260),
        Offset(100, 260),
        Offset(100, 230),
      ]);
    });

    test('places the rotation handle above the top edge', () {
      final page = EditorPage();

      page.placeSelectionHandles(_selection(strokes: []));

      expect(page.selectionRotationHandleCenter, const Offset(200, 180));
      expect(page.selectionDeleteButtonRect, isNull);
    });

    test('gives a lone arrow a vertex handle at each end', () {
      final page = EditorPage();
      final arrow = _arrow(page);

      page.placeSelectionHandles(_selection(strokes: [arrow]));

      expect(page.selectionVertexHandles, [arrow.start, arrow.end]);
    });

    test('gives no vertex handles to anything else', () {
      final page = EditorPage();
      page.selectionVertexHandles = const [Offset.zero];

      page.placeSelectionHandles(
        _selection(strokes: [_arrow(page), _arrow(page)]),
      );

      expect(page.selectionVertexHandles, isNull);
    });

    test('clearSelectionHandles removes every handle', () {
      final page = EditorPage()
        ..selectionDeleteButtonRect = _bounds
        ..placeSelectionHandles(_selection(strokes: [_arrow(EditorPage())]));

      page.clearSelectionHandles();

      expect(page.selectionDeleteButtonRect, isNull);
      expect(page.selectionRotationHandleCenter, isNull);
      expect(page.selectionResizeHandles, isNull);
      expect(page.selectionVertexHandles, isNull);
    });

    test('showSelectionHandles places handles around a selection', () {
      final page = EditorPage();
      final select = Select.currentSelect
        ..selectResult = _selection(strokes: [_arrow(page)])
        ..doneSelecting = true;

      page.showSelectionHandles(select);

      expect(page.selectionResizeHandles, hasLength(8));
      expect(select.doneSelecting, isTrue);
    });

    test('showSelectionHandles unselects when nothing was selected', () {
      final page = EditorPage()
        ..placeSelectionHandles(_selection(strokes: [_arrow(EditorPage())]));
      final select = Select.currentSelect
        ..selectResult = _selection(strokes: [])
        ..doneSelecting = true;

      page.showSelectionHandles(select);

      expect(page.selectionResizeHandles, isNull);
      expect(select.doneSelecting, isFalse);
    });
  });
}

SelectResult _selection({required List<Stroke> strokes}) => SelectResult(
  pageIndex: 0,
  strokes: strokes,
  images: [],
  path: Path()..addRect(_bounds),
);

ArrowStroke _arrow(EditorPage page) => ArrowStroke(
  color: Stroke.defaultColor,
  pressureEnabled: false,
  options: StrokeOptions(),
  pageIndex: 0,
  page: page,
  toolId: .arrow,
  start: _bounds.topLeft,
  end: _bounds.bottomRight,
);
