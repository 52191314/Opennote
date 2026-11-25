/// 🤖 Generated wholely or partially with Google Antigravity
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/opennote/toolbar_primitives.dart';
import 'package:saber/data/tools/arrow.dart';
import 'package:saber/data/tools/dimension.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:saber/i18n/strings.g.dart';

/// Contextual Tier 2 sub-bar for Shapes & Drafting tools.
class OpennoteDraftingSubBar extends StatelessWidget {
  const OpennoteDraftingSubBar({super.key, required this.actions});

  final EditorToolbarActions actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isRuler = actions.currentTool is Ruler;
    final isArrow = actions.currentTool is ArrowTool;
    final isDimension = actions.currentTool is DimensionTool;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionChip(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          avatar: const Icon(Icons.category_rounded, size: 14),
          label: Text(
            t.editor.drafting.shapeLibrary,
            style: const TextStyle(fontSize: 11),
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            actions.pickShape();
          },
        ),
        ToolbarGroupDivider(colorScheme: colorScheme),
        ChoiceChip(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          showCheckmark: false,
          avatar: const Icon(Icons.straighten_rounded, size: 14),
          label: Text(
            t.editor.pens.ruler,
            style: const TextStyle(fontSize: 11),
          ),
          selected: isRuler,
          onSelected: (_) {
            HapticFeedback.selectionClick();
            actions.setTool(Ruler());
          },
        ),
        const SizedBox(width: 5),
        ChoiceChip(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          showCheckmark: false,
          avatar: const Icon(Icons.arrow_right_alt_rounded, size: 14),
          label: Text(
            t.editor.drafting.arrow,
            style: const TextStyle(fontSize: 11),
          ),
          selected: isArrow,
          onSelected: (_) {
            HapticFeedback.selectionClick();
            actions.setTool(ArrowTool());
          },
        ),
        const SizedBox(width: 5),
        ChoiceChip(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          showCheckmark: false,
          avatar: const Icon(Icons.architecture_rounded, size: 14),
          label: Text(
            t.editor.drafting.dimension,
            style: const TextStyle(fontSize: 11),
          ),
          selected: isDimension,
          onSelected: (_) {
            HapticFeedback.selectionClick();
            actions.setTool(DimensionTool());
          },
        ),
      ],
    );
  }
}
