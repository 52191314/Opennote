/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Modified with Grok 4.7
library;

import 'package:flutter/material.dart';
import 'package:saber/components/toolbar/color_bar.dart';
import 'package:saber/components/toolbar/drafting_tools_popup.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/eraser_size_popup.dart';
import 'package:saber/components/toolbar/lasso_filter_popup.dart';
import 'package:saber/components/toolbar/opennote/contextual_sub_bar.dart';
import 'package:saber/components/toolbar/opennote/primary_tool_dock.dart';
import 'package:saber/components/toolbar/pen_modal.dart';
import 'package:saber/components/toolbar/tape_options_popup.dart';
import 'package:saber/components/toolbar/toolbar_dialog.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/study_tape.dart';
import 'package:saber/i18n/strings.g.dart';

/// A comprehensive Opennote Studio Dual-Tier Writing Toolbar.
///
/// **Tier 1 (Primary Studio Tool Dock)**:
/// - Floating studio dock with subtle inner border and visual grouping:
///   - Writing tools: Fountain/Ballpoint Pen, Pencil, Highlighter
///   - Editing & Selection tools: Eraser, Shapes & Drafting, Lasso
///   - Insert & Utility tools: Elements, Media/Photo, Text Box, Study Tape, Laser Pointer, Zoom Window
/// - Active tool receives a prominent studio pill container highlight with contrasting icon.
/// - Tapping an already active tool re-opens that tool's dedicated options modal.
///
/// **Tier 2 (Contextual Studio Sub-Bar)**:
/// - Dynamically updates directly below Tier 1:
///   - Pen / Highlighter / Pencil: Pen Tray presets, 3 Quick Colors + Full Palette Wheel, and 3 Quick Thicknesses.
///   - Eraser: 3 Quick Sizes, Clear Page, and Highlighter-Only / Object-Mode toggles.
///   - Lasso: Filter chips (Handwriting, Images, Text, Tape) + contextual selection actions.
///   - Study Tape: Conceal All, Reveal All, and pattern styles.
///   - Shapes: Shape presets and drafting shortcuts.
///   - Text: Rich text formatting controls.
class OpennoteToolbar extends StatefulWidget {
  const OpennoteToolbar({
    super.key,
    required this.actions,
    this.onClearPage,
    this.zoomWindowOpen = false,
    this.onToggleZoomWindow,
  });

  /// The editor state to show and the actions the tools trigger.
  final EditorToolbarActions actions;

  /// Clears the current page, if the editor allows it.
  final VoidCallback? onClearPage;

  /// Whether the zoom window is open.
  final bool zoomWindowOpen;

  /// Opens or dismisses the zoom window.
  final VoidCallback? onToggleZoomWindow;

  @override
  State<OpennoteToolbar> createState() => _OpennoteToolbarState();
}

class _OpennoteToolbarState extends State<OpennoteToolbar> {
  void _refresh() => setState(() {});

  Color? get _currentColor => switch (widget.actions.currentTool) {
    final Pen pen => pen.color,
    final Select select => select.getDominantStrokeColor(),
    _ => null,
  };

  void _showPenSettings(Tool Function() getTool) {
    showDialog(
      context: context,
      builder: (_) => ToolbarDialog(
        icon: Icons.edit_note_rounded,
        iconSize: 22,
        title: t.editor.tools.penOptions,
        child: PenModal(
          getTool: getTool,
          setTool: (pen) {
            widget.actions.setTool(pen);
            _refresh();
          },
        ),
      ),
    );
  }

  void _showEraserSettings() {
    showDialog(
      context: context,
      builder: (_) => EraserSizePopup(onClearPage: widget.onClearPage),
    );
  }

  void _showDraftingTools() {
    showDialog(
      context: context,
      builder: (context) => DraftingToolsPopup(
        currentTool: widget.actions.currentTool,
        onSelectTool: (tool) {
          widget.actions.setTool(tool);
          _refresh();
        },
        onPickShape: widget.actions.pickShape,
      ),
    );
  }

  void _showLassoOptions() {
    showDialog(context: context, builder: (_) => const LassoFilterPopup());
  }

  void _showTapeOptions() {
    final tool = widget.actions.currentTool is StudyTapeTool
        ? widget.actions.currentTool as StudyTapeTool
        : StudyTapeTool.currentStudyTape;
    if (widget.actions.currentTool is! StudyTapeTool) {
      widget.actions.setTool(tool);
    }
    showDialog(
      context: context,
      builder: (_) => TapeOptionsPopup(
        currentTapeTool: tool,
        onRevealAll: widget.actions.onRevealAllTape,
        onConcealAll: widget.actions.onConcealAllTape,
        onTapeChanged: _refresh,
      ),
    );
  }

  void _toggleColorOptions() {
    final brightness = Theme.brightnessOf(context);
    final invert =
        stows.editorAutoInvert.value && brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => ToolbarDialog(
        icon: Icons.palette_outlined,
        title: t.editor.toolbar.toggleColors,
        maxWidth: 420,
        child: ColorBar(
          axis: Axis.horizontal,
          currentColor: _currentColor,
          setColor: (color) {
            widget.actions.setColor(color);
            _refresh();
          },
          invert: invert,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.brightnessOf(context);
    final invert =
        stows.editorAutoInvert.value && brightness == Brightness.dark;

    return RepaintBoundary(
      child: ValueListenableBuilder<AxisDirection>(
        valueListenable: stows.editorToolbarAlignment,
        builder: (context, alignment, child) => SafeArea(
          top: alignment != AxisDirection.down,
          bottom: alignment != AxisDirection.up,
          left: alignment != AxisDirection.right,
          right: alignment != AxisDirection.left,
          child: child!,
        ),
        child: ColoredBox(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OpennotePrimaryToolDock(
                actions: widget.actions,
                zoomWindowOpen: widget.zoomWindowOpen,
                onToggleZoomWindow: widget.onToggleZoomWindow,
                onShowPenSettings: _showPenSettings,
                onShowEraserSettings: _showEraserSettings,
                onShowDraftingTools: _showDraftingTools,
                onShowLassoOptions: _showLassoOptions,
                onShowTapeOptions: _showTapeOptions,
                onStateChanged: _refresh,
              ),
              OpennoteContextualSubBar(
                actions: widget.actions,
                currentColor: _currentColor,
                invert: invert,
                onClearPage: widget.onClearPage,
                onShowLassoOptions: _showLassoOptions,
                onShowTapeOptions: _showTapeOptions,
                onToggleColorOptions: _toggleColorOptions,
                onStateChanged: _refresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
