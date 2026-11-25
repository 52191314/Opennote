/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/editor/page_grid/page_grid_empty_state.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/i18n/strings.g.dart';

/// A heading entry extracted from document text for the outline view.
class OutlineHeadingEntry {
  /// Creates an [OutlineHeadingEntry].
  const OutlineHeadingEntry({
    required this.pageIndex,
    required this.level,
    required this.text,
  });

  /// Zero-based page index where the heading appears.
  final int pageIndex;

  /// Heading level (1 through 6).
  final int level;

  /// Trimmed text content of the heading.
  final String text;
}

/// Extracts all Quill document headings across [pages].
List<OutlineHeadingEntry> extractDocumentHeadings(List<EditorPage> pages) {
  final headings = <OutlineHeadingEntry>[];
  for (int i = 0; i < pages.length; i++) {
    final delta = pages[i].quill.controller.document.toDelta();
    final lineBuffer = StringBuffer();
    for (final op in delta.toList()) {
      if (!op.isInsert || op.data is! String) continue;
      final data = op.data as String;
      final attributes = op.attributes;
      final inlineLevel = attributes?['heading'] ?? attributes?['header'];

      if (data == '\n') {
        final lineText = lineBuffer.toString().trim();
        lineBuffer.clear();
        if (inlineLevel is int && lineText.isNotEmpty) {
          headings.add(
            OutlineHeadingEntry(
              pageIndex: i,
              level: inlineLevel,
              text: lineText,
            ),
          );
        }
        continue;
      }

      if (inlineLevel is int) {
        final trimmed = data.trim();
        if (trimmed.isNotEmpty) {
          headings.add(
            OutlineHeadingEntry(
              pageIndex: i,
              level: inlineLevel,
              text: trimmed,
            ),
          );
        }
        lineBuffer.clear();
        continue;
      }

      final parts = data.split('\n');
      if (parts.length > 1) {
        lineBuffer
          ..clear()
          ..write(parts.last);
      } else {
        lineBuffer.write(data);
      }
    }
  }
  return headings;
}

/// Displays a scrollable document outline built from page headings.
class PageOutlineView extends StatelessWidget {
  /// Creates a [PageOutlineView].
  const PageOutlineView({
    super.key,
    required this.pages,
    required this.onJumpToPage,
  });

  /// Pages to scan for headings.
  final List<EditorPage> pages;

  /// Called when the user selects a heading to navigate to its page.
  final ValueChanged<int> onJumpToPage;

  @override
  Widget build(BuildContext context) {
    final headings = extractDocumentHeadings(pages);
    if (headings.isEmpty) {
      return PageGridEmptyState(
        icon: Icons.format_list_bulleted,
        title: t.editor.outline.noHeadingsInDocument,
        subtitle: t.editor.outline.howTo,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      itemCount: headings.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 48,
        color: colorScheme.outlineVariant.withValues(alpha: 0.35),
      ),
      itemBuilder: (context, index) => _OutlineRow(
        entry: headings[index],
        onTap: () => onJumpToPage(headings[index].pageIndex),
      ),
    );
  }
}

class _OutlineRow extends StatelessWidget {
  const _OutlineRow({required this.entry, required this.onTap});

  final OutlineHeadingEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final clampedLevel = entry.level.clamp(1, 6);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '${entry.pageIndex + 1}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
            SizedBox(width: 12 + (clampedLevel - 1) * 14.0),
            Expanded(
              child: Text(
                entry.text,
                style: TextStyle(
                  fontSize: 15.0 - (clampedLevel - 1) * 1.0,
                  fontWeight: clampedLevel <= 2
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
