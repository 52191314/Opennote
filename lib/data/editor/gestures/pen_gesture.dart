/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/gestures/tool_gesture.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/circle_to_select_detector.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/scribble_detector.dart';
import 'package:saber/data/tools/shape_pen.dart';

/// Draws strokes for [Pen] tools, and watches for the scribble-to-erase
/// and circle-to-select gestures made with them.
class PenGesture implements ToolGesture {
  /// [onCircleDetected] is called with the loop the pointer drew
  /// when it circles something and then holds still.
  PenGesture(this._host, {required void Function(Path loop) onCircleDetected})
    : _circleToSelect = CircleToSelectDetector(
        onCircleDetected: onCircleDetected,
      );

  final EditorGestureHost _host;
  final _scribble = ScribbleDetector();
  final CircleToSelectDetector _circleToSelect;

  /// A stroke with more points than this is never a tap.
  static const tapMaxPoints = 4;

  /// A stroke at least this long is never a tap.
  static const tapSlop = 15.0;

  /// How far outside a tape's edge a tap still toggles it.
  static const tapeTapMargin = 8.0;

  /// The line height the scribble detector assumes on a page without lines.
  static const fallbackLineHeight = 30.0;

  @override
  bool start(GesturePointer pointer) {
    final pen = _host.currentTool;
    if (pen is! Pen) return true;

    _showPreview(pointer, pen);
    if (stows.scribbleToErase.value) _scribble.start(pointer.position);
    if (stows.circleToSelect.value) _circleToSelect.start(pointer.position);
    pen.onDragStart(
      pointer.position,
      pointer.page,
      pointer.pageIndex,
      pointer.pressure,
    );
    return true;
  }

  @override
  void update(GesturePointer pointer) {
    final pen = _host.currentTool;
    if (pen is! Pen) return;

    _showPreview(pointer, pen);
    if (!_eraseScribble(pointer, pen)) {
      pen.onDragUpdate(pointer.position, pointer.pressure);
    }
    pointer.page.redrawStrokes();
    if (stows.circleToSelect.value) _circleToSelect.update(pointer.position);
  }

  @override
  bool end(GesturePointer pointer) {
    final pen = _host.currentTool;
    if (pen is! Pen) return true;

    _circleToSelect.cancel();
    if (_scribble.state == ScribbleState.erasing) {
      return _endScribble(pointer, pen);
    }

    final stroke = pen.onDragEnd();
    if (stroke == null || stroke.isEmpty) return true;
    if (_toggleTappedTape(pointer.page, stroke)) return true;
    if (_shouldStraighten(pen, stroke)) stroke.convertToLine();

    _host.createPage(stroke.pageIndex);
    pointer.page.insertStroke(stroke);
    _host.history.recordChange(
      EditorHistoryItem(
        type: .draw,
        pageIndex: pointer.pageIndex,
        strokes: [stroke],
        images: [],
      ),
    );
    return true;
  }

  static void _showPreview(GesturePointer pointer, Pen pen) {
    pointer.page
      ..penPreviewPosition = pointer.position
      ..penPreviewRadius = pen.options.size / 2
      ..penPreviewColor = pen.color;
  }

  /// Feeds the scribble detector and, once it sees a scribble,
  /// erases what the pointer crosses instead of drawing.
  ///
  /// Returns whether the pointer is erasing.
  bool _eraseScribble(GesturePointer pointer, Pen pen) {
    if (!stows.scribbleToErase.value) return false;

    final page = pointer.page;
    final lineHeight = (page.lineHeight ?? stows.gridSize.value).toDouble();
    final erased = _scribble.update(
      pointer.position,
      page.activeLayerStrokes,
      pen.options.size,
      page: page,
      lineHeight: lineHeight > 0 ? lineHeight : fallbackLineHeight,
    );
    if (_scribble.state != ScribbleState.erasing) return false;

    Pen.currentStroke = null;
    for (final stroke in erased) {
      page.removeStroke(stroke);
    }
    page.eraserCursorPosition = pointer.position;
    page.eraserCursorRadius = ScribbleDetector.eraserRadius;
    return true;
  }

  /// Records what a scribble erased. Returns whether it erased anything.
  bool _endScribble(GesturePointer pointer, Pen pen) {
    final erased = _scribble.end();
    final erasedImages = _scribble.getAndClearErasedImages();
    pen.onDragEnd();
    pointer.page.eraserCursorPosition = null;
    pointer.page.eraserCursorRadius = null;
    if (erased.isEmpty && erasedImages.isEmpty) return _scribble.erasedText;

    _host.history.recordChange(
      EditorHistoryItem(
        type: .erase,
        pageIndex: pointer.pageIndex,
        strokes: erased,
        images: erasedImages,
      ),
    );
    return true;
  }

  /// Conceals or reveals the tape under [tap] if [tap] is short enough to be
  /// a tap and not a stroke. Returns whether it found tape to toggle.
  bool _toggleTappedTape(EditorPage page, Stroke tap) {
    if (tap.length > tapMaxPoints) return false;
    final first = tap.firstPoint;
    final last = tap.lastPoint;
    if (first == null || last == null) return false;
    if ((last - first).distance >= tapSlop) return false;

    final tape = page.strokes.reversed.whereType<TapeStroke>().firstWhereOrNull(
      (tape) => tape.rect.inflate(tapeTapMargin).contains(first),
    );
    if (tape == null) return false;

    tape.toggleConceal();
    page.redrawStrokes();
    _host.autosaveAfterDelay();
    return true;
  }

  static bool _shouldStraighten(Pen pen, Stroke stroke) {
    if (pen is ShapePen) return false;
    if (!stows.autoStraightenLines.value && pen is! Highlighter) return false;
    return stroke.isStraightLine();
  }
}
