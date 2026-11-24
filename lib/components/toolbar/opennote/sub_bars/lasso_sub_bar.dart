/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/opennote/toolbar_primitives.dart';
import 'package:saber/components/toolbar/selection_bar.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/i18n/strings.g.dart';

/// Contextual Tier 2 sub-bar for the Lasso (Select) tool.
class OpennoteLassoSubBar extends StatelessWidget {
  const OpennoteLassoSubBar({
    super.key,
    required this.actions,
    required this.onShowLassoOptions,
    required this.onStateChanged,
  });

  final EditorToolbarActions actions;
  final VoidCallback onShowLassoOptions;
  final VoidCallback onStateChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilterChip(
          visualDensity: VisualDensity.compact,
          label: Text(
            t.editor.lasso.handwriting,
            style: const TextStyle(fontSize: 11),
          ),
          selected: stows.lassoSelectHandwriting.value,
          onSelected: (val) {
            stows.lassoSelectHandwriting.value = val;
            onStateChanged();
          },
        ),
        const SizedBox(width: 4),
        FilterChip(
          visualDensity: VisualDensity.compact,
          label: Text(
            t.editor.lasso.images,
            style: const TextStyle(fontSize: 11),
          ),
          selected: stows.lassoSelectImages.value,
          onSelected: (val) {
            stows.lassoSelectImages.value = val;
            onStateChanged();
          },
        ),
        const SizedBox(width: 4),
        FilterChip(
          visualDensity: VisualDensity.compact,
          label: Text(
            t.editor.lasso.textBoxes,
            style: const TextStyle(fontSize: 11),
          ),
          selected: stows.lassoSelectText.value,
          onSelected: (val) {
            stows.lassoSelectText.value = val;
            onStateChanged();
          },
        ),
        const SizedBox(width: 4),
        FilterChip(
          visualDensity: VisualDensity.compact,
          label: Text(
            t.editor.tape.short,
            style: const TextStyle(fontSize: 11),
          ),
          selected: stows.lassoSelectTape.value,
          onSelected: (val) {
            stows.lassoSelectTape.value = val;
            onStateChanged();
          },
        ),
        ToolbarGroupDivider(colorScheme: colorScheme),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.tune_rounded, size: 16),
          tooltip: t.editor.lasso.settings,
          onPressed: onShowLassoOptions,
        ),
        if (Select.currentSelect.doneSelecting &&
            Select.currentSelect.selectResult.isNotEmpty) ...[
          ToolbarGroupDivider(colorScheme: colorScheme),
          if (actions.cutSelection != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.content_cut_rounded, size: 16),
              tooltip: t.editor.actions.cut,
              onPressed: actions.cutSelection,
            ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.copy_rounded, size: 16),
            tooltip: t.editor.actions.copy,
            onPressed: actions.copySelection,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.copy_all_rounded, size: 16),
            tooltip: t.editor.selectionBar.duplicate,
            onPressed: actions.duplicateSelection,
          ),
          PopupMenuButton<Color>(
            tooltip: t.editor.lasso.color,
            icon: const Icon(Icons.palette_outlined, size: 16),
            padding: EdgeInsets.zero,
            onSelected: (color) =>
                (actions.onSetColor ?? actions.setColor)(color),
            itemBuilder: (context) => [
              for (final item in SelectionBar.quickColorOptions)
                PopupMenuItem<Color>(
                  value: item.color,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(item.name),
                    ],
                  ),
                ),
            ],
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.delete_outline_rounded, size: 16),
            tooltip: t.editor.actions.delete,
            onPressed: actions.deleteSelection,
          ),
        ],
      ],
    );
  }
}
