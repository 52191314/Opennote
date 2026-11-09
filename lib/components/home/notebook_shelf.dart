/// 🤖 Generated wholely or partially with Google Antigravity
/// 🤖 Generated wholely or partially with Grok 4.7
library;

import 'package:flutter/material.dart';
import 'package:saber/components/home/delete_folder_button.dart';
import 'package:saber/components/home/delete_note_button.dart';
import 'package:saber/components/home/rename_folder_button.dart';
import 'package:saber/components/home/rename_note_button.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/file_manager/item_drag_state.dart';
import 'package:saber/i18n/strings.g.dart';

/// Notebooks as covers on a shelf.
///
/// Tapping a cover calls [onOpenNote]. Tapping a folder calls [onOpenFolder].
/// Creating a notebook calls [onCreateNote] with its path so the shelf can
/// show it.
class NotebookShelf extends StatelessWidget {
  const NotebookShelf({
    super.key,
    required this.notes,
    required this.folders,
    required this.onOpenNote,
    required this.onOpenFolder,
    required this.onCreateNote,
    this.directory,
    this.onMoveItem,
    this.onDeleteNote,
    this.onRenameNote,
    this.onDeleteFolder,
    this.onRenameFolder,
    this.doesFolderExist,
    this.isFolderEmpty,
  });

  /// Note paths to show as covers.
  final List<String> notes;

  /// Folder names in the current directory.
  final List<String> folders;

  /// Directory the new notebook is created in. Null means the library root.
  final String? directory;

  final ValueChanged<String> onOpenNote;
  final ValueChanged<String> onOpenFolder;

  /// Called with the path of a notebook the user just created.
  final ValueChanged<String> onCreateNote;

  /// Called when an item is dropped and moved into a folder on the shelf.
  final void Function(String itemPath, String targetFolderPath)? onMoveItem;

  /// Called when a notebook is deleted from the shelf.
  final void Function(String notePath)? onDeleteNote;

  /// Called when a notebook is renamed.
  final void Function(String oldPath, String newName)? onRenameNote;

  /// Called when a folder is deleted from the shelf.
  final void Function(String folderName)? onDeleteFolder;

  /// Called when a folder is renamed.
  final void Function(String oldName, String newName)? onRenameFolder;

  /// Check whether a folder name already exists.
  final bool Function(String folderName)? doesFolderExist;

  /// Check whether a folder is empty before deletion.
  final Future<bool> Function(String folderName)? isFolderEmpty;

  static const _coverColors = <Color>[
    Color(0xFF2B4C7E), // Royal Moleskine Navy
    Color(0xFF2E6F56), // Forest Sage
    Color(0xFF8C3A3A), // Wine Burgundy
    Color(0xFF7A4F82), // Plum Moleskine
    Color(0xFF8D5B2C), // Saddle Leather
    Color(0xFF37474F), // Slate Charcoal
    Color(0xFF1B6B76), // Deep Teal
  ];

  String pathFor(String name) {
    final dir = directory;
    if (dir == null || dir.isEmpty || dir == '/') return '/$name';
    return '$dir/$name';
  }

  Future<void> _create(BuildContext context) async {
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => const _NewNotebookDialog(),
    );
    if (chosen == null || chosen.isEmpty) return;
    onCreateNote(pathFor(chosen));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (folders.isNotEmpty) ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final folder in folders)
                  DragTarget<String>(
                    onWillAcceptWithDetails: (details) {
                      final sourcePath = details.data;
                      final targetFolderPath = pathFor(folder);
                      if (sourcePath == targetFolderPath) return false;
                      if (targetFolderPath.startsWith('$sourcePath/')) {
                        return false;
                      }
                      final sourceParent = sourcePath.substring(
                        0,
                        sourcePath.lastIndexOf('/'),
                      );
                      final normalizedParent = sourceParent.isEmpty
                          ? '/'
                          : sourceParent;
                      if (targetFolderPath == normalizedParent) {
                        return false;
                      }
                      return true;
                    },
                    onAcceptWithDetails: (details) async {
                      final sourcePath = details.data;
                      final targetFolderPath = pathFor(folder);
                      final itemName = sourcePath.substring(
                        sourcePath.lastIndexOf('/') + 1,
                      );

                      await FileManager.moveItem(sourcePath, targetFolderPath);
                      onMoveItem?.call(sourcePath, targetFolderPath);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Moved $itemName to $folder'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isHovered = candidateData.isNotEmpty;
                      return ActionChip(
                        key: ValueKey('shelf-folder-$folder'),
                        avatar: Icon(
                          Icons.folder_rounded,
                          size: 18,
                          color: scheme.primary,
                        ),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              folder,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              iconSize: 15,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.more_vert_rounded,
                                size: 15,
                                color: scheme.onSurfaceVariant,
                              ),
                              onSelected: (value) async {
                                if (value == 'open') {
                                  onOpenFolder(folder);
                                } else if (value == 'rename') {
                                  await RenameFolderButton.showRenameDialog(
                                    context,
                                    folderName: folder,
                                    doesFolderExist:
                                        doesFolderExist ?? (_) => false,
                                    renameFolder: (newName) async {
                                      onRenameFolder?.call(folder, newName);
                                    },
                                  );
                                } else if (value == 'delete') {
                                  await DeleteFolderButton.showDeleteDialog(
                                    context,
                                    folderName: folder,
                                    deleteFolder: (name) async {
                                      onDeleteFolder?.call(name);
                                    },
                                    isFolderEmpty:
                                        isFolderEmpty ?? (_) async => true,
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'open',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.folder_open_rounded,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(t.home.tabs.browse),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit_square, size: 18),
                                      const SizedBox(width: 10),
                                      Text(t.home.renameFolder.renameFolder),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_forever_rounded,
                                        size: 18,
                                        color: scheme.error,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        t.home.deleteFolder.deleteFolder,
                                        style: TextStyle(color: scheme.error),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        backgroundColor: isHovered
                            ? scheme.primary.withValues(alpha: 0.2)
                            : scheme.secondaryContainer.withValues(alpha: 0.65),
                        side: BorderSide(
                          color: isHovered
                              ? scheme.primary
                              : scheme.outlineVariant.withValues(alpha: 0.5),
                          width: isHovered ? 1.5 : 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () => onOpenFolder(folder),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Wrap(
            spacing: 18,
            runSpacing: 22,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              for (final note in notes)
                _NotebookCover(
                  key: ValueKey('shelf-cover-$note'),
                  filePath: note,
                  title: _title(note),
                  color:
                      _coverColors[note.hashCode.abs() % _coverColors.length],
                  onTap: () => onOpenNote(note),
                  onDelete: () => onDeleteNote?.call(note),
                  onRename: () => onRenameNote?.call(note, note),
                ),
              _NewNotebook(onTap: () => _create(context)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 12,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.surfaceContainerHigh,
                  scheme.surfaceContainerHighest,
                ],
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.7),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _title(String path) {
    final slash = path.lastIndexOf('/');
    if (slash == -1 || slash == path.length - 1) return path;
    return path.substring(slash + 1);
  }
}

class _NotebookCover extends StatelessWidget {
  const _NotebookCover({
    super.key,
    required this.filePath,
    required this.title,
    required this.color,
    required this.onTap,
    this.onDelete,
    this.onRename,
  });

  final String filePath;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRename;

  static const _bookRadius = BorderRadius.only(
    topLeft: Radius.circular(4),
    bottomLeft: Radius.circular(4),
    topRight: Radius.circular(10),
    bottomRight: Radius.circular(10),
  );

  Widget _buildCoverContent(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;

    return SizedBox(
      width: 104,
      height: 138,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: _bookRadius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x38000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 3,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Left spine crease gradient
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0x42000000),
                      Color(0x1F000000),
                      Color(0x28FFFFFF),
                    ],
                  ),
                ),
              ),
            ),
            // Subtle right page-edge highlight
            const Positioned(
              right: 0,
              top: 3,
              bottom: 3,
              width: 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x26FFFFFF),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
            // Refined paper title label card
            Center(
              child: Container(
                margin: const EdgeInsets.fromLTRB(18, 16, 10, 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFFDCD6CA),
                    width: 0.8,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 4,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2416),
                    height: 1.2,
                  ),
                ),
              ),
            ),
            // Top-right 3-dots action menu button
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.transparent,
                child: PopupMenuButton<String>(
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 140),
                  icon: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  onSelected: (value) async {
                    if (value == 'open') {
                      onTap();
                    } else if (value == 'rename') {
                      await RenameNoteButton.showRenameDialog(
                        context,
                        existingPath: filePath,
                        onRenamed: onRename,
                      );
                    } else if (value == 'delete') {
                      await DeleteNoteButton.showDeleteDialog(
                        context,
                        filesToDelete: [filePath],
                        onDeleted: onDelete,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'open',
                      child: Row(
                        children: [
                          const Icon(Icons.launch_rounded, size: 18),
                          const SizedBox(width: 10),
                          Text(t.home.tabs.home),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_square, size: 18),
                          const SizedBox(width: 10),
                          Text(t.home.renameNote.renameNote),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_forever_rounded,
                            size: 18,
                            color: errorColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            t.home.deleteNote,
                            style: TextStyle(color: errorColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookWidget = InkWell(
      onTap: onTap,
      borderRadius: _bookRadius,
      child: _buildCoverContent(context),
    );

    final feedbackWidget = Material(
      color: Colors.transparent,
      elevation: 8,
      borderRadius: _bookRadius,
      child: Transform.scale(scale: 0.9, child: _buildCoverContent(context)),
    );

    return LongPressDraggable<String>(
      data: filePath,
      delay: const Duration(milliseconds: 200),
      onDragStarted: () => ItemDragState.startDrag(filePath),
      onDragEnd: (_) => ItemDragState.endDrag(),
      onDraggableCanceled: (_, _) => ItemDragState.endDrag(),
      onDragCompleted: () => ItemDragState.endDrag(),
      feedback: feedbackWidget,
      childWhenDragging: Opacity(opacity: 0.4, child: bookWidget),
      child: bookWidget,
    );
  }
}

class _NewNotebookDialog extends StatefulWidget {
  const _NewNotebookDialog();

  @override
  State<_NewNotebookDialog> createState() => _NewNotebookDialogState();
}

class _NewNotebookDialogState extends State<_NewNotebookDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _name.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.home.shelf.newNotebook),
      content: TextField(
        key: const ValueKey('shelf-notebook-name'),
        controller: _name,
        autofocus: true,
        decoration: InputDecoration(hintText: t.home.shelf.notebookName),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.common.cancel),
        ),
        TextButton(
          key: const ValueKey('shelf-create-confirm'),
          onPressed: _submit,
          child: Text(t.home.newFolder.create),
        ),
      ],
    );
  }
}

class _NewNotebook extends StatelessWidget {
  const _NewNotebook({required this.onTap});

  final VoidCallback onTap;

  static const _bookRadius = BorderRadius.only(
    topLeft: Radius.circular(4),
    bottomLeft: Radius.circular(4),
    topRight: Radius.circular(10),
    bottomRight: Radius.circular(10),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return InkWell(
      key: const ValueKey('shelf-new-notebook'),
      onTap: onTap,
      borderRadius: _bookRadius,
      child: SizedBox(
        width: 104,
        height: 138,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow.withValues(alpha: 0.7),
            borderRadius: _bookRadius,
            border: Border.all(color: scheme.outlineVariant, width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, color: scheme.primary, size: 20),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  t.home.shelf.newNotebook,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
