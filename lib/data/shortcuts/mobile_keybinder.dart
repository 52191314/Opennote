/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Represents a set of equivalent logical keyboard keys (such as left/right
/// modifiers or a single character/navigation key).
@immutable
class KeyCode {
  /// Creates a [KeyCode] matching any key in [keys].
  const KeyCode.fromSet(this.keys);

  /// Creates a [KeyCode] matching a single [LogicalKeyboardKey].
  factory KeyCode.from(LogicalKeyboardKey key) => KeyCode.fromSet({key});

  /// Control modifier key (left, right, or generic).
  static final ctrl = KeyCode.fromSet({
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
  });

  /// Shift modifier key (left, right, or generic).
  static final shift = KeyCode.fromSet({
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
  });

  /// Alt/Option modifier key (left, right, or generic).
  static final alt = KeyCode.fromSet({
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
  });

  /// Meta/Command modifier key (left, right, or generic).
  static final meta = KeyCode.fromSet({
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
  });

  static final Set<LogicalKeyboardKey> _allModifierKeys = {
    ...ctrl.keys,
    ...shift.keys,
    ...alt.keys,
    ...meta.keys,
  };

  /// The logical keys accepted by this [KeyCode].
  final Set<LogicalKeyboardKey> keys;

  /// Returns whether any key in [pressed] satisfies this [KeyCode].
  bool isPressedIn(Set<LogicalKeyboardKey> pressed) =>
      keys.any(pressed.contains);

  /// Returns whether [key] belongs to this [KeyCode].
  bool containsKey(LogicalKeyboardKey key) => keys.contains(key);

  bool get _isModifier => keys.any(_allModifierKeys.contains);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyCode && setEquals(keys, other.keys));

  @override
  int get hashCode => Object.hashAllUnordered(keys);
}

/// Defines a hardware keyboard shortcut combination of [KeyCode]s.
@immutable
class Keybinding {
  /// Creates a [Keybinding] from [codes].
  ///
  /// When [inclusive] is `true`, additional non-modifier keys may be held
  /// simultaneously (for example, holding two arrow keys for diagonal pan).
  Keybinding(Iterable<KeyCode> codes, {this.inclusive = false})
    : codes = List<KeyCode>.unmodifiable(codes),
      requiresCtrl = codes.any((c) => c.keys.any(KeyCode.ctrl.containsKey)),
      requiresShift = codes.any((c) => c.keys.any(KeyCode.shift.containsKey)),
      requiresAlt = codes.any((c) => c.keys.any(KeyCode.alt.containsKey)),
      requiresMeta = codes.any((c) => c.keys.any(KeyCode.meta.containsKey)),
      _nonModifierCodes = List<KeyCode>.unmodifiable(
        codes.where((c) => !c._isModifier),
      );

  /// All key codes required by this binding.
  final List<KeyCode> codes;

  /// Whether extra non-modifier keys may be held while triggering this binding.
  final bool inclusive;

  /// Whether Control is required.
  final bool requiresCtrl;

  /// Whether Shift is required.
  final bool requiresShift;

  /// Whether Alt/Option is required.
  final bool requiresAlt;

  /// Whether Meta/Command is required.
  final bool requiresMeta;

  final List<KeyCode> _nonModifierCodes;

  bool _modifiersMatch(
    Set<LogicalKeyboardKey> pressed,
    LogicalKeyboardKey eventKey,
  ) {
    final isCtrl = KeyCode.ctrl.isPressedIn(pressed);
    final isShift = KeyCode.shift.isPressedIn(pressed);
    final isAlt = KeyCode.alt.isPressedIn(pressed);
    final isMeta = KeyCode.meta.isPressedIn(pressed);

    if (isCtrl != requiresCtrl) return false;
    if (isAlt != requiresAlt) return false;
    if (isMeta != requiresMeta) return false;
    if (isShift != requiresShift) {
      final allowsShiftedPlus =
          isShift && !requiresShift && eventKey == LogicalKeyboardKey.add;
      if (!allowsShiftedPlus) return false;
    }
    return true;
  }

  bool _areRequiredCodesPressed(Set<LogicalKeyboardKey> pressed) =>
      codes.every((code) => code.isPressedIn(pressed));

  bool _matchesEvent(
    Set<LogicalKeyboardKey> pressed,
    LogicalKeyboardKey eventKey,
  ) {
    if (codes.isEmpty) return false;
    if (!_modifiersMatch(pressed, eventKey)) return false;
    if (!_areRequiredCodesPressed(pressed)) return false;

    final triggerTargets = _nonModifierCodes.isNotEmpty
        ? _nonModifierCodes
        : codes;
    if (!triggerTargets.any((code) => code.containsKey(eventKey))) {
      return false;
    }

    if (!inclusive) {
      for (final key in pressed) {
        if (KeyCode._allModifierKeys.contains(key)) continue;
        if (!_nonModifierCodes.any((code) => code.containsKey(key))) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Keybinding &&
          inclusive == other.inclusive &&
          listEquals(codes, other.codes));

  @override
  int get hashCode => Object.hash(inclusive, Object.hashAll(codes));
}

class _BindingEntry {
  _BindingEntry({required this.binding, this.onTrigger, this.onStateChanged});

  final Keybinding binding;
  final VoidCallback? onTrigger;
  final ValueChanged<bool>? onStateChanged;
  var isActive = false;
}

/// Zero-dependency hardware keyboard shortcut dispatcher backed directly by
/// Flutter's [HardwareKeyboard].
abstract final class MobileKeybinder {
  static final List<_BindingEntry> _entries = [];
  static var _handlerAttached = false;

  /// Registers [callback] (either [VoidCallback] or [ValueChanged<bool>]) for
  /// [keybinding].
  static void bind(Keybinding keybinding, Function callback) {
    remove(keybinding);

    if (callback is ValueChanged<bool>) {
      _entries.add(
        _BindingEntry(binding: keybinding, onStateChanged: callback),
      );
    } else if (callback is VoidCallback) {
      _entries.add(_BindingEntry(binding: keybinding, onTrigger: callback));
    } else {
      throw ArgumentError.value(
        callback,
        'callback',
        'Expected VoidCallback or ValueChanged<bool>.',
      );
    }

    _ensureHandlerAttached();
  }

  /// Removes any callback associated with [keybinding].
  static void remove(Keybinding keybinding) {
    _entries.removeWhere((entry) => entry.binding == keybinding);
    if (_entries.isEmpty) {
      _detachHandler();
    }
  }

  /// Clears all active keybindings and detaches the hardware keyboard listener.
  static void disposeAll() {
    _entries.clear();
    _detachHandler();
  }

  static void _ensureHandlerAttached() {
    if (_handlerAttached) return;
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    _handlerAttached = true;
  }

  static void _detachHandler() {
    if (!_handlerAttached) return;
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _handlerAttached = false;
  }

  static bool _handleKeyEvent(KeyEvent event) {
    if (_entries.isEmpty) return false;

    final snapshot = List<_BindingEntry>.of(_entries);

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final pressed = <LogicalKeyboardKey>{
        ...HardwareKeyboard.instance.logicalKeysPressed,
        event.logicalKey,
      };
      for (final entry in snapshot) {
        if (!entry.binding._matchesEvent(pressed, event.logicalKey)) continue;
        if (entry.onTrigger != null) {
          entry.onTrigger!();
        } else if (entry.onStateChanged != null &&
            event is KeyDownEvent &&
            !entry.isActive) {
          entry.isActive = true;
          entry.onStateChanged!(true);
        }
      }
      return false;
    }

    if (event is KeyUpEvent) {
      final remaining = Set<LogicalKeyboardKey>.of(
        HardwareKeyboard.instance.logicalKeysPressed,
      )..remove(event.logicalKey);
      for (final entry in snapshot) {
        if (entry.onStateChanged == null || !entry.isActive) continue;
        if (!entry.binding._areRequiredCodesPressed(remaining)) {
          entry.isActive = false;
          entry.onStateChanged!(false);
        }
      }
    }

    return false;
  }
}

/// Alias of [MobileKeybinder] preserving drop-in compatibility at call sites.
typedef Keybinder = MobileKeybinder;
