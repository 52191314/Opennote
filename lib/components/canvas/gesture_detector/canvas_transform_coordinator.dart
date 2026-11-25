/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
part of '../canvas_gesture_detector.dart';

/// Transform lifecycle, bounds clamping, snap-zoom, and HUD coordination
/// for [CanvasGestureDetectorState].
extension CanvasGestureTransformCoordinator on CanvasGestureDetectorState {
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

  /// Corrects the transform if it's out of bounds.
  /// If the scale is less than 1, centers the pages horizontally.
  /// Otherwise, prevents the user from scrolling past the edges.
  void onTransformChanged() {
    if (_isAdjustingTransform) return;
    final scale = widget._transformationController.value.maxScale2D;
    if (!scale.isFinite || scale <= 0) return;

    _scheduleSnapZoomIfNeeded();
    if (widget.isInfiniteCanvas) return;

    final adjustment = CanvasZoomPhysics.computeBoundsAdjustment(
      matrix: widget._transformationController.value,
      containerBounds: containerBounds,
      pages: widget.pages,
      isInfiniteCanvas: widget.isInfiniteCanvas,
    );
    if (adjustment.dx.abs() <= 0.1 && adjustment.dy.abs() <= 0.1) return;

    _isAdjustingTransform = true;
    try {
      widget._transformationController.value =
          widget._transformationController.value.clone()
            ..leftTranslateByDouble(adjustment.dx, adjustment.dy, 0, 1);
    } finally {
      _isAdjustingTransform = false;
    }
  }

  void _scheduleSnapZoomIfNeeded() {
    _snapZoomTimer?.cancel();
    if (_isGestureActive || _pointerPositions.isNotEmpty) return;

    final scale = widget._transformationController.value.maxScale2D;
    if (!CanvasZoomPhysics.shouldSnapZoomToOne(scale)) return;

    _snapZoomTimer = Timer(const Duration(milliseconds: 200), resetZoom);
  }

  Matrix4 _constrainTransformMatrix(Matrix4 matrix) =>
      CanvasZoomPhysics.constrainTransformMatrix(
        matrix: matrix,
        containerBounds: containerBounds,
        pages: widget.pages,
        isInfiniteCanvas: widget.isInfiniteCanvas,
      );

  bool _shouldRebuildPages(
    Matrix4 oldMatrix,
    Matrix4 newMatrix,
    Size viewportSize,
  ) {
    final result = CanvasViewportProjection.evaluatePageRebuild(
      oldMatrix: oldMatrix,
      newMatrix: newMatrix,
      viewportSize: viewportSize,
      containerBounds: containerBounds,
      pages: widget.pages,
      isInfiniteCanvas: widget.isInfiniteCanvas,
      isGestureActive: _isGestureActive,
    );
    if (result.shouldRebuild) {
      _needsHighZoomRefresh = false;
      return true;
    }
    if (result.markHighZoomRefresh) {
      _needsHighZoomRefresh = true;
    }
    return false;
  }

  void _handleInteractionStart(ScaleStartDetails _) {
    _isGestureActive = true;
    _snapZoomTimer?.cancel();
  }

  void _handleInteractionEnd(ScaleEndDetails details) {
    _isGestureActive = false;
    _scheduleSnapZoomIfNeeded();
    if (_needsHighZoomRefresh && mounted) {
      _needsHighZoomRefresh = false;
      final scale = widget._transformationController.value.maxScale2D;
      if (scale.isFinite && scale > 1.5) {
        _requestRebuild();
      }
    }
    widget.onInteractionEnd?.call(details);
  }

  Widget _buildInteractiveViewer(BoxConstraints containerBounds) {
    this.containerBounds = containerBounds;
    final effectiveMinScale = CanvasGestureDetector.minScaleFor(
      isInfiniteCanvas: widget.isInfiniteCanvas,
    );

    return InteractiveCanvasViewer.builder(
      palmEngine: _palmEngine,
      expandWidth: widget.isInfiniteCanvas,
      minScale: zoomLockedValue ?? effectiveMinScale,
      maxScale: zoomLockedValue ?? CanvasGestureDetector.kMaxScale,
      panEnabled: !singleFingerPanLock,
      panAxis: axisAlignedPanLock ? PanAxis.aligned : PanAxis.free,
      interactionEndFrictionCoefficient: 0.3,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      transformationController: widget._transformationController,
      isDrawGesture: widget.isDrawGesture,
      onInteractionStart: _handleInteractionStart,
      onInteractionEnd: _handleInteractionEnd,
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
          boundingBox: CanvasViewportProjection.axisAlignedBoundingBox(
            viewport,
          ),
          containerWidth: containerBounds.maxWidth,
          isInfiniteCanvas: widget.isInfiniteCanvas,
        );
      },
    );
  }

  Widget _buildHudOverlay() => Positioned.fill(
    child: RepaintBoundary(
      child: CanvasHud(
        transformationController: widget._transformationController,
        zoomLock: zoomLockedValue != null,
        setZoomLock: (bool zoomLock) => _updateState(() {
          zoomLockedValue = zoomLock
              ? widget._transformationController.value.maxScale2D
              : null;
          stows.lastZoomLock.value = zoomLock;
        }),
        resetZoom: zoomLockedValue != null ? null : resetZoom,
        singleFingerPanLock: singleFingerPanLock,
        setSingleFingerPanLock: (bool locked) => _updateState(() {
          singleFingerPanLock = locked;
          stows.lastSingleFingerPanLock.value = locked;
        }),
        axisAlignedPanLock: axisAlignedPanLock,
        setAxisAlignedPanLock: (bool locked) => _updateState(() {
          axisAlignedPanLock = locked;
          stows.lastAxisAlignedPanLock.value = locked;
        }),
        showProtractor: showProtractor,
        setShowProtractor: (bool visible) => _updateState(() {
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
  );

  Widget _buildFloatingLayersOverlay() => Positioned(
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
  );
}
