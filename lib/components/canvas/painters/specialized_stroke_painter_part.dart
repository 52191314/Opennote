/// 🤖 Generated wholely or partially with Google Antigravity
part of '../_canvas_painter.dart';

extension _SpecializedStrokePainter on CanvasPainter {
  void _drawTapeStroke(Canvas canvas, TapeStroke stroke) {
    final baseColor = stroke.color.withInversion(invert);
    final rrect = RRect.fromRectAndRadius(
      stroke.rect,
      const Radius.circular(5),
    );

    if (stroke.isConcealed) {
      final fillPaint = Paint()
        ..color = baseColor.withValues(alpha: 0.96)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      switch (stroke.pattern) {
        case TapePattern.stripes:
          canvas.save();
          canvas.clipRRect(rrect);
          final stripePaint = Paint()
            ..color = Color.lerp(
              baseColor,
              Colors.black,
              0.15,
            )!.withValues(alpha: 0.4)
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke;
          final rect = stroke.rect;
          const step = 10.0;
          for (
            double x = rect.left - rect.height;
            x < rect.right + rect.height;
            x += step
          ) {
            canvas.drawLine(
              Offset(x, rect.bottom),
              Offset(x + rect.height, rect.top),
              stripePaint,
            );
          }
          canvas.restore();
        case TapePattern.dots:
          canvas.save();
          canvas.clipRRect(rrect);
          final dotPaint = Paint()
            ..color = Color.lerp(
              baseColor,
              Colors.black,
              0.18,
            )!.withValues(alpha: 0.5)
            ..style = PaintingStyle.fill;
          final rect = stroke.rect;
          const spacing = 8.0;
          for (double x = rect.left + 4; x < rect.right; x += spacing) {
            for (double y = rect.top + 4; y < rect.bottom; y += spacing) {
              canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
            }
          }
          canvas.restore();
        case TapePattern.grid:
          canvas.save();
          canvas.clipRRect(rrect);
          final gridPaint = Paint()
            ..color = Color.lerp(
              baseColor,
              Colors.black,
              0.15,
            )!.withValues(alpha: 0.35)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;
          final rect = stroke.rect;
          const spacing = 8.0;
          for (double x = rect.left + spacing; x < rect.right; x += spacing) {
            canvas.drawLine(
              Offset(x, rect.top),
              Offset(x, rect.bottom),
              gridPaint,
            );
          }
          for (double y = rect.top + spacing; y < rect.bottom; y += spacing) {
            canvas.drawLine(
              Offset(rect.left, y),
              Offset(rect.right, y),
              gridPaint,
            );
          }
          canvas.restore();
        case TapePattern.solid:
          break;
      }

      final borderPaint = Paint()
        ..color = Color.lerp(
          baseColor,
          Colors.black,
          0.15,
        )!.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRRect(rrect, borderPaint);
    } else {
      final fillPaint = Paint()
        ..color = baseColor.withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      final dashedPath = dashPath(
        Path()..addRRect(rrect),
        dashArray: CircularIntervalList<double>([6, 4]),
      );
      final borderPaint = Paint()
        ..color = baseColor.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawPath(dashedPath, borderPaint);
    }
  }

  void _drawDimensionText(Canvas canvas, DimensionStroke stroke) {
    if (stroke.text.isEmpty) return;

    final textColor = stroke.color.withInversion(invert);
    final textSpan = TextSpan(
      text: stroke.text,
      style: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final center = stroke.textPosition;
    final pillRect = Rect.fromCenter(
      center: center,
      width: textPainter.width + 12,
      height: textPainter.height + 6,
    );
    final pillRRect = RRect.fromRectAndRadius(
      pillRect,
      const Radius.circular(4),
    );

    final pillBg = invert ? Colors.black : Colors.white;
    canvas.drawRRect(
      pillRRect,
      Paint()
        ..color = pillBg.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      pillRRect,
      Paint()
        ..color = textColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawDetectedShape(Canvas canvas) {
    final shape = ShapePen.detectedShape;
    if (shape == null) return;

    final color = currentStroke?.color.withInversion(invert) ?? Colors.black;
    final shapePaint = Paint()
      ..color = Color.lerp(color, primaryColor, 0.5)!.withValues(alpha: 0.7)
      ..style = .stroke
      ..strokeWidth = currentStroke?.options.size ?? 3;

    switch (shape.name) {
      case null:
        break;
      case DefaultUnistrokeNames.line:
        var (firstPoint, lastPoint) = shape.convertToLine();
        (firstPoint, lastPoint) = Stroke.snapLine(
          firstPoint is PointVector
              ? firstPoint
              : PointVector.fromOffset(offset: firstPoint),
          lastPoint is PointVector
              ? lastPoint
              : PointVector.fromOffset(offset: lastPoint),
        );
        canvas.drawLine(firstPoint, lastPoint, shapePaint);
      case DefaultUnistrokeNames.rectangle:
        final rect = shape.convertToRect();
        canvas.drawRect(rect, shapePaint);
      case DefaultUnistrokeNames.circle:
        final (center, radius) = shape.convertToCircle();
        canvas.drawCircle(center, radius, shapePaint);
      case DefaultUnistrokeNames.triangle:
      case DefaultUnistrokeNames.star:
        final polygon = shape.convertToCanonicalPolygon();
        canvas.drawPath(Path()..addPolygon(polygon, true), shapePaint);
    }
  }

  void _drawStyledStroke(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.isEmpty) return;
    final centerPath = stroke.centerlinePath;
    final strokeWidth = stroke.options.size;
    final isDotted = stroke.lineStyle == LineStyle.dotted;
    final dashArray = isDotted
        ? CircularIntervalList<double>([1.0, strokeWidth * 1.8])
        : CircularIntervalList<double>([strokeWidth * 3.0, strokeWidth * 1.8]);

    final styledPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dashedPath = dashPath(centerPath, dashArray: dashArray);
    canvas.drawPath(dashedPath, styledPaint);
  }
}
