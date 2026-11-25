/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/data/prefs/stow_helpers.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:sbn/tool_id.dart';
import 'package:stow_plain/stow_plain.dart';

/// Drawing tool options, eraser/lasso/tape/laser settings, pen tray presets,
/// quick-access slots, and recent color history preferences.
mixin CanvasToolsPrefs {
  static StrokeOptions _strokeOptionsFromJson(Object json) =>
      StrokeOptions.fromJson(json as Map<String, dynamic>);

  /// Whether the eraser automatically switches back to the previous tool after
  /// one stroke.
  final disableEraserAfterUse = PlainStow(
    'disableEraserAfterUse',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Eraser radius in logical pixels.
  final eraserSize = PlainStow(
    'eraserSize',
    30.0,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether scribbling back-and-forth with the pen erases overlapping strokes.
  final scribbleToErase = PlainStow(
    'scribbleToErase',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the select tool uses rectangle mode instead of freehand lasso.
  final selectionRectMode = PlainStow(
    'selectionRectMode',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the lasso/select tool selects handwriting strokes.
  final lassoSelectHandwriting = PlainStow<bool>(
    'lassoSelectHandwriting',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the lasso/select tool selects images and PDFs.
  final lassoSelectImages = PlainStow<bool>(
    'lassoSelectImages',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the lasso/select tool selects text boxes.
  final lassoSelectText = PlainStow<bool>(
    'lassoSelectText',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the lasso/select tool selects study tape strokes.
  final lassoSelectTape = PlainStow<bool>(
    'lassoSelectTape',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the lasso selects a stroke when it only covers part of it,
  /// instead of requiring most of the stroke to be inside.
  final lassoSelectPartial = PlainStow<bool>(
    'lassoSelectPartial',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the lasso also selects the strokes that touch the ones it
  /// selected, like the rest of a cursive word.
  final lassoSelectConnected = PlainStow<bool>(
    'lassoSelectConnected',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Default pattern for Study Tape ('solid', 'stripes', 'dots', 'grid').
  final studyTapePattern = PlainStow<String>(
    'studyTapePattern',
    'solid',
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the eraser only erases highlighter strokes.
  final eraserEraseHighlighterOnly = PlainStow<bool>(
    'eraserEraseHighlighterOnly',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the eraser only erases tape strokes.
  final eraserEraseTapeOnly = PlainStow<bool>(
    'eraserEraseTapeOnly',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Eraser style/mode ('object', 'precision').
  final eraserMode = PlainStow<String>(
    'eraserMode',
    'object',
    volatile: StowIsolate.isVolatile,
  );

  /// Whether highlighter strokes are automatically drawn in a straight line.
  final highlighterDrawInStraightLine = PlainStow<bool>(
    'highlighterDrawInStraightLine',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether drawing a closed loop and holding converts to a lasso selection.
  final circleToSelect = PlainStow<bool>(
    'circleToSelect',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Laser pointer mode ('trail', 'spotlight').
  final laserPointerMode = PlainStow<String>(
    'laserPointerMode',
    'trail',
    volatile: StowIsolate.isVolatile,
  );

  /// Pen stroke line style ('solid', 'dashed', 'dotted').
  final penLineStyle = PlainStow<String>(
    'penLineStyle',
    'solid',
    volatile: StowIsolate.isVolatile,
  );

  /// Saved pens, encoded as `colorHex:thickness` pairs.
  ///
  /// Kept in step with `PenTray.encodedDefaults`.
  final penTray = PlainStow<String>(
    'penTray',
    'ff000000:2,ff1565c0:3,ffc62828:4,ff2e7d32:3,ff6a1b9a:5,ff5d4037:8',
    volatile: StowIsolate.isVolatile,
  );

  /// Which saved pen is selected.
  final penTrayIndex = PlainStow<int>(
    'penTrayIndex',
    0,
    volatile: StowIsolate.isVolatile,
  );

  /// Three quick color slots for Pen (Black, Blue, Red by default).
  final quickColorsPen = PlainStow<List<int>>(
    'quickColorsPen',
    <int>[0xFF000000, 0xFF1976D2, 0xFFD32F2F],
    codec: const IntListCsvCodec(),
    volatile: StowIsolate.isVolatile,
  );

  /// Three quick color slots for Highlighter (Yellow, Green, Pink by default).
  final quickColorsHighlighter = PlainStow<List<int>>(
    'quickColorsHighlighter',
    <int>[0xFFFFF176, 0xFFA5D6A7, 0xFFF48FB1],
    codec: const IntListCsvCodec(),
    volatile: StowIsolate.isVolatile,
  );

  /// Three quick size slots for Pen (Thin, Medium, Thick).
  final quickSizesPen = PlainStow<List<double>>(
    'quickSizesPen',
    <double>[2.0, 4.0, 8.0],
    codec: const DoubleListCsvCodec(),
    volatile: StowIsolate.isVolatile,
  );

  /// Three quick size slots for Highlighter (Thin, Medium, Thick).
  final quickSizesHighlighter = PlainStow<List<double>>(
    'quickSizesHighlighter',
    <double>[15.0, 25.0, 40.0],
    codec: const DoubleListCsvCodec(),
    volatile: StowIsolate.isVolatile,
  );

  /// Active quick color slot index for Pen.
  final activeQuickColorIndexPen = PlainStow<int>(
    'activeQuickColorIndexPen',
    0,
    volatile: StowIsolate.isVolatile,
  );

  /// Active quick size slot index for Pen.
  final activeQuickSizeIndexPen = PlainStow<int>(
    'activeQuickSizeIndexPen',
    0,
    volatile: StowIsolate.isVolatile,
  );

  /// Active quick color slot index for Highlighter.
  final activeQuickColorIndexHighlighter = PlainStow<int>(
    'activeQuickColorIndexHighlighter',
    0,
    volatile: StowIsolate.isVolatile,
  );

  /// Active quick size slot index for Highlighter.
  final activeQuickSizeIndexHighlighter = PlainStow<int>(
    'activeQuickSizeIndexHighlighter',
    0,
    volatile: StowIsolate.isVolatile,
  );

  /// Pen pressure curve exponent.
  ///
  /// 1.0 = linear, >1 = more sensitive at high pressure,
  /// <1 = more sensitive at low pressure.
  final penPressureCurve = PlainStow<double>(
    'penPressureCurve',
    1.0,
    volatile: StowIsolate.isVolatile,
  );

  /// Recent colors ordered chronologically (oldest first).
  final recentColorsChronological = PlainStow(
    'recentColorsChronological',
    <String>[],
    volatile: StowIsolate.isVolatile,
  );

  /// Recent colors ordered by toolbar slot position.
  final recentColorsPositioned = PlainStow(
    'recentColorsPositioned',
    <String>[],
    volatile: StowIsolate.isVolatile,
  );

  /// User-pinned color swatches.
  final pinnedColors = PlainStow(
    'pinnedColors',
    <String>[],
    volatile: StowIsolate.isVolatile,
  );

  /// Whether preset palette colors are excluded from recent color history.
  final recentColorsDontSavePresets = PlainStow(
    'dontSavePresetColors',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Maximum number of recent colors retained.
  final recentColorsLength = PlainStow(
    'recentColorsLength',
    5,
    volatile: StowIsolate.isVolatile,
  );

  /// Last active drawing tool.
  final lastTool = PlainStow(
    'lastTool',
    ToolId.fountainPen,
    codec: ToolId.codec,
    volatile: StowIsolate.isVolatile,
  );

  /// Last used stroke options for the fountain pen.
  final lastFountainPenOptions = PlainStow.json(
    'lastFountainPenProperties',
    Pen.fountainPenOptions,
    fromJson: _strokeOptionsFromJson,
    volatile: StowIsolate.isVolatile,
  );

  /// Last used stroke options for the ballpoint pen.
  final lastBallpointPenOptions = PlainStow.json(
    'lastBallpointPenProperties',
    Pen.ballpointPenOptions,
    fromJson: _strokeOptionsFromJson,
    volatile: StowIsolate.isVolatile,
  );

  /// Last used stroke options for the highlighter.
  final lastHighlighterOptions = PlainStow.json(
    'lastHighlighterProperties',
    Pen.highlighterOptions,
    fromJson: _strokeOptionsFromJson,
    volatile: StowIsolate.isVolatile,
  );

  /// Last used stroke options for the pencil.
  final lastPencilOptions = PlainStow.json(
    'lastPencilProperties',
    Pen.pencilOptions,
    fromJson: _strokeOptionsFromJson,
    volatile: StowIsolate.isVolatile,
  );

  /// Last used stroke options for the shape pen.
  final lastShapePenOptions = PlainStow.json(
    'lastShapePenProperties',
    Pen.shapePenOptions,
    fromJson: _strokeOptionsFromJson,
    volatile: StowIsolate.isVolatile,
  );

  /// Last used ARGB32 color for the fountain pen.
  final lastFountainPenColor = PlainStow(
    'lastFountainPenColor',
    Colors.black.toARGB32(),
    volatile: StowIsolate.isVolatile,
  );

  /// Last used ARGB32 color for the ballpoint pen.
  final lastBallpointPenColor = PlainStow(
    'lastBallpointPenColor',
    Colors.black.toARGB32(),
    volatile: StowIsolate.isVolatile,
  );

  /// Last used ARGB32 color for the highlighter.
  final lastHighlighterColor = PlainStow(
    'lastHighlighterColor',
    Colors.yellow.withAlpha(Highlighter.alpha).toARGB32(),
    volatile: StowIsolate.isVolatile,
  );

  /// Last used ARGB32 color for the pencil.
  final lastPencilColor = PlainStow(
    'lastPencilColor',
    Colors.black.toARGB32(),
    volatile: StowIsolate.isVolatile,
  );

  /// Last used ARGB32 color for the shape pen.
  final lastShapePenColor = PlainStow(
    'lastShapePenColor',
    Colors.black.toARGB32(),
    volatile: StowIsolate.isVolatile,
  );
}
