/// 🤖 Generated wholely or partially with Claude Code; Gemini; Google Antigravity
/// Adapted for Saber from Flutter's [InteractiveViewer] class
/// https://github.com/flutter/flutter/blob/stable/packages/flutter/lib/src/widgets/interactive_viewer.dart
/// Using this commit (Flutter 3.44.0):
/// https://github.com/flutter/flutter/blob/86b97230b17c2fd37cf9e615f1f32650e1541d75/packages/flutter/lib/src/widgets/interactive_viewer.dart
library;

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in Flutter's LICENSE file.

// ignore_for_file: omit_obvious_property_types

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable, clampDouble;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:saber/components/canvas/interactive/canvas_matrix_math.dart';
import 'package:saber/components/canvas/interactive/canvas_scale_gesture_recognizer.dart';
import 'package:saber/data/extensions/matrix4_extensions.dart';
import 'package:saber/data/tools/palm_rejection.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Quad, Vector3;

export 'interactive/canvas_scale_gesture_recognizer.dart';

part 'interactive/interactive_canvas_gestures.dart';

typedef InteractiveCanvasViewerWidgetBuilder =
    Widget Function(BuildContext context, Quad viewport);

@immutable
class InteractiveCanvasViewer extends StatefulWidget {
  /// Create an InteractiveCanvasViewer.
  InteractiveCanvasViewer({
    super.key,
    this.clipBehavior = Clip.hardEdge,
    this.panAxis = PanAxis.free,
    this.boundaryMargin = .zero,
    this.constrained = true,
    this.maxScale = 2.5,
    this.minScale = 0.8,
    this.palmEngine,
    this.isDrawGesture,
    this.interactionEndFrictionCoefficient = kDrag,
    this.onInteractionStart,
    this.onInteractionEnd,
    this.constrainMatrix,
    this.shouldRebuildBuilder,
    this.onDrawEnd,
    this.onDrawStart,
    this.onDrawUpdate,
    this.panEnabled = true,
    this.scaleEnabled = true,
    this.scaleFactor = kDefaultMouseScrollToScaleFactor,
    this.transformationController,
    this.alignment,
    this.trackpadScrollCausesScale = false,
    required Widget this.child,
  }) : assert(minScale > 0),
       assert(interactionEndFrictionCoefficient > 0),
       assert(minScale.isFinite),
       assert(maxScale > 0),
       assert(!maxScale.isNaN),
       assert(maxScale >= minScale),
       assert(
         (boundaryMargin.horizontal.isInfinite &&
                 boundaryMargin.vertical.isInfinite) ||
             (boundaryMargin.top.isFinite &&
                 boundaryMargin.right.isFinite &&
                 boundaryMargin.bottom.isFinite &&
                 boundaryMargin.left.isFinite),
       ),
       builder = null;

  /// Creates an InteractiveCanvasViewer for a child that is created on demand.
  InteractiveCanvasViewer.builder({
    super.key,
    this.clipBehavior = Clip.hardEdge,
    this.panAxis = PanAxis.free,
    this.boundaryMargin = .zero,
    this.maxScale = 2.5,
    this.minScale = 0.8,
    this.palmEngine,
    this.isDrawGesture,
    this.interactionEndFrictionCoefficient = kDrag,
    this.onInteractionStart,
    this.onInteractionEnd,
    this.constrainMatrix,
    this.shouldRebuildBuilder,
    this.onDrawEnd,
    this.onDrawStart,
    this.onDrawUpdate,
    this.panEnabled = true,
    this.scaleEnabled = true,
    this.scaleFactor = 200.0,
    this.transformationController,
    this.alignment,
    this.trackpadScrollCausesScale = false,
    required InteractiveCanvasViewerWidgetBuilder this.builder,
  }) : assert(minScale > 0),
       assert(interactionEndFrictionCoefficient > 0),
       assert(minScale.isFinite),
       assert(maxScale > 0),
       assert(!maxScale.isNaN),
       assert(maxScale >= minScale),
       assert(
         (boundaryMargin.horizontal.isInfinite &&
                 boundaryMargin.vertical.isInfinite) ||
             (boundaryMargin.top.isFinite &&
                 boundaryMargin.right.isFinite &&
                 boundaryMargin.bottom.isFinite &&
                 boundaryMargin.left.isFinite),
       ),
       constrained = false,
       child = null;

  /// The alignment of the child's origin, relative to the size of the box.
  final Alignment? alignment;

  /// If set to [Clip.none], the child may extend beyond the size of the viewer.
  final Clip clipBehavior;

  /// Controls which axes panning is allowed on.
  final PanAxis panAxis;

  /// A margin for the visible boundaries of the child.
  final EdgeInsets boundaryMargin;

  /// Builds the child of this widget on demand for [InteractiveCanvasViewer.builder].
  final InteractiveCanvasViewerWidgetBuilder? builder;

  /// The child [Widget] transformed by this viewer.
  final Widget? child;

  /// Whether the normal size constraints at this point in the widget tree are applied to the child.
  final bool constrained;

  /// If false, the user will be prevented from panning.
  final bool panEnabled;

  /// If false, the user will be prevented from scaling.
  final bool scaleEnabled;

  /// {@macro flutter.gestures.scale.trackpadScrollCausesScale}
  final bool trackpadScrollCausesScale;

  /// Determines the amount of scale to be performed per pointer scroll.
  final double scaleFactor;

  /// The maximum allowed scale.
  final double maxScale;

  /// The minimum allowed scale.
  final double minScale;

  /// Changes the deceleration behavior after a gesture.
  final double interactionEndFrictionCoefficient;

  /// Called when the user ends a draw gesture on the widget.
  final GestureScaleEndCallback? onDrawEnd;

  /// Called when the user begins a draw gesture on the widget.
  final GestureScaleStartCallback? onDrawStart;

  /// Called when the user updates a draw gesture on the widget.
  final GestureScaleUpdateCallback? onDrawUpdate;

  /// Palm rejection filter engine for filtering wrist and hand contacts.
  final PalmRejectionEngine? palmEngine;

  /// A function to distinguish a draw gesture and a pan/zoom gesture.
  final bool Function(ScaleStartDetails scaleDetails)? isDrawGesture;

  /// Called when any gesture starts.
  final GestureScaleStartCallback? onInteractionStart;

  /// Called when any gesture ends.
  final GestureScaleEndCallback? onInteractionEnd;

  /// Optional matrix constraint applied before committing gesture updates to
  /// [transformationController].
  final Matrix4 Function(Matrix4 nextMatrix)? constrainMatrix;

  /// Optional predicate deciding whether [builder] must be re-invoked when the
  /// transformation matrix changes from `oldMatrix` to `newMatrix`.
  final bool Function(Matrix4 oldMatrix, Matrix4 newMatrix, Size viewportSize)?
  shouldRebuildBuilder;

  /// A [TransformationController] for the transformation performed on the child.
  final TransformationController? transformationController;

  // Used as the coefficient of friction in the inertial translation animation.
  // This value was eyeballed to give a feel similar to Google Photos.
  static const double kDrag = 0.0000135;

  /// Returns the closest point to the given point on the given line segment.
  @visibleForTesting
  static Vector3 getNearestPointOnLine(Vector3 point, Vector3 l1, Vector3 l2) =>
      canvasGetNearestPointOnLine(point, l1, l2);

  /// Given a quad, return its axis aligned bounding box.
  @visibleForTesting
  static Quad getAxisAlignedBoundingBox(Quad quad) =>
      canvasGetAxisAlignedBoundingBox(quad);

  /// Returns true iff the point is inside the rectangle given by the Quad, inclusively.
  @visibleForTesting
  static bool pointIsInside(Vector3 point, Quad quad) =>
      canvasPointIsInside(point, quad);

  /// Get the point inside (inclusively) the given Quad that is nearest to the given Vector3.
  @visibleForTesting
  static Vector3 getNearestPointInside(Vector3 point, Quad quad) =>
      canvasGetNearestPointInside(point, quad);

  @override
  State<InteractiveCanvasViewer> createState() =>
      _InteractiveCanvasViewerState();
}

class _InteractiveCanvasViewerState extends State<InteractiveCanvasViewer>
    with TickerProviderStateMixin {
  late TransformationController _transformer =
      widget.transformationController ?? TransformationController();

  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _parentKey = GlobalKey();
  Animation<Offset>? _animation;
  late AnimationController _controller;
  Axis? _currentAxis; // Used with panAxis.
  Offset? _referenceFocalPoint; // Point where the current gesture began.
  double? _scaleStart; // Scale value at start of scaling gesture.
  double? _rotationStart = 0; // Rotation at start of rotation gesture.
  double _currentRotation = 0; // Rotation of _transformationController.value.
  _GestureType? _gestureType;

  // -TODO(justinmc): Add rotateEnabled parameter to the widget and remove this
  // hardcoded value when the rotation feature is implemented.
  // https://github.com/flutter/flutter/issues/57698
  final bool _rotateEnabled = false;

  bool isCurrentGestureADrawGesture = false;
  Matrix4? _lastBuilderMatrix;
  Size? _lastViewportSize;
  Widget? _cachedBuiltChild;

  // The _boundaryRect is calculated by adding the boundaryMargin to the size of
  // the child.
  Rect get _boundaryRect {
    assert(_childKey.currentContext != null);
    assert(!widget.boundaryMargin.left.isNaN);
    assert(!widget.boundaryMargin.right.isNaN);
    assert(!widget.boundaryMargin.top.isNaN);
    assert(!widget.boundaryMargin.bottom.isNaN);

    final RenderBox childRenderBox =
        _childKey.currentContext!.findRenderObject()! as RenderBox;
    final Size childSize = childRenderBox.size;
    final Rect boundaryRect = widget.boundaryMargin.inflateRect(
      Offset.zero & childSize,
    );
    assert(
      !boundaryRect.isEmpty,
      "InteractiveCanvasViewer's child must have nonzero dimensions.",
    );
    assert(
      boundaryRect.isFinite ||
          (boundaryRect.left.isInfinite &&
              boundaryRect.top.isInfinite &&
              boundaryRect.right.isInfinite &&
              boundaryRect.bottom.isInfinite),
      'boundaryRect must either be infinite in all directions or finite in all directions.',
    );
    return boundaryRect;
  }

  // The Rect representing the child's parent.
  Rect get _viewport {
    assert(_parentKey.currentContext != null);
    final RenderBox parentRenderBox =
        _parentKey.currentContext!.findRenderObject()! as RenderBox;
    return Offset.zero & parentRenderBox.size;
  }

  void _handleTransformation() {
    if (widget.builder == null) return;
    if (widget.shouldRebuildBuilder != null &&
        _lastBuilderMatrix != null &&
        _lastViewportSize != null &&
        _cachedBuiltChild != null &&
        !widget.shouldRebuildBuilder!(
          _lastBuilderMatrix!,
          _transformer.value,
          _lastViewportSize!,
        )) {
      return;
    }
    _cachedBuiltChild = null;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _transformer.addListener(_handleTransformation);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedBuiltChild = null;
  }

  @override
  void didUpdateWidget(InteractiveCanvasViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _cachedBuiltChild = null;

    final TransformationController? newController =
        widget.transformationController;
    if (newController == oldWidget.transformationController) {
      return;
    }
    _transformer.removeListener(_handleTransformation);
    if (oldWidget.transformationController == null) {
      _transformer.dispose();
    }
    _transformer = newController ?? TransformationController();
    _transformer.addListener(_handleTransformation);
  }

  @override
  void dispose() {
    _controller.dispose();
    _transformer.removeListener(_handleTransformation);
    if (widget.transformationController == null) {
      _transformer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.child != null) {
      child = _InteractiveCanvasViewerBuilt(
        childKey: _childKey,
        clipBehavior: widget.clipBehavior,
        constrained: widget.constrained,
        transformationListenable: _transformer,
        alignment: widget.alignment,
        child: widget.child!,
      );
    } else {
      assert(widget.builder != null);
      assert(!widget.constrained);
      child = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.biggest != _lastViewportSize ||
              _cachedBuiltChild == null) {
            final Matrix4 matrix = _transformer.value;
            _lastViewportSize = constraints.biggest;
            _lastBuilderMatrix = matrix.clone();
            _cachedBuiltChild = widget.builder!(
              context,
              canvasTransformViewport(
                matrix,
                Offset.zero & constraints.biggest,
              ),
            );
          }
          return _InteractiveCanvasViewerBuilt(
            childKey: _childKey,
            clipBehavior: widget.clipBehavior,
            constrained: widget.constrained,
            alignment: widget.alignment,
            transformationListenable: _transformer,
            child: _cachedBuiltChild!,
          );
        },
      );
    }

    return Listener(
      key: _parentKey,
      onPointerSignal: _receivedPointerSignal,
      child: RawGestureDetector(
        behavior: HitTestBehavior.opaque, // Necessary when panning off screen.
        gestures: <Type, GestureRecognizerFactory>{
          CanvasScaleGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                CanvasScaleGestureRecognizer
              >(
                () => CanvasScaleGestureRecognizer(
                  palmEngine: widget.palmEngine,
                  dragStartBehavior: DragStartBehavior.down,
                  trackpadScrollCausesScale: widget.trackpadScrollCausesScale,
                  trackpadScrollToScaleFactor: Offset(
                    0,
                    -1 / widget.scaleFactor,
                  ),
                ),
                (CanvasScaleGestureRecognizer instance) {
                  instance
                    ..palmEngine = widget.palmEngine
                    ..trackpadScrollCausesScale =
                        widget.trackpadScrollCausesScale
                    ..trackpadScrollToScaleFactor = Offset(
                      0,
                      -1 / widget.scaleFactor,
                    )
                    ..onStart = _onScaleStart
                    ..onUpdate = _onScaleUpdate
                    ..onEnd = _onScaleEnd;
                },
              ),
        },
        child: child,
      ),
    );
  }
}

// This widget allows us to easily swap in and out the LayoutBuilder in
// InteractiveCanvasViewer's depending on if it's using a builder or a child.
class _InteractiveCanvasViewerBuilt extends StatelessWidget {
  const _InteractiveCanvasViewerBuilt({
    required this.child,
    required this.childKey,
    required this.clipBehavior,
    required this.constrained,
    required this.transformationListenable,
    required this.alignment,
  });

  final Widget child;
  final GlobalKey childKey;
  final Clip clipBehavior;
  final bool constrained;
  final ValueListenable<Matrix4> transformationListenable;
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    Widget child = ValueListenableBuilder<Matrix4>(
      valueListenable: transformationListenable,
      builder: (BuildContext context, Matrix4 matrix, Widget? child) {
        return Transform(transform: matrix, alignment: alignment, child: child);
      },
      child: KeyedSubtree(key: childKey, child: this.child),
    );

    if (!constrained) {
      child = OverflowBox(
        alignment: .topLeft,
        minWidth: 0,
        minHeight: 0,
        // maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: child,
      );
    }

    return RepaintBoundary(
      child: ClipRect(clipBehavior: clipBehavior, child: child),
    );
  }
}

// A classification of relevant user gestures. Each contiguous user gesture is
// represented by exactly one _GestureType.
enum _GestureType { pan, scale, rotate }
