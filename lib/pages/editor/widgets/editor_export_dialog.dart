/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/toolbar/export_bar.dart';
import 'package:saber/i18n/strings.g.dart';

/// Modal dialog presenting export actions (SBA, PDF, PNG) in a crisp surface card.
class EditorExportDialog extends StatelessWidget {
  /// Creates an [EditorExportDialog].
  const EditorExportDialog({
    super.key,
    required this.exportAsSba,
    required this.exportAsPdf,
    required this.exportAsPng,
  });

  /// Exports the note as a Saber/Opennote archive (`.sba`), or `null` if unavailable.
  final Future<void> Function(BuildContext)? exportAsSba;

  /// Exports the note as a PDF document, or `null` if unavailable.
  final Future<void> Function(BuildContext)? exportAsPdf;

  /// Exports the note as PNG images, or `null` if unavailable.
  final Future<void> Function(BuildContext)? exportAsPng;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 14, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.ios_share,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.editor.toolbar.export,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ExportBar(
              axis: Axis.horizontal,
              toggleExportBar: () => Navigator.of(context).pop(),
              exportAsSba: exportAsSba,
              exportAsPdf: exportAsPdf,
              exportAsPng: exportAsPng,
            ),
          ],
        ),
      ),
    );
  }
}
