/// 🤖 Modified with DeepSeek v4 Flash
/// 🤖 Generated wholely or partially with Claude Code; Gemini; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Modified with Claude Code (Claude Sonnet 5.5)
/// 🤖 Modified with Grok 4.7
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:collapsible/collapsible.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutter_quill;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_canvas_painter.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/components/canvas/canvas.dart';
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/components/canvas/canvas_image.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/components/canvas/lasso_screenshot_dialog.dart';
import 'package:saber/components/canvas/save_indicator.dart';
import 'package:saber/components/canvas/shape_library_dialog.dart';
import 'package:saber/components/canvas/zoom_window_view.dart';
import 'package:saber/components/editor/page_grid_overview.dart';
import 'package:saber/components/editor/presentation_mode.dart';
import 'package:saber/components/editor/read_only_banner.dart';
import 'package:saber/components/editor/template_picker_dialog.dart';
import 'package:saber/components/theming/adaptive_alert_dialog.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/components/theming/dynamic_material_app.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/components/toolbar/color_bar.dart';
import 'package:saber/components/toolbar/editor_bottom_sheet.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/elements_sheet.dart';
import 'package:saber/components/toolbar/export_bar.dart';
import 'package:saber/components/toolbar/floating_pen_menu.dart';
import 'package:saber/components/toolbar/opennote_header_bar.dart';
import 'package:saber/components/toolbar/opennote_toolbar.dart';
import 'package:saber/components/toolbar/toolbar.dart';
import 'package:saber/data/clipboard/mobile_clipboard.dart';
import 'package:saber/data/editor/canvas_mode_conversion.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_exporter.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/gestures/eraser_gesture.dart';
import 'package:saber/data/editor/gestures/laser_gesture.dart';
import 'package:saber/data/editor/gestures/pen_gesture.dart';
import 'package:saber/data/editor/gestures/select_gesture.dart';
import 'package:saber/data/editor/gestures/tool_gesture.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/editor/selection_clipboard.dart';
import 'package:saber/data/editor/selection_handles.dart';
import 'package:saber/data/editor/selection_resize.dart';
import 'package:saber/data/editor/selection_transform.dart';
import 'package:saber/data/editor/zoom_window.dart';
import 'package:saber/data/extensions/change_notifier_extensions.dart';
import 'package:saber/data/extensions/color_extensions.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/file_manager/note_paths.dart';
import 'package:saber/data/nextcloud/saber_syncer.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/shortcuts/mobile_keybinder.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/arrow.dart';
import 'package:saber/data/tools/dimension.dart';
import 'package:saber/data/tools/elements.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/laser_pointer.dart';
import 'package:saber/data/tools/page_templates.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pen_tray.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/shape_pen.dart';
import 'package:saber/data/tools/study_tape.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/home/whiteboard.dart';
import 'package:sbn/change.dart';

part 'editor_gesture_handlers.dart';
part 'editor_history_actions.dart';
part 'editor_media_import.dart';
part 'editor_page_management.dart';
part 'editor_persistence.dart';
part 'editor_selection_actions.dart';
part 'editor_ui_builders.dart';

typedef _PhotoInfo = ({Uint8List bytes, String extension});

class Editor extends StatefulWidget {
  Editor({
    super.key,
    String? path,
    this.customTitle,
    this.pdfPath,
    this.initialPageIndex,
  }) : initialPath = path != null
           ? Future.value(path)
           : FileManager.newFilePath('/'),
       needsNaming = path == null;

  final Future<String> initialPath;
  final bool needsNaming;

  final String? customTitle;
  final String? pdfPath;

  /// Page to show after the note opens. Null stays on the saved page.
  final int? initialPageIndex;

  /// The file extension used by the app. See [NotePaths.extension].
  static const extension = NotePaths.extension;

  /// The old file extension used by the app.
  /// See [NotePaths.extensionOldJson].
  static const extensionOldJson = NotePaths.extensionOldJson;

  static const double gapBetweenPages = 16;

  /// Returns true if [path] belongs to a hidden file
  /// used by other functions of the app
  static bool isReservedPath(String path) => NotePaths.isReserved(path);

  /// Whether the platform can rasterize a pdf
  static var canRasterPdf = true;

  @override
  State<Editor> createState() => EditorState();
}

class EditorState extends State<Editor>
    with WidgetsBindingObserver
    implements EditorGestureHost {
  final log = Logger('EditorState');

  late var coreInfo = EditorCoreInfo.placeholder;

  final _canvasGestureDetectorKey = GlobalKey<CanvasGestureDetectorState>();
  final _transformationController = TransformationController();
  double get scrollY {
    final transformation = _transformationController.value;
    final rawScale = transformation.maxScale2D;
    final scale = (rawScale.isFinite && rawScale > 0) ? rawScale : 1.0;
    final translation = transformation.getTranslation();
    final gestureDetector = _canvasGestureDetectorKey.currentState;

    if (gestureDetector == null) {
      log.warning('scrollY: Could not find CanvasGestureDetectorState');
      return translation.y / scale;
    } else {
      final middle = gestureDetector.containerBounds.maxHeight / 2;
      return (translation.y - middle) / scale + middle;
    }
  }

  @override
  var history = EditorHistory();

  final _zoomWindow = ZoomWindowController();
  var _zoomWindowOpen = false;
  var _zoomPageIndex = 0;

  @override
  int get lineHeight => coreInfo.lineHeight;

  @override
  double get currentScale => _transformationController.value.maxScale2D;

  late bool needsNaming = widget.needsNaming && stows.editorPromptRename.value;

  late Tool _currentTool = () {
    switch (stows.lastTool.value) {
      case .fountainPen:
        if (Pen.currentPen.toolId != stows.lastTool.value) {
          Pen.currentPen = Pen.fountainPen();
        }
        return Pen.currentPen;
      case .ballpointPen:
        if (Pen.currentPen.toolId != stows.lastTool.value) {
          Pen.currentPen = Pen.ballpointPen();
        }
        return Pen.currentPen;
      case .shapePen:
        if (Pen.currentPen.toolId != stows.lastTool.value) {
          Pen.currentPen = ShapePen();
        }
        return Pen.currentPen;
      case .highlighter:
        return Highlighter.currentHighlighter;
      case .pencil:
        return Pencil.currentPencil;
      case .eraser:
        return Eraser(size: stows.eraserSize.value);
      case .select:
        return Select.currentSelect;
      case .textEditing:
        return Tool.textEditing;
      case .laserPointer:
        return LaserPointer.currentLaserPointer;
      case .ruler:
        return Ruler();
      case .arrow:
        return ArrowTool();
      case .dimension:
        return DimensionTool();
      case .studyTape:
        return StudyTapeTool.currentStudyTape;
    }
  }();

  @override
  Tool get currentTool => _currentTool;
  set currentTool(Tool tool) {
    // If switching away from Select, exit crop mode on selected images
    if (_currentTool is Select && tool is! Select) {
      for (final image in Select.currentSelect.selectResult.images) {
        image.cropMode = false;
      }
    }
    _currentTool = tool;
    if (tool is! Eraser) _lastNonEraserTool = tool;
    stows.lastTool.value = tool.toolId;
  }

  ValueNotifier<SavingState> savingState = ValueNotifier(SavingState.saved);
  Timer? _delayedSaveTimer;
  Timer? _watchServerTimer;

  var lastSeenPointerCount = 0;
  var _recordedDrawInCurrentTouch = false;
  Timer? _lastSeenPointerCountTimer;

  ValueNotifier<QuillStruct?> quillFocus = ValueNotifier(null);

  /// Notifies only the active page canvas when an in-flight pen stroke begins
  /// or ends, avoiding a full [EditorState] rebuild on every stroke start.
  final _activeStrokeNotifier = ValueNotifier<Stroke?>(null);

  /// The last non-Eraser [currentTool] value.
  late Tool _lastNonEraserTool = Pen.currentPen;

  /// If the stylus button is pressed, or was pressed, during the current draw gesture.
  ///
  /// For now, this also includes when an [PointerDeviceKind.inverseStylus] is
  /// used since the stylus rear-end and stylus button currently act the same.
  /// If we add customized button bindings, we may have to separate this again.
  var stylusButtonWasPressed = false;

  /// Handles draw gestures made with a pen, including scribble-to-erase
  /// and circle-to-select.
  late final _penGesture = PenGesture(
    this,
    onCircleDetected: _onCircleToSelectDetected,
  );

  /// The selection copied to the internal clipboard (for paste).
  SelectionClipboard? _clipboard;

  /// Handles draw gestures made with the Select tool.
  late final _selectGesture = SelectGesture(this);

  /// Handles draw gestures made with the eraser.
  late final _eraserGesture = EraserGesture(this);

  /// Handles draw gestures made with the laser pointer.
  static const _laserGesture = LaserGesture();

  /// The position and page index of the most recent user canvas tap/click,
  /// used to place newly added elements, photos, stickers, and shapes.
  Offset? _lastCanvasTapPosition;
  int? _lastCanvasTapPageIndex;
  DateTime? _lastCanvasTapTime;

  Keybinding? _ctrlZ, _ctrlY, _ctrlShiftZ;

  /// The position of the previous draw gesture event.
  /// Used to move a selection.
  Offset previousPosition = .zero;

  /// The total offset of the current move gesture.
  /// Used to record a move in the history.
  Offset moveOffset = .zero;

  var isHovering = true;
  int? dragPageIndex;
  PointerDeviceKind? currentPointerKind;
  double? currentPressure;
  var _isHandScrollOnlyMode = false;

  late final _filenameFormKey = GlobalKey<FormState>();
  late final filenameTextEditingController = TextEditingController();
  Timer? _renameTimer;

  late int _lastCurrentPageIndex = coreInfo.initialPageIndex ?? 0;

  void _refreshUi([VoidCallback? fn]) => setState(fn ?? () {});
  void _setState() => setState(() {});

  @override
  void initState() {
    DynamicMaterialApp.addFullscreenListener(_setState);
    WidgetsBinding.instance.addObserver(this);

    _initAsync();
    _assignKeybindings();

    super.initState();
  }

  /// Saves as soon as the app leaves the foreground, since the system may
  /// kill it before the autosave timer fires.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == .resumed) return;
    if (savingState.value != .waitingToSave) return;
    unawaited(saveToFile());
  }

  @override
  void createPage(int pageIndex) => _createPageImpl(pageIndex);

  @override
  void removeExcessPages() => _removeExcessPagesImpl();

  @override
  void restoreToolAfterErasing() => _restoreToolAfterErasingImpl();

  @override
  void autosaveAfterDelay() => _autosaveAfterDelayImpl();

  @override
  void deleteSelection(EditorPage page) =>
      _deleteSelection(Select.currentSelect, page);

  @visibleForTesting
  static int getPageIndexFromScrollPosition({
    required double scrollY,
    required double screenWidth,
    required List<EditorPage> pages,
  }) => _getPageIndexFromScrollPosition(
    scrollY: scrollY,
    screenWidth: screenWidth,
    pages: pages,
  );

  @override
  Widget build(BuildContext context) => _buildEditor(context);

  @override
  void dispose() {
    unawaited(_cleanUpAsync());

    DynamicMaterialApp.removeFullscreenListener(_setState);
    WidgetsBinding.instance.removeObserver(this);

    _delayedSaveTimer?.cancel();
    _watchServerTimer?.cancel();
    _lastSeenPointerCountTimer?.cancel();

    _removeKeybindings();
    _zoomWindow.dispose();
    _activeStrokeNotifier.dispose();

    // manually save pen properties since the listeners don't fire if a property is changed
    stows.lastFountainPenOptions.notifyListeners();
    stows.lastBallpointPenOptions.notifyListeners();
    stows.lastHighlighterOptions.notifyListeners();
    stows.lastPencilOptions.notifyListeners();
    stows.lastShapePenOptions.notifyListeners();

    super.dispose();
  }
}
