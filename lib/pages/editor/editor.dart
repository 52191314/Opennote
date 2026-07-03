/// 🤖 Modified with DeepSeek v4 Flash
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/canvas.dart';
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/components/canvas/canvas_image.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/components/canvas/save_indicator.dart';
import 'package:saber/components/editor/outline_overlay.dart';
import 'package:saber/components/editor/presentation_mode.dart';
import 'package:saber/components/editor/read_only_banner.dart';
import 'package:saber/components/theming/adaptive_alert_dialog.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/components/theming/dynamic_material_app.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/components/toolbar/color_bar.dart';
import 'package:saber/components/toolbar/editor_bottom_sheet.dart';
import 'package:saber/components/toolbar/editor_page_manager.dart';
import 'package:saber/components/toolbar/toolbar.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_exporter.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/change_notifier_extensions.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/nextcloud/saber_syncer.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/laser_pointer.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:saber/data/tools/scribble_detector.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/shape_pen.dart';
import 'package:saber/components/canvas/shape_library_dialog.dart';
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
  final ScribbleDetector scribbleDetector = ScribbleDetector();

  /// Strokes copied to the internal clipboard (for paste).
  List<Stroke>? _clipboardStrokes;

  /// Whether the user is currently rotating a selection.
  bool _isRotating = false;

  /// The timestamp and position of the last tap (for double-tap detection).
  DateTime? _lastTapTime;
  Offset? _lastTapPosition;

  /// Whether the user is currently resizing a selection.
  bool _isResizing = false;

  /// Index of the resize handle being dragged (0-7).
  int _resizeHandleIndex = -1;

  /// The initial bounds of the selection when resize started.
  Rect _resizeStartBounds = Rect.zero;

  /// The initial angle (in radians) when the rotation gesture started.
  double _initialRotationAngle = 0;

  /// Images copied to the internal clipboard (for paste).
  List<EditorImage>? _clipboardImages;

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
    while (pageIndex >= coreInfo.pages.length - 1) {
      final page = EditorPage();
      coreInfo.pages.add(page);
      listenToQuillChanges(page.quill, coreInfo.pages.length - 1);
    }
  }

  void removeExcessPages() {
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
            coreInfo.pages[stroke.pageIndex].strokes.remove(stroke);
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
    }
  }

  int? onWhichPageIsFocalPoint(Offset focalPoint) {
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
  bool isDrawGesture(ScaleStartDetails details) {
    if (coreInfo.readOnly) return false;

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
    history.canRedo = false;

    if (currentTool is Pen) {
      // Set pen preview
      final pen = currentTool as Pen;
      page.penPreviewPosition = position;
      page.penPreviewRadius = pen.options.size / 2;
      page.penPreviewColor = pen.color;

      if (stows.scribbleToErase.value) {
        scribbleDetector.start(position);
      }
      pen.onDragStart(
        position,
        page,
        dragPageIndex!,
        currentPressure,
      );
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
          _lastTapTime != null && _lastTapPosition != null) {
        final now = DateTime.now();
        final timeDelta = now.difference(_lastTapTime!).inMilliseconds;
        final posDelta = (position - _lastTapPosition!).distance;
        if (timeDelta < 300 && posDelta < 20) {
          select.unselect();
          page.selectionDeleteButtonRect = null;
          page.selectionRotationHandleCenter = null;
          page.selectionResizeHandles = null;
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

        // Check if tap is on a resize handle
        final resizeHandles = page.selectionResizeHandles;
        if (resizeHandles != null) {
          for (int i = 0; i < resizeHandles.length; i++) {
            if ((position - resizeHandles[i]).distance < 16) {
              _isResizing = true;
              _resizeHandleIndex = i;
              _resizeStartBounds = select.selectResult.path.getBounds();
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
        final erased = scribbleDetector.update(
          position,
          page.activeLayerStrokes,
          penStrokeWidth,
        );

        if (scribbleDetector.state == ScribbleState.erasing) {
          // In scribble-erase mode: erase overlapping strokes
          for (final stroke in erased) {
            page.removeStroke(stroke);
          }
          // Show eraser cursor with pen width
          page.eraserCursorPosition = position;
          page.eraserCursorRadius = penStrokeWidth / 2;
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
      if (_isResizing && select.doneSelecting) {
        // Compute scale factors based on handle drag
        // Handle indices: 0=topLeft, 1=topCenter, 2=topRight,
        //                3=middleRight, 4=bottomRight, 5=bottomCenter,
        //                6=bottomLeft, 7=middleLeft
        final bounds = _resizeStartBounds;
        final handleIdx = _resizeHandleIndex;

        // Determine pivot (opposite corner/edge)
        final pivot = switch (handleIdx) {
          0 => bounds.bottomRight,       // topLeft → pivot bottomRight
          1 => Offset(bounds.center.dx, bounds.bottom),  // topCenter → pivot bottomCenter
          2 => bounds.bottomLeft,        // topRight → pivot bottomLeft
          3 => Offset(bounds.left, bounds.center.dy),     // middleRight → pivot middleLeft
          4 => bounds.topLeft,           // bottomRight → pivot topLeft
          5 => Offset(bounds.center.dx, bounds.top),      // bottomCenter → pivot topCenter
          6 => bounds.topRight,          // bottomLeft → pivot topRight
          _ => Offset(bounds.right, bounds.center.dy),    // middleLeft → pivot middleRight
        };

        // Constrain to prevent flipping
        final newBounds = select.selectResult.path.getBounds();
        double scaleX, scaleY;

        switch (handleIdx) {
          case 0: // topLeft
            scaleX = (bounds.right - position.dx) / bounds.width;
            scaleY = (bounds.bottom - position.dy) / bounds.height;
          case 1: // topCenter
            scaleX = 1;
            scaleY = (bounds.bottom - position.dy) / bounds.height;
          case 2: // topRight
            scaleX = (position.dx - bounds.left) / bounds.width;
            scaleY = (bounds.bottom - position.dy) / bounds.height;
          case 3: // middleRight
            scaleX = (position.dx - bounds.left) / bounds.width;
            scaleY = 1;
          case 4: // bottomRight
            scaleX = (position.dx - bounds.left) / bounds.width;
            scaleY = (position.dy - bounds.top) / bounds.height;
          case 5: // bottomCenter
            scaleX = 1;
            scaleY = (position.dy - bounds.top) / bounds.height;
          case 6: // bottomLeft
            scaleX = (bounds.right - position.dx) / bounds.width;
            scaleY = (position.dy - bounds.top) / bounds.height;
          default: // middleLeft
            scaleX = (bounds.right - position.dx) / bounds.width;
            scaleY = 1;
        }

        // Prevent flipping (minimum 10% size)
        scaleX = scaleX.clamp(0.1, 10);
        scaleY = scaleY.clamp(0.1, 10);

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
        final newCenter = Offset(
          pivot.dx + (newBounds.center.dx - pivot.dx) * scaleX,
          pivot.dy + (newBounds.center.dy - pivot.dy) * scaleY,
        );
        select.selectResult.path = _scalePath(
          select.selectResult.path, scaleX, scaleY, pivot,
        );
        page.redrawStrokes();
      } else if (_isRotating && select.doneSelecting) {
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
          select.selectResult.path, deltaAngle, center,
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
    bool shouldSave = true;
    setState(() {
      if (currentTool is Pen) {
        if (scribbleDetector.state == ScribbleState.erasing) {
          final erased = scribbleDetector.end();
          // Discard the partial stroke that was started before scribble detection
          (currentTool as Pen).onDragEnd();
          page.eraserCursorPosition = null;
          page.eraserCursorRadius = null;
          if (erased.isNotEmpty) {
            history.recordChange(
              EditorHistoryItem(
                type: .erase,
                pageIndex: dragPageIndex!,
                strokes: erased,
                images: [],
              ),
            );
          } else {
            shouldSave = false;
          }
          return;
        }

        final newStroke = (currentTool as Pen).onDragEnd();
        if (newStroke == null) return;
        if (newStroke.isEmpty) return;

        if (stows.autoStraightenLines.value &&
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
        final textRect = page.computeTextContentRect(coreInfo.lineHeight);

        // Detect tap (no drag, no resize, no rotate)
        if (moveOffset == .zero && !_isRotating && !_isResizing) {
          if (!select.doneSelecting) {
            // A new selection that ended without dragging → try tap-to-select
            final bounds = select.selectResult.path.getBounds();
            if (bounds.isEmpty ||
                (bounds.width < 20 && bounds.height < 20)) {
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
              } else {
                final selectionBounds =
                    select.selectResult.path.getBounds();
                page.selectionDeleteButtonRect = Rect.fromCenter(
                  center:
                      Offset(selectionBounds.right, selectionBounds.top),
                  width: 24,
                  height: 24,
                );
                page.selectionRotationHandleCenter = Offset(
                  selectionBounds.center.dx,
                  selectionBounds.top - 30,
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

        if (select.doneSelecting) {
          history.recordChange(
            EditorHistoryItem(
              type: (_isRotating || _isResizing) ? .draw : .move,
              pageIndex: dragPageIndex!,
              strokes: select.selectResult.strokes,
              images: select.selectResult.images,
              offset: (_isRotating || _isResizing)
                  ? null
                  : .fromLTRB(
                    moveOffset.dx,
                    moveOffset.dy,
                    moveOffset.dx,
                    moveOffset.dy,
                  ),
            ),
          );
        } else {
          shouldSave = false;
          select.onDragEnd(page.strokes, page.images, textRect: textRect);

          if (select.selectResult.isEmpty) {
            Select.currentSelect.unselect();
            page.selectionDeleteButtonRect = null;
            page.selectionRotationHandleCenter = null;
            page.selectionResizeHandles = null;
          } else {
            // Compute delete button and rotation handle positions
            final bounds = select.selectResult.path.getBounds();
            page.selectionDeleteButtonRect = Rect.fromCenter(
              center: Offset(bounds.right, bounds.top),
              width: 24,
              height: 24,
            );
            page.selectionRotationHandleCenter = Offset(
              bounds.center.dx,
              bounds.top - 30,
            );
            final halfH = 8;
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
          }
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
    _resizeHandleIndex = -1;

    if (shouldSave) autosaveAfterDelay();
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
    autosaveAfterDelay();
  }

  void _addStickyNote() {
    if (coreInfo.readOnly) return;
    final currentPageIndex = this.currentPageIndex;

    // Use the Select tool so that the user can move the new image
    currentTool = Select.currentSelect;

    final image = StickyNoteImage(
      id: coreInfo.nextImageId++,
      assetCache: coreInfo.assetCache,
      color: const Color(0xFFFFF59D), // yellow default
      text: 'New Note',
      pageIndex: currentPageIndex,
      pageSize: coreInfo.pages[currentPageIndex].size,
      onMoveImage: onMoveImage,
      onDeleteImage: onDeleteImage,
      onMiscChange: autosaveAfterDelay,
      onLoad: () => setState(() {}),
      dstRect: Rect.fromLTWH(20, 20, 200, 200),
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
    autosaveAfterDelay();
  }

  void _addSticker(String emoji) {
    if (coreInfo.readOnly) return;
    final currentPageIndex = this.currentPageIndex;

    // Use the Select tool so that the user can move the new image
    currentTool = Select.currentSelect;

    const double size = 64;

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
      dstRect: Rect.fromLTWH(20, 20, size, size),
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

  void _deleteSelection(Select select, EditorPage page) {
    final strokes = select.selectResult.strokes;
    final images = select.selectResult.images;

    for (final stroke in strokes) {
      page.removeStroke(stroke);
    }
    for (final image in images) {
      page.images.remove(image);
    }

    page.selectionDeleteButtonRect = null;
    page.selectionResizeHandles = null;
    page.selectionRotationHandleCenter = null;
    select.unselect();

    history.recordChange(
      EditorHistoryItem(
        type: .erase,
        pageIndex: strokes.firstOrNull?.pageIndex ?? 0,
        strokes: strokes,
        images: images,
      ),
    );
    autosaveAfterDelay();
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

  static Path _scalePath(Path path, double scaleX, double scaleY, Offset pivot) {
    if (scaleX == 1 && scaleY == 1) return path;
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return path;

    final newPath = Path();
    for (final metric in metrics) {
      for (double dist = 0; dist < metric.length; dist += 5) {
        final tangent = metric.getTangentForOffset(dist);
        if (tangent == null) continue;
        final pos = tangent.position;
        final scaled = Offset(
          pivot.dx + (pos.dx - pivot.dx) * scaleX,
          pivot.dy + (pos.dy - pivot.dy) * scaleY,
        );
        if (dist == 0) {
          newPath.moveTo(scaled.dx, scaled.dy);
        } else {
          newPath.lineTo(scaled.dx, scaled.dy);
        }
      }
    }
    return newPath;
  }

  void _copySelection() {
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    setState(() {
      _clipboardStrokes = select.selectResult.strokes
          .map((stroke) => stroke.copy())
          .toList();
      _clipboardImages = select.selectResult.images
          .map((image) => image.copy())
          .toList();
    });
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
    if (_clipboardStrokes == null && _clipboardImages == null) return;
    if ((_clipboardStrokes?.isEmpty ?? true) &&
        (_clipboardImages?.isEmpty ?? true)) {
      return;
    }
    setState(() {
      final page = coreInfo.pages[dragPageIndex ?? currentPageIndex];
      const pasteOffset = Offset(30, -30);

      if (_clipboardStrokes != null) {
        for (final stroke in _clipboardStrokes!) {
          final pasted = stroke.copy()..shift(pasteOffset);
          pasted.pageIndex = page.strokes.firstOrNull?.pageIndex ?? 0;
          page.activeLayerStrokes.add(pasted);
        }
      }

      if (_clipboardImages != null) {
        for (final image in _clipboardImages!) {
          final pasted = image.copy()
            ..id = coreInfo.nextImageId++
            ..dstRect.shift(pasteOffset);
          page.images.add(pasted);
        }
      }

      history.recordChange(
        EditorHistoryItem(
          type: .draw,
          pageIndex: page.strokes.firstOrNull?.pageIndex ?? 0,
          strokes: _clipboardStrokes ?? [],
          images: _clipboardImages ?? [],
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
    final bool currentPageBookmarked = coreInfo.pages.isNotEmpty &&
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
        child: Toolbar(
          readOnly: coreInfo.readOnly,
          setTool: (tool) {
            if (tool is Eraser && currentTool is Eraser) {
              // setTool(Eraser) is a special case to toggle the eraser on/off
              tool = _lastNonEraserTool;
            }

            currentTool = tool;

            if (tool is Highlighter) {
              Highlighter.currentHighlighter = tool;
            } else if (tool is Pencil) {
              Pencil.currentPencil = tool;
            } else if (tool is Pen) {
              Pen.currentPen = tool;
            }

            if (mounted) setState(() {});
          },
          currentTool: currentTool,
          duplicateSelection: () {
            final select = currentTool as Select;
            if (!select.doneSelecting) return;

            setState(() {
              final page = coreInfo.pages[select.selectResult.pageIndex];
              final strokes = select.selectResult.strokes;
              final images = select.selectResult.images;

              const duplicationFeedbackOffset = Offset(25, -25);

              final duplicatedStrokes = strokes.map((stroke) {
                return stroke.copy()..shift(duplicationFeedbackOffset);
              }).toList();

              final duplicatedImages = images.map((image) {
                return image.copy()
                  ..id = coreInfo.nextImageId++
                  ..dstRect.shift(duplicationFeedbackOffset);
              }).toList();

              page.activeLayerStrokes.addAll(duplicatedStrokes);
              page.images.addAll(duplicatedImages);

              select.selectResult = select.selectResult.copyWith(
                strokes: duplicatedStrokes,
                images: duplicatedImages,
                path: select.selectResult.path.shift(duplicationFeedbackOffset),
              );

              history.recordChange(
                EditorHistoryItem(
                  type: .draw,
                  pageIndex: select.selectResult.pageIndex,
                  strokes: duplicatedStrokes,
                  images: duplicatedImages,
                ),
              );
              autosaveAfterDelay();
            });
          },
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
                // Changes color of selected strokes
                final select = currentTool as Select;
                if (select.doneSelecting) {
                  final strokes = select.selectResult.strokes;

                  final colorChange = <Stroke, Change<Color>>{};
                  for (final stroke in strokes) {
                    colorChange[stroke] = Change(
                      previous: stroke.color,
                      current: color,
                    );
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
                }
              }
            });
          },
          quillFocus: quillFocus,
          textEditing: currentTool == Tool.textEditing,
          toggleTextEditing: () => setState(() {
            if (currentTool == Tool.textEditing) {
              currentTool = Pen.currentPen;
              for (final page in coreInfo.pages) {
                // unselect text, but maintain cursor position
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
            stows.editorFingerDrawing.value = !stows.editorFingerDrawing.value;
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
          exportAsSba: exportAsSba,
          exportAsPdf: exportAsPdf,
          exportAsPng: exportAsPng,
        ),
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
        appBar: DynamicMaterialApp.isFullscreen
            ? null
            : AppBar(
                toolbarHeight: kToolbarHeight,
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
                  IconButton(
                    icon: const AdaptiveIcon(
                      icon: Icons.insert_page_break,
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
                  IconButton(
                    icon: const AdaptiveIcon(
                      icon: Icons.grid_view,
                      cupertinoIcon: CupertinoIcons.rectangle_grid_2x2,
                    ),
                    tooltip: t.editor.pages,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AdaptiveAlertDialog(
                          title: Text(t.editor.pages),
                          content: pageManager(context),
                          actions: const [],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const AdaptiveIcon(
                      icon: Icons.list,
                      cupertinoIcon: CupertinoIcons.list_bullet,
                    ),
                    tooltip: 'Outline',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AdaptiveAlertDialog(
                          title: const Text('Document Outline'),
                          content: DocumentOutlineView(
                            coreInfo: coreInfo,
                            transformationController:
                                _transformationController,
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: Text(t.common.cancel),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const AdaptiveIcon(
                      icon: Icons.present_to_all,
                      cupertinoIcon: CupertinoIcons.rectangle_on_rectangle,
                    ),
                    tooltip: 'Present',
                    onPressed: () {
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
                  ),
                  IconButton(
                    icon: const AdaptiveIcon(
                      icon: Icons.auto_stories,
                      cupertinoIcon: CupertinoIcons.book,
                    ),
                    tooltip: 'Flashcards',
                    onPressed: () {
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
                  ),
                  IconButton(
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
    );
  }

  Widget pageBuilder(BuildContext context, int pageIndex) {
    final page = coreInfo.pages[pageIndex];
    final currentStroke = Pen.currentStroke?.pageIndex == pageIndex
        ? Pen.currentStroke
        : null;
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
      currentSelection: () {
        if (currentTool is! Select) return null;
        final selectResult = (currentTool as Select).selectResult;
        if (selectResult.pageIndex != pageIndex) return null;
        return selectResult;
      }(),
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
    return EditorPageManager(
      coreInfo: coreInfo,
      currentPageIndex: currentPageIndex,
      redrawAndSave: () => setState(() {
        if (coreInfo.readOnly) return;
        autosaveAfterDelay();
      }),
      insertPageAfter: insertPageAfter,
      duplicatePage: (int pageIndex) => setState(() {
        if (coreInfo.readOnly) return;
        final page = coreInfo.pages[pageIndex];
        final newPage = page.copyWith(
          strokes: page.strokes
              .map((stroke) => stroke.copy()..pageIndex += 1)
              .toList(),
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
            pageIndex: pageIndex,
            strokes: const [],
            images: const [],
            page: newPage,
          ),
        );
        autosaveAfterDelay();
      }),
      clearPage: clearPage,
      deletePage: (int pageIndex) => setState(() {
        if (coreInfo.readOnly) return;
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
      }),
      transformationController: _transformationController,
    );
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
