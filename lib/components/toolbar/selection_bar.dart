import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

class SelectionBar extends StatelessWidget {
  final VoidCallback copySelection;
  final VoidCallback pasteSelection;
  final VoidCallback duplicateSelection;
  final VoidCallback deleteSelection;
  final bool cropPossible;
  final bool cropActive;
  final VoidCallback? toggleCrop;

  const SelectionBar({
    super.key,
    required this.copySelection,
    required this.pasteSelection,
    required this.duplicateSelection,
    required this.deleteSelection,
    this.cropPossible = false,
    this.cropActive = false,
    this.toggleCrop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
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
                  ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: const CircleBorder(),
            ),
            tooltip: stows.selectionRectMode.value ? 'Rect Select' : 'Lasso Select',
            icon: Icon(
              stows.selectionRectMode.value ? Icons.crop_square : Icons.gesture,
            ),
          ),
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
            tooltip: cropActive ? 'Done cropping' : 'Crop image',
            icon: Icon(
              cropActive ? Icons.check : Icons.crop,
              color: cropActive
                  ? ColorScheme.of(context).primary
                  : null,
            ),
          ),
        IconButton(
          onPressed: copySelection,
          style: TextButton.styleFrom(
            foregroundColor: ColorScheme.of(context).secondary,
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(),
          ),
          tooltip: t.editor.selectionBar.duplicate,
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
          tooltip: 'Paste',
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
    );
  }
}
