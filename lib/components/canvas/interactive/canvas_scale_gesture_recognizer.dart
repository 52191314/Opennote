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
  final _recentlyRejectedDowns =
      <int, ({PointerDownEvent event, DateTime time})>{};

  static const _multiTouchForgiveWindowMs = 120;
  static const _multiTouchMinSeparation = 30.0;

  void _pruneStaleRejectedDowns(DateTime now) {
    _recentlyRejectedDowns.removeWhere((pointer, entry) {
      final expired =
          now.difference(entry.time).inMilliseconds >
          _multiTouchForgiveWindowMs;
      final lifted = !(palmEngine?.isTouchPointerDown(pointer) ?? false);
      return expired || lifted;
    });
  }

  ({PointerDownEvent event, DateTime time})? _findForgivableRejectedDown(
    PointerDownEvent event,
  ) {
    for (final entry in _recentlyRejectedDowns.values) {
      if ((event.position - entry.event.position).distance >=
          _multiTouchMinSeparation) {
        return entry;
      }
    }
    return null;
  }

  void _cancelActiveTouchPointer(int pointer, PointerEvent trigger) {
    super.handleEvent(
      PointerCancelEvent(
        pointer: pointer,
        position: trigger.position,
        timeStamp: trigger.timeStamp,
      ).transformed(trigger.transform),
    );
    resolvePointer(pointer, GestureDisposition.rejected);
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    final now = DateTime.now();
    _pruneStaleRejectedDowns(now);

    var isMultiTouch =
        event.kind == PointerDeviceKind.touch &&
        _activeTouchPointers.isNotEmpty;

    if (!isMultiTouch &&
        event.kind == PointerDeviceKind.touch &&
        !(palmEngine?.isStylusDown ?? false) &&
        _recentlyRejectedDowns.isNotEmpty &&
        event.radiusMajor < 52.0 &&
        event.radiusMinor < 52.0 &&
        event.size < 0.50) {
      final first = _findForgivableRejectedDown(event);
      if (first != null) {
        _recentlyRejectedDowns.remove(first.event.pointer);
        palmEngine?.forgiveRejectedPointer(first.event.pointer);
        _activeTouchPointers.add(first.event.pointer);
        super.addAllowedPointer(first.event);
        GestureBinding.instance.gestureArena.close(first.event.pointer);
        super.handleEvent(first.event);
        isMultiTouch = true;
      }
    }

    if (palmEngine?.isPalm(event, isMultiTouch: isMultiTouch) ?? false) {
      if (event.kind == PointerDeviceKind.touch &&
          !(palmEngine?.isStylusDown ?? false) &&
          event.radiusMajor < 48.0 &&
          event.radiusMinor < 48.0 &&
          event.size < 0.42) {
        _recentlyRejectedDowns[event.pointer] = (event: event, time: now);
      }
      return;
    }

    if (event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus) {
      _recentlyRejectedDowns.clear();
      final pointersToCancel = _activeTouchPointers.toList(growable: false);
      _activeTouchPointers.clear();
      for (final touchPointer in pointersToCancel) {
        _cancelActiveTouchPointer(touchPointer, event);
      }
    } else if (event.kind == PointerDeviceKind.touch) {
      _activeTouchPointers.add(event.pointer);
    }

    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      super.handleEvent(event);
      return;
    }

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _activeTouchPointers.remove(event.pointer);
      _recentlyRejectedDowns.remove(event.pointer);
      palmEngine?.onPointerUpOrCancel(event);
      super.handleEvent(event);
      return;
    }

    final isActiveMultiTouchGesture =
        _activeTouchPointers.length >= 2 &&
        _activeTouchPointers.contains(event.pointer) &&
        !(palmEngine?.isStylusDown ?? false);
    if (!isActiveMultiTouchGesture && (palmEngine?.isPalm(event) ?? false)) {
      if (_activeTouchPointers.remove(event.pointer)) {
        _cancelActiveTouchPointer(event.pointer, event);
      } else {
        stopTrackingPointer(event.pointer);
        resolvePointer(event.pointer, GestureDisposition.rejected);
      }
      return;
    }

    super.handleEvent(event);
  }

  @override
  void rejectGesture(int pointer) {
    _activeTouchPointers.remove(pointer);
    _recentlyRejectedDowns.remove(pointer);
    super.rejectGesture(pointer);
  }

  @override
  void dispose() {
    _activeTouchPointers.clear();
    _recentlyRejectedDowns.clear();
    super.dispose();
  }
}
