/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:ui';

import 'package:saber/data/editor/page.dart';
import 'package:saber/data/tools/select.dart';

/// The handles around a finished selection on an [EditorPage].
extension SelectionHandles on EditorPage {
  /// How far above the selection the rotation handle sits.
  static const rotationHandleOffset = 20.0;

  /// Removes every selection handle from this page.
  void clearSelectionHandles() {
    selectionDeleteButtonRect = null;
    selectionRotationHandleCenter = null;
    selectionResizeHandles = null;
    selectionVertexHandles = null;
  }

  /// Places the rotation, resize, and vertex handles around [selection].
  void placeSelectionHandles(SelectResult selection) {
    final bounds = selection.path.getBounds();
    final vertexHandles = selection.vertexHandles;
    selectionDeleteButtonRect = null;
    selectionRotationHandleCenter =
        bounds.topCenter - const Offset(0, rotationHandleOffset);
    selectionResizeHandles = [
      bounds.topLeft,
      bounds.topCenter,
      bounds.topRight,
      bounds.centerRight,
      bounds.bottomRight,
      bounds.bottomCenter,
      bounds.bottomLeft,
      bounds.centerLeft,
    ];
    selectionVertexHandles = vertexHandles.isEmpty ? null : vertexHandles;
  }

  /// Places the handles around what [select] selected,
  /// or unselects and clears them if it selected nothing.
  void showSelectionHandles(Select select) {
    if (select.selectResult.isNotEmpty) {
      return placeSelectionHandles(select.selectResult);
    }
    select.unselect();
    clearSelectionHandles();
  }
}
