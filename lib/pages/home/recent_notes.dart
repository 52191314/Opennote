/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:saber/components/home/floating_selection_dock.dart';
import 'package:saber/components/home/masonry_files.dart';
import 'package:saber/components/home/new_note_button.dart';
import 'package:saber/components/home/notebook_shelf.dart';
import 'package:saber/components/home/quick_template_strip.dart';
import 'package:saber/components/home/search_dialog.dart';
import 'package:saber/components/home/studio_filter_bar.dart';
import 'package:saber/components/home/syncing_button.dart';
import 'package:saber/components/home/trash_drop_zone.dart';
import 'package:saber/components/home/welcome.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';

/// Home / Recent Notes studio surface featuring quick-start templates, inline
/// search & filter chips, optional Pro banner slot, and Shelf/Grid views.
class RecentPage extends StatefulWidget {
  const RecentPage({
    super.key,
    this.topBanner,
    this.proBannerBuilder,
    this.onCreateTemplate,
    this.onProTemplateTap,
  });

  /// Optional widget displayed at the top of the scroll view (e.g. promo banner).
  final Widget? topBanner;

  /// Optional builder for a contextual Pro upgrade banner.
  final WidgetBuilder? proBannerBuilder;

  /// Optional callback invoked when a free quick-start template is tapped.
  final ValueChanged<QuickTemplateKind>? onCreateTemplate;

  /// Optional callback invoked when a Pro-badged template is tapped.
  final ValueChanged<QuickTemplateKind>? onProTemplateTap;

  @override
  State<RecentPage> createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> {
  final List<String> filePaths = [];
  var failed = false;
  LibraryFilter _activeFilter = LibraryFilter.all;
  LibrarySortOrder _sortOrder = LibrarySortOrder.recent;

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

  List<String> get _visibleFilePaths {
    var list = List<String>.of(filePaths);
    if (_activeFilter == LibraryFilter.recent && list.length > 8) {
      list = list.take(8).toList();
    }
    if (_sortOrder == LibrarySortOrder.name) {
      list.sort((a, b) {
        final nameA = a.substring(a.lastIndexOf('/') + 1).toLowerCase();
        final nameB = b.substring(b.lastIndexOf('/') + 1).toLowerCase();
        return nameA.compareTo(nameB);
      });
    }
    return list;
  }

  void _onFilterChanged(LibraryFilter filter) {
    if (filter == LibraryFilter.folders) {
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        router.go(HomeRoutes.getRoute(1));
        return;
      }
    }
    setState(() => _activeFilter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final platform = Theme.of(context).platform;
    final crossAxisCount = MediaQuery.sizeOf(context).width ~/ 300 + 1;
    final isStudioMode = stows.opennoteUiMode.value;
    final visibleFiles = _visibleFilePaths;
    final resolvedBanner =
        widget.topBanner ?? widget.proBannerBuilder?.call(context);

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
                  if (!failed)
                    SliverToBoxAdapter(
                      child: QuickTemplateStrip(
                        onCreateTemplate: widget.onCreateTemplate,
                        onProTemplateTap: widget.onProTemplateTap,
                      ),
                    ),
                  if (failed) ...[
                    SliverSafeArea(
                      sliver: SliverToBoxAdapter(
                        child: Welcome(
                          onCreateTemplate: widget.onCreateTemplate,
                          onProTemplateTap: widget.onProTemplateTap,
                        ),
                      ),
                    ),
                  ] else if (isStudioMode && visibleFiles.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_stories_rounded,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recent Notebooks',
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
                        notes: visibleFiles,
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
                      minimum: const EdgeInsets.only(bottom: 70),
                      sliver: MasonryFiles(
                        crossAxisCount: crossAxisCount,
                        files: visibleFiles,
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
          : FloatingSelectionDock(
              selectedFiles: selectedFiles.value,
              unselectNotes: () => selectedFiles.value = [],
            ),
    );
  }
}
