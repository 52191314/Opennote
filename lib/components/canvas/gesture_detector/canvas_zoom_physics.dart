/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:saber/components/canvas/gesture_detector/canvas_viewport_projection.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:vector_math/vector_math_64.dart';

/// Pure zoom scaling, snap-threshold, and viewport bounds clamping math for the canvas.
abstract final class CanvasZoomPhysics {
  /// Default minimum zoom scale when unconstrained.
  static const kMinScale = 0.001;

  /// Minimum interactive zoom scale for infinite canvas mode.
  static const kInfiniteMinScale = 0.02;

  /// Minimum interactive zoom scale for paged canvas mode.
  static const kPagedMinScale = 0.2;

  /// Maximum interactive zoom scale.
  static const kMaxScale = 10.0;

  /// Returns the interactive minimum zoom scale for [isInfiniteCanvas].
  static double minScaleFor({required bool isInfiniteCanvas}) =>
      isInfiniteCanvas ? kInfiniteMinScale : kPagedMinScale;

  /// Returns whether [scale] is close enough to 1.0x to snap back cleanly.
  static bool shouldSnapZoomToOne(double scale) {
    if (!scale.isFinite || scale <= 0) return false;
    final diffFrom1 = (scale - 1).abs();
    return diffFrom1 < 0.05 && diffFrom1 > 0.001;
  }

  /// Computes a centered zoom matrix adjusted by [scaleDelta], or `null` if
  /// the bounds are invalid or the scale is already clamped at its limit.
  static Matrix4? computeZoomMatrix({
    required double scaleDelta,
    required Matrix4 transformation,
    required BoxConstraints containerBounds,
    double minScale = kMinScale,
    double maxScale = kMaxScale,
  }) {
    if (!containerBounds.hasBoundedWidth ||
        !containerBounds.hasBoundedHeight ||
        containerBounds.maxWidth <= 0 ||
        containerBounds.maxHeight <= 0) {
      return null;
    }

    final oldScale = transformation.maxScale2D;
    if (!oldScale.isFinite || oldScale <= 0) return null;

    if (scaleDelta < 0 && oldScale <= minScale) return null;
    if (scaleDelta > 0 && oldScale >= maxScale) return null;

    double newScale = oldScale + scaleDelta;
    if (newScale < minScale) {
      if (oldScale <= minScale) return null;
      newScale = minScale;
    }
    if (newScale > maxScale) {
      if (oldScale >= maxScale) return null;
      newScale = maxScale;
    }

    final center = Vector3(
      containerBounds.maxWidth / 2,
      containerBounds.maxHeight / 2,
      0,
    );
    final translation =
        (transformation.getTranslation() - center) * (newScale / oldScale) +
        center;

    return Matrix4.translation(translation)
      ..scaleByDouble(newScale, newScale, 1.0, 1.0);
  }

  /// Computes the `(dx, dy)` translation correction required to keep [matrix]
  /// within the paged canvas bounds.
  static ({double dx, double dy}) computeBoundsAdjustment({
    required Matrix4 matrix,
    required BoxConstraints containerBounds,
    required List<EditorPage> pages,
    required bool isInfiniteCanvas,
  }) {
    if (isInfiniteCanvas) return (dx: 0.0, dy: 0.0);

    final scale = matrix.maxScale2D;
    if (!scale.isFinite || scale <= 0) return (dx: 0.0, dy: 0.0);

    final translation = matrix.getTranslation();
    if (scale < 1) {
      return _computeZoomedOutAdjustment(
        scale: scale,
        translation: translation,
        containerBounds: containerBounds,
        pages: pages,
      );
    }
    return _computeZoomedInAdjustment(
      scale: scale,
      translation: translation,
      containerBounds: containerBounds,
    );
  }

  /// Returns [matrix] clamped to the paged canvas bounds if any correction is needed.
  static Matrix4 constrainTransformMatrix({
    required Matrix4 matrix,
    required BoxConstraints containerBounds,
    required List<EditorPage> pages,
    required bool isInfiniteCanvas,
  }) {
    final adjustment = computeBoundsAdjustment(
      matrix: matrix,
      containerBounds: containerBounds,
      pages: pages,
      isInfiniteCanvas: isInfiniteCanvas,
    );
    if (adjustment.dx == 0.0 && adjustment.dy == 0.0) return matrix;
    return matrix.clone()
      ..leftTranslateByDouble(adjustment.dx, adjustment.dy, 0, 1);
  }

  static ({double dx, double dy}) _computeZoomedOutAdjustment({
    required double scale,
    required Vector3 translation,
    required BoxConstraints containerBounds,
    required List<EditorPage> pages,
  }) {
    double adjustmentX = 0;
    double adjustmentY = 0;

    if (containerBounds.hasBoundedWidth && containerBounds.maxWidth > 0) {
      final center = containerBounds.maxWidth * (1 - scale) / 2;
      adjustmentX = center - translation.x;
    }

    if (containerBounds.hasBoundedHeight &&
        containerBounds.maxHeight > 0 &&
        pages.isNotEmpty) {
      final totalContentHeight =
          CanvasViewportProjection.getTopOfPage(
            pageIndex: pages.length,
            pages: pages,
            screenWidth: containerBounds.maxWidth > 0
                ? containerBounds.maxWidth
                : 1000,
          ) *
          scale;
      final maxY = (1.0 - scale) * containerBounds.maxHeight * 0.5;
      final minY = min(
        0.0,
        containerBounds.maxHeight * 0.5 - totalContentHeight,
      );
      if (translation.y > maxY) {
        adjustmentY = maxY - translation.y;
      } else if (translation.y < minY) {
        adjustmentY = minY - translation.y;
      }
    }

    return (dx: adjustmentX, dy: adjustmentY);
  }

  static ({double dx, double dy}) _computeZoomedInAdjustment({
    required double scale,
    required Vector3 translation,
    required BoxConstraints containerBounds,
  }) {
    double adjustmentX = 0;
    double adjustmentY = 0;

    if (containerBounds.hasBoundedWidth && containerBounds.maxWidth > 0) {
      final minX = containerBounds.maxWidth * (1 - scale);
      if (translation.x > 0) {
        adjustmentX = -translation.x;
      } else if (translation.x < minX) {
        adjustmentX = minX - translation.x;
      }
    }

    if (translation.y > 0) {
      adjustmentY = -translation.y;
    }

    return (dx: adjustmentX, dy: adjustmentY);
  }
}
