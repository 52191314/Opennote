/// 🤖 Generated wholely or partially with Google Antigravity
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/opennote/toolbar_primitives.dart';
import 'package:saber/components/toolbar/pen_tray_bar.dart';
import 'package:saber/components/toolbar/quick_palette_bar.dart';
import 'package:saber/data/extensions/color_extensions.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/i18n/strings.g.dart';

/// Contextual Tier 2 sub-bar for Pen, Pencil, and Highlighter tools.
class OpennotePenSubBar extends StatelessWidget {
  const OpennotePenSubBar({
    super.key,
    required this.actions,
    required this.currentColor,
    required this.invert,
    required this.onToggleColorOptions,
    required this.onStateChanged,
  });

  final EditorToolbarActions actions;
  final Color? currentColor;
  final bool invert;
  final VoidCallback onToggleColorOptions;
  final VoidCallback onStateChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (Pen.isWritingPen(actions.currentTool)) ...[
          PenTrayBar(
            pen: actions.currentTool as Pen,
            onSelected: onStateChanged,
          ),
          ToolbarGroupDivider(colorScheme: colorScheme),
        ],
        QuickPaletteBar(
          axis: Axis.horizontal,
          currentTool: actions.currentTool,
          setColor: actions.setColor,
          onUpdate: onStateChanged,
          invert: invert,
        ),
        ToolbarGroupDivider(colorScheme: colorScheme),
        Tooltip(
          message: t.editor.toolbar.toggleColors,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              HapticFeedback.selectionClick();
              onToggleColorOptions();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                  width: 0.75,
                ),
              ),
              child: currentColor == null
                  ? const Icon(Icons.palette_outlined, size: 18)
                  : Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: currentColor!
                            .withInversion(invert)
                            .withValues(alpha: 1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
