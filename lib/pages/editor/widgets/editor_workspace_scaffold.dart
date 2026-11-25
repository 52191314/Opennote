/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/components/canvas/save_indicator.dart';
import 'package:saber/components/editor/read_only_banner.dart';
import 'package:saber/components/theming/dynamic_material_app.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/zoom_window.dart';
import 'package:saber/data/extensions/color_extensions.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/pages/editor/widgets/editor_canvas_surface.dart';
import 'package:saber/pages/editor/widgets/editor_editing_surface.dart';
import 'package:saber/pages/editor/widgets/editor_fullscreen_exit_fab.dart';
import 'package:saber/pages/editor/widgets/editor_header_bar_host.dart';
import 'package:saber/pages/editor/widgets/editor_save_pop_scope.dart';
import 'package:saber/pages/editor/widgets/editor_surface_layout.dart';

/// Top-level editor workspace scaffold composing save-before-exit protection,
/// adaptive canvas background color, header bar, canvas surface, toolbar,
/// read-only banner, and fullscreen exit FAB.
class EditorWorkspaceScaffold extends StatelessWidget {
  /// Creates an [EditorWorkspaceScaffold].
  const EditorWorkspaceScaffold({
    super.key,
    required this.coreInfo,
    required this.opennoteUiMode,
    required this.autoInvert,
    required this.toolbarAlignment,
    required this.showToolbarInFullscreen,
    required this.savingState,
    required this.onTriggerSave,
    required this.onNeedsSaveNotice,
    required this.onShowVersionTooNewDialog,
    required this.canvasKey,
    required this.explicitPageIndex,
    required this.currentPageIndex,
    required this.currentTool,
    required this.hasTape,
    required this.history,
    required this.actions,
    required this.gestures,
    required this.transformationController,
    required this.pageBuilder,
    required this.customTitle,
    required this.filenameController,
    required this.filenameFormKey,
    required this.onRenameFile,
    required this.validateFilename,
    required this.needsNaming,
    required this.isHandScrollMode,
    required this.onToggleHandScrollMode,
    required this.onOpenPages,
    required this.onToggleBookmark,
    required this.onInsertPage,
    required this.onFitContent,
    required this.onUndo,
    required this.onRedo,
    required this.onExport,
    required this.onOpenMenu,
    required this.onLayersChanged,
    required this.onRefreshUi,
    required this.zoomWindowOpen,
    required this.zoomWindowController,
    required this.zoomPageIndex,
    required this.zoomPenProvider,
    required this.onDismissZoomWindow,
    required this.onZoomStrokeStarted,
    required this.onZoomStrokeCommitted,
    required this.onClearPage,
    required this.onToggleZoomWindow,
    required this.onToggleFingerDrawing,
    required this.exportAsSba,
    required this.exportAsPdf,
    required this.exportAsPng,
  });

  final EditorCoreInfo coreInfo;
  final bool opennoteUiMode;
  final bool autoInvert;
  final ValueListenable<AxisDirection> toolbarAlignment;
  final bool showToolbarInFullscreen;
  final ValueNotifier<SavingState> savingState;
  final VoidCallback onTriggerSave;
  final VoidCallback onNeedsSaveNotice;
  final VoidCallback onShowVersionTooNewDialog;
  final GlobalKey<CanvasGestureDetectorState> canvasKey;
  final int? explicitPageIndex;
  final int currentPageIndex;
  final Tool currentTool;
  final bool hasTape;
  final EditorHistory history;
  final EditorToolbarActions actions;
  final EditorCanvasGestures gestures;
  final TransformationController transformationController;
  final Widget Function(BuildContext, int, [Rect?]) pageBuilder;
  final String? customTitle;
  final TextEditingController filenameController;
  final GlobalKey<FormState> filenameFormKey;
  final ValueChanged<String> onRenameFile;
  final FormFieldValidator<String> validateFilename;
  final bool needsNaming;
  final bool isHandScrollMode;
  final VoidCallback onToggleHandScrollMode;
  final VoidCallback onOpenPages;
  final void Function({bool delayAutosave}) onToggleBookmark;
  final VoidCallback onInsertPage;
  final VoidCallback onFitContent;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onExport;
  final VoidCallback onOpenMenu;
  final VoidCallback onLayersChanged;
  final VoidCallback onRefreshUi;
  final bool zoomWindowOpen;
  final ZoomWindowController zoomWindowController;
  final int? zoomPageIndex;
  final Pen Function() zoomPenProvider;
  final VoidCallback onDismissZoomWindow;
  final VoidCallback onZoomStrokeStarted;
  final VoidCallback onZoomStrokeCommitted;
  final VoidCallback onClearPage;
  final VoidCallback onToggleZoomWindow;
  final VoidCallback onToggleFingerDrawing;
  final Future<void> Function(BuildContext)? exportAsSba;
  final Future<void> Function(BuildContext)? exportAsPdf;
  final Future<void> Function(BuildContext)? exportAsPng;

  @override
  Widget build(BuildContext context) {
    final isFullscreen = DynamicMaterialApp.isFullscreen;
    final isDark = Theme.brightnessOf(context) == Brightness.dark;
    final bookmarked =
        coreInfo.pages.isNotEmpty &&
        currentPageIndex < coreInfo.pages.length &&
        coreInfo.pages[currentPageIndex].bookmarked;
    final background = coreInfo.isInfiniteCanvas
        ? (coreInfo.backgroundColor ?? const Color(0xFFFCFCFC)).withInversion(
            autoInvert && isDark,
          )
        : opennoteUiMode
        ? (isDark ? const Color(0xFF161618) : const Color(0xFFF3F2EE))
        : null;

    return EditorSavePopScope(
      savingState: savingState,
      onTriggerSave: onTriggerSave,
      onNeedsSaveNotice: onNeedsSaveNotice,
      child: Scaffold(
        extendBodyBehindAppBar: opennoteUiMode && !isFullscreen,
        backgroundColor: background,
        appBar: isFullscreen
            ? null
            : EditorHeaderBarHost(
                opennoteUiMode: opennoteUiMode,
                filePath: coreInfo.filePath,
                customTitle: customTitle,
                filenameController: filenameController,
                filenameFormKey: filenameFormKey,
                onRenameFile: onRenameFile,
                validateFilename: validateFilename,
                needsNaming: needsNaming,
                savingState: savingState,
                triggerSave: onTriggerSave,
                onBack: () => Navigator.of(context).maybePop(),
                onOpenPages: onOpenPages,
                currentPageIndex: currentPageIndex,
                totalPages: coreInfo.pages.length,
                isInfiniteCanvas: coreInfo.isInfiniteCanvas,
                onFitContent: onFitContent,
                isBookmarked: bookmarked,
                onToggleBookmark: () => onToggleBookmark(),
                onInsertPage: onInsertPage,
                onUndo: onUndo,
                canUndo: !coreInfo.readOnly && history.canUndo,
                onRedo: onRedo,
                canRedo: !coreInfo.readOnly && history.canRedo,
                onExport: onExport,
                isHandScrollMode: isHandScrollMode,
                onToggleHandScrollMode: onToggleHandScrollMode,
                onOpenMenu: onOpenMenu,
                readOnly: coreInfo.readOnly,
              ),
        body: EditorSurfaceLayout(
          toolbarAlignment: toolbarAlignment,
          opennoteUiMode: opennoteUiMode,
          showToolbarInFullscreen: showToolbarInFullscreen,
          editingSurface: EditorCanvasSurface(
            canvasKey: canvasKey,
            coreInfo: coreInfo,
            explicitPageIndex: explicitPageIndex,
            currentPageIndex: currentPageIndex,
            currentTool: currentTool,
            bookmarked: bookmarked,
            hasTape: hasTape,
            opennoteUiMode: opennoteUiMode,
            history: history,
            transformationController: transformationController,
            gestures: gestures,
            pageBuilder: pageBuilder,
            undo: onUndo,
            redo: onRedo,
            onToggleBookmarked: () => onToggleBookmark(delayAutosave: true),
            onRevealAllTape: actions.onRevealAllTape ?? () {},
            onConcealAllTape: actions.onConcealAllTape ?? () {},
            onLayersChanged: onLayersChanged,
            onFitContent: onFitContent,
            onRefreshUi: onRefreshUi,
            zoomWindowOpen: zoomWindowOpen,
            zoomWindowController: zoomWindowController,
            zoomPageIndex: zoomPageIndex,
            zoomPenProvider: zoomPenProvider,
            onDismissZoomWindow: onDismissZoomWindow,
            onZoomStrokeStarted: onZoomStrokeStarted,
            onZoomStrokeCommitted: onZoomStrokeCommitted,
          ),
          toolbarContent: EditorToolbarHost(
            opennoteUiMode: opennoteUiMode,
            actions: actions,
            onClearPage: onClearPage,
            zoomWindowOpen: zoomWindowOpen,
            onToggleZoomWindow: onToggleZoomWindow,
            undo: onUndo,
            isUndoPossible: history.canUndo,
            redo: onRedo,
            isRedoPossible: history.canRedo,
            toggleFingerDrawing: onToggleFingerDrawing,
            exportAsSba: exportAsSba,
            exportAsPdf: exportAsPdf,
            exportAsPng: exportAsPng,
          ),
          readonlyBanner: ReadOnlyBanner(
            coreInfo.readOnlyReason,
            action: coreInfo.readOnlyReason == .versionTooNew
                ? onShowVersionTooNewDialog
                : null,
          ),
        ),
        floatingActionButton: (isFullscreen && !showToolbarInFullscreen)
            ? const EditorFullscreenExitFab()
            : null,
      ),
    );
  }
}
