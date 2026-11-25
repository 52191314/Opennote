/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/toolbar/color_bar.dart';
import 'package:saber/components/toolbar/drafting_tools_popup.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/eraser_size_popup.dart';
import 'package:saber/components/toolbar/export_bar.dart';
import 'package:saber/components/toolbar/lasso_filter_popup.dart';
import 'package:saber/components/toolbar/pen_modal.dart';
import 'package:saber/components/toolbar/tape_options_popup.dart';
import 'package:saber/components/toolbar/toolbar_dialog.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/study_tape.dart';
import 'package:saber/i18n/strings.g.dart';

/// Shared modal dialog launchers for [Toolbar] and [OpennoteToolbar].
abstract final class ToolbarDialogs {
  /// Returns the currently active ink or selection color, if any.
  static Color? currentColorFor(Tool currentTool) => switch (currentTool) {
    final Pen pen => pen.color,
    final Select select => select.getDominantStrokeColor(),
    _ => null,
  };

  static void showColorOptions(
    BuildContext context, {
    required EditorToolbarActions actions,
    bool popOnSelect = true,
    VoidCallback? onChanged,
  }) {
    final brightness = Theme.brightnessOf(context);
    final invert =
        stows.editorAutoInvert.value && brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => ToolbarDialog(
        icon: Icons.palette_outlined,
        title: t.editor.toolbar.toggleColors,
        maxWidth: 420,
        child: ColorBar(
          axis: Axis.horizontal,
          setColor: (color) {
            actions.setColor(color);
            onChanged?.call();
            if (popOnSelect) Navigator.of(dialogContext).pop();
          },
          currentColor: currentColorFor(actions.currentTool),
          invert: invert,
        ),
      ),
    );
  }

  static void showExportBar(
    BuildContext context, {
    required Future Function(BuildContext)? exportAsSba,
    required Future Function(BuildContext)? exportAsPdf,
    required Future Function(BuildContext)? exportAsPng,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => ToolbarDialog(
        icon: Icons.ios_share,
        title: t.editor.toolbar.export,
        titleSize: 17,
        verticalPadding: 20,
        child: ExportBar(
          axis: Axis.horizontal,
          toggleExportBar: () => Navigator.of(dialogContext).pop(),
          exportAsSba: exportAsSba,
          exportAsPdf: exportAsPdf,
          exportAsPng: exportAsPng,
        ),
      ),
    );
  }

  static void showPenSettings(
    BuildContext context, {
    required EditorToolbarActions actions,
    required Tool Function() getTool,
    required VoidCallback onChanged,
    IconData icon = Icons.tune_rounded,
    double iconSize = 20,
    String? title,
  }) {
    showDialog(
      context: context,
      builder: (_) => ToolbarDialog(
        icon: icon,
        iconSize: iconSize,
        title: title ?? t.editor.tools.penSettings,
        child: PenModal(
          getTool: getTool,
          setTool: (pen) {
            actions.setTool(pen);
            onChanged();
          },
        ),
      ),
    );
  }

  static void showDraftingTools(
    BuildContext context, {
    required EditorToolbarActions actions,
    required VoidCallback onChanged,
  }) {
    showDialog(
      context: context,
      builder: (_) => DraftingToolsPopup(
        currentTool: actions.currentTool,
        onSelectTool: (tool) {
          actions.setTool(tool);
          onChanged();
        },
        onPickShape: actions.pickShape,
      ),
    );
  }

  static void showEraserSettings(
    BuildContext context, {
    VoidCallback? onClearPage,
  }) {
    showDialog(
      context: context,
      builder: (_) => EraserSizePopup(onClearPage: onClearPage),
    );
  }

  static void showLassoOptions(BuildContext context) {
    showDialog(context: context, builder: (_) => const LassoFilterPopup());
  }

  /// Opens [TapeOptionsPopup] while strictly preserving the
  /// [StudyTapeTool.currentStudyTape] singleton instance.
  static void showTapeOptions(
    BuildContext context, {
    required EditorToolbarActions actions,
    required VoidCallback onChanged,
  }) {
    final tool = actions.currentTool is StudyTapeTool
        ? actions.currentTool as StudyTapeTool
        : StudyTapeTool.currentStudyTape;
    if (actions.currentTool is! StudyTapeTool) {
      actions.setTool(tool);
    }
    showDialog(
      context: context,
      builder: (_) => TapeOptionsPopup(
        currentTapeTool: tool,
        onRevealAll: actions.onRevealAllTape,
        onConcealAll: actions.onConcealAllTape,
        onTapeChanged: onChanged,
      ),
    );
  }
}
