/// 🤖 Generated wholely or partially with Google Antigravity
part of '../_canvas_painter.dart';

extension _StrokePainter on CanvasPainter {
  static const _pictureCacheTileStep = 256.0;

  static Rect _computeRecordedCullRect(Rect cullRect) {
    final padX = max(_pictureCacheTileStep, cullRect.width * 0.25);
    final padY = max(_pictureCacheTileStep, cullRect.height * 0.25);
    final left =
        ((cullRect.left - padX) / _pictureCacheTileStep).floorToDouble() *
        _pictureCacheTileStep;
    final top =
        ((cullRect.top - padY) / _pictureCacheTileStep).floorToDouble() *
        _pictureCacheTileStep;
    final right =
        ((cullRect.right + padX) / _pictureCacheTileStep).ceilToDouble() *
        _pictureCacheTileStep;
    final bottom =
        ((cullRect.bottom + padY) / _pictureCacheTileStep).ceilToDouble() *
        _pictureCacheTileStep;
    return Rect.fromLTRB(left, top, right, bottom);
  }

  static bool _rectContains(Rect outer, Rect inner) =>
      inner.left >= outer.left &&
      inner.top >= outer.top &&
      inner.right <= outer.right &&
      inner.bottom <= outer.bottom;

  void _paintWithPictureCache(
    Canvas canvas,
    Size size,
    Rect? canvasRect,
    Rect cullRect,
  ) {
    var strokesDigest = page.layers.length;
    var pencilShaderMask = 0;
    for (int i = 0; i < page.layers.length; i++) {
      final layer = page.layers[i];
      if (!layer.visible) {
        strokesDigest = 0x1fffffff & (strokesDigest * 31 + 17);
        continue;
      }
      final layerStrokes = layer.strokes;
      strokesDigest = 0x1fffffff & (strokesDigest * 31 + layerStrokes.length);
      for (int j = 0; j < layerStrokes.length; j++) {
        final s = layerStrokes[j];
        strokesDigest = 0x1fffffff & (strokesDigest * 31 + s.renderSignature);
        if (s.toolId == .pencil) {
          pencilShaderMask =
              0x1fffffff &
              (pencilShaderMask * 31 +
                  (shouldUsePencilShader(s.options.size) ? 2 : 1));
        }
      }
    }

    var selectionIdentity = 0;
    final selectedList = currentSelection?.strokes;
    if (selectedList != null && selectedList.isNotEmpty) {
      selectionIdentity = selectedList.length;
      for (int i = 0; i < selectedList.length; i++) {
        selectionIdentity =
            0x1fffffff &
            (selectionIdentity * 31 + identityHashCode(selectedList[i]));
      }
    }

    final isLowQuality = currentScale < CanvasPainter._zoomThreshold;
    final primaryColorValue = primaryColor.toARGB32();
    final existingKey = page.strokePictureCacheKey;
    final isCacheHit =
        existingKey != null &&
        existingKey.strokesDigest == strokesDigest &&
        existingKey.invert == invert &&
        existingKey.primaryColorValue == primaryColorValue &&
        existingKey.isLowQuality == isLowQuality &&
        existingKey.pencilShaderMask == pencilShaderMask &&
        existingKey.selectionIdentity == selectionIdentity &&
        existingKey.isInfiniteCanvas == isInfiniteCanvas &&
        existingKey.canvasSize == size &&
        _rectContains(existingKey.recordedCullRect, cullRect);

    if (!isCacheHit) {
      page.invalidateStrokePictureCache();
      final recordedCullRect = _computeRecordedCullRect(cullRect);
      final strokes = page.strokes;

      var hasVisibleHighlighters = false;
      var hasVisibleNonHighlighters = false;
      for (int i = 0; i < strokes.length; i++) {
        final s = strokes[i];
        if (!s.boundingBox
            .inflate(s.options.size * 2)
            .overlaps(recordedCullRect)) {
          continue;
        }
        if (s.toolId == .highlighter) {
          hasVisibleHighlighters = true;
        } else {
          hasVisibleNonHighlighters = true;
        }
        if (hasVisibleHighlighters && hasVisibleNonHighlighters) break;
      }

      if (hasVisibleHighlighters) {
        final hlRecorder = ui.PictureRecorder();
        final hlCanvas = Canvas(hlRecorder);
        _drawHighlighterStrokes(
          hlCanvas,
          canvasRect,
          recordedCullRect,
          strokes,
        );
        page.cachedHighlighterPicture = hlRecorder.endRecording();
      }

      if (hasVisibleNonHighlighters) {
        final nonHlRecorder = ui.PictureRecorder();
        final nonHlCanvas = Canvas(nonHlRecorder);
        _drawNonHighlighterStrokes(nonHlCanvas, recordedCullRect, strokes);
        page.cachedNonHighlighterPicture = nonHlRecorder.endRecording();
      }

      page.strokePictureCacheKey = (
        strokesDigest: strokesDigest,
        invert: invert,
        primaryColorValue: primaryColorValue,
        isLowQuality: isLowQuality,
        pencilShaderMask: pencilShaderMask,
        selectionIdentity: selectionIdentity,
        isInfiniteCanvas: isInfiniteCanvas,
        canvasSize: size,
        recordedCullRect: recordedCullRect,
      );
    }

    final highlighterPic = page.cachedHighlighterPicture;
    if (highlighterPic != null) canvas.drawPicture(highlighterPic);

    if (currentStroke?.toolId == .highlighter) {
      _drawCurrentStroke(canvas);
      final nonHighlighterPic = page.cachedNonHighlighterPicture;
      if (nonHighlighterPic != null) canvas.drawPicture(nonHighlighterPic);
    } else {
      final nonHighlighterPic = page.cachedNonHighlighterPicture;
      if (nonHighlighterPic != null) canvas.drawPicture(nonHighlighterPic);
      _drawCurrentStroke(canvas);
    }
  }

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

    int i = 0;
    while (i < strokes.length) {
      final first = strokes[i];
      if (first.toolId != .highlighter) {
        i++;
        continue;
      }
      final firstBounds = first.boundingBox.inflate(first.options.size * 2);
      if (cullRect != null && !firstBounds.overlaps(cullRect)) {
        i++;
        continue;
      }

      final runColor = first.color.withValues(alpha: 1).withInversion(invert);
      var tightBounds = firstBounds;
      int runEnd = i + 1;

      while (runEnd < strokes.length) {
        final next = strokes[runEnd];
        if (next.toolId != .highlighter) {
          runEnd++;
          continue;
        }
        final nextBounds = next.boundingBox.inflate(next.options.size * 2);
        if (cullRect != null && !nextBounds.overlaps(cullRect)) {
          runEnd++;
          continue;
        }
        final nextColor = next.color.withValues(alpha: 1).withInversion(invert);
        if (nextColor != runColor) break;
        tightBounds = tightBounds.expandToInclude(nextBounds);
        runEnd++;
      }

      if (canvasRect != null) {
        tightBounds = tightBounds.intersect(canvasRect);
      }
      if (cullRect != null) {
        tightBounds = tightBounds.intersect(cullRect);
      }

      if (!tightBounds.isEmpty) {
        canvas.saveLayer(tightBounds, layerPaint);
        strokePaint.color = runColor;
        for (int j = i; j < runEnd; j++) {
          final stroke = strokes[j];
          if (stroke.toolId != .highlighter) continue;
          if (cullRect != null &&
              !stroke.boundingBox
                  .inflate(stroke.options.size * 2)
                  .overlaps(cullRect)) {
            continue;
          }
          canvas.drawPath(_selectPath(stroke), strokePaint);
        }
        canvas.restore();
      }

      i = runEnd;
    }
  }

  void _drawNonHighlighterStrokes(
    Canvas canvas,
    Rect? cullRect,
    List<Stroke> strokes,
  ) {
    final paint = Paint();
    final shapePaint = Paint()..style = PaintingStyle.stroke;
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final selectedList = currentSelection?.strokes;
    final Set<Stroke>? selectedSet =
        selectedList != null && selectedList.length > 4
        ? (Set<Stroke>.identity()..addAll(selectedList))
        : null;

    final useSubPixelLod = currentScale >= 0.0005 && currentScale < 0.2;

    for (final stroke in strokes) {
      if (stroke.toolId == .highlighter) continue;
      final strokeBounds = stroke.boundingBox;
      if (cullRect != null &&
          !strokeBounds.inflate(stroke.options.size * 2).overlaps(cullRect)) {
        continue;
      }
      if (useSubPixelLod && strokeBounds.longestSide * currentScale < 0.6) {
        continue;
      }

      var color = stroke.color.withInversion(invert);
      final isSelected = selectedSet != null
          ? selectedSet.contains(stroke)
          : (selectedList?.contains(stroke) ?? false);
      if (isSelected) {
        color = Color.lerp(color, primaryColor, 0.5)!;
      }

      if (useSubPixelLod && strokeBounds.longestSide * currentScale < 2.5) {
        fillPaint.color = color;
        canvas.drawRect(strokeBounds, fillPaint);
        continue;
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
