/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/components/theming/uni_icon.dart';
import 'package:saber/components/toolbar/color_bar.dart';
import 'package:saber/components/toolbar/drafting_tools_popup.dart';
import 'package:saber/components/toolbar/eraser_size_popup.dart';
import 'package:saber/components/toolbar/lasso_filter_popup.dart';
import 'package:saber/components/toolbar/pen_modal.dart';
import 'package:saber/components/toolbar/quick_palette_bar.dart';
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

/// A comprehensive Goodnotes 6/7-inspired Dual-Tier Writing Toolbar.
///
/// **Tier 1 (Main Tool Strip)**:
/// - Floating or docked rounded pill displaying primary note-taking tools:
///   Fountain/Ballpoint Pen, Pencil, Eraser, Highlighter, Shapes & Drafting,
///   Lasso, Elements, Media/Photo, Text Box, Study Tape, Laser Pointer.
/// - Active tool receives a prominent pill container highlight with contrasting icon.
/// - Tapping an already active tool re-opens that tool's dedicated options modal.
///
/// **Tier 2 (Dynamic Contextual Sub-Bar)**:
/// - Dynamically updates directly below Tier 1:
///   - Pen / Highlighter / Pencil: 3 Quick Colors + Full Palette Wheel, and 3 Quick Thicknesses.
///   - Eraser: 3 Quick Sizes, Clear Page, and Highlighter-Only / Object-Mode toggles.
///   - Lasso: Filter chips (Handwriting, Images, Text, Tape) + contextual selection actions.
///   - Study Tape: Conceal All, Reveal All, and pattern styles.
///   - Shapes: Shape presets and fill toggle.
///   - Text: Rich text formatting controls.
class GoodnotesToolbar extends StatefulWidget {
  const GoodnotesToolbar({
    super.key,
    required this.readOnly,
    required this.setTool,
    required this.currentTool,
    required this.setColor,
    required this.quillFocus,
    required this.textEditing,
    required this.toggleTextEditing,
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
    this.onRevealAllTape,
    this.onConcealAllTape,
    this.onClearPage,
  });

  final bool readOnly;
  final ValueChanged<Tool> setTool;
  final Tool currentTool;
  final ValueChanged<Color> setColor;

  final ValueNotifier<QuillStruct?> quillFocus;
  final bool textEditing;
  final VoidCallback toggleTextEditing;

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
  final VoidCallback? onRevealAllTape;
  final VoidCallback? onConcealAllTape;
  final VoidCallback? onClearPage;

  @override
  State<GoodnotesToolbar> createState() => _GoodnotesToolbarState();
}

class _GoodnotesToolbarState extends State<GoodnotesToolbar> {
  static const _buttonPadding = EdgeInsets.symmetric(
    horizontal: 5,
    vertical: 4,
  );

  void _showPenSettings(Tool Function() getTool) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: ColorScheme.of(context).surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ColorScheme.of(
                context,
              ).outlineVariant.withValues(alpha: 0.5),
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
                    Icons.edit_note_rounded,
                    size: 22,
                    color: ColorScheme.of(context).primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.editor.tools.penOptions,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorScheme.of(context).onSurface,
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
        currentTool: widget.currentTool,
        onSelectTool: (tool) {
          widget.setTool(tool);
          setState(() {});
        },
        onPickShape: widget.pickShape,
      ),
    );
  }

  void _showLassoOptions() {
    showDialog(context: context, builder: (_) => const LassoFilterPopup());
  }

  void _showTapeOptions() {
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
  }

  void _toggleColorOptions() {
    final colorScheme = ColorScheme.of(context);
    final brightness = Theme.brightnessOf(context);
    final invert =
        stows.editorAutoInvert.value && brightness == Brightness.dark;

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
                currentColor: currentColor,
                setColor: (color) {
                  widget.setColor(color);
                  setState(() {});
                },
                invert: invert,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final brightness = Theme.brightnessOf(context);
    final invert =
        stows.editorAutoInvert.value && brightness == Brightness.dark;

    final currentColor = switch (widget.currentTool) {
      final Pen pen => pen.color,
      final Select select => select.getDominantStrokeColor(),
      _ => null,
    };

    final isDrawingPen = Pen.isWritingPen(widget.currentTool);
    final isHighlighter = widget.currentTool is Highlighter;
    final isEraser = widget.currentTool is Eraser;
    final isLasso = widget.currentTool is Select;
    final isTape = widget.currentTool is StudyTapeTool;
    final isDrafting =
        widget.currentTool is Ruler ||
        widget.currentTool is ArrowTool ||
        widget.currentTool is DimensionTool;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            width: 0.75,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ----------------------------------------------------
          // TIER 1: Main Tool Strip (Floating Pill)
          // ----------------------------------------------------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Pen (Fountain / Ballpoint)
                ToolbarIconButton(
                  tooltip: Pen.currentPen.name,
                  selected: isDrawingPen,
                  enabled: !widget.readOnly,
                  onPressed: () {
                    if (isDrawingPen) {
                      _showPenSettings(() => Pen.currentPen);
                    } else {
                      widget.setTool(Pen.currentPen);
                    }
                  },
                  onLongPress: () => _showPenSettings(() => Pen.currentPen),
                  padding: _buttonPadding,
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
                  onLongPress: () =>
                      _showPenSettings(() => Pencil.currentPencil),
                  padding: _buttonPadding,
                  child: const FaIcon(Pencil.pencilIcon, size: 16),
                ),

                // 3. Eraser
                ToolbarIconButton(
                  tooltip: t.editor.toolbar.toggleEraser,
                  selected: isEraser,
                  enabled: !widget.readOnly,
                  onPressed: () {
                    if (isEraser) {
                      _showEraserSettings();
                    } else {
                      widget.setTool(Eraser(size: stows.eraserSize.value));
                    }
                  },
                  onLongPress: _showEraserSettings,
                  padding: _buttonPadding,
                  child: const FaIcon(FontAwesomeIcons.eraser, size: 16),
                ),

                // 4. Highlighter
                ToolbarIconButton(
                  tooltip: t.editor.pens.highlighter,
                  selected: isHighlighter,
                  enabled: !widget.readOnly,
                  onPressed: () {
                    if (isHighlighter) {
                      _showPenSettings(() => Highlighter.currentHighlighter);
                    } else {
                      widget.setTool(Highlighter.currentHighlighter);
                    }
                  },
                  onLongPress: () =>
                      _showPenSettings(() => Highlighter.currentHighlighter),
                  padding: _buttonPadding,
                  child: const FaIcon(Highlighter.highlighterIcon, size: 16),
                ),

                // 5. Shapes & Drafting (Ruler, Arrow, Dimension, Shapes)
                ToolbarIconButton(
                  tooltip: t.editor.drafting.title,
                  selected: isDrafting,
                  enabled: !widget.readOnly,
                  onPressed: _showDraftingTools,
                  onLongPress: _showDraftingTools,
                  padding: _buttonPadding,
                  child: const FaIcon(FontAwesomeIcons.shapes, size: 16),
                ),

                // 6. Lasso (Select)
                ToolbarIconButton(
                  tooltip: t.editor.toolbar.select,
                  selected: isLasso,
                  enabled: !widget.readOnly,
                  onPressed: () {
                    if (isLasso) {
                      _showLassoOptions();
                    } else {
                      widget.setTool(Select.currentSelect);
                    }
                  },
                  onLongPress: _showLassoOptions,
                  padding: _buttonPadding,
                  child: const Icon(CupertinoIcons.lasso),
                ),

                // 7. Elements (Stickers)
                ToolbarIconButton(
                  tooltip: t.editor.elements.tooltip,
                  selected: false,
                  enabled: !widget.readOnly,
                  onPressed: () => widget.openElementsSheet?.call(),
                  padding: _buttonPadding,
                  child: const Icon(Icons.auto_awesome, size: 16),
                ),

                // 8. Media / Photo
                ToolbarIconButton(
                  tooltip: t.editor.toolbar.photo,
                  enabled: !widget.readOnly,
                  onPressed: widget.pickPhoto,
                  padding: _buttonPadding,
                  child: const AdaptiveIcon(
                    icon: Icons.photo,
                    cupertinoIcon: CupertinoIcons.photo,
                  ),
                ),

                // 9. Text Box
                ToolbarIconButton(
                  tooltip: t.editor.toolbar.text,
                  selected: widget.textEditing,
                  enabled: !widget.readOnly,
                  onPressed: widget.toggleTextEditing,
                  padding: _buttonPadding,
                  child: const AdaptiveIcon(
                    icon: Icons.text_fields,
                    cupertinoIcon: CupertinoIcons.text_cursor,
                  ),
                ),

                // 10. Study Tape (Active recall)
                ToolbarIconButton(
                  tooltip: t.editor.tape.tooltip,
                  selected: isTape,
                  enabled: !widget.readOnly,
                  onPressed: () {
                    if (isTape) {
                      _showTapeOptions();
                    } else {
                      widget.setTool(StudyTapeTool());
                    }
                  },
                  onLongPress: _showTapeOptions,
                  padding: _buttonPadding,
                  child: const Icon(Icons.view_headline_rounded, size: 16),
                ),

                // 11. Laser Pointer
                ToolbarIconButton(
                  tooltip: stows.laserPointerMode.value == 'spotlight'
                      ? t.editor.tools.laserSpotlight
                      : t.editor.pens.laserPointer,
                  selected:
                      widget.currentTool == LaserPointer.currentLaserPointer,
                  enabled: true,
                  onPressed: () {
                    if (widget.currentTool ==
                        LaserPointer.currentLaserPointer) {
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
                  padding: _buttonPadding,
                  child: Icon(
                    stows.laserPointerMode.value == 'spotlight'
                        ? Icons.adjust_rounded
                        : Symbols.stylus_laser_pointer,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),

          // ----------------------------------------------------
          // TIER 2: Dynamic Contextual Sub-Bar
          // ----------------------------------------------------
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CASE A: Study Tape (specific Pen subclass)
                  if (isTape) ...[
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(
                        Icons.visibility_off_rounded,
                        size: 14,
                      ),
                      label: Text(
                        t.editor.tape.concealAll,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: widget.onConcealAllTape,
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.visibility_rounded, size: 14),
                      label: Text(
                        t.editor.tape.revealAll,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: widget.onRevealAllTape,
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.palette_outlined, size: 14),
                      label: Text(
                        t.editor.tape.patterns,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: _showTapeOptions,
                    ),
                  ]
                  // CASE B: Shapes & Drafting (ArrowTool, Ruler, DimensionTool)
                  else if (isDrafting) ...[
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.category_rounded, size: 14),
                      label: Text(
                        t.editor.drafting.shapeLibrary,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: widget.pickShape,
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.straighten_rounded, size: 14),
                      label: Text(
                        t.editor.pens.ruler,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () => widget.setTool(Ruler()),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(
                        Icons.arrow_right_alt_rounded,
                        size: 14,
                      ),
                      label: Text(
                        t.editor.drafting.arrow,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () => widget.setTool(ArrowTool()),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.architecture_rounded, size: 14),
                      label: Text(
                        t.editor.drafting.dimension,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () => widget.setTool(DimensionTool()),
                    ),
                  ]
                  // CASE C: Eraser
                  else if (isEraser) ...[
                    // 3 Quick Sizes
                    _EraserQuickSizeButton(
                      label: t.editor.tools.fine,
                      size: 15.0,
                      selected: (stows.eraserSize.value - 15.0).abs() < 5,
                      onTap: () =>
                          setState(() => stows.eraserSize.value = 15.0),
                    ),
                    const SizedBox(width: 4),
                    _EraserQuickSizeButton(
                      label: t.editor.tools.medium,
                      size: 30.0,
                      selected: (stows.eraserSize.value - 30.0).abs() < 5,
                      onTap: () =>
                          setState(() => stows.eraserSize.value = 30.0),
                    ),
                    const SizedBox(width: 4),
                    _EraserQuickSizeButton(
                      label: t.editor.tools.broad,
                      size: 60.0,
                      selected: (stows.eraserSize.value - 60.0).abs() < 5,
                      onTap: () =>
                          setState(() => stows.eraserSize.value = 60.0),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 18,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 8),
                    // Highlighter-only toggle
                    FilterChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        t.editor.eraser.highlighterOnlyShort,
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: stows.eraserEraseHighlighterOnly.value,
                      onSelected: (val) => setState(
                        () => stows.eraserEraseHighlighterOnly.value = val,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Erase stroke toggle
                    FilterChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        t.editor.eraser.entireStroke,
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: stows.eraserMode.value == 'object',
                      onSelected: (val) => setState(
                        () => stows.eraserMode.value = val
                            ? 'object'
                            : 'precision',
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Clear page button
                    if (widget.onClearPage != null)
                      ActionChip(
                        visualDensity: VisualDensity.compact,
                        avatar: const Icon(
                          Icons.delete_sweep_rounded,
                          size: 14,
                        ),
                        label: Text(
                          t.editor.eraser.clearPage,
                          style: const TextStyle(fontSize: 11),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(t.editor.eraser.clearPageTitle),
                              content: Text(
                                t.editor.eraser.clearPageDescription,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: Text(t.common.cancel),
                                ),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: colorScheme.error,
                                  ),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    widget.onClearPage?.call();
                                  },
                                  child: Text(t.editor.actions.clear),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ]
                  // CASE D: Lasso (Select)
                  else if (isLasso) ...[
                    FilterChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        t.editor.lasso.handwriting,
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: stows.lassoSelectHandwriting.value,
                      onSelected: (val) => setState(
                        () => stows.lassoSelectHandwriting.value = val,
                      ),
                    ),
                    const SizedBox(width: 4),
                    FilterChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        t.editor.lasso.images,
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: stows.lassoSelectImages.value,
                      onSelected: (val) =>
                          setState(() => stows.lassoSelectImages.value = val),
                    ),
                    const SizedBox(width: 4),
                    FilterChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        t.editor.lasso.textBoxes,
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: stows.lassoSelectText.value,
                      onSelected: (val) =>
                          setState(() => stows.lassoSelectText.value = val),
                    ),
                    const SizedBox(width: 4),
                    FilterChip(
                      visualDensity: VisualDensity.compact,
                      label: Text(
                        t.editor.tape.short,
                        style: const TextStyle(fontSize: 11),
                      ),
                      selected: stows.lassoSelectTape.value,
                      onSelected: (val) =>
                          setState(() => stows.lassoSelectTape.value = val),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.tune_rounded, size: 16),
                      tooltip: t.editor.lasso.settings,
                      onPressed: _showLassoOptions,
                    ),
                  ]
                  // CASE E: General Pen / Pencil / Highlighter
                  else if (widget.currentTool is Pen) ...[
                    QuickPaletteBar(
                      axis: Axis.horizontal,
                      currentTool: widget.currentTool,
                      setColor: widget.setColor,
                      onUpdate: () => setState(() {}),
                      invert: invert,
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 1,
                      height: 18,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 6),
                    Tooltip(
                      message: t.editor.toolbar.toggleColors,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _toggleColorOptions,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
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
                      ),
                    ),
                  ]
                  // CASE F: Text Editing
                  else if (widget.textEditing) ...[
                    ValueListenableBuilder(
                      valueListenable: widget.quillFocus,
                      builder: (context, quill, _) {
                        if (quill == null) {
                          return Text(
                            t.editor.tools.tapToAddText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          );
                        }
                        return Expanded(
                          child: QuillSimpleToolbar(
                            controller: quill.controller,
                            config: const QuillSimpleToolbarConfig(
                              axis: Axis.horizontal,
                              showUndo: false,
                              showRedo: false,
                              showFontSize: false,
                              showFontFamily: false,
                              showClearFormat: false,
                            ),
                          ),
                        );
                      },
                    ),
                  ]
                  // Default: General writing info
                  else ...[
                    Text(
                      t.editor.tools.toolbarLabel,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.8,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EraserQuickSizeButton extends StatelessWidget {
  const _EraserQuickSizeButton({
    required this.label,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colorScheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
