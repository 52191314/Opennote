/// 🤖 Generated wholely or partially with Grok 4.7
library;

import 'package:flutter/material.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pen_tray.dart';
import 'package:saber/i18n/strings.g.dart';

/// The saved pens for the current writing pen.
class PenTrayBar extends StatelessWidget {
  const PenTrayBar({super.key, required this.pen, required this.onSelected});

  /// The pen already in use. Tapping a slot changes this same pen.
  final Pen pen;

  /// Called after a slot is applied so the toolbar can redraw.
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final presets = PenTray.presets;
    final selected = PenTray.selectedIndex;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < presets.length; index++)
          _PenNib(
            key: ValueKey('pen-tray-$index'),
            color: Color(presets[index].color),
            thickness: presets[index].size,
            selected: index == selected,
            tooltip: '${t.editor.pens.savedPen} ${index + 1}',
            onTap: () {
              PenTray.select(index, pen);
              onSelected();
            },
          ),
      ],
    );
  }
}

class _PenNib extends StatelessWidget {
  const _PenNib({
    super.key,
    required this.color,
    required this.thickness,
    required this.selected,
    required this.tooltip,
    required this.onTap,
  });

  final Color color;
  final double thickness;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nib = (6 + thickness).clamp(8.0, 16.0);
    final scheme = ColorScheme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Container(
            width: nib * 0.42,
            height: nib,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
