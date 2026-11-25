/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/theming/dynamic_material_app.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/widgets/toolbar_contextual_bars.dart';
import 'package:saber/components/toolbar/widgets/toolbar_dialogs.dart';
import 'package:saber/components/toolbar/widgets/toolbar_keybindings.dart';
import 'package:saber/components/toolbar/widgets/toolbar_tool_strip.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/eraser.dart';

/// Classic editor toolbar supporting top, bottom, left, and right docking.
class Toolbar extends StatefulWidget {
  const Toolbar({
    super.key,
    required this.actions,
    required this.undo,
    required this.isUndoPossible,
    required this.redo,
    required this.isRedoPossible,
    required this.toggleFingerDrawing,
    required this.exportAsSba,
    required this.exportAsPdf,
    required this.exportAsPng,
  });

  /// The editor state to show and the actions the tools trigger.
  final EditorToolbarActions actions;

  final VoidCallback undo;
  final bool isUndoPossible;
  final VoidCallback redo;
  final bool isRedoPossible;

  final VoidCallback toggleFingerDrawing;

  final Future Function(BuildContext)? exportAsSba;
  final Future Function(BuildContext)? exportAsPdf;
  final Future Function(BuildContext)? exportAsPng;

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  late final ToolbarKeybindings _keybindings;

  @override
  void initState() {
    super.initState();
    _keybindings = ToolbarKeybindings(
      onToggleFingerDrawing: widget.toggleFingerDrawing,
      onToggleEraser: toggleEraser,
      onToggleColorOptions: toggleColorOptions,
      onToggleExportBar: toggleExportBar,
      onToggleFullscreen: toggleFullscreen,
      onPaste: widget.actions.paste,
    )..register();
    DynamicMaterialApp.addFullscreenListener(_setState);
  }

  void _setState() => setState(() {});

  void toggleEraser() {
    widget.actions.setTool(Eraser(size: stows.eraserSize.value));
  }

  void toggleColorOptions() {
    ToolbarDialogs.showColorOptions(
      context,
      actions: widget.actions,
      popOnSelect: true,
    );
  }

  void toggleExportBar() {
    ToolbarDialogs.showExportBar(
      context,
      exportAsSba: widget.exportAsSba,
      exportAsPdf: widget.exportAsPdf,
      exportAsPng: widget.exportAsPng,
    );
  }

  void toggleFullscreen() {
    DynamicMaterialApp.setFullscreen(
      !DynamicMaterialApp.isFullscreen,
      updateSystem: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.brightnessOf(context);
    final invert =
        stows.editorAutoInvert.value && brightness == Brightness.dark;

    final isToolbarVertical =
        stows.editorToolbarAlignment.value == AxisDirection.left ||
        stows.editorToolbarAlignment.value == AxisDirection.right;

    final bars = <Widget>[
      ToolbarQuillBar(actions: widget.actions, isVertical: isToolbarVertical),
      ToolbarSelectionBar(
        actions: widget.actions,
        isVertical: isToolbarVertical,
      ),
      ToolbarToolStrip(
        actions: widget.actions,
        isVertical: isToolbarVertical,
        invert: invert,
        undo: widget.undo,
        isUndoPossible: widget.isUndoPossible,
        redo: widget.redo,
        isRedoPossible: widget.isRedoPossible,
        toggleFingerDrawing: widget.toggleFingerDrawing,
        onToggleEraser: toggleEraser,
        onToggleColorOptions: toggleColorOptions,
        onToggleFullscreen: toggleFullscreen,
        onStateChanged: _setState,
      ),
    ];

    return Flex(
      direction: isToolbarVertical ? Axis.horizontal : Axis.vertical,
      textDirection: switch (stows.editorToolbarAlignment.value) {
        AxisDirection.left => TextDirection.rtl,
        AxisDirection.right => TextDirection.ltr,
        _ => null,
      },
      verticalDirection: switch (stows.editorToolbarAlignment.value) {
        AxisDirection.down => VerticalDirection.down,
        AxisDirection.up => VerticalDirection.up,
        _ => VerticalDirection.down,
      },
      children: bars,
    );
  }

  @override
  void dispose() {
    DynamicMaterialApp.removeFullscreenListener(_setState);
    DynamicMaterialApp.setFullscreen(false, updateSystem: true);
    _keybindings.dispose();
    super.dispose();
  }
}

enum ToolOptions { hide, pen, highlighter, pencil, select }
