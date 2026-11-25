/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
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

part 'painters/cursor_painter_part.dart';
part 'painters/selection_painter_part.dart';
part 'painters/specialized_stroke_painter_part.dart';
part 'painters/stroke_painter_part.dart';

class CanvasPainter extends CustomPainter {
  CanvasPainter({
    super.repaint,
    this.invert = false,
    this.strokes,
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
    int? strokesVersion,
  }) : strokesVersion = strokesVersion ?? page.strokesVersion;

  final bool invert;

  /// The strokes to paint, or null to paint whatever strokes are on [page]
  /// each time this paints.
  ///
  /// Leave this null for a canvas that is being edited: strokes are added,
  /// erased and swapped between builds, and a list captured at build time
  /// would go stale.
  final List<Stroke>? strokes;
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

  /// Snapshot of [EditorPage.strokesVersion] when this painter was constructed.
  final int strokesVersion;

  /// The radius of the rotation handle knob.
  static const double rotationHandleRadius = 8;

  /// The distance from the selection bounds top edge
  /// to the rotation handle center.
  static const double rotationHandleOffset = 20;

  /// The radius of each circular corner resize handle.
  static const double resizeHandleRadius = 6;

  /// The hit-test distance for resize handles.
  static const double resizeHandleHitRadius = 18;

  static const double _pageIndicatorFontSize = 20;
  static const double _pageIndicatorPadding = 5;
  static const _zoomThreshold = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    final canvasRect = isInfiniteCanvas ? null : (Offset.zero & size);
    final cullRect = _tryGetCullRect(canvas);

    if (strokes == null && cullRect != null) {
      _paintWithPictureCache(canvas, size, canvasRect, cullRect);
    } else {
      final strokes = this.strokes ?? page.strokes;
      _drawHighlighterStrokes(canvas, canvasRect, cullRect, strokes);
      if (currentStroke?.toolId == .highlighter) {
        _drawCurrentStroke(canvas);
        _drawNonHighlighterStrokes(canvas, cullRect, strokes);
      } else {
        _drawNonHighlighterStrokes(canvas, cullRect, strokes);
        _drawCurrentStroke(canvas);
      }
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
        (page.laserSpotlightPosition !=
            oldDelegate.page.laserSpotlightPosition) ||
        // Check for any other changes
        invert != oldDelegate.invert ||
        (strokes == null
            ? strokesVersion != oldDelegate.strokesVersion
            : strokes!.length != oldDelegate.strokes?.length) ||
        currentSelection != oldDelegate.currentSelection ||
        isDoneSelecting != oldDelegate.isDoneSelecting ||
        primaryColor != oldDelegate.primaryColor ||
        page != oldDelegate.page ||
        showPageIndicator != oldDelegate.showPageIndicator ||
        pageIndex != oldDelegate.pageIndex ||
        totalPages != oldDelegate.totalPages ||
        currentScale != oldDelegate.currentScale ||
        isInfiniteCanvas != oldDelegate.isInfiniteCanvas;
  }

  /// Safely queries [Canvas.getLocalClipBounds], returning null on mock test
  /// canvases (e.g. `TestRecordingCanvas`) or when bounds are unbounded.
  static Rect? _tryGetCullRect(Canvas canvas) {
    try {
      final rawClip = canvas.getLocalClipBounds();
      return _isValidCullRect(rawClip) ? rawClip : null;
    } catch (_) {
      return null;
    }
  }

  /// Whether a local clip rect is a finite, bounded viewport suitable for
  /// stroke culling and layer bounds (excluding empty or ±1e9 sentinels).
  static bool _isValidCullRect(Rect rect) {
    if (!rect.isFinite || rect.isEmpty) return false;
    if (rect.left <= -1e8 ||
        rect.top <= -1e8 ||
        rect.right >= 1e8 ||
        rect.bottom >= 1e8) {
      return false;
    }
    return true;
  }

  static MaskFilter _getPencilMaskFilter(double size) =>
      MaskFilter.blur(BlurStyle.normal, min(size * 0.2, 3));

  bool shouldUsePencilShader(double strokeSize) =>
      currentScale >= _zoomThreshold && (strokeSize * currentScale) >= 3;

  Path _selectPath(Stroke stroke) => switch (currentScale) {
    < _zoomThreshold => stroke.lowQualityPath,
    _ => stroke.highQualityPath,
  };
}
