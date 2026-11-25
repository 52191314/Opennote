/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/editor/presentation_mode.dart';
import 'package:saber/components/toolbar/editor_bottom_sheet.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/prefs.dart';
import 'package:sbn/change.dart';

/// Hosts [EditorBottomSheet] with clean state-mutation and navigation wiring.
class EditorBottomSheetHost extends StatelessWidget {
  /// Creates an [EditorBottomSheetHost].
  const EditorBottomSheetHost({
    super.key,
    required this.coreInfo,
    required this.history,
    required this.currentPageIndex,
    required this.canRasterPdf,
    required this.onRefreshUi,
    required this.onAutosaveAfterDelay,
    required this.onAutosaveUntracked,
    required this.onSetInfiniteCanvas,
    required this.onFitContent,
    required this.onClearPage,
    required this.onClearAllPages,
    required this.onPickPhotos,
    required this.onImportPdf,
    required this.onAddStickyNote,
    required this.onAddSticker,
    required this.getIsWatchingServer,
    required this.setIsWatchingServer,
    required this.onExport,
  });

  /// Active document core info.
  final EditorCoreInfo coreInfo;

  /// Active editor history stack.
  final EditorHistory history;

  /// Zero-based index of the current page.
  final int currentPageIndex;

  /// Whether PDF rasterization is supported on this platform.
  final bool canRasterPdf;

  /// Triggers a UI rebuild on the parent editor state.
  final void Function([VoidCallback?]) onRefreshUi;

  /// Schedules a tracked autosave.
  final VoidCallback onAutosaveAfterDelay;

  /// Schedules an untracked autosave.
  final VoidCallback onAutosaveUntracked;

  /// Toggles infinite canvas mode.
  final ValueChanged<bool> onSetInfiniteCanvas;

  /// Fits infinite canvas content to the viewport.
  final VoidCallback onFitContent;

  /// Clears the active page.
  final VoidCallback onClearPage;

  /// Clears all pages in the note.
  final VoidCallback onClearAllPages;

  /// Media and element insertion callbacks.
  final Future<int> Function() onPickPhotos;
  final Future<bool> Function() onImportPdf;
  final VoidCallback onAddStickyNote;
  final ValueChanged<String> onAddSticker;

  /// Server-watch live-refresh hooks.
  final bool Function() getIsWatchingServer;
  final ValueChanged<bool> setIsWatchingServer;

  /// Opens the export dialog.
  final VoidCallback onExport;

  /// Opens the editor bottom sheet modal with consistent constraints.
  static Future<void> showModal(BuildContext context, WidgetBuilder builder) =>
      showModalBottomSheet(
        context: context,
        builder: builder,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: ColorScheme.of(context).surface,
        constraints: const BoxConstraints(maxWidth: 500),
      );

  @override
  Widget build(BuildContext context) {
    final invert =
        stows.editorAutoInvert.value &&
        Theme.brightnessOf(context) == Brightness.dark;

    return EditorBottomSheet(
      invert: invert,
      coreInfo: coreInfo,
      currentPageIndex: currentPageIndex,
      setBackgroundPattern: (pattern) => onRefreshUi(() {
        if (coreInfo.readOnly) return;
        final previous = coreInfo.backgroundPattern;
        coreInfo.backgroundPattern = pattern;
        stows.lastBackgroundPattern.value = pattern;
        history.recordChange(
          EditorHistoryItem(
            type: EditorHistoryItemType.backgroundPattern,
            pageIndex: currentPageIndex,
            backgroundPatternChange: Change(
              previous: previous,
              current: pattern,
            ),
            strokes: [],
            images: [],
          ),
        );
        onAutosaveAfterDelay();
      }),
      setLineHeight: (lineHeight) => onRefreshUi(() {
        if (coreInfo.readOnly) return;
        coreInfo.lineHeight = lineHeight;
        stows.lastLineHeight.value = lineHeight;
        onAutosaveUntracked();
      }),
      setLineThickness: (lineThickness) => onRefreshUi(() {
        if (coreInfo.readOnly) return;
        coreInfo.lineThickness = lineThickness;
        stows.lastLineThickness.value = lineThickness;
        onAutosaveUntracked();
      }),
      setPageSize: (Size newSize) => onRefreshUi(() {
        if (coreInfo.readOnly || currentPageIndex >= coreInfo.pages.length) {
          return;
        }
        final page = coreInfo.pages[currentPageIndex];
        page.size = newSize;
        page.redrawStrokes();
        onAutosaveUntracked();
      }),
      setInfiniteCanvas: onSetInfiniteCanvas,
      onFitContent: onFitContent,
      removeBackgroundImage: () => onRefreshUi(() {
        if (coreInfo.readOnly) return;
        final page = coreInfo.pages[currentPageIndex];
        if (page.backgroundImage == null) return;
        page.images.add(page.backgroundImage!);
        page.backgroundImage = null;
        onAutosaveUntracked();
      }),
      redrawImage: () => onRefreshUi(),
      clearPage: onClearPage,
      clearAllPages: onClearAllPages,
      redrawAndSave: () => onRefreshUi(() {
        if (coreInfo.readOnly) return;
        onAutosaveUntracked();
      }),
      pickPhotos: onPickPhotos,
      importPdf: onImportPdf,
      canRasterPdf: canRasterPdf,
      addStickyNote: onAddStickyNote,
      addSticker: onAddSticker,
      getIsWatchingServer: getIsWatchingServer,
      setIsWatchingServer: setIsWatchingServer,
      onOpenPresentation: () => _openPresentation(context),
      onOpenFlashcards: () =>
          _openPresentation(context, mode: DisplayMode.flashcard),
      onExport: onExport,
    );
  }

  void _openPresentation(BuildContext context, {DisplayMode? mode}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => mode == null
            ? PresentationMode(
                coreInfo: coreInfo,
                initialPageIndex: currentPageIndex,
              )
            : PresentationMode(
                coreInfo: coreInfo,
                initialPageIndex: currentPageIndex,
                mode: mode,
              ),
        fullscreenDialog: true,
      ),
    );
  }
}
