/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/canvas_preview.dart';
import 'package:saber/components/editor/page_grid/page_options_menu.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/i18n/strings.g.dart';

/// A crisp page thumbnail card displaying a live preview, active indicator,
/// bookmark toggle, page number, and options menu.
class PageThumbnailCard extends StatelessWidget {
  /// Creates a [PageThumbnailCard].
  const PageThumbnailCard({
    super.key,
    required this.coreInfo,
    required this.pageIndex,
    required this.page,
    required this.isActive,
    required this.isDragTargetHovered,
    required this.onJumpToPage,
    required this.onToggleBookmark,
    required this.onDuplicate,
    required this.onInsertAfter,
    required this.onDelete,
    this.onClear,
  });

  /// Document core info passed to [CanvasPreview].
  final EditorCoreInfo coreInfo;

  /// Zero-based index of the page.
  final int pageIndex;

  /// Page model for aspect ratio and bookmark state.
  final EditorPage page;

  /// Whether this page is the currently active page in the editor.
  final bool isActive;

  /// Whether a dragged page is currently hovering over this card.
  final bool isDragTargetHovered;

  /// Called when the user taps the page preview to jump to it.
  final VoidCallback onJumpToPage;

  /// Called when the user taps the bookmark star icon.
  final VoidCallback onToggleBookmark;

  /// Called when the user selects duplicate in the options menu.
  final VoidCallback onDuplicate;

  /// Called when the user selects insert-after in the options menu.
  final VoidCallback onInsertAfter;

  /// Called when the user selects delete in the options menu.
  final VoidCallback onDelete;

  /// Optional callback when the user selects clear in the options menu.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final borderColor = isDragTargetHovered
        ? colorScheme.tertiary
        : isActive
        ? colorScheme.primary
        : colorScheme.outlineVariant.withValues(alpha: 0.5);

    final borderWidth = (isDragTargetHovered || isActive) ? 2.0 : 1.0;

    return DecoratedBox(
      key: Key('page_thumbnail_card_$pageIndex'),
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primaryContainer.withValues(alpha: 0.24)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 3),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopBar(colorScheme),
          Expanded(child: _buildPreviewBody()),
          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildTopBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 5, 6, 3),
      child: Row(
        children: [
          if (isActive)
            Flexible(
              child: Container(
                key: Key('active_page_badge_$pageIndex'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2.5,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  t.editor.pageGrid.current,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          const Spacer(),
          IconButton(
            key: Key('bookmark_star_$pageIndex'),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: Icon(
              page.bookmarked ? Icons.star : Icons.star_border,
              color: page.bookmarked
                  ? Colors.amber
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            tooltip: page.bookmarked
                ? t.editor.bookmark.remove
                : t.editor.bookmark.add,
            onPressed: onToggleBookmark,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBody() {
    return InkWell(
      key: Key('page_jump_target_$pageIndex'),
      onTap: onJumpToPage,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Center(
          child: AspectRatio(
            aspectRatio: page.size.width / page.size.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: coreInfo.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 5,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: page.size.width,
                    height: page.size.height,
                    child: IgnorePointer(
                      child: CanvasPreview(
                        pageIndex: pageIndex,
                        height: null,
                        coreInfo: coreInfo,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 2, bottom: 4),
      child: Row(
        children: [
          Text(
            '${pageIndex + 1}',
            key: Key('page_number_$pageIndex'),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          PageOptionsMenu(
            pageIndex: pageIndex,
            totalPages: coreInfo.pages.length,
            onDuplicate: onDuplicate,
            onInsertAfter: onInsertAfter,
            onClear: onClear,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}
