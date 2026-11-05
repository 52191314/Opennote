/// 🤖 Generated wholely or partially with Grok 4.7
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/study_tape.dart';

/// Keys for the zoom window, the on-page box, and the toolbar control.
abstract final class ZoomWindowKeys {
  static const toolbarButton = ValueKey<String>('zoom-window-toolbar');
  static const window = ValueKey<String>('zoom-window');
  static const pageBox = ValueKey<String>('zoom-page-box');
  static const dismiss = ValueKey<String>('zoom-window-dismiss');
  static const advanceRegion = ValueKey<String>('zoom-advance-region');
  static const newLine = ValueKey<String>('zoom-window-new-line');
  static const autoAdvance = ValueKey<String>('zoom-window-auto-advance');
}

/// The pen a zoom window writes with.
///
/// Uses the active writing pen, pencil, or highlighter. Other tools keep
/// their singleton and the window writes with [Pen.currentPen].
Pen penForZoomWindow(Tool tool) {
  if (tool is StudyTapeTool) return Pen.currentPen;
  if (tool is Pencil) return tool;
  if (tool is Highlighter) return tool;
  if (Pen.isWritingPen(tool)) return tool as Pen;
  return Pen.currentPen;
}

/// Magnified writing region: an on-page zoom box and a floating window.
///
/// Window coordinates map onto the zoom box. A smaller box magnifies more
/// because a window distance covers less of the page. Moving the window
/// does not change the box. Moving the box changes the magnified region.
class ZoomWindowController extends ChangeNotifier {
  static const _minExtent = 24.0;

  /// How tall the window chrome is above [windowRect].
  ///
  /// [windowRect] is the ink surface. The chrome sits above it, so a freshly
  /// opened window starts far enough down that the chrome stays on screen.
  static const chromeHeight = 72.0;

  Rect _pageBounds = Rect.zero;
  Rect _zoomBox = Rect.zero;
  var _windowRect = const Rect.fromLTWH(24, 96, 320, 150);
  double _lineStartX = 0;
  double _returnHeight = 48;
  var _autoAdvance = true;
  var _advanceArmed = false;
  Offset? _lastPointer;

  /// The page rectangle the zoom box is clipped to.
  Rect get pageBounds => _pageBounds;

  /// The page region the window magnifies.
  Rect get zoomBox => _zoomBox;

  /// The ink surface, in the same coordinates the overlay uses.
  Rect get windowRect => _windowRect;

  /// Page x the box returns to at a new line.
  double get lineStartX => _lineStartX;

  /// How far a new line shifts the zoom box down.
  double get returnHeight => _returnHeight;

  set returnHeight(double value) {
    if (value == _returnHeight) return;
    _returnHeight = value;
    notifyListeners();
  }

  /// Whether writing past the advance region moves the zoom box.
  bool get autoAdvance => _autoAdvance;

  set autoAdvance(bool value) {
    if (value == _autoAdvance) return;
    _autoAdvance = value;
    notifyListeners();
  }

  /// Horizontal magnification: window width divided by zoom-box width.
  double get magnificationX {
    if (_zoomBox.width == 0) return 1;
    return _windowRect.width / _zoomBox.width;
  }

  /// The right half of the window, after a stroke crosses its middle.
  ///
  /// Null when auto-advance is off or no stroke has crossed the middle yet.
  Rect? get advanceRegion {
    if (!_autoAdvance || !_advanceArmed) return null;
    final mid = _windowRect.center.dx;
    return Rect.fromLTRB(
      mid,
      _windowRect.top,
      _windowRect.right,
      _windowRect.bottom,
    );
  }

  /// Places the zoom box on a visible region of [pageBounds].
  void openForPage(Rect pageBounds) {
    _pageBounds = pageBounds;
    _zoomBox = _defaultZoomBox(pageBounds);
    _lineStartX = _zoomBox.left;
    _windowRect = const Rect.fromLTWH(24, 96, 320, 150);
    _advanceArmed = false;
    _lastPointer = null;
    notifyListeners();
  }

  /// Maps a point on the ink surface to the page.
  ///
  /// The window's top-left lands on the zoom box's top-left. Distances scale
  /// by zoom-box size over window size, so a smaller box magnifies more.
  Offset pagePointFor(Offset windowPoint) {
    return _zoomBox.topLeft + _pageDeltaFor(windowPoint - _windowRect.topLeft);
  }

  /// How far [windowDelta] travels on the page at the current magnification.
  Offset pageDeltaForWindowDelta(Offset windowDelta) {
    return _pageDeltaFor(windowDelta);
  }

  /// Changes width and height together, keeping the box's aspect ratio.
  void resizeCorner(Offset delta) {
    final box = _zoomBox;
    if (box.width == 0 || box.height == 0) return;

    final aspect = box.width / box.height;
    final scaleW = (box.width + delta.dx) / box.width;
    final scaleH = (box.height + delta.dy) / box.height;
    var scale = (scaleW + scaleH) / 2;
    final minScale = math.max(_minExtent / box.width, _minExtent / box.height);
    if (scale < minScale) scale = minScale;

    final width = box.width * scale;
    final height = width / aspect;
    _zoomBox = Rect.fromLTWH(box.left, box.top, width, height);
    notifyListeners();
  }

  /// Changes only the zoom box height.
  void resizeHeight(double deltaHeight) {
    final box = _zoomBox;
    final height = math.max(_minExtent, box.height + deltaHeight);
    _zoomBox = Rect.fromLTWH(box.left, box.top, box.width, height);
    notifyListeners();
  }

  /// Moves the floating window. The magnified page region stays put.
  void moveWindowBy(Offset delta) {
    var next = _windowRect.shift(delta);
    if (next.top < chromeHeight) {
      next = next.shift(Offset(0, chromeHeight - next.top));
    }
    if (next.left < 0) {
      next = next.shift(Offset(-next.left, 0));
    }
    _windowRect = next;
    notifyListeners();
  }

  /// Moves the on-page zoom box, and the line start moves with it.
  void moveZoomBoxBy(Offset delta) {
    _zoomBox = _contained(_zoomBox.shift(delta));
    _lineStartX = _zoomBox.left;
    notifyListeners();
  }

  /// Feeds one ink-surface sample.
  ///
  /// Returns the page point for this sample before any auto-advance the
  /// sample itself causes. With auto-advance on, a stroke that crosses the
  /// window's horizontal middle arms the advance region. Later samples in
  /// that region move the zoom box forward. Past the page's right edge, the
  /// box drops by [returnHeight] and returns to [lineStartX].
  Offset ingestPointer(Offset windowPoint, {required bool strokeStart}) {
    final mapped = pagePointFor(windowPoint);
    final previous = strokeStart ? null : _lastPointer;
    _lastPointer = windowPoint;
    if (!_autoAdvance) return mapped;

    final mid = _windowRect.center.dx;
    final crossed =
        previous != null && previous.dx < mid && windowPoint.dx >= mid;
    if (crossed) _advanceArmed = true;
    if (!_advanceArmed || previous == null || windowPoint.dx < mid) {
      if (crossed) notifyListeners();
      return mapped;
    }

    final pageDx = (windowPoint.dx - math.max(previous.dx, mid)) * _scaleX;
    if (pageDx <= 0) {
      if (crossed) notifyListeners();
      return mapped;
    }

    final shifted = _zoomBox.shift(Offset(pageDx, 0));
    _zoomBox = shifted.right > _pageBounds.right ? _wrapped() : shifted;
    notifyListeners();
    return mapped;
  }

  /// Forgets the pointer that ended, and keeps the advance region armed.
  void endStroke() {
    _lastPointer = null;
  }

  /// Shifts the zoom box down by [returnHeight] and back to the line start.
  void newLine() {
    _zoomBox = _wrapped();
    _advanceArmed = false;
    _lastPointer = null;
    notifyListeners();
  }

  Offset _pageDeltaFor(Offset windowDelta) {
    return Offset(windowDelta.dx * _scaleX, windowDelta.dy * _scaleY);
  }

  double get _scaleX {
    final width = _windowRect.width;
    if (width == 0) return 1;
    return _zoomBox.width / width;
  }

  double get _scaleY {
    final height = _windowRect.height;
    if (height == 0) return 1;
    return _zoomBox.height / height;
  }

  Rect _wrapped() {
    return Rect.fromLTWH(
      _lineStartX,
      _zoomBox.top + _returnHeight,
      _zoomBox.width,
      _zoomBox.height,
    );
  }

  Rect _contained(Rect box) {
    var dx = 0.0;
    var dy = 0.0;
    if (box.width <= _pageBounds.width) {
      if (box.left < _pageBounds.left) dx = _pageBounds.left - box.left;
      if (box.right > _pageBounds.right) dx = _pageBounds.right - box.right;
    }
    if (box.height <= _pageBounds.height) {
      if (box.top < _pageBounds.top) dy = _pageBounds.top - box.top;
      if (box.bottom > _pageBounds.bottom) dy = _pageBounds.bottom - box.bottom;
    }
    if (dx == 0 && dy == 0) return box;
    return box.shift(Offset(dx, dy));
  }

  static Rect _defaultZoomBox(Rect page) {
    if (page.width <= 0 || page.height <= 0) {
      return Rect.fromLTWH(page.left, page.top, _minExtent, _minExtent);
    }

    final width = math.min(page.width * 0.45, page.width);
    final height = math.min(
      math.max(page.height * 0.12, _minExtent),
      page.height,
    );
    var box = Rect.fromLTWH(
      page.left + page.width * 0.12,
      page.top + page.height * 0.18,
      width,
      height,
    );
    if (box.right > page.right) {
      box = box.shift(Offset(page.right - box.right, 0));
    }
    if (box.bottom > page.bottom) {
      box = box.shift(Offset(0, page.bottom - box.bottom));
    }
    if (box.left < page.left) {
      box = box.shift(Offset(page.left - box.left, 0));
    }
    if (box.top < page.top) {
      box = box.shift(Offset(0, page.top - box.top));
    }
    return box;
  }
}

/// Writes zoom-window ink as an ordinary page stroke.
///
/// Points are mapped through [ZoomWindowController.pagePointFor] and then
/// follow the same pen insertion and draw-history path as a stroke drawn
/// on the page. One [undoDraw] removes that history item.
class ZoomInk {
  ZoomInk({
    required this.zoom,
    required this.pen,
    required this.page,
    required this.pageIndex,
    required this.history,
  });

  final ZoomWindowController zoom;
  final Pen pen;
  final EditorPage page;
  final int pageIndex;
  final EditorHistory history;

  /// Starts a stroke at [windowPoint].
  void begin(Offset windowPoint) {
    final pagePoint = zoom.ingestPointer(windowPoint, strokeStart: true);
    pen.onDragStart(pagePoint, page, pageIndex, null);
    page.redrawStrokes();
  }

  /// Extends the stroke that [begin] started.
  void extend(Offset windowPoint) {
    final pagePoint = zoom.ingestPointer(windowPoint, strokeStart: false);
    pen.onDragUpdate(pagePoint, null);
    page.redrawStrokes();
  }

  /// Inserts the finished stroke and records one draw history item.
  ///
  /// Returns null when the pen produced nothing or the active layer rejected it.
  Stroke? end() {
    final stroke = pen.onDragEnd();
    zoom.endStroke();
    if (stroke == null || stroke.isEmpty) return null;

    final before = page.activeLayerStrokes.length;
    page.insertStroke(stroke);
    if (page.activeLayerStrokes.length == before) return null;

    history.recordChange(
      EditorHistoryItem(
        type: .draw,
        pageIndex: pageIndex,
        strokes: [stroke],
        images: const [],
      ),
    );
    page.redrawStrokes();
    return stroke;
  }

  /// Draws [windowPoints] through [begin], [extend], and [end].
  Stroke? commit(List<Offset> windowPoints) {
    if (windowPoints.isEmpty) return null;
    begin(windowPoints.first);
    for (final point in windowPoints.skip(1)) {
      extend(point);
    }
    return end();
  }

  /// Undoes the last draw the same way the editor undoes a page stroke.
  ///
  /// Pops one history item and, when it is a draw, removes its strokes
  /// from [page].
  static EditorHistoryItem undoDraw(EditorHistory history, EditorPage page) {
    final item = history.undo();
    if (item.type != .draw) {
      throw StateError('Expected a draw stroke to undo');
    }
    for (final stroke in item.strokes) {
      page.removeStroke(stroke);
    }
    for (final image in item.images) {
      page.images.remove(image);
    }
    page.redrawStrokes();
    return item;
  }
}
