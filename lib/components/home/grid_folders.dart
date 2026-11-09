/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path/path.dart' as p;
import 'package:saber/components/home/delete_folder_button.dart';
import 'package:saber/components/home/new_folder_dialog.dart';
import 'package:saber/components/home/rename_folder_button.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/data/extensions/list_extensions.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/file_manager/item_drag_state.dart';
import 'package:saber/i18n/strings.g.dart';

class GridFolders extends StatelessWidget {
  const GridFolders({
    super.key,
    required this.isAtRoot,
    required this.onTap,
    required this.crossAxisCount,
    required this.createFolder,
    required this.renameFolder,
    required this.isFolderEmpty,
    required this.deleteFolder,
    required this.doesFolderExist,
    required this.folders,
    this.currentPath,
    this.onItemMoved,
  });

  final bool isAtRoot;
  final Function(String) onTap;
  final int crossAxisCount;

  final void Function(String) createFolder;
  final bool Function(String) doesFolderExist;
  final Future<void> Function(String oldName, String newName) renameFolder;
  final Future<bool> Function(String) isFolderEmpty;
  final Future<void> Function(String) deleteFolder;

  final List<String> folders;
  final String? currentPath;
  final void Function(String itemPath, String targetFolderPath)? onItemMoved;

  @override
  Widget build(BuildContext context) {
    /// The cards that come before the actual folders
    final extraCards = <_FolderCardType>[
      if (!isAtRoot) .backFolder,
      .newFolder,
    ];

    return SliverPadding(
      padding: const .symmetric(horizontal: 12, vertical: 8),
      sliver: SliverAlignedGrid.count(
        itemCount: folders.length + extraCards.length,
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemBuilder: (context, index) {
          final cardType = extraCards.getOrNull(index) ?? .realFolder;
          final folderName = cardType == .realFolder
              ? folders[index - extraCards.length]
              : null;
          return _GridFolder(
            cardType: cardType,
            folderName: folderName,
            createFolder: createFolder,
            doesFolderExist: doesFolderExist,
            renameFolder: renameFolder,
            isFolderEmpty: isFolderEmpty,
            deleteFolder: deleteFolder,
            onTap: onTap,
            currentPath: currentPath,
            onItemMoved: onItemMoved,
          );
        },
      ),
    );
  }
}

class _GridFolder extends StatefulWidget {
  const _GridFolder({
    // ignore: unused_element_parameter
    super.key,
    required this.cardType,
    required this.folderName,
    required this.createFolder,
    required this.doesFolderExist,
    required this.renameFolder,
    required this.isFolderEmpty,
    required this.deleteFolder,
    required this.onTap,
    this.currentPath,
    this.onItemMoved,
  }) : assert(
         (folderName == null) ^ (cardType == .realFolder),
         'Real folders must specify a folder name',
       );

  final _FolderCardType cardType;
  final String? folderName;
  final void Function(String) createFolder;
  final bool Function(String) doesFolderExist;
  final Future<void> Function(String oldName, String newName) renameFolder;
  final Future<bool> Function(String) isFolderEmpty;
  final Future<void> Function(String) deleteFolder;
  final Function(String) onTap;
  final String? currentPath;
  final void Function(String itemPath, String targetFolderPath)? onItemMoved;

  @override
  State<_GridFolder> createState() => _GridFolderState();
}

class _GridFolderState extends State<_GridFolder> {
  ValueNotifier<bool> expanded = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final cardElevatedColor = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.06),
      colorScheme.surface,
    );
    final isDesktop = switch (Theme.of(context).platform) {
      TargetPlatform.windows ||
      TargetPlatform.macOS ||
      TargetPlatform.linux => true,
      _ => false,
    };

    final String currentDir = widget.currentPath ?? '/';
    final String targetFolderPath =
        widget.cardType == _FolderCardType.realFolder
        ? (currentDir == '/' || currentDir.isEmpty
              ? '/${widget.folderName!}'
              : '$currentDir/${widget.folderName!}')
        : (currentDir == '/' || currentDir.isEmpty
              ? '/'
              : (p.dirname(currentDir).isEmpty ? '/' : p.dirname(currentDir)));

    Widget buildFolderCard(bool isTargeted) {
      return Card(
        elevation: isTargeted ? 2 : 0,
        color: isTargeted
            ? colorScheme.primaryContainer.withValues(alpha: 0.35)
            : colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: const .all(.circular(14)),
          side: BorderSide(
            color: isTargeted
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.45),
            width: isTargeted ? 2.0 : 1.0,
          ),
        ),
        child: Padding(
          padding: const .symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisSize: .min,
            children: [
              SizedBox(
                width: double.infinity,
                child: Stack(
                  children: [
                    Center(
                      child: Tooltip(
                        message: switch (widget.cardType) {
                          .backFolder => t.home.backFolder,
                          .newFolder => t.home.newFolder.newFolder,
                          .realFolder => '',
                        },
                        child: AdaptiveIcon(
                          icon: switch (widget.cardType) {
                            .backFolder => Icons.folder_open,
                            .newFolder => Icons.create_new_folder,
                            .realFolder => Icons.folder,
                          },
                          cupertinoIcon: switch (widget.cardType) {
                            .backFolder => CupertinoIcons.folder_open,
                            .newFolder => CupertinoIcons.folder_fill_badge_plus,
                            .realFolder => CupertinoIcons.folder_fill,
                          },
                          size: 46,
                        ),
                      ),
                    ),
                    if (widget.cardType == .realFolder)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: expanded,
                          builder: (context, isExpanded, _) => IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: isExpanded
                                ? t.common.cancel
                                : t.home.tabs.settings,
                            icon: Icon(
                              isExpanded
                                  ? Icons.close_rounded
                                  : Icons.more_vert_rounded,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () => expanded.value = !expanded.value,
                          ),
                        ),
                      ),
                    if (widget.cardType == .realFolder)
                      Positioned.fill(
                        child: ValueListenableBuilder(
                          valueListenable: expanded,
                          builder: (context, expanded, child) =>
                              AnimatedOpacity(
                                opacity: expanded ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: IgnorePointer(
                                  ignoring: !expanded,
                                  child: child!,
                                ),
                              ),
                          child: GestureDetector(
                            onTap: () => expanded.value = !expanded.value,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: const .all(.circular(10)),
                                gradient: LinearGradient(
                                  begin: .topCenter,
                                  end: .bottomCenter,
                                  colors: [
                                    cardElevatedColor.withValues(alpha: 0.3),
                                    cardElevatedColor.withValues(alpha: 0.9),
                                    cardElevatedColor.withValues(alpha: 1),
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: .center,
                                crossAxisAlignment: .end,
                                children: [
                                  RenameFolderButton(
                                    folderName: widget.folderName!,
                                    doesFolderExist: widget.doesFolderExist,
                                    renameFolder: (String folderName) async {
                                      await widget.renameFolder(
                                        widget.folderName!,
                                        folderName,
                                      );
                                      expanded.value = false;
                                    },
                                  ),
                                  DeleteFolderButton(
                                    folderName: widget.folderName!,
                                    deleteFolder: (String folderName) async {
                                      await widget.deleteFolder(folderName);
                                      expanded.value = false;
                                    },
                                    isFolderEmpty: widget.isFolderEmpty,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              switch (widget.cardType) {
                .backFolder => const Icon(Icons.arrow_back, size: 20),
                .newFolder => Text(
                  t.home.newFolder.newFolder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                .realFolder => Text(
                  widget.folderName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              },
            ],
          ),
        ),
      );
    }

    final feedbackWidget = Material(
      elevation: 6,
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.95),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_rounded, size: 28, color: colorScheme.primary),
            const SizedBox(width: 10),
            Text(
              widget.folderName ?? '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );

    Widget wrapWithDraggable(Widget cardContent) {
      if (widget.cardType != _FolderCardType.realFolder) return cardContent;
      if (expanded.value) return cardContent;

      if (isDesktop) {
        return Draggable<String>(
          data: targetFolderPath,
          onDragStarted: () => ItemDragState.startDrag(targetFolderPath),
          onDragEnd: (_) => ItemDragState.endDrag(),
          onDraggableCanceled: (_, _) => ItemDragState.endDrag(),
          onDragCompleted: () => ItemDragState.endDrag(),
          feedback: feedbackWidget,
          childWhenDragging: Opacity(opacity: 0.4, child: cardContent),
          child: cardContent,
        );
      } else {
        return LongPressDraggable<String>(
          delay: const Duration(milliseconds: 200),
          data: targetFolderPath,
          onDragStarted: () => ItemDragState.startDrag(targetFolderPath),
          onDragEnd: (_) => ItemDragState.endDrag(),
          onDraggableCanceled: (_, _) => ItemDragState.endDrag(),
          onDragCompleted: () => ItemDragState.endDrag(),
          feedback: feedbackWidget,
          childWhenDragging: Opacity(opacity: 0.4, child: cardContent),
          child: cardContent,
        );
      }
    }

    Widget buildClickableCard(bool isTargeted) {
      final cardWidget = buildFolderCard(isTargeted);
      final draggable = wrapWithDraggable(cardWidget);

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (expanded.value) return;
            switch (widget.cardType) {
              case .newFolder:
                showDialog(
                  context: context,
                  builder: (context) => NewFolderDialog(
                    createFolder: widget.createFolder,
                    doesFolderExist: widget.doesFolderExist,
                  ),
                );
              case .backFolder:
                widget.onTap('..');
              case .realFolder:
                widget.onTap(widget.folderName!);
            }
          },
          onLongPress: widget.cardType == .realFolder
              ? () => expanded.value = !expanded.value
              : null,
          onSecondaryTap: widget.cardType == .realFolder
              ? () => expanded.value = !expanded.value
              : null,
          child: draggable,
        ),
      );
    }

    if (widget.cardType == _FolderCardType.realFolder ||
        widget.cardType == _FolderCardType.backFolder) {
      return DragTarget<String>(
        onWillAcceptWithDetails: (details) {
          final sourcePath = details.data;
          // Cannot drop onto itself
          if (sourcePath == targetFolderPath) return false;
          // Cannot drop a folder into its descendant
          if (targetFolderPath.startsWith('$sourcePath/')) return false;
          // Cannot drop into current parent folder (item already here)
          final sourceParent = sourcePath.substring(
            0,
            sourcePath.lastIndexOf('/'),
          );
          final normalizedSourceParent = sourceParent.isEmpty
              ? '/'
              : sourceParent;
          if (targetFolderPath == normalizedSourceParent) return false;
          return true;
        },
        onAcceptWithDetails: (details) async {
          final sourcePath = details.data;
          final itemName = sourcePath.substring(
            sourcePath.lastIndexOf('/') + 1,
          );
          final targetName = targetFolderPath == '/'
              ? 'root'
              : targetFolderPath.substring(
                  targetFolderPath.lastIndexOf('/') + 1,
                );

          await FileManager.moveItem(sourcePath, targetFolderPath);
          widget.onItemMoved?.call(sourcePath, targetFolderPath);

          if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Moved $itemName to $targetName'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isTargeted = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              boxShadow: isTargeted
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: buildClickableCard(isTargeted),
          );
        },
      );
    }

    return buildClickableCard(false);
  }
}

enum _FolderCardType { backFolder, newFolder, realFolder }
