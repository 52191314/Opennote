/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_circle_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_polygon_stroke.dart';
import 'package:saber/components/canvas/_rectangle_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/color_extensions.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/laser_pointer.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/shape_pen.dart';

class CanvasPainter extends CustomPainter {
  const CanvasPainter({
    super.repaint,
    this.invert = false,
    required this.strokes,
    required this.laserStrokes,
    required this.currentStroke,
    required this.currentSelection,
    this.isDoneSelecting = true,
    required this.primaryColor,
    required this.page,
    required this.showPageIndicator,
    required this.pageIndex,
    required this.totalPages,
    required this.currentScale,
    required this.defaultTextStyle,
    this.isInfiniteCanvas = false,
  });

  final bool invert;
  final List<Stroke> strokes;
  final List<LaserStroke> laserStrokes;
  final Stroke? currentStroke;
  final SelectResult? currentSelection;
  final bool isDoneSelecting;
  final Color primaryColor;
  final EditorPage page;
  final bool showPageIndicator;
  final int pageIndex;
  final int totalPages;
  final double currentScale;
  final TextStyle defaultTextStyle;
  final bool isInfiniteCanvas;

  @override
  void paint(Canvas canvas, Size size) {
    final canvasRect = isInfiniteCanvas ? null : (Offset.zero & size);

    _drawHighlighterStrokes(canvas, canvasRect);
    if (currentStroke?.toolId == .highlighter) {
      _drawCurrentStroke(canvas);
      _drawNonHighlighterStrokes(canvas);
    } else {
      _drawNonHighlighterStrokes(canvas);
      _drawCurrentStroke(canvas);
    }
    for (final stroke in laserStrokes) _drawLaserStroke(canvas, stroke);
    _drawDetectedShape(canvas);
    _drawPenPreview(canvas);
    _drawSelection(canvas);
    _drawEraserCursor(canvas);
    _drawLaserSpotlight(canvas);
    if (!isInfiniteCanvas) _drawPageIndicator(canvas, size);
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return false ||
        // Current stroke is being drawn, so always repaint if present
        (currentStroke != null || oldDelegate.currentStroke != null) ||
        // Laser strokes are always fading out, so always repaint if present
        (laserStrokes.isNotEmpty || oldDelegate.laserStrokes.isNotEmpty) ||
        // Laser spotlight active
        (page.laserSpotlightPosition != oldDelegate.page.laserSpotlightPosition) ||
        // Check for any other changes
        invert != oldDelegate.invert ||
        strokes.length != oldDelegate.strokes.length ||
        currentSelection != oldDelegate.currentSelection ||
        primaryColor != oldDelegate.primaryColor ||
        page != oldDelegate.page ||
        showPageIndicator != oldDelegate.showPageIndicator ||
        pageIndex != oldDelegate.pageIndex ||
        totalPages != oldDelegate.totalPages ||
        currentScale != oldDelegate.currentScale ||
        isInfiniteCanvas != oldDelegate.isInfiniteCanvas;
  }

  void _drawHighlighterStrokes(Canvas canvas, Rect? canvasRect) {
    final layerPaint = Paint()
      ..blendMode = invert ? BlendMode.lighten : BlendMode.darken
      ..color = Colors.white.withAlpha(Highlighter.alpha);
    bool needToRestoreCanvasLayer = false;

    Color? lastColor;
    for (final stroke in strokes) {
      if (stroke.toolId != .highlighter) continue;

      final color = stroke.color.withValues(alpha: 1).withInversion(invert);

      if (color != lastColor) {
        // new layer for each color
        if (needToRestoreCanvasLayer) canvas.restore();
        canvas.saveLayer(canvasRect, layerPaint);

        needToRestoreCanvasLayer = true;
        lastColor = color;
      }

      canvas.drawPath(_selectPath(stroke), Paint()..color = color);
    }

    if (needToRestoreCanvasLayer) canvas.restore();
  }

  void _drawNonHighlighterStrokes(Canvas canvas) {
    late final paint = Paint();

    for (final stroke in strokes) {
      if (stroke.toolId == .highlighter) continue;

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
          paint.maskFilter = _getPencilMaskFilter(stroke.options.size);
        } else {
          // Fast imitation of pencil when zoomed out
          final background = invert ? Colors.black : Colors.white;
          paint.color = Color.lerp(background, color, 0.6)!;
        }
      }

      late final shapePaint = Paint()
        ..color = paint.color
        ..style = .stroke
        ..strokeWidth = stroke.options.size;

      if (stroke is CircleStroke) {
        // Fill circle if fillColor is set
        if (stroke.fillColor != null) {
          canvas.drawCircle(
            stroke.center,
            stroke.radius,
            Paint()..color = stroke.fillColor!.withInversion(invert),
          );
        }
        canvas.drawCircle(stroke.center, stroke.radius, shapePaint);
      } else if (stroke is RectangleStroke) {
        final strokeSize = stroke.options.size;
        final rrect = RRect.fromRectAndRadius(
          stroke.rect,
          Radius.circular(strokeSize / 4),
        );
        // Fill rect if fillColor is set
        if (stroke.fillColor != null) {
          canvas.drawRRect(
            rrect,
            Paint()..color = stroke.fillColor!.withInversion(invert),
          );
        }
        canvas.drawRRect(rrect, shapePaint);
      } else if (stroke is ArrowStroke) {
        canvas.drawPath(
          stroke.getPath(stroke.getPolygon(quality: .high)),
          shapePaint,
        );
      } else if (stroke is DimensionStroke) {
        canvas.drawPath(
          stroke.getPath(stroke.getPolygon(quality: .high)),
          shapePaint,
        );
        _drawDimensionText(canvas, stroke);
      } else if (stroke is PolygonStroke) {
        final fillPaint = Paint()
          ..color = stroke.fillColor?.withInversion(invert) ?? paint.color
          ..style = stroke.fillColor != null ? .fill : .stroke;
        if (stroke.fillColor != null) {
          canvas.drawPath(
            stroke.getPath(stroke.getPolygon(quality: .high)),
            fillPaint,
          );
        }
        canvas.drawPath(
          stroke.getPath(stroke.getPolygon(quality: .high)),
          shapePaint,
        );
      } else if (stroke is TapeStroke) {
        _drawTapeStroke(canvas, stroke);
      } else if (stroke.lineStyle != LineStyle.solid) {
        _drawStyledStroke(canvas, stroke, paint);
      } else {
        canvas.drawPath(_selectPath(stroke), paint);
      }
    }
  }

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
            ..color = Color.lerp(baseColor, Colors.black, 0.15)!.withValues(alpha: 0.4)
            ..strokeWidth = 3.0
            ..style = PaintingStyle.stroke;
          final rect = stroke.rect;
          const step = 10.0;
          for (double x = rect.left - rect.height; x < rect.right + rect.height; x += step) {
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
            ..color = Color.lerp(baseColor, Colors.black, 0.18)!.withValues(alpha: 0.5)
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
            ..color = Color.lerp(baseColor, Colors.black, 0.15)!.withValues(alpha: 0.35)
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke;
          final rect = stroke.rect;
          const spacing = 8.0;
          for (double x = rect.left + spacing; x < rect.right; x += spacing) {
            canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridPaint);
          }
          for (double y = rect.top + spacing; y < rect.bottom; y += spacing) {
            canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);
          }
          canvas.restore();
        case TapePattern.solid:
          break;
      }

      final borderPaint = Paint()
        ..color = Color.lerp(baseColor, Colors.black, 0.15)!.withValues(alpha: 0.5)
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
    final pillRRect =
        RRect.fromRectAndRadius(pillRect, const Radius.circular(4));

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

  void _drawCurrentStroke(Canvas canvas) {
    if (currentStroke == null) return;

    if (currentStroke! is LaserStroke) {
      return _drawLaserStroke(canvas, currentStroke as LaserStroke);
    }

    final color = currentStroke!.color.withInversion(invert);
    final paint = Paint();

    paint.color = color;
    paint.shader = null;
    paint.maskFilter = null;
    if (currentStroke!.toolId == .pencil) {
      paint.color = Colors.white;
      paint.shader = page.pencilShader
        ..setFloat(0, color.r)
        ..setFloat(1, color.g)
        ..setFloat(2, color.b);
      paint.maskFilter = _getPencilMaskFilter(currentStroke!.options.size);
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

  /// The radius of the rotation handle knob.
  static const double rotationHandleRadius = 8;

  /// The distance from the selection bounds top edge
  /// to the rotation handle center.
  static const double rotationHandleOffset = 20;

  /// The radius of each circular corner resize handle.
  static const double resizeHandleRadius = 6;

  /// The hit-test distance for resize handles.
  static const double resizeHandleHitRadius = 18;

  void _drawSelection(Canvas canvas) {
    if (currentSelection == null) return;

    // While actively drawing the lasso loop, show only a delicate in-progress contour
    if (!isDoneSelecting) {
      page.selectionDeleteButtonRect = null;
      page.selectionRotationHandleCenter = null;
      page.selectionResizeHandles = null;
      page.selectionVertexHandles = null;

      // Soft translucent fill
      canvas.drawPath(
        currentSelection!.path,
        Paint()..color = primaryColor.withValues(alpha: 0.04),
      );

      // Delicate dashed contour
      canvas.drawPath(
        dashPath(
          currentSelection!.path,
          dashArray: CircularIntervalList([6, 4]),
        ),
        Paint()
          ..color = primaryColor.withValues(alpha: 0.85)
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    final bounds = currentSelection!.path.getBounds();
    if (bounds.isEmpty) return;

    // Remove the clunky red delete circle completely (delete is on floating callout & toolbar)
    page.selectionDeleteButtonRect = null;

    final padded = bounds.inflate(6.0);
    final center = padded.center;
    final rrect = RRect.fromRectAndRadius(padded, const Radius.circular(8));

    // Draw subtle bounding box fill
    canvas.drawRRect(
      rrect,
      Paint()..color = primaryColor.withValues(alpha: 0.035),
    );

    // Draw clean dashed bounding box outline
    canvas.drawPath(
      dashPath(
        Path()..addRRect(rrect),
        dashArray: CircularIntervalList([6, 4]),
      ),
      Paint()
        ..color = primaryColor.withValues(alpha: 0.75)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke,
    );

    // Subtle freehand path contour inside bounding box
    canvas.drawPath(
      dashPath(
        currentSelection!.path,
        dashArray: CircularIntervalList([4, 4]),
      ),
      Paint()
        ..color = primaryColor.withValues(alpha: 0.25)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // Draw modern rotation knob (centered above selection top edge)
    final rotationHandleCenter = Offset(center.dx, padded.top - rotationHandleOffset);
    page.selectionRotationHandleCenter = rotationHandleCenter;

    // Connector line
    canvas.drawLine(
      Offset(center.dx, padded.top),
      rotationHandleCenter,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.45)
        ..strokeWidth = 1.0,
    );

    // Rotation knob shadow & fill
    canvas.drawCircle(
      rotationHandleCenter + const Offset(0, 1),
      rotationHandleRadius + 0.5,
      Paint()..color = Colors.black.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      rotationHandleCenter,
      rotationHandleRadius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      rotationHandleCenter,
      rotationHandleRadius,
      Paint()
        ..color = primaryColor
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );

    // Small curved rotate arrow icon
    final arrowPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: rotationHandleCenter,
        width: 8,
        height: 8,
      ),
      -0.8,
      2.2,
      false,
      arrowPaint,
    );

    // 4 Elegant circular corner knobs (no chunky square midpoints!)
    final cornerPositions = <Offset>[
      padded.topLeft,
      padded.topRight,
      padded.bottomRight,
      padded.bottomLeft,
    ];

    for (final pos in cornerPositions) {
      canvas.drawCircle(
        pos + const Offset(0, 1),
        resizeHandleRadius + 0.5,
        Paint()..color = Colors.black.withValues(alpha: 0.16),
      );
      canvas.drawCircle(
        pos,
        resizeHandleRadius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        pos,
        resizeHandleRadius,
        Paint()
          ..color = primaryColor
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }

    // Keep all 8 positions in selectionResizeHandles so edge & corner hit-testing remains functional
    page.selectionResizeHandles = [
      padded.topLeft,                           // 0: topLeft
      Offset(center.dx, padded.top),            // 1: topCenter
      padded.topRight,                          // 2: topRight
      Offset(padded.right, center.dy),          // 3: middleRight
      padded.bottomRight,                       // 4: bottomRight
      Offset(center.dx, padded.bottom),         // 5: bottomCenter
      padded.bottomLeft,                        // 6: bottomLeft
      Offset(padded.left, center.dy),           // 7: middleLeft
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

  void _drawPenPreview(Canvas canvas) {
    final pos = page.penPreviewPosition;
    final radius = page.penPreviewRadius;
    final color = page.penPreviewColor;
    if (pos == null || radius == null || color == null || radius <= 0) return;

    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawEraserCursor(Canvas canvas) {
    final position = page.eraserCursorPosition;
    final radius = page.eraserCursorRadius;
    if (position == null || radius == null || radius <= 0) return;

    canvas.drawCircle(
      position,
      radius,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      position,
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawLaserSpotlight(Canvas canvas) {
    final position = page.laserSpotlightPosition;
    if (position == null) return;

    // Outer translucent halo (Goodnotes spotlight)
    canvas.drawCircle(
      position,
      28,
      Paint()
        ..color = Colors.red.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      position,
      16,
      Paint()
        ..color = Colors.red.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill,
    );
    // Core vibrant dot
    canvas.drawCircle(
      position,
      7,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill,
    );
    // Specular center dot
    canvas.drawCircle(
      position,
      2.5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.fill,
    );
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

  static const double _pageIndicatorFontSize = 20;
  static const double _pageIndicatorPadding = 5;
  void _drawPageIndicator(Canvas canvas, Size pageSize) {
    if (!showPageIndicator) return;

    final style = ui.ParagraphStyle(
      textAlign: .end,
      textDirection: .ltr,
      maxLines: 1,
    );

    final builder = ui.ParagraphBuilder(style)
      ..pushStyle(
        ui.TextStyle(
          color: Colors.black.withInversion(invert).withValues(alpha: 0.5),
          fontSize: _pageIndicatorFontSize,
          fontFamily: defaultTextStyle.fontFamily,
          fontFamilyFallback: defaultTextStyle.fontFamilyFallback,
        ),
      )
      ..addText('${page.bookmarked ? '★ ' : ''}${pageIndex + 1} / $totalPages');

    final paragraph = builder.build();
    paragraph.layout(
      ui.ParagraphConstraints(
        width: pageSize.width - 2 * _pageIndicatorPadding,
      ),
    );

    canvas.drawParagraph(
      paragraph,
      Offset(
        _pageIndicatorPadding,
        pageSize.height - _pageIndicatorPadding - _pageIndicatorFontSize * 1.2,
      ),
    );
  }

  static MaskFilter _getPencilMaskFilter(double size) =>
      MaskFilter.blur(BlurStyle.normal, min(size * 0.2, 3));
  bool shouldUsePencilShader(double strokeSize) =>
      currentScale >= _zoomThreshold && (strokeSize * currentScale) >= 3;

  static const _zoomThreshold = 0.9;
  Path _selectPath(Stroke stroke) => switch (currentScale) {
    < _zoomThreshold => stroke.lowQualityPath,
    _ => stroke.highQualityPath,
  };
}
