/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:sbn/canvas_background_pattern.dart';

/// A tool that constructs and places a [DimensionStroke] between two points
/// with a live Euclidean distance label.
class DimensionTool extends Pen {
  DimensionTool({this.defaultOffset = 30.0})
    : super(
        name: 'Dimension',
        sizeMin: 1,
        sizeMax: 25,
        sizeStep: 1,
        icon: dimensionIcon,
        options: stows.lastBallpointPenOptions.value,
        pressureEnabled: false,
        color: Color(stows.lastBallpointPenColor.value),
        toolId: .dimension,
      );

  static const dimensionIcon = Icons.straighten;
  final double defaultOffset;

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
    Pen.currentStroke = DimensionStroke(
      color: color,
      pressureEnabled: false,
      options: options.copyWith(isComplete: false),
      pageIndex: pageIndex,
      page: page,
      toolId: toolId,
      start: _dragStart!,
      end: _dragStart!,
      offset: defaultOffset,
      text: '0.0 px',
    );
  }

  @override
  void onDragUpdate(Offset position, double? pressure) {
    if (_dragStart == null || Pen.currentStroke is! DimensionStroke) return;

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

    final dim = Pen.currentStroke as DimensionStroke;
    dim.end = snappedEnd;
    final distance = (dim.end - dim.start).distance;
    dim.text = '${distance.toStringAsFixed(1)} px';
    dim.markPolygonNeedsUpdating();
  }

  @override
  Stroke? onDragEnd() {
    final stroke = Pen.currentStroke;
    Pen.currentStroke = null;
    _dragStart = null;
    _activePage = null;
    if (stroke is! DimensionStroke) return null;
    if (stroke.start == stroke.end) return null;

    final distance = (stroke.end - stroke.start).distance;
    stroke.text = '${distance.toStringAsFixed(1)} px';

    return stroke
      ..options.isComplete = true
      ..markPolygonNeedsUpdating();
  }
}
