/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/save_indicator.dart';
import 'package:saber/components/toolbar/opennote_header_bar.dart';
import 'package:saber/pages/editor/widgets/editor_classic_app_bar.dart';

/// Chooses between the floating [OpennoteHeaderBar] and [EditorClassicAppBar]
/// based on the active UI mode.
class EditorHeaderBarHost extends StatelessWidget
    implements PreferredSizeWidget {
  /// Creates an [EditorHeaderBarHost].
  const EditorHeaderBarHost({
    super.key,
    required this.opennoteUiMode,
    required this.filePath,
    required this.customTitle,
    required this.filenameController,
    required this.filenameFormKey,
    required this.onRenameFile,
    required this.validateFilename,
    required this.needsNaming,
    required this.savingState,
    required this.triggerSave,
    required this.onBack,
    required this.onOpenPages,
    required this.currentPageIndex,
    required this.totalPages,
    required this.isInfiniteCanvas,
    required this.onFitContent,
    required this.isBookmarked,
    required this.onToggleBookmark,
    required this.onInsertPage,
    required this.onUndo,
    required this.canUndo,
    required this.onRedo,
    required this.canRedo,
    required this.onExport,
    required this.isHandScrollMode,
    required this.onToggleHandScrollMode,
    required this.onOpenMenu,
    required this.readOnly,
  });

  final bool opennoteUiMode;
  final String filePath;
  final String? customTitle;
  final TextEditingController filenameController;
  final GlobalKey<FormState> filenameFormKey;
  final ValueChanged<String> onRenameFile;
  final FormFieldValidator<String> validateFilename;
  final bool needsNaming;
  final ValueNotifier<SavingState> savingState;
  final VoidCallback triggerSave;
  final VoidCallback onBack;
  final VoidCallback onOpenPages;
  final int currentPageIndex;
  final int totalPages;
  final bool isInfiniteCanvas;
  final VoidCallback onFitContent;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;
  final VoidCallback onInsertPage;
  final VoidCallback onUndo;
  final bool canUndo;
  final VoidCallback onRedo;
  final bool canRedo;
  final VoidCallback onExport;
  final bool isHandScrollMode;
  final VoidCallback onToggleHandScrollMode;
  final VoidCallback onOpenMenu;
  final bool readOnly;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    if (opennoteUiMode) {
      return OpennoteHeaderBar(
        filePath: filePath,
        customTitle: customTitle,
        filenameTextEditingController: filenameController,
        filenameFormKey: filenameFormKey,
        renameFile: onRenameFile,
        validateFilename: validateFilename,
        needsNaming: needsNaming,
        savingState: savingState,
        triggerSave: triggerSave,
        onBack: onBack,
        onOpenThumbnails: onOpenPages,
        currentPageIndex: currentPageIndex,
        totalPages: totalPages,
        isInfiniteCanvas: isInfiniteCanvas,
        onFitContent: onFitContent,
        isBookmarked: isBookmarked,
        onToggleBookmark: onToggleBookmark,
        onInsertPage: onInsertPage,
        undo: onUndo,
        canUndo: canUndo,
        redo: onRedo,
        canRedo: canRedo,
        onExport: onExport,
        isHandScrollMode: isHandScrollMode,
        onToggleHandScrollMode: onToggleHandScrollMode,
        onOpenMenu: onOpenMenu,
        readOnly: readOnly,
      );
    }

    return EditorClassicAppBar(
      customTitle: customTitle,
      filenameFormKey: filenameFormKey,
      filenameController: filenameController,
      onRenameFile: onRenameFile,
      needsNaming: needsNaming,
      validateFilename: validateFilename,
      savingState: savingState,
      triggerSave: triggerSave,
      canUndo: canUndo,
      canRedo: canRedo,
      onUndo: onUndo,
      onRedo: onRedo,
      isInfiniteCanvas: isInfiniteCanvas,
      currentPageIndex: currentPageIndex,
      totalPages: totalPages,
      currentPageBookmarked: isBookmarked,
      onOpenPages: onOpenPages,
      onToggleBookmark: onToggleBookmark,
      onAddOrFit: isInfiniteCanvas ? onFitContent : onInsertPage,
      onExport: onExport,
      onOpenMenu: onOpenMenu,
    );
  }
}
