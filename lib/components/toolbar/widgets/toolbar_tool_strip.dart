/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/components/theming/dynamic_material_app.dart';
import 'package:saber/components/theming/uni_icon.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/quick_palette_bar.dart';
import 'package:saber/components/toolbar/toolbar_button.dart';
import 'package:saber/components/toolbar/widgets/toolbar_dialogs.dart';
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

/// Primary tool strip rendered inside the classic [Toolbar].
///
/// Adapts spacing between compact mobile viewports (360-390px) and spacious
/// tablet/desktop viewports while strictly preserving tool singleton identity.
class ToolbarToolStrip extends StatelessWidget {
  const ToolbarToolStrip({
    super.key,
    required this.actions,
    required this.isVertical,
    required this.invert,
    required this.undo,
    required this.isUndoPossible,
    required this.redo,
    required this.isRedoPossible,
    required this.toggleFingerDrawing,
    required this.onToggleEraser,
    required this.onToggleColorOptions,
    required this.onToggleFullscreen,
    required this.onStateChanged,
  });

  final EditorToolbarActions actions;
  final bool isVertical;
  final bool invert;
  final VoidCallback undo;
  final bool isUndoPossible;
  final VoidCallback redo;
  final bool isRedoPossible;
  final VoidCallback toggleFingerDrawing;
  final VoidCallback onToggleEraser;
  final VoidCallback onToggleColorOptions;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onStateChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final isCompactMobile = !isVertical && viewportWidth < 430;
    final isTabletOrDesktop = viewportWidth >= 600;

    final buttonPadding = isVertical
        ? const EdgeInsets.symmetric(vertical: 4)
        : EdgeInsets.symmetric(
            horizontal: isCompactMobile ? 2 : (isTabletOrDesktop ? 5 : 3),
          );

    final currentColor = ToolbarDialogs.currentColorFor(actions.currentTool);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.96),
        border: Border(
          top: isVertical
              ? BorderSide.none
              : BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.38),
                  width: 0.75,
                ),
          bottom: isVertical
              ? BorderSide.none
              : BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.38),
                  width: 0.75,
                ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isCompactMobile ? 6 : 10,
          vertical: 4,
        ),
        child: Wrap(
          direction: isVertical ? Axis.vertical : Axis.horizontal,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: isCompactMobile ? 1 : (isTabletOrDesktop ? 3 : 2),
          runSpacing: 4,
          children: [
            // 1. Pen
            ToolbarIconButton(
              tooltip: Pen.currentPen.name,
              selected: Pen.isWritingPen(actions.currentTool),
              enabled: !actions.readOnly,
              onPressed: () {
                if (Pen.isWritingPen(actions.currentTool)) {
                  ToolbarDialogs.showPenSettings(
                    context,
                    actions: actions,
                    getTool: () => Pen.currentPen,
                    onChanged: onStateChanged,
                  );
                } else {
                  actions.setTool(Pen.currentPen);
                }
              },
              onLongPress: () => ToolbarDialogs.showPenSettings(
                context,
                actions: actions,
                getTool: () => Pen.currentPen,
                onChanged: onStateChanged,
              ),
              padding: buttonPadding,
              child: UniIcon(Pen.currentPen.icon, size: 17),
            ),

            // 2. Pencil
            ToolbarIconButton(
              tooltip: t.editor.pens.pencil,
              selected: actions.currentTool == Pencil.currentPencil,
              enabled: !actions.readOnly,
              onPressed: () {
                if (actions.currentTool == Pencil.currentPencil) {
                  ToolbarDialogs.showPenSettings(
                    context,
                    actions: actions,
                    getTool: () => Pencil.currentPencil,
                    onChanged: onStateChanged,
                  );
                } else {
                  actions.setTool(Pencil.currentPencil);
                }
              },
              onLongPress: () => ToolbarDialogs.showPenSettings(
                context,
                actions: actions,
                getTool: () => Pencil.currentPencil,
                onChanged: onStateChanged,
              ),
              padding: buttonPadding,
              child: const Icon(Pencil.pencilIcon, size: 17),
            ),

            // 3. Highlighter
            ToolbarIconButton(
              tooltip: t.editor.pens.highlighter,
              selected: actions.currentTool == Highlighter.currentHighlighter,
              enabled: !actions.readOnly,
              onPressed: () {
                if (actions.currentTool == Highlighter.currentHighlighter) {
                  ToolbarDialogs.showPenSettings(
                    context,
                    actions: actions,
                    getTool: () => Highlighter.currentHighlighter,
                    onChanged: onStateChanged,
                  );
                } else {
                  actions.setTool(Highlighter.currentHighlighter);
                }
              },
              onLongPress: () => ToolbarDialogs.showPenSettings(
                context,
                actions: actions,
                getTool: () => Highlighter.currentHighlighter,
                onChanged: onStateChanged,
              ),
              padding: buttonPadding,
              child: const Icon(Highlighter.highlighterIcon, size: 17),
            ),

            // 4. Eraser
            ToolbarIconButton(
              tooltip: t.editor.toolbar.toggleEraser,
              selected: actions.currentTool is Eraser,
              enabled: !actions.readOnly,
              onPressed: () {
                if (actions.currentTool is Eraser) {
                  ToolbarDialogs.showEraserSettings(context);
                } else {
                  onToggleEraser();
                }
              },
              onLongPress: () => ToolbarDialogs.showEraserSettings(context),
              padding: buttonPadding,
              child: const Icon(Icons.auto_fix_normal_rounded, size: 17),
            ),

            // 5. Drafting & Shapes
            ToolbarIconButton(
              tooltip: t.editor.drafting.titleAlt,
              selected:
                  actions.currentTool is Ruler ||
                  actions.currentTool is ArrowTool ||
                  actions.currentTool is DimensionTool,
              enabled: !actions.readOnly,
              onPressed: () => ToolbarDialogs.showDraftingTools(
                context,
                actions: actions,
                onChanged: onStateChanged,
              ),
              onLongPress: () => ToolbarDialogs.showDraftingTools(
                context,
                actions: actions,
                onChanged: onStateChanged,
              ),
              padding: buttonPadding,
              child: const Icon(Icons.category_rounded, size: 17),
            ),

            // 6. Lasso
            ToolbarIconButton(
              tooltip: t.editor.toolbar.select,
              selected: actions.currentTool is Select,
              enabled: !actions.readOnly,
              onPressed: () {
                if (actions.currentTool is Select) {
                  ToolbarDialogs.showLassoOptions(context);
                } else {
                  actions.setTool(Select.currentSelect);
                }
              },
              onLongPress: () => ToolbarDialogs.showLassoOptions(context),
              padding: buttonPadding,
              child: const Icon(CupertinoIcons.lasso, size: 17),
            ),

            // 7. Study Tape (preserves StudyTapeTool.currentStudyTape singleton)
            ToolbarIconButton(
              tooltip: t.editor.tape.tooltip,
              selected: actions.currentTool is StudyTapeTool,
              enabled: !actions.readOnly,
              onPressed: () {
                if (actions.currentTool is StudyTapeTool) {
                  ToolbarDialogs.showTapeOptions(
                    context,
                    actions: actions,
                    onChanged: onStateChanged,
                  );
                } else {
                  actions.setTool(StudyTapeTool.currentStudyTape);
                }
              },
              onLongPress: () => ToolbarDialogs.showTapeOptions(
                context,
                actions: actions,
                onChanged: onStateChanged,
              ),
              padding: buttonPadding,
              child: const Icon(Icons.view_headline_rounded, size: 17),
            ),

            // 8. Elements (Stickers)
            ToolbarIconButton(
              tooltip: t.editor.elements.tooltip,
              selected: false,
              enabled: !actions.readOnly,
              onPressed: () => actions.openElementsSheet?.call(),
              padding: buttonPadding,
              child: const Icon(Icons.auto_awesome, size: 17),
            ),

            // 9. Photo
            ToolbarIconButton(
              tooltip: t.editor.toolbar.photo,
              enabled: !actions.readOnly,
              onPressed: actions.pickPhoto,
              padding: buttonPadding,
              child: const AdaptiveIcon(
                icon: Icons.photo,
                cupertinoIcon: CupertinoIcons.photo,
              ),
            ),

            // 10. Text Box
            ToolbarIconButton(
              tooltip: t.editor.toolbar.text,
              selected: actions.textEditing,
              enabled: !actions.readOnly,
              onPressed: actions.toggleTextEditing,
              padding: buttonPadding,
              child: const AdaptiveIcon(
                icon: Icons.text_fields,
                cupertinoIcon: CupertinoIcons.text_cursor,
              ),
            ),

            // 11. Laser Pointer
            ToolbarIconButton(
              tooltip: stows.laserPointerMode.value == 'spotlight'
                  ? t.editor.tools.laserSpotlight
                  : t.editor.pens.laserPointer,
              selected: actions.currentTool == LaserPointer.currentLaserPointer,
              enabled: true,
              onPressed: () {
                if (actions.currentTool == LaserPointer.currentLaserPointer) {
                  stows.laserPointerMode.value =
                      stows.laserPointerMode.value == 'spotlight'
                      ? 'trail'
                      : 'spotlight';
                  onStateChanged();
                } else {
                  actions.setTool(LaserPointer.currentLaserPointer);
                }
              },
              onLongPress: () {
                stows.laserPointerMode.value =
                    stows.laserPointerMode.value == 'spotlight'
                    ? 'trail'
                    : 'spotlight';
                onStateChanged();
              },
              padding: buttonPadding,
              child: Icon(
                stows.laserPointerMode.value == 'spotlight'
                    ? Icons.adjust_rounded
                    : Icons.flare_rounded,
                size: 17,
              ),
            ),

            // Contextual Quick Palette (3 Quick Colors + 3 Quick Sizes)
            if (actions.currentTool is Pen || actions.currentTool is Select)
              Padding(
                padding: isVertical
                    ? const EdgeInsets.symmetric(vertical: 2)
                    : const EdgeInsets.symmetric(horizontal: 4),
                child: QuickPaletteBar(
                  axis: isVertical ? Axis.vertical : Axis.horizontal,
                  currentTool: actions.currentTool,
                  setColor: actions.setColor,
                  onUpdate: onStateChanged,
                  invert: invert,
                ),
              ),

            // Full Color Palette Icon
            ToolbarIconButton(
              tooltip: t.editor.toolbar.toggleColors,
              selected: false,
              enabled: !actions.readOnly,
              onPressed: onToggleColorOptions,
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
                    enabled: !actions.readOnly,
                    onPressed: toggleFingerDrawing,
                    padding: buttonPadding,
                    child: const Icon(CupertinoIcons.hand_draw),
                  );
                },
              ),

            // Fullscreen Toggle
            ToolbarIconButton(
              tooltip: t.editor.toolbar.fullscreen,
              selected: DynamicMaterialApp.isFullscreen,
              enabled: !actions.readOnly,
              onPressed: onToggleFullscreen,
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
            if (isVertical) ...[
              ToolbarIconButton(
                tooltip: t.editor.toolbar.undo,
                enabled: !actions.readOnly && isUndoPossible,
                onPressed: undo,
                padding: buttonPadding,
                child: const AdaptiveIcon(
                  icon: Icons.undo,
                  cupertinoIcon: CupertinoIcons.arrow_uturn_left,
                ),
              ),
              ToolbarIconButton(
                tooltip: t.editor.toolbar.redo,
                enabled: !actions.readOnly && isRedoPossible,
                onPressed: redo,
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
    );
  }
}
