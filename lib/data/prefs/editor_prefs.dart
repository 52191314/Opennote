/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/data/prefs/stow_helpers.dart';
import 'package:saber/data/tools/palm_rejection.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:stow_codecs/stow_codecs.dart';
import 'package:stow_plain/stow_plain.dart';

/// Editor chrome, canvas layout, gestures, palm rejection, snapping, and
/// document behavior preferences.
mixin EditorPrefs {
  /// Default line height for lined/grid canvas backgrounds.
  static const defaultLineHeight = 40;

  /// Default line thickness for lined/grid canvas backgrounds.
  static const defaultLineThickness = 3;

  /// Constant representing 3-axis isometric 30-degree snapping mode for
  /// [snapAngleStep].
  static const snapAngleStepIso30 = -30;

  /// Docked edge for the editor toolbar.
  final editorToolbarAlignment = PlainStow(
    'editorToolbarAlignment',
    AxisDirection.down,
    codec: const EnumCodec(AxisDirection.values),
    volatile: StowIsolate.isVolatile,
  );

  /// Edge of the floating pen menu: top, right, bottom, or left.
  final floatingPenMenuEdge = PlainStow<String>(
    'floatingPenMenuEdge',
    'right',
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the editor toolbar remains visible in fullscreen mode.
  final editorToolbarShowInFullscreen = PlainStow(
    'editorToolbarShowInFullscreen',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether finger drawing is enabled in the editor.
  final editorFingerDrawing = PlainStow(
    'editorFingerDrawing',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the editor automatically inverts colors in dark mode.
  final editorAutoInvert = PlainStow(
    'editorAutoInvert',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether greyscale rendering is preferred for e-ink displays.
  final preferGreyscale = PlainStow(
    'preferGreyscale',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether to prompt for a note rename when creating a new note.
  final editorPromptRename = PlainStow(
    'editorPromptRename',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Autosave debounce delay in milliseconds.
  final autosaveDelay = PlainStow(
    'autosaveDelay',
    10000,
    volatile: StowIsolate.isVolatile,
  );

  /// Delay in milliseconds before holding a stroke triggers shape recognition.
  final shapeRecognitionDelay = PlainStow(
    'shapeRecognitionDelay',
    500,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether nearly straight lines are automatically straightened.
  final autoStraightenLines = PlainStow(
    'autoStraightenLines',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether page indicators are included when printing or exporting PDFs.
  final printPageIndicators = PlainStow(
    'printPageIndicators',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Maximum dimension (in pixels) for imported images.
  final maxImageSize = PlainStow<double>(
    'maxImageSize',
    1000,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the whiteboard automatically clears when exited.
  final autoClearWhiteboardOnExit = PlainStow(
    'autoClearWhiteboardOnExit',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether new notes default to 2D infinite canvas mode.
  final defaultInfiniteCanvas = PlainStow<bool>(
    'defaultInfiniteCanvas',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the floating layers HUD is visible on canvas.
  final showFloatingLayersHud = PlainStow<bool>(
    'showFloatingLayersHud',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Persisted reusable elements / stickers JSON array.
  final elementsJson = PlainStow<String>(
    'elementsJson',
    '',
    volatile: StowIsolate.isVolatile,
  );

  /// Whether two-finger tap triggers undo and three-finger tap triggers redo.
  final twoFingerTapUndo = PlainStow<bool>(
    'twoFingerTapUndo',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the finger-drawing toggle button is hidden from the toolbar.
  final hideFingerDrawingToggle = PlainStow(
    'hideFingerDrawingToggle',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether finger drawing is disabled automatically when a stylus is detected.
  final autoDisableFingerDrawingWhenStylusDetected = PlainStow(
    'autoDisableFingerDrawingWhenStylusDetected',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Writing posture configuration for palm rejection and wrist comfort.
  final writingPosture = PlainStow(
    'writingPosture',
    WritingPosture.rightBelow,
    codec: const EnumCodec(WritingPosture.values),
    volatile: StowIsolate.isVolatile,
  );

  /// Palm rejection filtering sensitivity.
  final palmRejectionSensitivity = PlainStow(
    'palmRejectionSensitivity',
    PalmRejectionSensitivity.medium,
    codec: const EnumCodec(PalmRejectionSensitivity.values),
    volatile: StowIsolate.isVolatile,
  );

  /// Last selected canvas background pattern.
  final lastBackgroundPattern = PlainStow(
    'lastBackgroundPattern',
    CanvasBackgroundPattern.none,
    codec: const EnumCodec(CanvasBackgroundPattern.values),
    volatile: StowIsolate.isVolatile,
  );

  /// Last selected background line height.
  final lastLineHeight = PlainStow(
    'lastLineHeight',
    defaultLineHeight,
    volatile: StowIsolate.isVolatile,
  );

  /// Last selected background line thickness.
  final lastLineThickness = PlainStow(
    'lastLineThickness',
    defaultLineThickness,
    volatile: StowIsolate.isVolatile,
  );

  /// Last zoom-lock toggle state.
  final lastZoomLock = PlainStow(
    'lastZoomLock',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Last single-finger pan-lock toggle state.
  final lastSingleFingerPanLock = PlainStow(
    'lastSingleFingerPanLock',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Last axis-aligned pan-lock toggle state.
  final lastAxisAlignedPanLock = PlainStow(
    'lastAxisAlignedPanLock',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// If true, stroke endpoints snap to the nearest grid intersection.
  final snapToGrid = PlainStow(
    'snapToGrid',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// The grid cell size (in logical pixels) used for snap-to-grid.
  final gridSize = PlainStow<double>(
    'gridSize',
    20.0,
    volatile: StowIsolate.isVolatile,
  );

  /// If true, line strokes snap to the nearest angle step.
  final snapToAngle = PlainStow(
    'snapToAngle',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// The angle step (in degrees) used for snap-to-angle, e.g. 15, 30, 45, or
  /// [snapAngleStepIso30].
  final snapAngleStep = PlainStow(
    'snapAngleStep',
    15,
    volatile: StowIsolate.isVolatile,
  );
}
