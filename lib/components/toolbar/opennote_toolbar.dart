/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Modified with Grok 4.7
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/opennote/contextual_sub_bar.dart';
import 'package:saber/components/toolbar/opennote/primary_tool_dock.dart';
import 'package:saber/components/toolbar/widgets/toolbar_dialogs.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/i18n/strings.g.dart';

/// A comprehensive Opennote Studio Dual-Tier Writing Toolbar.
///
/// **Tier 1 (Primary Studio Tool Dock)**:
/// - Floating studio dock with subtle hairline border and logical tool grouping.
/// - Active tool receives a refined halo highlight with contrasting icon.
/// - Tapping an already active tool re-opens that tool's dedicated options modal.
///
/// **Tier 2 (Contextual Studio Sub-Bar)**:
/// - Dynamically updates directly below Tier 1 for Pen, Eraser, Lasso,
///   Study Tape, Drafting/Shapes, and Rich Text editing.
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

  void _showPenSettings(Tool Function() getTool) {
    ToolbarDialogs.showPenSettings(
      context,
      actions: widget.actions,
      getTool: getTool,
      onChanged: _refresh,
      icon: Icons.edit_note_rounded,
      iconSize: 22,
      title: t.editor.tools.penOptions,
    );
  }

  void _showEraserSettings() {
    ToolbarDialogs.showEraserSettings(context, onClearPage: widget.onClearPage);
  }

  void _showDraftingTools() {
    ToolbarDialogs.showDraftingTools(
      context,
      actions: widget.actions,
      onChanged: _refresh,
    );
  }

  void _showLassoOptions() {
    ToolbarDialogs.showLassoOptions(context);
  }

  void _showTapeOptions() {
    ToolbarDialogs.showTapeOptions(
      context,
      actions: widget.actions,
      onChanged: _refresh,
    );
  }

  void _toggleColorOptions() {
    ToolbarDialogs.showColorOptions(
      context,
      actions: widget.actions,
      popOnSelect: false,
      onChanged: _refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.brightnessOf(context);
    final invert =
        stows.editorAutoInvert.value && brightness == Brightness.dark;
    final currentColor = ToolbarDialogs.currentColorFor(
      widget.actions.currentTool,
    );

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
                currentColor: currentColor,
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
