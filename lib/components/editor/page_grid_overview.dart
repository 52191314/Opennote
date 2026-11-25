/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:saber/components/editor/page_grid/draggable_page_grid.dart';
import 'package:saber/components/editor/page_grid/page_grid_empty_state.dart';
import 'package:saber/components/editor/page_grid/page_grid_header.dart';
import 'package:saber/components/editor/page_grid/page_outline_view.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/i18n/strings.g.dart';

export 'package:saber/components/editor/page_grid/page_grid_header.dart'
    show PageGridFilter;

/// A responsive modal dialog presenting a multi-column thumbnail grid
/// overview of all notebook pages.
///
/// Supports single-tap navigation, drag-and-drop page reordering,
/// bookmark toggling, filtering, document outline, and page actions.
class PageGridOverviewDialog extends StatefulWidget {
  /// Creates a [PageGridOverviewDialog].
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
    if (mounted) Navigator.of(context).pop();
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

  void _handleClear(int pageIndex) {
    if (widget.clearPage == null) return;
    widget.clearPage!(pageIndex);
    setState(() {});
  }

  void _handleDelete(int pageIndex) {
    if (widget.coreInfo.pages.length <= 1) return;
    widget.deletePage(pageIndex);
    setState(() {});
  }

  void _handleAddNewPage() {
    widget.insertPageAfter(widget.coreInfo.pages.length - 1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = min(screenSize.width * 0.92, 1080.0);
    final dialogHeight = min(screenSize.height * 0.88, 860.0);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        color: theme.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageGridHeader(
              filter: _filter,
              totalPages: widget.coreInfo.pages.length,
              bookmarkedCount: _bookmarkedCount,
              onFilterChanged: (next) => setState(() => _filter = next),
              onAddPage: _handleAddNewPage,
              onClose: () => Navigator.of(context).pop(),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_filter == PageGridFilter.outline) {
      return PageOutlineView(
        pages: widget.coreInfo.pages,
        onJumpToPage: _jumpToPage,
      );
    }

    final visibleIndices = _visibleIndices;
    if (visibleIndices.isEmpty) {
      return PageGridEmptyState(
        icon: Icons.star_outline_rounded,
        title: t.editor.pageGrid.noBookmarks,
        subtitle: t.editor.pageGrid.starPagesHint,
      );
    }

    return DraggablePageGrid(
      controller: _scrollController,
      coreInfo: widget.coreInfo,
      visibleIndices: visibleIndices,
      currentPageIndex: widget.currentPageIndex,
      canReorder: _filter == PageGridFilter.all,
      onJumpToPage: _jumpToPage,
      onToggleBookmark: _toggleBookmark,
      onReorder: _onReorder,
      onDuplicate: _handleDuplicate,
      onInsertAfter: _handleInsertAfter,
      onClear: widget.clearPage != null ? _handleClear : null,
      onDelete: _handleDelete,
    );
  }
}
