/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/foundation.dart';

/// Global drag coordinator for workspace items (notes and folders).
///
/// Tracks when an item is being dragged so dynamic workspace drop targets
/// like [TrashDropZone] can animate in and handle drag-and-drop operations.
class ItemDragState {
  ItemDragState._();

  /// The active item path currently being dragged, or null if no drag is active.
  static final activeDragItem = ValueNotifier<String?>(null);

  /// Whether an item drag operation is currently in progress.
  static bool get isDragging => activeDragItem.value != null;

  /// Mark the start of an item drag operation.
  static void startDrag(String itemPath) {
    activeDragItem.value = itemPath;
  }

  /// Mark the completion or cancellation of an item drag operation.
  static void endDrag() {
    activeDragItem.value = null;
  }
}
