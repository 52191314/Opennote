/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/i18n/strings.g.dart';

class Highlighter extends Pen {
  Highlighter()
      : super(
          name: t.editor.pens.highlighter,
          sizeMin: 10,
          sizeMax: 100,
          sizeStep: 10,
          icon: highlighterIcon,
          options: stows.lastHighlighterOptions.value,
          pressureEnabled: false,
          color: Colors.yellow.withAlpha(Highlighter.alpha),
          toolId: .highlighter,
        );

  static const alpha = 100;

  static Pen currentHighlighter = Highlighter();

  static const highlighterIcon = FontAwesomeIcons.highlighter;

  Offset? _dragStart;

  @override
  void onDragStart(
    Offset position,
    EditorPage page,
    int pageIndex,
    double? pressure,
  ) {
    _dragStart = position;
    super.onDragStart(position, page, pageIndex, pressure);
  }

  @override
  void onDragUpdate(Offset position, double? pressure) {
    if (!stows.highlighterDrawInStraightLine.value ||
        _dragStart == null ||
        Pen.currentStroke == null) {
      super.onDragUpdate(position, pressure);
      return;
    }

    final start = _dragStart!;
    final dx = position.dx - start.dx;
    final dy = position.dy - start.dy;

    final Offset target;
    if (dx.abs() > dy.abs() * 1.4) {
      // Horizontal straight line
      target = Offset(position.dx, start.dy);
    } else if (dy.abs() > dx.abs() * 1.4) {
      // Vertical straight line
      target = Offset(start.dx, position.dy);
    } else {
      // Direct diagonal line
      target = position;
    }

    Pen.currentStroke!.setStraightLine(start, target);
  }

  @override
  Stroke? onDragEnd() {
    _dragStart = null;
    return super.onDragEnd();
  }
}
