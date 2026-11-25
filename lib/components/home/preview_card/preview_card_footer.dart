/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/home/delete_note_button.dart';
import 'package:saber/components/home/rename_note_button.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_exporter.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/i18n/strings.g.dart';

/// Metadata footer for a notebook preview card, displaying its title, optional
/// subtitle/timestamp, and contextual action menu (Select, Rename, Export, Delete).
class PreviewCardFooter extends StatelessWidget {
  const PreviewCardFooter({
    super.key,
    required this.filePath,
    required this.displayName,
    required this.isSelected,
    required this.onToggleSelection,
    this.subtitle,
  });

  final String filePath;
  final String displayName;
  final bool isSelected;
  final VoidCallback onToggleSelection;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.26),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.15,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          PreviewCardActionMenu(
            filePath: filePath,
            isSelected: isSelected,
            onToggleSelection: onToggleSelection,
          ),
        ],
      ),
    );
  }
}

/// Overflow menu for a notebook preview card with Select, Rename, Export PDF,
/// and Delete actions.
class PreviewCardActionMenu extends StatelessWidget {
  const PreviewCardActionMenu({
    super.key,
    required this.filePath,
    required this.isSelected,
    required this.onToggleSelection,
  });

  final String filePath;
  final bool isSelected;
  final VoidCallback onToggleSelection;

  Future<void> _exportPdf(BuildContext context) async {
    final coreInfo = await EditorCoreInfo.loadFromFilePath(filePath);
    if (!context.mounted) return;
    final pdfDoc = await EditorExporter.generatePdf(coreInfo, context);
    final pdfBytes = await pdfDoc.save();
    if (!context.mounted) return;
    final fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
    await FileManager.exportFile('$fileName.pdf', pdfBytes, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<String>(
        iconSize: 18,
        padding: EdgeInsets.zero,
        tooltip: 'Notebook options',
        constraints: const BoxConstraints(minWidth: 156),
        icon: Icon(
          Icons.more_vert_rounded,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        onSelected: (value) async {
          switch (value) {
            case 'select':
              onToggleSelection();
            case 'rename':
              await RenameNoteButton.showRenameDialog(
                context,
                existingPath: filePath,
              );
            case 'export_pdf':
              await _exportPdf(context);
            case 'delete':
              await DeleteNoteButton.showDeleteDialog(
                context,
                filesToDelete: [filePath],
              );
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'select',
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(isSelected ? 'Deselect' : 'Select'),
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
            value: 'export_pdf',
            child: Row(
              children: [
                const Icon(Icons.ios_share_rounded, size: 18),
                const SizedBox(width: 10),
                Text('${t.home.tooltips.exportNote} (PDF)'),
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
                  color: colorScheme.error,
                ),
                const SizedBox(width: 10),
                Text(
                  t.home.deleteNote,
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
