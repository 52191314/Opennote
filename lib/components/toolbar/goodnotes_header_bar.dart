/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/canvas/save_indicator.dart';
import 'package:saber/i18n/strings.g.dart';

/// A Goodnotes 6/7-inspired document header bar.
///
/// Features:
/// - Navigation `<` button returning to document library
/// - Document Hub / Thumbnails button with page counter (`1 / 5`)
/// - Notebook Document Tab with inline renaming and close `×` button
/// - `+` button to insert pages
/// - Undo & Redo icon controls
/// - Bookmark / Favorite star toggle
/// - Share & Export button
/// - Read-Only / Stylus Hand Scroll mode toggle (disables pencil marks for reading/panning)
/// - More `...` overflow menu
class GoodnotesHeaderBar extends StatelessWidget
    implements PreferredSizeWidget {
  const GoodnotesHeaderBar({
    super.key,
    required this.filePath,
    this.customTitle,
    required this.filenameTextEditingController,
    required this.filenameFormKey,
    required this.renameFile,
    required this.validateFilename,
    required this.needsNaming,
    required this.savingState,
    required this.triggerSave,
    required this.onBack,
    required this.onOpenThumbnails,
    required this.currentPageIndex,
    required this.totalPages,
    required this.isInfiniteCanvas,
    required this.isBookmarked,
    required this.onToggleBookmark,
    required this.onInsertPage,
    required this.undo,
    required this.canUndo,
    required this.redo,
    required this.canRedo,
    required this.onExport,
    required this.isHandScrollMode,
    required this.onToggleHandScrollMode,
    required this.onOpenMenu,
    this.readOnly = false,
  });

  final String filePath;
  final String? customTitle;
  final TextEditingController filenameTextEditingController;
  final GlobalKey<FormState> filenameFormKey;
  final ValueChanged<String> renameFile;
  final String? Function(String?) validateFilename;
  final bool needsNaming;
  final ValueNotifier<SavingState> savingState;
  final VoidCallback triggerSave;

  final VoidCallback onBack;
  final VoidCallback onOpenThumbnails;
  final int currentPageIndex;
  final int totalPages;
  final bool isInfiniteCanvas;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;
  final VoidCallback onInsertPage;

  final VoidCallback undo;
  final bool canUndo;
  final VoidCallback redo;
  final bool canRedo;
  final VoidCallback onExport;
  final bool isHandScrollMode;
  final VoidCallback onToggleHandScrollMode;
  final VoidCallback onOpenMenu;
  final bool readOnly;

  @override
  Size get preferredSize => const Size.fromHeight(50.0);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 520;
    final isUltraCompact = screenWidth < 420;

    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            width: 0.75,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 4.0 : 8.0),
      child: Row(
        children: [
          // 1. Back button to document browser
          Tooltip(
            message: 'Documents',
            child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(CupertinoIcons.chevron_back, size: 20),
              onPressed: onBack,
            ),
          ),

          // 2. Document Hub & Page Thumbnail Overview
          Tooltip(
            message: 'Document Hub (Thumbnails, Bookmarks & Outline)',
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onOpenThumbnails,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 6 : 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    width: 0.75,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isInfiniteCanvas
                          ? Icons.all_inclusive_rounded
                          : Icons.grid_view_rounded,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    if (!isUltraCompact) ...[
                      const SizedBox(width: 5),
                      Text(
                        isInfiniteCanvas
                            ? 'Infinite'
                            : '${currentPageIndex + 1} / ${totalPages == 0 ? 1 : totalPages}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // 3. Document Tab (Notebook styling with title + close)
          if (!isUltraCompact)
            Expanded(
              child: Container(
                height: 34,
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.65,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    width: 0.75,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.doc_text_fill,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: customTitle != null
                          ? Text(
                              customTitle!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            )
                          : Form(
                              key: filenameFormKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                controller: filenameTextEditingController,
                                onChanged: renameFile,
                                autofocus: needsNaming,
                                validator: validateFilename,
                              ),
                            ),
                    ),
                    const SizedBox(width: 4),
                    SaveIndicator(
                      savingState: savingState,
                      triggerSave: triggerSave,
                    ),
                  ],
                ),
              ),
            )
          else
            const Spacer(),

          // 4. Add Page button
          if (!isCompact)
            Tooltip(
              message: t.editor.menu.insertPage,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(CupertinoIcons.add, size: 18),
                onPressed: readOnly ? null : onInsertPage,
              ),
            ),

          SizedBox(width: isCompact ? 2 : 6),

          // 5. Undo & Redo (Goodnotes 6 action cluster)
          Tooltip(
            message: t.editor.toolbar.undo,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(CupertinoIcons.arrow_uturn_left, size: 18),
              onPressed: (!readOnly && canUndo) ? undo : null,
            ),
          ),
          Tooltip(
            message: t.editor.toolbar.redo,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(CupertinoIcons.arrow_uturn_right, size: 18),
              onPressed: (!readOnly && canRedo) ? redo : null,
            ),
          ),

          // 6. Bookmark Star
          Tooltip(
            message: isBookmarked ? 'Remove bookmark' : 'Bookmark page',
            child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isBookmarked ? Icons.star_rounded : Icons.star_border_rounded,
                  key: ValueKey(isBookmarked),
                  size: 20,
                  color: isBookmarked
                      ? Colors.amber.shade700
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              onPressed: readOnly ? null : onToggleBookmark,
            ),
          ),

          // 7. Share / Export
          if (screenWidth >= 440)
            Tooltip(
              message: t.editor.toolbar.export,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(CupertinoIcons.share, size: 18),
                onPressed: onExport,
              ),
            ),

          // 8. Hand Scroll / Read-Only Mode toggle (Goodnotes navigation toggle)
          Tooltip(
            message: isHandScrollMode
                ? 'Hand Reading Mode (Drawing disabled)'
                : 'Editing Mode (Draw with Pen/Finger)',
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isHandScrollMode
                    ? colorScheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isHandScrollMode
                      ? CupertinoIcons.hand_raised_fill
                      : CupertinoIcons.hand_raised,
                  size: 18,
                  color: isHandScrollMode
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                onPressed: onToggleHandScrollMode,
              ),
            ),
          ),

          // 9. More (...) menu
          Tooltip(
            message: 'More Options',
            child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(CupertinoIcons.ellipsis, size: 19),
              onPressed: onOpenMenu,
            ),
          ),
        ],
      ),
    );
  }
}
