/// 🤖 Generated wholely or partially with Google Antigravity
part of '../_canvas_painter.dart';

extension _StrokePainter on CanvasPainter {
  void _drawHighlighterStrokes(
    Canvas canvas,
    Rect? canvasRect,
    Rect? cullRect,
    List<Stroke> strokes,
  ) {
    final layerPaint = Paint()
      ..blendMode = invert ? BlendMode.lighten : BlendMode.darken
      ..color = Colors.white.withAlpha(Highlighter.alpha);
    final strokePaint = Paint();
    final layerBounds = canvasRect ?? cullRect;
    bool needToRestoreCanvasLayer = false;

    Color? lastColor;
    for (final stroke in strokes) {
      if (stroke.toolId != .highlighter) continue;
      if (cullRect != null &&
          !stroke.boundingBox
              .inflate(stroke.options.size * 2)
              .overlaps(cullRect)) {
        continue;
      }

      final color = stroke.color.withValues(alpha: 1).withInversion(invert);

      if (color != lastColor) {
        // new layer for each color
        if (needToRestoreCanvasLayer) canvas.restore();
        canvas.saveLayer(layerBounds, layerPaint);

        needToRestoreCanvasLayer = true;
        lastColor = color;
      }

      strokePaint.color = color;
      canvas.drawPath(_selectPath(stroke), strokePaint);
    }

    if (needToRestoreCanvasLayer) canvas.restore();
  }

  void _drawNonHighlighterStrokes(
    Canvas canvas,
    Rect? cullRect,
    List<Stroke> strokes,
  ) {
    final paint = Paint();
    final shapePaint = Paint()..style = PaintingStyle.stroke;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    for (final stroke in strokes) {
      if (stroke.toolId == .highlighter) continue;
      if (cullRect != null &&
          !stroke.boundingBox
              .inflate(stroke.options.size * 2)
              .overlaps(cullRect)) {
        continue;
      }

      var color = stroke.color.withInversion(invert);
      if (currentSelection?.strokes.contains(stroke) ?? false) {
        color = Color.lerp(color, primaryColor, 0.5)!;
      }

      paint.color = color;
      paint.shader = null;
      paint.maskFilter = null;
      if (stroke.toolId == .pencil) {
        if (shouldUsePencilShader(stroke.options.size)) {
          paint.color = Colors.white;
          paint.shader = page.pencilShader
            ..setFloat(0, color.r)
            ..setFloat(1, color.g)
            ..setFloat(2, color.b);
          paint.maskFilter = CanvasPainter._getPencilMaskFilter(
            stroke.options.size,
          );
        } else {
          // Fast imitation of pencil when zoomed out
          final background = invert ? Colors.black : Colors.white;
          paint.color = Color.lerp(background, color, 0.6)!;
        }
      }

      if (stroke is CircleStroke) {
        if (stroke.fillColor != null) {
          fillPaint.color = stroke.fillColor!.withInversion(invert);
          canvas.drawCircle(stroke.center, stroke.radius, fillPaint);
        }
        shapePaint
          ..color = paint.color
          ..strokeWidth = stroke.options.size;
        canvas.drawCircle(stroke.center, stroke.radius, shapePaint);
      } else if (stroke is RectangleStroke) {
        final strokeSize = stroke.options.size;
        final rrect = RRect.fromRectAndRadius(
          stroke.rect,
          Radius.circular(strokeSize / 4),
        );
        if (stroke.fillColor != null) {
          fillPaint.color = stroke.fillColor!.withInversion(invert);
          canvas.drawRRect(rrect, fillPaint);
        }
        shapePaint
          ..color = paint.color
          ..strokeWidth = strokeSize;
        canvas.drawRRect(rrect, shapePaint);
      } else if (stroke is ArrowStroke) {
        shapePaint
          ..color = paint.color
          ..strokeWidth = stroke.options.size;
        canvas.drawPath(stroke.highQualityPath, shapePaint);
      } else if (stroke is DimensionStroke) {
        shapePaint
          ..color = paint.color
          ..strokeWidth = stroke.options.size;
        canvas.drawPath(stroke.highQualityPath, shapePaint);
        _drawDimensionText(canvas, stroke);
      } else if (stroke is PolygonStroke) {
        final path = stroke.highQualityPath;
        if (stroke.fillColor != null) {
          fillPaint.color = stroke.fillColor!.withInversion(invert);
          canvas.drawPath(path, fillPaint);
        }
        shapePaint
          ..color = paint.color
          ..strokeWidth = stroke.options.size;
        canvas.drawPath(path, shapePaint);
      } else if (stroke is TapeStroke) {
        _drawTapeStroke(canvas, stroke);
      } else if (stroke.lineStyle != LineStyle.solid) {
        _drawStyledStroke(canvas, stroke, paint);
      } else {
        canvas.drawPath(_selectPath(stroke), paint);
      }
    }
  }

  void _drawCurrentStroke(Canvas canvas) {
    if (currentStroke == null) return;

    if (currentStroke! is LaserStroke) {
      return _drawLaserStroke(canvas, currentStroke as LaserStroke);
    }

    final color = currentStroke!.color.withInversion(invert);
    final paint = Paint()..color = color;

    if (currentStroke!.toolId == .pencil) {
      paint.color = Colors.white;
      paint.shader = page.pencilShader
        ..setFloat(0, color.r)
        ..setFloat(1, color.g)
        ..setFloat(2, color.b);
      paint.maskFilter = CanvasPainter._getPencilMaskFilter(
        currentStroke!.options.size,
      );
    }

    if (currentStroke is ArrowStroke || currentStroke is DimensionStroke) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = currentStroke!.options.size;
    }

    // Current stroke always uses high quality
    if (currentStroke!.lineStyle != LineStyle.solid) {
      _drawStyledStroke(canvas, currentStroke!, paint);
    } else {
      canvas.drawPath(currentStroke!.highQualityPath, paint);
    }

    if (currentStroke is DimensionStroke) {
      _drawDimensionText(canvas, currentStroke as DimensionStroke);
    }
  }

  void _drawLaserStroke(Canvas canvas, LaserStroke stroke) {
    canvas.drawPath(
      _selectPath(stroke),
      Paint()
        ..color = stroke.color.withInversion(invert)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.solid,
          stroke.options.size * 0.4,
        ),
    );
    canvas.drawPath(stroke.innerPath, Paint()..color = const Color(0xDDffffff));
  }
}
