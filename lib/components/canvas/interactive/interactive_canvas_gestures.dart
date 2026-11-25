/// 🤖 Generated wholely or partially with Claude Code; Gemini; Google Antigravity
part of '../interactive_canvas.dart';

// ignore_for_file: omit_obvious_property_types

extension _InteractiveCanvasViewerGestures on _InteractiveCanvasViewerState {
  Matrix4 _constrain(Matrix4 matrix) =>
      widget.constrainMatrix?.call(matrix) ?? matrix;

  // Return a new matrix representing the given matrix after applying the given
  // translation.
  Matrix4 _matrixTranslate(Matrix4 matrix, Offset translation) {
    if (translation == .zero) {
      return matrix.clone();
    }

    final Offset alignedTranslation;

    if (_currentAxis != null) {
      alignedTranslation = switch (widget.panAxis) {
        PanAxis.horizontal => canvasAlignAxis(translation, Axis.horizontal),
        PanAxis.vertical => canvasAlignAxis(translation, Axis.vertical),
        PanAxis.aligned => canvasAlignAxis(translation, _currentAxis!),
        PanAxis.free => translation,
      };
    } else {
      alignedTranslation = translation;
    }

    final Matrix4 nextMatrix = matrix.clone()
      ..translateByDouble(alignedTranslation.dx, alignedTranslation.dy, 0, 1);

    // If the boundaries are infinite, then no need to check if the translation
    // fits within them.
    if (_hasInfiniteBoundaryMargin || _boundaryRect.isInfinite) {
      return nextMatrix;
    }

    // Transform the viewport to determine where its four corners will be after
    // the child has been transformed.
    final Quad nextViewport = canvasTransformViewport(nextMatrix, _viewport);

    // Expand the boundaries with rotation. This prevents the problem where a
    // mismatch in orientation between the viewport and boundaries effectively
    // limits translation. With this approach, all points that are visible with
    // no rotation are visible after rotation.
    final Quad boundariesAabbQuad = canvasGetAxisAlignedBoundingBoxWithRotation(
      _boundaryRect,
      _currentRotation,
    );

    // If the given translation fits completely within the boundaries, allow it.
    final Offset offendingDistance = canvasExceedsBy(
      boundariesAabbQuad,
      nextViewport,
    );
    if (offendingDistance == .zero) {
      return nextMatrix;
    }

    // Desired translation goes out of bounds, so translate to the nearest
    // in-bounds point instead.
    final Offset nextTotalTranslation = canvasGetMatrixTranslation(nextMatrix);
    final double currentScale = matrix.maxScale2D;
    final Offset correctedTotalTranslation = Offset(
      nextTotalTranslation.dx - offendingDistance.dx * currentScale,
      nextTotalTranslation.dy - offendingDistance.dy * currentScale,
    );
    // -TODO(justinmc): This needs some work to handle rotation properly. The
    // idea is that the boundaries are axis aligned (boundariesAabbQuad), but
    // calculating the translation to put the viewport inside that Quad is more
    // complicated than this when rotated.
    // https://github.com/flutter/flutter/issues/57698
    final Matrix4 correctedMatrix = matrix.clone()
      ..setTranslation(
        Vector3(correctedTotalTranslation.dx, correctedTotalTranslation.dy, 0),
      );

    // Double check that the corrected translation fits.
    final Quad correctedViewport = canvasTransformViewport(
      correctedMatrix,
      _viewport,
    );
    final Offset offendingCorrectedDistance = canvasExceedsBy(
      boundariesAabbQuad,
      correctedViewport,
    );
    if (offendingCorrectedDistance == .zero) {
      return correctedMatrix;
    }

    // If the corrected translation doesn't fit in either direction, don't allow
    // any translation at all. This happens when the viewport is larger than the
    // entire boundary.
    if (offendingCorrectedDistance.dx != 0.0 &&
        offendingCorrectedDistance.dy != 0.0) {
      return matrix.clone();
    }

    // Otherwise, allow translation in only the direction that fits. This
    // happens when the viewport is larger than the boundary in one direction.
    final Offset unidirectionalCorrectedTotalTranslation = Offset(
      offendingCorrectedDistance.dx == 0.0 ? correctedTotalTranslation.dx : 0.0,
      offendingCorrectedDistance.dy == 0.0 ? correctedTotalTranslation.dy : 0.0,
    );
    return matrix.clone()..setTranslation(
      Vector3(
        unidirectionalCorrectedTotalTranslation.dx,
        unidirectionalCorrectedTotalTranslation.dy,
        0,
      ),
    );
  }

  // Return a new matrix representing the given matrix after applying the given
  // scale.
  Matrix4 _matrixScale(Matrix4 matrix, double scale) {
    if (!scale.isFinite || scale <= 0.0 || scale == 1.0) {
      return matrix.clone();
    }

    // Don't allow a scale that results in an overall scale beyond min/max
    // scale.
    final double currentScale = matrix.maxScale2D;
    if (!currentScale.isFinite || currentScale <= 0.0) {
      return matrix.clone();
    }
    final double minBoundScale =
        (_hasInfiniteBoundaryMargin || _boundaryRect.isInfinite)
        ? 0.0
        : math.max(
            _viewport.width / _boundaryRect.width,
            _viewport.height / _boundaryRect.height,
          );
    final double totalScale = math.max(currentScale * scale, minBoundScale);
    final double clampedTotalScale = clampDouble(
      totalScale,
      widget.minScale,
      widget.maxScale,
    );
    final double clampedScale = clampedTotalScale / currentScale;
    if (!clampedScale.isFinite || clampedScale <= 0.0) {
      return matrix.clone();
    }
    return matrix.clone()..scaleByDouble(clampedScale, clampedScale, 1.0, 1.0);
  }

  // Return a new matrix representing the given matrix after applying the given
  // rotation.
  Matrix4 _matrixRotate(Matrix4 matrix, double rotation, Offset focalPoint) {
    if (rotation == 0) {
      return matrix.clone();
    }
    final Offset focalPointScene = _toScene(focalPoint);
    return matrix.clone()
      ..translateByDouble(focalPointScene.dx, focalPointScene.dy, 0, 1)
      ..rotateZ(-rotation)
      ..translateByDouble(-focalPointScene.dx, -focalPointScene.dy, 0, 1);
  }

  // Returns true iff the given _GestureType is enabled.
  bool _gestureIsSupported(_GestureType? gestureType, [int pointerCount = 1]) {
    return switch (gestureType) {
      _GestureType.rotate => _rotateEnabled,
      _GestureType.scale => widget.scaleEnabled,
      _GestureType.pan || null => widget.panEnabled || pointerCount >= 2,
    };
  }

  // Decide which type of gesture this is by comparing the amount of scale
  // and rotation in the gesture, if any. Scale starts at 1 and rotation
  // starts at 0. Pan will have no scale and no rotation because it uses only one
  // finger.
  _GestureType _getGestureType(ScaleUpdateDetails details) {
    final double scale = !widget.scaleEnabled ? 1.0 : details.scale;
    final double rotation = !_rotateEnabled ? 0.0 : details.rotation;
    if ((scale - 1).abs() > rotation.abs()) {
      return _GestureType.scale;
    } else if (rotation != 0.0) {
      return _GestureType.rotate;
    } else {
      return _GestureType.pan;
    }
  }

  // Handle the start of a gesture. All of pan, scale, and rotate are handled
  // with GestureDetector's scale gesture.
  void _onScaleStart(ScaleStartDetails details) {
    _stopInertiaAnimation();

    widget.onInteractionStart?.call(details);

    isCurrentGestureADrawGesture = false;
    _gestureType = null;
    _currentAxis = null;
    _scaleStart = _transformer.value.maxScale2D;
    _referenceFocalPoint = _toScene(details.localFocalPoint);
    _rotationStart = _currentRotation;

    if (widget.isDrawGesture?.call(details) ?? false) {
      isCurrentGestureADrawGesture = true;
      widget.onDrawStart?.call(details);
    }
  }

  // Handle an update to an ongoing gesture. All of pan, scale, and rotate are
  // handled with GestureDetector's scale gesture.
  void _onScaleUpdate(ScaleUpdateDetails details) {
    final double scale = _transformer.value.maxScale2D;
    final Offset focalPointScene = _toScene(details.localFocalPoint);

    if (isCurrentGestureADrawGesture && details.pointerCount >= 2) {
      isCurrentGestureADrawGesture = false;
      widget.onDrawEnd?.call(
        ScaleEndDetails(pointerCount: details.pointerCount),
      );
      _gestureType = _getGestureType(details);
      _scaleStart = details.scale >= 0.05 ? (scale / details.scale) : scale;
      _referenceFocalPoint = focalPointScene;
    } else if (isCurrentGestureADrawGesture) {
      _gestureType = _GestureType.pan;
    } else if (_gestureType == _GestureType.pan) {
      // When a gesture first starts, it sometimes has no change in scale and
      // rotation despite being a two-finger gesture. Here the gesture is
      // allowed to be reinterpreted as its correct type after originally
      // being marked as a pan.
      _gestureType = _getGestureType(details);
    } else {
      _gestureType ??= _getGestureType(details);
    }
    if (!_gestureIsSupported(_gestureType, details.pointerCount) &&
        !isCurrentGestureADrawGesture) {
      return;
    }

    switch (_gestureType!) {
      case _GestureType.scale:
        assert(_scaleStart != null);
        if (!details.scale.isFinite ||
            details.scale <= 0.0 ||
            !scale.isFinite ||
            scale <= 0.0) {
          return;
        }
        // details.scale gives us the amount to change the scale as of the
        // start of this gesture, so calculate the amount to scale as of the
        // previous call to _onScaleUpdate.
        final double desiredScale = _scaleStart! * details.scale;
        final double scaleChange = desiredScale / scale;
        final Matrix4 scaledMatrix = _matrixScale(
          _transformer.value,
          scaleChange,
        );
        final double actualScale = scaledMatrix.maxScale2D;
        if ((actualScale - desiredScale).abs() > 1e-9) {
          final double safeDetailScale = details.scale.clamp(0.05, 20.0);
          _scaleStart = actualScale / safeDetailScale;
        }

        // While scaling, translate such that the user's two fingers stay on
        // the same places in the scene. That means that the focal point of
        // the scale should be on the same place in the scene before and after
        // the scale.
        final double det = scaledMatrix.determinant();
        if (!det.isFinite || det.abs() < 1e-12) {
          return;
        }
        final Matrix4 scaledInverse = scaledMatrix.clone()..invert();
        final Vector3 focalVec = scaledInverse.transform3(
          Vector3(details.localFocalPoint.dx, details.localFocalPoint.dy, 0),
        );
        final Offset focalPointSceneScaled = Offset(focalVec.x, focalVec.y);
        final Matrix4 constrained = _constrain(
          _matrixTranslate(
            scaledMatrix,
            focalPointSceneScaled - _referenceFocalPoint!,
          ),
        );
        if (constrained != _transformer.value) {
          _transformer.value = constrained;
        }

        // details.localFocalPoint should now be at the same location as the
        // original _referenceFocalPoint point. If it's not, that's because
        // the translate came in contact with a boundary. In that case, update
        // _referenceFocalPoint so subsequent updates happen in relation to
        // the new effective focal point.
        final Offset focalPointSceneCheck = _toScene(details.localFocalPoint);
        if (canvasRoundOffset(_referenceFocalPoint!) !=
            canvasRoundOffset(focalPointSceneCheck)) {
          _referenceFocalPoint = focalPointSceneCheck;
        }

      case _GestureType.rotate:
        if (details.rotation == 0.0) {
          return;
        }
        final double desiredRotation = _rotationStart! + details.rotation;
        final Matrix4 constrained = _constrain(
          _matrixRotate(
            _transformer.value,
            _currentRotation - desiredRotation,
            details.localFocalPoint,
          ),
        );
        if (constrained != _transformer.value) {
          _transformer.value = constrained;
        }
        _currentRotation = desiredRotation;

      case _GestureType.pan:
        assert(_referenceFocalPoint != null);
        if (isCurrentGestureADrawGesture) {
          widget.onDrawUpdate?.call(details);
          return;
        }

        // details may have a change in scale here when scaleEnabled is false.
        // In an effort to keep the behavior similar whether or not scaleEnabled
        // is true, these gestures are thrown away.
        if (!widget.scaleEnabled && details.scale != 1.0) {
          return;
        }

        _currentAxis ??= canvasGetPanAxis(
          _referenceFocalPoint!,
          focalPointScene,
        );
        // Translate so that the same point in the scene is underneath the
        // focal point before and after the movement.
        final Offset translationChange =
            focalPointScene - _referenceFocalPoint!;
        final Matrix4 constrained = _constrain(
          _matrixTranslate(_transformer.value, translationChange),
        );
        if (constrained != _transformer.value) {
          _transformer.value = constrained;
        }
        _referenceFocalPoint = _toScene(details.localFocalPoint);
    }
  }

  // Handle the end of a gesture of _GestureType. All of pan, scale, and rotate
  // are handled with GestureDetector's scale gesture.
  void _onScaleEnd(ScaleEndDetails details) {
    widget.onInteractionEnd?.call(details);

    final endedGestureType = _gestureType;
    _gestureType = null;
    _scaleStart = null;
    _rotationStart = null;
    _referenceFocalPoint = null;

    if (endedGestureType == _GestureType.scale || details.pointerCount >= 2) {
      _lastMultiTouchEndTime = DateTime.now();
    }

    if (isCurrentGestureADrawGesture) {
      isCurrentGestureADrawGesture = false;
      return widget.onDrawEnd?.call(details);
    }

    _stopInertiaAnimation();

    if (!_gestureIsSupported(endedGestureType, details.pointerCount)) {
      _currentAxis = null;
      return;
    }

    switch (endedGestureType) {
      case _GestureType.pan:
        if (_lastMultiTouchEndTime != null &&
            DateTime.now().difference(_lastMultiTouchEndTime!).inMilliseconds <
                150) {
          _currentAxis = null;
          return;
        }
        if (details.velocity.pixelsPerSecond.distance < kMinFlingVelocity) {
          _currentAxis = null;
          return;
        }
        final Vector3 translationVector = _transformer.value.getTranslation();
        final Offset translation = Offset(
          translationVector.x,
          translationVector.y,
        );
        final FrictionSimulation frictionSimulationX = FrictionSimulation(
          widget.interactionEndFrictionCoefficient,
          translation.dx,
          details.velocity.pixelsPerSecond.dx,
        );
        final FrictionSimulation frictionSimulationY = FrictionSimulation(
          widget.interactionEndFrictionCoefficient,
          translation.dy,
          details.velocity.pixelsPerSecond.dy,
        );
        final double tFinal = canvasGetFinalTime(
          details.velocity.pixelsPerSecond.distance,
          widget.interactionEndFrictionCoefficient,
        );
        _animation = Tween<Offset>(
          begin: translation,
          end: Offset(frictionSimulationX.finalX, frictionSimulationY.finalX),
        ).chain(CurveTween(curve: Curves.decelerate)).animate(_controller);
        _controller.duration = Duration(milliseconds: (tFinal * 1000).round());
        _animation!.addListener(_handleInertiaAnimation);
        _controller.forward();
      case _GestureType.scale || _GestureType.rotate || null:
        _currentAxis = null;
    }
  }

  // Handle mousewheel and web trackpad scroll events.
  void _receivedPointerSignal(PointerSignalEvent event) {
    final Offset local = event.localPosition;
    final Offset global = event.position;
    final double scaleChange;
    if (event is PointerScrollEvent) {
      if (!HardwareKeyboard.instance.isControlPressed &&
          !HardwareKeyboard.instance.isMetaPressed) {
        // Scroll without Ctrl pressed, so treat it as a pan.
        if (!_gestureIsSupported(_GestureType.pan)) return;

        final Offset localDelta = PointerEvent.transformDeltaViaPositions(
          untransformedEndPosition: global + event.scrollDelta,
          untransformedDelta: event.scrollDelta,
          transform: event.transform,
        );

        final Offset focalPointScene = _toScene(local);

        final Offset newFocalPointScene = _toScene(local - localDelta);

        final Matrix4 constrained = _constrain(
          _matrixTranslate(
            _transformer.value,
            newFocalPointScene - focalPointScene,
          ),
        );
        if (constrained != _transformer.value) {
          _transformer.value = constrained;
        }

        return;
      }
      // Ignore left and right mouse wheel scroll.
      if (event.scrollDelta.dy == 0.0) {
        return;
      }
      scaleChange = math.exp(-event.scrollDelta.dy / widget.scaleFactor);
    } else if (event is PointerScaleEvent) {
      scaleChange = event.scale;
    } else {
      return;
    }

    if (!_gestureIsSupported(_GestureType.scale)) return;

    final Offset focalPointScene = _toScene(local);
    final Matrix4 scaledMatrix = _matrixScale(_transformer.value, scaleChange);

    // After scaling, translate such that the event's position is at the
    // same scene point before and after the scale.
    final double det = scaledMatrix.determinant();
    if (!det.isFinite || det.abs() < 1e-12) {
      return;
    }
    final Matrix4 scaledInverse = scaledMatrix.clone()..invert();
    final Vector3 focalVec = scaledInverse.transform3(
      Vector3(local.dx, local.dy, 0),
    );
    final Offset focalPointSceneScaled = Offset(focalVec.x, focalVec.y);
    final Matrix4 constrained = _constrain(
      _matrixTranslate(scaledMatrix, focalPointSceneScaled - focalPointScene),
    );
    if (constrained != _transformer.value) {
      _transformer.value = constrained;
    }
  }
}
