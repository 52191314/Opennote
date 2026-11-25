/// 🤖 Generated wholely or partially with Google Antigravity
part of 'editor.dart';

extension EditorGestureHandlers on EditorState {
  int? onWhichPageIsFocalPoint(Offset focalPoint) {
    if (coreInfo.isInfiniteCanvas && coreInfo.pages.isNotEmpty) {
      return 0;
    }
    int? closestIndex;
    double minDistance = double.infinity;
    for (int i = 0; i < coreInfo.pages.length; ++i) {
      final box = coreInfo.pages[i].renderBox;
      if (box == null || !box.attached) continue;
      final local = box.globalToLocal(focalPoint);
      final pageBounds = Offset.zero & coreInfo.pages[i].size;
      if (pageBounds.contains(local)) return i;

      final dx = local.dx < 0
          ? -local.dx
          : (local.dx > pageBounds.width ? local.dx - pageBounds.width : 0.0);
      final dy = local.dy < 0
          ? -local.dy
          : (local.dy > pageBounds.height ? local.dy - pageBounds.height : 0.0);
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < minDistance) {
        minDistance = dist;
        closestIndex = i;
      }
    }
    // Snap to closest page if within 120 screen px (gap between pages or margin)
    final safeScale = (currentScale.isFinite && currentScale > 0)
        ? currentScale.clamp(0.05, 1.0)
        : 1.0;
    if (closestIndex != null && minDistance <= 120.0 / safeScale) {
      return closestIndex;
    }
    return null;
  }

  bool isDrawGesture(ScaleStartDetails details) {
    if (coreInfo.readOnly || _isHandScrollOnlyMode) return false;

    CanvasImage.deactivateAll(); // un-select active image

    final isStylus =
        currentPointerKind == PointerDeviceKind.stylus ||
        currentPointerKind == PointerDeviceKind.invertedStylus ||
        currentPressure != null;

    _lastSeenPointerCountTimer?.cancel();

    if (!isStylus) {
      if (lastSeenPointerCount >= 2) {
        // Was a zoom gesture; consume this trailing touch and reset so future strokes succeed
        lastSeenPointerCount = 0;
        return false;
      } else if (details.pointerCount >= 2) {
        // is a zoom gesture, remove accidental stroke
        if (lastSeenPointerCount == 1 &&
            stows.editorFingerDrawing.value &&
            (currentTool is Pen || currentTool is Eraser)) {
          final item = history.removeAccidentalStroke();
          if (item != null) undo(item);
        }
        lastSeenPointerCount = details.pointerCount;
        return false;
      } else {
        // is a stroke
        lastSeenPointerCount = details.pointerCount;
      }
    } else {
      // Stylus is a precision hardware tool; never blocked by prior multi-finger zoom residue
      lastSeenPointerCount = 1;
      if (details.pointerCount >= 2) return false;
    }

    dragPageIndex = onWhichPageIsFocalPoint(details.focalPoint);
    if (dragPageIndex == null) return false;

    if (currentTool == Tool.textEditing) {
      return false;
    } else if (stows.editorFingerDrawing.value || isStylus) {
      return true;
    } else {
      log.fine('Non-stylus found, rejected stroke');
      return false;
    }
  }

  void onDrawStart(ScaleStartDetails details) {
    if (dragPageIndex == null || dragPageIndex! >= coreInfo.pages.length)
      return;
    final page = coreInfo.pages[dragPageIndex!];
    final box = page.renderBox;
    if (box == null || !box.attached) return;
    final position = box.globalToLocal(details.focalPoint);
    _lastCanvasTapPosition = position;
    _lastCanvasTapPageIndex = dragPageIndex;
    _lastCanvasTapTime = DateTime.now();
    final wasRedoEnabled = history.canRedo;
    history.canRedo = false;
    _selectGesture.forgetTransform();
    if (_isLockedForDrawing(page)) return;

    final isTracked = _gesture?.start(_pointerAt(page, position)) ?? true;
    if (!isTracked) return;

    previousPosition = position;
    moveOffset = .zero;
    final hadSelection =
        currentTool is! Select &&
        (Select.currentSelect.doneSelecting ||
            Select.currentSelect.selectResult.isNotEmpty);
    if (currentTool is! Select) Select.currentSelect.unselect();

    final isDirectDrawTool =
        currentTool is Pen ||
        currentTool is Eraser ||
        currentTool is LaserPointer;
    if (isDirectDrawTool && !hadSelection && !wasRedoEnabled) {
      _activeStrokeNotifier.value = Pen.currentStroke;
      page.redrawStrokes();
      return;
    }
    _activeStrokeNotifier.value = Pen.currentStroke;
    _refreshUi();
  }

  void onDrawUpdate(ScaleUpdateDetails details) {
    if (dragPageIndex == null || dragPageIndex! >= coreInfo.pages.length)
      return;
    final page = coreInfo.pages[dragPageIndex!];
    if (_isLockedForDrawing(page)) return;

    final box = page.renderBox;
    if (box == null || !box.attached) return;
    final position = box.globalToLocal(details.focalPoint);
    final delta = position - previousPosition;
    _gesture?.update(_pointerAt(page, position, delta: delta));
    previousPosition = position;
    moveOffset += delta;
  }

  void onDrawEnd(ScaleEndDetails details) {
    if (dragPageIndex == null || dragPageIndex! >= coreInfo.pages.length)
      return;
    final page = coreInfo.pages[dragPageIndex!];
    if (_isLockedForDrawing(page)) return _abandonDraw(page);

    final previousStrokeCount = page.strokes.length;
    final willSnapShape = _willSnapCurrentStroke();
    var shouldSave = true;
    _refreshUi(() {
      shouldSave = _gesture?.end(_pointerAt(page, previousPosition)) ?? true;
      _activeStrokeNotifier.value = null;
    });
    if (willSnapShape && page.strokes.length > previousStrokeCount) {
      HapticFeedback.mediumImpact();
    }
    _hideDrawCursors(page);
    _selectGesture.releaseHandle();
    if (shouldSave) autosaveAfterDelay();
  }

  /// Whether the in-flight pen stroke is about to snap into a recognized shape
  /// or auto-straightened line when the drag ends.
  bool _willSnapCurrentStroke() {
    final stroke = Pen.currentStroke;
    if (stroke == null || stroke.isEmpty) return false;
    if (currentTool is ShapePen) {
      return (ShapePen.detectedShape ?? stroke.detectShape())?.name != null;
    }
    if (currentTool is Pen &&
        (stows.autoStraightenLines.value || currentTool is Highlighter)) {
      return stroke.isStraightLine();
    }
    return false;
  }

  /// The gesture that draws with [currentTool], if it is a drawing tool.
  ToolGesture? get _gesture => switch (currentTool) {
    Pen() => _penGesture,
    Eraser() => _eraserGesture,
    Select() => _selectGesture,
    LaserPointer() => EditorState._laserGesture,
    _ => null,
  };

  /// Whether [page]'s active layer is locked against [currentTool].
  bool _isLockedForDrawing(EditorPage page) =>
      page.activeLayer.locked && (currentTool is Pen || currentTool is Eraser);

  GesturePointer _pointerAt(
    EditorPage page,
    Offset position, {
    Offset delta = .zero,
  }) => GesturePointer(
    page: page,
    pageIndex: dragPageIndex!,
    position: position,
    delta: delta,
    moved: moveOffset,
    pressure: currentPressure,
  );

  /// Ends a draw gesture that a locked layer refused, keeping nothing.
  void _abandonDraw(EditorPage page) {
    switch (currentTool) {
      case final Pen pen:
        pen.onDragEnd();
      case final Eraser eraser:
        eraser.onDragEnd();
      default:
    }
    _activeStrokeNotifier.value = null;
    _hideDrawCursors(page);
    _selectGesture.releaseHandle();
  }

  void _hideDrawCursors(EditorPage page) {
    page
      ..eraserCursorPosition = null
      ..eraserCursorRadius = null
      ..penPreviewPosition = null
      ..penPreviewRadius = null
      ..penPreviewColor = null;
  }

  void _restoreToolAfterErasingImpl() {
    if (!stylusButtonWasPressed && !stows.disableEraserAfterUse.value) return;
    stylusButtonWasPressed = false;
    currentTool = _lastNonEraserTool;
  }

  void onInteractionEnd(ScaleEndDetails details) {
    // reset after 1ms to keep track of the same gesture only
    _lastSeenPointerCountTimer?.cancel();
    _lastSeenPointerCountTimer = Timer(const Duration(milliseconds: 10), () {
      lastSeenPointerCount = 0;
    });
  }

  void updatePointerData(PointerDeviceKind kind, double? pressure) {
    currentPointerKind = kind;
    currentPressure = pressure;
  }

  void onHovering() {
    isHovering = true;
  }

  void onHoveringEnd() {
    isHovering = false;
  }

  void onStylusButtonChanged(bool buttonIsPressed) {
    stylusButtonWasPressed |= buttonIsPressed;

    if (!isHovering) return;
    if (buttonIsPressed) {
      // button pressed while hovering, switch to Eraser
      if (currentTool is! Eraser) {
        currentTool = Eraser(size: stows.eraserSize.value);
      }
    } else {
      // button was released while hovering, switch back to non-Eraser
      if (currentTool is Eraser) {
        currentTool = _lastNonEraserTool;
      }
    }

    if (mounted) _refreshUi();
  }

  void onMoveImage(EditorImage image, Rect offset) {
    history.recordChange(
      EditorHistoryItem(
        type: .move,
        pageIndex: image.pageIndex,
        strokes: [],
        images: [image],
        offset: offset,
      ),
    );
    // setState to update undo button
    _refreshUi();
    autosaveAfterDelay();
  }

  void onDeleteImage(EditorImage image) {
    history.recordChange(
      EditorHistoryItem(
        type: .erase,
        pageIndex: image.pageIndex,
        strokes: [],
        images: [image],
      ),
    );
    _refreshUi(() {
      coreInfo.pages[image.pageIndex].images.remove(image);
    });
    autosaveAfterDelay();
  }
}
