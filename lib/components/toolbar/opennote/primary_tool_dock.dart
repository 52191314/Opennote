/// 🤖 Generated wholely or partially with Google Antigravity
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/components/theming/uni_icon.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/opennote/toolbar_primitives.dart';
import 'package:saber/components/toolbar/toolbar_button.dart';
import 'package:saber/data/editor/zoom_window.dart';
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

/// Tier 1 of the Opennote toolbar: the floating primary studio tool dock.
class OpennotePrimaryToolDock extends StatelessWidget {
  const OpennotePrimaryToolDock({
    super.key,
    required this.actions,
    required this.zoomWindowOpen,
    required this.onToggleZoomWindow,
    required this.onShowPenSettings,
    required this.onShowEraserSettings,
    required this.onShowDraftingTools,
    required this.onShowLassoOptions,
    required this.onShowTapeOptions,
    required this.onStateChanged,
  });

  final EditorToolbarActions actions;
  final bool zoomWindowOpen;
  final VoidCallback? onToggleZoomWindow;
  final void Function(Tool Function() getTool) onShowPenSettings;
  final VoidCallback onShowEraserSettings;
  final VoidCallback onShowDraftingTools;
  final VoidCallback onShowLassoOptions;
  final VoidCallback onShowTapeOptions;
  final VoidCallback onStateChanged;

  void _selectTool(Tool tool) {
    HapticFeedback.selectionClick();
    actions.setTool(tool);
  }

  Widget _dockButton(Widget button, {required bool isCompact}) =>
      ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: isCompact ? 36 : 42,
          minHeight: isCompact ? 36 : 40,
        ),
        child: button,
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final isCompact = viewportWidth < 430;
    final isTablet = viewportWidth >= 600;
    final buttonPadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 2, vertical: 3)
        : (isTablet
              ? const EdgeInsets.symmetric(horizontal: 5, vertical: 4)
              : opennoteToolbarButtonPadding);

    final isDrawingPen = Pen.isWritingPen(actions.currentTool);
    final isHighlighter = actions.currentTool is Highlighter;
    final isEraser = actions.currentTool is Eraser;
    final isLasso = actions.currentTool is Select;
    final isTape = actions.currentTool is StudyTapeTool;
    final isDrafting =
        actions.currentTool is Ruler ||
        actions.currentTool is ArrowTool ||
        actions.currentTool is DimensionTool;

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 14,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 6 : 10,
              vertical: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Group 1: Writing & Highlighting Tools
                _dockButton(
                  ToolbarIconButton(
                    tooltip: Pen.currentPen.name,
                    selected: isDrawingPen,
                    enabled: !actions.readOnly,
                    onPressed: () {
                      if (isDrawingPen) {
                        onShowPenSettings(() => Pen.currentPen);
                      } else {
                        _selectTool(Pen.currentPen);
                      }
                    },
                    onLongPress: () => onShowPenSettings(() => Pen.currentPen),
                    padding: buttonPadding,
                    child: UniIcon(Pen.currentPen.icon, size: 17),
                  ),
                  isCompact: isCompact,
                ),
                _dockButton(
                  ToolbarIconButton(
                    tooltip: t.editor.pens.pencil,
                    selected: actions.currentTool == Pencil.currentPencil,
                    enabled: !actions.readOnly,
                    onPressed: () {
                      if (actions.currentTool == Pencil.currentPencil) {
                        onShowPenSettings(() => Pencil.currentPencil);
                      } else {
                        _selectTool(Pencil.currentPencil);
                      }
                    },
                    onLongPress: () =>
                        onShowPenSettings(() => Pencil.currentPencil),
                    padding: buttonPadding,
                    child: const Icon(Pencil.pencilIcon, size: 17),
                  ),
                  isCompact: isCompact,
                ),
                _dockButton(
                  ToolbarIconButton(
                    tooltip: t.editor.pens.highlighter,
                    selected: isHighlighter,
                    enabled: !actions.readOnly,
                    onPressed: () {
                      if (isHighlighter) {
                        onShowPenSettings(() => Highlighter.currentHighlighter);
                      } else {
                        _selectTool(Highlighter.currentHighlighter);
                      }
                    },
                    onLongPress: () =>
                        onShowPenSettings(() => Highlighter.currentHighlighter),
                    padding: buttonPadding,
                    child: const Icon(Highlighter.highlighterIcon, size: 17),
                  ),
                  isCompact: isCompact,
                ),

                ToolbarGroupDivider(colorScheme: colorScheme),

                // Group 2: Editing, Selection & Drafting Tools
                _dockButton(
                  ToolbarIconButton(
                    tooltip: t.editor.toolbar.toggleEraser,
                    selected: isEraser,
                    enabled: !actions.readOnly,
                    onPressed: () {
                      if (isEraser) {
                        onShowEraserSettings();
                      } else {
                        _selectTool(Eraser(size: stows.eraserSize.value));
                      }
                    },
                    onLongPress: onShowEraserSettings,
                    padding: buttonPadding,
                    child: const Icon(Icons.auto_fix_normal_rounded, size: 17),
                  ),
                  isCompact: isCompact,
                ),
                _dockButton(
                  ToolbarIconButton(
                    tooltip: t.editor.drafting.title,
                    selected: isDrafting,
                    enabled: !actions.readOnly,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      onShowDraftingTools();
                    },
                    onLongPress: onShowDraftingTools,
                    padding: buttonPadding,
                    child: const Icon(Icons.category_rounded, size: 17),
                  ),
                  isCompact: isCompact,
                ),
                _dockButton(
                  ToolbarIconButton(
                    tooltip: t.editor.toolbar.select,
                    selected: isLasso,
                    enabled: !actions.readOnly,
                    onPressed: () {
                      if (isLasso) {
                        onShowLassoOptions();
                      } else {
                        _selectTool(Select.currentSelect);
                      }
                    },
                    onLongPress: onShowLassoOptions,
                    padding: buttonPadding,
                    child: const Icon(CupertinoIcons.lasso, size: 17),
                  ),
                  isCompact: isCompact,
                ),

                ToolbarGroupDivider(colorScheme: colorScheme),

                // Group 3: Insert, Study & Utility Tools
                _dockButton(
                  ToolbarIconButton(
                    tooltip: t.editor.elements.tooltip,
                    selected: false,
                    enabled: !actions.readOnly,
                    onPressed: () => actions.openElementsSheet?.call(),
                    padding: buttonPadding,
                    child: const Icon(Icons.auto_awesome, size: 17),
                  ),
                  isCompact: isCompact,
                ),
                _dockButton(
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
                  isCompact: isCompact,
                ),
                _dockButton(
                  ToolbarIconButton(
                    tooltip: t.editor.toolbar.text,
                    selected: actions.textEditing,
                    enabled: !actions.readOnly,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      actions.toggleTextEditing();
                    },
                    padding: buttonPadding,
                    child: const AdaptiveIcon(
                      icon: Icons.text_fields,
                      cupertinoIcon: CupertinoIcons.text_cursor,
                    ),
                  ),
                  isCompact: isCompact,
                ),
                _dockButton(
                  ToolbarIconButton(
                    tooltip: t.editor.tape.tooltip,
                    selected: isTape,
                    enabled: !actions.readOnly,
                    onPressed: () {
                      if (isTape) {
                        onShowTapeOptions();
                      } else {
                        _selectTool(StudyTapeTool.currentStudyTape);
                      }
                    },
                    onLongPress: onShowTapeOptions,
                    padding: buttonPadding,
                    child: const Icon(Icons.view_headline_rounded, size: 17),
                  ),
                  isCompact: isCompact,
                ),
                _dockButton(
                  ToolbarIconButton(
                    tooltip: stows.laserPointerMode.value == 'spotlight'
                        ? t.editor.tools.laserSpotlight
                        : t.editor.pens.laserPointer,
                    selected:
                        actions.currentTool == LaserPointer.currentLaserPointer,
                    enabled: true,
                    onPressed: () {
                      if (actions.currentTool ==
                          LaserPointer.currentLaserPointer) {
                        HapticFeedback.selectionClick();
                        stows.laserPointerMode.value =
                            stows.laserPointerMode.value == 'spotlight'
                            ? 'trail'
                            : 'spotlight';
                        onStateChanged();
                      } else {
                        _selectTool(LaserPointer.currentLaserPointer);
                      }
                    },
                    onLongPress: () {
                      HapticFeedback.selectionClick();
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
                  isCompact: isCompact,
                ),
                _dockButton(
                  ToolbarIconButton(
                    key: ZoomWindowKeys.toolbarButton,
                    tooltip: t.editor.toolbar.zoomWindow,
                    selected: zoomWindowOpen,
                    enabled: !actions.readOnly && onToggleZoomWindow != null,
                    onPressed: onToggleZoomWindow != null
                        ? () {
                            HapticFeedback.selectionClick();
                            onToggleZoomWindow!();
                          }
                        : null,
                    padding: buttonPadding,
                    child: const Icon(Icons.fit_screen, size: 17),
                  ),
                  isCompact: isCompact,
                ),

                // Quick Dock Position Toggle (Top <-> Bottom)
                ToolbarGroupDivider(colorScheme: colorScheme),
                ValueListenableBuilder<AxisDirection>(
                  valueListenable: stows.editorToolbarAlignment,
                  builder: (context, alignment, _) {
                    final isTop = alignment == AxisDirection.up;
                    return _dockButton(
                      ToolbarIconButton(
                        tooltip: isTop
                            ? 'Dock toolbar Bottom'
                            : 'Dock toolbar Top',
                        padding: buttonPadding,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          stows.editorToolbarAlignment.value = isTop
                              ? AxisDirection.down
                              : AxisDirection.up;
                        },
                        child: Icon(
                          isTop
                              ? Icons.vertical_align_bottom_rounded
                              : Icons.vertical_align_top_rounded,
                          size: 17,
                        ),
                      ),
                      isCompact: isCompact,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
