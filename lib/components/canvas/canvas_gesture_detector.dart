/// 🤖 Generated wholely or partially with Claude Code; Gemini; Google Antigravity
/// 🤖 Modified with Grok 4.7
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saber/components/canvas/_canvas_background_painter.dart';
import 'package:saber/components/canvas/_canvas_painter.dart';
import 'package:saber/components/canvas/gesture_detector/canvas_transform_cache.dart';
import 'package:saber/components/canvas/hud/canvas_hud.dart';
import 'package:saber/components/canvas/hud/floating_layers_overlay.dart';
import 'package:saber/components/canvas/hud/protractor_overlay.dart';
import 'package:saber/components/canvas/interactive/canvas_matrix_math.dart';
import 'package:saber/components/canvas/interactive_canvas.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/change_notifier_extensions.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/shortcuts/mobile_keybinder.dart';
import 'package:saber/data/tools/palm_rejection.dart';
import 'package:saber/pages/editor/editor.dart';
import 'package:vector_math/vector_math_64.dart';

export 'gesture_detector/canvas_transform_cache.dart';

part 'gesture_detector/canvas_navigation_controls.dart';
part 'gesture_detector/canvas_pages_builder.dart';
part 'gesture_detector/canvas_pointer_handlers.dart';

class CanvasGestureDetector extends StatefulWidget {
  CanvasGestureDetector({
    super.key,
    required this.filePath,
    required this.isDrawGesture,
    this.onInteractionEnd,
    required this.onDrawStart,
    required this.onDrawUpdate,
    required this.onDrawEnd,
    required this.updatePointerData,
    required this.onHovering,
    required this.onHoveringEnd,
    required this.onStylusButtonChanged,
    required this.undo,
    required this.redo,
    required this.pages,
    required this.initialPageIndex,
    this.explicitPageIndex,
    required this.pageBuilder,
    required this.placeholderPageBuilder,
    required this.isTextEditing,
    this.bookmarked = false,
    this.onToggleBookmarked,
    this.hasTape = false,
    this.onRevealAllTape,
    this.onConcealAllTape,
    this.activePage,
    this.onLayersChanged,
    this.isInfiniteCanvas = false,
    this.onFitContent,
    TransformationController? transformationController,
  }) : _transformationController =
           transformationController ?? TransformationController();

  final String filePath;

  final bool Function(ScaleStartDetails scaleDetails) isDrawGesture;
  final ValueChanged<ScaleEndDetails>? onInteractionEnd;
  final ValueChanged<ScaleStartDetails> onDrawStart;
  final ValueChanged<ScaleUpdateDetails> onDrawUpdate;
  final ValueChanged<ScaleEndDetails> onDrawEnd;

  /// Called when the pressure of the stylus changes.
  /// The [pressure] value is normalized into a range of 0 to 1.
  final void Function(PointerDeviceKind kind, double? pressure)
  updatePointerData;
  final VoidCallback onHovering;
  final VoidCallback onHoveringEnd;
  final ValueChanged<bool> onStylusButtonChanged;

  final VoidCallback undo;
  final VoidCallback redo;

  final List<EditorPage> pages;
  final int? initialPageIndex;

  /// Page requested by the route, such as an ink-search hit.
  ///
  /// When set, it is shown even if this note still has a cached scroll position.
  final int? explicitPageIndex;
  final Widget Function(
    BuildContext context,
    int pageIndex, [
    Rect? viewportRect,
  ])
  pageBuilder;
  final Widget Function(BuildContext context, int pageIndex)
  placeholderPageBuilder;

  final bool Function() isTextEditing;
  final bool bookmarked;
  final VoidCallback? onToggleBookmarked;
  final bool hasTape;
  final VoidCallback? onRevealAllTape;
  final VoidCallback? onConcealAllTape;
  final EditorPage? activePage;
  final VoidCallback? onLayersChanged;
  final bool isInfiniteCanvas;
  final VoidCallback? onFitContent;

  late final TransformationController _transformationController;

  @override
  State<CanvasGestureDetector> createState() => CanvasGestureDetectorState();

  static const kMinScale = 0.001;
  static const kInfiniteMinScale = 0.02;
  static const kPagedMinScale = 0.2;
  static const kMaxScale = 10.0;

  /// Returns the interactive minimum zoom scale for [isInfiniteCanvas].
  static double minScaleFor({required bool isInfiniteCanvas}) =>
      isInfiniteCanvas ? kInfiniteMinScale : kPagedMinScale;

  static double getTopOfPage({
    required int pageIndex,
    required List<EditorPage> pages,
    required double screenWidth,
  }) {
    if (pageIndex <= 0) return 0;

    double top = 0;

    for (int i = 0; i < pageIndex && i < pages.length; i++) {
      final pageSize = pages[i].size;

      /// Since we use a FittedBox, the actual width of the page
      /// is the minimum of the page width and the screen width.
      final pageWidthFitted = min(pageSize.width, screenWidth);

      top += 16;
      top += pageSize.height * (pageWidthFitted / pageSize.width);
    }

    return top;
  }

  static void scrollToPage({
    required int pageIndex,
    required List<EditorPage> pages,
    required double screenWidth,
    required TransformationController transformationController,
  }) {
    final topOfPage = -CanvasGestureDetector.getTopOfPage(
      pageIndex: pageIndex,
      pages: pages,
      screenWidth: screenWidth,
    );
    transformationController.value = Matrix4.translationValues(
      0,
      // Slight upwards offset so that the page is not flush with the top of the screen
      topOfPage + 50,
      0,
    );
  }

  static int getPageIndex({
    required double scrollY,
    required List<EditorPage> pages,
    required double screenWidth,
  }) {
    if (scrollY <= 0) return 0;

    double top = 0;

    for (int i = 0; i < pages.length; i++) {
      final pageSize = pages[i].size;

      /// Since we use a FittedBox, the actual width of the page
      /// is the minimum of the page width and the screen width.
      final pageWidthFitted = min(pageSize.width, screenWidth);

      top += 16;
      top += pageSize.height * (pageWidthFitted / pageSize.width);

      if (top > scrollY) return i;
    }

    return pages.length - 1;
  }
}

class CanvasGestureDetectorState extends State<CanvasGestureDetector> {
  late var containerBounds = const BoxConstraints();
  final _palmEngine = PalmRejectionEngine();

  /// If zooming is locked, this is the zoom level.
  /// Otherwise, this is null.
  late double? zoomLockedValue = stows.lastZoomLock.value
      ? widget._transformationController.value.maxScale2D
      : null;

  /// Whether single-finger panning is locked.
  /// Two-finger panning is always enabled.
  late bool singleFingerPanLock = stows.lastSingleFingerPanLock.value;

  /// Whether panning is locked to being horizontal or vertical.
  /// Otherwise, panning can be done in any (i.e. diagonal) direction.
  late bool axisAlignedPanLock = stows.lastAxisAlignedPanLock.value;

  /// Whether the protractor overlay is visible.
  var showProtractor = false;

  final Map<AxisDirection, Timer> _arrowKeyPanTimers = {};
  var _setupKeybindings = false;
  late Keybinding _ctrlPlus, _ctrlEquals, _ctrlMinus;
  late Keybinding _leftKey, _rightKey, _upKey, _downKey;

  Timer? _snapZoomTimer;
  var _isGestureActive = false;

  final Map<int, Offset> _pointerPositions = {};
  DateTime? _multiPointerDownTime;
  var _maxPointerCountDuringGesture = 0;
  var _multiPointerMoved = false;
  var stylusButtonWasPressed = false;

  @visibleForTesting
  static Matrix4? setZoom({
    required double scaleDelta,
    required Matrix4 transformation,
    required BoxConstraints containerBounds,
    double minScale = CanvasGestureDetector.kMinScale,
  }) {
    if (!containerBounds.hasBoundedWidth ||
        !containerBounds.hasBoundedHeight ||
        containerBounds.maxWidth <= 0 ||
        containerBounds.maxHeight <= 0) {
      return null;
    }
    final oldScale = transformation.maxScale2D;
    if (!oldScale.isFinite || oldScale <= 0) return null;
    double newScale = oldScale + scaleDelta;

    if (scaleDelta < 0 && oldScale <= minScale) {
      return null;
    }
    if (scaleDelta > 0 && oldScale >= CanvasGestureDetector.kMaxScale) {
      return null;
    }

    if (newScale < minScale) {
      if (oldScale > minScale) {
        newScale = minScale;
      } else {
        return null;
      }
    }
    if (newScale > CanvasGestureDetector.kMaxScale) {
      if (oldScale < CanvasGestureDetector.kMaxScale) {
        newScale = CanvasGestureDetector.kMaxScale;
      } else {
        return null;
      }
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

  @override
  void initState() {
    setInitialTransform();
    widget._transformationController.addListener(onTransformChanged);
    _assignKeybindings();
    super.initState();
  }

  /// When the widget is created, we still have an empty coreInfo.
  /// Wait for note to be loaded before setting the initial transform.
  @override
  void didUpdateWidget(CanvasGestureDetector oldWidget) {
    if (oldWidget.initialPageIndex != widget.initialPageIndex ||
        oldWidget.explicitPageIndex != widget.explicitPageIndex ||
        oldWidget.filePath != widget.filePath) {
      setInitialTransform();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// Sets the initial transform so that we're scrolled to the correct page.
  /// Has no effect if note hasn't yet loaded or if the user has already scrolled.
  void setInitialTransform() {
    final cached = widget.filePath.isEmpty
        ? null
        : CanvasTransformCache.get(widget.filePath);
    final choice = chooseCanvasOpenTarget(
      noteLoaded: widget.filePath.isNotEmpty,
      userHasScrolled: !widget._transformationController.value.isIdentity(),
      cachedTransform: cached?.transform,
      isInfiniteCanvas: widget.isInfiniteCanvas,
      explicitPageIndex: widget.explicitPageIndex,
      savedPageIndex: widget.initialPageIndex,
    );

    switch (choice.scroll) {
      case CanvasOpenScroll.unchanged:
        return;
      case CanvasOpenScroll.restoreCache:
        final transform = cached!.transform;
        widget._transformationController.value = transform;
        if (zoomLockedValue != null) {
          zoomLockedValue = transform.maxScale2D;
        }
      case CanvasOpenScroll.scrollToPage:
        CanvasGestureDetector.scrollToPage(
          pageIndex: choice.pageIndex!,
          pages: widget.pages,
          screenWidth: MediaQuery.sizeOf(context).width,
          transformationController: widget._transformationController,
        );
      case CanvasOpenScroll.identity:
        widget._transformationController.value = Matrix4.identity();
    }
  }

  var _isAdjustingTransform = false;

  void _scheduleSnapZoomIfNeeded() {
    _snapZoomTimer?.cancel();
    if (_isGestureActive) return;
    final scale = widget._transformationController.value.maxScale2D;
    if (!scale.isFinite || scale <= 0) return;

    final diffFrom1 = (scale - 1).abs();
    if (diffFrom1 < 0.05 && diffFrom1 > 0.001) {
      _snapZoomTimer = Timer(const Duration(milliseconds: 200), resetZoom);
    }
  }

  ({double dx, double dy}) _computeBoundsAdjustment(Matrix4 matrix) {
    if (widget.isInfiniteCanvas) return (dx: 0.0, dy: 0.0);
    final scale = matrix.maxScale2D;
    if (!scale.isFinite || scale <= 0) return (dx: 0.0, dy: 0.0);

    final translation = matrix.getTranslation();
    double adjustmentX = 0;
    double adjustmentY = 0;

    if (scale < 1) {
      if (containerBounds.hasBoundedWidth && containerBounds.maxWidth > 0) {
        final center = containerBounds.maxWidth * (1 - scale) / 2;
        adjustmentX = center - translation.x;
      }
      if (containerBounds.hasBoundedHeight &&
          containerBounds.maxHeight > 0 &&
          widget.pages.isNotEmpty) {
        final totalContentHeight =
            CanvasGestureDetector.getTopOfPage(
              pageIndex: widget.pages.length,
              pages: widget.pages,
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
    } else {
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
    }

    return (dx: adjustmentX, dy: adjustmentY);
  }

  Matrix4 _constrainTransformMatrix(Matrix4 matrix) {
    final adjustment = _computeBoundsAdjustment(matrix);
    if (adjustment.dx == 0.0 && adjustment.dy == 0.0) return matrix;
    return matrix.clone()
      ..leftTranslateByDouble(adjustment.dx, adjustment.dy, 0, 1);
  }

  bool _shouldRebuildPages(
    Matrix4 oldMatrix,
    Matrix4 newMatrix,
    Size viewportSize,
  ) {
    final oldScale = oldMatrix.maxScale2D;
    final newScale = newMatrix.maxScale2D;
    if (!oldScale.isFinite ||
        oldScale <= 0 ||
        !newScale.isFinite ||
        newScale <= 0) {
      return false;
    }

    if (CanvasPainter.visualScaleBucket(oldScale) !=
        CanvasPainter.visualScaleBucket(newScale)) {
      return true;
    }
    if (CanvasBackgroundPainter.quantizedScaleForInfinite(oldScale) !=
        CanvasBackgroundPainter.quantizedScaleForInfinite(newScale)) {
      return true;
    }

    final viewport = Offset.zero & viewportSize;
    final oldBounds = _axisAlignedBoundingBox(
      canvasTransformViewport(oldMatrix, viewport),
    );
    final newBounds = _axisAlignedBoundingBox(
      canvasTransformViewport(newMatrix, viewport),
    );

    if (widget.isInfiniteCanvas) {
      if (CanvasBackgroundPainter.quantizedInfiniteRect(oldBounds, oldScale) !=
          CanvasBackgroundPainter.quantizedInfiniteRect(newBounds, newScale)) {
        return true;
      }
      if ((oldScale > 1.5 || newScale > 1.5) &&
          CanvasPainter.quantizedHighZoomViewport(oldBounds, oldScale) !=
              CanvasPainter.quantizedHighZoomViewport(newBounds, newScale)) {
        return true;
      }
      return false;
    }

    final containerWidth =
        containerBounds.hasBoundedWidth && containerBounds.maxWidth > 0
        ? containerBounds.maxWidth
        : viewportSize.width;
    final firstPageWidth = widget.pages.isNotEmpty
        ? widget.pages.first.size.width
        : 1000.0;
    final fittedRatio = firstPageWidth > 0
        ? min(firstPageWidth, containerWidth) / firstPageWidth
        : min(containerWidth / 1000.0, 1.0);
    final oldChrome = oldScale * fittedRatio < 0.35 || oldScale > 1.8;
    final newChrome = newScale * fittedRatio < 0.35 || newScale > 1.8;
    if (oldChrome != newChrome) return true;

    final checkHighZoom = oldScale > 1.5 || newScale > 1.5;
    double topOfPage = Editor.gapBetweenPages * 2;
    for (int pageIndex = 0; pageIndex < widget.pages.length; pageIndex++) {
      final page = widget.pages[pageIndex];
      final pageWidth = min(page.size.width, containerWidth);
      final pageHeight = pageWidth / page.size.width * page.size.height;
      final bottomOfPage = topOfPage + pageHeight;

      final wasInViewport =
          oldBounds.bottom >= topOfPage && oldBounds.top <= bottomOfPage;
      final isInViewport =
          newBounds.bottom >= topOfPage && newBounds.top <= bottomOfPage;
      if (wasInViewport != isInViewport) return true;

      if (checkHighZoom && isInViewport) {
        final oldPageLocal = _computePageLocalViewport(
          pageSize: page.size,
          pageWidth: pageWidth,
          topOfPage: topOfPage,
          containerWidth: containerWidth,
          boundingBox: oldBounds,
        );
        final newPageLocal = _computePageLocalViewport(
          pageSize: page.size,
          pageWidth: pageWidth,
          topOfPage: topOfPage,
          containerWidth: containerWidth,
          boundingBox: newBounds,
        );
        if (CanvasPainter.quantizedHighZoomViewport(oldPageLocal, oldScale) !=
            CanvasPainter.quantizedHighZoomViewport(newPageLocal, newScale)) {
          return true;
        }
      }

      topOfPage = bottomOfPage + Editor.gapBetweenPages;
    }

    return false;
  }

  /// Corrects the transform if it's out of bounds.
  /// If the scale is less than 1, centers the pages horizontally.
  /// Otherwise, prevents the user from scrolling past the edges.
  void onTransformChanged() {
    if (_isAdjustingTransform) return;
    final scale = widget._transformationController.value.maxScale2D;
    if (!scale.isFinite || scale <= 0) return;

    _scheduleSnapZoomIfNeeded();

    if (widget.isInfiniteCanvas) return;

    final adjustment = _computeBoundsAdjustment(
      widget._transformationController.value,
    );
    if (adjustment.dx.abs() > 0.1 || adjustment.dy.abs() > 0.1) {
      _isAdjustingTransform = true;
      try {
        widget._transformationController.value =
            widget._transformationController.value.clone()
              ..leftTranslateByDouble(adjustment.dx, adjustment.dy, 0, 1);
      } finally {
        _isAdjustingTransform = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          onPointerDown: _listenerPointerEvent,
          onPointerMove: _listenerPointerEvent,
          onPointerUp: _listenerPointerUpEvent,
          onPointerCancel: _listenerPointerUpEvent,
          onPointerHover: _listenerPointerHoverEvent,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints containerBounds) {
              this.containerBounds = containerBounds;

              final effectiveMinScale = CanvasGestureDetector.minScaleFor(
                isInfiniteCanvas: widget.isInfiniteCanvas,
              );

              return InteractiveCanvasViewer.builder(
                palmEngine: _palmEngine,
                minScale: zoomLockedValue ?? effectiveMinScale,
                maxScale: zoomLockedValue ?? CanvasGestureDetector.kMaxScale,
                panEnabled: !singleFingerPanLock,
                panAxis: axisAlignedPanLock ? PanAxis.aligned : PanAxis.free,

                // Smoother scrolling fling gesture than the default
                interactionEndFrictionCoefficient: 0.3,

                // we need a non-zero boundary margin so we can zoom out
                // past the size of the page (for minScale < 1)
                boundaryMargin: const EdgeInsets.all(double.infinity),

                transformationController: widget._transformationController,

                isDrawGesture: widget.isDrawGesture,
                onInteractionStart: (_) {
                  _isGestureActive = true;
                  _snapZoomTimer?.cancel();
                },
                onInteractionEnd: (details) {
                  _isGestureActive = false;
                  _scheduleSnapZoomIfNeeded();
                  widget.onInteractionEnd?.call(details);
                },
                constrainMatrix: _constrainTransformMatrix,
                shouldRebuildBuilder: _shouldRebuildPages,
                onDrawStart: widget.onDrawStart,
                onDrawUpdate: widget.onDrawUpdate,
                onDrawEnd: widget.onDrawEnd,

                builder: (BuildContext context, Quad viewport) {
                  return _PagesBuilder(
                    pages: widget.pages,
                    pageBuilder: widget.pageBuilder,
                    placeholderPageBuilder: widget.placeholderPageBuilder,
                    boundingBox: _axisAlignedBoundingBox(viewport),
                    containerWidth: containerBounds.maxWidth,
                    isInfiniteCanvas: widget.isInfiniteCanvas,
                  );
                },
              );
            },
          ),
        ),
        if (showProtractor) const ProtractorOverlay(),
        Positioned.fill(
          child: RepaintBoundary(
            child: CanvasHud(
              transformationController: widget._transformationController,
              zoomLock: zoomLockedValue != null,
              setZoomLock: (bool zoomLock) => setState(() {
                zoomLockedValue = zoomLock
                    ? widget._transformationController.value.maxScale2D
                    : null;
                stows.lastZoomLock.value = zoomLock;
              }),
              resetZoom: zoomLockedValue != null ? null : resetZoom,
              singleFingerPanLock: singleFingerPanLock,
              setSingleFingerPanLock: (bool singleFingerPanLock) =>
                  setState(() {
                    this.singleFingerPanLock = singleFingerPanLock;
                    stows.lastSingleFingerPanLock.value = singleFingerPanLock;
                  }),
              axisAlignedPanLock: axisAlignedPanLock,
              setAxisAlignedPanLock: (bool axisAlignedPanLock) => setState(() {
                this.axisAlignedPanLock = axisAlignedPanLock;
                stows.lastAxisAlignedPanLock.value = axisAlignedPanLock;
              }),
              showProtractor: showProtractor,
              setShowProtractor: (bool visible) => setState(() {
                showProtractor = visible;
              }),
              bookmarked: widget.bookmarked,
              onToggleBookmarked: widget.onToggleBookmarked,
              hasTape: widget.hasTape,
              onRevealAllTape: widget.onRevealAllTape,
              onConcealAllTape: widget.onConcealAllTape,
              isInfiniteCanvas: widget.isInfiniteCanvas,
              onFitContent: widget.onFitContent,
            ),
          ),
        ),
        if (widget.activePage != null)
          Positioned(
            bottom: 24,
            left: 16,
            child: ValueListenableBuilder<bool>(
              valueListenable: stows.showFloatingLayersHud,
              builder: (context, show, _) {
                if (!show) return const SizedBox.shrink();
                return FloatingLayersOverlay(
                  page: widget.activePage,
                  onChanged: () {
                    widget.activePage?.redrawStrokes();
                    widget.onLayersChanged?.call();
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _snapZoomTimer?.cancel();
    CanvasTransformCache.add(
      widget.filePath,
      widget._transformationController.value,
    );
    widget._transformationController.removeListener(onTransformChanged);
    widget._transformationController.dispose();
    _removeKeybindings();
    super.dispose();
  }

  /// Returns the axis aligned bounding box for the given Quad,
  /// which might not be axis aligned.
  /// From https://api.flutter.dev/flutter/widgets/InteractiveViewer/builder.html
  static Rect _axisAlignedBoundingBox(Quad quad) {
    final List<Vector3> points = [
      quad.point0,
      quad.point1,
      quad.point2,
      quad.point3,
    ];

    final left = points.map((point) => point.x).reduce(min);
    final right = points.map((point) => point.x).reduce(max);
    final top = points.map((point) => point.y).reduce(min);
    final bottom = points.map((point) => point.y).reduce(max);

    return .fromLTRB(left, top, right, bottom);
  }
}
