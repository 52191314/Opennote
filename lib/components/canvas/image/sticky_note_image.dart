part of 'editor_image.dart';

/// 🤖 Generated with DeepSeek v4 Flash
///
/// A sticky note (post-it note) image that displays colored text
/// inside a colored rectangle on the canvas.
class StickyNoteImage extends EditorImage {
  /// The background color of the sticky note (e.g. yellow, pink, green, blue).
  Color color;

  /// The text content displayed on the sticky note.
  String text;

  /// The font size of the text on the sticky note.
  double fontSize;

  StickyNoteImage({
    required super.id,
    required super.assetCache,
    required this.color,
    required this.text,
    this.fontSize = 14,
    required super.pageIndex,
    required super.pageSize,
    super.invertible,
    super.backgroundFit,
    required super.onMoveImage,
    required super.onDeleteImage,
    required super.onMiscChange,
    super.onLoad,
    super.newImage,
    super.dstRect,
    super.srcRect,
    super.naturalSize,
    super.isThumbnail,
  }) : super(extension: '.sticky');

  factory StickyNoteImage.fromJson(
    Map<String, dynamic> json, {
    required List<Uint8List>? inlineAssets,
    bool isThumbnail = false,
    required String sbnPath,
    required AssetCache assetCache,
  }) {
    return StickyNoteImage(
      id: json['id'] ?? -1,
      assetCache: assetCache,
      color: Color(json['c'] as int),
      text: json['t'] as String? ?? '',
      fontSize: (json['fs'] as num?)?.toDouble() ?? 14,
      pageIndex: json['i'] ?? 0,
      pageSize: .infinite,
      invertible: json['v'] ?? true,
      backgroundFit: json['f'] != null ? .values[json['f']] : .contain,
      onMoveImage: null,
      onDeleteImage: null,
      onMiscChange: null,
      onLoad: null,
      newImage: false,
      dstRect: .fromLTWH(
        json['x'] ?? 20,
        json['y'] ?? 20,
        json['w'] ?? 200,
        json['h'] ?? 200,
      ),
      srcRect: .fromLTWH(
        json['sx'] ?? 0,
        json['sy'] ?? 0,
        json['sw'] ?? 200,
        json['sh'] ?? 200,
      ),
      naturalSize: Size(json['nw'] ?? 200, json['nh'] ?? 200),
      isThumbnail: isThumbnail,
    );
  }

  @override
  Map<String, dynamic> toJson(OrderedAssetCache assets) =>
      super.toJson(assets)
        ..addAll({
          'c': color.toARGB32(),
          't': text,
          'fs': fontSize,
        });

  @override
  Future<void> firstLoad() async {
    if (naturalSize == Size.zero) {
      naturalSize = const Size(200, 200);
    }
    if (srcRect == Rect.zero || srcRect.size == Size.zero) {
      srcRect = Offset.zero & naturalSize;
    }
    if (dstRect == Rect.zero || dstRect.size == Size.zero) {
      dstRect = const Rect.fromLTWH(20, 20, 200, 200);
    }
  }

  @override
  Future<void> loadIn() async => await super.loadIn();

  @override
  Future<bool> loadOut() async => await super.loadOut();

  @override
  Future<void> precache(BuildContext context) async {
    // Sticky notes have no external assets to precache.
  }

  @override
  Widget buildImageWidget({
    required BuildContext context,
    required BoxFit? overrideBoxFit,
    required bool isBackground,
    required bool invert,
  }) {
    return InvertWidget(
      invert: invert,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.black87,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  @override
  StickyNoteImage copy() => StickyNoteImage(
    id: id,
    assetCache: assetCache,
    color: color,
    text: text,
    fontSize: fontSize,
    pageIndex: pageIndex,
    pageSize: .infinite,
    invertible: invertible,
    backgroundFit: backgroundFit,
    onMoveImage: onMoveImage,
    onDeleteImage: onDeleteImage,
    onMiscChange: onMiscChange,
    onLoad: onLoad,
    newImage: true,
    dstRect: dstRect,
    srcRect: srcRect,
    naturalSize: naturalSize,
    isThumbnail: isThumbnail,
  );
}
