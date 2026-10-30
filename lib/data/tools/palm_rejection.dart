/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:saber/data/prefs.dart';

/// Goodnotes-inspired writing postures for palm rejection and wrist protection.
enum WritingPosture {
  /// Right-handed with wrist resting below the writing line.
  rightBelow,

  /// Right-handed with wrist resting level with the writing line.
  rightLevel,

  /// Right-handed with wrist hooked above the writing line.
  rightAbove,

  /// Left-handed with wrist resting below the writing line.
  leftBelow,

  /// Left-handed with wrist resting level with the writing line.
  leftLevel,

  /// Left-handed with wrist hooked above the writing line.
  leftAbove;

  /// Whether the writer holds the stylus in the right hand.
  bool get isRightHanded =>
      this == rightBelow || this == rightLevel || this == rightAbove;

  /// Whether the writer holds the stylus in the left hand.
  bool get isLeftHanded => !isRightHanded;

  /// Whether the wrist rests below the writing baseline.
  bool get isHandBelow => this == rightBelow || this == leftBelow;

  /// Whether the wrist rests level with the writing baseline.
  bool get isHandLevel => this == rightLevel || this == leftLevel;

  /// Whether the wrist is hooked above the writing baseline.
  bool get isHandAbove => this == rightAbove || this == leftAbove;
}

/// Sensitivity levels for palm rejection filtering.
enum PalmRejectionSensitivity {
  /// Palm rejection filtering is turned off.
  disabled,

  /// Low sensitivity: only rejects very large contacts.
  low,

  /// Medium sensitivity: standard Goodnotes-style palm rejection.
  medium,

  /// High sensitivity: aggressive rejection of any contact near the writing posture zone.
  high,
}

/// Palm rejection engine that filters resting hand and wrist contacts on tablets and iPads.
class PalmRejectionEngine {
  PalmRejectionEngine({
    WritingPosture? writingPosture,
    PalmRejectionSensitivity? sensitivity,
  }) : _configuredPosture = writingPosture,
       _configuredSensitivity = sensitivity;

  final WritingPosture? _configuredPosture;
  final PalmRejectionSensitivity? _configuredSensitivity;

  /// Active writing posture preference.
  WritingPosture get writingPosture =>
      _configuredPosture ?? stows.writingPosture.value;

  /// Active sensitivity level.
  PalmRejectionSensitivity get sensitivity =>
      _configuredSensitivity ?? stows.palmRejectionSensitivity.value;

  /// The pointer ID of the stylus currently making contact, if any.
  int? activeStylusPointerId;

  /// Last known global position of the stylus tip.
  Offset? lastStylusPosition;

  /// Timestamp of the most recent stylus interaction (hover or touch).
  DateTime? lastStylusTime;

  final _rejectedPointers = <int>{};

  /// Whether a stylus is currently in contact with the display.
  bool get isStylusDown => activeStylusPointerId != null;

  /// Returns true if [event] corresponds to a resting palm or wrist.
  bool isPalm(PointerEvent event) {
    if (sensitivity == PalmRejectionSensitivity.disabled) return false;

    if (event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus) {
      notifyStylusEvent(event);
      return false;
    }

    if (event.kind != PointerDeviceKind.touch) return false;

    if (_rejectedPointers.contains(event.pointer)) {
      if (event is PointerUpEvent || event is PointerCancelEvent) {
        _rejectedPointers.remove(event.pointer);
      }
      return true;
    }

    if (isStylusDown) {
      _rejectedPointers.add(event.pointer);
      return true;
    }

    if (_isLargeContact(event)) {
      _rejectedPointers.add(event.pointer);
      return true;
    }

    if (_isInPostureRejectionZone(event.position)) {
      _rejectedPointers.add(event.pointer);
      return true;
    }

    return false;
  }

  /// Updates internal stylus coordinates and timestamps from stylus events.
  void notifyStylusEvent(PointerEvent event) {
    if (event.kind != PointerDeviceKind.stylus &&
        event.kind != PointerDeviceKind.invertedStylus) {
      return;
    }

    lastStylusPosition = event.position;
    lastStylusTime = DateTime.now();

    if (event is PointerDownEvent) {
      activeStylusPointerId = event.pointer;
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      if (activeStylusPointerId == event.pointer) {
        activeStylusPointerId = null;
      }
    }
  }

  /// Cleans up pointer tracking when a pointer is lifted or cancelled.
  void onPointerUpOrCancel(PointerEvent event) {
    _rejectedPointers.remove(event.pointer);
    if (activeStylusPointerId == event.pointer) {
      activeStylusPointerId = null;
    }
  }

  /// Resets all tracked pointer states.
  void reset() {
    activeStylusPointerId = null;
    lastStylusPosition = null;
    lastStylusTime = null;
    _rejectedPointers.clear();
  }

  bool _isLargeContact(PointerEvent event) {
    final double radius = max(event.radiusMajor, event.radiusMinor);
    final (
      double thresholdRadius,
      double thresholdSize,
    ) = switch (sensitivity) {
      PalmRejectionSensitivity.high => (16.0, 0.14),
      PalmRejectionSensitivity.medium => (22.0, 0.20),
      PalmRejectionSensitivity.low => (32.0, 0.28),
      PalmRejectionSensitivity.disabled => (double.infinity, double.infinity),
    };

    return radius >= thresholdRadius || event.size >= thresholdSize;
  }

  bool _isInPostureRejectionZone(Offset touchPosition) {
    final stylusPos = lastStylusPosition;
    final stylusTime = lastStylusTime;
    if (stylusPos == null || stylusTime == null) return false;

    final int gracePeriodMs = switch (sensitivity) {
      PalmRejectionSensitivity.high => 2500,
      PalmRejectionSensitivity.medium => 1800,
      PalmRejectionSensitivity.low => 1000,
      PalmRejectionSensitivity.disabled => 0,
    };

    final elapsed = DateTime.now().difference(stylusTime).inMilliseconds;
    if (elapsed > gracePeriodMs) return false;

    final dx = touchPosition.dx - stylusPos.dx;
    final dy = touchPosition.dy - stylusPos.dy;

    return isPointInPostureZone(dx, dy, writingPosture);
  }

  /// Evaluates whether a relative offset [dx, dy] from the stylus tip falls inside
  /// the palm rejection region for [posture].
  static bool isPointInPostureZone(
    double dx,
    double dy,
    WritingPosture posture,
  ) {
    switch (posture) {
      case WritingPosture.rightBelow:
        if (dy > 30 && dx.abs() < 350) return true;
        return dy > -20 && dx > -80;

      case WritingPosture.rightLevel:
        return dx > 20 && dy.abs() < 240;

      case WritingPosture.rightAbove:
        return dy < 20 && dx > -80;

      case WritingPosture.leftBelow:
        if (dy > 30 && dx.abs() < 350) return true;
        return dy > -20 && dx < 80;

      case WritingPosture.leftLevel:
        return dx < -20 && dy.abs() < 240;

      case WritingPosture.leftAbove:
        return dy < 20 && dx < 80;
    }
  }
}
