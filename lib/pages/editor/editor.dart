/// 🤖 Modified with DeepSeek v4 Flash
/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:collapsible/collapsible.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutter_quill;
import 'package:keybinder/keybinder.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_canvas_painter.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/components/canvas/canvas.dart';
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/components/canvas/canvas_image.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/components/canvas/lasso_screenshot_dialog.dart';
import 'package:saber/components/canvas/save_indicator.dart';
import 'package:saber/components/canvas/shape_library_dialog.dart';
import 'package:saber/components/editor/page_grid_overview.dart';
import 'package:saber/components/editor/presentation_mode.dart';
import 'package:saber/components/editor/read_only_banner.dart';
import 'package:saber/components/theming/adaptive_alert_dialog.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/components/theming/dynamic_material_app.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/components/toolbar/color_bar.dart';
import 'package:saber/components/toolbar/editor_bottom_sheet.dart';
import 'package:saber/components/toolbar/elements_sheet.dart';
import 'package:saber/components/toolbar/export_bar.dart';
import 'package:saber/components/toolbar/goodnotes_header_bar.dart';
import 'package:saber/components/toolbar/goodnotes_toolbar.dart';
import 'package:saber/components/toolbar/toolbar.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_exporter.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/editor/selection_clipboard.dart';
import 'package:saber/data/editor/selection_resize.dart';
import 'package:saber/data/editor/selection_transform.dart';
import 'package:saber/data/extensions/change_notifier_extensions.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/nextcloud/saber_syncer.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/arrow.dart';
import 'package:saber/data/tools/circle_to_select_detector.dart';
import 'package:saber/data/tools/dimension.dart';
import 'package:saber/data/tools/elements.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/laser_pointer.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:saber/data/tools/scribble_detector.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/shape_pen.dart';
import 'package:saber/data/tools/study_tape.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/home/whiteboard.dart';
import 'package:sbn/change.dart';
import 'package:super_clipboard/super_clipboard.dart';

typedef _PhotoInfo = ({Uint8List bytes, String extension});

class Editor extends StatefulWidget {
  Editor({super.key, String? path, this.customTitle, this.pdfPath})
    : initialPath = path != null
          ? Future.value(path)
          : FileManager.newFilePath('/'),
      needsNaming = path == null;

  final Future<String> initialPath;
  final bool needsNaming;

  final String? customTitle;
  final String? pdfPath;

  /// The file extension used by the app.
  /// Files with this extension are
  /// encoded in BSON format.
  static const extension = '.sbn2';

  /// The old file extension used by the app.
  /// Files with this extension are
  /// encoded in JSON format.
  static const extensionOldJson = '.sbn';

  static const double gapBetweenPages = 16;

  /// Returns true if [path] belongs to a hidden file
  /// used by other functions of the app
  static bool isReservedPath(String path) {
    return _reservedFilePaths.any((regex) => regex.hasMatch(path));
  }

  static final _reservedFilePaths = <RegExp>[
    RegExp(RegExp.escape(Whiteboard.filePath)),
  ];

  /// Whether the platform can rasterize a pdf
  static var canRasterPdf = true;

  @override
  State<Editor> createState() => EditorState();
}

class EditorState extends State<Editor> {
  final log = Logger('EditorState');

  late var coreInfo = EditorCoreInfo.placeholder;

  final _canvasGestureDetectorKey = GlobalKey<CanvasGestureDetectorState>();
  final _transformationController = TransformationController();
  double get scrollY {
    final transformation = _transformationController.value;
    final scale = transformation.approxScale;
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

  var history = EditorHistory();

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

  // used to prevent accidentally drawing when pinch zooming
  var lastSeenPointerCount = 0;
  Timer? _lastSeenPointerCountTimer;

  ValueNotifier<QuillStruct?> quillFocus = ValueNotifier(null);

  /// The last non-Eraser [currentTool] value.
  late Tool _lastNonEraserTool = Pen.currentPen;

  /// If the stylus button is pressed, or was pressed, during the current draw gesture.
  ///
  /// For now, this also includes when an [PointerDeviceKind.inverseStylus] is
  /// used since the stylus rear-end and stylus button currently act the same.
  /// If we add customized button bindings, we may have to separate this again.
  var stylusButtonWasPressed = false;

  /// Detects scribble-to-erase gestures when the pen tool is active.
  final scribbleDetector = ScribbleDetector();

  /// Detects circle-to-select loop gestures when the pen tool is active.
  late final circleToSelectDetector = CircleToSelectDetector(
    onCircleDetected: _onCircleToSelectDetected,
  );

  /// The selection copied to the internal clipboard (for paste).
  SelectionClipboard? _clipboard;

  /// Whether the user is currently rotating a selection.
  var _isRotating = false;

  /// The timestamp and position of the last tap (for double-tap detection).
  DateTime? _lastTapTime;
  Offset? _lastTapPosition;

  /// The position and page index of the most recent user canvas tap/click,
  /// used to place newly added elements, photos, stickers, and shapes.
  Offset? _lastCanvasTapPosition;
  int? _lastCanvasTapPageIndex;
  DateTime? _lastCanvasTapTime;

  /// Whether the user is currently resizing a selection.
  var _isResizing = false;

  /// The resize handle drag in progress, if any.
  SelectionResize? _selectionResize;

  /// The resize, rotation, or vertex edit in progress, once it has changed
  /// something. Recorded in [history] when the gesture ends.
  SelectionTransform? _selectionTransform;

  /// The initial angle (in radians) when the rotation gesture started.
  double _initialRotationAngle = 0;

  /// Whether the user is currently dragging a vertex of a drafting stroke.
  var _isDraggingVertex = false;
  var _draggedVertexIndex = -1;
  Stroke? _draggedVertexStroke;

  @override
  void initState() {
    DynamicMaterialApp.addFullscreenListener(_setState);

    _initAsync();
    _assignKeybindings();

    super.initState();
  }

  void _initAsync() async {
    final filePath = await widget.initialPath;
    filenameTextEditingController.text = p.basename(filePath);

    if (needsNaming) {
      filenameTextEditingController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: filenameTextEditingController.text.length,
      );
    }

    await _loadCoreInfo(filePath);

    if (widget.pdfPath != null) {
      await importPdfFromFilePath(widget.pdfPath!);
    }
  }

  Future _loadCoreInfo(String filePath) async {
    coreInfo = await EditorCoreInfo.loadFromFilePath(filePath);
    if (coreInfo.readOnly) {
      log.info('Loaded file as read-only: ${coreInfo.readOnlyReason}');
    }

    for (int pageIndex = 0; pageIndex < coreInfo.pages.length; pageIndex++) {
      listenToQuillChanges(coreInfo.pages[pageIndex].quill, pageIndex);
    }

    if (coreInfo.isEmpty) {
      createPage(-1);
    } else {
      for (final page in coreInfo.pages) {
        page.backgroundImage?.onMoveImage = onMoveImage;
        page.backgroundImage?.onDeleteImage = onDeleteImage;
        page.backgroundImage?.onMiscChange = autosaveAfterDelay;
        for (final image in page.images) {
          image.onMoveImage = onMoveImage;
          image.onDeleteImage = onDeleteImage;
          image.onMiscChange = autosaveAfterDelay;
        }
      }
    }

    if (currentTool == Tool.textEditing) {
      int pageIndex;
      if (coreInfo.initialPageIndex != null) {
        pageIndex = coreInfo.initialPageIndex!;
      } else {
        pageIndex = 0;
      }
      assert(pageIndex < coreInfo.pages.length);

      quillFocus.value = coreInfo.pages[pageIndex].quill
        ..focusNode.requestFocus();
    }

    if (coreInfo.filePath == Whiteboard.filePath &&
        stows.autoClearWhiteboardOnExit.value &&
        Whiteboard.needsToAutoClearWhiteboard) {
      // clear whiteboard (and add to history)
      clearAllPages();

      // save cleared whiteboard
      await saveToFile();
      Whiteboard.needsToAutoClearWhiteboard = false;
    } else {
      setState(() {});
    }
  }

  void _setState() => setState(() {});

  Keybinding? _ctrlZ, _ctrlY, _ctrlShiftZ;
  void _assignKeybindings() {
    _ctrlZ = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyZ),
    ], inclusive: true);
    _ctrlY = Keybinding([
      KeyCode.ctrl,
      KeyCode.from(LogicalKeyboardKey.keyY),
    ], inclusive: true);
    _ctrlShiftZ = Keybinding([
      KeyCode.ctrl,
      KeyCode.shift,
      KeyCode.from(LogicalKeyboardKey.keyZ),
    ], inclusive: true);
    Keybinder.bind(_ctrlZ!, undo);
    Keybinder.bind(_ctrlY!, redo);
    Keybinder.bind(_ctrlShiftZ!, redo);
  }

  void _removeKeybindings() {
    if (_ctrlZ != null) Keybinder.remove(_ctrlZ!);
    if (_ctrlY != null) Keybinder.remove(_ctrlY!);
    if (_ctrlShiftZ != null) Keybinder.remove(_ctrlShiftZ!);
  }

  /// Creates pages until the given page index exists,
  /// plus an extra blank page
  void createPage(int pageIndex) {
    if (coreInfo.isInfiniteCanvas) {
      if (coreInfo.pages.isEmpty) {
        final page = EditorPage();
        coreInfo.pages.add(page);
        listenToQuillChanges(page.quill, 0);
      }
      return;
    }
    while (pageIndex >= coreInfo.pages.length - 1) {
      final page = EditorPage();
      coreInfo.pages.add(page);
      listenToQuillChanges(page.quill, coreInfo.pages.length - 1);
    }
  }

  void removeExcessPages() {
    if (coreInfo.isInfiniteCanvas) return;
    bool removedAPage = false;

    // remove excess pages if all pages >= this one are empty
    for (int i = coreInfo.pages.length - 1; i >= 1; --i) {
      final thisPage = coreInfo.pages[i];
      final prevPage = coreInfo.pages[i - 1];
      if (thisPage.isEmpty && prevPage.isEmpty) {
        final page = coreInfo.pages.removeAt(i);
        page.dispose();
        removedAPage = true;
      } else {
        break;
      }
    }

    if (removedAPage) {
      // scroll to the last page (only if we're below the last page)

      final scrollY = this.scrollY;
      late final topOfLastPage = -CanvasGestureDetector.getTopOfPage(
        pageIndex: coreInfo.pages.length - 1,
        pages: coreInfo.pages,
        screenWidth: MediaQuery.sizeOf(context).width,
      );
      final bottomOfLastPage = -CanvasGestureDetector.getTopOfPage(
        pageIndex: coreInfo.pages.length,
        pages: coreInfo.pages,
        screenWidth: MediaQuery.sizeOf(context).width,
      );

      if (scrollY < bottomOfLastPage) {
        _transformationController.value = Matrix4.translationValues(
          0,
          // Slight upwards offset so that the page is not flush with the top of the screen
          topOfLastPage + 50,
          0,
        );
      }
    }
  }

  void undo([EditorHistoryItem? item]) {
    if (item == null) {
      if (!history.canUndo) return;

      // if we disabled redo, re-enable it
      if (!history.canRedo) {
        // no redo is possible, so clear the redo stack
        history.clearRedo();
        // don't disable redoing anymore
        history.canRedo = true;
      }

      item = history.undo();
    }

    setState(() {
      switch (item!.type) {
        case .draw:
          for (final stroke in item.strokes) {
            coreInfo.pages[stroke.pageIndex].removeStroke(stroke);
          }
          for (final image in item.images) {
            coreInfo.pages[image.pageIndex].images.remove(image);
          }
          removeExcessPages();

        case .erase:
          for (final stroke in item.strokes) {
            createPage(stroke.pageIndex);
            coreInfo.pages[stroke.pageIndex].insertStroke(stroke);
          }
          for (final image in item.images) {
            createPage(image.pageIndex);
            coreInfo.pages[image.pageIndex].images.add(image);
            image.newImage = true;
          }

        case .deletePage:
          // make sure we already have a (blank/otherwise) page at this index
          createPage(item.pageIndex - 1);

          // insert the page at the correct index
          coreInfo.pages.insert(item.pageIndex, item.page!);

          // fix the page indices of all pages after this one
          for (int i = item.pageIndex + 1; i < coreInfo.pages.length; ++i) {
            final page = coreInfo.pages[i];
            page.updatePageIndex(i);
          }

        case .insertPage:
          // remove the page at the given index
          coreInfo.pages.removeAt(item.pageIndex);

          // fix the page indices of all pages after this one
          for (int i = item.pageIndex; i < coreInfo.pages.length; ++i) {
            final page = coreInfo.pages[i];
            page.updatePageIndex(i);
          }

        case .move:
          for (final stroke in item.strokes) {
            stroke.shift(Offset(-item.offset!.left, -item.offset!.top));
          }
          final select = Select.currentSelect;
          if (select.doneSelecting) {
            select.selectResult.path = select.selectResult.path.shift(
              Offset(-item.offset!.left, -item.offset!.top),
            );
          }
          for (final image in item.images) {
            image.dstRect = .fromLTRB(
              image.dstRect.left - item.offset!.left,
              image.dstRect.top - item.offset!.top,
              image.dstRect.right - item.offset!.right,
              image.dstRect.bottom - item.offset!.bottom,
            );
          }
          final textPlacementChange = item.textPlacementChange;
          if (textPlacementChange != null) {
            coreInfo.pages[item.pageIndex].textPlacement =
                textPlacementChange.previous;
          }

        case .quillChange:
          final quill = coreInfo.pages[item.pageIndex].quill;
          quill.controller.undo();

        case .quillUndoneChange:
          final quill = coreInfo.pages[item.pageIndex].quill;
          quill.controller.redo();

        case .changeColor:
          for (final stroke in item.strokes) {
            stroke.color = item.colorChange![stroke]!.previous;
          }

        case .backgroundPattern:
          coreInfo.backgroundPattern = item.backgroundPatternChange!.previous;

        case .transform:
          SelectionTransform.revert(item, coreInfo.pages[item.pageIndex]);
      }

      if (item.type != .move) {
        Select.currentSelect.unselect();
      }
    });

    autosaveAfterDelay();
  }

  void redo() {
    if (!history.canRedo) return;
    final item = history.redo();

    switch (item.type) {
      case .draw:
        undo(item.copyWith(type: .erase));
      case .erase:
        undo(item.copyWith(type: .draw));
      case .deletePage:
        undo(item.copyWith(type: .insertPage));
      case .insertPage:
        undo(item.copyWith(type: .deletePage));
      case .move:
        undo(
          item.copyWith(
            offset: .fromLTRB(
              -item.offset!.left,
              -item.offset!.top,
              -item.offset!.right,
              -item.offset!.bottom,
            ),
            textPlacementChange: item.textPlacementChange?.reverse(),
          ),
        );
      case .quillChange:
        undo(item.copyWith(type: .quillUndoneChange));
      case .quillUndoneChange: // this will never happen
        throw Exception('history should not contain quillUndoneChange items');
      case .changeColor:
        undo(
          item.copyWith(
            colorChange: item.colorChange!.map(
              (key, value) => MapEntry(key, value.reverse()),
            ),
          ),
        );
      case .backgroundPattern:
        undo(
          item.copyWith(
            backgroundPatternChange: item.backgroundPatternChange!.reverse(),
          ),
        );
      case .transform:
        undo(SelectionTransform.reversed(item));
    }
  }

  int? onWhichPageIsFocalPoint(Offset focalPoint) {
    if (coreInfo.isInfiniteCanvas && coreInfo.pages.isNotEmpty) {
      if (coreInfo.pages[0].renderBox != null) {
        return 0;
      }
    }
    for (int i = 0; i < coreInfo.pages.length; ++i) {
      if (coreInfo.pages[i].renderBox == null) continue;
      final pageBounds = Offset.zero & coreInfo.pages[i].size;
      if (pageBounds.contains(
        coreInfo.pages[i].renderBox!.globalToLocal(focalPoint),
      ))
        return i;
    }
    return null;
  }

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
  bool isDrawGesture(ScaleStartDetails details) {
    if (coreInfo.readOnly || _isHandScrollOnlyMode) return false;

    CanvasImage.activeListener
        .notifyListenersPlease(); // un-select active image

    _lastSeenPointerCountTimer?.cancel();
    if (lastSeenPointerCount >= 2) {
      // was a zoom gesture, ignore
      lastSeenPointerCount = lastSeenPointerCount;
      return false;
    } else if (details.pointerCount >= 2) {
      // is a zoom gesture, remove accidental stroke
      if (lastSeenPointerCount == 1 &&
          stows.editorFingerDrawing.value &&
          (currentTool is Pen || currentTool is Eraser)) {
        final item = history.removeAccidentalStroke();
        if (item != null) undo(item);
      }
      lastSeenPointerCount = details.pointerCount;
      return false;
    } else {
      // is a stroke
      lastSeenPointerCount = details.pointerCount;
    }

    dragPageIndex = onWhichPageIsFocalPoint(details.focalPoint);
    if (dragPageIndex == null) return false;

    if (currentTool == Tool.textEditing) {
      return false;
    } else if (stows.editorFingerDrawing.value ||
        currentPointerKind == PointerDeviceKind.stylus ||
        currentPointerKind == PointerDeviceKind.invertedStylus ||
        currentPressure != null) {
      return true;
    } else {
      log.fine('Non-stylus found, rejected stroke');
      return false;
    }
  }

  void onDrawStart(ScaleStartDetails details) {
    final page = coreInfo.pages[dragPageIndex!];
    final position = page.renderBox!.globalToLocal(details.focalPoint);
    _lastCanvasTapPosition = position;
    _lastCanvasTapPageIndex = dragPageIndex;
    _lastCanvasTapTime = DateTime.now();
    history.canRedo = false;
    _selectionTransform = null;

    if (page.activeLayer.locked &&
        (currentTool is Pen || currentTool is Eraser)) {
      return;
    }

    if (currentTool is Pen) {
      // Set pen preview
      final pen = currentTool as Pen;
      page.penPreviewPosition = position;
      page.penPreviewRadius = pen.options.size / 2;
      page.penPreviewColor = pen.color;

      if (stows.scribbleToErase.value) {
        scribbleDetector.start(position);
      }
      if (stows.circleToSelect.value) {
        circleToSelectDetector.start(position);
      }
      pen.onDragStart(position, page, dragPageIndex!, currentPressure);
    } else if (currentTool is Eraser) {
      final eraser = currentTool as Eraser;
      page.eraserCursorPosition = position;
      page.eraserCursorRadius = eraser.size / 2;
      for (final stroke in eraser.checkForOverlappingStrokes(
        position,
        page.activeLayerStrokes,
      )) {
        page.removeStroke(stroke);
      }
      removeExcessPages();
    } else if (currentTool is Select) {
      final select = currentTool as Select;

      // Double-tap detection: two taps close in time and space
      // trigger a re-selection even if a stroke is already selected.
      if (select.doneSelecting &&
          select.selectResult.pageIndex == dragPageIndex! &&
          _lastTapTime != null &&
          _lastTapPosition != null) {
        final now = DateTime.now();
        final timeDelta = now.difference(_lastTapTime!).inMilliseconds;
        final posDelta = (position - _lastTapPosition!).distance;
        if (timeDelta < 300 && posDelta < 20) {
          select.unselect();
          page.selectionDeleteButtonRect = null;
          page.selectionRotationHandleCenter = null;
          page.selectionResizeHandles = null;
          page.selectionVertexHandles = null;
          _isDraggingVertex = false;
          select.onDragStart(position, dragPageIndex!);
          history.canRedo = true;
          return;
        }
      }

      if (select.doneSelecting &&
          select.selectResult.pageIndex == dragPageIndex!) {
        // Check if tap is on the delete button
        final deleteRect = page.selectionDeleteButtonRect;
        if (deleteRect != null && deleteRect.contains(position)) {
          _deleteSelection(select, page);
          return;
        }

        // Check if tap is on a vertex handle (ArrowStroke / DimensionStroke)
        final vertexHandles = page.selectionVertexHandles;
        if (vertexHandles != null && select.selectResult.strokes.length == 1) {
          final stroke = select.selectResult.strokes.first;
          if (stroke is ArrowStroke || stroke is DimensionStroke) {
            for (int i = 0; i < vertexHandles.length; i++) {
              if ((position - vertexHandles[i]).distance < 20) {
                _isDraggingVertex = true;
                _draggedVertexIndex = i;
                _draggedVertexStroke = stroke;
                return;
              }
            }
          }
        }

        // Check if tap is on a resize handle
        final resizeHandles = page.selectionResizeHandles;
        if (resizeHandles != null) {
          for (int i = 0; i < resizeHandles.length; i++) {
            if ((position - resizeHandles[i]).distance < 16) {
              _isResizing = true;
              _selectionResize = SelectionResize(
                startBounds: select.selectResult.path.getBounds(),
                handleIndex: i,
              );
              return;
            }
          }
        }

        // Check if tap is on the rotation handle
        final rotationHandle = page.selectionRotationHandleCenter;
        if (rotationHandle != null &&
            (position - rotationHandle).distance < 20) {
          _isRotating = true;
          _initialRotationAngle = 0;
          return;
        }

        if (select.selectResult.path.contains(position)) {
          // drag selection in onDrawUpdate
        } else {
          select.unselect();
          page.selectionDeleteButtonRect = null;
          page.selectionRotationHandleCenter = null;
          page.selectionResizeHandles = null;
          page.selectionVertexHandles = null;
          _isDraggingVertex = false;
          select.onDragStart(position, dragPageIndex!);
          history.canRedo = true;
        }
      } else {
        select.onDragStart(position, dragPageIndex!);
        history.canRedo = true; // selection doesn't affect history
      }
    } else if (currentTool is LaserPointer) {
      (currentTool as LaserPointer).onDragStart(position, page, dragPageIndex!);
    } else if (currentTool is Ruler) {
      (currentTool as Ruler).onDragStart(
        position,
        page,
        dragPageIndex!,
        currentPressure,
      );
    }

    previousPosition = position;
    moveOffset = .zero;

    if (currentTool is! Select) {
      Select.currentSelect.unselect();
    }

    // setState to let canvas know about currentStroke
    setState(() {});
  }

  void onDrawUpdate(ScaleUpdateDetails details) {
    final page = coreInfo.pages[dragPageIndex!];
    if (page.activeLayer.locked &&
        (currentTool is Pen || currentTool is Eraser)) {
      return;
    }
    final position = page.renderBox!.globalToLocal(details.focalPoint);
    final offset = position - previousPosition;

    if (currentTool is Pen) {
      final pen = currentTool as Pen;
      // Update pen preview
      page.penPreviewPosition = position;
      page.penPreviewRadius = pen.options.size / 2;
      page.penPreviewColor = pen.color;

      if (stows.scribbleToErase.value) {
        final penStrokeWidth = pen.options.size;
        final lh = (page.lineHeight ?? stows.gridSize.value).toDouble();
        final erased = scribbleDetector.update(
          position,
          page.activeLayerStrokes,
          penStrokeWidth,
          page: page,
          lineHeight: lh > 0 ? lh : 30.0,
        );

        if (scribbleDetector.state == ScribbleState.erasing) {
          if (Pen.currentStroke != null) {
            Pen.currentStroke = null;
          }
          // In scribble-erase mode: erase overlapping strokes
          for (final stroke in erased) {
            page.removeStroke(stroke);
          }
          // Show eraser cursor with eraser radius
          page.eraserCursorPosition = position;
          page.eraserCursorRadius = ScribbleDetector.eraserRadius;
          page.redrawStrokes();
        } else {
          // Still drawing or undetermined — draw normally
          pen.onDragUpdate(position, currentPressure);
          page.redrawStrokes();
        }
      } else {
        // Scribble-to-erase disabled — normal drawing
        (currentTool as Pen).onDragUpdate(position, currentPressure);
        page.redrawStrokes();
      }

      if (stows.circleToSelect.value) {
        circleToSelectDetector.update(position);
      }
    } else if (currentTool is Eraser) {
      final eraser = currentTool as Eraser;
      page.eraserCursorPosition = position;
      page.eraserCursorRadius = eraser.size / 2;
      for (final stroke in eraser.checkForOverlappingStrokes(
        position,
        page.activeLayerStrokes,
      )) {
        page.removeStroke(stroke);
      }
      page.redrawStrokes();
      removeExcessPages();
    } else if (currentTool is Select) {
      final select = currentTool as Select;
      if (_isDraggingVertex && _draggedVertexStroke != null) {
        _selectionTransform ??= SelectionTransform.begin(
          page,
          select.selectResult,
        );
        final stroke = select.selectResult.strokes.first;
        if (stroke is ArrowStroke) {
          if (_draggedVertexIndex == 0) {
            stroke.start = position;
          } else if (_draggedVertexIndex == 1) {
            stroke.end = position;
          }
          stroke.markPolygonNeedsUpdating();
          select.selectResult.path = Select.createTightSelectionPath(
            stroke.lowQualityPolygon,
          );
        } else if (stroke is DimensionStroke) {
          if (_draggedVertexIndex == 0) {
            stroke.start = position;
            final dist = (stroke.end - stroke.start).distance;
            stroke.text = '${dist.toStringAsFixed(1)} px';
          } else if (_draggedVertexIndex == 1) {
            stroke.end = position;
            final dist = (stroke.end - stroke.start).distance;
            stroke.text = '${dist.toStringAsFixed(1)} px';
          } else if (_draggedVertexIndex == 2) {
            final dir = stroke.end - stroke.start;
            final length = dir.distance;
            if (length > 0.001) {
              final perp = Offset(-dir.dy / length, dir.dx / length);
              stroke.offset =
                  (position.dx - stroke.start.dx) * perp.dx +
                  (position.dy - stroke.start.dy) * perp.dy;
            }
          }
          stroke.markPolygonNeedsUpdating();
          select.selectResult.path = Select.createTightSelectionPath(
            stroke.lowQualityPolygon,
          );
        }
        page.redrawStrokes();
        return;
      }
      final resize = _selectionResize;
      if (_isResizing && resize != null && select.doneSelecting) {
        _selectionTransform ??= SelectionTransform.begin(
          page,
          select.selectResult,
        );
        final pivot = resize.pivot;
        final (x: scaleX, y: scaleY) = resize.stepTo(position);

        for (final stroke in select.selectResult.strokes) {
          stroke.scaleAround(scaleX, scaleY, pivot);
        }
        for (final image in select.selectResult.images) {
          final rect = image.dstRect;
          final newCenter = Offset(
            pivot.dx + (rect.center.dx - pivot.dx) * scaleX,
            pivot.dy + (rect.center.dy - pivot.dy) * scaleY,
          );
          image.dstRect = Rect.fromCenter(
            center: newCenter,
            width: rect.width * scaleX,
            height: rect.height * scaleY,
          );
        }
        // Handle text resize: scale text offset relative to pivot
        if (select.selectResult.textSelected) {
          page.textContentOffset = Offset(
            pivot.dx + (page.textContentOffset.dx - pivot.dx) * scaleX,
            pivot.dy + (page.textContentOffset.dy - pivot.dy) * scaleY,
          );
        }
        // Update selection path bounds
        select.selectResult.path = scalePathAround(
          select.selectResult.path,
          scaleX,
          scaleY,
          pivot,
        );
        page.redrawStrokes();
      } else if (_isRotating && select.doneSelecting) {
        _selectionTransform ??= SelectionTransform.begin(
          page,
          select.selectResult,
        );
        // Compute rotation angle
        final bounds = select.selectResult.path.getBounds();
        final center = bounds.center;
        final currentAngle = (position - center).direction;
        if (_initialRotationAngle == 0) {
          _initialRotationAngle = currentAngle;
        }
        final deltaAngle = currentAngle - _initialRotationAngle;
        _initialRotationAngle = currentAngle;

        for (final stroke in select.selectResult.strokes) {
          stroke.rotateAround(deltaAngle, center);
        }
        for (final image in select.selectResult.images) {
          // Rotate image around selection center
          final rect = image.dstRect;
          final cosA = cos(deltaAngle);
          final sinA = sin(deltaAngle);
          final dx = rect.center.dx - center.dx;
          final dy = rect.center.dy - center.dy;
          final newCenter = Offset(
            center.dx + dx * cosA - dy * sinA,
            center.dy + dx * sinA + dy * cosA,
          );
          image.dstRect = Rect.fromCenter(
            center: newCenter,
            width: rect.width,
            height: rect.height,
          );
        }
        // Handle text rotation
        if (select.selectResult.textSelected) {
          page.textContentRotation += deltaAngle;
        }

        // Update the selection path bounds
        select.selectResult.path = _rotatePath(
          select.selectResult.path,
          deltaAngle,
          center,
        );
        page.redrawStrokes();
      } else if (select.doneSelecting) {
        for (final stroke in select.selectResult.strokes) {
          stroke.shift(offset);
        }
        for (final image in select.selectResult.images) {
          image.dstRect = image.dstRect.shift(offset);
        }
        if (select.selectResult.textSelected) {
          page.textContentOffset += offset;
        }
        select.selectResult.path = select.selectResult.path.shift(offset);
      } else {
        select.onDragUpdate(position);
      }
      page.redrawStrokes();
    } else if (currentTool is LaserPointer) {
      (currentTool as LaserPointer).onDragUpdate(position);
      page.redrawStrokes();
    } else if (currentTool is Ruler) {
      (currentTool as Ruler).onDragUpdate(position, currentPressure);
      page.redrawStrokes();
    }
    previousPosition = position;
    moveOffset += offset;
  }

  void onDrawEnd(ScaleEndDetails details) {
    final page = coreInfo.pages[dragPageIndex!];
    if (page.activeLayer.locked &&
        (currentTool is Pen || currentTool is Eraser)) {
      if (currentTool is Pen) (currentTool as Pen).onDragEnd();
      if (currentTool is Eraser) (currentTool as Eraser).onDragEnd();
      page.eraserCursorPosition = null;
      page.eraserCursorRadius = null;
      page.penPreviewPosition = null;
      page.penPreviewRadius = null;
      page.penPreviewColor = null;
      _isRotating = false;
      _initialRotationAngle = 0;
      _isResizing = false;
      _selectionResize = null;
      return;
    }
    bool shouldSave = true;
    setState(() {
      if (currentTool is Pen) {
        circleToSelectDetector.cancel();
        if (scribbleDetector.state == ScribbleState.erasing) {
          final erased = scribbleDetector.end();
          final erasedImages = scribbleDetector.getAndClearErasedImages();
          // Discard the partial stroke that was started before scribble detection
          (currentTool as Pen).onDragEnd();
          page.eraserCursorPosition = null;
          page.eraserCursorRadius = null;
          if (erased.isNotEmpty || erasedImages.isNotEmpty) {
            history.recordChange(
              EditorHistoryItem(
                type: .erase,
                pageIndex: dragPageIndex!,
                strokes: erased,
                images: erasedImages,
              ),
            );
          } else if (!scribbleDetector.erasedText) {
            shouldSave = false;
          }
          return;
        }

        final newStroke = (currentTool as Pen).onDragEnd();
        if (newStroke == null) return;
        if (newStroke.isEmpty) return;

        // Check if a quick tap was on an existing TapeStroke to toggle conceal/reveal
        if (newStroke.length <= 4) {
          final p0 = newStroke.firstPoint;
          final pEnd = newStroke.lastPoint;
          if (p0 != null && pEnd != null && (pEnd - p0).distance < 15.0) {
            for (final stroke in page.strokes.reversed) {
              if (stroke is TapeStroke && stroke.rect.inflate(8).contains(p0)) {
                stroke.toggleConceal();
                page.redrawStrokes();
                autosaveAfterDelay();
                return;
              }
            }
          }
        }

        if ((stows.autoStraightenLines.value || currentTool is Highlighter) &&
            currentTool is! ShapePen &&
            newStroke.isStraightLine()) {
          newStroke.convertToLine();
        }

        createPage(newStroke.pageIndex);
        page.insertStroke(newStroke);
        history.recordChange(
          EditorHistoryItem(
            type: .draw,
            pageIndex: dragPageIndex!,
            strokes: [newStroke],
            images: [],
          ),
        );
      } else if (currentTool is Eraser) {
        final erased = (currentTool as Eraser).onDragEnd();
        if (stylusButtonWasPressed || stows.disableEraserAfterUse.value) {
          // restore previous tool
          stylusButtonWasPressed = false;
          currentTool = _lastNonEraserTool;
        }
        if (erased.isEmpty) return;
        history.recordChange(
          EditorHistoryItem(
            type: .erase,
            pageIndex: dragPageIndex!,
            strokes: erased,
            images: [],
          ),
        );
      } else if (currentTool is Select) {
        final select = currentTool as Select;
        if (_isDraggingVertex) {
          _isDraggingVertex = false;
          _draggedVertexIndex = -1;
          _draggedVertexStroke = null;
          final bounds = select.selectResult.path.getBounds();
          page.selectionDeleteButtonRect = null;
          page.selectionRotationHandleCenter = Offset(
            bounds.center.dx,
            bounds.top - 20,
          );
          final center = bounds.center;
          page.selectionResizeHandles = [
            Offset(bounds.left, bounds.top),
            Offset(center.dx, bounds.top),
            Offset(bounds.right, bounds.top),
            Offset(bounds.right, center.dy),
            Offset(bounds.right, bounds.bottom),
            Offset(center.dx, bounds.bottom),
            Offset(bounds.left, bounds.bottom),
            Offset(bounds.left, center.dy),
          ];
          _recordSelectionTransform(dragPageIndex!);
          return;
        }

        final textRect = page.computeTextContentRect(
          coreInfo.lineHeight.toDouble(),
        );

        // Detect tap (no drag, no resize, no rotate)
        if (moveOffset == .zero && !_isRotating && !_isResizing) {
          if (!select.doneSelecting) {
            // A new selection that ended without dragging → try tap-to-select
            final bounds = select.selectResult.path.getBounds();
            if (bounds.isEmpty || (bounds.width < 20 && bounds.height < 20)) {
              select.tapSelect(
                previousPosition,
                page.strokes,
                page.images,
                dragPageIndex!,
                textRect: textRect,
              );
              shouldSave = false;

              if (select.selectResult.isEmpty) {
                Select.currentSelect.unselect();
                page.selectionDeleteButtonRect = null;
                page.selectionRotationHandleCenter = null;
                page.selectionResizeHandles = null;
                page.selectionVertexHandles = null;
              } else {
                final selectionBounds = select.selectResult.path.getBounds();
                page.selectionDeleteButtonRect = null;
                page.selectionRotationHandleCenter = Offset(
                  selectionBounds.center.dx,
                  selectionBounds.top - 20,
                );
                final center = selectionBounds.center;
                page.selectionResizeHandles = [
                  Offset(selectionBounds.left, selectionBounds.top),
                  Offset(center.dx, selectionBounds.top),
                  Offset(selectionBounds.right, selectionBounds.top),
                  Offset(selectionBounds.right, center.dy),
                  Offset(selectionBounds.right, selectionBounds.bottom),
                  Offset(center.dx, selectionBounds.bottom),
                  Offset(selectionBounds.left, selectionBounds.bottom),
                  Offset(selectionBounds.left, center.dy),
                ];
                if (select.selectResult.strokes.length == 1) {
                  final s = select.selectResult.strokes.first;
                  if (s is ArrowStroke) {
                    page.selectionVertexHandles = [s.start, s.end];
                  } else if (s is DimensionStroke) {
                    page.selectionVertexHandles = [
                      s.start,
                      s.end,
                      s.textPosition,
                    ];
                  } else {
                    page.selectionVertexHandles = null;
                  }
                } else {
                  page.selectionVertexHandles = null;
                }
              }

              // Track for double-tap detection
              _lastTapTime = DateTime.now();
              _lastTapPosition = previousPosition;
              return;
            }
          }
          if (select.doneSelecting) return; // tap on existing selection
          // Otherwise fall through to finalize the lasso selection
        }

        if (_isRotating || _isResizing) {
          _recordSelectionTransform(dragPageIndex!);
        } else if (select.doneSelecting) {
          history.recordChange(
            EditorHistoryItem(
              type: .move,
              pageIndex: dragPageIndex!,
              strokes: select.selectResult.strokes,
              images: select.selectResult.images,
              offset: .fromLTRB(
                moveOffset.dx,
                moveOffset.dy,
                moveOffset.dx,
                moveOffset.dy,
              ),
              textPlacementChange: select.selectResult.textSelected
                  ? Change(
                      previous: (
                        offset: page.textContentOffset - moveOffset,
                        rotation: page.textContentRotation,
                      ),
                      current: page.textPlacement,
                    )
                  : null,
            ),
          );
        } else {
          shouldSave = false;
          select.onDragEnd(page.strokes, page.images, textRect: textRect);

          _updateSelectionHandles(page, select);
        }
      } else if (currentTool is LaserPointer) {
        shouldSave = false;
        final newStroke = (currentTool as LaserPointer).onDragEnd(
          page.redrawStrokes,
          (Stroke stroke) {
            page.laserStrokes.remove(stroke);
          },
        );
        if (newStroke != null) page.laserStrokes.add(newStroke);
      } else if (currentTool is Ruler) {
        final newStroke = (currentTool as Ruler).onDragEnd();
        if (newStroke == null) return;
        if (newStroke.isEmpty) return;

        createPage(newStroke.pageIndex);
        page.insertStroke(newStroke);
        history.recordChange(
          EditorHistoryItem(
            type: .draw,
            pageIndex: dragPageIndex!,
            strokes: [newStroke],
            images: [],
          ),
        );
      }
    });

    // Clear eraser cursor and pen preview after gesture ends
    page.eraserCursorPosition = null;
    page.eraserCursorRadius = null;
    page.penPreviewPosition = null;
    page.penPreviewRadius = null;
    page.penPreviewColor = null;

    // Reset rotation and resize state
    _isRotating = false;
    _initialRotationAngle = 0;
    _isResizing = false;
    _selectionResize = null;

    if (shouldSave) autosaveAfterDelay();
  }

  /// Records the resize, rotation, or vertex edit that just ended,
  /// unless the gesture ended before changing anything.
  void _recordSelectionTransform(int pageIndex) {
    final transform = _selectionTransform;
    _selectionTransform = null;
    if (transform == null) return;
    history.recordChange(transform.finish(pageIndex: pageIndex));
  }

  void onInteractionEnd(ScaleEndDetails details) {
    // reset after 1ms to keep track of the same gesture only
    _lastSeenPointerCountTimer?.cancel();
    _lastSeenPointerCountTimer = Timer(const Duration(milliseconds: 10), () {
      lastSeenPointerCount = 0;
    });
  }

  void updatePointerData(PointerDeviceKind kind, double? pressure) {
    currentPointerKind = kind;
    currentPressure = pressure;
  }

  void onHovering() {
    isHovering = true;
  }

  void onHoveringEnd() {
    isHovering = false;
  }

  void onStylusButtonChanged(bool buttonIsPressed) {
    stylusButtonWasPressed |= buttonIsPressed;

    if (!isHovering) return;
    if (buttonIsPressed) {
      // button pressed while hovering, switch to Eraser
      if (currentTool is! Eraser) {
        currentTool = Eraser(size: stows.eraserSize.value);
      }
    } else {
      // button was released while hovering, switch back to non-Eraser
      if (currentTool is Eraser) {
        currentTool = _lastNonEraserTool;
      }
    }

    if (mounted) setState(() {});
  }

  void onMoveImage(EditorImage image, Rect offset) {
    history.recordChange(
      EditorHistoryItem(
        type: .move,
        pageIndex: image.pageIndex,
        strokes: [],
        images: [image],
        offset: offset,
      ),
    );
    // setState to update undo button
    setState(() {});
    autosaveAfterDelay();
  }

  void onDeleteImage(EditorImage image) {
    history.recordChange(
      EditorHistoryItem(
        type: .erase,
        pageIndex: image.pageIndex,
        strokes: [],
        images: [image],
      ),
    );
    setState(() {
      coreInfo.pages[image.pageIndex].images.remove(image);
    });
    autosaveAfterDelay();
  }

  void listenToQuillChanges(QuillStruct quill, int pageIndex) {
    quill.changeSubscription?.cancel();
    quill.changeSubscription = quill.controller.changes.listen((event) {
      final undoRedoButtonsNeedUpdating = !history.canUndo || history.canRedo;
      _addQuillChangeToHistory(
        quill: quill,
        pageIndex: pageIndex,
        event: event,
      );
      createPage(pageIndex); // create empty last page
      if (undoRedoButtonsNeedUpdating) {
        setState(() {});
      }
      autosaveAfterDelay();
    });
    quill.focusNode.addListener(_onQuillFocusChange);
  }

  void _onQuillFocusChange() {
    for (final page in coreInfo.pages) {
      if (!page.quill.focusNode.hasFocus) continue;
      quillFocus.value = page.quill;
    }
  }

  void _addQuillChangeToHistory({
    required QuillStruct quill,
    required int pageIndex,
    required flutter_quill.DocChange event,
  }) {
    final eventWasUndo = quill.controller.hasRedo;
    if (eventWasUndo) return;

    // the change subscription sometimes fires multiple times for the same change
    // so compare the "before" of each change to merge them
    if (history.canUndo && !history.canRedo) {
      final lastChange = history.peekUndo();
      if (lastChange.type == .quillChange &&
          lastChange.pageIndex == pageIndex &&
          lastChange.quillChange!.before == event.before) {
        history.undo(); // remove the last change, to be replaced
      }
    }

    history.recordChange(
      EditorHistoryItem(
        type: .quillChange,
        pageIndex: pageIndex,
        strokes: const [],
        images: const [],
        quillChange: event,
      ),
    );
  }

  void _refreshCurrentNote() async {
    if (coreInfo.readOnlyReason != .watchingServer) return;
    if (!stows.loggedIn) return;

    final relativeFilePath = coreInfo.filePath;
    assert(relativeFilePath.isNotEmpty, 'Cannot refresh unnamed file');
    final syncFile = await SaberSyncFile.relative(
      relativeFilePath + Editor.extension,
    );

    final bestFile = await SaberSyncInterface.getBestFile(
      syncFile,
      onLocalFileNotFound: .local,
      onEqualFiles: .local,
      preferCache: false,
    );
    if (bestFile != .remote) return;

    late final StreamSubscription<SaberSyncFile> subscription;
    void listener(SaberSyncFile transferred) {
      if (transferred != syncFile) return;
      subscription.cancel();
      _loadCoreInfo(
        relativeFilePath,
      ).then((_) => coreInfo.readOnlyReason = .watchingServer);
    }

    subscription = syncer.downloader.transferStream.listen(listener);

    await syncer.downloader.enqueue(syncFile: syncFile);
    syncer.downloader.bringToFront(syncFile);
  }

  void autosaveAfterDelay() {
    if (history.isCurrentStateSaved) return cancelAutosaveAndMarkSaved();

    late final void Function() callback;

    void startTimer() {
      _delayedSaveTimer?.cancel();
      if (stows.autosaveDelay.value < 0) return;
      _delayedSaveTimer = Timer(
        Duration(milliseconds: stows.autosaveDelay.value),
        callback,
      );
    }

    callback = () {
      if (Pen.currentStroke != null) {
        // don't save yet if the pen is currently drawing
        startTimer();
        return;
      }
      saveToFile();
    };

    savingState.value = .waitingToSave;
    startTimer();
  }

  void cancelAutosaveAndMarkSaved() {
    _delayedSaveTimer?.cancel();
    savingState.value = .saved;
    history.markLastChangeAsSaved();
  }

  Future<void> saveToFile() async {
    if (coreInfo.readOnly) return;

    switch (savingState.value) {
      case .saved:
        // avoid saving if nothing has changed
        return;
      case .saving:
        // avoid saving if already saving
        log.warning('saveToFile() called while already saving');
        return;
      case .waitingToSave:
        // continue
        _delayedSaveTimer?.cancel();
        savingState.value = .saving;
    }
    if (history.isCurrentStateSaved) return cancelAutosaveAndMarkSaved();

    await _renameFileNow();

    final filePath = coreInfo.filePath + Editor.extension;
    final Uint8List bson;
    final OrderedAssetCache assets;
    coreInfo.assetCache.allowRemovingAssets = false;
    try {
      (bson, assets) = coreInfo.saveToBinary(
        currentPageIndex: currentPageIndex,
      );
    } finally {
      coreInfo.assetCache.allowRemovingAssets = true;
    }
    try {
      await Future.wait([
        FileManager.writeFile(filePath, bson, awaitWrite: true),
        for (int i = 0; i < assets.length; ++i)
          assets
              .getBytes(i)
              .then(
                (bytes) => FileManager.writeFile(
                  '$filePath.$i',
                  bytes,
                  awaitWrite: true,
                ),
              ),
        FileManager.removeUnusedAssets(filePath, numAssets: assets.length),
      ]);
      savingState.value = .saved;
      history.markLastChangeAsSaved();
    } catch (e, st) {
      log.severe('Failed to save file: $e', e, st);
      savingState.value = .waitingToSave;
      if (kDebugMode) rethrow;
      return;
    }

    if (!mounted) return;
    final page = coreInfo.pages.first;
    final previewHeight = page.previewHeight(lineHeight: coreInfo.lineHeight);
    final thumbnailSize = Size(720, 720 * previewHeight / page.size.width);
    final thumbnail = await EditorExporter.screenshotPage(
      coreInfo: coreInfo,
      pageIndex: 0,
      rasterizeAllStrokes: true,
      targetSize: thumbnailSize,
      cropHeight: previewHeight,
      pixelRatio: 1,
    );
    final thumbnailPng = await thumbnail.toByteData(format: .png);
    thumbnail.dispose();
    await FileManager.writeFile(
      // Note that this ends with .sbn2.p
      '$filePath.p',
      thumbnailPng!.buffer.asUint8List(),
      awaitWrite: true,
    );
  }

  late final _filenameFormKey = GlobalKey<FormState>();
  late final filenameTextEditingController = TextEditingController();
  Timer? _renameTimer;
  void renameFile([String? _]) {
    _renameTimer?.cancel();
    _renameTimer = Timer(const Duration(seconds: 5), _renameFileNow);
  }

  Future<void> _renameFileNow() async {
    final newName = filenameTextEditingController.text.trim();
    if (newName == coreInfo.fileName) return;

    if (_filenameFormKey.currentState?.validate() ??
        _validateFilenameTextField(newName) == null) {
      coreInfo.filePath = await FileManager.moveFile(
        coreInfo.filePath + Editor.extension,
        newName.trim() + Editor.extension,
      );
      coreInfo.filePath = coreInfo.filePath.substring(
        0,
        coreInfo.filePath.lastIndexOf(Editor.extension),
      );
      needsNaming = false;
    }

    final actualName = coreInfo.fileName;
    if (actualName != newName) {
      // update text field if renamed differently
      filenameTextEditingController.value = filenameTextEditingController.value
          .copyWith(
            text: actualName,
            selection: TextSelection.fromPosition(
              TextPosition(offset: actualName.length),
            ),
            composing: TextRange.empty,
          );
    }
  }

  String? _validateFilenameTextField(String? newName) {
    if (newName == null) return null;
    return FileManager.validateFilename(newName);
  }

  void updateColorBar(Color color) {
    if (stows.recentColorsDontSavePresets.value) {
      if (ColorBar.colorPresets.any(
        (colorPreset) => colorPreset.color == color,
      )) {
        return;
      }
    }

    final newColorString = color.toARGB32().toString();

    // migrate from old pref format
    if (stows.recentColorsChronological.value.length !=
        stows.recentColorsPositioned.value.length) {
      log.info(
        'MIGRATING recentColors: ${stows.recentColorsChronological.value.length} vs ${stows.recentColorsPositioned.value.length}',
      );
      stows.recentColorsChronological.value = List.of(
        stows.recentColorsPositioned.value,
      );
    }

    if (stows.pinnedColors.value.contains(newColorString)) {
      // do nothing, color is already pinned
    } else if (stows.recentColorsPositioned.value.contains(newColorString)) {
      // if it's already a recent color, move it to the top
      stows.recentColorsChronological.value.remove(newColorString);
      stows.recentColorsChronological.value.add(newColorString);
      stows.recentColorsChronological.notifyListeners();
    } else {
      if (stows.recentColorsPositioned.value.length >=
          stows.recentColorsLength.value) {
        // if full, replace the oldest color with the new one
        final removedColorString = stows.recentColorsChronological.value
            .removeAt(0);
        stows.recentColorsChronological.value.add(newColorString);
        final int removedColorPosition = stows.recentColorsPositioned.value
            .indexOf(removedColorString);
        stows.recentColorsPositioned.value[removedColorPosition] =
            newColorString;
      } else {
        // if not full, add the new color to the end
        stows.recentColorsChronological.value.add(newColorString);
        stows.recentColorsPositioned.value.insert(0, newColorString);
      }
      stows.recentColorsChronological.notifyListeners();
      stows.recentColorsPositioned.notifyListeners();
    }
  }

  /// Prompts the user to pick photos from their device.
  /// Returns the number of photos picked.
  ///
  /// If [photoInfos] is provided, it will be used instead of the file picker.
  Future<int> _pickPhotos([List<_PhotoInfo>? photoInfos]) async {
    if (coreInfo.readOnly) return 0;

    final currentPageIndex = this.currentPageIndex;

    photoInfos ??= await _pickPhotosWithFilePicker();
    if (photoInfos.isEmpty) return 0;

    // use the Select tool so that the user can move the new image
    currentTool = Select.currentSelect;

    final images = [
      for (final _PhotoInfo photoInfo in photoInfos)
        if (photoInfo.extension == '.svg')
          SvgEditorImage(
            id: coreInfo.nextImageId++,
            svgString: utf8.decode(photoInfo.bytes),
            svgFile: null,
            pageIndex: currentPageIndex,
            pageSize: coreInfo.pages[currentPageIndex].size,
            onMoveImage: onMoveImage,
            onDeleteImage: onDeleteImage,
            onMiscChange: autosaveAfterDelay,
            onLoad: () => setState(() {}),
            assetCache: coreInfo.assetCache,
          )
        else
          PngEditorImage(
            id: coreInfo.nextImageId++,
            extension: photoInfo.extension,
            imageProvider: MemoryImage(photoInfo.bytes),
            pageIndex: currentPageIndex,
            pageSize: coreInfo.pages[currentPageIndex].size,
            onMoveImage: onMoveImage,
            onDeleteImage: onDeleteImage,
            onMiscChange: autosaveAfterDelay,
            onLoad: () => setState(() {}),
            assetCache: coreInfo.assetCache,
          ),
    ];

    final center = _getPlacementCenter(currentPageIndex);
    for (int i = 0; i < images.length; i++) {
      final img = images[i];
      await img.loadIn();
      final offset = Offset(i * 20.0, i * 20.0);
      final imgCenter = center + offset;
      final w = img.dstRect.width > 0 ? img.dstRect.width : 200.0;
      final h = img.dstRect.height > 0 ? img.dstRect.height : 200.0;
      img.dstRect = Rect.fromCenter(center: imgCenter, width: w, height: h);
    }

    history.recordChange(
      EditorHistoryItem(
        type: .draw,
        pageIndex: currentPageIndex,
        strokes: [],
        images: images,
      ),
    );
    createPage(currentPageIndex);
    coreInfo.pages[currentPageIndex].images.addAll(images);
    Select.currentSelect.selectImages(images, currentPageIndex);
    _updateSelectionHandles(
      coreInfo.pages[currentPageIndex],
      Select.currentSelect,
    );
    setState(() {});
    autosaveAfterDelay();

    return images.length;
  }

  Future<void> _insertShapeFromLibrary() async {
    if (coreInfo.readOnly) return;
    final currentPageIndex = this.currentPageIndex;

    final svgString = await ShapeLibraryDialog.show(context);
    if (svgString == null || svgString.isEmpty) return;

    currentTool = Select.currentSelect;

    final image = SvgEditorImage(
      id: coreInfo.nextImageId++,
      svgString: svgString,
      svgFile: null,
      pageIndex: currentPageIndex,
      pageSize: coreInfo.pages[currentPageIndex].size,
      onMoveImage: onMoveImage,
      onDeleteImage: onDeleteImage,
      onMiscChange: autosaveAfterDelay,
      onLoad: () => setState(() {}),
      assetCache: coreInfo.assetCache,
    );

    await image.loadIn();
    final center = _getPlacementCenter(currentPageIndex);
    final w = image.dstRect.width > 0 ? image.dstRect.width : 200.0;
    final h = image.dstRect.height > 0 ? image.dstRect.height : 200.0;
    image.dstRect = Rect.fromCenter(center: center, width: w, height: h);

    history.recordChange(
      EditorHistoryItem(
        type: .draw,
        pageIndex: currentPageIndex,
        strokes: [],
        images: [image],
      ),
    );
    createPage(currentPageIndex);
    coreInfo.pages[currentPageIndex].images.add(image);
    Select.currentSelect.selectImages([image], currentPageIndex);
    _updateSelectionHandles(
      coreInfo.pages[currentPageIndex],
      Select.currentSelect,
    );
    setState(() {});
    autosaveAfterDelay();
  }

  void _addStickyNote() {
    if (coreInfo.readOnly) return;
    final currentPageIndex = this.currentPageIndex;

    // Use the Select tool so that the user can move the new image
    currentTool = Select.currentSelect;
    final center = _getPlacementCenter(currentPageIndex);

    final image = StickyNoteImage(
      id: coreInfo.nextImageId++,
      assetCache: coreInfo.assetCache,
      color: const Color(0xFFFFF59D), // yellow default
      text: t.editor.stickyNote.defaultText,
      pageIndex: currentPageIndex,
      pageSize: coreInfo.pages[currentPageIndex].size,
      onMoveImage: onMoveImage,
      onDeleteImage: onDeleteImage,
      onMiscChange: autosaveAfterDelay,
      onLoad: () => setState(() {}),
      dstRect: Rect.fromCenter(center: center, width: 200, height: 200),
    );

    history.recordChange(
      EditorHistoryItem(
        type: .draw,
        pageIndex: currentPageIndex,
        strokes: [],
        images: [image],
      ),
    );
    createPage(currentPageIndex);
    coreInfo.pages[currentPageIndex].images.add(image);
    Select.currentSelect.selectImages([image], currentPageIndex);
    _updateSelectionHandles(
      coreInfo.pages[currentPageIndex],
      Select.currentSelect,
    );
    setState(() {});
    autosaveAfterDelay();
  }

  void _addSticker(String emoji) {
    if (coreInfo.readOnly) return;
    final currentPageIndex = this.currentPageIndex;

    // Use the Select tool so that the user can move the new image
    currentTool = Select.currentSelect;

    const double size = 64;
    final center = _getPlacementCenter(currentPageIndex);

    final image = StickerImage(
      id: coreInfo.nextImageId++,
      assetCache: coreInfo.assetCache,
      emoji: emoji,
      pageIndex: currentPageIndex,
      pageSize: coreInfo.pages[currentPageIndex].size,
      onMoveImage: onMoveImage,
      onDeleteImage: onDeleteImage,
      onMiscChange: autosaveAfterDelay,
      onLoad: () => setState(() {}),
      dstRect: Rect.fromCenter(center: center, width: size, height: size),
    );

    history.recordChange(
      EditorHistoryItem(
        type: .draw,
        pageIndex: currentPageIndex,
        strokes: [],
        images: [image],
      ),
    );
    createPage(currentPageIndex);
    coreInfo.pages[currentPageIndex].images.add(image);
    Select.currentSelect.selectImages([image], currentPageIndex);
    _updateSelectionHandles(
      coreInfo.pages[currentPageIndex],
      Select.currentSelect,
    );
    setState(() {});
    autosaveAfterDelay();
  }

  Future<List<_PhotoInfo>> _pickPhotosWithFilePicker() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      // Taken from
      // https://github.com/brendan-duncan/image/blob/main/doc/formats.md
      // (plus .svg)
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'tiff',
        'bmp',
        'tga',
        'ico',
        'pvrtc',
        'svg',
        'webp',
        'psd',
        'exr',
      ],
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return const [];

    return [
      for (final PlatformFile file in result.files)
        if (file.bytes != null && file.extension != null)
          (bytes: file.bytes!, extension: '.${file.extension}'),
    ];
  }

  /// Prompts the user to pick a PDF to import.
  /// Returns whether a PDF was picked.
  Future<bool> importPdf() async {
    if (coreInfo.readOnly) return false;
    if (!Editor.canRasterPdf) return false;

    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null) return false;

    final PlatformFile file = result.files.single;
    return importPdfFromFilePath(file.path!);
  }

  Future<bool> importPdfFromFilePath(String path) async {
    final pdfDocument = await coreInfo.assetCache.pdfDocumentCache.load(path);

    final emptyPage = coreInfo.pages.removeLast();
    assert(emptyPage.isEmpty);

    for (final pdfPage in pdfDocument.pages) {
      assert(pdfPage.pageNumber >= 1, 'pdfrx page numbers start at 1');

      // resize to [defaultWidth] to keep pen sizes consistent
      final pageSize = Size(
        EditorPage.defaultWidth,
        EditorPage.defaultWidth * pdfPage.height / pdfPage.width,
      );

      final page = EditorPage(
        size: pageSize,
        backgroundImage: PdfEditorImage(
          id: coreInfo.nextImageId++,
          pdfBytes: null,
          pdfFile: File(path),
          pdfPage: pdfPage.pageNumber - 1,
          pageIndex: coreInfo.pages.length,
          pageSize: pageSize,
          naturalSize: pdfPage.size,
          onMoveImage: onMoveImage,
          onDeleteImage: onDeleteImage,
          onMiscChange: autosaveAfterDelay,
          onLoad: () => setState(() {}),
          assetCache: coreInfo.assetCache,
        ),
      );
      coreInfo.pages.add(page);
      // TODO(adil192): Group multiple pages into one atomic change
      history.recordChange(
        EditorHistoryItem(
          type: .insertPage,
          pageIndex: coreInfo.pages.length - 1,
          strokes: const [],
          images: const [],
          page: page,
        ),
      );
    }

    coreInfo.pages.add(emptyPage);
    if (mounted) setState(() {});

    autosaveAfterDelay();

    return true;
  }

  Future paste() async {
    /// Maps image formats to their file extension.
    const Map<SimpleFileFormat, String> formats = {
      Formats.jpeg: '.jpeg',
      Formats.png: '.png',
      Formats.gif: '.gif',
      Formats.tiff: '.tiff',
      Formats.bmp: '.bmp',
      Formats.ico: '.ico',
      Formats.svg: '.svg',
      Formats.webp: '.webp',
    };

    final reader = await SystemClipboard.instance?.read();
    if (reader == null) return;

    final List<_PhotoInfo> photoInfos = [];
    final List<ReadProgress> progresses = [];

    for (final format in formats.keys) {
      if (!reader.canProvide(format)) continue;
      final progress = reader.getFile(format, (file) async {
        final stream = file.getStream();
        final List<int> bytes = [];
        await for (final chunk in stream) {
          bytes.addAll(chunk);
        }
        if (bytes.isEmpty) {
          log.warning('Pasted empty file: $file (${formats[format]})');
          return;
        }

        String extension;
        if (file.fileName != null) {
          extension = file.fileName!.substring(file.fileName!.lastIndexOf('.'));
        } else {
          extension = formats[format]!;
        }

        photoInfos.add((
          bytes: Uint8List.fromList(bytes),
          extension: extension,
        ));
      });
      if (progress != null) progresses.add(progress);
    }

    while (progresses.isNotEmpty) {
      progresses.removeWhere((progress) => progress.fraction.value == 1);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await _pickPhotos(photoInfos);
  }

  /// Updates selection handles (rotation, resize, and vertex handles) on [page]
  /// to match [select.selectResult].
  void _updateSelectionHandles(EditorPage page, Select select) {
    if (select.selectResult.isEmpty) {
      select.unselect();
      page.selectionDeleteButtonRect = null;
      page.selectionRotationHandleCenter = null;
      page.selectionResizeHandles = null;
      page.selectionVertexHandles = null;
      return;
    }
    final bounds = select.selectResult.path.getBounds();
    page.selectionDeleteButtonRect = null;
    page.selectionRotationHandleCenter = Offset(
      bounds.center.dx,
      bounds.top - 20,
    );
    final center = bounds.center;
    page.selectionResizeHandles = [
      Offset(bounds.left, bounds.top),
      Offset(center.dx, bounds.top),
      Offset(bounds.right, bounds.top),
      Offset(bounds.right, center.dy),
      Offset(bounds.right, bounds.bottom),
      Offset(center.dx, bounds.bottom),
      Offset(bounds.left, bounds.bottom),
      Offset(bounds.left, center.dy),
    ];
    if (select.selectResult.strokes.length == 1) {
      final s = select.selectResult.strokes.first;
      if (s is ArrowStroke) {
        page.selectionVertexHandles = [s.start, s.end];
      } else if (s is DimensionStroke) {
        page.selectionVertexHandles = [s.start, s.end, s.textPosition];
      } else {
        page.selectionVertexHandles = null;
      }
    } else {
      page.selectionVertexHandles = null;
    }
  }

  /// Calculates the target center for placing new elements, photos, or shapes.
  /// Prioritizes the user's most recent canvas tap if it occurred recently
  /// (within 30 seconds) on [pageIndex]. Otherwise, projects the center of
  /// the current visible screen/viewport into local page coordinates.
  Offset _getPlacementCenter(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= coreInfo.pages.length) {
      return const Offset(200, 200);
    }

    if (_lastCanvasTapPosition != null &&
        _lastCanvasTapPageIndex == pageIndex &&
        _lastCanvasTapTime != null &&
        DateTime.now().difference(_lastCanvasTapTime!).inSeconds < 30) {
      final tapPos = _lastCanvasTapPosition!;
      _lastCanvasTapPosition = null;
      _lastCanvasTapPageIndex = null;
      _lastCanvasTapTime = null;
      return tapPos;
    }

    final page = coreInfo.pages[pageIndex];
    if (page.renderBox != null && mounted) {
      try {
        final mediaQuery = MediaQuery.maybeSizeOf(context);
        final screenSize = mediaQuery ?? const Size(800, 600);
        final screenCenter = Offset(
          screenSize.width / 2,
          screenSize.height / 2,
        );
        final localCenter = page.renderBox!.globalToLocal(screenCenter);
        if (!coreInfo.isInfiniteCanvas) {
          final clampedX = localCenter.dx.clamp(
            50.0,
            (page.size.width - 50.0).clamp(50.0, double.infinity),
          );
          final clampedY = localCenter.dy.clamp(
            50.0,
            (page.size.height - 50.0).clamp(50.0, double.infinity),
          );
          return Offset(clampedX, clampedY);
        }
        return localCenter;
      } catch (_) {
        // Fallback below
      }
    }

    return Offset(page.size.width / 2, page.size.height / 2);
  }

  void _deleteSelection(Select select, EditorPage page) {
    final strokes = List<Stroke>.from(select.selectResult.strokes);
    final images = List<EditorImage>.from(select.selectResult.images);

    for (final stroke in strokes) {
      page.removeStroke(stroke);
    }
    for (final image in images) {
      page.images.remove(image);
    }
    if (select.selectResult.textSelected &&
        !page.quill.controller.document.isEmpty()) {
      page.quill.controller.clear();
    }

    page.selectionDeleteButtonRect = null;
    page.selectionResizeHandles = null;
    page.selectionRotationHandleCenter = null;
    page.selectionVertexHandles = null;
    select.unselect();
    page.redrawStrokes();

    history.recordChange(
      EditorHistoryItem(
        type: .erase,
        pageIndex: strokes.firstOrNull?.pageIndex ?? 0,
        strokes: strokes,
        images: images,
      ),
    );
    autosaveAfterDelay();
    setState(() {});
  }

  void _onCircleToSelectDetected(Path path) {
    if (!mounted || dragPageIndex == null) return;
    final page = coreInfo.pages[dragPageIndex!];

    // Discard the pen stroke currently being drawn
    if (currentTool is Pen) {
      (currentTool as Pen).onDragEnd();
    }

    HapticFeedback.mediumImpact();

    final textRect = page.computeTextContentRect(
      coreInfo.lineHeight.toDouble(),
    );

    Select.currentSelect.selectFromPath(
      path: path,
      strokes: page.activeLayerStrokes,
      images: page.images,
      pageIndex: dragPageIndex!,
      textRect: textRect,
    );

    currentTool = Select.currentSelect;
    _updateSelectionHandles(page, Select.currentSelect);

    page.redrawStrokes();
    setState(() {});
  }

  bool get currentPageHasTape {
    final idx = currentPageIndex;
    if (idx >= coreInfo.pages.length) return false;
    return coreInfo.pages[idx].strokes.any((s) => s is TapeStroke);
  }

  void _revealAllTapeOnCurrentPage() {
    final idx = currentPageIndex;
    if (idx >= coreInfo.pages.length) return;
    final page = coreInfo.pages[idx];
    for (final s in page.strokes) {
      if (s is TapeStroke) s.isConcealed = false;
    }
    page.redrawStrokes();
    autosaveAfterDelay();
    setState(() {});
  }

  void _concealAllTapeOnCurrentPage() {
    final idx = currentPageIndex;
    if (idx >= coreInfo.pages.length) return;
    final page = coreInfo.pages[idx];
    for (final s in page.strokes) {
      if (s is TapeStroke) s.isConcealed = true;
    }
    page.redrawStrokes();
    autosaveAfterDelay();
    setState(() {});
  }

  /// Rotates a [Path] by [angleRadians] around [center].
  static Path _rotatePath(Path path, double angleRadians, Offset center) {
    if (angleRadians == 0) return path;
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return path;

    final cosA = cos(angleRadians);
    final sinA = sin(angleRadians);

    // Extract the path vertices and rebuild
    final newPath = Path();
    for (final metric in metrics) {
      for (double dist = 0; dist < metric.length; dist += 5) {
        final tangent = metric.getTangentForOffset(dist);
        if (tangent == null) continue;
        final pos = tangent.position;
        final dx = pos.dx - center.dx;
        final dy = pos.dy - center.dy;
        final rotated = Offset(
          center.dx + dx * cosA - dy * sinA,
          center.dy + dx * sinA + dy * cosA,
        );
        if (dist == 0) {
          newPath.moveTo(rotated.dx, rotated.dy);
        } else {
          newPath.lineTo(rotated.dx, rotated.dy);
        }
      }
    }
    return newPath;
  }

  void _copySelection() {
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    setState(() {
      _clipboard = SelectionClipboard.copyOf(select.selectResult);
    });
  }

  void _duplicateSelection() {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;

    setState(() {
      final pageIndex = select.selectResult.pageIndex;
      const duplicationFeedbackOffset = Offset(25, -25);

      final duplicated = SelectionClipboard.copyOf(select.selectResult)
          .pasteOnto(
            coreInfo.pages[pageIndex],
            pageIndex: pageIndex,
            takeImageId: () => coreInfo.nextImageId++,
            offset: duplicationFeedbackOffset,
          );

      select.selectResult = select.selectResult.copyWith(
        strokes: duplicated.strokes,
        images: duplicated.images,
        path: select.selectResult.path.shift(duplicationFeedbackOffset),
      );

      history.recordChange(duplicated);
      autosaveAfterDelay();
    });
  }

  void _cutSelection() {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final page = coreInfo.pages[select.selectResult.pageIndex];
    setState(() {
      _copySelection();
      _deleteSelection(select, page);
    });
  }

  void _setSelectionColor(Color color) {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final strokes = select.selectResult.strokes;
    if (strokes.isEmpty) return;

    setState(() {
      updateColorBar(color);

      final colorChange = <Stroke, Change<Color>>{};
      for (final stroke in strokes) {
        colorChange[stroke] = Change(previous: stroke.color, current: color);
        stroke.color = color;
      }

      history.recordChange(
        EditorHistoryItem(
          type: .changeColor,
          pageIndex: strokes.first.pageIndex,
          strokes: strokes,
          colorChange: colorChange,
          images: [],
        ),
      );
      autosaveAfterDelay();
    });
  }

  void _bringSelectionToFront() {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final page = coreInfo.pages[select.selectResult.pageIndex];
    final strokes = select.selectResult.strokes;
    final images = select.selectResult.images;
    if (strokes.isEmpty && images.isEmpty) return;

    setState(() {
      if (strokes.isNotEmpty) {
        page.activeLayerStrokes.removeWhere((s) => strokes.contains(s));
        page.activeLayerStrokes.addAll(strokes);
      }
      if (images.isNotEmpty) {
        page.images.removeWhere((img) => images.contains(img));
        page.images.addAll(images);
      }
      page.redrawStrokes();
      autosaveAfterDelay();
    });
  }

  void _sendSelectionToBack() {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final page = coreInfo.pages[select.selectResult.pageIndex];
    final strokes = select.selectResult.strokes;
    final images = select.selectResult.images;
    if (strokes.isEmpty && images.isEmpty) return;

    setState(() {
      if (strokes.isNotEmpty) {
        page.activeLayerStrokes.removeWhere((s) => strokes.contains(s));
        page.activeLayerStrokes.insertAll(0, strokes);
      }
      if (images.isNotEmpty) {
        page.images.removeWhere((img) => images.contains(img));
        page.images.insertAll(0, images);
      }
      page.redrawStrokes();
      autosaveAfterDelay();
    });
  }

  void _smoothenSelection() {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final page = coreInfo.pages[select.selectResult.pageIndex];
    final strokes = select.selectResult.strokes;
    if (strokes.isEmpty) return;

    setState(() {
      for (final stroke in strokes) {
        stroke.smoothen(iterations: 2);
      }
      page.redrawStrokes();
      autosaveAfterDelay();
    });
  }

  void _addToElements() {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final strokes = select.selectResult.strokes;
    if (strokes.isEmpty) return;

    final controller = TextEditingController(
      text: t.editor.elements.defaultName(
        n: ElementsManager.instance.items.length + 1,
      ),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.editor.elements.add),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: t.editor.elements.nameLabel,
            hintText: t.editor.elements.nameHint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim().isNotEmpty
                  ? controller.text.trim()
                  : 'Element';
              ElementsManager.instance.addElement(
                name: name,
                strokes: strokes,
                category: 'My Elements',
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.editor.elements.added(name: name)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(t.editor.actions.save),
          ),
        ],
      ),
    );
  }

  void _toggleSelectionResize() {
    setState(() {
      Select.currentSelect.isResizeActive =
          !Select.currentSelect.isResizeActive;
    });
  }

  Future<void> _takeSelectionScreenshot() async {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting || select.selectResult.isEmpty) return;

    final page = coreInfo.pages[select.selectResult.pageIndex];
    final bounds = select.selectResult.path.getBounds();
    if (bounds.isEmpty || bounds.width <= 0 || bounds.height <= 0) return;

    final renderBounds = bounds.inflate(14.0);
    final width = renderBounds.width.ceil().toDouble();
    final height = renderBounds.height.ceil().toDouble();

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Draw background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Translate coordinate system
    canvas.translate(-renderBounds.left, -renderBounds.top);

    final painter = CanvasPainter(
      page: page,
      strokes: select.selectResult.strokes,
      laserStrokes: const [],
      currentStroke: null,
      currentSelection: null,
      isDoneSelecting: true,
      primaryColor: Theme.of(context).colorScheme.primary,
      showPageIndicator: false,
      pageIndex: select.selectResult.pageIndex,
      totalPages: coreInfo.pages.length,
      currentScale: 1.0,
      defaultTextStyle:
          Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
      invert: false,
    );
    painter.paint(canvas, Size(renderBounds.right, renderBounds.bottom));

    final picture = recorder.endRecording();
    const scale = 2.0;
    final uiImage = await picture.toImage(
      (width * scale).toInt(),
      (height * scale).toInt(),
    );
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final bytes = byteData.buffer.asUint8List();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => LassoScreenshotDialog(
        imageBytes: bytes,
        onCopied: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.editor.lasso.screenshotCopied),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _openElementsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ElementsSheet(onSelectElement: _stampElement),
    );
  }

  void _stampElement(ElementItem item) {
    if (coreInfo.readOnly) return;
    final pageIndex = currentPageIndex.clamp(0, coreInfo.pages.length - 1);
    final page = coreInfo.pages[pageIndex];
    if (page.activeLayer.locked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.editor.elements.lockedLayer)));
      return;
    }

    final targetCenter = _getPlacementCenter(pageIndex);
    final newStrokes = item.instantiateStrokes(
      page: page,
      targetCenter: targetCenter,
    );
    if (newStrokes.isEmpty) return;

    for (final s in newStrokes) {
      s.pageIndex = pageIndex;
      page.insertStroke(s);
    }

    history.recordChange(
      EditorHistoryItem(
        type: .draw,
        pageIndex: pageIndex,
        strokes: newStrokes,
        images: [],
      ),
    );

    page.redrawStrokes();
    currentTool = Select.currentSelect;
    Select.currentSelect.selectStrokes(newStrokes, pageIndex);
    _updateSelectionHandles(page, Select.currentSelect);
    setState(() {});
    autosaveAfterDelay();
  }

  /// Whether the current selection has exactly one image and no strokes,
  /// which makes the crop button available.
  bool get _cropPossible {
    if (currentTool is! Select) return false;
    final select = currentTool as Select;
    if (!select.doneSelecting) return false;
    return select.selectResult.images.length == 1 &&
        select.selectResult.strokes.isEmpty;
  }

  /// Whether crop mode is currently active on the single selected image.
  bool get _cropActive {
    if (!_cropPossible) return false;
    return (currentTool as Select).selectResult.images.first.cropMode;
  }

  /// Toggles crop mode on the single selected image.
  void _toggleCrop() {
    if (!_cropPossible) return;
    final select = currentTool as Select;
    final image = select.selectResult.images.first;
    setState(() {
      image.cropMode = !image.cropMode;
    });
  }

  void _pasteSelection() {
    final clipboard = _clipboard;
    if (clipboard == null || clipboard.isEmpty) return;
    setState(() {
      final pageIndex = dragPageIndex ?? currentPageIndex;
      history.recordChange(
        clipboard.pasteOnto(
          coreInfo.pages[pageIndex],
          pageIndex: pageIndex,
          takeImageId: () => coreInfo.nextImageId++,
        ),
      );
      autosaveAfterDelay();
    });
  }

  Future exportAsPdf(BuildContext context) async {
    final pdf = await EditorExporter.generatePdf(coreInfo, context);
    final bytes = await pdf.save();
    if (!context.mounted) return;
    await FileManager.exportFile(
      '${coreInfo.fileName}.pdf',
      bytes,
      context: context,
    );
  }

  /// Exports the current note as an SBA (Saber Archive) file.
  Future exportAsSba(BuildContext context) async {
    final sba = await coreInfo.saveToSba(currentPageIndex: currentPageIndex);
    if (!context.mounted) return;
    await FileManager.exportFile(
      '${coreInfo.fileName}.sba',
      sba,
      context: context,
    );
  }

  /// Exports the current page as a PNG image file.
  ///
  /// This captures the canvas natively via [EditorExporter.screenshotPage],
  /// which guarantees the correct background color and omits UI elements
  /// like selection bounds or the text cursor. It computes a dynamic [pixelRatio]
  /// to ensure high quality while averting Out-Of-Memory exceptions on large canvases.
  Future exportAsPng(BuildContext context) async {
    final page = coreInfo.pages[currentPageIndex];

    const maxRasterizableSize = 3000.0;
    var targetPixelRatio = maxRasterizableSize / page.size.longestSide;
    if (targetPixelRatio > 1) targetPixelRatio = 1;

    try {
      final image = await EditorExporter.screenshotPage(
        coreInfo: coreInfo,
        pageIndex: currentPageIndex,
        rasterizeAllStrokes: true,
        pixelRatio: targetPixelRatio,
      );
      final pngBytes = await image.toByteData(format: .png);
      image.dispose();

      if (!context.mounted) return;
      await FileManager.exportFile(
        '${coreInfo.fileName}_page_${currentPageIndex + 1}.png',
        pngBytes!.buffer.asUint8List(),
        isImage: true,
        context: context,
      );
    } catch (e, st) {
      log.severe('Failed to export PNG', e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final platform = Theme.of(context).platform;
    final isToolbarVertical =
        stows.editorToolbarAlignment.value == AxisDirection.left ||
        stows.editorToolbarAlignment.value == AxisDirection.right;

    final int currentPageIdx = currentPageIndex;
    final bool currentPageBookmarked =
        coreInfo.pages.isNotEmpty &&
        currentPageIdx < coreInfo.pages.length &&
        coreInfo.pages[currentPageIdx].bookmarked;

    final Widget canvas = CanvasGestureDetector(
      key: _canvasGestureDetectorKey,
      filePath: coreInfo.filePath,
      isDrawGesture: isDrawGesture,
      onInteractionEnd: onInteractionEnd,
      onDrawStart: onDrawStart,
      onDrawUpdate: onDrawUpdate,
      onDrawEnd: onDrawEnd,
      onHovering: onHovering,
      onHoveringEnd: onHoveringEnd,
      onStylusButtonChanged: onStylusButtonChanged,
      updatePointerData: updatePointerData,
      undo: undo,
      redo: redo,
      pages: coreInfo.pages,
      initialPageIndex: coreInfo.initialPageIndex,
      pageBuilder: pageBuilder,
      isTextEditing: () => currentTool == Tool.textEditing,
      bookmarked: currentPageBookmarked,
      onToggleBookmarked: () => setState(() {
        if (coreInfo.readOnly) return;
        final pageIdx = currentPageIndex;
        if (pageIdx >= coreInfo.pages.length) return;
        final page = coreInfo.pages[pageIdx];
        page.bookmarked = !page.bookmarked;
        page.redrawStrokes();
        autosaveAfterDelay();
      }),
      hasTape: currentPageHasTape,
      onRevealAllTape: _revealAllTapeOnCurrentPage,
      onConcealAllTape: _concealAllTapeOnCurrentPage,
      activePage: coreInfo.pages.isNotEmpty
          ? coreInfo.pages[currentPageIndex.clamp(0, coreInfo.pages.length - 1)]
          : null,
      onLayersChanged: () => setState(() {
        autosaveAfterDelay();
      }),
      isInfiniteCanvas: coreInfo.isInfiniteCanvas,
      placeholderPageBuilder: (BuildContext context, int pageIndex) {
        return Canvas(
          path: coreInfo.filePath,
          page: coreInfo.pages[pageIndex],
          pageIndex: 0,
          textEditing: false,
          coreInfo: EditorCoreInfo.placeholder,
          currentStroke: null,
          currentStrokeDetectedShape: null,
          currentSelection: null,
          placeholder: true,
          setAsBackground: null,
          currentTool: currentTool,
          currentScale: double.minPositive,
        );
      },
      transformationController: _transformationController,
    );

    final readonlyBanner = ReadOnlyBanner(
      coreInfo.readOnlyReason,
      action: coreInfo.readOnlyReason == .versionTooNew
          ? showVersionTooNewDialog
          : null,
    );

    final Widget toolbarContent = stows.goodnotesUiMode.value
        ? GoodnotesToolbar(
            readOnly: coreInfo.readOnly,
            setTool: (tool) {
              if (tool is Eraser && currentTool is Eraser) {
                tool = _lastNonEraserTool;
              }
              currentTool = tool;
              if (tool is Highlighter) {
                Highlighter.currentHighlighter = tool;
              } else if (tool is Pencil) {
                Pencil.currentPencil = tool;
              } else if (Pen.isWritingPen(tool)) {
                Pen.currentPen = tool as Pen;
              }
              if (mounted) setState(() {});
            },
            currentTool: currentTool,
            duplicateSelection: _duplicateSelection,
            deleteSelection: () {
              final select = currentTool as Select;
              if (!select.doneSelecting) return;
              final page = coreInfo.pages[select.selectResult.pageIndex];
              setState(() => _deleteSelection(select, page));
            },
            setColor: (color) {
              setState(() {
                updateColorBar(color);
                if (currentTool is Highlighter) {
                  (currentTool as Highlighter).color = color.withAlpha(
                    Highlighter.alpha,
                  );
                } else if (currentTool is Pen) {
                  (currentTool as Pen).color = color;
                } else if (currentTool is Select) {
                  _setSelectionColor(color);
                }
              });
            },
            quillFocus: quillFocus,
            textEditing: currentTool == Tool.textEditing,
            toggleTextEditing: () => setState(() {
              if (currentTool == Tool.textEditing) {
                currentTool = Pen.currentPen;
                for (final page in coreInfo.pages) {
                  page.quill.controller.moveCursorToPosition(
                    page.quill.controller.selection.extentOffset,
                  );
                  page.quill.focusNode.unfocus();
                }
              } else {
                currentTool = Tool.textEditing;
                quillFocus.value = coreInfo.pages[currentPageIndex].quill
                  ..focusNode.requestFocus();
              }
            }),
            pickPhoto: _pickPhotos,
            pickShape: _insertShapeFromLibrary,
            paste: paste,
            copySelection: _copySelection,
            pasteSelection: _pasteSelection,
            cropPossible: _cropPossible,
            cropActive: _cropActive,
            toggleCrop: _toggleCrop,
            bringToFront: _bringSelectionToFront,
            sendToBack: _sendSelectionToBack,
            smoothen: _smoothenSelection,
            addToElements: _addToElements,
            openElementsSheet: _openElementsSheet,
            onRevealAllTape: _revealAllTapeOnCurrentPage,
            onConcealAllTape: _concealAllTapeOnCurrentPage,
            onClearPage: () => clearPage(currentPageIndex),
          )
        : Toolbar(
            readOnly: coreInfo.readOnly,
            setTool: (tool) {
              if (tool is Eraser && currentTool is Eraser) {
                tool = _lastNonEraserTool;
              }
              currentTool = tool;
              if (tool is Highlighter) {
                Highlighter.currentHighlighter = tool;
              } else if (tool is Pencil) {
                Pencil.currentPencil = tool;
              } else if (Pen.isWritingPen(tool)) {
                Pen.currentPen = tool as Pen;
              }
              if (mounted) setState(() {});
            },
            currentTool: currentTool,
            duplicateSelection: _duplicateSelection,
            deleteSelection: () {
              final select = currentTool as Select;
              if (!select.doneSelecting) return;
              final page = coreInfo.pages[select.selectResult.pageIndex];
              setState(() => _deleteSelection(select, page));
            },
            setColor: (color) {
              setState(() {
                updateColorBar(color);
                if (currentTool is Highlighter) {
                  (currentTool as Highlighter).color = color.withAlpha(
                    Highlighter.alpha,
                  );
                } else if (currentTool is Pen) {
                  (currentTool as Pen).color = color;
                } else if (currentTool is Select) {
                  _setSelectionColor(color);
                }
              });
            },
            quillFocus: quillFocus,
            textEditing: currentTool == Tool.textEditing,
            toggleTextEditing: () => setState(() {
              if (currentTool == Tool.textEditing) {
                currentTool = Pen.currentPen;
                for (final page in coreInfo.pages) {
                  page.quill.controller.moveCursorToPosition(
                    page.quill.controller.selection.extentOffset,
                  );
                  page.quill.focusNode.unfocus();
                }
              } else {
                currentTool = Tool.textEditing;
                quillFocus.value = coreInfo.pages[currentPageIndex].quill
                  ..focusNode.requestFocus();
              }
            }),
            undo: undo,
            isUndoPossible: history.canUndo,
            redo: redo,
            isRedoPossible: history.canRedo,
            toggleFingerDrawing: () {
              stows.editorFingerDrawing.value =
                  !stows.editorFingerDrawing.value;
              lastSeenPointerCount = 0;
            },
            pickPhoto: _pickPhotos,
            pickShape: _insertShapeFromLibrary,
            paste: paste,
            copySelection: _copySelection,
            pasteSelection: _pasteSelection,
            cropPossible: _cropPossible,
            cropActive: _cropActive,
            toggleCrop: _toggleCrop,
            bringToFront: _bringSelectionToFront,
            sendToBack: _sendSelectionToBack,
            smoothen: _smoothenSelection,
            addToElements: _addToElements,
            openElementsSheet: _openElementsSheet,
            exportAsSba: exportAsSba,
            exportAsPdf: exportAsPdf,
            exportAsPng: exportAsPng,
            onRevealAllTape: _revealAllTapeOnCurrentPage,
            onConcealAllTape: _concealAllTapeOnCurrentPage,
          );

    final Widget toolbar = Collapsible(
      axis: isToolbarVertical
          ? CollapsibleAxis.horizontal
          : CollapsibleAxis.vertical,
      collapsed:
          DynamicMaterialApp.isFullscreen &&
          !stows.editorToolbarShowInFullscreen.value,
      maintainState: true,
      child: SafeArea(
        bottom: stows.editorToolbarAlignment.value != AxisDirection.up,
        child: toolbarContent,
      ),
    );

    final Widget body;
    if (isToolbarVertical) {
      body = Row(
        textDirection: stows.editorToolbarAlignment.value == AxisDirection.left
            ? .ltr
            : .rtl,
        children: [
          toolbar,
          Expanded(
            child: Column(
              children: [
                Expanded(child: canvas),
                readonlyBanner,
              ],
            ),
          ),
        ],
      );
    } else {
      body = Column(
        verticalDirection:
            stows.editorToolbarAlignment.value == AxisDirection.up
            ? VerticalDirection.up
            : VerticalDirection.down,
        children: [
          Expanded(child: canvas),
          toolbar,
          readonlyBanner,
        ],
      );
    }

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isCompact = screenWidth < 500;
    final bool isVeryCompact = screenWidth < 400;

    return ValueListenableBuilder(
      valueListenable: savingState,
      builder: (context, savingState, child) {
        // don't allow user to go back until saving is done
        return PopScope(
          canPop: savingState == .saved,
          onPopInvokedWithResult: (didPop, _) {
            switch (savingState) {
              case .waitingToSave:
                assert(!didPop);
                saveToFile(); // trigger save now
                snackBarNeedsToSaveBeforeExiting();
              case .saving:
                assert(!didPop);
                snackBarNeedsToSaveBeforeExiting();
              case .saved:
                break;
            }
          },
          child: child!,
        );
      },
      child: Scaffold(
        backgroundColor: stows.goodnotesUiMode.value
            ? (Theme.brightnessOf(context) == Brightness.dark
                  ? const Color(0xFF161618)
                  : const Color(0xFFF3F2EE))
            : null,
        appBar: DynamicMaterialApp.isFullscreen
            ? null
            : stows.goodnotesUiMode.value
            ? GoodnotesHeaderBar(
                filePath: coreInfo.filePath,
                customTitle: widget.customTitle,
                filenameTextEditingController: filenameTextEditingController,
                filenameFormKey: _filenameFormKey,
                renameFile: renameFile,
                validateFilename: _validateFilenameTextField,
                needsNaming: needsNaming,
                savingState: savingState,
                triggerSave: saveToFile,
                onBack: () => Navigator.of(context).maybePop(),
                onOpenThumbnails: () {
                  showDialog(
                    context: context,
                    builder: (context) => pageManager(context),
                  );
                },
                currentPageIndex: currentPageIdx,
                totalPages: coreInfo.pages.length,
                isInfiniteCanvas: coreInfo.isInfiniteCanvas,
                isBookmarked: currentPageBookmarked,
                onToggleBookmark: () => setState(() {
                  if (coreInfo.readOnly) return;
                  final pageIdx = currentPageIndex;
                  if (pageIdx >= coreInfo.pages.length) return;
                  final page = coreInfo.pages[pageIdx];
                  page.bookmarked = !page.bookmarked;
                  page.redrawStrokes();
                  autosaveAfterDelay();
                }),
                onInsertPage: () => setState(() {
                  final currentPageIndex = this.currentPageIndex;
                  insertPageAfter(currentPageIndex);
                  CanvasGestureDetector.scrollToPage(
                    pageIndex: currentPageIndex + 1,
                    pages: coreInfo.pages,
                    screenWidth: MediaQuery.sizeOf(context).width,
                    transformationController: _transformationController,
                  );
                }),
                undo: undo,
                canUndo: !coreInfo.readOnly && history.canUndo,
                redo: redo,
                canRedo: !coreInfo.readOnly && history.canRedo,
                onExport: () => _showExportDialog(context),
                isHandScrollMode: _isHandScrollOnlyMode,
                onToggleHandScrollMode: () => setState(() {
                  _isHandScrollOnlyMode = !_isHandScrollOnlyMode;
                }),
                onOpenMenu: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => bottomSheet(context),
                    isScrollControlled: true,
                    showDragHandle: true,
                    backgroundColor: colorScheme.surface,
                    constraints: const BoxConstraints(maxWidth: 500),
                  );
                },
                readOnly: coreInfo.readOnly,
              )
            : AppBar(
                toolbarHeight: kToolbarHeight,
                leadingWidth: isCompact ? 44.0 : null,
                titleSpacing: isCompact
                    ? 6.0
                    : NavigationToolbar.kMiddleSpacing,
                title: widget.customTitle != null
                    ? Text(widget.customTitle!)
                    : Form(
                        key: _filenameFormKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          controller: filenameTextEditingController,
                          onChanged: renameFile,
                          autofocus: needsNaming,
                          validator: _validateFilenameTextField,
                        ),
                      ),
                leading: SaveIndicator(
                  savingState: savingState,
                  triggerSave: saveToFile,
                ),
                actions: [
                  // Undo & Redo (Goodnotes 6 Navigation Bar controls)
                  IconButton(
                    visualDensity: isCompact ? VisualDensity.compact : null,
                    padding: isCompact
                        ? const EdgeInsets.symmetric(horizontal: 4)
                        : null,
                    icon: const AdaptiveIcon(
                      icon: Icons.undo,
                      cupertinoIcon: CupertinoIcons.arrow_uturn_left,
                    ),
                    tooltip: t.editor.toolbar.undo,
                    onPressed: (!coreInfo.readOnly && history.canUndo)
                        ? undo
                        : null,
                  ),
                  IconButton(
                    visualDensity: isCompact ? VisualDensity.compact : null,
                    padding: isCompact
                        ? const EdgeInsets.symmetric(horizontal: 4)
                        : null,
                    icon: const AdaptiveIcon(
                      icon: Icons.redo,
                      cupertinoIcon: CupertinoIcons.arrow_uturn_right,
                    ),
                    tooltip: t.editor.toolbar.redo,
                    onPressed: (!coreInfo.readOnly && history.canRedo)
                        ? redo
                        : null,
                  ),
                  SizedBox(width: isCompact ? 2 : 4),

                  // Goodnotes Document Hub & Page Pill: Page X / Y ⭐
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isCompact ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.65,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.4,
                          ),
                          width: 0.75,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: t.editor.pages,
                            child: InkWell(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(16),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => pageManager(context),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 6 : 8,
                                  vertical: isCompact ? 4 : 6,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (coreInfo.isInfiniteCanvas) ...[
                                      Icon(
                                        Icons.all_inclusive_rounded,
                                        size: isCompact ? 13 : 15,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      SizedBox(width: isCompact ? 3 : 5),
                                      Text(
                                        'Infinite',
                                        style: TextStyle(
                                          fontSize: isCompact ? 11.5 : 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ] else ...[
                                      Icon(
                                        Icons.grid_view_rounded,
                                        size: isCompact ? 13 : 15,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      SizedBox(width: isCompact ? 3 : 5),
                                      Text(
                                        '${currentPageIdx + 1} / ${coreInfo.pages.length}',
                                        style: TextStyle(
                                          fontSize: isCompact ? 11.5 : 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: isCompact ? 12 : 16,
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          Tooltip(
                            message: currentPageBookmarked
                                ? t.editor.bookmark.remove
                                : t.editor.bookmark.add,
                            child: InkResponse(
                              radius: 16,
                              onTap: () => setState(() {
                                if (coreInfo.readOnly) return;
                                final pageIdx = currentPageIndex;
                                if (pageIdx >= coreInfo.pages.length) return;
                                final page = coreInfo.pages[pageIdx];
                                page.bookmarked = !page.bookmarked;
                                page.redrawStrokes();
                                autosaveAfterDelay();
                              }),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isCompact ? 5 : 7,
                                  vertical: isCompact ? 4 : 6,
                                ),
                                child: Icon(
                                  currentPageBookmarked
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: isCompact ? 14 : 16,
                                  color: currentPageBookmarked
                                      ? Colors.amber.shade700
                                      : colorScheme.onSurfaceVariant.withValues(
                                          alpha: 0.6,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Add Page
                  if (!isVeryCompact)
                    IconButton(
                      visualDensity: isCompact ? VisualDensity.compact : null,
                      padding: isCompact
                          ? const EdgeInsets.symmetric(horizontal: 4)
                          : null,
                      icon: const AdaptiveIcon(
                        icon: Icons.add,
                        cupertinoIcon: CupertinoIcons.add,
                      ),
                      tooltip: t.editor.menu.insertPage,
                      onPressed: () => setState(() {
                        final currentPageIndex = this.currentPageIndex;
                        insertPageAfter(currentPageIndex);
                        CanvasGestureDetector.scrollToPage(
                          pageIndex: currentPageIndex + 1,
                          pages: coreInfo.pages,
                          screenWidth: MediaQuery.sizeOf(context).width,
                          transformationController: _transformationController,
                        );
                      }),
                    ),

                  // Share / Export
                  if (screenWidth >= 450)
                    IconButton(
                      visualDensity: isCompact ? VisualDensity.compact : null,
                      padding: isCompact
                          ? const EdgeInsets.symmetric(horizontal: 4)
                          : null,
                      icon: const AdaptiveIcon(
                        icon: Icons.ios_share,
                        cupertinoIcon: CupertinoIcons.share,
                      ),
                      tooltip: t.editor.toolbar.export,
                      onPressed: () => _showExportDialog(context),
                    ),

                  // More (...) menu
                  IconButton(
                    visualDensity: isCompact ? VisualDensity.compact : null,
                    padding: isCompact
                        ? const EdgeInsets.symmetric(horizontal: 4)
                        : null,
                    icon: const AdaptiveIcon(
                      icon: Icons.more_vert,
                      cupertinoIcon: CupertinoIcons.ellipsis_vertical,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => bottomSheet(context),
                        isScrollControlled: true,
                        showDragHandle: true,
                        backgroundColor: colorScheme.surface,
                        constraints: const BoxConstraints(maxWidth: 500),
                      );
                    },
                  ),
                ],
              ),
        body: body,
        floatingActionButton:
            (DynamicMaterialApp.isFullscreen &&
                !stows.editorToolbarShowInFullscreen.value)
            ? FloatingActionButton(
                shape: platform.isCupertino ? const CircleBorder() : null,
                onPressed: () {
                  DynamicMaterialApp.setFullscreen(false, updateSystem: true);
                },
                child: const Icon(Icons.fullscreen_exit),
              )
            : null,
      ),
    );
  }

  void snackBarNeedsToSaveBeforeExiting() {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.editor.needsToSaveBeforeExiting)));
  }

  void _showExportDialog(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.ios_share, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    t.editor.toolbar.export,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ExportBar(
                axis: Axis.horizontal,
                toggleExportBar: () => Navigator.of(context).pop(),
                exportAsSba: exportAsSba,
                exportAsPdf: exportAsPdf,
                exportAsPng: exportAsPng,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSheet(BuildContext context) {
    final Brightness brightness = Theme.brightnessOf(context);
    final invert = stows.editorAutoInvert.value && brightness == .dark;
    final int currentPageIndex = this.currentPageIndex;

    return EditorBottomSheet(
      invert: invert,
      coreInfo: coreInfo,
      currentPageIndex: currentPageIndex,
      setBackgroundPattern: (pattern) => setState(() {
        if (coreInfo.readOnly) return;
        final previous = coreInfo.backgroundPattern;
        coreInfo.backgroundPattern = pattern;
        stows.lastBackgroundPattern.value = pattern;
        history.recordChange(
          EditorHistoryItem(
            type: .backgroundPattern,
            pageIndex: currentPageIndex,
            backgroundPatternChange: Change(
              previous: previous,
              current: pattern,
            ),
            strokes: [],
            images: [],
          ),
        );
        autosaveAfterDelay();
      }),
      setLineHeight: (lineHeight) => setState(() {
        if (coreInfo.readOnly) return;
        coreInfo.lineHeight = lineHeight;
        stows.lastLineHeight.value = lineHeight;
        autosaveAfterDelay();
      }),
      setLineThickness: (lineThickness) => setState(() {
        if (coreInfo.readOnly) return;
        coreInfo.lineThickness = lineThickness;
        stows.lastLineThickness.value = lineThickness;
        autosaveAfterDelay();
      }),
      setPageSize: (Size newSize) => setState(() {
        if (coreInfo.readOnly) return;
        if (currentPageIndex >= coreInfo.pages.length) return;
        final page = coreInfo.pages[currentPageIndex];
        page.size = newSize;
        page.redrawStrokes();
        autosaveAfterDelay();
      }),
      removeBackgroundImage: () => setState(() {
        if (coreInfo.readOnly) return;

        final page = coreInfo.pages[currentPageIndex];
        if (page.backgroundImage == null) return;
        page.images.add(page.backgroundImage!);
        page.backgroundImage = null;

        autosaveAfterDelay();
      }),
      redrawImage: () => setState(() {}),
      clearPage: () {
        clearPage(currentPageIndex);
      },
      clearAllPages: clearAllPages,
      redrawAndSave: () => setState(() {
        if (coreInfo.readOnly) return;
        autosaveAfterDelay();
      }),
      pickPhotos: _pickPhotos,
      importPdf: importPdf,
      canRasterPdf: Editor.canRasterPdf,
      addStickyNote: _addStickyNote,
      addSticker: _addSticker,
      getIsWatchingServer: () => _watchServerTimer?.isActive ?? false,
      setIsWatchingServer: (bool watch) {
        if (watch) {
          _watchServerTimer ??= Timer.periodic(
            const Duration(seconds: 5),
            (_) => _refreshCurrentNote(),
          );
          if (coreInfo.readOnlyReason != .watchingServer) {
            assert(coreInfo.readOnlyReason == null);
            coreInfo.readOnlyReason = .watchingServer;
            if (mounted) setState(() {});
          }
        } else {
          _watchServerTimer?.cancel();
          _watchServerTimer = null;
          if (coreInfo.readOnlyReason == .watchingServer) {
            coreInfo.readOnlyReason = null;
            if (mounted) setState(() {});
          }
        }
      },
      onOpenPresentation: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PresentationMode(
              coreInfo: coreInfo,
              initialPageIndex: currentPageIndex,
            ),
            fullscreenDialog: true,
          ),
        );
      },
      onOpenFlashcards: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PresentationMode(
              coreInfo: coreInfo,
              initialPageIndex: currentPageIndex,
              mode: DisplayMode.flashcard,
            ),
            fullscreenDialog: true,
          ),
        );
      },
      onExport: () => _showExportDialog(context),
    );
  }

  Widget pageBuilder(BuildContext context, int pageIndex) {
    final page = coreInfo.pages[pageIndex];
    final currentStroke = Pen.currentStroke?.pageIndex == pageIndex
        ? Pen.currentStroke
        : null;
    final isSelect = currentTool is Select;
    final select = isSelect ? currentTool as Select : null;
    final isCurrentPageSelected = select?.selectResult.pageIndex == pageIndex;

    return Canvas(
      path: coreInfo.filePath,
      page: page,
      pageIndex: pageIndex,
      textEditing: currentTool == Tool.textEditing,
      coreInfo: coreInfo,
      currentStroke: currentStroke,
      currentStrokeDetectedShape:
          currentTool is ShapePen && currentStroke != null
          ? ShapePen.detectedShape
          : null,
      currentSelection: isCurrentPageSelected ? select?.selectResult : null,
      isDoneSelecting:
          isCurrentPageSelected && (select?.doneSelecting ?? false),
      onCutSelection: isCurrentPageSelected ? _cutSelection : null,
      onCopySelection: isCurrentPageSelected ? _copySelection : null,
      onDuplicateSelection: isCurrentPageSelected ? _duplicateSelection : null,
      onDeleteSelection: isCurrentPageSelected
          ? () {
              if (select != null) _deleteSelection(select, page);
            }
          : null,
      onSetColor: isCurrentPageSelected ? _setSelectionColor : null,
      isResizeActive:
          isCurrentPageSelected && (select?.isResizeActive ?? false),
      onToggleResize: isCurrentPageSelected ? _toggleSelectionResize : null,
      onTakeScreenshot: isCurrentPageSelected ? _takeSelectionScreenshot : null,
      onAddToElements: isCurrentPageSelected ? _addToElements : null,
      onBringToFront: isCurrentPageSelected ? _bringSelectionToFront : null,
      onSendToBack: isCurrentPageSelected ? _sendSelectionToBack : null,
      onSmoothen: isCurrentPageSelected ? _smoothenSelection : null,
      cropPossible: isCurrentPageSelected && _cropPossible,
      cropActive: isCurrentPageSelected && _cropActive,
      onToggleCrop: isCurrentPageSelected ? _toggleCrop : null,
      setAsBackground: (EditorImage image) {
        if (page.backgroundImage != null) {
          // restore previous background image as normal image
          page.images.add(page.backgroundImage!);
        }
        page.images.remove(image);
        page.backgroundImage = image;

        CanvasImage.activeListener
            .notifyListenersPlease(); // un-select active image

        autosaveAfterDelay();
        setState(() {});
      },
      currentTool: currentTool,
      currentScale: _transformationController.value.approxScale,
    );
  }

  Widget pageManager(BuildContext context) {
    return PageGridOverviewDialog(
      coreInfo: coreInfo,
      currentPageIndex: currentPageIndex,
      scrollToPage: (int pageIndex) {
        CanvasGestureDetector.scrollToPage(
          pageIndex: pageIndex,
          pages: coreInfo.pages,
          screenWidth: MediaQuery.sizeOf(context).width,
          transformationController: _transformationController,
        );
      },
      redrawAndSave: () => setState(() {
        if (coreInfo.readOnly) return;
        autosaveAfterDelay();
      }),
      insertPageAfter: insertPageAfter,
      duplicatePage: duplicatePage,
      clearPage: clearPage,
      deletePage: deletePage,
    );
  }

  void duplicatePage(int pageIndex) {
    if (coreInfo.readOnly) return;
    if (pageIndex < 0 || pageIndex >= coreInfo.pages.length) return;
    setState(() {
      final page = coreInfo.pages[pageIndex];
      final newLayers = page.layers
          .map(
            (layer) => Layer(
              name: layer.name,
              visible: layer.visible,
              strokes: layer.strokes
                  .map((stroke) => stroke.copy()..pageIndex = pageIndex + 1)
                  .toList(),
            ),
          )
          .toList();
      final newPage = page.copyWith(
        layers: newLayers,
        images: page.images
            .map((image) => image.copy()..pageIndex += 1)
            .toList(),
        quill: QuillStruct(
          controller: flutter_quill.QuillController(
            document: flutter_quill.Document.fromDelta(
              page.quill.controller.document.toDelta(),
            ),
            selection: const TextSelection.collapsed(offset: 0),
          ),
          focusNode: FocusNode(debugLabel: 'Quill Focus Node'),
        ),
        backgroundImage: page.backgroundImage?.copy()?..pageIndex += 1,
      );
      coreInfo.pages.insert(pageIndex + 1, newPage);
      listenToQuillChanges(newPage.quill, pageIndex + 1);
      history.recordChange(
        EditorHistoryItem(
          type: .insertPage,
          pageIndex: pageIndex + 1,
          strokes: const [],
          images: const [],
          page: newPage,
        ),
      );
      autosaveAfterDelay();
    });
  }

  void deletePage(int pageIndex) {
    if (coreInfo.readOnly) return;
    if (coreInfo.pages.length <= 1) return;
    if (pageIndex < 0 || pageIndex >= coreInfo.pages.length) return;
    setState(() {
      final page = coreInfo.pages.removeAt(pageIndex);
      createPage(pageIndex - 1);
      history.recordChange(
        EditorHistoryItem(
          type: .deletePage,
          pageIndex: pageIndex,
          strokes: const [],
          images: const [],
          page: page,
        ),
      );
      autosaveAfterDelay();
    });
  }

  void insertPageAfter(int pageIndex) => setState(() {
    if (coreInfo.readOnly) return;
    final page = EditorPage();
    coreInfo.pages.insert(pageIndex + 1, page);
    listenToQuillChanges(page.quill, pageIndex + 1);
    history.recordChange(
      EditorHistoryItem(
        type: .insertPage,
        pageIndex: pageIndex + 1,
        strokes: const [],
        images: const [],
        page: page,
      ),
    );
    autosaveAfterDelay();
  });

  void clearPage(int pageIndex) {
    if (coreInfo.readOnly) return;
    final page = coreInfo.pages[pageIndex];
    setState(() {
      final removedStrokes = page.strokes.toList();
      final removedImages = page.images.toList();
      for (final layer in page.layers) layer.strokes.clear();
      page.images.clear();
      removeExcessPages();
      history.recordChange(
        EditorHistoryItem(
          type: .erase,
          pageIndex: pageIndex,
          strokes: removedStrokes,
          images: removedImages,
        ),
      );
      autosaveAfterDelay();
    });
  }

  void clearAllPages() {
    if (coreInfo.readOnly) return;
    setState(() {
      final removedStrokes = <Stroke>[];
      final removedImages = <EditorImage>[];
      for (final page in coreInfo.pages) {
        removedStrokes.addAll(page.strokes);
        removedImages.addAll(page.images);
        for (final layer in page.layers) layer.strokes.clear();
        page.images.clear();
      }
      removeExcessPages();
      history.recordChange(
        EditorHistoryItem(
          type: .erase,
          pageIndex: 0,
          strokes: removedStrokes,
          images: removedImages,
        ),
      );
    });
    autosaveAfterDelay();
  }

  Future<void> showVersionTooNewDialog() async {
    final disableReadOnly =
        await showDialog(
          context: context,
          builder: (context) => AdaptiveAlertDialog(
            title: Text(t.editor.versionTooNew.title),
            content: Text(t.editor.versionTooNew.subtitle),
            actions: [
              CupertinoDialogAction(
                child: Text(t.common.cancel),
                onPressed: () => Navigator.pop(context, false),
              ),
              CupertinoDialogAction(
                child: Text(t.editor.versionTooNew.allowEditing),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted) return;
    if (!disableReadOnly) return;

    if (coreInfo.readOnlyReason == .versionTooNew) {
      coreInfo.readOnlyReason = null;
      if (mounted) setState(() {});
    }
  }

  late int _lastCurrentPageIndex = coreInfo.initialPageIndex ?? 0;

  /// The index of the page that is currently centered on screen.
  int get currentPageIndex {
    if (!mounted) return _lastCurrentPageIndex;

    final screenWidth = MediaQuery.sizeOf(context).width;

    return _lastCurrentPageIndex = getPageIndexFromScrollPosition(
      scrollY: -scrollY,
      screenWidth: screenWidth,
      pages: coreInfo.pages,
    );
  }

  @visibleForTesting
  static int getPageIndexFromScrollPosition({
    required double scrollY,
    required double screenWidth,
    required List<EditorPage> pages,
  }) {
    for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
      final bottomOfPage = CanvasGestureDetector.getTopOfPage(
        pageIndex: pageIndex + 1, // top of next page
        pages: pages,
        screenWidth: screenWidth,
      );

      if (scrollY < bottomOfPage) {
        return pageIndex;
      }
    }
    // below the last page
    return pages.length - 1;
  }

  @override
  void dispose() {
    unawaited(_cleanUpAsync());

    DynamicMaterialApp.removeFullscreenListener(_setState);

    _delayedSaveTimer?.cancel();
    _watchServerTimer?.cancel();
    _lastSeenPointerCountTimer?.cancel();

    _removeKeybindings();

    // manually save pen properties since the listeners don't fire if a property is changed
    stows.lastFountainPenOptions.notifyListeners();
    stows.lastBallpointPenOptions.notifyListeners();
    stows.lastHighlighterOptions.notifyListeners();
    stows.lastPencilOptions.notifyListeners();
    stows.lastShapePenOptions.notifyListeners();

    super.dispose();
  }

  Future<void> _cleanUpAsync() async {
    try {
      if (_renameTimer?.isActive ?? false) {
        _renameTimer!.cancel();
        await _renameFileNow();
        filenameTextEditingController.dispose();
      }
      await saveToFile();
    } finally {
      coreInfo.dispose();
    }
  }
}
