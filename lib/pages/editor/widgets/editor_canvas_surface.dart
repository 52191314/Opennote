/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/zoom_window.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/pages/editor/widgets/editor_canvas_page.dart';
import 'package:saber/pages/editor/widgets/editor_editing_surface.dart';

/// Groups the canvas gesture callbacks forwarded from `EditorState`.
class EditorCanvasGestures {
  /// Creates an [EditorCanvasGestures] bundle.
  const EditorCanvasGestures({
    required this.isDrawGesture,
    required this.onInteractionEnd,
    required this.onDrawStart,
    required this.onDrawUpdate,
    required this.onDrawEnd,
    required this.onHovering,
    required this.onHoveringEnd,
    required this.onStylusButtonChanged,
    required this.updatePointerData,
  });

  final bool Function(ScaleStartDetails) isDrawGesture;
  final ValueChanged<ScaleEndDetails> onInteractionEnd;
  final ValueChanged<ScaleStartDetails> onDrawStart;
  final ValueChanged<ScaleUpdateDetails> onDrawUpdate;
  final ValueChanged<ScaleEndDetails> onDrawEnd;
  final VoidCallback onHovering;
  final VoidCallback onHoveringEnd;
  final ValueChanged<bool> onStylusButtonChanged;
  final void Function(PointerDeviceKind, double?) updatePointerData;
}

/// Composes [CanvasGestureDetector] with floating pen menu and zoom window overlays.
class EditorCanvasSurface extends StatelessWidget {
  /// Creates an [EditorCanvasSurface].
  const EditorCanvasSurface({
    super.key,
    required this.canvasKey,
    required this.coreInfo,
    required this.explicitPageIndex,
    required this.currentPageIndex,
    required this.currentTool,
    required this.bookmarked,
    required this.hasTape,
    required this.opennoteUiMode,
    required this.history,
    required this.transformationController,
    required this.gestures,
    required this.pageBuilder,
    required this.undo,
    required this.redo,
    required this.onToggleBookmarked,
    required this.onRevealAllTape,
    required this.onConcealAllTape,
    required this.onLayersChanged,
    required this.onFitContent,
    required this.onRefreshUi,
    required this.zoomWindowOpen,
    required this.zoomWindowController,
    required this.zoomPageIndex,
    required this.zoomPenProvider,
    required this.onDismissZoomWindow,
    required this.onZoomStrokeStarted,
    required this.onZoomStrokeCommitted,
  });

  final GlobalKey<CanvasGestureDetectorState> canvasKey;
  final EditorCoreInfo coreInfo;
  final int? explicitPageIndex;
  final int currentPageIndex;
  final Tool currentTool;
  final bool bookmarked;
  final bool hasTape;
  final bool opennoteUiMode;
  final EditorHistory history;
  final TransformationController transformationController;
  final EditorCanvasGestures gestures;
  final Widget Function(BuildContext, int, [Rect?]) pageBuilder;
  final VoidCallback undo;
  final VoidCallback redo;
  final VoidCallback onToggleBookmarked;
  final VoidCallback onRevealAllTape;
  final VoidCallback onConcealAllTape;
  final VoidCallback onLayersChanged;
  final VoidCallback onFitContent;
  final VoidCallback onRefreshUi;
  final bool zoomWindowOpen;
  final ZoomWindowController zoomWindowController;
  final int? zoomPageIndex;
  final Pen Function() zoomPenProvider;
  final VoidCallback onDismissZoomWindow;
  final VoidCallback onZoomStrokeStarted;
  final VoidCallback onZoomStrokeCommitted;

  @override
  Widget build(BuildContext context) {
    final activePage = coreInfo.pages.isNotEmpty
        ? coreInfo.pages[currentPageIndex.clamp(0, coreInfo.pages.length - 1)]
        : null;

    return EditorEditingSurface(
      canvas: CanvasGestureDetector(
        key: canvasKey,
        filePath: coreInfo.filePath,
        isDrawGesture: gestures.isDrawGesture,
        onInteractionEnd: gestures.onInteractionEnd,
        onDrawStart: gestures.onDrawStart,
        onDrawUpdate: gestures.onDrawUpdate,
        onDrawEnd: gestures.onDrawEnd,
        onHovering: gestures.onHovering,
        onHoveringEnd: gestures.onHoveringEnd,
        onStylusButtonChanged: gestures.onStylusButtonChanged,
        updatePointerData: gestures.updatePointerData,
        undo: undo,
        redo: redo,
        pages: coreInfo.pages,
        initialPageIndex: coreInfo.initialPageIndex,
        explicitPageIndex: explicitPageIndex,
        pageBuilder: pageBuilder,
        isTextEditing: () => currentTool == Tool.textEditing,
        bookmarked: bookmarked,
        onToggleBookmarked: onToggleBookmarked,
        hasTape: hasTape,
        onRevealAllTape: onRevealAllTape,
        onConcealAllTape: onConcealAllTape,
        activePage: activePage,
        onLayersChanged: onLayersChanged,
        isInfiniteCanvas: coreInfo.isInfiniteCanvas,
        onFitContent: onFitContent,
        placeholderPageBuilder: (_, idx) => EditorCanvasPage.buildPlaceholder(
          coreInfo: coreInfo,
          pageIndex: idx,
          currentTool: currentTool,
        ),
        transformationController: transformationController,
      ),
      opennoteUiMode: opennoteUiMode,
      currentTool: currentTool,
      onRefreshUi: onRefreshUi,
      zoomWindowOpen: zoomWindowOpen,
      zoomWindowController: zoomWindowController,
      zoomPage: zoomPageIndex != null ? coreInfo.pages[zoomPageIndex!] : null,
      zoomPageIndex: zoomPageIndex,
      history: history,
      zoomPenProvider: zoomPenProvider,
      onDismissZoomWindow: onDismissZoomWindow,
      onZoomStrokeStarted: onZoomStrokeStarted,
      onZoomStrokeCommitted: onZoomStrokeCommitted,
    );
  }
}
