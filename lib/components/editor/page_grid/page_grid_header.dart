/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/i18n/strings.g.dart';

/// Filter selection for the page grid overview / document hub.
enum PageGridFilter { all, bookmarked, outline }

/// Responsive header bar for the page grid overview dialog.
///
/// Renders the title badge, segmented filter selector, add-page action,
/// and close button, stacking cleanly on compact widths.
class PageGridHeader extends StatelessWidget {
  /// Creates a [PageGridHeader].
  const PageGridHeader({
    super.key,
    required this.filter,
    required this.totalPages,
    required this.bookmarkedCount,
    required this.onFilterChanged,
    required this.onAddPage,
    required this.onClose,
  });

  /// Currently selected filter tab.
  final PageGridFilter filter;

  /// Total number of pages in the document.
  final int totalPages;

  /// Number of bookmarked pages in the document.
  final int bookmarkedCount;

  /// Called when the user switches the filter tab.
  final ValueChanged<PageGridFilter> onFilterChanged;

  /// Called when the user taps the add-page button.
  final VoidCallback onAddPage;

  /// Called when the user closes the overview dialog.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 680;
        final filterControl = _buildFilterControl(colorScheme);
        final titleRow = _buildTitleLeading(theme);
        final actionButtons = _buildActionButtons(context);

        if (isCompact) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [titleRow, const Spacer(), ...actionButtons]),
                const SizedBox(height: 8),
                Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: filterControl),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 14, 12),
          child: Row(
            children: [
              titleRow,
              const SizedBox(width: 12),
              Expanded(
                child: Center(
                  child: FittedBox(fit: BoxFit.scaleDown, child: filterControl),
                ),
              ),
              const SizedBox(width: 12),
              ...actionButtons,
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleLeading(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(
              Icons.grid_view_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          t.editor.pages,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterControl(ColorScheme colorScheme) {
    return SegmentedButton<PageGridFilter>(
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        selectedBackgroundColor: colorScheme.primaryContainer,
        selectedForegroundColor: colorScheme.onPrimaryContainer,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      segments: [
        ButtonSegment<PageGridFilter>(
          value: PageGridFilter.all,
          label: Text(t.editor.pageGrid.all(n: totalPages)),
          icon: const Icon(Icons.grid_view, size: 16),
        ),
        ButtonSegment<PageGridFilter>(
          value: PageGridFilter.bookmarked,
          label: Text(t.editor.pageGrid.bookmarked(n: bookmarkedCount)),
          icon: const Icon(Icons.star, size: 16),
        ),
        ButtonSegment<PageGridFilter>(
          value: PageGridFilter.outline,
          label: Text(t.editor.outline.title),
          icon: const Icon(Icons.format_list_bulleted, size: 16),
        ),
      ],
      selected: {filter},
      onSelectionChanged: (newSelection) => onFilterChanged(newSelection.first),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    return [
      IconButton(
        key: const Key('add_page_button'),
        icon: const AdaptiveIcon(
          icon: Icons.add,
          cupertinoIcon: CupertinoIcons.add,
        ),
        tooltip: t.editor.menu.insertPage,
        onPressed: onAddPage,
      ),
      IconButton(
        key: const Key('close_overview_button'),
        icon: const Icon(Icons.close),
        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        onPressed: onClose,
      ),
    ];
  }
}
