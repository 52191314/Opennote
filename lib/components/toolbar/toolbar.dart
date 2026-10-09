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
import 'package:saber/components/toolbar/eraser_size_popup.dart';
import 'package:saber/components/toolbar/export_bar.dart';
import 'package:saber/components/toolbar/lasso_filter_popup.dart';
import 'package:saber/components/toolbar/pen_modal.dart';
import 'package:saber/components/toolbar/quick_palette_bar.dart';
import 'package:saber/components/toolbar/selection_bar.dart';
import 'package:saber/components/toolbar/tape_options_popup.dart';
import 'package:saber/components/toolbar/toolbar_button.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/color_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
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
    required this.readOnly,
    required this.setTool,
    required this.currentTool,
    required this.setColor,
    required this.quillFocus,
    required this.textEditing,
    required this.toggleTextEditing,
    required this.undo,
    required this.isUndoPossible,
    required this.redo,
    required this.isRedoPossible,
    required this.toggleFingerDrawing,
    required this.pickPhoto,
    required this.pickShape,
    required this.paste,
    required this.copySelection,
    required this.pasteSelection,
    required this.duplicateSelection,
    required this.deleteSelection,
    this.cropPossible = false,
    this.cropActive = false,
    this.toggleCrop,
    this.bringToFront,
    this.sendToBack,
    this.smoothen,
    this.addToElements,
    this.openElementsSheet,
    required this.exportAsSba,
    required this.exportAsPdf,
    required this.exportAsPng,
    this.onRevealAllTape,
    this.onConcealAllTape,
  });

  final bool readOnly;

  final ValueChanged<Tool> setTool;
  final Tool currentTool;
  final ValueChanged<Color> setColor;

  final ValueNotifier<QuillStruct?> quillFocus;
  final bool textEditing;
  final VoidCallback toggleTextEditing;

  final VoidCallback undo;
  final bool isUndoPossible;
  final VoidCallback redo;
  final bool isRedoPossible;

  final VoidCallback toggleFingerDrawing;

  final VoidCallback pickPhoto;

  final VoidCallback pickShape;

  final VoidCallback paste;

  final VoidCallback copySelection;
  final VoidCallback pasteSelection;

  final VoidCallback duplicateSelection;
  final VoidCallback deleteSelection;
  final bool cropPossible;
  final bool cropActive;
  final VoidCallback? toggleCrop;
  final VoidCallback? bringToFront;
  final VoidCallback? sendToBack;
  final VoidCallback? smoothen;
  final VoidCallback? addToElements;
  final VoidCallback? openElementsSheet;

  final Future Function(BuildContext)? exportAsSba;
  final Future Function(BuildContext)? exportAsPdf;
  final Future Function(BuildContext)? exportAsPng;
  final VoidCallback? onRevealAllTape;
  final VoidCallback? onConcealAllTape;

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
    Keybinder.bind(_ctrlV!, widget.paste);
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
    widget.setTool(Eraser(size: stows.eraserSize.value)); // this toggles eraser
  }

  void toggleColorOptions() {
    final colorScheme = ColorScheme.of(context);
    final brightness = Theme.brightnessOf(context);
    final invert = stows.editorAutoInvert.value && brightness == .dark;

    final currentColor = switch (widget.currentTool) {
      final Pen pen => pen.color,
      final Select select => select.getDominantStrokeColor(),
      _ => null,
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.editor.toolbar.toggleColors,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ColorBar(
                axis: Axis.horizontal,
                setColor: (color) {
                  widget.setColor(color);
                  Navigator.of(context).pop();
                },
                currentColor: currentColor,
                invert: invert,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void toggleExportBar() {
    final colorScheme = ColorScheme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.ios_share, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    t.editor.toolbar.export,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ExportBar(
                axis: Axis.horizontal,
                toggleExportBar: () => Navigator.of(context).pop(),
                exportAsSba: widget.exportAsSba,
                exportAsPdf: widget.exportAsPdf,
                exportAsPng: widget.exportAsPng,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPenSettings(Pen Function() getTool) {
    final colorScheme = ColorScheme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.editor.tools.penSettings,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PenModal(
                getTool: getTool,
                setTool: (pen) {
                  widget.setTool(pen);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDraftingTools() {
    showDialog(
      context: context,
      builder: (context) => DraftingToolsPopup(
        currentTool: widget.currentTool,
        onSelectTool: (tool) {
          widget.setTool(tool);
          setState(() {});
        },
        onPickShape: widget.pickShape,
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

    final currentColor = switch (widget.currentTool) {
      final Pen pen => pen.color,
      final Select select => select.getDominantStrokeColor(),
      _ => null,
    };

    final bars = <Widget>[
      ValueListenableBuilder(
        valueListenable: widget.quillFocus,
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
            collapsed: !widget.textEditing || quill == null,
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
        collapsed: widget.currentTool is! Select,
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
            copySelection: widget.copySelection,
            pasteSelection: widget.pasteSelection,
            duplicateSelection: widget.duplicateSelection,
            deleteSelection: widget.deleteSelection,
            cropPossible: widget.cropPossible,
            cropActive: widget.cropActive,
            toggleCrop: widget.toggleCrop,
            bringToFront: widget.bringToFront,
            sendToBack: widget.sendToBack,
            smoothen: widget.smoothen,
            addToElements: widget.addToElements,
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
                selected: Pen.isWritingPen(widget.currentTool),
                enabled: !widget.readOnly,
                onPressed: () {
                  if (Pen.isWritingPen(widget.currentTool)) {
                    _showPenSettings(() => Pen.currentPen);
                  } else {
                    widget.setTool(Pen.currentPen);
                  }
                },
                onLongPress: () => _showPenSettings(() => Pen.currentPen),
                padding: buttonPadding,
                child: UniIcon(Pen.currentPen.icon, size: 16),
              ),

              // 2. Pencil
              ToolbarIconButton(
                tooltip: t.editor.pens.pencil,
                selected: widget.currentTool == Pencil.currentPencil,
                enabled: !widget.readOnly,
                onPressed: () {
                  if (widget.currentTool == Pencil.currentPencil) {
                    _showPenSettings(() => Pencil.currentPencil);
                  } else {
                    widget.setTool(Pencil.currentPencil);
                  }
                },
                onLongPress: () => _showPenSettings(() => Pencil.currentPencil),
                padding: buttonPadding,
                child: const FaIcon(Pencil.pencilIcon, size: 16),
              ),

              // 3. Highlighter
              ToolbarIconButton(
                tooltip: t.editor.pens.highlighter,
                selected: widget.currentTool == Highlighter.currentHighlighter,
                enabled: !widget.readOnly,
                onPressed: () {
                  if (widget.currentTool == Highlighter.currentHighlighter) {
                    _showPenSettings(() => Highlighter.currentHighlighter);
                  } else {
                    widget.setTool(Highlighter.currentHighlighter);
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
                selected: widget.currentTool is Eraser,
                enabled: !widget.readOnly,
                onPressed: () {
                  if (widget.currentTool is Eraser) {
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
                    widget.currentTool is Ruler ||
                    widget.currentTool is ArrowTool ||
                    widget.currentTool is DimensionTool,
                enabled: !widget.readOnly,
                onPressed: _showDraftingTools,
                onLongPress: _showDraftingTools,
                padding: buttonPadding,
                child: const FaIcon(FontAwesomeIcons.shapes, size: 16),
              ),

              // 6. Lasso
              ToolbarIconButton(
                tooltip: t.editor.toolbar.select,
                selected: widget.currentTool is Select,
                enabled: !widget.readOnly,
                onPressed: () {
                  if (widget.currentTool is Select) {
                    showDialog(
                      context: context,
                      builder: (_) => const LassoFilterPopup(),
                    );
                  } else {
                    widget.setTool(Select.currentSelect);
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
                selected: widget.currentTool is StudyTapeTool,
                enabled: !widget.readOnly,
                onPressed: () {
                  if (widget.currentTool is StudyTapeTool) {
                    showDialog(
                      context: context,
                      builder: (_) => TapeOptionsPopup(
                        currentTapeTool: widget.currentTool as StudyTapeTool,
                        onRevealAll: widget.onRevealAllTape,
                        onConcealAll: widget.onConcealAllTape,
                        onTapeChanged: () => setState(() {}),
                      ),
                    );
                  } else {
                    widget.setTool(StudyTapeTool());
                  }
                },
                onLongPress: () {
                  final tool = widget.currentTool is StudyTapeTool
                      ? widget.currentTool as StudyTapeTool
                      : StudyTapeTool();
                  if (widget.currentTool is! StudyTapeTool) {
                    widget.setTool(tool);
                  }
                  showDialog(
                    context: context,
                    builder: (_) => TapeOptionsPopup(
                      currentTapeTool: tool,
                      onRevealAll: widget.onRevealAllTape,
                      onConcealAll: widget.onConcealAllTape,
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
                enabled: !widget.readOnly,
                onPressed: () => widget.openElementsSheet?.call(),
                padding: buttonPadding,
                child: const Icon(Icons.auto_awesome, size: 16),
              ),

              // 9. Photo
              ToolbarIconButton(
                tooltip: t.editor.toolbar.photo,
                enabled: !widget.readOnly,
                onPressed: widget.pickPhoto,
                padding: buttonPadding,
                child: const AdaptiveIcon(
                  icon: Icons.photo,
                  cupertinoIcon: CupertinoIcons.photo,
                ),
              ),

              // 10. Text Box
              ToolbarIconButton(
                tooltip: t.editor.toolbar.text,
                selected: widget.textEditing,
                enabled: !widget.readOnly,
                onPressed: widget.toggleTextEditing,
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
                    widget.currentTool == LaserPointer.currentLaserPointer,
                enabled: true,
                onPressed: () {
                  if (widget.currentTool == LaserPointer.currentLaserPointer) {
                    stows.laserPointerMode.value =
                        stows.laserPointerMode.value == 'spotlight'
                        ? 'trail'
                        : 'spotlight';
                    setState(() {});
                  } else {
                    widget.setTool(LaserPointer.currentLaserPointer);
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
              if (widget.currentTool is Pen || widget.currentTool is Select)
                Padding(
                  padding: isToolbarVertical
                      ? const EdgeInsets.symmetric(vertical: 2)
                      : const EdgeInsets.symmetric(horizontal: 4),
                  child: QuickPaletteBar(
                    axis: isToolbarVertical ? Axis.vertical : Axis.horizontal,
                    currentTool: widget.currentTool,
                    setColor: widget.setColor,
                    onUpdate: () => setState(() {}),
                    invert: invert,
                  ),
                ),

              // Full Color Palette Icon
              ToolbarIconButton(
                tooltip: t.editor.toolbar.toggleColors,
                selected: false,
                enabled: !widget.readOnly,
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
                      enabled: !widget.readOnly,
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
                enabled: !widget.readOnly,
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
                  enabled: !widget.readOnly && widget.isUndoPossible,
                  onPressed: widget.undo,
                  padding: buttonPadding,
                  child: const AdaptiveIcon(
                    icon: Icons.undo,
                    cupertinoIcon: CupertinoIcons.arrow_uturn_left,
                  ),
                ),
                ToolbarIconButton(
                  tooltip: t.editor.toolbar.redo,
                  enabled: !widget.readOnly && widget.isRedoPossible,
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
