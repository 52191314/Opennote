/// 🤖 Generated wholely or partially with Claude Code; Gemini; Google Antigravity
part of '../canvas_gesture_detector.dart';

extension _CanvasGesturePointerHandlers on CanvasGestureDetectorState {
  void _trackPointerForTapGestures(PointerEvent event) {
    if (!stows.twoFingerTapUndo.value) return;

    if (event is PointerDownEvent) {
      _pointerPositions[event.pointer] = event.position;
      if (_pointerPositions.length > _maxPointerCountDuringGesture) {
        _maxPointerCountDuringGesture = _pointerPositions.length;
      }
      if (_pointerPositions.length >= 2) {
        _multiPointerDownTime ??= DateTime.now();
      }
    } else if (event is PointerMoveEvent) {
      final initial = _pointerPositions[event.pointer];
      if (initial != null && (event.position - initial).distance > 18.0) {
        _multiPointerMoved = true;
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointerPositions.remove(event.pointer);

      if (_pointerPositions.isEmpty) {
        if (!_multiPointerMoved && _multiPointerDownTime != null) {
          final duration = DateTime.now()
              .difference(_multiPointerDownTime!)
              .inMilliseconds;
          if (duration < 350) {
            if (_maxPointerCountDuringGesture == 2) {
              HapticFeedback.lightImpact();
              widget.undo();
            } else if (_maxPointerCountDuringGesture >= 3) {
              HapticFeedback.lightImpact();
              widget.redo();
            }
          }
        }
        _multiPointerDownTime = null;
        _maxPointerCountDuringGesture = 0;
        _multiPointerMoved = false;
      }
    }
  }

  void _listenerPointerEvent(PointerEvent event) {
    final isStylus =
        event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus;

    if (isStylus) {
      _palmEngine.notifyStylusEvent(event);
    } else if (_palmEngine.isPalm(event)) {
      return;
    }

    _trackPointerForTapGestures(event);
    if (isStylus && event is PointerDownEvent) {
      _detectStylusButton(event);
    }

    final double? pressure;
    if (isStylus) {
      if (event.pressureMin != event.pressureMax) {
        pressure = _inverseLerp(
          event.pressure,
          min: event.pressureMin,
          max: event.pressureMax,
        );
      } else {
        // Detected as stylus, but no pressure values
        pressure = null;
      }
    } else {
      pressure = null;
    }
    widget.updatePointerData(event.kind, pressure);

    if (isStylus &&
        stows.autoDisableFingerDrawingWhenStylusDetected.value &&
        // Don't change if the user has a fixed value for finger drawing
        !stows.hideFingerDrawingToggle.value) {
      stows.editorFingerDrawing.value = false;
    }
  }

  void _listenerPointerHoverEvent(PointerEvent event) {
    if (event.kind != .stylus && event.kind != .invertedStylus) return;
    _palmEngine.notifyStylusEvent(event);

    // Apparently flutter synthesizes a hover event on pointer down,
    // so these are used to detect when hovering ends
    if (event.synthesized) {
      widget.onHoveringEnd();
    } else {
      widget.onHovering();
    }

    _detectStylusButton(event);
  }

  void _detectStylusButton(PointerEvent event) {
    final pressed =
        event.buttons == kSecondaryButton || event.kind == .invertedStylus;
    if (stylusButtonWasPressed != pressed) {
      stylusButtonWasPressed = pressed;
      widget.onStylusButtonChanged(pressed);
    }
  }

  void _listenerPointerUpEvent(PointerEvent event) {
    _palmEngine.onPointerUpOrCancel(event);
    _trackPointerForTapGestures(event);
    widget.updatePointerData(event.kind, null);
    if (stylusButtonWasPressed) {
      stylusButtonWasPressed = false;
      widget.onStylusButtonChanged(false);
    }
  }
}

double _inverseLerp(num value, {required num min, required num max}) {
  assert(max >= min, 'Max ($max) must be >= min ($min)');
  assert(
    value >= min && value <= max,
    'Value ($value) must be between $min and $max',
  );
  return (value - min) / (max - min);
}
