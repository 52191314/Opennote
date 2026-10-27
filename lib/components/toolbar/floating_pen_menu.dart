/// 🤖 Generated wholely or partially with Grok 4.7
library;

import 'package:flutter/material.dart';
import 'package:saber/components/toolbar/pen_tray_bar.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/i18n/strings.g.dart';

/// Which edge the floating pen menu sits on.
enum PenMenuEdge { top, right, bottom, left }

/// Remembers the menu edge with the other editor preferences.
class PenMenuPlacement {
  static PenMenuEdge get edge {
    final name = stows.floatingPenMenuEdge.value;
    for (final edge in PenMenuEdge.values) {
      if (edge.name == name) return edge;
    }
    return PenMenuEdge.right;
  }

  static void place(PenMenuEdge edge) {
    stows.floatingPenMenuEdge.value = edge.name;
  }
}

/// The saved-pen menu, shown only while a writing pen is the current tool.
class WritingPenMenu extends StatelessWidget {
  const WritingPenMenu({
    super.key,
    required this.tool,
    required this.onChanged,
  });

  final Tool? tool;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final tool = this.tool;
    if (!Pen.isWritingPen(tool)) return const SizedBox.shrink();
    return FloatingPenMenu(pen: tool as Pen, onChanged: onChanged);
  }
}

/// A floating menu of the current pen's saved colors and thicknesses.
///
/// It can sit on any edge of the editor. The last edge is kept. Choosing a
/// pen changes [pen] in place.
class FloatingPenMenu extends StatefulWidget {
  const FloatingPenMenu({
    super.key,
    required this.pen,
    required this.onChanged,
  });

  final Pen pen;
  final VoidCallback onChanged;

  @override
  State<FloatingPenMenu> createState() => _FloatingPenMenuState();
}

class _FloatingPenMenuState extends State<FloatingPenMenu> {
  PenMenuEdge get _edge => PenMenuPlacement.edge;

  void _place(PenMenuEdge edge) {
    PenMenuPlacement.place(edge);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final edge = _edge;
    final vertical = edge == PenMenuEdge.left || edge == PenMenuEdge.right;
    final scheme = ColorScheme.of(context);
    return Align(
      alignment: switch (edge) {
        PenMenuEdge.top => Alignment.topCenter,
        PenMenuEdge.right => Alignment.centerRight,
        PenMenuEdge.bottom => Alignment.bottomCenter,
        PenMenuEdge.left => Alignment.centerLeft,
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Material(
          key: const ValueKey('pen-menu'),
          elevation: 6,
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Flex(
              direction: vertical ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final candidate in PenMenuEdge.values)
                  IconButton(
                    key: ValueKey('pen-menu-edge-${candidate.name}'),
                    tooltip: switch (candidate) {
                      PenMenuEdge.top => t.editor.penMenu.top,
                      PenMenuEdge.right => t.editor.penMenu.right,
                      PenMenuEdge.bottom => t.editor.penMenu.bottom,
                      PenMenuEdge.left => t.editor.penMenu.left,
                    },
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _place(candidate),
                    icon: Icon(
                      switch (candidate) {
                        PenMenuEdge.top => Icons.keyboard_arrow_up,
                        PenMenuEdge.right => Icons.keyboard_arrow_right,
                        PenMenuEdge.bottom => Icons.keyboard_arrow_down,
                        PenMenuEdge.left => Icons.keyboard_arrow_left,
                      },
                      size: 18,
                      color: candidate == edge ? scheme.primary : null,
                    ),
                  ),
                PenTrayBar(pen: widget.pen, onSelected: widget.onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
