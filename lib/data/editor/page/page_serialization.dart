/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Modified with Grok 4.7
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
part of '../page.dart';

/// Serialization and deserialization helpers for [EditorPage] and its assets.
abstract final class EditorPageSerialization {
  /// Deserializes an [EditorPage] from JSON, supporting both layered (`l`)
  /// and legacy flat-stroke (`s`) formats.
  static EditorPage fromJson(
    Map<String, dynamic> json, {
    required List<Uint8List>? inlineAssets,
    required bool readOnly,
    required int fileVersion,
    required String sbnPath,
    required AssetCache assetCache,
  }) {
    final size = Size(
      (json['w'] as num?)?.toDouble() ?? EditorPage.defaultWidth,
      (json['h'] as num?)?.toDouble() ?? EditorPage.defaultHeight,
    );
    final hasSize = HasSize(size);
    final paperPattern = json.containsKey('pp')
        ? CanvasBackgroundPattern.fromName(json['pp'] as String?)
        : null;
    final rawPaperColor = json['pc'];
    final paperColor = rawPaperColor is int ? Color(rawPaperColor) : null;

    final layersList = json['l'] as List?;
    final layers = layersList
        ?.map(
          (layerJson) => Layer.fromJson(
            layerJson as Map<String, dynamic>,
            fileVersion: fileVersion,
            pageIndex: 0,
            page: hasSize,
          ),
        )
        .toList();
    final strokes = layers == null
        ? parseStrokesJson(
            json['s'] as List?,
            page: hasSize,
            onlyFirstPage: false,
            fileVersion: fileVersion,
          )
        : null;

    return EditorPage(
      size: size,
      bookmarked: json['bm'] as bool? ?? false,
      paperPattern: paperPattern,
      paperColor: paperColor,
      paperLineHeight: (json['plh'] as num?)?.toInt(),
      paperLineThickness: (json['plt'] as num?)?.toInt(),
      textContentOffset: parseOffset(json['to']),
      textContentRotation: (json['tr'] as num?)?.toDouble() ?? 0,
      textContentScale: (json['ts'] as num?)?.toDouble() ?? 1.0,
      layers: layers,
      strokes: strokes,
      images: parseImagesJson(
        json['i'] as List?,
        inlineAssets: inlineAssets,
        isThumbnail: readOnly,
        onlyFirstPage: false,
        sbnPath: sbnPath,
        assetCache: assetCache,
      ),
      quill: QuillStruct(
        controller: json['q'] != null
            ? QuillController(
                document: Document.fromJson(json['q'] as List),
                selection: const TextSelection.collapsed(offset: 0),
              )
            : QuillController.basic(),
        focusNode: FocusNode(debugLabel: 'Quill Focus Node'),
      ),
      backgroundImage: json['b'] != null
          ? parseImageJson(
              json['b'],
              inlineAssets: inlineAssets,
              isThumbnail: false,
              sbnPath: sbnPath,
              assetCache: assetCache,
            )
          : null,
    );
  }

  /// Serializes [page] into a JSON map using [assets] for binary deduplication.
  static Map<String, dynamic> toJson(
    EditorPage page,
    OrderedAssetCache assets,
  ) => {
    'w': page.size.width,
    'h': page.size.height,
    if (page.bookmarked) 'bm': page.bookmarked,
    if (page.paperPattern != null) 'pp': page.paperPattern!.name,
    if (page.paperColor != null) 'pc': page.paperColor!.toARGB32(),
    if (page.paperLineHeight != null) 'plh': page.paperLineHeight,
    if (page.paperLineThickness != null) 'plt': page.paperLineThickness,
    if (page.textContentOffset != Offset.zero)
      'to': [page.textContentOffset.dx, page.textContentOffset.dy],
    if (page.textContentRotation != 0) 'tr': page.textContentRotation,
    if (page.textContentScale != 1.0) 'ts': page.textContentScale,
    if (page.layers.isNotEmpty)
      'l': page.layers.map((layer) => layer.toJson()).toList(),
    if (page.images.isNotEmpty)
      'i': page.images.map((image) => image.toJson(assets)).toList(),
    if (!page.quill.controller.document.isEmpty())
      'q': page.quill.controller.document.toDelta().toJson(),
    if (page.backgroundImage != null) 'b': page.backgroundImage?.toJson(assets),
  };

  /// Reads an offset saved as `[dx, dy]`, or [Offset.zero] if absent/invalid.
  static Offset parseOffset(Object? json) {
    if (json is! List || json.length != 2) return Offset.zero;
    return Offset((json[0] as num).toDouble(), (json[1] as num).toDouble());
  }

  /// Deserializes a list of stroke JSON maps into [Stroke] instances.
  static List<Stroke> parseStrokesJson(
    List<dynamic>? strokes, {
    required HasSize page,
    required bool onlyFirstPage,
    required int fileVersion,
  }) => (strokes ?? [])
      .map((dynamic stroke) {
        final map = stroke as Map<String, dynamic>;
        final pageIndex = map['i'] ?? 0;
        if (onlyFirstPage && pageIndex > 0) return null;
        return Stroke.fromJson(
          map,
          fileVersion: fileVersion,
          pageIndex: pageIndex,
          page: page,
        );
      })
      .where((element) => element != null)
      .cast<Stroke>()
      .toList();

  /// Deserializes a list of image JSON maps into [EditorImage] instances.
  static List<EditorImage> parseImagesJson(
    List<dynamic>? images, {
    required List<Uint8List>? inlineAssets,
    required bool isThumbnail,
    required bool onlyFirstPage,
    required String sbnPath,
    required AssetCache assetCache,
  }) =>
      images
          ?.cast<Map<String, dynamic>>()
          .map((Map<String, dynamic> image) {
            if (onlyFirstPage && image['i'] > 0) return null;
            return parseImageJson(
              image,
              inlineAssets: inlineAssets,
              isThumbnail: isThumbnail,
              sbnPath: sbnPath,
              assetCache: assetCache,
            );
          })
          .where((element) => element != null)
          .cast<EditorImage>()
          .toList() ??
      [];

  /// Deserializes a single image JSON map into an [EditorImage].
  static EditorImage parseImageJson(
    Map<String, dynamic> json, {
    required List<Uint8List>? inlineAssets,
    required bool isThumbnail,
    required String sbnPath,
    required AssetCache assetCache,
  }) => EditorImage.fromJson(
    json,
    inlineAssets: inlineAssets,
    isThumbnail: isThumbnail,
    sbnPath: sbnPath,
    assetCache: assetCache,
  );
}
