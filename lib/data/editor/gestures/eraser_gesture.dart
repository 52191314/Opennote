/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/gestures/tool_gesture.dart';
import 'package:saber/data/tools/eraser.dart';

/// Erases the strokes the pointer crosses for the [Eraser] tool.
class EraserGesture implements ToolGesture {
  EraserGesture(this._host);

  final EditorGestureHost _host;

  @override
  bool start(GesturePointer pointer) {
    _eraseAt(pointer);
    _host.removeExcessPages();
    return true;
  }

  @override
  void update(GesturePointer pointer) {
    _eraseAt(pointer);
    pointer.page.redrawStrokes();
    _host.removeExcessPages();
  }

  @override
  bool end(GesturePointer pointer) {
    final eraser = _host.currentTool;
    if (eraser is! Eraser) return true;

    final erased = eraser.onDragEnd();
    _host.restoreToolAfterErasing();
    if (erased.isEmpty) return true;

    _host.history.recordChange(
      EditorHistoryItem(
        type: .erase,
        pageIndex: pointer.pageIndex,
        strokes: erased,
        images: [],
      ),
    );
    return true;
  }

  void _eraseAt(GesturePointer pointer) {
    final eraser = _host.currentTool;
    if (eraser is! Eraser) return;

    final page = pointer.page;
    page.eraserCursorPosition = pointer.position;
    page.eraserCursorRadius = eraser.size / 2;
    final crossed = eraser.checkForOverlappingStrokes(
      pointer.position,
      page.activeLayerStrokes,
    );
    for (final stroke in crossed) {
      page.removeStroke(stroke);
    }
  }
}
