/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Modified with Grok 4.7
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' show FragmentShader, Picture;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/components/canvas/inner_canvas.dart';
import 'package:saber/components/canvas/pencil_shader.dart';
import 'package:saber/data/editor/editor_exporter.dart';
import 'package:saber/data/tools/laser_pointer.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/has_size.dart';

part 'page/page_config.dart';
part 'page/page_models.dart';
part 'page/page_mutations.dart';
part 'page/page_serialization.dart';

/// Represents a single editable page inside a note, holding its layers,
/// images, rich text, paper configuration, and transient rendering caches.
class EditorPage extends ChangeNotifier
    with _EditorPageConfig, _EditorPageMutations
    implements HasSize {
  /// Default logical width of a new page.
  static const double defaultWidth = 1000;

  /// Default logical height of a new page.
  static const double defaultHeight = defaultWidth * 1.4;

  /// Default logical [Size] of a new page.
  static const defaultSize = Size(defaultWidth, defaultHeight);

  @override
  Size size;

  /// Global key for this page's [InnerCanvas].
  late final CanvasKey innerCanvasKey = CanvasKey();
  RenderBox? _renderBox;

  /// Cached [RenderBox] for this page's canvas, re-queried if detached.
  RenderBox? get renderBox {
    if (_renderBox != null && _renderBox!.attached) return _renderBox;

    final renderObject = innerCanvasKey.currentState?.context
        .findRenderObject();
    if (renderObject is RenderBox && renderObject.attached) {
      return _renderBox = renderObject;
    }
    _renderBox = null;
    return null;
  }

  /// Clears the cached [renderBox] so subsequent lookups re-query the render tree.
  void clearRenderBoxCache() {
    _renderBox = null;
  }

  var _isRendered = false;

  /// Whether this page is currently rendered in the active viewport.
  bool get isRendered => _isRendered;
  set isRendered(bool isRendered) {
    if (isRendered == _isRendered) return;
    _isRendered = isRendered;
    _renderBox = null;
  }

  /// Lazily initialized fragment shader for pencil strokes on this page.
  FragmentShader get pencilShader => _pencilShader ??= PencilShader.create();
  FragmentShader? _pencilShader;

  /// Ordered drawing layers on this page.
  final List<Layer> layers;

  /// Transient laser-pointer strokes currently fading on this page.
  final List<LaserStroke> laserStrokes;

  /// Foreground images placed on this page.
  final List<EditorImage> images;

  /// Rich-text controller and focus node for this page.
  final QuillStruct quill;

  /// Monotonically increasing version counter incremented whenever strokes or
  /// layers on this page are mutated or redrawn.
  var strokesVersion = 0;

  /// Cached display list for static highlighter strokes on this page.
  Picture? cachedHighlighterPicture;

  /// Cached display list for static non-highlighter strokes on this page.
  Picture? cachedNonHighlighterPicture;

  /// Cache key matching [cachedHighlighterPicture] and [cachedNonHighlighterPicture].
  StrokePictureCacheKey? strokePictureCacheKey;

  /// Index of the currently active layer for drawing operations.
  int activeLayerIndex;

  /// Optional position of the laser pointer spotlight dot (in page-local coordinates).
  Offset? laserSpotlightPosition;

  /// Position of the eraser cursor on this page (in page-local coordinates).
  Offset? eraserCursorPosition;

  /// Radius of the eraser cursor circle.
  double? eraserCursorRadius;

  /// Hit-test rect for the delete button on the selection bounding box.
  Rect? selectionDeleteButtonRect;

  /// Center of the rotation handle (above the selection bounding box).
  Offset? selectionRotationHandleCenter;

  /// Positions of the 8 resize handles around the selection bounding box.
  List<Offset>? selectionResizeHandles;

  /// Whether this page is bookmarked/favorited by the user.
  var bookmarked = false;

  /// Paper pattern drawn on this page. `null` uses the notebook's paper.
  CanvasBackgroundPattern? paperPattern;

  /// Paper color for this page. `null` uses the notebook's color.
  Color? paperColor;

  /// Line spacing for this page. `null` uses the notebook's line height.
  int? paperLineHeight;

  /// Line thickness for this page. `null` uses the notebook's line thickness.
  int? paperLineThickness;

  /// Offset applied to the text content from its default position.
  Offset textContentOffset = Offset.zero;

  /// Rotation angle (in radians) applied to the text content.
  double textContentRotation = 0;

  /// Scale factor applied to the text content (default `1.0`).
  var textContentScale = 1.0;

  /// Position for the pen preview circle (shown when hovering/ready to draw).
  Offset? penPreviewPosition;

  /// Radius of the pen preview circle (pen stroke width / 2).
  double? penPreviewRadius;

  /// Color of the pen preview circle.
  Color? penPreviewColor;

  /// Optional full-page background image (e.g. imported PDF page).
  EditorImage? backgroundImage;

  /// Creates an [EditorPage] with optional geometry, content, and paper settings.
  EditorPage({
    Size? size,
    double? width,
    double? height,
    List<Stroke>? strokes,
    List<Layer>? layers,
    List<EditorImage>? images,
    QuillStruct? quill,
    this.backgroundImage,
    this.activeLayerIndex = 0,
    this.bookmarked = false,
    this.paperPattern,
    this.paperColor,
    this.paperLineHeight,
    this.paperLineThickness,
    this.textContentOffset = Offset.zero,
    this.textContentRotation = 0,
    this.textContentScale = 1.0,
  }) : assert(
         (size == null) || (width == null && height == null),
         "size and width/height shouldn't both be specified",
       ),
       size = size ?? Size(width ?? defaultWidth, height ?? defaultHeight),
       layers =
           layers ??
           (strokes != null
               ? [Layer(name: 'Default', strokes: strokes)]
               : [Layer(name: 'Default')]),
       laserStrokes = [],
       images = images ?? [],
       quill =
           quill ??
           QuillStruct(
             controller: QuillController.basic(),
             focusNode: FocusNode(debugLabel: 'Quill Focus Node'),
           );

  /// Deserializes an [EditorPage] from JSON.
  factory EditorPage.fromJson(
    Map<String, dynamic> json, {
    required List<Uint8List>? inlineAssets,
    required bool readOnly,
    required int fileVersion,
    required String sbnPath,
    required AssetCache assetCache,
  }) => EditorPageSerialization.fromJson(
    json,
    inlineAssets: inlineAssets,
    readOnly: readOnly,
    fileVersion: fileVersion,
    sbnPath: sbnPath,
    assetCache: assetCache,
  );

  /// Serializes this page into a JSON map.
  Map<String, dynamic> toJson(OrderedAssetCache assets) =>
      EditorPageSerialization.toJson(this, assets);

  /// Triggers a redraw of the strokes.
  void redrawStrokes() {
    strokesVersion++;
    notifyListeners();
  }

  /// Deserializes a list of stroke JSON maps into [Stroke] instances.
  static List<Stroke> parseStrokesJson(
    List<dynamic>? strokes, {
    required HasSize page,
    required bool onlyFirstPage,
    required int fileVersion,
  }) => EditorPageSerialization.parseStrokesJson(
    strokes,
    page: page,
    onlyFirstPage: onlyFirstPage,
    fileVersion: fileVersion,
  );

  /// Deserializes a list of image JSON maps into [EditorImage] instances.
  static List<EditorImage> parseImagesJson(
    List<dynamic>? images, {
    required List<Uint8List>? inlineAssets,
    required bool isThumbnail,
    required bool onlyFirstPage,
    required String sbnPath,
    required AssetCache assetCache,
  }) => EditorPageSerialization.parseImagesJson(
    images,
    inlineAssets: inlineAssets,
    isThumbnail: isThumbnail,
    onlyFirstPage: onlyFirstPage,
    sbnPath: sbnPath,
    assetCache: assetCache,
  );

  /// Deserializes a single image JSON map into an [EditorImage].
  static EditorImage parseImageJson(
    Map<String, dynamic> json, {
    required List<Uint8List>? inlineAssets,
    required bool isThumbnail,
    required String sbnPath,
    required AssetCache assetCache,
  }) => EditorPageSerialization.parseImageJson(
    json,
    inlineAssets: inlineAssets,
    isThumbnail: isThumbnail,
    sbnPath: sbnPath,
    assetCache: assetCache,
  );

  @override
  void dispose() {
    invalidateStrokePictureCache(immediate: true);
    quill.dispose();
    _pencilShader?.dispose();
    isRendered = false;
    for (final image in images) {
      image.dispose();
    }
    backgroundImage?.dispose();
    super.dispose();
  }

  /// Disposes only the resources exclusive to a [cloneForRasterization] copy.
  void disposeClonedData() {
    invalidateStrokePictureCache(immediate: true);
    quill.dispose();
    _pencilShader?.dispose();
    isRendered = false;
    super.dispose();
  }
}
