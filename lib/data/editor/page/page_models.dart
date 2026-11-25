/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Modified with Grok 4.7
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
part of '../page.dart';

/// Global key referencing an [InnerCanvas] state instance.
typedef CanvasKey = GlobalKey<State<InnerCanvas>>;

/// Where a page's text sits relative to its default position.
typedef TextPlacement = ({Offset offset, double rotation, double scale});

/// Key identifying the visual state of static committed strokes cached on [EditorPage].
typedef StrokePictureCacheKey = ({
  int strokesDigest,
  bool invert,
  int primaryColorValue,
  bool isLowQuality,
  int pencilShaderMask,
  int selectionIdentity,
  bool isInfiniteCanvas,
  Size canvasSize,
  Rect recordedCullRect,
});

/// A single layer within a page, containing a set of strokes.
///
/// Each page can have multiple layers that can be independently
/// hidden, reordered, and locked.
class Layer {
  /// Display name for this layer.
  String name;

  /// Whether strokes on this layer are rendered.
  bool visible;

  /// Whether strokes on this layer are protected from edits.
  bool locked;

  /// Strokes belonging to this layer.
  final List<Stroke> strokes;

  /// Creates a [Layer] with optional [name], visibility, lock state, and [strokes].
  Layer({
    this.name = 'Default',
    this.visible = true,
    this.locked = false,
    List<Stroke>? strokes,
  }) : strokes = strokes ?? [];

  /// Serializes this layer into a JSON map.
  Map<String, dynamic> toJson() => {
    'n': name,
    'v': visible,
    'l': locked,
    's': strokes.map((s) => s.toJson()).toList(),
  };

  /// Deserializes a [Layer] from a JSON map.
  factory Layer.fromJson(
    Map<String, dynamic> json, {
    required int fileVersion,
    required int pageIndex,
    required HasSize page,
  }) => Layer(
    name: json['n'] as String? ?? 'Default',
    visible: json['v'] as bool? ?? true,
    locked: json['l'] as bool? ?? false,
    strokes: EditorPageSerialization.parseStrokesJson(
      json['s'] as List?,
      page: page,
      onlyFirstPage: false,
      fileVersion: fileVersion,
    ),
  );
}

/// Bundles a [QuillController], its [FocusNode], and change subscription for a page.
class QuillStruct {
  /// Controller managing rich-text document edits.
  final QuillController controller;

  /// Focus node attached to the page's text editor.
  late final FocusNode focusNode;

  /// Optional subscription listening to document changes.
  StreamSubscription? changeSubscription;

  /// Creates a [QuillStruct] with the required [controller] and [focusNode].
  QuillStruct({required this.controller, required this.focusNode});

  /// Releases subscriptions, focus node, and controller resources.
  void dispose() {
    changeSubscription?.cancel();
    focusNode.dispose();
    controller.dispose();
  }

  /// Creates an isolated copy suitable for offscreen screenshot rasterization.
  QuillStruct cloneForScreenshot() => QuillStruct(
    controller: QuillController(
      document: Document.fromDelta(controller.document.toDelta()),
      selection: const TextSelection.collapsed(offset: 0),
    ),
    focusNode: FocusNode(debugLabel: 'Screenshot Quill Focus Node'),
  );
}
