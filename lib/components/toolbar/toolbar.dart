/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
library;

import 'dart:io';

import 'package:collapsible/collapsible.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keybinder/keybinder.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/components/theming/dynamic_material_app.dart';
import 'package:saber/components/theming/uni_icon.dart';
import 'package:saber/components/toolbar/color_bar.dart';
import 'package:saber/components/toolbar/drafting_tools_popup.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/eraser_size_popup.dart';
import 'package:saber/components/toolbar/export_bar.dart';
import 'package:saber/components/toolbar/lasso_filter_popup.dart';
import 'package:saber/components/toolbar/pen_modal.dart';
import 'package:saber/components/toolbar/quick_palette_bar.dart';
import 'package:saber/components/toolbar/selection_bar.dart';
import 'package:saber/components/toolbar/tape_options_popup.dart';
import 'package:saber/components/toolbar/toolbar_button.dart';
import 'package:saber/components/toolbar/toolbar_dialog.dart';
import 'package:saber/data/extensions/color_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/arrow.dart';
import 'package:saber/data/tools/dimension.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/laser_pointer.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/study_tape.dart';
import 'package:saber/i18n/strings.g.dart';

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

  static const _buttonPaddingHorizontal = EdgeInsets.symmetric(horizontal: 6);
  static const _buttonPaddingVertical = EdgeInsets.symmetric(vertical: 6);
}

class _ToolbarState extends State<Toolbar> {
  @override
  void initState() {
    _assignKeybindings();

    DynamicMaterialApp.addFullscreenListener(_setState);

    super.initState();
  }

  void _setState() => setState(() {});

  Keybinding? _ctrlF;
  Keybinding? _ctrlE;
  Keybinding? _ctrlC;
  Keybinding? _ctrlShiftS;
  Keybinding? _f11;
  Keybinding? _ctrlV;
  void _assignKeybindings() {
    _ctrlF = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyF),
    ], inclusive: true);
    _ctrlE = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyE),
    ], inclusive: true);
    _ctrlC = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyC),
    ], inclusive: true);
    _ctrlShiftS = Keybinding([
      KeyCode.ctrl,
      KeyCode.shift,
      KeyCode.from(LogicalKeyboardKey.keyS),
    ], inclusive: true);
    _f11 = Keybinding([KeyCode.from(LogicalKeyboardKey.f11)], inclusive: true);
    _ctrlV = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyV),
    ], inclusive: true);

    Keybinder.bind(_ctrlF!, widget.toggleFingerDrawing);
    Keybinder.bind(_ctrlE!, toggleEraser);
    Keybinder.bind(_ctrlC!, toggleColorOptions);
    Keybinder.bind(_ctrlShiftS!, toggleExportBar);
    Keybinder.bind(_f11!, toggleFullscreen);
    Keybinder.bind(_ctrlV!, widget.actions.paste);
  }

  void _removeKeybindings() {
    if (_ctrlF != null) Keybinder.remove(_ctrlF!);
    if (_ctrlE != null) Keybinder.remove(_ctrlE!);
    if (_ctrlC != null) Keybinder.remove(_ctrlC!);
    if (_ctrlShiftS != null) Keybinder.remove(_ctrlShiftS!);
    if (_f11 != null) Keybinder.remove(_f11!);
    if (_ctrlV != null) Keybinder.remove(_ctrlV!);
  }

  void toggleEraser() {
    widget.actions.setTool(
      Eraser(size: stows.eraserSize.value),
    ); // this toggles eraser
  }

  void toggleColorOptions() {
    final brightness = Theme.brightnessOf(context);
    final invert = stows.editorAutoInvert.value && brightness == .dark;

    final currentColor = switch (widget.actions.currentTool) {
      final Pen pen => pen.color,
      final Select select => select.getDominantStrokeColor(),
      _ => null,
    };

    showDialog(
      context: context,
      builder: (context) => ToolbarDialog(
        icon: Icons.palette_outlined,
        title: t.editor.toolbar.toggleColors,
        maxWidth: 420,
        child: ColorBar(
          axis: Axis.horizontal,
          setColor: (color) {
            widget.actions.setColor(color);
            Navigator.of(context).pop();
          },
          currentColor: currentColor,
          invert: invert,
        ),
      ),
    );
  }

  void toggleExportBar() {
    showDialog(
      context: context,
      builder: (context) => ToolbarDialog(
        icon: Icons.ios_share,
        title: t.editor.toolbar.export,
        titleSize: 17,
        verticalPadding: 20,
        child: ExportBar(
          axis: Axis.horizontal,
          toggleExportBar: () => Navigator.of(context).pop(),
          exportAsSba: widget.exportAsSba,
          exportAsPdf: widget.exportAsPdf,
          exportAsPng: widget.exportAsPng,
        ),
      ),
    );
  }

  void _showPenSettings(Pen Function() getTool) {
    showDialog(
      context: context,
      builder: (_) => ToolbarDialog(
        icon: Icons.tune_rounded,
        title: t.editor.tools.penSettings,
        child: PenModal(
          getTool: getTool,
          setTool: (pen) {
            widget.actions.setTool(pen);
            setState(() {});
          },
        ),
      ),
    );
  }

  void _showDraftingTools() {
    showDialog(
      context: context,
      builder: (context) => DraftingToolsPopup(
        currentTool: widget.actions.currentTool,
        onSelectTool: (tool) {
          widget.actions.setTool(tool);
          setState(() {});
        },
        onPickShape: widget.actions.pickShape,
      ),
    );
  }

  void toggleFullscreen() async {
    DynamicMaterialApp.setFullscreen(
      !DynamicMaterialApp.isFullscreen,
      updateSystem: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    final brightness = Theme.brightnessOf(context);
    final invert = stows.editorAutoInvert.value && brightness == .dark;

    final isToolbarVertical =
        stows.editorToolbarAlignment.value == AxisDirection.left ||
        stows.editorToolbarAlignment.value == AxisDirection.right;

    final buttonPadding = isToolbarVertical
        ? Toolbar._buttonPaddingVertical
        : Toolbar._buttonPaddingHorizontal;

    final currentColor = switch (widget.actions.currentTool) {
      final Pen pen => pen.color,
      final Select select => select.getDominantStrokeColor(),
      _ => null,
    };

    final bars = <Widget>[
      ValueListenableBuilder(
        valueListenable: widget.actions.quillFocus,
        builder: (context, quill, _) {
          final baseButtonStyle =
              IconButtonTheme.of(context).style ?? const ButtonStyle();

          final iconTheme = QuillIconTheme(
            iconButtonUnselectedData: IconButtonData(
              style: baseButtonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                foregroundColor: WidgetStateProperty.all(colorScheme.primary),
              ),
            ),
            iconButtonSelectedData: IconButtonData(
              style: baseButtonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(colorScheme.primary),
                foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
              ),
            ),
          );
          return Collapsible(
            axis: isToolbarVertical
                ? CollapsibleAxis.horizontal
                : CollapsibleAxis.vertical,
            maintainState: false,
            collapsed: !widget.actions.textEditing || quill == null,
            child: quill != null
                ? QuillSimpleToolbar(
                    controller: quill.controller,
                    config: QuillSimpleToolbarConfig(
                      axis: isToolbarVertical ? Axis.vertical : Axis.horizontal,
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                        base: QuillToolbarBaseButtonOptions(
                          iconTheme: iconTheme,
                        ),
                      ),
                      multiRowsDisplay: !Platform.isAndroid && !Platform.isIOS,
                      showUndo: false,
                      showRedo: false,
                      showFontSize: false,
                      showFontFamily: false,
                      showClearFormat: false,
                    ),
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
      Collapsible(
        axis: isToolbarVertical
            ? CollapsibleAxis.horizontal
            : CollapsibleAxis.vertical,
        maintainState: false,
        collapsed: widget.actions.currentTool is! Select,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: 0.75,
            ),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: SelectionBar(
            copySelection: widget.actions.copySelection,
            pasteSelection: widget.actions.pasteSelection,
            duplicateSelection: widget.actions.duplicateSelection,
            deleteSelection: widget.actions.deleteSelection,
            cropPossible: widget.actions.cropPossible,
            cropActive: widget.actions.cropActive,
            toggleCrop: widget.actions.toggleCrop,
            bringToFront: widget.actions.bringToFront,
            sendToBack: widget.actions.sendToBack,
            smoothen: widget.actions.smoothen,
            addToElements: widget.actions.addToElements,
          ),
        ),
      ),
      DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.95),
          border: Border(
            top: isToolbarVertical
                ? BorderSide.none
                : BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    width: 0.75,
                  ),
            bottom: isToolbarVertical
                ? BorderSide.none
                : BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    width: 0.75,
                  ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Wrap(
            direction: isToolbarVertical ? Axis.vertical : Axis.horizontal,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            runSpacing: 4,
            children: [
              // 1. Pen
              ToolbarIconButton(
                tooltip: Pen.currentPen.name,
                selected: Pen.isWritingPen(widget.actions.currentTool),
                enabled: !widget.actions.readOnly,
                onPressed: () {
                  if (Pen.isWritingPen(widget.actions.currentTool)) {
                    _showPenSettings(() => Pen.currentPen);
                  } else {
                    widget.actions.setTool(Pen.currentPen);
                  }
                },
                onLongPress: () => _showPenSettings(() => Pen.currentPen),
                padding: buttonPadding,
                child: UniIcon(Pen.currentPen.icon, size: 16),
              ),

              // 2. Pencil
              ToolbarIconButton(
                tooltip: t.editor.pens.pencil,
                selected: widget.actions.currentTool == Pencil.currentPencil,
                enabled: !widget.actions.readOnly,
                onPressed: () {
                  if (widget.actions.currentTool == Pencil.currentPencil) {
                    _showPenSettings(() => Pencil.currentPencil);
                  } else {
                    widget.actions.setTool(Pencil.currentPencil);
                  }
                },
                onLongPress: () => _showPenSettings(() => Pencil.currentPencil),
                padding: buttonPadding,
                child: const FaIcon(Pencil.pencilIcon, size: 16),
              ),

              // 3. Highlighter
              ToolbarIconButton(
                tooltip: t.editor.pens.highlighter,
                selected:
                    widget.actions.currentTool ==
                    Highlighter.currentHighlighter,
                enabled: !widget.actions.readOnly,
                onPressed: () {
                  if (widget.actions.currentTool ==
                      Highlighter.currentHighlighter) {
                    _showPenSettings(() => Highlighter.currentHighlighter);
                  } else {
                    widget.actions.setTool(Highlighter.currentHighlighter);
                  }
                },
                onLongPress: () =>
                    _showPenSettings(() => Highlighter.currentHighlighter),
                padding: buttonPadding,
                child: const FaIcon(Highlighter.highlighterIcon, size: 16),
              ),

              // 4. Eraser
              ToolbarIconButton(
                tooltip: t.editor.toolbar.toggleEraser,
                selected: widget.actions.currentTool is Eraser,
                enabled: !widget.actions.readOnly,
                onPressed: () {
                  if (widget.actions.currentTool is Eraser) {
                    showDialog(
                      context: context,
                      builder: (_) => const EraserSizePopup(),
                    );
                  } else {
                    toggleEraser();
                  }
                },
                onLongPress: () => showDialog(
                  context: context,
                  builder: (_) => const EraserSizePopup(),
                ),
                padding: buttonPadding,
                child: const FaIcon(FontAwesomeIcons.eraser, size: 16),
              ),

              // 5. Drafting & Shapes (Shapes, Ruler, Arrow, Dimension)
              ToolbarIconButton(
                tooltip: t.editor.drafting.titleAlt,
                selected:
                    widget.actions.currentTool is Ruler ||
                    widget.actions.currentTool is ArrowTool ||
                    widget.actions.currentTool is DimensionTool,
                enabled: !widget.actions.readOnly,
                onPressed: _showDraftingTools,
                onLongPress: _showDraftingTools,
                padding: buttonPadding,
                child: const FaIcon(FontAwesomeIcons.shapes, size: 16),
              ),

              // 6. Lasso
              ToolbarIconButton(
                tooltip: t.editor.toolbar.select,
                selected: widget.actions.currentTool is Select,
                enabled: !widget.actions.readOnly,
                onPressed: () {
                  if (widget.actions.currentTool is Select) {
                    showDialog(
                      context: context,
                      builder: (_) => const LassoFilterPopup(),
                    );
                  } else {
                    widget.actions.setTool(Select.currentSelect);
                  }
                },
                onLongPress: () => showDialog(
                  context: context,
                  builder: (_) => const LassoFilterPopup(),
                ),
                padding: buttonPadding,
                child: const Icon(CupertinoIcons.lasso),
              ),

              // 7. Study Tape
              ToolbarIconButton(
                tooltip: t.editor.tape.tooltip,
                selected: widget.actions.currentTool is StudyTapeTool,
                enabled: !widget.actions.readOnly,
                onPressed: () {
                  if (widget.actions.currentTool is StudyTapeTool) {
                    showDialog(
                      context: context,
                      builder: (_) => TapeOptionsPopup(
                        currentTapeTool:
                            widget.actions.currentTool as StudyTapeTool,
                        onRevealAll: widget.actions.onRevealAllTape,
                        onConcealAll: widget.actions.onConcealAllTape,
                        onTapeChanged: () => setState(() {}),
                      ),
                    );
                  } else {
                    widget.actions.setTool(StudyTapeTool());
                  }
                },
                onLongPress: () {
                  final tool = widget.actions.currentTool is StudyTapeTool
                      ? widget.actions.currentTool as StudyTapeTool
                      : StudyTapeTool();
                  if (widget.actions.currentTool is! StudyTapeTool) {
                    widget.actions.setTool(tool);
                  }
                  showDialog(
                    context: context,
                    builder: (_) => TapeOptionsPopup(
                      currentTapeTool: tool,
                      onRevealAll: widget.actions.onRevealAllTape,
                      onConcealAll: widget.actions.onConcealAllTape,
                      onTapeChanged: () => setState(() {}),
                    ),
                  );
                },
                padding: buttonPadding,
                child: const Icon(Icons.view_headline_rounded, size: 16),
              ),

              // 8. Elements (Stickers)
              ToolbarIconButton(
                tooltip: t.editor.elements.tooltip,
                selected: false,
                enabled: !widget.actions.readOnly,
                onPressed: () => widget.actions.openElementsSheet?.call(),
                padding: buttonPadding,
                child: const Icon(Icons.auto_awesome, size: 16),
              ),

              // 9. Photo
              ToolbarIconButton(
                tooltip: t.editor.toolbar.photo,
                enabled: !widget.actions.readOnly,
                onPressed: widget.actions.pickPhoto,
                padding: buttonPadding,
                child: const AdaptiveIcon(
                  icon: Icons.photo,
                  cupertinoIcon: CupertinoIcons.photo,
                ),
              ),

              // 10. Text Box
              ToolbarIconButton(
                tooltip: t.editor.toolbar.text,
                selected: widget.actions.textEditing,
                enabled: !widget.actions.readOnly,
                onPressed: widget.actions.toggleTextEditing,
                padding: buttonPadding,
                child: const AdaptiveIcon(
                  icon: Icons.text_fields,
                  cupertinoIcon: CupertinoIcons.text_cursor,
                ),
              ),

              // 11. Laser Pointer (Trail / Spotlight mode toggle)
              ToolbarIconButton(
                tooltip: stows.laserPointerMode.value == 'spotlight'
                    ? t.editor.tools.laserSpotlight
                    : t.editor.pens.laserPointer,
                selected:
                    widget.actions.currentTool ==
                    LaserPointer.currentLaserPointer,
                enabled: true,
                onPressed: () {
                  if (widget.actions.currentTool ==
                      LaserPointer.currentLaserPointer) {
                    stows.laserPointerMode.value =
                        stows.laserPointerMode.value == 'spotlight'
                        ? 'trail'
                        : 'spotlight';
                    setState(() {});
                  } else {
                    widget.actions.setTool(LaserPointer.currentLaserPointer);
                  }
                },
                onLongPress: () {
                  stows.laserPointerMode.value =
                      stows.laserPointerMode.value == 'spotlight'
                      ? 'trail'
                      : 'spotlight';
                  setState(() {});
                },
                padding: buttonPadding,
                child: Icon(
                  stows.laserPointerMode.value == 'spotlight'
                      ? Icons.adjust_rounded
                      : Symbols.stylus_laser_pointer,
                  size: 16,
                ),
              ),

              // Contextual Quick Palette (3 Quick Colors + 3 Quick Sizes)
              if (widget.actions.currentTool is Pen ||
                  widget.actions.currentTool is Select)
                Padding(
                  padding: isToolbarVertical
                      ? const EdgeInsets.symmetric(vertical: 2)
                      : const EdgeInsets.symmetric(horizontal: 4),
                  child: QuickPaletteBar(
                    axis: isToolbarVertical ? Axis.vertical : Axis.horizontal,
                    currentTool: widget.actions.currentTool,
                    setColor: widget.actions.setColor,
                    onUpdate: () => setState(() {}),
                    invert: invert,
                  ),
                ),

              // Full Color Palette Icon
              ToolbarIconButton(
                tooltip: t.editor.toolbar.toggleColors,
                selected: false,
                enabled: !widget.actions.readOnly,
                onPressed: toggleColorOptions,
                padding: buttonPadding,
                child: currentColor == null
                    ? const Icon(Icons.palette_outlined, size: 18)
                    : Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: currentColor
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

              // Finger Drawing Toggle
              if (!stows.hideFingerDrawingToggle.value)
                ValueListenableBuilder(
                  valueListenable: stows.editorFingerDrawing,
                  builder: (context, value, child) {
                    return ToolbarIconButton(
                      tooltip: t.editor.toolbar.toggleFingerDrawing,
                      selected: value,
                      enabled: !widget.actions.readOnly,
                      onPressed: widget.toggleFingerDrawing,
                      padding: buttonPadding,
                      child: const Icon(CupertinoIcons.hand_draw),
                    );
                  },
                ),

              // Fullscreen Toggle
              ToolbarIconButton(
                tooltip: t.editor.toolbar.fullscreen,
                selected: DynamicMaterialApp.isFullscreen,
                enabled: !widget.actions.readOnly,
                onPressed: toggleFullscreen,
                padding: buttonPadding,
                child: AdaptiveIcon(
                  icon: DynamicMaterialApp.isFullscreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  cupertinoIcon: DynamicMaterialApp.isFullscreen
                      ? CupertinoIcons.fullscreen_exit
                      : CupertinoIcons.fullscreen,
                ),
              ),

              // Undo/Redo fallback when vertical
              if (isToolbarVertical) ...[
                ToolbarIconButton(
                  tooltip: t.editor.toolbar.undo,
                  enabled: !widget.actions.readOnly && widget.isUndoPossible,
                  onPressed: widget.undo,
                  padding: buttonPadding,
                  child: const AdaptiveIcon(
                    icon: Icons.undo,
                    cupertinoIcon: CupertinoIcons.arrow_uturn_left,
                  ),
                ),
                ToolbarIconButton(
                  tooltip: t.editor.toolbar.redo,
                  enabled: !widget.actions.readOnly && widget.isRedoPossible,
                  onPressed: widget.redo,
                  padding: buttonPadding,
                  child: const AdaptiveIcon(
                    icon: Icons.redo,
                    cupertinoIcon: CupertinoIcons.arrow_uturn_right,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ];

    return Flex(
      direction: isToolbarVertical ? Axis.horizontal : Axis.vertical,
      textDirection: switch (stows.editorToolbarAlignment.value) {
        AxisDirection.left => .rtl,
        AxisDirection.right => .ltr,
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

    _removeKeybindings();
    super.dispose();
  }
}

enum ToolOptions { hide, pen, highlighter, pencil, select }
