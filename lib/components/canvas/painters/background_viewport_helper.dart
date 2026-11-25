/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/painters/background_pattern_element.dart';
import 'package:saber/data/extensions/color_extensions.dart';
import 'package:sbn/canvas_background_pattern.dart';

/// Base quantization grid step for infinite-canvas background caching.
const infiniteQuantizeStep = 500.0;

/// Maximum span dimension allowed when clamping infinite-canvas pattern bounds.
const maxInfiniteBoundsSpan = 2000000.0;

/// Resolves the page fill color with optional dark-mode inversion.
Color resolveBackgroundColor(Color backgroundColor, bool invert) =>
    backgroundColor.withInversion(invert);

/// Resolves a pattern ink color with preview or normal canvas opacity.
Color resolvePatternColor(Color color, {required bool preview}) =>
    color.withValues(alpha: preview ? 0.5 : 0.2);

/// Whether [rect] represents a real, finite visible viewport rather than an
/// unclipped Skia/Impeller sentinel or a runaway dimension.
bool isValidViewport(Rect rect) {
  if (!rect.isFinite || rect.isEmpty) return false;
  if (rect.left <= -1e8 ||
      rect.top <= -1e8 ||
      rect.right >= 1e8 ||
      rect.bottom >= 1e8) {
    return false;
  }
  if (rect.width > maxInfiniteBoundsSpan ||
      rect.height > maxInfiniteBoundsSpan) {
    return false;
  }
  return true;
}

/// Clamps [bounds] to a finite, viewport-bounded rect for infinite-canvas
/// pattern generation, returning null if [bounds] is invalid or empty.
Rect? clampInfiniteBounds(Rect bounds) {
  if (!bounds.isFinite || bounds.isEmpty) return null;
  if (bounds.left <= -1e8 ||
      bounds.top <= -1e8 ||
      bounds.right >= 1e8 ||
      bounds.bottom >= 1e8 ||
      bounds.width > 5000000 ||
      bounds.height > 5000000) {
    return null;
  }
  final clampedWidth = bounds.width.clamp(0.0, maxInfiniteBoundsSpan);
  final clampedHeight = bounds.height.clamp(0.0, maxInfiniteBoundsSpan);
  final clamped = Rect.fromCenter(
    center: bounds.center,
    width: clampedWidth,
    height: clampedHeight,
  );
  return clamped.isEmpty ? null : clamped;
}

/// Quantizes [scale] downward to a power-of-2 octave in `(0, 1]` so
/// continuous pinch-zoom frames within each octave keep an identical
/// infinite-canvas background rect.
double quantizedScaleForInfinite(double scale) {
  if (!scale.isFinite || scale <= 0) return 1.0;
  if (scale >= 1.0) return 1.0;
  final clamped = scale.clamp(0.001, 1.0);
  var bucket = 1.0;
  while (bucket > clamped && bucket > 0.001953125) {
    bucket *= 0.5;
  }
  return bucket;
}

/// Quantizes [rect] outward to octave-quantized multiples of
/// [infiniteQuantizeStep] for scales `<= 1.5` and a tighter 256px grid above
/// `1.5x` so small pan and zoom deltas reuse the cached background without
/// high-zoom overdraw.
Rect? quantizedInfiniteRect(Rect? rect, [double scale = 1.0]) {
  if (rect == null || !isValidViewport(rect)) return null;
  final double step;
  final double inflateAmount;
  if (scale > 1.5) {
    step = 256.0;
    inflateAmount = 192.0;
  } else {
    final bucketScale = quantizedScaleForInfinite(scale);
    step = infiniteQuantizeStep / bucketScale;
    inflateAmount = (infiniteQuantizeStep * 0.75) / bucketScale;
  }
  final inflated = rect.inflate(inflateAmount);
  return Rect.fromLTRB(
    (inflated.left / step).floorToDouble() * step,
    (inflated.top / step).floorToDouble() * step,
    (inflated.right / step).ceilToDouble() * step,
    (inflated.bottom / step).ceilToDouble() * step,
  );
}

/// Quantizes [rect] to a 256px grid for high-zoom (`> 1.5x`) culling on finite pages.
Rect? quantizedNormalHighZoomRect(Rect? rect, double scale) {
  if (scale <= 1.5 || rect == null) return null;
  if (rect.isEmpty) return Rect.zero;
  if (!isValidViewport(rect)) return null;
  const step = 256.0;
  final inflated = rect.inflate(step);
  return Rect.fromLTRB(
    (inflated.left / step).floorToDouble() * step,
    (inflated.top / step).floorToDouble() * step,
    (inflated.right / step).ceilToDouble() * step,
    (inflated.bottom / step).ceilToDouble() * step,
  );
}

/// Resolves the visible paint rect for either infinite or finite canvas modes.
Rect resolveVisibleRect({
  required bool isInfiniteCanvas,
  required Rect? viewportRect,
  required double currentScale,
  required Canvas canvas,
  required Size size,
}) {
  if (!isInfiniteCanvas) return Offset.zero & size;

  final quantized = quantizedInfiniteRect(viewportRect, currentScale);
  if (quantized != null) return quantized;

  final clip = canvas.getLocalClipBounds();
  if (isValidViewport(clip)) {
    final bucketScale = quantizedScaleForInfinite(currentScale);
    return clip.inflate(infiniteQuantizeStep / bucketScale);
  }

  const margin = 5000.0;
  final baseWidth = size.width.isFinite && size.width > 0 ? size.width : 1000.0;
  final baseHeight = size.height.isFinite && size.height > 0
      ? size.height
      : 1400.0;
  return Rect.fromLTRB(
    -margin,
    -margin,
    baseWidth + margin,
    baseHeight + margin,
  );
}

/// Computes the LOD-adjusted line spacing bucket for [scale] and [pattern].
int lodBucket(int lineHeight, double scale, CanvasBackgroundPattern pattern) {
  if (lineHeight <= 0 || !scale.isFinite || scale <= 0) return lineHeight;
  var step = lineHeight;
  final minScreenSpacing = pattern == CanvasBackgroundPattern.dots ? 16.0 : 6.0;
  while (step * scale < minScreenSpacing && step < 10000000) {
    step *= 2;
  }
  return step;
}

/// Computes the effective pattern spacing after applying LOD and infinite-canvas
/// dot density caps.
int computeEffectiveLineHeight({
  required int lineHeight,
  required double currentScale,
  required bool isInfiniteCanvas,
  required CanvasBackgroundPattern pattern,
  required Rect visibleRect,
}) {
  var effective = lineHeight;
  if ((isInfiniteCanvas || (currentScale >= 0.0005 && currentScale < 0.6)) &&
      effective > 0 &&
      currentScale.isFinite &&
      currentScale > 0) {
    effective = lodBucket(effective, currentScale, pattern);
  }
  if (pattern == CanvasBackgroundPattern.dots &&
      isInfiniteCanvas &&
      effective > 0) {
    while (((visibleRect.width / effective) + 1) *
                ((visibleRect.height / effective) + 1) >
            4000 &&
        effective < 10000000) {
      effective *= 2;
    }
  }
  return effective;
}

/// Returns whether [element] intersects [cullRect].
bool isElementInRect(PatternElement element, Rect cullRect) {
  if (element.isLine) {
    final minX = min(element.start.dx, element.end.dx);
    final maxX = max(element.start.dx, element.end.dx);
    final minY = min(element.start.dy, element.end.dy);
    final maxY = max(element.start.dy, element.end.dy);
    return maxX >= cullRect.left &&
        minX <= cullRect.right &&
        maxY >= cullRect.top &&
        minY <= cullRect.bottom;
  }
  final x = element.start.dx;
  final y = element.start.dy;
  return x >= cullRect.left &&
      x <= cullRect.right &&
      y >= cullRect.top &&
      y <= cullRect.bottom;
}
