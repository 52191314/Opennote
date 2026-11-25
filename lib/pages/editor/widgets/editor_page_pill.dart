/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/i18n/strings.g.dart';

/// Compact pill displaying the current page counter (or Infinite badge)
/// alongside a quick bookmark star toggle.
class EditorPagePill extends StatelessWidget {
  /// Creates an [EditorPagePill].
  const EditorPagePill({
    super.key,
    required this.isInfiniteCanvas,
    required this.currentPageIndex,
    required this.totalPages,
    required this.isBookmarked,
    required this.isCompact,
    required this.onOpenPages,
    required this.onToggleBookmark,
  });

  /// Whether the active note uses an infinite canvas.
  final bool isInfiniteCanvas;

  /// Zero-based index of the currently visible page.
  final int currentPageIndex;

  /// Total number of pages in the document.
  final int totalPages;

  /// Whether the current page is bookmarked.
  final bool isBookmarked;

  /// Whether to use compact spacing for narrow phone widths.
  final bool isCompact;

  /// Called when the user taps the page indicator segment.
  final VoidCallback onOpenPages;

  /// Called when the user taps the bookmark star segment.
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final labelStyle = TextStyle(
      fontSize: isCompact ? 11.5 : 12.5,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isCompact ? 2 : 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            width: 0.75,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: t.editor.pages,
              child: InkWell(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
                onTap: onOpenPages,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 7 : 10,
                    vertical: isCompact ? 4.5 : 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isInfiniteCanvas
                            ? Icons.all_inclusive_rounded
                            : Icons.grid_view_rounded,
                        size: isCompact ? 13.5 : 15,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: isCompact ? 3.5 : 5),
                      Text(
                        isInfiniteCanvas
                            ? 'Infinite'
                            : '${currentPageIndex + 1} / $totalPages',
                        style: labelStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: isCompact ? 12 : 16,
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            Tooltip(
              message: isBookmarked
                  ? t.editor.bookmark.remove
                  : t.editor.bookmark.add,
              child: InkResponse(
                radius: 16,
                onTap: onToggleBookmark,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 6 : 8,
                    vertical: isCompact ? 4.5 : 6,
                  ),
                  child: Icon(
                    isBookmarked ? Icons.star : Icons.star_border,
                    size: isCompact ? 14.5 : 16,
                    color: isBookmarked
                        ? Colors.amber.shade700
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
