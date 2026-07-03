/// 🤖 Generated with DeepSeek v4 Flash
///
/// An image variant that renders a single emoji character as a sticker/stamp
/// on the canvas. It has no background decoration — just the emoji text.
part of 'editor_image.dart';

/// A canvas image that displays an emoji as a sticker.
///
/// Unlike [StickyNoteImage] which shows text inside a coloured rectangle,
/// a [StickerImage] renders only the emoji character with no background,
/// suitable for stamp-like decorations on the canvas.
class StickerImage extends EditorImage {
  /// The emoji character(s) to display.
  String emoji;

  /// The font size used to render the emoji.
  double fontSize;

  StickerImage({
    required super.id,
    required super.assetCache,
    required this.emoji,
    this.fontSize = 48,
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
  }) : super(extension: '.sticker');

  factory StickerImage.fromJson(
    Map<String, dynamic> json, {
    required List<Uint8List>? inlineAssets,
    bool isThumbnail = false,
    required String sbnPath,
    required AssetCache assetCache,
  }) {
    return StickerImage(
      id: json['id'] ?? -1,
      assetCache: assetCache,
      emoji: json['em'] as String? ?? '⭐',
      fontSize: (json['fs'] as num?)?.toDouble() ?? 48,
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
        json['w'] ?? 64,
        json['h'] ?? 64,
      ),
      srcRect: .fromLTWH(
        json['sx'] ?? 0,
        json['sy'] ?? 0,
        json['sw'] ?? 64,
        json['sh'] ?? 64,
      ),
      naturalSize: Size(json['nw'] ?? 64, json['nh'] ?? 64),
      isThumbnail: isThumbnail,
    );
  }

  @override
  Map<String, dynamic> toJson(OrderedAssetCache assets) =>
      super.toJson(assets)
        ..addAll({
          'em': emoji,
          'fs': fontSize,
        });

  @override
  Future<void> firstLoad() async {
    if (naturalSize == Size.zero) {
      naturalSize = const Size(64, 64);
    }
    if (srcRect == Rect.zero || srcRect.size == Size.zero) {
      srcRect = Offset.zero & naturalSize;
    }
    if (dstRect == Rect.zero || dstRect.size == Size.zero) {
      dstRect = const Rect.fromLTWH(20, 20, 64, 64);
    }
  }

  @override
  Future<void> loadIn() async => await super.loadIn();

  @override
  Future<bool> loadOut() async => await super.loadOut();

  @override
  Future<void> precache(BuildContext context) async {
    // Stickers have no external assets to precache.
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
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  StickerImage copy() => StickerImage(
    id: id,
    assetCache: assetCache,
    emoji: emoji,
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
