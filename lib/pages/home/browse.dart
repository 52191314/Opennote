/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'dart:async';

import 'package:collapsible/collapsible.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/home/delete_note_button.dart';
import 'package:saber/components/home/export_note_button.dart';
import 'package:saber/components/home/grid_folders.dart';
import 'package:saber/components/home/masonry_files.dart';
import 'package:saber/components/home/move_note_button.dart';
import 'package:saber/components/home/new_note_button.dart';
import 'package:saber/components/home/no_files.dart';
import 'package:saber/components/home/notebook_shelf.dart';
import 'package:saber/components/home/path_components.dart';
import 'package:saber/components/home/rename_note_button.dart';
import 'package:saber/components/home/search_dialog.dart';
import 'package:saber/components/home/syncing_button.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key, String? path}) : initialPath = path;

  final String? initialPath;

  @visibleForTesting
  static DirectoryChildren? overrideChildren;

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  DirectoryChildren? children;

  String? path;

  final ValueNotifier<List<String>> selectedFiles = ValueNotifier([]);

  /// Notebooks created on the shelf before the directory listing refreshes.
  final _pendingNotes = <String>[];

  @override
  void initState() {
    path = widget.initialPath;

    findChildrenOfPath();
    fileWriteSubscription = FileManager.fileWriteStream.stream.listen(
      fileWriteListener,
    );
    selectedFiles.addListener(_setState);
    stows.goodnotesUiMode.addListener(_setState);

    super.initState();
  }

  @override
  void dispose() {
    selectedFiles.removeListener(_setState);
    stows.goodnotesUiMode.removeListener(_setState);
    fileWriteSubscription?.cancel();
    super.dispose();
  }

  StreamSubscription? fileWriteSubscription;
  void fileWriteListener(FileOperation event) {
    if (!event.filePath.startsWith(path ?? '/')) return;
    findChildrenOfPath(fromFileListener: true);
  }

  void _setState() => setState(() {});

  Future findChildrenOfPath({bool fromFileListener = false}) async {
    if (!mounted) return;

    if (fromFileListener) {
      // don't refresh if we're not on the home page
      final location = GoRouterState.of(context).uri.toString();
      if (!location.startsWith(RoutePaths.prefixOfHome)) return;
    }

    children =
        BrowsePage.overrideChildren ??
        await FileManager.getChildrenOfDirectory(path ?? '/');

    if (mounted) setState(() {});
  }

  void onDirectoryTap(String folder) {
    selectedFiles.value = [];
    if (folder == '..') {
      path = p.dirname(path ?? '/');
      if (path == '/') path = null;
    } else {
      path = p.join(path ?? '/', folder);
    }
    context.go(HomeRoutes.browseFilePath(path ?? '/'));
    findChildrenOfPath();
  }

  void onPathComponentTap(String? newPath) {
    selectedFiles.value = [];
    if (newPath == null || newPath.isEmpty || newPath == '/') {
      newPath = null;
    }
    path = newPath;
    context.go(HomeRoutes.browseFilePath(path ?? '/'));
    findChildrenOfPath();
  }

  Future<void> createFolder(String folderName) async {
    final folderPath = '${path ?? ''}/$folderName';
    await FileManager.createFolder(folderPath);
    findChildrenOfPath();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final platform = Theme.of(context).platform;
    final crossAxisCount = MediaQuery.sizeOf(context).width ~/ 300 + 1;
    final isStudioMode = stows.goodnotesUiMode.value;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Future.wait([
          findChildrenOfPath(),
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
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  t.home.titles.browse,
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
                  tooltip: isStudioMode ? 'Notebook Shelf View' : 'Grid View',
                  onPressed: () {
                    stows.goodnotesUiMode.value = !stows.goodnotesUiMode.value;
                  },
                ),
                const SyncingButton(),
                const SizedBox(width: 4),
              ],
            ),
            // Workspace Omnibar & Bento Hero Action Strip
            SliverToBoxAdapter(
              child: _WorkspaceHeroStrip(
                isStudioMode: isStudioMode,
                createPath: path,
              ),
            ),
            SliverToBoxAdapter(
              child: PathComponents(
                path,
                onPathComponentTap: onPathComponentTap,
              ),
            ),
            const SliverPadding(padding: .only(bottom: 8)),
            GridFolders(
              isAtRoot: path?.isEmpty ?? true,
              crossAxisCount: crossAxisCount,
              onTap: onDirectoryTap,
              createFolder: createFolder,
              doesFolderExist: (String folderName) {
                return children?.directories.contains(folderName) ?? false;
              },
              renameFolder: (String oldName, String newName) async {
                final oldPath = '${path ?? ''}/$oldName';
                await FileManager.renameDirectory(oldPath, newName);
                findChildrenOfPath();
              },
              isFolderEmpty: (String folderName) async {
                final folderPath = '${path ?? ''}/$folderName';
                final children = await FileManager.getChildrenOfDirectory(
                  folderPath,
                );
                return children?.isEmpty ?? true;
              },
              deleteFolder: (String folderName) async {
                final folderPath = '${path ?? ''}/$folderName';
                await FileManager.deleteDirectory(folderPath);
                findChildrenOfPath();
              },
              folders: [
                for (final directoryPath in children?.directories ?? const [])
                  directoryPath,
              ],
            ),
            if (children == null) ...[
              // loading
            ] else if (isStudioMode) ...[
              SliverToBoxAdapter(
                child: NotebookShelf(
                  directory: path,
                  notes: {
                    for (final filePath in children?.files ?? const [])
                      "${path ?? ""}/$filePath",
                    ..._pendingNotes.where(
                      (note) => path == null
                          ? !note.substring(1).contains('/')
                          : note.startsWith('$path/'),
                    ),
                  }.toList(),
                  folders: const [],
                  onOpenNote: (note) =>
                      context.push(RoutePaths.editFilePath(note)),
                  onOpenFolder: onDirectoryTap,
                  onCreateNote: (note) {
                    setState(() => _pendingNotes.add(note));
                    context.push(RoutePaths.editFilePath(note));
                  },
                ),
              ),
            ] else if (children!.isEmpty) ...[
              const SliverSafeArea(
                sliver: SliverToBoxAdapter(child: NoFiles()),
              ),
            ] else ...[
              SliverSafeArea(
                top: false,
                minimum: const .only(top: 8, bottom: 70),
                sliver: MasonryFiles(
                  crossAxisCount: crossAxisCount,
                  files: [
                    for (final filePath in children?.files ?? const [])
                      "${path ?? ""}/$filePath",
                  ],
                  selectedFiles: selectedFiles,
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: NewNoteButton(
        cupertino: platform.isCupertino,
        path: path,
      ),
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
  const _WorkspaceHeroStrip({required this.isStudioMode, this.createPath});

  final bool isStudioMode;
  final String? createPath;

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
        onTap: () {
          if (createPath != null && createPath!.isNotEmpty) {
            context.push(RoutePaths.editFilePath('$createPath/Untitled'));
          } else {
            context.push(RoutePaths.edit);
          }
        },
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
          stows.goodnotesUiMode.value = !stows.goodnotesUiMode.value;
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
