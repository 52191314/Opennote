/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
library;

import 'dart:math';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:saber/components/canvas/canvas_preview.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/i18n/strings.g.dart';

/// Filter selection for the page grid overview / document hub.
enum PageGridFilter { all, bookmarked, outline }

/// A heading entry extracted from document text for the Outline view.
class _OutlineHeadingEntry {
  final int pageIndex;
  final int level; // 1-6
  final String text;

  const _OutlineHeadingEntry({
    required this.pageIndex,
    required this.level,
    required this.text,
  });
}

/// A responsive modal dialog presenting a multi-column thumbnail grid
/// overview of all notebook pages.
///
/// Supports single-tap navigation, drag-and-drop page reordering,
/// bookmark toggling, filtering, and page actions (duplicate, insert, delete).
class PageGridOverviewDialog extends StatefulWidget {
  const PageGridOverviewDialog({
    super.key,
    required this.coreInfo,
    required this.currentPageIndex,
    required this.scrollToPage,
    required this.redrawAndSave,
    required this.duplicatePage,
    required this.deletePage,
    required this.insertPageAfter,
    this.clearPage,
    this.initialFilter = PageGridFilter.all,
  });

  final EditorCoreInfo coreInfo;
  final int currentPageIndex;
  final void Function(int pageIndex) scrollToPage;
  final VoidCallback redrawAndSave;
  final void Function(int pageIndex) duplicatePage;
  final void Function(int pageIndex) deletePage;
  final void Function(int pageIndex) insertPageAfter;
  final void Function(int pageIndex)? clearPage;
  final PageGridFilter initialFilter;

  @override
  State<PageGridOverviewDialog> createState() => _PageGridOverviewDialogState();
}

class _PageGridOverviewDialogState extends State<PageGridOverviewDialog> {
  late PageGridFilter _filter;
  final _scrollController = ScrollController();
  int? _hoveredDropTargetIndex;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<int> get _visibleIndices {
    final pages = widget.coreInfo.pages;
    if (_filter == PageGridFilter.bookmarked) {
      return [
        for (int i = 0; i < pages.length; i++)
          if (pages[i].bookmarked) i,
      ];
    }
    return [for (int i = 0; i < pages.length; i++) i];
  }

  int get _bookmarkedCount {
    var count = 0;
    for (final page in widget.coreInfo.pages) {
      if (page.bookmarked) count++;
    }
    return count;
  }

  void _jumpToPage(int pageIndex) {
    widget.scrollToPage(pageIndex);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _toggleBookmark(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= widget.coreInfo.pages.length) return;
    final page = widget.coreInfo.pages[pageIndex];
    setState(() {
      page.bookmarked = !page.bookmarked;
      page.redrawStrokes();
    });
    widget.redrawAndSave();
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= widget.coreInfo.pages.length) return;
    if (newIndex < 0 || newIndex >= widget.coreInfo.pages.length) return;

    setState(() {
      final page = widget.coreInfo.pages.removeAt(oldIndex);
      widget.coreInfo.pages.insert(newIndex, page);
      for (int i = 0; i < widget.coreInfo.pages.length; i++) {
        widget.coreInfo.pages[i].updatePageIndex(i);
      }
    });
    widget.redrawAndSave();
  }

  void _handleDuplicate(int pageIndex) {
    widget.duplicatePage(pageIndex);
    setState(() {});
  }

  void _handleInsertAfter(int pageIndex) {
    widget.insertPageAfter(pageIndex);
    setState(() {});
  }

  void _handleDelete(int pageIndex) {
    if (widget.coreInfo.pages.length <= 1) return;
    widget.deletePage(pageIndex);
    setState(() {});
  }

  void _handleAddNewPage() {
    final lastIndex = widget.coreInfo.pages.length - 1;
    widget.insertPageAfter(lastIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = min(screenSize.width * 0.92, 1080.0);
    final dialogHeight = min(screenSize.height * 0.88, 860.0);
    final visibleIndices = _visibleIndices;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        color: theme.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, theme),
            const Divider(height: 1),
            Expanded(
              child: _filter == PageGridFilter.outline
                  ? _buildOutlineView(context, theme)
                  : (visibleIndices.isEmpty
                        ? _buildEmptyState(theme)
                        : _buildGrid(context, theme, visibleIndices)),
            ),
          ],
        ),
      ),
    );
  }

  List<_OutlineHeadingEntry> _extractHeadings() {
    final headings = <_OutlineHeadingEntry>[];
    for (int i = 0; i < widget.coreInfo.pages.length; i++) {
      final page = widget.coreInfo.pages[i];
      final delta = page.quill.controller.document.toDelta();
      for (final op in delta.toList()) {
        if (op.isInsert && op.data is String) {
          final attributes = op.attributes;
          if (attributes != null && attributes.containsKey('heading')) {
            final text = (op.data as String).trim();
            if (text.isEmpty) continue;
            final level = attributes['heading'] as int;
            headings.add(
              _OutlineHeadingEntry(pageIndex: i, level: level, text: text),
            );
          }
        }
      }
    }
    return headings;
  }

  Widget _buildOutlineView(BuildContext context, ThemeData theme) {
    final headings = _extractHeadings();
    if (headings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.format_list_bulleted,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              t.editor.outline.noHeadingsInDocument,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.editor.outline.howTo,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: headings.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 48),
      itemBuilder: (context, index) {
        final entry = headings[index];
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _jumpToPage(entry.pageIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${entry.pageIndex + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: 12 + (entry.level - 1) * 16.0),
                Expanded(
                  child: Text(
                    entry.text,
                    style: TextStyle(
                      fontSize: 15.0 - (entry.level - 1) * 1.0,
                      fontWeight: entry.level <= 2
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final totalPages = widget.coreInfo.pages.length;
    final bookmarked = _bookmarkedCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;

        final filterControl = SegmentedButton<PageGridFilter>(
          segments: [
            ButtonSegment<PageGridFilter>(
              value: PageGridFilter.all,
              label: Text(t.editor.pageGrid.all(n: totalPages)),
              icon: const Icon(Icons.grid_view, size: 16),
            ),
            ButtonSegment<PageGridFilter>(
              value: PageGridFilter.bookmarked,
              label: Text(t.editor.pageGrid.bookmarked(n: bookmarked)),
              icon: const Icon(Icons.star, size: 16),
            ),
            ButtonSegment<PageGridFilter>(
              value: PageGridFilter.outline,
              label: Text(t.editor.outline.title),
              icon: const Icon(Icons.format_list_bulleted, size: 16),
            ),
          ],
          selected: {_filter},
          onSelectionChanged: (newSelection) {
            setState(() {
              _filter = newSelection.first;
            });
          },
        );

        if (isCompact) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.grid_view, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      t.editor.pages,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      key: const Key('add_page_button'),
                      icon: const AdaptiveIcon(
                        icon: Icons.add,
                        cupertinoIcon: CupertinoIcons.add,
                      ),
                      tooltip: t.editor.menu.insertPage,
                      onPressed: _handleAddNewPage,
                    ),
                    IconButton(
                      key: const Key('close_overview_button'),
                      icon: const Icon(Icons.close),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Center(child: filterControl),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.grid_view, size: 20),
              const SizedBox(width: 8),
              Text(
                t.editor.pages,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              filterControl,
              const Spacer(),
              IconButton(
                key: const Key('add_page_button'),
                icon: const AdaptiveIcon(
                  icon: Icons.add,
                  cupertinoIcon: CupertinoIcons.add,
                ),
                tooltip: t.editor.menu.insertPage,
                onPressed: _handleAddNewPage,
              ),
              IconButton(
                key: const Key('close_overview_button'),
                icon: const Icon(Icons.close),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              t.editor.pageGrid.noBookmarks,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.editor.pageGrid.starPagesHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    ThemeData theme,
    List<int> visibleIndices,
  ) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: visibleIndices.length,
      itemBuilder: (context, index) {
        final pageIndex = visibleIndices[index];
        final page = widget.coreInfo.pages[pageIndex];
        final isActive = pageIndex == widget.currentPageIndex;
        final canReorder = _filter == PageGridFilter.all;

        return _buildThumbnailCard(
          context: context,
          theme: theme,
          pageIndex: pageIndex,
          page: page,
          isActive: isActive,
          canReorder: canReorder,
        );
      },
    );
  }

  Widget _buildThumbnailCard({
    required BuildContext context,
    required ThemeData theme,
    required int pageIndex,
    required EditorPage page,
    required bool isActive,
    required bool canReorder,
  }) {
    final cardWidget = _buildCardContainer(
      context: context,
      theme: theme,
      pageIndex: pageIndex,
      page: page,
      isActive: isActive,
      isDragTargetHovered: _hoveredDropTargetIndex == pageIndex,
    );

    if (!canReorder) {
      return cardWidget;
    }

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != pageIndex,
      onAcceptWithDetails: (details) {
        setState(() {
          _hoveredDropTargetIndex = null;
        });
        _onReorder(details.data, pageIndex);
      },
      onMove: (_) {
        if (_hoveredDropTargetIndex != pageIndex) {
          setState(() {
            _hoveredDropTargetIndex = pageIndex;
          });
        }
      },
      onLeave: (_) {
        if (_hoveredDropTargetIndex == pageIndex) {
          setState(() {
            _hoveredDropTargetIndex = null;
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered =
            candidateData.isNotEmpty || _hoveredDropTargetIndex == pageIndex;

        return LongPressDraggable<int>(
          data: pageIndex,
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 160,
              height: 235,
              child: Opacity(
                opacity: 0.9,
                child: _buildCardContainer(
                  context: context,
                  theme: theme,
                  pageIndex: pageIndex,
                  page: page,
                  isActive: isActive,
                  isDragTargetHovered: false,
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildCardContainer(
              context: context,
              theme: theme,
              pageIndex: pageIndex,
              page: page,
              isActive: isActive,
              isDragTargetHovered: false,
            ),
          ),
          child: _buildCardContainer(
            context: context,
            theme: theme,
            pageIndex: pageIndex,
            page: page,
            isActive: isActive,
            isDragTargetHovered: isHovered,
          ),
        );
      },
    );
  }

  Widget _buildCardContainer({
    required BuildContext context,
    required ThemeData theme,
    required int pageIndex,
    required EditorPage page,
    required bool isActive,
    required bool isDragTargetHovered,
  }) {
    final borderColor = isDragTargetHovered
        ? theme.colorScheme.tertiary
        : isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.5);

    final borderWidth = (isDragTargetHovered || isActive) ? 2.5 : 1.0;

    return DecoratedBox(
      key: Key('page_thumbnail_card_$pageIndex'),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardTopBar(theme, pageIndex, page, isActive),
          Expanded(child: _buildCardBody(pageIndex, page)),
          _buildCardFooter(context, theme, pageIndex),
        ],
      ),
    );
  }

  Widget _buildCardTopBar(
    ThemeData theme,
    int pageIndex,
    EditorPage page,
    bool isActive,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          if (isActive)
            Container(
              key: Key('active_page_badge_$pageIndex'),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                t.editor.pageGrid.current,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
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
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            tooltip: page.bookmarked
                ? t.editor.bookmark.remove
                : t.editor.bookmark.add,
            onPressed: () => _toggleBookmark(pageIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBody(int pageIndex, EditorPage page) {
    return InkWell(
      key: Key('page_jump_target_$pageIndex'),
      onTap: () => _jumpToPage(pageIndex),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Center(
          child: AspectRatio(
            aspectRatio: page.size.width / page.size.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.coreInfo.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: page.size.width,
                    height: page.size.height,
                    child: IgnorePointer(
                      child: CanvasPreview(
                        pageIndex: pageIndex,
                        height: null,
                        coreInfo: widget.coreInfo,
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

  Widget _buildCardFooter(
    BuildContext context,
    ThemeData theme,
    int pageIndex,
  ) {
    final canDelete = widget.coreInfo.pages.length > 1;

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 4, bottom: 4),
      child: Row(
        children: [
          Text(
            '${pageIndex + 1}',
            key: Key('page_number_$pageIndex'),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            key: Key('page_menu_$pageIndex'),
            icon: const Icon(Icons.more_vert, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: t.editor.pageGrid.pageOptions,
            onSelected: (value) {
              switch (value) {
                case 'duplicate':
                  _handleDuplicate(pageIndex);
                case 'insert':
                  _handleInsertAfter(pageIndex);
                case 'clear':
                  if (widget.clearPage != null) {
                    widget.clearPage!(pageIndex);
                    setState(() {});
                  }
                case 'delete':
                  _handleDelete(pageIndex);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'duplicate',
                key: Key('duplicate_page_$pageIndex'),
                child: Row(
                  children: [
                    const Icon(Icons.copy, size: 18),
                    const SizedBox(width: 8),
                    Text(t.editor.menu.duplicatePage),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'insert',
                key: Key('insert_page_$pageIndex'),
                child: Row(
                  children: [
                    const Icon(Icons.add_box_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(t.editor.menu.insertPage),
                  ],
                ),
              ),
              if (widget.clearPage != null)
                PopupMenuItem(
                  value: 'clear',
                  key: Key('clear_page_$pageIndex'),
                  child: Row(
                    children: [
                      const Icon(Icons.cleaning_services_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        t.editor.menu.clearPage(
                          page: pageIndex + 1,
                          totalPages: widget.coreInfo.pages.length,
                        ),
                      ),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'delete',
                enabled: canDelete,
                key: Key('delete_page_$pageIndex'),
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: canDelete ? Colors.red : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      t.editor.menu.deletePage,
                      style: TextStyle(color: canDelete ? Colors.red : null),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
