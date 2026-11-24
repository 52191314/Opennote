/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'dart:async';

import 'package:collapsible/collapsible.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/home/delete_note_button.dart';
import 'package:saber/components/home/export_note_button.dart';
import 'package:saber/components/home/masonry_files.dart';
import 'package:saber/components/home/move_note_button.dart';
import 'package:saber/components/home/new_note_button.dart';
import 'package:saber/components/home/notebook_shelf.dart';
import 'package:saber/components/home/rename_note_button.dart';
import 'package:saber/components/home/search_dialog.dart';
import 'package:saber/components/home/syncing_button.dart';
import 'package:saber/components/home/trash_drop_zone.dart';
import 'package:saber/components/home/welcome.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';

class RecentPage extends StatefulWidget {
  const RecentPage({super.key});

  @override
  State<RecentPage> createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> {
  final List<String> filePaths = [];
  var failed = false;

  final ValueNotifier<List<String>> selectedFiles = ValueNotifier([]);

  final log = Logger('RecentPage');

  /// Mitigates a bug where files got imported starting with `null/` instead of `/`.
  void moveIncorrectlyImportedFiles() async {
    for (final filePath in stows.recentFiles.value) {
      if (filePath.startsWith('/')) continue;

      final String newFilePath;
      if (filePath.startsWith('null/')) {
        newFilePath = await FileManager.suffixFilePathToMakeItUnique(
          filePath.substring('null'.length),
        );
      } else {
        newFilePath = await FileManager.suffixFilePathToMakeItUnique(
          '/$filePath',
        );
      }

      log.warning(
        'Found incorrectly imported file at `$filePath`; moving to `$newFilePath`',
      );
      await FileManager.moveFile(filePath, newFilePath);
    }
  }

  @override
  void initState() {
    findRecentlyAccessedNotes();
    fileWriteSubscription = FileManager.fileWriteStream.stream.listen(
      fileWriteListener,
    );
    selectedFiles.addListener(_setState);
    stows.opennoteUiMode.addListener(_setState);

    super.initState();
    moveIncorrectlyImportedFiles();
  }

  @override
  void dispose() {
    selectedFiles.removeListener(_setState);
    stows.opennoteUiMode.removeListener(_setState);
    fileWriteSubscription?.cancel();
    super.dispose();
  }

  StreamSubscription? fileWriteSubscription;
  void fileWriteListener(FileOperation event) {
    findRecentlyAccessedNotes(fromFileListener: true);
  }

  void _setState() => setState(() {});

  Future findRecentlyAccessedNotes({bool fromFileListener = false}) async {
    if (!mounted) return;

    if (fromFileListener) {
      final location = GoRouterState.of(context).uri.toString();
      if (!location.startsWith(RoutePaths.prefixOfHome)) return;
    }

    final children = await FileManager.getRecentlyAccessed();
    filePaths.clear();
    if (children.isEmpty) {
      failed = true;
    } else {
      failed = false;
      filePaths.addAll(children);
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final platform = Theme.of(context).platform;
    final crossAxisCount = MediaQuery.sizeOf(context).width ~/ 300 + 1;
    final isStudioMode = stows.opennoteUiMode.value;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () => Future.wait([
                findRecentlyAccessedNotes(),
                Future.delayed(const Duration(milliseconds: 500)),
              ]),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    collapsedHeight: 56,
                    expandedHeight: 88,
                    pinned: true,
                    scrolledUnderElevation: 0.5,
                    surfaceTintColor: Colors.transparent,
                    shape: Border(
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.25,
                        ),
                        width: 1,
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        t.home.titles.home,
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
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: t.home.search.hint,
                        onPressed: () => SearchDialog.show(context),
                      ),
                      IconButton(
                        icon: Icon(
                          isStudioMode
                              ? Icons.auto_stories_rounded
                              : Icons.grid_view_rounded,
                        ),
                        tooltip: isStudioMode
                            ? 'Notebook Shelf View'
                            : 'Grid View',
                        onPressed: () {
                          stows.opennoteUiMode.value =
                              !stows.opennoteUiMode.value;
                        },
                      ),
                      const SyncingButton(),
                      const SizedBox(width: 4),
                    ],
                  ),
                  // Workspace Omnibar & Bento Hero Action Strip
                  SliverToBoxAdapter(
                    child: _WorkspaceHeroStrip(isStudioMode: isStudioMode),
                  ),
                  if (failed) ...[
                    const SliverSafeArea(
                      sliver: SliverToBoxAdapter(child: Welcome()),
                    ),
                  ] else if (isStudioMode && filePaths.isNotEmpty) ...[
                    // Jump Back In — Pinned & Recent Shelf
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_stories_rounded,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Jump Back In — Pinned & Recent Shelf',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: NotebookShelf(
                        notes: filePaths,
                        folders: const [],
                        onOpenNote: (note) =>
                            context.push(RoutePaths.editFilePath(note)),
                        onOpenFolder: (_) {},
                        onDeleteNote: (note) => findRecentlyAccessedNotes(),
                        onRenameNote: (oldPath, newName) =>
                            findRecentlyAccessedNotes(),
                        onCreateNote: (note) =>
                            context.push(RoutePaths.editFilePath(note)),
                      ),
                    ),
                  ] else ...[
                    SliverSafeArea(
                      minimum: const .only(bottom: 70),
                      sliver: MasonryFiles(
                        crossAxisCount: crossAxisCount,
                        files: [for (final filePath in filePaths) filePath],
                        selectedFiles: selectedFiles,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: TrashDropZone(
                onItemDeleted: (deletedPath) => findRecentlyAccessedNotes(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: NewNoteButton(cupertino: platform.isCupertino),
      bottomNavigationBar: selectedFiles.value.isEmpty
          ? null
          : _FloatingSelectionDock(
              selectedFiles: selectedFiles.value,
              unselectNotes: () => selectedFiles.value = [],
            ),
    );
  }
}

class _WorkspaceHeroStrip extends StatelessWidget {
  const _WorkspaceHeroStrip({required this.isStudioMode});

  final bool isStudioMode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 680;

    final cards = [
      _HeroCardData(
        icon: Icons.edit_document,
        title: 'Quick Note',
        subtitle: 'Blank Canvas',
        color: colorScheme.primary,
        onTap: () => context.push(RoutePaths.edit),
      ),
      _HeroCardData(
        icon: Icons.all_inclusive_rounded,
        title: 'Infinite Board',
        subtitle: 'Freeform Canvas',
        color: const Color(0xFF6750A4),
        onTap: () => context.go(HomeRoutes.getRoute(2)),
      ),
      _HeroCardData(
        icon: isStudioMode
            ? Icons.auto_stories_rounded
            : Icons.grid_view_rounded,
        title: isStudioMode ? 'Shelf View' : 'Grid View',
        subtitle: isStudioMode ? 'Notebook Covers' : 'Card Grid',
        color: const Color(0xFF1B6B76),
        onTap: () {
          stows.opennoteUiMode.value = !stows.opennoteUiMode.value;
        },
      ),
      _HeroCardData(
        icon: Icons.manage_search_rounded,
        title: 'Search Notes',
        subtitle: 'Quick Find',
        color: const Color(0xFF8D5B2C),
        onTap: () => SearchDialog.show(context),
      ),
    ];

    if (isCompact) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final card = cards[index];
              return SizedBox(width: 160, child: _HeroActionCard(data: card));
            },
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: _HeroActionCard(data: cards[i])),
          ],
        ],
      ),
    );
  }
}

class _HeroCardData {
  const _HeroCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}

class _HeroActionCard extends StatelessWidget {
  const _HeroActionCard({required this.data});

  final _HeroCardData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    return Material(
      color: isDark
          ? OpennoteTokens.cardDarkSurface
          : OpennoteTokens.cardLightSurface,
      borderRadius: BorderRadius.circular(OpennoteTokens.radiusMd),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(OpennoteTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OpennoteTokens.radiusMd),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.38),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(OpennoteTokens.radiusSm),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(data.icon, size: 20, color: data.color),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingSelectionDock extends StatelessWidget {
  const _FloatingSelectionDock({
    required this.selectedFiles,
    required this.unselectNotes,
  });

  final List<String> selectedFiles;
  final VoidCallback unselectNotes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color:
                (isDark
                        ? colorScheme.surfaceContainerHigh
                        : colorScheme.surface)
                    .withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(OpennoteTokens.radiusPill),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${selectedFiles.length} selected',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                tooltip: 'Clear selection',
                onPressed: unselectNotes,
              ),
              const SizedBox(width: 4),
              Collapsible(
                axis: CollapsibleAxis.horizontal,
                collapsed: selectedFiles.length != 1,
                child: RenameNoteButton(
                  existingPath: selectedFiles.isEmpty
                      ? ''
                      : selectedFiles.first,
                  unselectNotes: unselectNotes,
                ),
              ),
              MoveNoteButton(
                filesToMove: selectedFiles,
                unselectNotes: unselectNotes,
              ),
              DeleteNoteButton(
                filesToDelete: selectedFiles,
                unselectNotes: unselectNotes,
              ),
              ExportNoteButton(selectedFiles: selectedFiles),
            ],
          ),
        ),
      ),
    );
  }
}
