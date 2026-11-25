/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pen_tray.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/select.dart';

/// Stateless tool-switching and color-mutation helpers that preserve
/// tool singleton identities (`Pen.currentPen`, `Highlighter.currentHighlighter`,
/// `Pencil.currentPencil`, `Eraser.currentEraser`, `Select.currentSelect`).
abstract final class EditorToolActions {
  /// Resolves the next active [Tool] and updates matching tool singletons
  /// in-place without re-instantiating them.
  static Tool selectTool({
    required Tool requestedTool,
    required Tool currentTool,
    required Tool lastNonEraserTool,
  }) {
    final nextTool = (requestedTool is Eraser && currentTool is Eraser)
        ? lastNonEraserTool
        : requestedTool;
    if (nextTool is Highlighter) {
      Highlighter.currentHighlighter = nextTool;
    } else if (nextTool is Pencil) {
      Pencil.currentPencil = nextTool;
    } else if (Pen.isWritingPen(nextTool)) {
      Pen.currentPen = nextTool as Pen;
    }
    return nextTool;
  }

  /// Applies [color] in-place to the active writing tool or active selection.
  static void applyToolColor({
    required Tool currentTool,
    required Color color,
    required ValueChanged<Color> onUpdateColorBar,
    required ValueChanged<Color> onSelectionColor,
  }) {
    onUpdateColorBar(color);
    switch (currentTool) {
      case final Highlighter highlighter:
        highlighter.color = color.withAlpha(Highlighter.alpha);
      case final Pen pen:
        pen.color = color;
        if (Pen.isWritingPen(pen)) PenTray.remember(pen);
      case Select():
        onSelectionColor(color);
      default:
    }
  }

  /// Toggles between [Tool.textEditing] and [Pen.currentPen], updating focus.
  static Tool toggleTextEditing({
    required Tool currentTool,
    required List<EditorPage> pages,
    required int currentPageIndex,
    required ValueNotifier<QuillStruct?> quillFocus,
  }) {
    if (currentTool != Tool.textEditing) {
      quillFocus.value = pages[currentPageIndex].quill
        ..focusNode.requestFocus();
      return Tool.textEditing;
    }
    for (final page in pages) {
      page.quill.controller.moveCursorToPosition(
        page.quill.controller.selection.extentOffset,
      );
      page.quill.focusNode.unfocus();
    }
    return Pen.currentPen;
  }

  /// Toggles the bookmark state on [currentPageIndex] if editable.
  static bool toggleBookmark({
    required EditorCoreInfo coreInfo,
    required int currentPageIndex,
  }) {
    if (coreInfo.readOnly || currentPageIndex >= coreInfo.pages.length) {
      return false;
    }
    final page = coreInfo.pages[currentPageIndex];
    page.bookmarked = !page.bookmarked;
    page.redrawStrokes();
    return true;
  }

  /// Starts or stops the periodic server-watch timer and updates
  /// `coreInfo.readOnlyReason` accordingly.
  static Timer? updateServerWatch({
    required bool watch,
    required Timer? existingTimer,
    required EditorCoreInfo coreInfo,
    required VoidCallback onPoll,
    required VoidCallback onChanged,
  }) {
    if (watch) {
      final timer =
          existingTimer ??
          Timer.periodic(const Duration(seconds: 5), (_) => onPoll());
      if (coreInfo.readOnlyReason != .watchingServer) {
        assert(coreInfo.readOnlyReason == null);
        coreInfo.readOnlyReason = .watchingServer;
        onChanged();
      }
      return timer;
    }
    existingTimer?.cancel();
    if (coreInfo.readOnlyReason == .watchingServer) {
      coreInfo.readOnlyReason = null;
      onChanged();
    }
    return null;
  }
}
