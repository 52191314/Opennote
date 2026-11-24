/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/opennote/toolbar_primitives.dart';
import 'package:saber/i18n/strings.g.dart';

/// Contextual Tier 2 sub-bar for the Study Tape active-recall tool.
class OpennoteStudyTapeSubBar extends StatelessWidget {
  const OpennoteStudyTapeSubBar({
    super.key,
    required this.actions,
    required this.onShowTapeOptions,
  });

  final EditorToolbarActions actions;
  final VoidCallback onShowTapeOptions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionChip(
          visualDensity: VisualDensity.standard,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          avatar: const Icon(Icons.visibility_off_rounded, size: 14),
          label: Text(
            t.editor.tape.concealAll,
            style: const TextStyle(fontSize: 11),
          ),
          onPressed: actions.onConcealAllTape,
        ),
        const SizedBox(width: 6),
        ActionChip(
          visualDensity: VisualDensity.standard,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          avatar: const Icon(Icons.visibility_rounded, size: 14),
          label: Text(
            t.editor.tape.revealAll,
            style: const TextStyle(fontSize: 11),
          ),
          onPressed: actions.onRevealAllTape,
        ),
        ToolbarGroupDivider(colorScheme: colorScheme),
        ActionChip(
          visualDensity: VisualDensity.standard,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          avatar: const Icon(Icons.palette_outlined, size: 14),
          label: Text(
            t.editor.tape.patterns,
            style: const TextStyle(fontSize: 11),
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            onShowTapeOptions();
          },
        ),
      ],
    );
  }
}
