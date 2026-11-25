/// 🤖 Generated wholely or partially with Google Antigravity
part of '../_canvas_painter.dart';

typedef _DashPathCacheKey = (
  int pathIdentity,
  Rect bounds,
  double quantizedInvScale,
  double dashOn,
  double dashOff,
);

final Map<_DashPathCacheKey, Path> _dashPathCache = {};
const _dashPathCacheMaxEntries = 8;

double _quantizeSelectionInvScale(double invScale) =>
    (invScale * 4).round() / 4.0;

Path _getCachedDashPath({
  required int pathIdentity,
  required Rect bounds,
  required Path Function() buildSourcePath,
  required double invScale,
  required double dashOn,
  required double dashOff,
}) {
  final qScale = _quantizeSelectionInvScale(invScale);
  final key = (pathIdentity, bounds, qScale, dashOn, dashOff);
  final cached = _dashPathCache[key];
  if (cached != null) {
    _dashPathCache.remove(key);
    _dashPathCache[key] = cached;
    return cached;
  }

  if (_dashPathCache.length >= _dashPathCacheMaxEntries) {
    _dashPathCache.remove(_dashPathCache.keys.first);
  }
  final dashed = dashPath(
    buildSourcePath(),
    dashArray: CircularIntervalList([dashOn * qScale, dashOff * qScale]),
  );
  _dashPathCache[key] = dashed;
  return dashed;
}

extension _SelectionPainter on CanvasPainter {
  double get _invSelectionScale =>
      (currentScale.isFinite && currentScale > 0 && currentScale < 1.0)
      ? 1.0 / currentScale.clamp(0.02, 1.0)
      : 1.0;

  void _drawSelection(Canvas canvas) {
    if (currentSelection == null) return;
    if (isDoneSelecting && currentSelection!.isEmpty) {
      page.selectionDeleteButtonRect = null;
      page.selectionRotationHandleCenter = null;
      page.selectionResizeHandles = null;
      page.selectionVertexHandles = null;
      return;
    }

    final invScale = _invSelectionScale;

    if (!isDoneSelecting) {
      page.selectionDeleteButtonRect = null;
      page.selectionRotationHandleCenter = null;
      page.selectionResizeHandles = null;
      page.selectionVertexHandles = null;

      canvas.drawPath(
        currentSelection!.path,
        Paint()..color = primaryColor.withValues(alpha: 0.04),
      );

      canvas.drawPath(
        dashPath(
          currentSelection!.path,
          dashArray: CircularIntervalList([6 * invScale, 4 * invScale]),
        ),
        Paint()
          ..color = primaryColor.withValues(alpha: 0.85)
          ..strokeWidth = 1.4 * invScale
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    final bounds = currentSelection!.path.getBounds();
    if (bounds.isEmpty) return;

    page.selectionDeleteButtonRect = null;

    final isTransformActive = Select.currentSelect.isResizeActive;
    if (!isTransformActive) {
      page.selectionRotationHandleCenter = null;
      page.selectionResizeHandles = null;

      canvas.drawPath(
        currentSelection!.path,
        Paint()..color = primaryColor.withValues(alpha: 0.04),
      );

      canvas.drawPath(
        _getCachedDashPath(
          pathIdentity: identityHashCode(currentSelection!.path),
          bounds: bounds,
          buildSourcePath: () => currentSelection!.path,
          invScale: invScale,
          dashOn: 6,
          dashOff: 4,
        ),
        Paint()
          ..color = primaryColor.withValues(alpha: 0.85)
          ..strokeWidth = 1.4 * invScale
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      final singleStroke = currentSelection!.strokes.length == 1
          ? currentSelection!.strokes.first
          : null;
      if (singleStroke is ArrowStroke) {
        final vHandles = [singleStroke.start, singleStroke.end];
        page.selectionVertexHandles = vHandles;
        _drawVertexHandles(canvas, vHandles);
      } else if (singleStroke is DimensionStroke) {
        final vHandles = [
          singleStroke.start,
          singleStroke.end,
          singleStroke.textPosition,
        ];
        page.selectionVertexHandles = vHandles;
        _drawVertexHandles(canvas, vHandles);
      } else {
        page.selectionVertexHandles = null;
      }
      return;
    }

    final padded = bounds.inflate(6.0);
    final center = padded.center;
    final rrect = RRect.fromRectAndRadius(padded, const Radius.circular(8));

    canvas.drawRRect(
      rrect,
      Paint()..color = primaryColor.withValues(alpha: 0.035),
    );

    canvas.drawPath(
      _getCachedDashPath(
        pathIdentity: 0,
        bounds: padded,
        buildSourcePath: () => Path()..addRRect(rrect),
        invScale: invScale,
        dashOn: 6,
        dashOff: 4,
      ),
      Paint()
        ..color = primaryColor.withValues(alpha: 0.75)
        ..strokeWidth = 1.3 * invScale
        ..style = PaintingStyle.stroke,
    );

    canvas.drawPath(
      _getCachedDashPath(
        pathIdentity: identityHashCode(currentSelection!.path),
        bounds: bounds,
        buildSourcePath: () => currentSelection!.path,
        invScale: invScale,
        dashOn: 4,
        dashOff: 4,
      ),
      Paint()
        ..color = primaryColor.withValues(alpha: 0.25)
        ..strokeWidth = 1.0 * invScale
        ..style = PaintingStyle.stroke,
    );

    final rotationHandleCenter = Offset(
      center.dx,
      padded.top - CanvasPainter.rotationHandleOffset,
    );
    page.selectionRotationHandleCenter = rotationHandleCenter;

    canvas.drawLine(
      Offset(center.dx, padded.top),
      rotationHandleCenter,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.45)
        ..strokeWidth = 1.0,
    );

    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.16);
    final knobFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final knobBorderPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      rotationHandleCenter + const Offset(0, 1),
      CanvasPainter.rotationHandleRadius + 0.5,
      shadowPaint,
    );
    canvas.drawCircle(
      rotationHandleCenter,
      CanvasPainter.rotationHandleRadius,
      knobFillPaint,
    );
    canvas.drawCircle(
      rotationHandleCenter,
      CanvasPainter.rotationHandleRadius,
      knobBorderPaint,
    );

    final arrowPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: rotationHandleCenter, width: 8, height: 8),
      -0.8,
      2.2,
      false,
      arrowPaint,
    );

    final cornerPositions = <Offset>[
      padded.topLeft,
      padded.topRight,
      padded.bottomRight,
      padded.bottomLeft,
    ];

    knobBorderPaint.strokeWidth = 1.5;
    for (final pos in cornerPositions) {
      canvas.drawCircle(
        pos + const Offset(0, 1),
        CanvasPainter.resizeHandleRadius + 0.5,
        shadowPaint,
      );
      canvas.drawCircle(pos, CanvasPainter.resizeHandleRadius, knobFillPaint);
      canvas.drawCircle(pos, CanvasPainter.resizeHandleRadius, knobBorderPaint);
    }

    page.selectionResizeHandles = [
      padded.topLeft, // 0: topLeft
      Offset(center.dx, padded.top), // 1: topCenter
      padded.topRight, // 2: topRight
      Offset(padded.right, center.dy), // 3: middleRight
      padded.bottomRight, // 4: bottomRight
      Offset(center.dx, padded.bottom), // 5: bottomCenter
      padded.bottomLeft, // 6: bottomLeft
      Offset(padded.left, center.dy), // 7: middleLeft
    ];

    final singleStroke = currentSelection!.strokes.length == 1
        ? currentSelection!.strokes.first
        : null;
    if (singleStroke is ArrowStroke) {
      final vHandles = [singleStroke.start, singleStroke.end];
      page.selectionVertexHandles = vHandles;
      _drawVertexHandles(canvas, vHandles);
    } else if (singleStroke is DimensionStroke) {
      final vHandles = [
        singleStroke.start,
        singleStroke.end,
        singleStroke.textPosition,
      ];
      page.selectionVertexHandles = vHandles;
      _drawVertexHandles(canvas, vHandles);
    } else {
      page.selectionVertexHandles = null;
    }
  }

  void _drawVertexHandles(Canvas canvas, List<Offset> handles) {
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final handleBorderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final pos in handles) {
      canvas.drawCircle(pos, 6, handlePaint);
      canvas.drawCircle(pos, 6, handleBorderPaint);
    }
  }
}
