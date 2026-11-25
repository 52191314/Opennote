/// 🤖 Generated wholely or partially with Google Antigravity
part of '../_canvas_painter.dart';

typedef _PageIndicatorCacheKey = (
  int pageIndex,
  int totalPages,
  bool bookmarked,
  bool invert,
  double width,
  String? fontFamily,
);

final Map<_PageIndicatorCacheKey, ui.Paragraph> _pageIndicatorCache = {};
const _pageIndicatorCacheMaxEntries = 64;

extension _CursorPainter on CanvasPainter {
  void _drawPenPreview(Canvas canvas) {
    final pos = page.penPreviewPosition;
    final radius = page.penPreviewRadius;
    final color = page.penPreviewColor;
    if (pos == null || radius == null || color == null || radius <= 0) return;

    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawEraserCursor(Canvas canvas) {
    final position = page.eraserCursorPosition;
    final radius = page.eraserCursorRadius;
    if (position == null || radius == null || radius <= 0) return;

    canvas.drawCircle(
      position,
      radius,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      position,
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawLaserSpotlight(Canvas canvas) {
    final position = page.laserSpotlightPosition;
    if (position == null) return;

    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = Colors.red.withValues(alpha: 0.25);
    canvas.drawCircle(position, 28, paint);

    paint.color = Colors.red.withValues(alpha: 0.45);
    canvas.drawCircle(position, 16, paint);

    paint.color = Colors.red;
    canvas.drawCircle(position, 7, paint);

    paint.color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(position, 2.5, paint);
  }

  void _drawPageIndicator(Canvas canvas, Size pageSize) {
    if (!showPageIndicator) return;

    final layoutWidth =
        pageSize.width - 2 * CanvasPainter._pageIndicatorPadding;
    final cacheKey = (
      pageIndex,
      totalPages,
      page.bookmarked,
      invert,
      layoutWidth,
      defaultTextStyle.fontFamily,
    );

    var paragraph = _pageIndicatorCache[cacheKey];
    if (paragraph == null) {
      if (_pageIndicatorCache.length >= _pageIndicatorCacheMaxEntries) {
        final oldestKey = _pageIndicatorCache.keys.first;
        final evicted = _pageIndicatorCache.remove(oldestKey);
        if (evicted != null) {
          try {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => evicted.dispose(),
            );
          } on FlutterError {
            evicted.dispose();
          }
        }
      }
      final style = ui.ParagraphStyle(
        textAlign: .end,
        textDirection: .ltr,
        maxLines: 1,
      );
      final builder = ui.ParagraphBuilder(style)
        ..pushStyle(
          ui.TextStyle(
            color: Colors.black.withInversion(invert).withValues(alpha: 0.5),
            fontSize: CanvasPainter._pageIndicatorFontSize,
            fontFamily: defaultTextStyle.fontFamily,
            fontFamilyFallback: defaultTextStyle.fontFamilyFallback,
          ),
        )
        ..addText(
          '${page.bookmarked ? '★ ' : ''}${pageIndex + 1} / $totalPages',
        );

      paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: layoutWidth));
      _pageIndicatorCache[cacheKey] = paragraph;
    }

    canvas.drawParagraph(
      paragraph,
      Offset(
        CanvasPainter._pageIndicatorPadding,
        pageSize.height -
            CanvasPainter._pageIndicatorPadding -
            CanvasPainter._pageIndicatorFontSize * 1.2,
      ),
    );
  }
}
