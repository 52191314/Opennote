/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/navbar/responsive_navbar.dart';
import 'package:saber/components/settings/nextcloud_profile.dart';
import 'package:saber/data/codecs/base64_codec.dart';
import 'package:saber/data/codecs/quota_codec.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/sentry/sentry_consent.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/tool_id.dart';
import 'package:stow/stow.dart';
import 'package:stow_codecs/stow_codecs.dart';
import 'package:stow_plain/stow_plain.dart';
import 'package:stow_secure/stow_secure.dart';

/// If false, all stows are stuck at their default values.
var _isOnMainIsolate = false;

final stows = Stows();

class Stows {
  Stows() {
    recentColorsLength.addListener(() {
      // truncate if needed
      while (recentColorsLength.value < recentColorsPositioned.value.length) {
        // remove oldest color
        final removed = recentColorsChronological.value.removeAt(0);
        recentColorsPositioned.value.remove(removed);
      }
    });
  }

  /// Call this before [runApp] to set [_isOnMainIsolate] to true.
  static void markAsOnMainIsolate() {
    _isOnMainIsolate = true;
  }

  final log = Logger('Stows');

  final customDataDir = PlainStow<String?>(
    'customDataDir',
    null,
    volatile: !_isOnMainIsolate,
  );

  final allowInsecureConnections = SecureStow.bool(
    'allowInsecureConnections',
    false,
    volatile: !_isOnMainIsolate,
  );
  final url = SecureStow('url', '', volatile: !_isOnMainIsolate);
  final username = SecureStow('username', '', volatile: !_isOnMainIsolate);

  /// the password used to login to Nextcloud
  final ncPassword = SecureStow('ncPassword', '', volatile: !_isOnMainIsolate);

  /// the password used to encrypt/decrypt notes
  final encPassword = SecureStow(
    'encPassword',
    '',
    volatile: !_isOnMainIsolate,
  );

  /// Whether the user is logged in and has provided both passwords.
  /// Please ensure that the relevant Prefs are loaded before using this.
  bool get loggedIn =>
      username.value.isNotEmpty &&
      ncPassword.value.isNotEmpty &&
      encPassword.value.isNotEmpty;

  final key = SecureStow('key', '', volatile: !_isOnMainIsolate);
  final iv = SecureStow('iv', '', volatile: !_isOnMainIsolate);

  final pfp = PlainStow<Uint8List?>(
    'pfp',
    null,
    codec: const Base64StowCodec(),
    volatile: !_isOnMainIsolate,
  );
  final syncInBackground = PlainStow(
    'syncInBackground',
    true,
    volatile: !_isOnMainIsolate,
  );

  final appTheme = PlainStow(
    'appTheme',
    ThemeMode.system,
    codec: const EnumCodec(ThemeMode.values),
    volatile: !_isOnMainIsolate,
  );

  /// The type of platform to theme. Default value is [defaultTargetPlatform].
  final platform = PlainStow(
    'platform',
    defaultTargetPlatform,
    codec: const EnumCodec(TargetPlatform.values),
    volatile: !_isOnMainIsolate,
  );
  final layoutSize = PlainStow(
    'layoutSize',
    LayoutSize.auto,
    codec: LayoutSize.codec,
    volatile: !_isOnMainIsolate,
  );

  /// The accent color of the app. If 0, the system accent color will be used.
  final accentColor = PlainStow<Color?>(
    'accentColor',
    null,
    codec: const ColorCodec(),
    volatile: !_isOnMainIsolate,
  );
  final hyperlegibleFont = PlainStow(
    'hyperlegibleFont',
    false,
    volatile: !_isOnMainIsolate,
  );

  final editorToolbarAlignment = PlainStow(
    'editorToolbarAlignment',
    AxisDirection.down,
    codec: const EnumCodec(AxisDirection.values),
    volatile: !_isOnMainIsolate,
  );
  final editorToolbarShowInFullscreen = PlainStow(
    'editorToolbarShowInFullscreen',
    true,
    volatile: !_isOnMainIsolate,
  );
  final editorFingerDrawing = PlainStow(
    'editorFingerDrawing',
    true,
    volatile: !_isOnMainIsolate,
  );
  final editorAutoInvert = PlainStow(
    'editorAutoInvert',
    true,
    volatile: !_isOnMainIsolate,
  );
  final preferGreyscale = PlainStow(
    'preferGreyscale',
    false,
    volatile: !_isOnMainIsolate,
  );
  final editorPromptRename = PlainStow(
    'editorPromptRename',
    isDesktop,
    volatile: !_isOnMainIsolate,
  );
  final autosaveDelay = PlainStow(
    'autosaveDelay',
    10000,
    volatile: !_isOnMainIsolate,
  );
  final shapeRecognitionDelay = PlainStow(
    'shapeRecognitionDelay',
    500,
    volatile: !_isOnMainIsolate,
  );
  final autoStraightenLines = PlainStow(
    'autoStraightenLines',
    true,
    volatile: !_isOnMainIsolate,
  );

  final simplifiedHomeLayout = PlainStow(
    'simplifiedHomeLayout',
    false,
    volatile: !_isOnMainIsolate,
  );
  final printPageIndicators = PlainStow(
    'printPageIndicators',
    false,
    volatile: !_isOnMainIsolate,
  );

  /// When true, enables the Goodnotes-inspired dual-tier toolbar and document tabs header.
  final goodnotesUiMode = PlainStow(
    'goodnotesUiMode',
    true,
    volatile: !_isOnMainIsolate,
  );

  final maxImageSize = PlainStow<double>(
    'maxImageSize',
    1000,
    volatile: !_isOnMainIsolate,
  );

  final autoClearWhiteboardOnExit = PlainStow(
    'autoClearWhiteboardOnExit',
    false,
    volatile: !_isOnMainIsolate,
  );

  final disableEraserAfterUse = PlainStow(
    'disableEraserAfterUse',
    false,
    volatile: !_isOnMainIsolate,
  );

  final eraserSize = PlainStow('eraserSize', 30.0, volatile: !_isOnMainIsolate);

  /// Whether scribbling back-and-forth with the pen erases overlapping strokes.
  final scribbleToErase = PlainStow(
    'scribbleToErase',
    true,
    volatile: !_isOnMainIsolate,
  );

  /// Whether new notes default to 2D infinite canvas mode.
  final defaultInfiniteCanvas = PlainStow<bool>(
    'defaultInfiniteCanvas',
    false,
    volatile: !_isOnMainIsolate,
  );

  /// Whether the user has completed or dismissed the initial onboarding guide.
  final hasSeenOnboarding = PlainStow<bool>(
    'hasSeenOnboarding',
    false,
    volatile: !_isOnMainIsolate,
  );

  final selectionRectMode = PlainStow(
    'selectionRectMode',
    false,
    volatile: !_isOnMainIsolate,
  );

  /// Whether the lasso/select tool selects handwriting strokes.
  final lassoSelectHandwriting = PlainStow<bool>(
    'lassoSelectHandwriting',
    true,
    volatile: !_isOnMainIsolate,
  );

  /// Whether the lasso/select tool selects images and PDFs.
  final lassoSelectImages = PlainStow<bool>(
    'lassoSelectImages',
    true,
    volatile: !_isOnMainIsolate,
  );

  /// Whether the lasso/select tool selects text boxes.
  final lassoSelectText = PlainStow<bool>(
    'lassoSelectText',
    true,
    volatile: !_isOnMainIsolate,
  );

  /// Whether the lasso/select tool selects study tape strokes.
  final lassoSelectTape = PlainStow<bool>(
    'lassoSelectTape',
    true,
    volatile: !_isOnMainIsolate,
  );

  /// Default pattern for Study Tape ('solid', 'stripes', 'dots', 'grid').
  final studyTapePattern = PlainStow<String>(
    'studyTapePattern',
    'solid',
    volatile: !_isOnMainIsolate,
  );

  /// Whether the eraser only erases highlighter strokes.
  final eraserEraseHighlighterOnly = PlainStow<bool>(
    'eraserEraseHighlighterOnly',
    false,
    volatile: !_isOnMainIsolate,
  );

  /// Whether the eraser only erases tape strokes.
  final eraserEraseTapeOnly = PlainStow<bool>(
    'eraserEraseTapeOnly',
    false,
    volatile: !_isOnMainIsolate,
  );

  /// Eraser style/mode ('object', 'precision').
  final eraserMode = PlainStow<String>(
    'eraserMode',
    'object',
    volatile: !_isOnMainIsolate,
  );

  /// Whether highlighter strokes are automatically drawn in a straight line.
  final highlighterDrawInStraightLine = PlainStow<bool>(
    'highlighterDrawInStraightLine',
    false,
    volatile: !_isOnMainIsolate,
  );

  /// Whether drawing a closed loop and holding converts to a lasso selection.
  final circleToSelect = PlainStow<bool>(
    'circleToSelect',
    true,
    volatile: !_isOnMainIsolate,
  );

  /// Laser pointer mode ('trail', 'spotlight').
  final laserPointerMode = PlainStow<String>(
    'laserPointerMode',
    'trail',
    volatile: !_isOnMainIsolate,
  );

  /// Pen stroke line style ('solid', 'dashed', 'dotted').
  final penLineStyle = PlainStow<String>(
    'penLineStyle',
    'solid',
    volatile: !_isOnMainIsolate,
  );

  /// Whether the floating layers HUD is visible on canvas.
  final showFloatingLayersHud = PlainStow<bool>(
    'showFloatingLayersHud',
    true,
    volatile: !_isOnMainIsolate,
  );

  /// Persisted reusable elements / stickers JSON array.
  final elementsJson = PlainStow<String>(
    'elementsJson',
    '',
    volatile: !_isOnMainIsolate,
  );

  /// Whether two-finger tap triggers undo and three-finger tap triggers redo.
  final twoFingerTapUndo = PlainStow<bool>(
    'twoFingerTapUndo',
    true,
    volatile: !_isOnMainIsolate,
  );

  /// 3 Quick Color slots for Pen (Black, Blue, Red by default).
  final quickColorsPen = PlainStow<List<int>>(
    'quickColorsPen',
    <int>[0xFF000000, 0xFF1976D2, 0xFFD32F2F],
    codec: const _IntListCsvCodec(),
    volatile: !_isOnMainIsolate,
  );

  /// 3 Quick Color slots for Highlighter (Yellow, Green, Pink by default).
  final quickColorsHighlighter = PlainStow<List<int>>(
    'quickColorsHighlighter',
    <int>[0xFFFFF176, 0xFFA5D6A7, 0xFFF48FB1],
    codec: const _IntListCsvCodec(),
    volatile: !_isOnMainIsolate,
  );

  /// 3 Quick Size slots for Pen (Thin, Medium, Thick).
  final quickSizesPen = PlainStow<List<double>>(
    'quickSizesPen',
    <double>[2.0, 4.0, 8.0],
    codec: const _DoubleListCsvCodec(),
    volatile: !_isOnMainIsolate,
  );

  /// 3 Quick Size slots for Highlighter (Thin, Medium, Thick).
  final quickSizesHighlighter = PlainStow<List<double>>(
    'quickSizesHighlighter',
    <double>[15.0, 25.0, 40.0],
    codec: const _DoubleListCsvCodec(),
    volatile: !_isOnMainIsolate,
  );

  final activeQuickColorIndexPen = PlainStow<int>(
    'activeQuickColorIndexPen',
    0,
    volatile: !_isOnMainIsolate,
  );

  final activeQuickSizeIndexPen = PlainStow<int>(
    'activeQuickSizeIndexPen',
    0,
    volatile: !_isOnMainIsolate,
  );

  final activeQuickColorIndexHighlighter = PlainStow<int>(
    'activeQuickColorIndexHighlighter',
    0,
    volatile: !_isOnMainIsolate,
  );

  final activeQuickSizeIndexHighlighter = PlainStow<int>(
    'activeQuickSizeIndexHighlighter',
    0,
    volatile: !_isOnMainIsolate,
  );

  final hideFingerDrawingToggle = PlainStow(
    'hideFingerDrawingToggle',
    false,
    volatile: !_isOnMainIsolate,
  );

  /// People don't know to turn off finger drawing when using a stylus,
  /// so we can do it automatically.
  final autoDisableFingerDrawingWhenStylusDetected = PlainStow(
    'autoDisableFingerDrawingWhenStylusDetected',
    true,
    volatile: !_isOnMainIsolate,
  );

  /// Pen pressure curve exponent.
  /// 1.0 = linear, >1 = more sensitive at high pressure, <1 = more sensitive at low pressure.
  final penPressureCurve = PlainStow<double>(
    'penPressureCurve',
    1.0,
    volatile: !_isOnMainIsolate,
  );

  final recentColorsChronological = PlainStow(
    'recentColorsChronological',
    <String>[],
    volatile: !_isOnMainIsolate,
  );
  final recentColorsPositioned = PlainStow(
    'recentColorsPositioned',
    <String>[],
    volatile: !_isOnMainIsolate,
  );
  final pinnedColors = PlainStow(
    'pinnedColors',
    <String>[],
    volatile: !_isOnMainIsolate,
  );
  final recentColorsDontSavePresets = PlainStow(
    'dontSavePresetColors',
    false,
    volatile: !_isOnMainIsolate,
  );
  final recentColorsLength = PlainStow(
    'recentColorsLength',
    5,
    volatile: !_isOnMainIsolate,
  );

  final lastTool = PlainStow(
    'lastTool',
    ToolId.fountainPen,
    codec: ToolId.codec,
    volatile: !_isOnMainIsolate,
  );
  static StrokeOptions _strokeOptionsFromJson(Object json) =>
      StrokeOptions.fromJson(json as Map<String, dynamic>);
  final lastFountainPenOptions = PlainStow.json(
        'lastFountainPenProperties',
        Pen.fountainPenOptions,
        fromJson: _strokeOptionsFromJson,
        volatile: !_isOnMainIsolate,
      ),
      lastBallpointPenOptions = PlainStow.json(
        'lastBallpointPenProperties',
        Pen.ballpointPenOptions,
        fromJson: _strokeOptionsFromJson,
        volatile: !_isOnMainIsolate,
      ),
      lastHighlighterOptions = PlainStow.json(
        'lastHighlighterProperties',
        Pen.highlighterOptions,
        fromJson: _strokeOptionsFromJson,
        volatile: !_isOnMainIsolate,
      ),
      lastPencilOptions = PlainStow.json(
        'lastPencilProperties',
        Pen.pencilOptions,
        fromJson: _strokeOptionsFromJson,
        volatile: !_isOnMainIsolate,
      ),
      lastShapePenOptions = PlainStow.json(
        'lastShapePenProperties',
        Pen.shapePenOptions,
        fromJson: _strokeOptionsFromJson,
        volatile: !_isOnMainIsolate,
      );
  final lastFountainPenColor = PlainStow(
        'lastFountainPenColor',
        Colors.black.toARGB32(),
        volatile: !_isOnMainIsolate,
      ),
      lastBallpointPenColor = PlainStow(
        'lastBallpointPenColor',
        Colors.black.toARGB32(),
        volatile: !_isOnMainIsolate,
      ),
      lastHighlighterColor = PlainStow(
        'lastHighlighterColor',
        Colors.yellow.withAlpha(Highlighter.alpha).toARGB32(),
        volatile: !_isOnMainIsolate,
      ),
      lastPencilColor = PlainStow(
        'lastPencilColor',
        Colors.black.toARGB32(),
        volatile: !_isOnMainIsolate,
      ),
      lastShapePenColor = PlainStow(
        'lastShapePenColor',
        Colors.black.toARGB32(),
        volatile: !_isOnMainIsolate,
      );
  final lastBackgroundPattern = PlainStow(
    'lastBackgroundPattern',
    CanvasBackgroundPattern.none,
    codec: const EnumCodec(CanvasBackgroundPattern.values),
    volatile: !_isOnMainIsolate,
  );
  static const defaultLineHeight = 40;
  static const defaultLineThickness = 3;
  final lastLineHeight = PlainStow(
    'lastLineHeight',
    defaultLineHeight,
    volatile: !_isOnMainIsolate,
  );
  final lastLineThickness = PlainStow(
    'lastLineThickness',
    defaultLineThickness,
    volatile: !_isOnMainIsolate,
  );
  final lastZoomLock = PlainStow(
        'lastZoomLock',
        false,
        volatile: !_isOnMainIsolate,
      ),
      lastSingleFingerPanLock = PlainStow(
        'lastSingleFingerPanLock',
        false,
        volatile: !_isOnMainIsolate,
      ),
      lastAxisAlignedPanLock = PlainStow(
        'lastAxisAlignedPanLock',
        false,
        volatile: !_isOnMainIsolate,
      );

  /// If true, stroke endpoints snap to the nearest grid intersection.
  final snapToGrid = PlainStow(
    'snapToGrid',
    false,
    volatile: !_isOnMainIsolate,
  );

  /// The grid cell size (in logical pixels) used for snap-to-grid.
  final gridSize = PlainStow<double>(
    'gridSize',
    20.0,
    volatile: !_isOnMainIsolate,
  );

  /// If true, line strokes snap to the nearest angle step.
  final snapToAngle = PlainStow(
    'snapToAngle',
    false,
    volatile: !_isOnMainIsolate,
  );

  /// Constant representing 3-axis isometric 30° snapping mode for [snapAngleStep].
  static const snapAngleStepIso30 = -30;

  /// The angle step (in degrees) used for snap-to-angle, e.g. 15, 30, 45, or [snapAngleStepIso30].
  final snapAngleStep = PlainStow(
    'snapAngleStep',
    15,
    volatile: !_isOnMainIsolate,
  );

  final recentFiles = PlainStow(
    'recentFiles',
    <String>[],
    volatile: !_isOnMainIsolate,
  );

  /// File paths that have been deleted locally
  final fileSyncAlreadyDeleted = PlainStow(
    'fileSyncAlreadyDeleted',
    <String>{},
    volatile: !_isOnMainIsolate,
  );

  /// File paths that are known to be corrupted on Nextcloud
  final fileSyncCorruptFiles = PlainStow(
    'fileSyncCorruptFiles',
    <String>{},
    volatile: !_isOnMainIsolate,
  );

  /// Set when we want to resync everything.
  /// Files on the server older than this date will be
  /// reuploaded with the local version.
  /// By default, we resync everything uploaded before v0.18.4, since uploads before then resulted in 0B files.
  final fileSyncResyncEverythingDate = PlainStow(
    'fileSyncResyncEverythingDate',
    DateTime.parse('2023-12-10T10:06:31.000Z'),
    codec: const DateTimeCodec(),
    volatile: !_isOnMainIsolate,
  );

  /// The last storage quota that was fetched from Nextcloud
  final lastStorageQuota = PlainStow<Quota?>(
    'lastStorageQuota',
    null,
    codec: const QuotaCodec(),
    volatile: !_isOnMainIsolate,
  );

  final shouldCheckForUpdates = PlainStow(
    'shouldCheckForUpdates',
    FlavorConfig.shouldCheckForUpdatesByDefault && !Platform.isLinux,
    volatile: !_isOnMainIsolate,
  );
  final shouldAlwaysAlertForUpdates = PlainStow(
    'shouldAlwaysAlertForUpdates',
    kDebugMode ? true : false,
    volatile: !_isOnMainIsolate,
  );

  final locale = PlainStow('locale', '', volatile: !_isOnMainIsolate);

  final sentryConsent = PlainStow(
    'sentryConsent',
    SentryConsent.unknown,
    codec: SentryConsent.codec,
    volatile: !_isOnMainIsolate,
  );

  @pragma('vm:platform-const')
  static final isDesktop =
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;
}

/// An [Stow] that transforms the value of another [Stow].
class TransformedStow<T_in, T_out> extends Stow<dynamic, T_out, dynamic> {
  final Stow<dynamic, T_in, dynamic> parent;
  final T_out Function(T_in) transform;
  final T_in Function(T_out) reverseTransform;

  @override
  T_out get value => transform(parent.value);

  @override
  set value(T_out value) => parent.value = reverseTransform(value);

  TransformedStow(this.parent, this.transform, this.reverseTransform)
    : super(parent.key, transform(parent.defaultValue), volatile: true) {
    parent.addListener(notifyListeners);
  }

  @override
  Future<dynamic> protectedRead() async => null;

  @override
  Future<void> protectedWrite(dynamic value) async {}

  @override
  String toString() {
    return 'TransformedPref<$T_in, $T_out>(from ${parent.key}, $value)';
  }

  @override
  void dispose() {
    parent.removeListener(notifyListeners);
    super.dispose();
  }
}

class _IntListCsvCodec extends AbstractCodec<List<int>, String> {
  const _IntListCsvCodec();

  @override
  String encode(List<int> input) => input.join(',');

  @override
  List<int> decode(String encoded) =>
      encoded.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
}

class _DoubleListCsvCodec extends AbstractCodec<List<double>, String> {
  const _DoubleListCsvCodec();

  @override
  String encode(List<double> input) => input.join(',');

  @override
  List<double> decode(String encoded) =>
      encoded.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
}
