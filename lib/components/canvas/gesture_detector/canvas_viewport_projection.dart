/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:saber/components/canvas/_canvas_background_painter.dart';
import 'package:saber/components/canvas/_canvas_painter.dart';
import 'package:saber/components/canvas/interactive/canvas_matrix_math.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:saber/pages/editor/editor.dart';
import 'package:vector_math/vector_math_64.dart';

/// Pure viewport projection, page offset mapping, and rebuild-decision helpers.
abstract final class CanvasViewportProjection {
  /// Returns the vertical offset of the top of [pageIndex] in the paged column.
  static double getTopOfPage({
    required int pageIndex,
    required List<EditorPage> pages,
    required double screenWidth,
  }) {
    if (pageIndex <= 0) return 0;

    double top = 0;
    for (int i = 0; i < pageIndex && i < pages.length; i++) {
      final pageSize = pages[i].size;
      final pageWidthFitted = min(pageSize.width, screenWidth);

      top += 16;
      top += pageSize.height * (pageWidthFitted / pageSize.width);
    }
    return top;
  }

  /// Updates [transformationController] to scroll directly to [pageIndex].
  static void scrollToPage({
    required int pageIndex,
    required List<EditorPage> pages,
    required double screenWidth,
    required TransformationController transformationController,
  }) {
    final topOfPage = -getTopOfPage(
      pageIndex: pageIndex,
      pages: pages,
      screenWidth: screenWidth,
    );
    transformationController.value = Matrix4.translationValues(
      0,
      topOfPage + 50,
      0,
    );
  }

  /// Returns the page index corresponding to [scrollY] in the paged column.
  static int getPageIndex({
    required double scrollY,
    required List<EditorPage> pages,
    required double screenWidth,
  }) {
    if (scrollY <= 0) return 0;

    double top = 0;
    for (int i = 0; i < pages.length; i++) {
      final pageSize = pages[i].size;
      final pageWidthFitted = min(pageSize.width, screenWidth);

      top += 16;
      top += pageSize.height * (pageWidthFitted / pageSize.width);

      if (top > scrollY) return i;
    }
    return pages.length - 1;
  }

  /// Returns the axis-aligned bounding box for [quad].
  static Rect axisAlignedBoundingBox(Quad quad) {
    final points = [quad.point0, quad.point1, quad.point2, quad.point3];

    final left = points.map((point) => point.x).reduce(min);
    final right = points.map((point) => point.x).reduce(max);
    final top = points.map((point) => point.y).reduce(min);
    final bottom = points.map((point) => point.y).reduce(max);

    return Rect.fromLTRB(left, top, right, bottom);
  }

  /// Projects a column-space [boundingBox] into local coordinates for a page.
  static Rect? computePageLocalViewport({
    required Size pageSize,
    required double pageWidth,
    required double topOfPage,
    required double containerWidth,
    required Rect boundingBox,
  }) {
    final fitRatio = pageWidth > 0 && pageSize.width > 0
        ? pageWidth / pageSize.width
        : 1.0;
    if (fitRatio <= 0 || !boundingBox.isFinite || boundingBox.isEmpty) {
      return null;
    }
    final pageLeftInColumn = (containerWidth - pageWidth) * 0.5;
    return Rect.fromLTRB(
      ((boundingBox.left - pageLeftInColumn) / fitRatio).clamp(
        0.0,
        pageSize.width,
      ),
      ((boundingBox.top - topOfPage) / fitRatio).clamp(0.0, pageSize.height),
      ((boundingBox.right - pageLeftInColumn) / fitRatio).clamp(
        0.0,
        pageSize.width,
      ),
      ((boundingBox.bottom - topOfPage) / fitRatio).clamp(0.0, pageSize.height),
    );
  }

  /// Determines whether the page builder needs to rebuild for a transform change
  /// and whether a deferred high-zoom refresh should be scheduled after gesture end.
  static ({bool shouldRebuild, bool markHighZoomRefresh}) evaluatePageRebuild({
    required Matrix4 oldMatrix,
    required Matrix4 newMatrix,
    required Size viewportSize,
    required BoxConstraints containerBounds,
    required List<EditorPage> pages,
    required bool isInfiniteCanvas,
    required bool isGestureActive,
  }) {
    final oldScale = oldMatrix.maxScale2D;
    final newScale = newMatrix.maxScale2D;
    if (!oldScale.isFinite ||
        oldScale <= 0 ||
        !newScale.isFinite ||
        newScale <= 0) {
      return (shouldRebuild: false, markHighZoomRefresh: false);
    }

    if (CanvasPainter.visualScaleBucket(oldScale) !=
        CanvasPainter.visualScaleBucket(newScale)) {
      return (shouldRebuild: true, markHighZoomRefresh: false);
    }
    if (CanvasBackgroundPainter.quantizedScaleForInfinite(oldScale) !=
        CanvasBackgroundPainter.quantizedScaleForInfinite(newScale)) {
      return (shouldRebuild: true, markHighZoomRefresh: false);
    }

    final viewport = Offset.zero & viewportSize;
    final oldBounds = axisAlignedBoundingBox(
      canvasTransformViewport(oldMatrix, viewport),
    );
    final newBounds = axisAlignedBoundingBox(
      canvasTransformViewport(newMatrix, viewport),
    );

    if (isInfiniteCanvas) {
      return _evaluateInfiniteCanvasRebuild(
        oldBounds: oldBounds,
        newBounds: newBounds,
        oldScale: oldScale,
        newScale: newScale,
        isGestureActive: isGestureActive,
      );
    }

    return _evaluatePagedCanvasRebuild(
      oldBounds: oldBounds,
      newBounds: newBounds,
      oldScale: oldScale,
      newScale: newScale,
      viewportSize: viewportSize,
      containerBounds: containerBounds,
      pages: pages,
      isGestureActive: isGestureActive,
    );
  }

  static ({bool shouldRebuild, bool markHighZoomRefresh})
  _evaluateInfiniteCanvasRebuild({
    required Rect oldBounds,
    required Rect newBounds,
    required double oldScale,
    required double newScale,
    required bool isGestureActive,
  }) {
    if (CanvasBackgroundPainter.quantizedInfiniteRect(oldBounds, oldScale) !=
        CanvasBackgroundPainter.quantizedInfiniteRect(newBounds, newScale)) {
      return (shouldRebuild: true, markHighZoomRefresh: false);
    }
    if (oldScale > 1.5 || newScale > 1.5) {
      if (isGestureActive) {
        return (shouldRebuild: false, markHighZoomRefresh: true);
      }
      if (CanvasPainter.quantizedHighZoomViewport(oldBounds, oldScale) !=
          CanvasPainter.quantizedHighZoomViewport(newBounds, newScale)) {
        return (shouldRebuild: true, markHighZoomRefresh: false);
      }
    }
    return (shouldRebuild: false, markHighZoomRefresh: false);
  }

  static ({bool shouldRebuild, bool markHighZoomRefresh})
  _evaluatePagedCanvasRebuild({
    required Rect oldBounds,
    required Rect newBounds,
    required double oldScale,
    required double newScale,
    required Size viewportSize,
    required BoxConstraints containerBounds,
    required List<EditorPage> pages,
    required bool isGestureActive,
  }) {
    if ((oldScale > 2.0) != (newScale > 2.0)) {
      return (shouldRebuild: true, markHighZoomRefresh: false);
    }

    final containerWidth =
        containerBounds.hasBoundedWidth && containerBounds.maxWidth > 0
        ? containerBounds.maxWidth
        : viewportSize.width;
    final isHighZoom = oldScale > 1.5 || newScale > 1.5;
    final checkHighZoom = !isGestureActive && isHighZoom;
    double topOfPage = Editor.gapBetweenPages * 2;

    for (final page in pages) {
      final pageWidth = min(page.size.width, containerWidth);
      final pageHeight = pageWidth / page.size.width * page.size.height;
      final bottomOfPage = topOfPage + pageHeight;

      final wasInViewport =
          oldBounds.bottom >= topOfPage && oldBounds.top <= bottomOfPage;
      final isInViewport =
          newBounds.bottom >= topOfPage && newBounds.top <= bottomOfPage;
      if (wasInViewport != isInViewport) {
        return (shouldRebuild: true, markHighZoomRefresh: false);
      }

      if (checkHighZoom && isInViewport) {
        final oldPageLocal = computePageLocalViewport(
          pageSize: page.size,
          pageWidth: pageWidth,
          topOfPage: topOfPage,
          containerWidth: containerWidth,
          boundingBox: oldBounds,
        );
        final newPageLocal = computePageLocalViewport(
          pageSize: page.size,
          pageWidth: pageWidth,
          topOfPage: topOfPage,
          containerWidth: containerWidth,
          boundingBox: newBounds,
        );
        if (CanvasPainter.quantizedHighZoomViewport(oldPageLocal, oldScale) !=
            CanvasPainter.quantizedHighZoomViewport(newPageLocal, newScale)) {
          return (shouldRebuild: true, markHighZoomRefresh: false);
        }
      }

      topOfPage = bottomOfPage + Editor.gapBetweenPages;
    }

    return (
      shouldRebuild: false,
      markHighZoomRefresh: isGestureActive && isHighZoom,
    );
  }
}
