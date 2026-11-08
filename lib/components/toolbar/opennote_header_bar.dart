/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/canvas/save_indicator.dart';
import 'package:saber/i18n/strings.g.dart';

/// An Opennote Studio document header bar designed as Three Floating Glass
/// Islands separated by transparent canvas breathing room.
///
/// Features:
/// - **Left Floating Island**: Back navigation button, vertical hairline divider,
///   Document Hub / Thumbnails badge (`1 / 5` or `Infinite`), and Bookmark star.
/// - **Center Floating Document Capsule**: Elevated centered pill with book icon,
///   inline `TextFormField` document title, [SaveIndicator], and close `×` button.
/// - **Right Floating Action Island**: Grouped action capsule for Undo & Redo,
///   Hand-Scroll / Read-Only toggle, Add Page / Fit Content, Export, and More Inspector menu.
class OpennoteHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const OpennoteHeaderBar({
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
    this.onFitContent,
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
  final VoidCallback? onFitContent;

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
  Size get preferredSize => const Size.fromHeight(54.0);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isUltraCompact = screenWidth < 500;
    final topPadding = MediaQuery.paddingOf(context).top;

    final pillDecoration = BoxDecoration(
      color: colorScheme.surface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );

    return Container(
      height: preferredSize.height + topPadding,
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        isUltraCompact ? 4.0 : 8.0,
        topPadding + 4.0,
        isUltraCompact ? 4.0 : 8.0,
        4.0,
      ),
      child: Row(
        children: [
          // ----------------------------------------------------
          // 1. Left Floating Island (Back + Hub + Bookmark Star)
          // ----------------------------------------------------
          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: isUltraCompact ? 2 : 4),
            decoration: pillDecoration,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: t.editor.header.documents,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: BoxConstraints.tightFor(
                      width: isUltraCompact ? 28 : 34,
                      height: 34,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(CupertinoIcons.chevron_back, size: 18),
                    onPressed: onBack,
                  ),
                ),
                Container(
                  width: 1,
                  height: 16,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                Tooltip(
                  message: t.editor.pages,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onOpenThumbnails,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isUltraCompact ? 4 : 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isInfiniteCanvas
                                ? Icons.all_inclusive_rounded
                                : Icons.grid_view_rounded,
                            size: 15,
                            color: colorScheme.primary,
                          ),
                          if (screenWidth >= 450) ...[
                            const SizedBox(width: 4),
                            Text(
                              isInfiniteCanvas
                                  ? t.editor.header.infinite
                                  : '${currentPageIndex + 1} / ${totalPages == 0 ? 1 : totalPages}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (screenWidth >= 480) ...[
                  Container(
                    width: 1,
                    height: 16,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                  Tooltip(
                    message: isBookmarked
                        ? t.editor.bookmark.remove
                        : t.editor.bookmark.add,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: BoxConstraints.tightFor(
                        width: isUltraCompact ? 28 : 34,
                        height: 34,
                      ),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isBookmarked
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 18,
                        color: isBookmarked
                            ? Colors.amber.shade700
                            : colorScheme.onSurfaceVariant,
                      ),
                      onPressed: readOnly ? null : onToggleBookmark,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: isUltraCompact ? 4 : 8),

          // ----------------------------------------------------
          // 2. Center Floating Document Capsule (Book + Title + Save + Close)
          // ----------------------------------------------------
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(
                    horizontal: isUltraCompact ? 8 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow.withValues(
                      alpha: 0.92,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.book_fill,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: customTitle != null
                            ? Text(
                                customTitle!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
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
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: SaveIndicator(
                          savingState: savingState,
                          triggerSave: triggerSave,
                        ),
                      ),
                      if (screenWidth >= 600) ...[
                        const SizedBox(width: 4),
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: onBack,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              CupertinoIcons.xmark,
                              size: 12,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.75,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: isUltraCompact ? 4 : 8),

          // ----------------------------------------------------
          // 3. Right Floating Action Island (Undo, Redo, Hand, Add/Fit, Share, More)
          // ----------------------------------------------------
          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: isUltraCompact ? 2 : 4),
            decoration: pillDecoration,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Undo
                Tooltip(
                  message: t.editor.toolbar.undo,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: BoxConstraints.tightFor(
                      width: isUltraCompact ? 28 : 34,
                      height: 34,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.undo, size: 18),
                    onPressed: (!readOnly && canUndo) ? undo : null,
                  ),
                ),
                // Redo
                Tooltip(
                  message: t.editor.toolbar.redo,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: BoxConstraints.tightFor(
                      width: isUltraCompact ? 28 : 34,
                      height: 34,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.redo, size: 18),
                    onPressed: (!readOnly && canRedo) ? redo : null,
                  ),
                ),
                Container(
                  width: 1,
                  height: 16,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                ),
                // Hand scroll mode
                if (screenWidth >= 420) ...[
                  Tooltip(
                    message: isHandScrollMode
                        ? t.editor.header.readingMode
                        : t.editor.header.editingMode,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: BoxConstraints.tightFor(
                        width: isUltraCompact ? 28 : 34,
                        height: 34,
                      ),
                      padding: EdgeInsets.zero,
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
                ],
                // Add Page / Fit Content in Infinite Canvas
                if (screenWidth >= 500) ...[
                  Tooltip(
                    message: isInfiniteCanvas
                        ? t.editor.canvasHud.fitContent
                        : t.editor.menu.insertPage,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: BoxConstraints.tightFor(
                        width: isUltraCompact ? 28 : 34,
                        height: 34,
                      ),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        isInfiniteCanvas
                            ? Icons.fit_screen_rounded
                            : CupertinoIcons.add,
                        size: 18,
                      ),
                      onPressed: readOnly
                          ? null
                          : (isInfiniteCanvas ? onFitContent : onInsertPage),
                    ),
                  ),
                ],
                // Share / Export
                if (screenWidth >= 540) ...[
                  Tooltip(
                    message: t.editor.toolbar.export,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: BoxConstraints.tightFor(
                        width: isUltraCompact ? 28 : 34,
                        height: 34,
                      ),
                      padding: EdgeInsets.zero,
                      icon: const Icon(CupertinoIcons.share, size: 18),
                      onPressed: onExport,
                    ),
                  ),
                ],
                // More (...) menu
                Tooltip(
                  message: t.editor.header.moreOptions,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: BoxConstraints.tightFor(
                      width: isUltraCompact ? 28 : 34,
                      height: 34,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(CupertinoIcons.ellipsis, size: 18),
                    onPressed: onOpenMenu,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
