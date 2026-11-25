/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Modified with Grok 4.7
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
part of '../page.dart';

/// Background configuration, text placement, and content-bounds members for [EditorPage].
mixin _EditorPageConfig {
  EditorPage get _page => this as EditorPage;

  /// The pattern to paint: this page's override, or [notebookPattern].
  CanvasBackgroundPattern paperPatternOr(
    CanvasBackgroundPattern notebookPattern,
  ) => _page.paperPattern ?? notebookPattern;

  /// The paper color to paint: this page's override, or [notebookColor].
  Color? paperColorOr(Color? notebookColor) =>
      _page.paperColor ?? notebookColor;

  /// Line spacing to use: this page's override, or [notebookLineHeight].
  int paperLineHeightOr(int notebookLineHeight) =>
      _page.paperLineHeight ?? notebookLineHeight;

  /// Line thickness to use: this page's override, or [notebookLineThickness].
  int paperLineThicknessOr(int notebookLineThickness) =>
      _page.paperLineThickness ?? notebookLineThickness;

  /// [EditorPage.textContentOffset], [EditorPage.textContentRotation],
  /// and [EditorPage.textContentScale] together.
  TextPlacement get textPlacement => (
    offset: _page.textContentOffset,
    rotation: _page.textContentRotation,
    scale: _page.textContentScale,
  );

  /// Updates [EditorPage.textContentOffset], [EditorPage.textContentRotation],
  /// and [EditorPage.textContentScale] together.
  set textPlacement(TextPlacement placement) {
    _page.textContentOffset = placement.offset;
    _page.textContentRotation = placement.rotation;
    _page.textContentScale = placement.scale;
  }

  /// Whether the page has no visible strokes, images, text, or background image.
  bool get isEmpty =>
      _page.strokes.isEmpty &&
      _page.images.isEmpty &&
      _page.quill.controller.document.isEmpty() &&
      _page.backgroundImage == null;

  /// Whether the page contains any visible content.
  bool get isNotEmpty => !isEmpty;

  /// Returns the bounding rect of the text content, computing it from
  /// [EditorPage.quill] document length and the given [lineHeight].
  Rect computeTextContentRect(double lineHeight) {
    if (_page.quill.controller.document.isEmpty()) return Rect.zero;

    final plainText = _page.quill.controller.document.toPlainText();
    if (plainText.trim().isEmpty) return Rect.zero;

    final lines = plainText.trimRight().split('\n').length;
    final estimatedHeight = lines * lineHeight * _page.textContentScale;
    final left = lineHeight * 0.5 * _page.textContentScale;
    final top = lineHeight * 1.2 * _page.textContentScale;
    return Rect.fromLTWH(
      left + _page.textContentOffset.dx,
      top + _page.textContentOffset.dy,
      (_page.size.width - lineHeight) * _page.textContentScale,
      estimatedHeight,
    );
  }

  /// The height of the canvas cropped to the content, clamped between
  /// 10% and 100% of [EditorPage.size] height.
  double previewHeight({required int lineHeight}) {
    assert(_page.size.height != 0);
    assert(_page.size.width != 0);
    if (_page.size.height == 0 || _page.size.width == 0) return 0;
    if (_page.backgroundImage != null) return _page.size.height;

    double maxY = 0;
    for (final stroke in _page.strokes) {
      maxY = max(maxY, stroke.maxY);
    }
    for (final image in _page.images) {
      maxY = max(maxY, image.dstRect.bottom);
    }
    if (!_page.quill.controller.document.isEmpty()) {
      final linesOfText = _page.quill.controller.document
          .toPlainText()
          .split('\n')
          .length;
      maxY = max(maxY, linesOfText * lineHeight * 1.5);
    }

    final fullHeight = _page.size.height;
    return min(fullHeight, max(maxY, 0) + (0.1 * fullHeight));
  }
}
