/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:sbn/canvas_background_pattern.dart';

/// A tool that constructs and places an [ArrowStroke] between two points.
class ArrowTool extends Pen {
  ArrowTool({
    this.arrowheadStyle = ArrowheadStyle.single,
  }) : super(
          name: 'Arrow',
          sizeMin: 1,
          sizeMax: 25,
          sizeStep: 1,
          icon: arrowIcon,
          options: stows.lastBallpointPenOptions.value,
          pressureEnabled: false,
          color: Color(stows.lastBallpointPenColor.value),
          toolId: .arrow,
        );

  static const arrowIcon = Icons.arrow_right_alt;
  final ArrowheadStyle arrowheadStyle;

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
    Pen.currentStroke = ArrowStroke(
      color: color,
      pressureEnabled: false,
      options: options.copyWith(isComplete: false),
      pageIndex: pageIndex,
      page: page,
      toolId: toolId,
      start: _dragStart!,
      end: _dragStart!,
      arrowheadStyle: arrowheadStyle,
    );
  }

  @override
  void onDragUpdate(Offset position, double? pressure) {
    if (_dragStart == null || Pen.currentStroke is! ArrowStroke) return;

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

    final arrow = Pen.currentStroke as ArrowStroke;
    arrow.end = snappedEnd;
    arrow.markPolygonNeedsUpdating();
  }

  @override
  Stroke? onDragEnd() {
    final stroke = Pen.currentStroke;
    Pen.currentStroke = null;
    _dragStart = null;
    _activePage = null;
    if (stroke is! ArrowStroke) return null;
    if (stroke.start == stroke.end) return null;

    return stroke
      ..options.isComplete = true
      ..markPolygonNeedsUpdating();
  }
}
