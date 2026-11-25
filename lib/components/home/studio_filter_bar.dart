/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/i18n/strings.g.dart';

/// Filter category for the Home / Library studio bar.
enum LibraryFilter { all, recent, folders }

/// Sort order for notebooks displayed in the studio grid or shelf.
enum LibrarySortOrder { recent, name }

/// Compact studio control bar featuring an inline search trigger, filter chips
/// (All, Recent, Folders), and crisp sort + view-mode toggles.
class StudioFilterBar extends StatelessWidget {
  const StudioFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.sortOrder,
    required this.onSortChanged,
    required this.isStudioMode,
    required this.onToggleViewMode,
    required this.onSearchTap,
  });

  final LibraryFilter activeFilter;
  final ValueChanged<LibraryFilter> onFilterChanged;
  final LibrarySortOrder sortOrder;
  final ValueChanged<LibrarySortOrder> onSortChanged;
  final bool isStudioMode;
  final VoidCallback onToggleViewMode;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: isDark
                ? OpennoteTokens.cardDarkSurface
                : OpennoteTokens.cardLightSurface,
            borderRadius: BorderRadius.circular(OpennoteTokens.radiusPill),
            child: InkWell(
              key: const ValueKey('StudioSearchPill'),
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(OpennoteTokens.radiusPill),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    OpennoteTokens.radiusPill,
                  ),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.42),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.home.search.hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterPill(
                        label: 'All',
                        selected: activeFilter == LibraryFilter.all,
                        onTap: () => onFilterChanged(LibraryFilter.all),
                      ),
                      const SizedBox(width: 6),
                      _FilterPill(
                        label: 'Recent',
                        selected: activeFilter == LibraryFilter.recent,
                        onTap: () => onFilterChanged(LibraryFilter.recent),
                      ),
                      const SizedBox(width: 6),
                      _FilterPill(
                        label: 'Folders',
                        selected: activeFilter == LibraryFilter.folders,
                        onTap: () => onFilterChanged(LibraryFilter.folders),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CompactActionButton(
                key: const ValueKey('StudioSortToggle'),
                icon: sortOrder == LibrarySortOrder.recent
                    ? Icons.schedule_rounded
                    : Icons.sort_by_alpha_rounded,
                tooltip: sortOrder == LibrarySortOrder.recent
                    ? 'Sorted by recent'
                    : 'Sorted by name',
                onTap: () => onSortChanged(
                  sortOrder == LibrarySortOrder.recent
                      ? LibrarySortOrder.name
                      : LibrarySortOrder.recent,
                ),
              ),
              const SizedBox(width: 6),
              _CompactActionButton(
                key: const ValueKey('StudioViewToggle'),
                icon: isStudioMode
                    ? Icons.auto_stories_rounded
                    : Icons.grid_view_rounded,
                tooltip: isStudioMode ? 'Notebook Shelf View' : 'Grid View',
                onTap: onToggleViewMode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Material(
      color: selected
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(OpennoteTokens.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(OpennoteTokens.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(OpennoteTokens.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OpennoteTokens.radiusSm),
          child: SizedBox(
            width: 34,
            height: 32,
            child: Icon(icon, size: 17, color: colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
