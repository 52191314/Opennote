/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/theming/adaptive_switch_list_tile.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/i18n/strings.g.dart';
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
      final activeCount =
          (stows.lassoSelectHandwriting.value ? 1 : 0) +
          (stows.lassoSelectImages.value ? 1 : 0) +
          (stows.lassoSelectText.value ? 1 : 0) +
          (stows.lassoSelectTape.value ? 1 : 0);
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
        child: SingleChildScrollView(
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
                    t.editor.lasso.options,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                t.editor.lasso.typeHeading,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text(t.editor.lasso.freehand),
                    icon: const Icon(CupertinoIcons.lasso, size: 16),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text(t.editor.lasso.rectangular),
                    icon: const Icon(Icons.crop_square_rounded, size: 16),
                  ),
                ],
                selected: {stows.selectionRectMode.value},
                onSelectionChanged: (selected) {
                  if (selected.isNotEmpty) {
                    setState(() {
                      stows.selectionRectMode.value = selected.first;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Text(
                t.editor.lasso.includedHeading,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              AdaptiveSwitchListTile(
                secondary: const Icon(Icons.gesture),
                title: Text(t.editor.lasso.handwriting),
                subtitle: Text(t.editor.lasso.handwritingDescription),
                value: stows.lassoSelectHandwriting.value,
                onChanged: (val) => _toggle(stows.lassoSelectHandwriting, val),
                contentPadding: EdgeInsets.zero,
              ),
              AdaptiveSwitchListTile(
                secondary: const Icon(Icons.image_outlined),
                title: Text(t.editor.lasso.images),
                subtitle: Text(t.editor.lasso.imagesDescription),
                value: stows.lassoSelectImages.value,
                onChanged: (val) => _toggle(stows.lassoSelectImages, val),
                contentPadding: EdgeInsets.zero,
              ),
              AdaptiveSwitchListTile(
                secondary: const Icon(Icons.title),
                title: Text(t.editor.lasso.textBoxes),
                subtitle: Text(t.editor.lasso.textBoxesDescription),
                value: stows.lassoSelectText.value,
                onChanged: (val) => _toggle(stows.lassoSelectText, val),
                contentPadding: EdgeInsets.zero,
              ),
              AdaptiveSwitchListTile(
                secondary: const Icon(Icons.view_headline_rounded),
                title: Text(t.editor.tape.title),
                subtitle: Text(t.editor.lasso.tapeDescription),
                value: stows.lassoSelectTape.value,
                onChanged: (val) => _toggle(stows.lassoSelectTape, val),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
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
