/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:ui';

import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/gestures/tool_gesture.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/editor/selection_handles.dart';
import 'package:saber/data/editor/selection_resize.dart';
import 'package:saber/data/editor/selection_rotation.dart';
import 'package:saber/data/editor/selection_transform.dart';
import 'package:saber/data/tools/select.dart';
import 'package:sbn/change.dart';

/// Lassos, taps, moves, and reshapes selections for the [Select] tool.
class SelectGesture implements ToolGesture {
  SelectGesture(this._host);

  final EditorGestureHost _host;

  /// The longest gap between two taps that still makes a double tap.
  static const doubleTapTimeout = Duration(milliseconds: 300);

  /// The furthest apart two taps can be and still make a double tap.
  static const doubleTapSlop = 20.0;

  /// How close a touch must be to a vertex or rotation handle to grab it.
  static const handleHitRadius = 20.0;

  /// How close a touch must be to a resize handle to grab it.
  static const resizeHandleHitRadius = 16.0;

  /// A lasso smaller than this in both directions counts as a tap.
  static const tapSlop = 20.0;

  DateTime? _lastTapTime;
  Offset? _lastTapPosition;

  /// The resize handle drag in progress, if any.
  SelectionResize? _resize;

  /// The resize, rotation, or vertex edit in progress, once it has changed
  /// something. Recorded in the history when the gesture ends.
  SelectionTransform? _transform;

  var _isRotating = false;

  /// The pointer's angle around the selection at the previous rotation
  /// update, or 0 before the first one.
  double _previousAngle = 0;

  /// The index of the vertex handle being dragged, if any.
  int? _draggedVertex;

  /// Forgets a reshape that an interrupted gesture left unrecorded.
  void forgetTransform() => _transform = null;

  /// Lets go of the resize or rotation handle being dragged.
  void releaseHandle() {
    _isRotating = false;
    _previousAngle = 0;
    _resize = null;
  }

  @override
  bool start(GesturePointer pointer) {
    final select = Select.currentSelect;
    final hasSelectionHere =
        select.doneSelecting &&
        select.selectResult.pageIndex == pointer.pageIndex;
    if (!hasSelectionHere) {
      _beginLasso(pointer);
      return true;
    }
    if (_isDoubleTap(pointer.position)) {
      _replaceSelection(pointer);
      return false;
    }
    if (_grabHandle(pointer)) return false;
    if (select.selectResult.path.contains(pointer.position)) return true;
    _replaceSelection(pointer);
    return true;
  }

  @override
  void update(GesturePointer pointer) {
    _follow(pointer);
    pointer.page.redrawStrokes();
  }

  @override
  bool end(GesturePointer pointer) {
    if (_draggedVertex != null) return _endVertexDrag(pointer);

    final select = Select.currentSelect;
    final isReshaping = _isRotating || _resize != null;
    if (pointer.moved == Offset.zero && !isReshaping) {
      if (_isTap(select)) return _tapSelect(pointer);
      if (select.doneSelecting) return true;
    }
    if (isReshaping) {
      _recordTransform(pointer.pageIndex);
      return true;
    }
    if (select.doneSelecting) {
      _recordMove(pointer);
      return true;
    }
    return _endLasso(pointer);
  }

  void _beginLasso(GesturePointer pointer) {
    Select.currentSelect.onDragStart(pointer.position, pointer.pageIndex);
    _host.history.canRedo = true;
  }

  void _replaceSelection(GesturePointer pointer) {
    Select.currentSelect.unselect();
    pointer.page.clearSelectionHandles();
    _draggedVertex = null;
    _beginLasso(pointer);
  }

  bool _isDoubleTap(Offset position) {
    final lastTime = _lastTapTime;
    final lastPosition = _lastTapPosition;
    if (lastTime == null || lastPosition == null) return false;
    return DateTime.now().difference(lastTime) < doubleTapTimeout &&
        (position - lastPosition).distance < doubleTapSlop;
  }

  /// Returns whether the touch landed on the delete button or on a handle.
  bool _grabHandle(GesturePointer pointer) {
    final page = pointer.page;
    final position = pointer.position;
    if (page.selectionDeleteButtonRect?.contains(position) ?? false) {
      _host.deleteSelection(page);
      return true;
    }
    final vertex = _vertexHandleAt(page, position);
    if (vertex != null) {
      _draggedVertex = vertex;
      return true;
    }
    final resizeHandle = _handleNear(
      page.selectionResizeHandles,
      position,
      resizeHandleHitRadius,
    );
    if (resizeHandle != null) {
      _resize = SelectionResize(
        startBounds: Select.currentSelect.selectResult.path.getBounds(),
        handleIndex: resizeHandle,
      );
      return true;
    }
    final rotationHandle = page.selectionRotationHandleCenter;
    if (rotationHandle == null) return false;
    if ((position - rotationHandle).distance >= handleHitRadius) return false;
    _isRotating = true;
    _previousAngle = 0;
    return true;
  }

  int? _vertexHandleAt(EditorPage page, Offset position) {
    final strokes = Select.currentSelect.selectResult.strokes;
    if (strokes.length != 1) return null;
    final stroke = strokes.first;
    if (stroke is! ArrowStroke && stroke is! DimensionStroke) return null;
    return _handleNear(page.selectionVertexHandles, position, handleHitRadius);
  }

  static int? _handleNear(
    List<Offset>? handles,
    Offset position,
    double radius,
  ) {
    if (handles == null) return null;
    final index = handles.indexWhere(
      (handle) => (position - handle).distance < radius,
    );
    return index < 0 ? null : index;
  }

  void _follow(GesturePointer pointer) {
    if (_draggedVertex != null) return _dragVertex(pointer);
    final select = Select.currentSelect;
    if (!select.doneSelecting) return select.onDragUpdate(pointer.position);
    final resize = _resize;
    if (resize != null) return _resizeTo(pointer, resize);
    if (_isRotating) return _rotateTo(pointer);
    _move(pointer);
  }

  void _dragVertex(GesturePointer pointer) {
    final selection = Select.currentSelect.selectResult;
    _transform ??= SelectionTransform.begin(pointer.page, selection);
    final stroke = selection.strokes.first;
    switch (stroke) {
      case ArrowStroke():
        _moveArrowEnd(stroke, pointer.position);
      case DimensionStroke():
        _moveDimensionVertex(stroke, pointer.position);
      default:
        return;
    }
    stroke.markPolygonNeedsUpdating();
    selection.path = Select.createTightSelectionPath(stroke.lowQualityPolygon);
  }

  void _moveArrowEnd(ArrowStroke arrow, Offset position) {
    if (_draggedVertex == 0) arrow.start = position;
    if (_draggedVertex == 1) arrow.end = position;
  }

  void _moveDimensionVertex(DimensionStroke dimension, Offset position) {
    switch (_draggedVertex) {
      case 0:
        dimension.start = position;
        dimension.text = _lengthLabel(dimension);
      case 1:
        dimension.end = position;
        dimension.text = _lengthLabel(dimension);
      case 2:
        _slideDimensionLine(dimension, position);
    }
  }

  static String _lengthLabel(DimensionStroke dimension) {
    final length = (dimension.end - dimension.start).distance;
    return '${length.toStringAsFixed(1)} px';
  }

  /// Moves the dimension line so that it passes through [position],
  /// keeping it parallel to the points it measures between.
  static void _slideDimensionLine(DimensionStroke dimension, Offset position) {
    final direction = dimension.end - dimension.start;
    final length = direction.distance;
    if (length <= 0.001) return;
    final perpendicular = Offset(-direction.dy / length, direction.dx / length);
    dimension.offset =
        (position.dx - dimension.start.dx) * perpendicular.dx +
        (position.dy - dimension.start.dy) * perpendicular.dy;
  }

  void _resizeTo(GesturePointer pointer, SelectionResize resize) {
    final page = pointer.page;
    final selection = Select.currentSelect.selectResult;
    _transform ??= SelectionTransform.begin(page, selection);
    final pivot = resize.pivot;
    final scale = resize.stepTo(pointer.position);

    for (final stroke in selection.strokes) {
      stroke.scaleAround(scale.x, scale.y, pivot);
    }
    for (final image in selection.images) {
      final rect = image.dstRect;
      image.dstRect = Rect.fromCenter(
        center: _scaleOffsetAround(rect.center, scale, pivot),
        width: rect.width * scale.x,
        height: rect.height * scale.y,
      );
    }
    if (selection.textSelected) {
      page.textContentOffset = _scaleOffsetAround(
        page.textContentOffset,
        scale,
        pivot,
      );
    }
    selection.path = scalePathAround(selection.path, scale.x, scale.y, pivot);
  }

  static Offset _scaleOffsetAround(Offset point, Scale scale, Offset pivot) =>
      Offset(
        pivot.dx + (point.dx - pivot.dx) * scale.x,
        pivot.dy + (point.dy - pivot.dy) * scale.y,
      );

  void _rotateTo(GesturePointer pointer) {
    final page = pointer.page;
    final selection = Select.currentSelect.selectResult;
    _transform ??= SelectionTransform.begin(page, selection);
    final center = selection.path.getBounds().center;
    final angle = (pointer.position - center).direction;
    if (_previousAngle == 0) _previousAngle = angle;
    final turn = angle - _previousAngle;
    _previousAngle = angle;

    for (final stroke in selection.strokes) {
      stroke.rotateAround(turn, center);
    }
    for (final image in selection.images) {
      final rect = image.dstRect;
      image.dstRect = Rect.fromCenter(
        center: rotateOffsetAround(rect.center, turn, center),
        width: rect.width,
        height: rect.height,
      );
    }
    if (selection.textSelected) page.textContentRotation += turn;
    selection.path = rotatePathAround(selection.path, turn, center);
  }

  void _move(GesturePointer pointer) {
    final selection = Select.currentSelect.selectResult;
    for (final stroke in selection.strokes) {
      stroke.shift(pointer.delta);
    }
    for (final image in selection.images) {
      image.dstRect = image.dstRect.shift(pointer.delta);
    }
    if (selection.textSelected) {
      pointer.page.textContentOffset += pointer.delta;
    }
    selection.path = selection.path.shift(pointer.delta);
  }

  bool _endVertexDrag(GesturePointer pointer) {
    _draggedVertex = null;
    pointer.page.placeSelectionHandles(Select.currentSelect.selectResult);
    _recordTransform(pointer.pageIndex);
    return true;
  }

  /// Whether the pointer lifted without having drawn a lasso.
  static bool _isTap(Select select) {
    if (select.doneSelecting) return false;
    final bounds = select.selectResult.path.getBounds();
    return bounds.isEmpty ||
        (bounds.width < tapSlop && bounds.height < tapSlop);
  }

  bool _tapSelect(GesturePointer pointer) {
    final page = pointer.page;
    final select = Select.currentSelect;
    select.tapSelect(
      pointer.position,
      page.strokes,
      page.images,
      pointer.pageIndex,
      textRect: _textRect(page),
    );
    page.showSelectionHandles(select);
    _lastTapTime = DateTime.now();
    _lastTapPosition = pointer.position;
    return false;
  }

  bool _endLasso(GesturePointer pointer) {
    final page = pointer.page;
    final select = Select.currentSelect;
    select.onDragEnd(page.strokes, page.images, textRect: _textRect(page));
    page.showSelectionHandles(select);
    return false;
  }

  Rect _textRect(EditorPage page) =>
      page.computeTextContentRect(_host.lineHeight.toDouble());

  /// Records the resize, rotation, or vertex edit that just ended,
  /// unless the gesture ended before changing anything.
  void _recordTransform(int pageIndex) {
    final transform = _transform;
    _transform = null;
    if (transform == null) return;
    _host.history.recordChange(transform.finish(pageIndex: pageIndex));
  }

  void _recordMove(GesturePointer pointer) {
    final page = pointer.page;
    final selection = Select.currentSelect.selectResult;
    final moved = pointer.moved;
    _host.history.recordChange(
      EditorHistoryItem(
        type: .move,
        pageIndex: pointer.pageIndex,
        strokes: selection.strokes,
        images: selection.images,
        offset: .fromLTRB(moved.dx, moved.dy, moved.dx, moved.dy),
        textPlacementChange: selection.textSelected
            ? Change(
                previous: (
                  offset: page.textContentOffset - moved,
                  rotation: page.textContentRotation,
                ),
                current: page.textPlacement,
              )
            : null,
      ),
    );
  }
}
