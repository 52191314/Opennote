/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/zoom_window_view.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/floating_pen_menu.dart';
import 'package:saber/components/toolbar/opennote_toolbar.dart';
import 'package:saber/components/toolbar/toolbar.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/editor/zoom_window.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/pen.dart';

/// Stacks the main interactive canvas with optional floating overlays
/// (classic writing pen menu and zoom writing window).
class EditorEditingSurface extends StatelessWidget {
  /// Creates an [EditorEditingSurface].
  const EditorEditingSurface({
    super.key,
    required this.canvas,
    required this.opennoteUiMode,
    required this.currentTool,
    required this.onRefreshUi,
    required this.zoomWindowOpen,
    required this.zoomWindowController,
    required this.zoomPage,
    required this.zoomPageIndex,
    required this.history,
    required this.zoomPenProvider,
    required this.onDismissZoomWindow,
    required this.onZoomStrokeStarted,
    required this.onZoomStrokeCommitted,
  });

  /// The primary canvas gesture detector widget.
  final Widget canvas;

  /// Whether Opennote Studio chrome is active.
  final bool opennoteUiMode;

  /// Currently active tool singleton.
  final Tool currentTool;

  /// Callback to refresh editor UI when pen menu options change.
  final VoidCallback onRefreshUi;

  /// Whether the precision zoom window overlay is open.
  final bool zoomWindowOpen;

  /// Controller for the zoom writing window.
  final ZoomWindowController zoomWindowController;

  /// Page targeted by the zoom window, or `null` if no pages exist.
  final EditorPage? zoomPage;

  /// Zero-based index of [zoomPage].
  final int? zoomPageIndex;

  /// Editor undo/redo history for zoom window strokes.
  final EditorHistory history;

  /// Resolves the active pen for zoom window drawing.
  final Pen Function() zoomPenProvider;

  /// Dismisses the zoom window overlay.
  final VoidCallback onDismissZoomWindow;

  /// Called when a stroke begins inside the zoom window.
  final VoidCallback onZoomStrokeStarted;

  /// Called when a stroke finishes inside the zoom window.
  final VoidCallback onZoomStrokeCommitted;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        canvas,
        if (!opennoteUiMode && Pen.isWritingPen(currentTool))
          Positioned.fill(
            child: WritingPenMenu(tool: currentTool, onChanged: onRefreshUi),
          ),
        if (zoomWindowOpen && zoomPage != null && zoomPageIndex != null)
          ZoomWindowPanel(
            controller: zoomWindowController,
            page: zoomPage!,
            pageIndex: zoomPageIndex!,
            history: history,
            pen: zoomPenProvider,
            onDismiss: onDismissZoomWindow,
            onStrokeStarted: onZoomStrokeStarted,
            onStrokeCommitted: onZoomStrokeCommitted,
          ),
      ],
    );
  }
}

/// Switches cleanly between the modern [OpennoteToolbar] and classic [Toolbar].
class EditorToolbarHost extends StatelessWidget {
  /// Creates an [EditorToolbarHost].
  const EditorToolbarHost({
    super.key,
    required this.opennoteUiMode,
    required this.actions,
    required this.onClearPage,
    required this.zoomWindowOpen,
    required this.onToggleZoomWindow,
    required this.undo,
    required this.isUndoPossible,
    required this.redo,
    required this.isRedoPossible,
    required this.toggleFingerDrawing,
    required this.exportAsSba,
    required this.exportAsPdf,
    required this.exportAsPng,
  });

  /// Whether Opennote Studio UI mode is enabled.
  final bool opennoteUiMode;

  /// Shared toolbar action descriptors.
  final EditorToolbarActions actions;

  /// Clears the active page.
  final VoidCallback onClearPage;

  /// Whether the zoom writing window is currently open.
  final bool zoomWindowOpen;

  /// Toggles the zoom writing window.
  final VoidCallback onToggleZoomWindow;

  /// Undo/redo controls for classic toolbar mode.
  final VoidCallback undo;
  final bool isUndoPossible;
  final VoidCallback redo;
  final bool isRedoPossible;

  /// Toggles finger drawing in classic toolbar mode.
  final VoidCallback toggleFingerDrawing;

  /// Export handlers for classic toolbar mode.
  final Future<void> Function(BuildContext)? exportAsSba;
  final Future<void> Function(BuildContext)? exportAsPdf;
  final Future<void> Function(BuildContext)? exportAsPng;

  @override
  Widget build(BuildContext context) {
    if (opennoteUiMode) {
      return RepaintBoundary(
        child: OpennoteToolbar(
          actions: actions,
          onClearPage: onClearPage,
          zoomWindowOpen: zoomWindowOpen,
          onToggleZoomWindow: onToggleZoomWindow,
        ),
      );
    }

    return Toolbar(
      actions: actions,
      undo: undo,
      isUndoPossible: isUndoPossible,
      redo: redo,
      isRedoPossible: isRedoPossible,
      toggleFingerDrawing: toggleFingerDrawing,
      exportAsSba: exportAsSba,
      exportAsPdf: exportAsPdf,
      exportAsPng: exportAsPng,
    );
  }
}
