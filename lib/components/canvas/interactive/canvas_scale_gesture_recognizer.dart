/// 🤖 Generated wholely or partially with Claude Code; Gemini; Google Antigravity
library;

import 'package:flutter/gestures.dart';
import 'package:saber/data/tools/palm_rejection.dart';

/// A specialized [ScaleGestureRecognizer] that filters resting palm/wrist touches via
/// [PalmRejectionEngine] and prioritizes active stylus writing over concurrent touch inputs.
class CanvasScaleGestureRecognizer extends ScaleGestureRecognizer {
  CanvasScaleGestureRecognizer({
    super.debugOwner,
    super.supportedDevices,
    super.allowedButtonsFilter,
    super.dragStartBehavior,
    super.trackpadScrollCausesScale,
    super.trackpadScrollToScaleFactor,
    this.palmEngine,
  });

  PalmRejectionEngine? palmEngine;
  final _activeTouchPointers = <int>{};

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (palmEngine?.isPalm(event) ?? false) {
      return;
    }

    if (event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus) {
      // Stylus preemption: clear any prior tracked touch pointers (e.g. wrist touching first)
      final pointersToCancel = _activeTouchPointers.toList(growable: false);
      _activeTouchPointers.clear();
      for (final touchPointer in pointersToCancel) {
        super.handleEvent(
          PointerCancelEvent(
            pointer: touchPointer,
            position: event.position,
            timeStamp: event.timeStamp,
          ),
        );
      }
    } else if (event.kind == PointerDeviceKind.touch) {
      _activeTouchPointers.add(event.pointer);
    }

    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    final isActiveMultiTouchGesture =
        event is! PointerDownEvent &&
        _activeTouchPointers.length >= 2 &&
        _activeTouchPointers.contains(event.pointer) &&
        !(palmEngine?.isStylusDown ?? false);
    if (!isActiveMultiTouchGesture && (palmEngine?.isPalm(event) ?? false)) {
      // Forward a cancel/up to ScaleGestureRecognizer if this pointer was tracked,
      // otherwise _pointerLocations/_pointerQueue would retain a ghost pointer.
      if (_activeTouchPointers.remove(event.pointer)) {
        final cleanupEvent =
            (event is PointerUpEvent || event is PointerCancelEvent)
            ? event
            : PointerCancelEvent(
                pointer: event.pointer,
                position: event.position,
                timeStamp: event.timeStamp,
              );
        super.handleEvent(cleanupEvent);
      } else {
        stopTrackingIfPointerNoLongerDown(event);
      }
      return;
    }

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _activeTouchPointers.remove(event.pointer);
    }

    super.handleEvent(event);
  }

  @override
  void rejectGesture(int pointer) {
    _activeTouchPointers.remove(pointer);
    super.rejectGesture(pointer);
  }

  @override
  void dispose() {
    _activeTouchPointers.clear();
    super.dispose();
  }
}
