/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/theming/adaptive_switch_list_tile.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';
import 'package:stow_plain/stow_plain.dart';

/// A popup dialog allowing users to toggle lasso selection filters
/// for handwriting, images/PDFs, and text boxes.
class LassoFilterPopup extends StatefulWidget {
  const LassoFilterPopup({super.key});

  @override
  State<LassoFilterPopup> createState() => _LassoFilterPopupState();
}

class _LassoFilterPopupState extends State<LassoFilterPopup> {
  void _toggle(PlainStow<bool> stow, bool value) {
    if (!value) {
      final activeCount = (stows.lassoSelectHandwriting.value ? 1 : 0) +
          (stows.lassoSelectImages.value ? 1 : 0) +
          (stows.lassoSelectText.value ? 1 : 0);
      if (activeCount <= 1) return;
    }
    setState(() {
      stow.value = value;
    });
    Select.currentSelect.pruneDisabledFilters();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.lasso,
                  size: 22,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Lasso Options',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AdaptiveSwitchListTile(
              secondary: const Icon(Icons.gesture),
              title: const Text('Handwriting'),
              subtitle: const Text('Pen, pencil, and highlighter strokes'),
              value: stows.lassoSelectHandwriting.value,
              onChanged: (val) => _toggle(stows.lassoSelectHandwriting, val),
              contentPadding: EdgeInsets.zero,
            ),
            AdaptiveSwitchListTile(
              secondary: const Icon(Icons.image_outlined),
              title: const Text('Images'),
              subtitle: const Text('Photos, stickers, and PDFs'),
              value: stows.lassoSelectImages.value,
              onChanged: (val) => _toggle(stows.lassoSelectImages, val),
              contentPadding: EdgeInsets.zero,
            ),
            AdaptiveSwitchListTile(
              secondary: const Icon(Icons.title),
              title: const Text('Text Boxes'),
              subtitle: const Text('Typed notes and text boxes'),
              value: stows.lassoSelectText.value,
              onChanged: (val) => _toggle(stows.lassoSelectText, val),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}
