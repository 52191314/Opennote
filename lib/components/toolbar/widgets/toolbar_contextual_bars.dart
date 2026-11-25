/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:io';

import 'package:collapsible/collapsible.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/selection_bar.dart';
import 'package:saber/data/tools/select.dart';

/// Collapsible rich-text Quill formatting bar displayed when text editing is
/// active inside [Toolbar].
class ToolbarQuillBar extends StatelessWidget {
  const ToolbarQuillBar({
    super.key,
    required this.actions,
    required this.isVertical,
  });

  final EditorToolbarActions actions;
  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return ValueListenableBuilder(
      valueListenable: actions.quillFocus,
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
          axis: isVertical
              ? CollapsibleAxis.horizontal
              : CollapsibleAxis.vertical,
          maintainState: false,
          collapsed: !actions.textEditing || quill == null,
          child: quill != null
              ? QuillSimpleToolbar(
                  controller: quill.controller,
                  config: QuillSimpleToolbarConfig(
                    axis: isVertical ? Axis.vertical : Axis.horizontal,
                    buttonOptions: QuillSimpleToolbarButtonOptions(
                      base: QuillToolbarBaseButtonOptions(iconTheme: iconTheme),
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
    );
  }
}

/// Collapsible floating selection actions capsule displayed when [Select] is
/// active inside [Toolbar].
class ToolbarSelectionBar extends StatelessWidget {
  const ToolbarSelectionBar({
    super.key,
    required this.actions,
    required this.isVertical,
  });

  final EditorToolbarActions actions;
  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Collapsible(
      axis: isVertical ? CollapsibleAxis.horizontal : CollapsibleAxis.vertical,
      maintainState: false,
      collapsed: actions.currentTool is! Select,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 0.75,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: SelectionBar(
          cutSelection: actions.cutSelection,
          copySelection: actions.copySelection,
          pasteSelection: actions.pasteSelection,
          duplicateSelection: actions.duplicateSelection,
          deleteSelection: actions.deleteSelection,
          onSetColor: actions.onSetColor ?? actions.setColor,
          cropPossible: actions.cropPossible,
          cropActive: actions.cropActive,
          toggleCrop: actions.toggleCrop,
          toggleResize: actions.toggleResize,
          isResizeActive: actions.isResizeActive,
          bringToFront: actions.bringToFront,
          sendToBack: actions.sendToBack,
          smoothen: actions.smoothen,
          addToElements: actions.addToElements,
          reduceTextSize: actions.reduceSelectionSize,
          enlargeTextSize: actions.enlargeSelectionSize,
        ),
      ),
    );
  }
}
