/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:ui';

import 'package:vector_math/vector_math_64.dart' show Matrix4;

/// Horizontal and vertical scale factors.
typedef Scale = ({double x, double y});

/// A drag of one of the eight resize handles around a selection.
///
/// Scale factors are measured against [startBounds], the bounds the selection
/// had when the drag began, so the selection follows the pointer no matter
/// how many updates the drag is split into.
class SelectionResize {
  SelectionResize({required this.startBounds, required this.handleIndex});

  /// The bounds of the selection when the drag began.
  final Rect startBounds;

  /// Which handle is being dragged, as an index into
  /// `EditorPage.selectionResizeHandles`: clockwise from the top left corner.
  final int handleIndex;

  /// The smallest scale allowed, which stops the selection from flipping.
  static const minScale = 0.1;

  /// The largest scale allowed.
  static const maxScale = 10.0;

  Scale _applied = (x: 1, y: 1);

  bool get _dragsLeft => const {0, 6, 7}.contains(handleIndex);
  bool get _dragsRight => const {2, 3, 4}.contains(handleIndex);
  bool get _dragsTop => const {0, 1, 2}.contains(handleIndex);
  bool get _dragsBottom => const {4, 5, 6}.contains(handleIndex);

  /// The point that stays still during the resize:
  /// the corner or edge midpoint opposite the dragged handle.
  Offset get pivot => Offset(
    _dragsLeft
        ? startBounds.right
        : _dragsRight
        ? startBounds.left
        : startBounds.center.dx,
    _dragsTop
        ? startBounds.bottom
        : _dragsBottom
        ? startBounds.top
        : startBounds.center.dy,
  );

  /// The scale of the selection relative to [startBounds]
  /// when the handle has been dragged to [position].
  Scale scaleAt(Offset position) => (
    x: _clamp(
      _dragsLeft
          ? (startBounds.right - position.dx) / startBounds.width
          : _dragsRight
          ? (position.dx - startBounds.left) / startBounds.width
          : 1,
    ),
    y: _clamp(
      _dragsTop
          ? (startBounds.bottom - position.dy) / startBounds.height
          : _dragsBottom
          ? (position.dy - startBounds.top) / startBounds.height
          : 1,
    ),
  );

  /// The scale to apply around [pivot] to take the selection from where the
  /// previous call left it to where the handle is at [position].
  Scale stepTo(Offset position) {
    final target = scaleAt(position);
    final step = (x: target.x / _applied.x, y: target.y / _applied.y);
    _applied = target;
    return step;
  }

  static double _clamp(double scale) => scale.clamp(minScale, maxScale);
}

/// Returns [path] scaled by [scaleX] and [scaleY] around [pivot].
Path scalePathAround(Path path, double scaleX, double scaleY, Offset pivot) {
  final aroundPivot = Matrix4.identity()
    ..translateByDouble(pivot.dx, pivot.dy, 0, 1)
    ..scaleByDouble(scaleX, scaleY, 1, 1)
    ..translateByDouble(-pivot.dx, -pivot.dy, 0, 1);
  return path.transform(aroundPivot.storage);
}
