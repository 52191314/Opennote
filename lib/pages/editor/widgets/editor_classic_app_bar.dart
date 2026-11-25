/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:saber/components/canvas/save_indicator.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/widgets/editor_page_pill.dart';

/// Classic Material/Cupertino editor app bar with inline filename editing,
/// undo/redo controls, page indicator pill, and overflow actions.
class EditorClassicAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Creates an [EditorClassicAppBar].
  const EditorClassicAppBar({
    super.key,
    required this.customTitle,
    required this.filenameFormKey,
    required this.filenameController,
    required this.onRenameFile,
    required this.needsNaming,
    required this.validateFilename,
    required this.savingState,
    required this.triggerSave,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    required this.isInfiniteCanvas,
    required this.currentPageIndex,
    required this.totalPages,
    required this.currentPageBookmarked,
    required this.onOpenPages,
    required this.onToggleBookmark,
    required this.onAddOrFit,
    required this.onExport,
    required this.onOpenMenu,
  });

  /// Optional fixed title shown instead of the editable filename field.
  final String? customTitle;

  /// Form key for filename validation.
  final GlobalKey<FormState> filenameFormKey;

  /// Controller for the editable filename text field.
  final TextEditingController filenameController;

  /// Called whenever the filename text changes.
  final ValueChanged<String> onRenameFile;

  /// Whether the filename field should autofocus on mount.
  final bool needsNaming;

  /// Validator for the filename field.
  final FormFieldValidator<String> validateFilename;

  /// Observable saving state for [SaveIndicator].
  final ValueNotifier<SavingState> savingState;

  /// Manually triggers a save when the user taps the save indicator.
  final VoidCallback triggerSave;

  /// Whether undo is currently available.
  final bool canUndo;

  /// Whether redo is currently available.
  final bool canRedo;

  /// Undo callback.
  final VoidCallback onUndo;

  /// Redo callback.
  final VoidCallback onRedo;

  /// Whether the note is in infinite canvas mode.
  final bool isInfiniteCanvas;

  /// Zero-based index of the currently active page.
  final int currentPageIndex;

  /// Total number of pages in the note.
  final int totalPages;

  /// Whether the current page is bookmarked.
  final bool currentPageBookmarked;

  /// Opens the page grid overview (or menu in infinite canvas mode).
  final VoidCallback onOpenPages;

  /// Toggles bookmark status on the current page.
  final VoidCallback onToggleBookmark;

  /// Adds a page from template, or fits content in infinite canvas mode.
  final VoidCallback onAddOrFit;

  /// Opens the export dialog.
  final VoidCallback onExport;

  /// Opens the editor options bottom sheet.
  final VoidCallback onOpenMenu;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 500;
    final isVeryCompact = screenWidth < 400;
    final density = isCompact ? VisualDensity.compact : null;
    final buttonPadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 4)
        : null;

    return AppBar(
      toolbarHeight: kToolbarHeight,
      leadingWidth: isCompact ? 44.0 : null,
      titleSpacing: isCompact ? 6.0 : NavigationToolbar.kMiddleSpacing,
      title: customTitle != null
          ? Text(customTitle!, maxLines: 1, overflow: TextOverflow.ellipsis)
          : Form(
              key: filenameFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: TextFormField(
                decoration: const InputDecoration(border: InputBorder.none),
                controller: filenameController,
                onChanged: onRenameFile,
                autofocus: needsNaming,
                validator: validateFilename,
              ),
            ),
      leading: SaveIndicator(
        savingState: savingState,
        triggerSave: triggerSave,
      ),
      actions: [
        IconButton(
          visualDensity: density,
          padding: buttonPadding,
          icon: const AdaptiveIcon(
            icon: Icons.undo,
            cupertinoIcon: CupertinoIcons.arrow_uturn_left,
          ),
          tooltip: t.editor.toolbar.undo,
          onPressed: canUndo ? onUndo : null,
        ),
        IconButton(
          visualDensity: density,
          padding: buttonPadding,
          icon: const AdaptiveIcon(
            icon: Icons.redo,
            cupertinoIcon: CupertinoIcons.arrow_uturn_right,
          ),
          tooltip: t.editor.toolbar.redo,
          onPressed: canRedo ? onRedo : null,
        ),
        SizedBox(width: isCompact ? 2 : 4),
        EditorPagePill(
          isInfiniteCanvas: isInfiniteCanvas,
          currentPageIndex: currentPageIndex,
          totalPages: totalPages,
          isBookmarked: currentPageBookmarked,
          isCompact: isCompact,
          onOpenPages: onOpenPages,
          onToggleBookmark: onToggleBookmark,
        ),
        if (!isVeryCompact)
          IconButton(
            visualDensity: density,
            padding: buttonPadding,
            icon: AdaptiveIcon(
              icon: isInfiniteCanvas ? Icons.fit_screen_rounded : Icons.add,
              cupertinoIcon: isInfiniteCanvas
                  ? Icons.fit_screen_rounded
                  : CupertinoIcons.add,
            ),
            tooltip: isInfiniteCanvas
                ? t.editor.canvasHud.fitContent
                : t.editor.menu.insertPage,
            onPressed: onAddOrFit,
          ),
        if (screenWidth >= 450)
          IconButton(
            visualDensity: density,
            padding: buttonPadding,
            icon: const AdaptiveIcon(
              icon: Icons.ios_share,
              cupertinoIcon: CupertinoIcons.share,
            ),
            tooltip: t.editor.toolbar.export,
            onPressed: onExport,
          ),
        IconButton(
          visualDensity: density,
          padding: buttonPadding,
          icon: const AdaptiveIcon(
            icon: Icons.more_vert,
            cupertinoIcon: CupertinoIcons.ellipsis_vertical,
          ),
          onPressed: onOpenMenu,
        ),
      ],
    );
  }
}
