/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:collapsible/collapsible.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/home/delete_note_button.dart';
import 'package:saber/components/home/export_note_button.dart';
import 'package:saber/components/home/move_note_button.dart';
import 'package:saber/components/home/rename_note_button.dart';

/// Floating multi-select action pill displayed at the bottom of Recent and
/// Browse pages whenever one or more notebooks are selected.
class FloatingSelectionDock extends StatelessWidget {
  const FloatingSelectionDock({
    super.key,
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
                    .withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(OpennoteTokens.radiusPill),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: OpennoteTokens.floatingShadow(colorScheme.brightness),
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
