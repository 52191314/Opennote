/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:sbn/canvas_background_pattern.dart';

/// A tool that draws a perfectly straight line between two points.
///
/// Unlike [Pen] which records freehand points, this tool only records
/// the start and end points and draws a straight line between them.
/// Optionally snaps to the nearest angle if [snapToAngle] is enabled.
class Ruler extends Pen {
  Ruler()
    : super(
        name: 'Ruler',
        sizeMin: 1,
        sizeMax: 25,
        sizeStep: 1,
        icon: rulerIcon,
        options: stows.lastBallpointPenOptions.value,
        pressureEnabled: false,
        color: Color(stows.lastBallpointPenColor.value),
        toolId: .ruler,
      );

  static const rulerIcon = FontAwesomeIcons.ruler;

  Offset? _dragStart;
  EditorPage? _activePage;

  Offset _snapPoint(Offset position, EditorPage? page) {
    if (!stows.snapToGrid.value) return position;

    final lh = (page?.lineHeight ?? 0) > 0
        ? page!.lineHeight!.toDouble()
        : stows.gridSize.value;
    if (lh <= 0) return position;

    if (page?.backgroundPattern == CanvasBackgroundPattern.isometric) {
      return Stroke.snapPointToIsometricGrid(position, lh);
    } else {
      return Stroke.snapPointToGrid(position, lh);
    }
  }

  @override
  void onDragStart(
    Offset position,
    EditorPage page,
    int pageIndex,
    double? pressure,
  ) {
    _activePage = page;
    _dragStart = _snapPoint(position, page);
    super.onDragStart(_dragStart!, page, pageIndex, pressure);
    super.onDragUpdate(_dragStart!, pressure);
  }

  @override
  void onDragUpdate(Offset position, double? pressure) {
    if (_dragStart == null) return;

    var snappedEnd = _snapPoint(position, _activePage);

    final isIso =
        _activePage?.backgroundPattern == CanvasBackgroundPattern.isometric ||
        stows.snapAngleStep.value == -30;

    if (stows.snapToAngle.value && (stows.snapAngleStep.value > 0 || isIso)) {
      final first = PointVector.fromOffset(offset: _dragStart!);
      final last = PointVector.fromOffset(offset: snappedEnd);
      final (_, snappedLast) = Stroke.snapLineToAngle(
        first,
        last,
        stows.snapAngleStep.value.toDouble(),
        isIsometric: isIso,
      );
      snappedEnd = Offset(snappedLast.dx, snappedLast.dy);
    }

    // Replace stroke points by rebuilding: pop first, add new point
    if (Pen.currentStroke != null) {
      while (Pen.currentStroke!.length > 0) {
        Pen.currentStroke!.popFirstPoint();
      }
      Pen.currentStroke!.addPoint(_dragStart!);
      Pen.currentStroke!.addPoint(snappedEnd);
    }
  }

  @override
  Stroke? onDragEnd() {
    final stroke = Pen.currentStroke;
    Pen.currentStroke = null;
    _dragStart = null;
    _activePage = null;
    if (stroke == null) return null;

    return stroke
      ..options.isComplete = true
      ..options.start.taperEnabled = false
      ..options.end.taperEnabled = false
      ..markPolygonNeedsUpdating();
  }
}
