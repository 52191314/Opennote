/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/services.dart';
import 'package:saber/data/shortcuts/mobile_keybinder.dart';

/// Manages keyboard shortcuts bound by [Toolbar] and cleans them up on dispose.
class ToolbarKeybindings {
  ToolbarKeybindings({
    required this.onToggleFingerDrawing,
    required this.onToggleEraser,
    required this.onToggleColorOptions,
    required this.onToggleExportBar,
    required this.onToggleFullscreen,
    required this.onPaste,
  });

  final VoidCallback onToggleFingerDrawing;
  final VoidCallback onToggleEraser;
  final VoidCallback onToggleColorOptions;
  final VoidCallback onToggleExportBar;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onPaste;

  Keybinding? _ctrlF;
  Keybinding? _ctrlE;
  Keybinding? _ctrlC;
  Keybinding? _ctrlShiftS;
  Keybinding? _f11;
  Keybinding? _ctrlV;

  /// Registers all toolbar shortcuts with [Keybinder].
  void register() {
    _ctrlF = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyF),
    ], inclusive: true);
    _ctrlE = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyE),
    ], inclusive: true);
    _ctrlC = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyC),
    ], inclusive: true);
    _ctrlShiftS = Keybinding([
      KeyCode.ctrl,
      KeyCode.shift,
      KeyCode.from(LogicalKeyboardKey.keyS),
    ], inclusive: true);
    _f11 = Keybinding([KeyCode.from(LogicalKeyboardKey.f11)], inclusive: true);
    _ctrlV = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyV),
    ], inclusive: true);

    Keybinder.bind(_ctrlF!, onToggleFingerDrawing);
    Keybinder.bind(_ctrlE!, onToggleEraser);
    Keybinder.bind(_ctrlC!, onToggleColorOptions);
    Keybinder.bind(_ctrlShiftS!, onToggleExportBar);
    Keybinder.bind(_f11!, onToggleFullscreen);
    Keybinder.bind(_ctrlV!, onPaste);
  }

  /// Unregisters all toolbar shortcuts from [Keybinder].
  void dispose() {
    if (_ctrlF != null) Keybinder.remove(_ctrlF!);
    if (_ctrlE != null) Keybinder.remove(_ctrlE!);
    if (_ctrlC != null) Keybinder.remove(_ctrlC!);
    if (_ctrlShiftS != null) Keybinder.remove(_ctrlShiftS!);
    if (_f11 != null) Keybinder.remove(_f11!);
    if (_ctrlV != null) Keybinder.remove(_ctrlV!);
  }
}
