/// 🤖 Generated wholely or partially with Claude Code; Gemini; Google Antigravity
/// 🤖 Modified with Grok 4.7
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saber/components/canvas/gesture_detector/canvas_transform_cache.dart';
import 'package:saber/components/canvas/gesture_detector/canvas_viewport_projection.dart';
import 'package:saber/components/canvas/gesture_detector/canvas_zoom_physics.dart';
import 'package:saber/components/canvas/hud/canvas_hud.dart';
import 'package:saber/components/canvas/hud/floating_layers_overlay.dart';
import 'package:saber/components/canvas/hud/protractor_overlay.dart';
import 'package:saber/components/canvas/interactive_canvas.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/change_notifier_extensions.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/shortcuts/mobile_keybinder.dart';
import 'package:saber/data/tools/palm_rejection.dart';
import 'package:saber/pages/editor/editor.dart';
import 'package:vector_math/vector_math_64.dart';

export 'gesture_detector/canvas_transform_cache.dart';
export 'gesture_detector/canvas_viewport_projection.dart';
export 'gesture_detector/canvas_zoom_physics.dart';

part 'gesture_detector/canvas_navigation_controls.dart';
part 'gesture_detector/canvas_pages_builder.dart';
part 'gesture_detector/canvas_pointer_handlers.dart';
part 'gesture_detector/canvas_transform_coordinator.dart';

/// Hosts the interactive canvas viewer, pointer routing, palm rejection,
/// keyboard navigation, and HUD overlays.
class CanvasGestureDetector extends StatefulWidget {
  CanvasGestureDetector({
    super.key,
    required this.filePath,
    required this.isDrawGesture,
    this.onInteractionEnd,
    required this.onDrawStart,
    required this.onDrawUpdate,
    required this.onDrawEnd,
    required this.updatePointerData,
    required this.onHovering,
    required this.onHoveringEnd,
    required this.onStylusButtonChanged,
    required this.undo,
    required this.redo,
    required this.pages,
    required this.initialPageIndex,
    this.explicitPageIndex,
    required this.pageBuilder,
    required this.placeholderPageBuilder,
    required this.isTextEditing,
    this.bookmarked = false,
    this.onToggleBookmarked,
    this.hasTape = false,
    this.onRevealAllTape,
    this.onConcealAllTape,
    this.activePage,
    this.onLayersChanged,
    this.isInfiniteCanvas = false,
    this.onFitContent,
    TransformationController? transformationController,
  }) : _ownsTransformationController = transformationController == null,
       _transformationController =
           transformationController ?? TransformationController();

  final String filePath;
  final bool Function(ScaleStartDetails scaleDetails) isDrawGesture;
  final ValueChanged<ScaleEndDetails>? onInteractionEnd;
  final ValueChanged<ScaleStartDetails> onDrawStart;
  final ValueChanged<ScaleUpdateDetails> onDrawUpdate;
  final ValueChanged<ScaleEndDetails> onDrawEnd;

  /// Called when the pressure of the stylus changes (normalized to `[0, 1]`).
  final void Function(PointerDeviceKind kind, double? pressure)
  updatePointerData;
  final VoidCallback onHovering;
  final VoidCallback onHoveringEnd;
  final ValueChanged<bool> onStylusButtonChanged;

  final VoidCallback undo;
  final VoidCallback redo;

  final List<EditorPage> pages;
  final int? initialPageIndex;

  /// Page requested by the route, such as an ink-search hit.
  ///
  /// When set, it is shown even if this note still has a cached scroll position.
  final int? explicitPageIndex;
  final Widget Function(
    BuildContext context,
    int pageIndex, [
    Rect? viewportRect,
  ])
  pageBuilder;
  final Widget Function(BuildContext context, int pageIndex)
  placeholderPageBuilder;

  final bool Function() isTextEditing;
  final bool bookmarked;
  final VoidCallback? onToggleBookmarked;
  final bool hasTape;
  final VoidCallback? onRevealAllTape;
  final VoidCallback? onConcealAllTape;
  final EditorPage? activePage;
  final VoidCallback? onLayersChanged;
  final bool isInfiniteCanvas;
  final VoidCallback? onFitContent;

  final bool _ownsTransformationController;
  late final TransformationController _transformationController;

  @override
  State<CanvasGestureDetector> createState() => CanvasGestureDetectorState();

  static const kMinScale = CanvasZoomPhysics.kMinScale;
  static const kInfiniteMinScale = CanvasZoomPhysics.kInfiniteMinScale;
  static const kPagedMinScale = CanvasZoomPhysics.kPagedMinScale;
  static const kMaxScale = CanvasZoomPhysics.kMaxScale;

  /// Returns the interactive minimum zoom scale for [isInfiniteCanvas].
  static double minScaleFor({required bool isInfiniteCanvas}) =>
      CanvasZoomPhysics.minScaleFor(isInfiniteCanvas: isInfiniteCanvas);

  /// Returns the vertical offset of the top of [pageIndex] in the paged column.
  static double getTopOfPage({
    required int pageIndex,
    required List<EditorPage> pages,
    required double screenWidth,
  }) => CanvasViewportProjection.getTopOfPage(
    pageIndex: pageIndex,
    pages: pages,
    screenWidth: screenWidth,
  );

  /// Scrolls [transformationController] to the top of [pageIndex].
  static void scrollToPage({
    required int pageIndex,
    required List<EditorPage> pages,
    required double screenWidth,
    required TransformationController transformationController,
  }) => CanvasViewportProjection.scrollToPage(
    pageIndex: pageIndex,
    pages: pages,
    screenWidth: screenWidth,
    transformationController: transformationController,
  );

  /// Returns the page index corresponding to [scrollY].
  static int getPageIndex({
    required double scrollY,
    required List<EditorPage> pages,
    required double screenWidth,
  }) => CanvasViewportProjection.getPageIndex(
    scrollY: scrollY,
    pages: pages,
    screenWidth: screenWidth,
  );
}

/// State backing [CanvasGestureDetector].
class CanvasGestureDetectorState extends State<CanvasGestureDetector> {
  late var containerBounds = const BoxConstraints();
  final _palmEngine = PalmRejectionEngine();

  /// If zooming is locked, this is the zoom level; otherwise `null`.
  late double? zoomLockedValue = stows.lastZoomLock.value
      ? widget._transformationController.value.maxScale2D
      : null;

  /// Whether single-finger panning is locked. Two-finger panning stays enabled.
  late bool singleFingerPanLock = stows.lastSingleFingerPanLock.value;

  /// Whether panning is locked to horizontal or vertical axes.
  late bool axisAlignedPanLock = stows.lastAxisAlignedPanLock.value;

  /// Whether the protractor overlay is visible.
  var showProtractor = false;

  final Map<AxisDirection, Timer> _arrowKeyPanTimers = {};
  var _setupKeybindings = false;
  late Keybinding _ctrlPlus, _ctrlEquals, _ctrlMinus;
  late Keybinding _leftKey, _rightKey, _upKey, _downKey;

  Timer? _snapZoomTimer;
  var _isGestureActive = false;
  var _needsHighZoomRefresh = false;
  var _isAdjustingTransform = false;

  final Map<int, Offset> _pointerPositions = {};

  /// Whether a touch or scale/pan gesture is currently in progress.
  bool get isGestureActive => _isGestureActive || _pointerPositions.isNotEmpty;
  DateTime? _multiPointerDownTime;
  var _maxPointerCountDuringGesture = 0;
  var _multiPointerMoved = false;
  var stylusButtonWasPressed = false;

  /// Computes a centered zoom matrix for [scaleDelta], or `null` when clamped.
  @visibleForTesting
  static Matrix4? setZoom({
    required double scaleDelta,
    required Matrix4 transformation,
    required BoxConstraints containerBounds,
    double minScale = CanvasGestureDetector.kMinScale,
  }) => CanvasZoomPhysics.computeZoomMatrix(
    scaleDelta: scaleDelta,
    transformation: transformation,
    containerBounds: containerBounds,
    minScale: minScale,
  );

  void _requestRebuild() => setState(() {});

  void _updateState(VoidCallback fn) => setState(fn);

  @override
  void initState() {
    setInitialTransform();
    widget._transformationController.addListener(onTransformChanged);
    _assignKeybindings();
    super.initState();
  }

  @override
  void didUpdateWidget(CanvasGestureDetector oldWidget) {
    if (oldWidget.initialPageIndex != widget.initialPageIndex ||
        oldWidget.explicitPageIndex != widget.explicitPageIndex ||
        oldWidget.filePath != widget.filePath) {
      setInitialTransform();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          onPointerDown: _listenerPointerEvent,
          onPointerMove: _listenerPointerEvent,
          onPointerUp: _listenerPointerUpEvent,
          onPointerCancel: _listenerPointerUpEvent,
          onPointerHover: _listenerPointerHoverEvent,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints containerBounds) =>
                _buildInteractiveViewer(containerBounds),
          ),
        ),
        if (showProtractor) const ProtractorOverlay(),
        _buildHudOverlay(),
        if (widget.activePage != null) _buildFloatingLayersOverlay(),
      ],
    );
  }

  @override
  void dispose() {
    _snapZoomTimer?.cancel();
    CanvasTransformCache.add(
      widget.filePath,
      widget._transformationController.value,
    );
    widget._transformationController.removeListener(onTransformChanged);
    if (widget._ownsTransformationController) {
      widget._transformationController.dispose();
    }
    _removeKeybindings();
    super.dispose();
  }
}
