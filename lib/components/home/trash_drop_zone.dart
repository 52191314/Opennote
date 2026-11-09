/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/home/delete_folder_button.dart';
import 'package:saber/components/home/delete_note_button.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/file_manager/item_drag_state.dart';
import 'package:saber/i18n/strings.g.dart';

/// Floating drag-and-drop target for deleting notebooks and folders.
///
/// Automatically animates into view whenever [ItemDragState.isDragging] is true.
/// Dropping an item onto this zone prompts confirmation and deletes the item.
class TrashDropZone extends StatelessWidget {
  const TrashDropZone({super.key, this.onItemDeleted});

  /// Called after a note or folder is successfully deleted.
  final void Function(String itemPath)? onItemDeleted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return ValueListenableBuilder<String?>(
      valueListenable: ItemDragState.activeDragItem,
      builder: (context, activeItem, _) {
        final isDragging = activeItem != null;

        return AnimatedSlide(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          offset: isDragging ? Offset.zero : const Offset(0, 1.5),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isDragging ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !isDragging,
              child: DragTarget<String>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) async {
                  final itemPath = details.data;
                  ItemDragState.endDrag();

                  if (!context.mounted) return;

                  if (FileManager.isDirectory(itemPath)) {
                    final folderName = itemPath.substring(
                      itemPath.lastIndexOf('/') + 1,
                    );
                    await DeleteFolderButton.showDeleteDialog(
                      context,
                      folderName: folderName,
                      deleteFolder: (name) async {
                        await FileManager.deleteDirectory(itemPath);
                        onItemDeleted?.call(itemPath);
                      },
                      isFolderEmpty: (name) async {
                        final children =
                            await FileManager.getChildrenOfDirectory(itemPath);
                        return children?.isEmpty ?? true;
                      },
                    );
                  } else {
                    await DeleteNoteButton.showDeleteDialog(
                      context,
                      filesToDelete: [itemPath],
                      onDeleted: () => onItemDeleted?.call(itemPath),
                    );
                  }
                },
                builder: (context, candidateData, rejectedData) {
                  final isHovered = candidateData.isNotEmpty;

                  return Material(
                    elevation: isHovered ? 12 : 6,
                    borderRadius: BorderRadius.circular(30),
                    color: isHovered
                        ? colorScheme.errorContainer
                        : colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.95,
                          ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isHovered
                              ? colorScheme.error
                              : colorScheme.error.withValues(alpha: 0.4),
                          width: isHovered ? 2.2 : 1.2,
                        ),
                        boxShadow: isHovered
                            ? [
                                BoxShadow(
                                  color: colorScheme.error.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            duration: const Duration(milliseconds: 180),
                            scale: isHovered ? 1.2 : 1.0,
                            child: Icon(
                              isHovered
                                  ? Icons.delete_forever_rounded
                                  : Icons.delete_outline_rounded,
                              color: colorScheme.error,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isHovered
                                ? t.home.deleteNoteDialog.delete.toUpperCase()
                                : t.home.deleteNote,
                            style: TextStyle(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
