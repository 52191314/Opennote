/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/editor/page_grid/page_thumbnail_card.dart';
import 'package:saber/data/editor/editor_core_info.dart';

/// Multi-column page thumbnail grid supporting optional long-press drag reordering.
class DraggablePageGrid extends StatefulWidget {
  /// Creates a [DraggablePageGrid].
  const DraggablePageGrid({
    super.key,
    required this.controller,
    required this.coreInfo,
    required this.visibleIndices,
    required this.currentPageIndex,
    required this.canReorder,
    required this.onJumpToPage,
    required this.onToggleBookmark,
    required this.onReorder,
    required this.onDuplicate,
    required this.onInsertAfter,
    required this.onDelete,
    this.onClear,
  });

  /// Scroll controller owned by the parent overview dialog.
  final ScrollController controller;

  /// Document core info containing the pages list.
  final EditorCoreInfo coreInfo;

  /// Page indices currently visible under the active filter.
  final List<int> visibleIndices;

  /// Zero-based index of the currently active page.
  final int currentPageIndex;

  /// Whether long-press drag reordering is enabled for the current filter.
  final bool canReorder;

  /// Called when the user taps a page preview.
  final ValueChanged<int> onJumpToPage;

  /// Called when the user toggles a page bookmark.
  final ValueChanged<int> onToggleBookmark;

  /// Called when a page is dragged from `oldIndex` onto `newIndex`.
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Called when the user duplicates a page.
  final ValueChanged<int> onDuplicate;

  /// Called when the user inserts a page after the given index.
  final ValueChanged<int> onInsertAfter;

  /// Called when the user deletes a page.
  final ValueChanged<int> onDelete;

  /// Optional callback when the user clears a page.
  final ValueChanged<int>? onClear;

  @override
  State<DraggablePageGrid> createState() => _DraggablePageGridState();
}

class _DraggablePageGridState extends State<DraggablePageGrid> {
  int? _hoveredDropTargetIndex;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: widget.controller,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: widget.visibleIndices.length,
      itemBuilder: (context, index) {
        final pageIndex = widget.visibleIndices[index];
        return _buildGridItem(pageIndex);
      },
    );
  }

  Widget _buildGridItem(int pageIndex) {
    if (!widget.canReorder) {
      return _buildCard(pageIndex, isHovered: false);
    }

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != pageIndex,
      onAcceptWithDetails: (details) {
        setState(() => _hoveredDropTargetIndex = null);
        widget.onReorder(details.data, pageIndex);
      },
      onMove: (_) {
        if (_hoveredDropTargetIndex == pageIndex) return;
        setState(() => _hoveredDropTargetIndex = pageIndex);
      },
      onLeave: (_) {
        if (_hoveredDropTargetIndex != pageIndex) return;
        setState(() => _hoveredDropTargetIndex = null);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered =
            candidateData.isNotEmpty || _hoveredDropTargetIndex == pageIndex;

        return LongPressDraggable<int>(
          data: pageIndex,
          feedback: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 160,
              height: 235,
              child: Opacity(
                opacity: 0.92,
                child: _buildCard(pageIndex, isHovered: false),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildCard(pageIndex, isHovered: false),
          ),
          child: _buildCard(pageIndex, isHovered: isHovered),
        );
      },
    );
  }

  Widget _buildCard(int pageIndex, {required bool isHovered}) {
    final page = widget.coreInfo.pages[pageIndex];
    return PageThumbnailCard(
      coreInfo: widget.coreInfo,
      pageIndex: pageIndex,
      page: page,
      isActive: pageIndex == widget.currentPageIndex,
      isDragTargetHovered: isHovered,
      onJumpToPage: () => widget.onJumpToPage(pageIndex),
      onToggleBookmark: () => widget.onToggleBookmark(pageIndex),
      onDuplicate: () => widget.onDuplicate(pageIndex),
      onInsertAfter: () => widget.onInsertAfter(pageIndex),
      onClear: widget.onClear != null ? () => widget.onClear!(pageIndex) : null,
      onDelete: () => widget.onDelete(pageIndex),
    );
  }
}
