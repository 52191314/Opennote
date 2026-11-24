/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/components/toolbar/lasso_filter_popup.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

class SelectionBar extends StatelessWidget {
  final VoidCallback? cutSelection;
  final VoidCallback? onCutSelection;
  final VoidCallback copySelection;
  final VoidCallback pasteSelection;
  final VoidCallback duplicateSelection;
  final VoidCallback deleteSelection;
  final ValueChanged<Color>? onSetColor;
  final bool cropPossible;
  final bool cropActive;
  final VoidCallback? toggleCrop;
  final VoidCallback? toggleResize;
  final bool isResizeActive;
  final VoidCallback? takeScreenshot;
  final VoidCallback? bringToFront;
  final VoidCallback? sendToBack;
  final VoidCallback? smoothen;
  final VoidCallback? addToElements;
  final VoidCallback? reduceTextSize;
  final VoidCallback? enlargeTextSize;

  static List<({String name, Color color})> get quickColorOptions => [
    (name: t.editor.colors.black, color: const Color(0xFF000000)),
    (name: t.editor.colors.blue, color: const Color(0xFF1976D2)),
    (name: t.editor.colors.red, color: const Color(0xFFD32F2F)),
    (name: t.editor.colors.green, color: const Color(0xFF388E3C)),
    (name: t.editor.colors.yellow, color: const Color(0xFFFBC02D)),
    (name: t.editor.colors.purple, color: const Color(0xFF7B1FA2)),
    (name: t.editor.colors.orange, color: const Color(0xFFF57C00)),
  ];

  const SelectionBar({
    super.key,
    this.cutSelection,
    this.onCutSelection,
    required this.copySelection,
    required this.pasteSelection,
    required this.duplicateSelection,
    required this.deleteSelection,
    this.onSetColor,
    this.cropPossible = false,
    this.cropActive = false,
    this.toggleCrop,
    this.toggleResize,
    this.isResizeActive = false,
    this.takeScreenshot,
    this.bringToFront,
    this.sendToBack,
    this.smoothen,
    this.addToElements,
    this.reduceTextSize,
    this.enlargeTextSize,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StatefulBuilder(
            builder: (context, setState) => IconButton(
              onPressed: () {
                stows.selectionRectMode.value = !stows.selectionRectMode.value;
                setState(() {});
              },
              style: TextButton.styleFrom(
                foregroundColor: stows.selectionRectMode.value
                    ? ColorScheme.of(context).secondary
                    : ColorScheme.of(context).onSurface,
                backgroundColor: stows.selectionRectMode.value
                    ? Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1)
                    : Colors.transparent,
                shape: const CircleBorder(),
              ),
              tooltip: stows.selectionRectMode.value
                  ? t.editor.lasso.rectSelect
                  : t.editor.lasso.lassoSelect,
              icon: Icon(
                stows.selectionRectMode.value
                    ? Icons.crop_square
                    : Icons.gesture,
              ),
            ),
          ),
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const LassoFilterPopup(),
            ),
            style: TextButton.styleFrom(
              foregroundColor: ColorScheme.of(context).secondary,
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
            ),
            tooltip: t.editor.lasso.filters,
            icon: const Icon(Icons.tune),
          ),
          if (cropPossible)
            IconButton(
              onPressed: toggleCrop,
              style: TextButton.styleFrom(
                foregroundColor: cropActive
                    ? ColorScheme.of(context).primary
                    : ColorScheme.of(context).secondary,
                backgroundColor: cropActive
                    ? ColorScheme.of(context).primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                shape: const CircleBorder(),
              ),
              tooltip: cropActive
                  ? t.editor.lasso.doneCropping
                  : t.editor.lasso.cropImage,
              icon: Icon(
                cropActive ? Icons.check : Icons.crop,
                color: cropActive ? ColorScheme.of(context).primary : null,
              ),
            ),
          if (cutSelection != null || onCutSelection != null)
            IconButton(
              onPressed: cutSelection ?? onCutSelection,
              style: TextButton.styleFrom(
                foregroundColor: ColorScheme.of(context).secondary,
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
              tooltip: t.editor.actions.cut,
              icon: const AdaptiveIcon(
                icon: Icons.content_cut,
                cupertinoIcon: CupertinoIcons.scissors,
              ),
            ),
          IconButton(
            onPressed: copySelection,
            style: TextButton.styleFrom(
              foregroundColor: ColorScheme.of(context).secondary,
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
            ),
            tooltip: t.editor.actions.copy,
            icon: const AdaptiveIcon(
              icon: Icons.file_copy,
              cupertinoIcon: CupertinoIcons.doc_on_clipboard,
            ),
          ),
          IconButton(
            onPressed: pasteSelection,
            style: TextButton.styleFrom(
              foregroundColor: ColorScheme.of(context).secondary,
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
            ),
            tooltip: t.editor.actions.paste,
            icon: const AdaptiveIcon(
              icon: Icons.content_paste,
              cupertinoIcon: CupertinoIcons.doc_on_clipboard,
            ),
          ),
          IconButton(
            onPressed: duplicateSelection,
            style: TextButton.styleFrom(
              foregroundColor: ColorScheme.of(context).secondary,
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
            ),
            tooltip: t.editor.selectionBar.duplicate,
            icon: const AdaptiveIcon(
              icon: Icons.copy_all,
              cupertinoIcon: CupertinoIcons.plus_rectangle_on_rectangle,
            ),
          ),
          if (onSetColor != null)
            PopupMenuButton<Color>(
              tooltip: t.editor.lasso.color,
              icon: const Icon(Icons.palette_outlined),
              style: TextButton.styleFrom(
                foregroundColor: ColorScheme.of(context).secondary,
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
              onSelected: (color) {
                HapticFeedback.selectionClick();
                onSetColor?.call(color);
              },
              itemBuilder: (context) => [
                for (final item in quickColorOptions)
                  PopupMenuItem<Color>(
                    value: item.color,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(item.name),
                      ],
                    ),
                  ),
              ],
            ),
          if (bringToFront != null)
            IconButton(
              onPressed: bringToFront,
              style: TextButton.styleFrom(
                foregroundColor: ColorScheme.of(context).secondary,
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
              tooltip: t.editor.lasso.bringToFront,
              icon: const Icon(Icons.flip_to_front_rounded),
            ),
          if (sendToBack != null)
            IconButton(
              onPressed: sendToBack,
              style: TextButton.styleFrom(
                foregroundColor: ColorScheme.of(context).secondary,
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
              tooltip: t.editor.lasso.sendToBack,
              icon: const Icon(Icons.flip_to_back_rounded),
            ),
          if (smoothen != null)
            IconButton(
              onPressed: smoothen,
              style: TextButton.styleFrom(
                foregroundColor: ColorScheme.of(context).secondary,
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
              tooltip: t.editor.lasso.smoothenHandwriting,
              icon: const Icon(Icons.auto_fix_high_rounded),
            ),
          if (toggleResize != null)
            IconButton(
              onPressed: toggleResize,
              style: TextButton.styleFrom(
                foregroundColor: isResizeActive
                    ? ColorScheme.of(context).primary
                    : ColorScheme.of(context).secondary,
                backgroundColor: isResizeActive
                    ? ColorScheme.of(context).primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                shape: const CircleBorder(),
              ),
              tooltip: isResizeActive
                  ? t.editor.lasso.doneResizing
                  : t.editor.lasso.resize,
              icon: const Icon(Icons.open_in_full_rounded),
            ),
          if (reduceTextSize != null)
            IconButton(
              onPressed: reduceTextSize,
              style: TextButton.styleFrom(
                foregroundColor: ColorScheme.of(context).secondary,
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
              tooltip: t.editor.lasso.reduceSize,
              icon: const Icon(Icons.text_decrease_rounded),
            ),
          if (enlargeTextSize != null)
            IconButton(
              onPressed: enlargeTextSize,
              style: TextButton.styleFrom(
                foregroundColor: ColorScheme.of(context).secondary,
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
              tooltip: t.editor.lasso.enlargeSize,
              icon: const Icon(Icons.text_increase_rounded),
            ),
          if (takeScreenshot != null)
            IconButton(
              onPressed: takeScreenshot,
              style: TextButton.styleFrom(
                foregroundColor: ColorScheme.of(context).secondary,
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
              tooltip: t.editor.lasso.screenshot,
              icon: const Icon(Icons.crop_free_rounded),
            ),
          if (addToElements != null)
            IconButton(
              onPressed: addToElements,
              style: TextButton.styleFrom(
                foregroundColor: ColorScheme.of(context).secondary,
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
              tooltip: t.editor.elements.add,
              icon: const Icon(Icons.bookmark_add_outlined),
            ),
          IconButton(
            onPressed: deleteSelection,
            style: TextButton.styleFrom(
              foregroundColor: ColorScheme.of(context).secondary,
              backgroundColor: Colors.transparent,
              shape: const CircleBorder(),
            ),
            tooltip: t.editor.selectionBar.delete,
            icon: const AdaptiveIcon(
              icon: Icons.delete,
              cupertinoIcon: CupertinoIcons.delete,
            ),
          ),
        ],
      ),
    );
  }
}
