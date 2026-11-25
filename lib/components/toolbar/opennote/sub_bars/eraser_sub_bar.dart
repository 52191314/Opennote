/// 🤖 Generated wholely or partially with Google Antigravity
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saber/components/toolbar/opennote/toolbar_primitives.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

/// Contextual Tier 2 sub-bar for the Eraser tool.
class OpennoteEraserSubBar extends StatelessWidget {
  const OpennoteEraserSubBar({
    super.key,
    required this.onClearPage,
    required this.onStateChanged,
  });

  final VoidCallback? onClearPage;
  final VoidCallback onStateChanged;

  void _confirmClearPage(BuildContext context, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.editor.eraser.clearPageTitle),
        content: Text(t.editor.eraser.clearPageDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              onClearPage?.call();
            },
            child: Text(t.editor.actions.clear),
          ),
        ],
      ),
    );
  }

  void _selectEraserSize(double size) {
    HapticFeedback.selectionClick();
    stows.eraserSize.value = size;
    onStateChanged();
  }

  Widget _quickSizeTarget({required String label, required double size}) {
    void onTap() => _selectEraserSize(size);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 42, minHeight: 36),
        child: Center(
          child: EraserQuickSizeButton(
            label: label,
            size: size,
            selected: (stows.eraserSize.value - size).abs() < 5,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _quickSizeTarget(label: t.editor.tools.fine, size: 15.0),
        const SizedBox(width: 4),
        _quickSizeTarget(label: t.editor.tools.medium, size: 30.0),
        const SizedBox(width: 4),
        _quickSizeTarget(label: t.editor.tools.broad, size: 60.0),
        ToolbarGroupDivider(colorScheme: colorScheme),
        FilterChip(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          label: Text(
            t.editor.eraser.highlighterOnlyShort,
            style: const TextStyle(fontSize: 11),
          ),
          selected: stows.eraserEraseHighlighterOnly.value,
          onSelected: (val) {
            HapticFeedback.selectionClick();
            stows.eraserEraseHighlighterOnly.value = val;
            onStateChanged();
          },
        ),
        const SizedBox(width: 4),
        FilterChip(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          label: Text(
            t.editor.eraser.entireStroke,
            style: const TextStyle(fontSize: 11),
          ),
          selected: stows.eraserMode.value == 'object',
          onSelected: (val) {
            HapticFeedback.selectionClick();
            stows.eraserMode.value = val ? 'object' : 'precision';
            onStateChanged();
          },
        ),
        if (onClearPage != null) ...[
          ToolbarGroupDivider(colorScheme: colorScheme),
          ActionChip(
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            avatar: const Icon(Icons.delete_sweep_rounded, size: 14),
            label: Text(
              t.editor.eraser.clearPage,
              style: const TextStyle(fontSize: 11),
            ),
            onPressed: () => _confirmClearPage(context, colorScheme),
          ),
        ],
      ],
    );
  }
}
