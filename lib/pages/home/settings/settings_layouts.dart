/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/settings/update_manager.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/home/settings/settings_category.dart';

/// Shared search field used by both wide and compact settings layouts.
class SettingsSearchField extends StatelessWidget {
  const SettingsSearchField({
    super.key,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
    this.compact = false,
  });

  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final borderRadius = BorderRadius.circular(compact ? 12 : 10);
    final borderSide = BorderSide(
      color: colorScheme.outlineVariant.withValues(alpha: compact ? 0.45 : 0.4),
    );

    return TextField(
      key: const ValueKey('settings-search-field'),
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: t.home.search.hint,
        prefixIcon: Icon(Icons.search_rounded, size: compact ? 20 : 18),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear_rounded, size: compact ? 18 : 16),
                onPressed: onClear,
              )
            : null,
        isDense: true,
        filled: true,
        fillColor: compact
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainer,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 10,
          vertical: compact ? 10 : 8,
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: borderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: borderSide,
        ),
      ),
    );
  }
}

/// Two-pane wide settings layout with a left category rail and detail view.
class SettingsWideLayout extends StatelessWidget {
  const SettingsWideLayout({
    super.key,
    required this.selectedCategory,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.onCategorySelected,
    required this.cards,
  });

  final SettingsCategory selectedCategory;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final ValueChanged<SettingsCategory> onCategorySelected;
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                border: BorderDirectional(
                  end: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                right: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        t.home.titles.settings,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      child: SettingsSearchField(
                        controller: searchController,
                        searchQuery: searchQuery,
                        onChanged: onSearchChanged,
                        onClear: onSearchCleared,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        children: [
                          for (final category in SettingsCategory.values)
                            _WideCategoryRailItem(
                              category: category,
                              selected: selectedCategory == category,
                              onTap: () => onCategorySelected(category),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text(
                    selectedCategory.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  pinned: true,
                  scrolledUnderElevation: 0.5,
                  surfaceTintColor: Colors.transparent,
                  shape: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  actions: const [_UpdateStatusAction()],
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  sliver: SliverList.list(children: cards),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Single-column compact settings layout with search field and category chips.
class SettingsCompactLayout extends StatelessWidget {
  const SettingsCompactLayout({
    super.key,
    required this.selectedCategory,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.onCategorySelected,
    required this.cards,
  });

  final SettingsCategory selectedCategory;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final ValueChanged<SettingsCategory> onCategorySelected;
  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            collapsedHeight: 56,
            expandedHeight: 88,
            pinned: true,
            scrolledUnderElevation: 0.5,
            surfaceTintColor: Colors.transparent,
            shape: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                t.home.titles.settings,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsetsDirectional.only(
                start: 20,
                bottom: 12,
              ),
            ),
            actions: const [_UpdateStatusAction()],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsSearchField(
                    controller: searchController,
                    searchQuery: searchQuery,
                    onChanged: onSearchChanged,
                    onClear: onSearchCleared,
                    compact: true,
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final category in SettingsCategory.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              key: ValueKey(
                                'settings-category-${category.name}',
                              ),
                              avatar: Icon(category.icon, size: 16),
                              label: Text(category.label),
                              selected: selectedCategory == category,
                              onSelected: (_) => onCategorySelected(category),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverSafeArea(top: false, sliver: SliverList.list(children: cards)),
        ],
      ),
    );
  }
}

class _WideCategoryRailItem extends StatelessWidget {
  const _WideCategoryRailItem({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final SettingsCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(OpennoteTokens.radiusSm),
        child: InkWell(
          key: ValueKey('settings-category-${category.name}'),
          borderRadius: BorderRadius.circular(OpennoteTokens.radiusSm),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  category.icon,
                  size: 18,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdateStatusAction extends StatelessWidget {
  const _UpdateStatusAction();

  @override
  Widget build(BuildContext context) {
    if (UpdateManager.status.value == .upToDate) {
      return const SizedBox.shrink();
    }
    return IconButton(
      tooltip: t.home.tooltips.showUpdateDialog,
      icon: const Icon(Icons.system_update),
      onPressed: () {
        UpdateManager.showUpdateDialog(context, userTriggered: true);
      },
    );
  }
}
