/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:saber/components/home/floating_selection_dock.dart';
import 'package:saber/components/home/grid_folders.dart';
import 'package:saber/components/home/masonry_files.dart';
import 'package:saber/components/home/new_note_button.dart';
import 'package:saber/components/home/no_files.dart';
import 'package:saber/components/home/notebook_shelf.dart';
import 'package:saber/components/home/path_components.dart';
import 'package:saber/components/home/quick_template_strip.dart';
import 'package:saber/components/home/search_dialog.dart';
import 'package:saber/components/home/studio_filter_bar.dart';
import 'package:saber/components/home/syncing_button.dart';
import 'package:saber/components/home/trash_drop_zone.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';

/// Library / Browse studio surface for navigating folders and notebooks.
class BrowsePage extends StatefulWidget {
  const BrowsePage({
    super.key,
    String? path,
    this.topBanner,
    this.proBannerBuilder,
    this.onCreateTemplate,
    this.onProTemplateTap,
  }) : initialPath = path;

  final String? initialPath;

  /// Optional widget displayed at the top of the Browse scroll view.
  final Widget? topBanner;

  /// Optional builder for a contextual Pro upgrade banner.
  final WidgetBuilder? proBannerBuilder;

  /// Optional callback invoked when a free quick-start template is tapped.
  final ValueChanged<QuickTemplateKind>? onCreateTemplate;

  /// Optional callback invoked when a Pro-badged template is tapped.
  final ValueChanged<QuickTemplateKind>? onProTemplateTap;

  @visibleForTesting
  static DirectoryChildren? overrideChildren;

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  DirectoryChildren? children;
  String? path;
  LibraryFilter _activeFilter = LibraryFilter.folders;
  LibrarySortOrder _sortOrder = LibrarySortOrder.name;

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
    stows.opennoteUiMode.addListener(_setState);

    super.initState();
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
    if (!event.filePath.startsWith(path ?? '/')) return;
    findChildrenOfPath(fromFileListener: true);
  }

  void _setState() => setState(() {});

  Future findChildrenOfPath({bool fromFileListener = false}) async {
    if (!mounted) return;

    if (fromFileListener) {
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

  void _onFilterChanged(LibraryFilter filter) {
    if (filter == LibraryFilter.recent) {
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        router.go(HomeRoutes.getRoute(0));
        return;
      }
    }
    setState(() => _activeFilter = filter);
  }

  List<String> _sortedFiles(Iterable<String> rawFiles) {
    final list = rawFiles.toList();
    if (_sortOrder == LibrarySortOrder.name) {
      list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final platform = Theme.of(context).platform;
    final crossAxisCount = MediaQuery.sizeOf(context).width ~/ 300 + 1;
    final isStudioMode = stows.opennoteUiMode.value;
    final resolvedBanner =
        widget.topBanner ?? widget.proBannerBuilder?.call(context);

    final folderNames = _sortedFiles(children?.directories ?? const []);
    final fileNames = _sortedFiles(children?.files ?? const []);
    final fullFilePaths = [
      for (final filePath in fileNames) "${path ?? ""}/$filePath",
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () => Future.wait([
                findChildrenOfPath(),
                Future.delayed(const Duration(milliseconds: 500)),
              ]),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    collapsedHeight: 56,
                    expandedHeight: 84,
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
                    actions: const [SyncingButton(), SizedBox(width: 6)],
                  ),
                  if (resolvedBanner != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                        child: resolvedBanner,
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: StudioFilterBar(
                      activeFilter: _activeFilter,
                      onFilterChanged: _onFilterChanged,
                      sortOrder: _sortOrder,
                      onSortChanged: (order) =>
                          setState(() => _sortOrder = order),
                      isStudioMode: isStudioMode,
                      onToggleViewMode: () {
                        stows.opennoteUiMode.value =
                            !stows.opennoteUiMode.value;
                      },
                      onSearchTap: () => SearchDialog.show(context),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: QuickTemplateStrip(
                      createPath: path,
                      compact: true,
                      showHeader: false,
                      onCreateTemplate: widget.onCreateTemplate,
                      onProTemplateTap: widget.onProTemplateTap,
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(top: 6)),
                  SliverToBoxAdapter(
                    child: PathComponents(
                      path,
                      onPathComponentTap: onPathComponentTap,
                      onItemMoved: (item, target) => findChildrenOfPath(),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 8)),
                  GridFolders(
                    isAtRoot: path?.isEmpty ?? true,
                    currentPath: path,
                    crossAxisCount: crossAxisCount,
                    onTap: onDirectoryTap,
                    onItemMoved: (item, target) => findChildrenOfPath(),
                    createFolder: createFolder,
                    doesFolderExist: (String folderName) {
                      return children?.directories.contains(folderName) ??
                          false;
                    },
                    renameFolder: (String oldName, String newName) async {
                      final oldPath = '${path ?? ''}/$oldName';
                      await FileManager.renameDirectory(oldPath, newName);
                      findChildrenOfPath();
                    },
                    isFolderEmpty: (String folderName) async {
                      final folderPath = '${path ?? ''}/$folderName';
                      final dirChildren =
                          await FileManager.getChildrenOfDirectory(folderPath);
                      return dirChildren?.isEmpty ?? true;
                    },
                    deleteFolder: (String folderName) async {
                      final folderPath = '${path ?? ''}/$folderName';
                      await FileManager.deleteDirectory(folderPath);
                      findChildrenOfPath();
                    },
                    folders: folderNames,
                  ),
                  if (children == null) ...[
                    // loading
                  ] else if (isStudioMode) ...[
                    SliverToBoxAdapter(
                      child: NotebookShelf(
                        directory: path,
                        notes: {
                          ...fullFilePaths,
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
                        onMoveItem: (item, target) => findChildrenOfPath(),
                        onDeleteNote: (note) => findChildrenOfPath(),
                        onRenameNote: (oldPath, newName) =>
                            findChildrenOfPath(),
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
                      minimum: const EdgeInsets.only(top: 8, bottom: 70),
                      sliver: MasonryFiles(
                        crossAxisCount: crossAxisCount,
                        files: fullFilePaths,
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
                onItemDeleted: (deletedPath) => findChildrenOfPath(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: NewNoteButton(
        cupertino: platform.isCupertino,
        path: path,
      ),
      bottomNavigationBar: selectedFiles.value.isEmpty
          ? null
          : FloatingSelectionDock(
              selectedFiles: selectedFiles.value,
              unselectNotes: () => selectedFiles.value = [],
            ),
    );
  }
}
