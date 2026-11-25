/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/i18n/strings.g.dart';

/// Popup menu exposing page-level actions (duplicate, insert, clear, delete).
class PageOptionsMenu extends StatelessWidget {
  /// Creates a [PageOptionsMenu] for the page at [pageIndex].
  const PageOptionsMenu({
    super.key,
    required this.pageIndex,
    required this.totalPages,
    required this.onDuplicate,
    required this.onInsertAfter,
    required this.onDelete,
    this.onClear,
  });

  /// Zero-based index of the target page.
  final int pageIndex;

  /// Total number of pages in the document (used for clear label and delete guard).
  final int totalPages;

  /// Called when the user chooses to duplicate this page.
  final VoidCallback onDuplicate;

  /// Called when the user chooses to insert a blank page after this page.
  final VoidCallback onInsertAfter;

  /// Called when the user chooses to delete this page.
  final VoidCallback onDelete;

  /// Optional callback to clear the contents of this page.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final canDelete = totalPages > 1;
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      key: Key('page_menu_$pageIndex'),
      icon: Icon(
        Icons.more_vert_rounded,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tooltip: t.editor.pageGrid.pageOptions,
      onSelected: _handleSelection,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'duplicate',
          key: Key('duplicate_page_$pageIndex'),
          child: _MenuRow(
            icon: Icons.copy_rounded,
            label: t.editor.menu.duplicatePage,
          ),
        ),
        PopupMenuItem(
          value: 'insert',
          key: Key('insert_page_$pageIndex'),
          child: _MenuRow(
            icon: Icons.add_box_outlined,
            label: t.editor.menu.insertPage,
          ),
        ),
        if (onClear != null)
          PopupMenuItem(
            value: 'clear',
            key: Key('clear_page_$pageIndex'),
            child: _MenuRow(
              icon: Icons.cleaning_services_outlined,
              label: t.editor.menu.clearPage(
                page: pageIndex + 1,
                totalPages: totalPages,
              ),
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          enabled: canDelete,
          key: Key('delete_page_$pageIndex'),
          child: _MenuRow(
            icon: Icons.delete_outline_rounded,
            label: t.editor.menu.deletePage,
            color: canDelete ? Colors.red : null,
          ),
        ),
      ],
    );
  }

  void _handleSelection(String value) {
    switch (value) {
      case 'duplicate':
        onDuplicate();
      case 'insert':
        onInsertAfter();
      case 'clear':
        onClear?.call();
      case 'delete':
        onDelete();
    }
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: color != null ? TextStyle(color: color) : null),
      ],
    );
  }
}
