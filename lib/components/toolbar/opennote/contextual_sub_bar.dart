/// 🤖 Generated wholely or partially with Google Antigravity
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/opennote/sub_bars/drafting_sub_bar.dart';
import 'package:saber/components/toolbar/opennote/sub_bars/eraser_sub_bar.dart';
import 'package:saber/components/toolbar/opennote/sub_bars/lasso_sub_bar.dart';
import 'package:saber/components/toolbar/opennote/sub_bars/pen_sub_bar.dart';
import 'package:saber/components/toolbar/opennote/sub_bars/study_tape_sub_bar.dart';
import 'package:saber/data/tools/arrow.dart';
import 'package:saber/data/tools/dimension.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/study_tape.dart';
import 'package:saber/i18n/strings.g.dart';

/// Tier 2 of the Opennote toolbar: the contextual floating palette capsule.
class OpennoteContextualSubBar extends StatelessWidget {
  const OpennoteContextualSubBar({
    super.key,
    required this.actions,
    required this.currentColor,
    required this.invert,
    required this.onClearPage,
    required this.onShowLassoOptions,
    required this.onShowTapeOptions,
    required this.onToggleColorOptions,
    required this.onStateChanged,
  });

  final EditorToolbarActions actions;
  final Color? currentColor;
  final bool invert;
  final VoidCallback? onClearPage;
  final VoidCallback onShowLassoOptions;
  final VoidCallback onShowTapeOptions;
  final VoidCallback onToggleColorOptions;
  final VoidCallback onStateChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final isCompact = viewportWidth < 430;

    final isEraser = actions.currentTool is Eraser;
    final isLasso = actions.currentTool is Select;
    final isTape = actions.currentTool is StudyTapeTool;
    final isDrafting =
        actions.currentTool is Ruler ||
        actions.currentTool is ArrowTool ||
        actions.currentTool is DimensionTool;

    final platform = Theme.of(context).platform;
    final scrollPhysics = platform == TargetPlatform.iOS
        ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
        : const ClampingScrollPhysics();

    return Center(
      child: Container(
        height: isCompact ? 38 : 42,
        margin: EdgeInsets.symmetric(
          horizontal: isCompact ? 6 : 12,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: scrollPhysics,
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isTape)
                  OpennoteStudyTapeSubBar(
                    actions: actions,
                    onShowTapeOptions: onShowTapeOptions,
                  )
                else if (isDrafting)
                  OpennoteDraftingSubBar(actions: actions)
                else if (isEraser)
                  OpennoteEraserSubBar(
                    onClearPage: onClearPage,
                    onStateChanged: onStateChanged,
                  )
                else if (isLasso)
                  OpennoteLassoSubBar(
                    actions: actions,
                    onShowLassoOptions: onShowLassoOptions,
                    onStateChanged: onStateChanged,
                  )
                else if (actions.currentTool is Pen)
                  OpennotePenSubBar(
                    actions: actions,
                    currentColor: currentColor,
                    invert: invert,
                    onToggleColorOptions: onToggleColorOptions,
                    onStateChanged: onStateChanged,
                  )
                else if (actions.textEditing)
                  ValueListenableBuilder(
                    valueListenable: actions.quillFocus,
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
                      return QuillSimpleToolbar(
                        controller: quill.controller,
                        config: const QuillSimpleToolbarConfig(
                          axis: Axis.horizontal,
                          showUndo: false,
                          showRedo: false,
                          showFontSize: false,
                          showFontFamily: false,
                          showClearFormat: false,
                        ),
                      );
                    },
                  )
                else
                  Text(
                    t.editor.tools.toolbarLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.85,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
