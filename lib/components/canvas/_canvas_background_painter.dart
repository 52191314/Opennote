/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/painters/background_batch_renderer.dart';
import 'package:saber/components/canvas/painters/background_pattern_dispatcher.dart';
import 'package:saber/components/canvas/painters/background_pattern_element.dart';
import 'package:saber/components/canvas/painters/background_viewport_helper.dart'
    as viewport;
import 'package:sbn/canvas_background_pattern.dart';

export 'painters/background_pattern_element.dart';

/// Paints page backgrounds and ruled/grid/dot/music/Cornell patterns for both
/// fixed-size pages and viewport-culled infinite canvases.
class CanvasBackgroundPainter extends CustomPainter {
  const CanvasBackgroundPainter({
    required this.invert,
    required this.backgroundColor,
    this.backgroundPattern = .none,
    required this.lineHeight,
    required this.lineThickness,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.red,
    this.preview = false,
    this.isInfiniteCanvas = false,
    this.viewportRect,
    this.currentScale = 1.0,
  });

  final bool invert;
  final Color backgroundColor;

  /// The pattern to use for the background. See [CanvasBackgroundPattern].
  final CanvasBackgroundPattern backgroundPattern;

  /// The height between each line in the background pattern.
  final int lineHeight;
  final int lineThickness;
  final Color primaryColor;
  final Color secondaryColor;

  /// Whether to draw the background pattern in a preview mode (more opaque).
  final bool preview;

  /// Whether to paint an unbounded 2D infinite canvas.
  final bool isInfiniteCanvas;

  /// The visible viewport bounding box in scene coordinates for infinite canvas.
  final Rect? viewportRect;

  /// Current canvas zoom magnification used for adaptive LOD on infinite canvas.
  final double currentScale;

  /// Quantizes [scale] downward to a power-of-2 octave in `(0, 1]`.
  static double quantizedScaleForInfinite(double scale) =>
      viewport.quantizedScaleForInfinite(scale);

  /// Quantizes [rect] outward to octave-quantized multiples for infinite-canvas
  /// background caching.
  static Rect? quantizedInfiniteRect(Rect? rect, [double scale = 1.0]) =>
      viewport.quantizedInfiniteRect(rect, scale);

  @override
  void paint(Canvas canvas, Size size) {
    final visibleRect = viewport.resolveVisibleRect(
      isInfiniteCanvas: isInfiniteCanvas,
      viewportRect: viewportRect,
      currentScale: currentScale,
      canvas: canvas,
      size: size,
    );
    final paint = Paint()
      ..color = viewport.resolveBackgroundColor(backgroundColor, invert);
    canvas.drawRect(visibleRect, paint);

    final shouldClip = !isInfiniteCanvas && backgroundPattern.requiresClipping;
    if (shouldClip) {
      canvas.save();
      canvas.clipRect(visibleRect);
    }

    final normalCull = _resolveNormalCullRect(visibleRect);
    if (backgroundPattern != CanvasBackgroundPattern.none &&
        (normalCull == null || !normalCull.isEmpty)) {
      final effectiveLineHeight = viewport.computeEffectiveLineHeight(
        lineHeight: lineHeight,
        currentScale: currentScale,
        isInfiniteCanvas: isInfiniteCanvas,
        pattern: backgroundPattern,
        visibleRect: visibleRect,
      );
      final infiniteThicknessScale = isInfiniteCanvas && currentScale < 1.0
          ? 1.0 / currentScale.clamp(0.02, 1.0)
          : 1.0;

      paintBackgroundPatternElements(
        canvas: canvas,
        paint: paint,
        elements: getPatternElements(
          pattern: backgroundPattern,
          size: size,
          lineHeight: effectiveLineHeight,
          lineThickness: lineThickness,
          bounds: isInfiniteCanvas ? visibleRect : null,
        ),
        cullRect: normalCull,
        lineThickness: lineThickness,
        infiniteThicknessScale: infiniteThicknessScale,
        effectivePrimary: viewport.resolvePatternColor(
          primaryColor,
          preview: preview,
        ),
        effectiveSecondary: viewport.resolvePatternColor(
          secondaryColor,
          preview: preview,
        ),
      );
    }

    if (shouldClip) canvas.restore();
  }

  Rect? _resolveNormalCullRect(Rect visibleRect) {
    if (isInfiniteCanvas) return null;
    final quantized = viewport.quantizedNormalHighZoomRect(
      viewportRect,
      currentScale,
    );
    if (quantized == null) return null;
    return quantized.isEmpty ? Rect.zero : quantized.intersect(visibleRect);
  }

  @override
  bool shouldRepaint(CanvasBackgroundPainter oldDelegate) {
    final lodChanged =
        (isInfiniteCanvas ||
            currentScale < 0.6 ||
            oldDelegate.currentScale < 0.6) &&
        viewport.lodBucket(
              oldDelegate.lineHeight,
              oldDelegate.currentScale,
              oldDelegate.backgroundPattern,
            ) !=
            viewport.lodBucket(lineHeight, currentScale, backgroundPattern);
    final viewportChanged =
        isInfiniteCanvas &&
        (viewportRect == null ||
            oldDelegate.viewportRect == null ||
            quantizedInfiniteRect(
                  oldDelegate.viewportRect,
                  oldDelegate.currentScale,
                ) !=
                quantizedInfiniteRect(viewportRect, currentScale));
    final normalHighZoomChanged =
        !isInfiniteCanvas &&
        backgroundPattern != CanvasBackgroundPattern.none &&
        (currentScale > 1.5 || oldDelegate.currentScale > 1.5) &&
        viewport.quantizedNormalHighZoomRect(
              oldDelegate.viewportRect,
              oldDelegate.currentScale,
            ) !=
            viewport.quantizedNormalHighZoomRect(viewportRect, currentScale);
    return lodChanged ||
        viewportChanged ||
        normalHighZoomChanged ||
        oldDelegate.invert != invert ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.backgroundPattern != backgroundPattern ||
        oldDelegate.lineHeight != lineHeight ||
        oldDelegate.lineThickness != lineThickness ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.preview != preview ||
        oldDelegate.isInfiniteCanvas != isInfiniteCanvas;
  }

  /// Generates all [PatternElement] primitives for [pattern].
  ///
  /// When [bounds] is provided (infinite canvas mode), all pattern loops are
  /// strictly clamped to the finite visible cull rect.
  static Iterable<PatternElement> getPatternElements({
    required CanvasBackgroundPattern pattern,
    required Size size,
    required int lineHeight,
    int lineThickness = 3,
    Rect? bounds,
  }) => generateBackgroundPatternElements(
    pattern: pattern,
    size: size,
    lineHeight: lineHeight,
    lineThickness: lineThickness,
    bounds: bounds,
  );
}
