/// 🤖 Generated wholely or partially with Claude Code; Gemini; Google Antigravity
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
part of '../canvas_gesture_detector.dart';

class _PagesBuilder extends StatelessWidget {
  const _PagesBuilder({
    // ignore: unused_element_parameter
    super.key,
    required this.pages,
    required this.pageBuilder,
    required this.placeholderPageBuilder,
    required this.boundingBox,
    required this.containerWidth,
    this.isInfiniteCanvas = false,
  });

  final List<EditorPage> pages;
  final Widget Function(
    BuildContext context,
    int pageIndex, [
    Rect? viewportRect,
  ])
  pageBuilder;
  final Widget Function(BuildContext context, int pageIndex)
  placeholderPageBuilder;
  final Rect boundingBox;
  final double containerWidth;
  final bool isInfiniteCanvas;

  @override
  Widget build(BuildContext context) {
    if (isInfiniteCanvas) {
      if (pages.isEmpty) return const SizedBox.shrink();
      pages.first.isRendered = true;
      return pageBuilder(context, 0, boundingBox);
    }

    final List<Widget> children = [
      const SizedBox.square(dimension: Editor.gapBetweenPages),
      const SizedBox.square(dimension: Editor.gapBetweenPages),
    ];

    double topOfPage = Editor.gapBetweenPages * 2;
    for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
      final page = pages[pageIndex];
      final pageWidth = min(page.size.width, containerWidth);
      final pageHeight = pageWidth / page.size.width * page.size.height;
      final bottomOfPage = topOfPage + pageHeight;

      final isFocused = page.quill.focusNode.hasFocus;
      final isInViewport =
          boundingBox.bottom >= topOfPage && boundingBox.top <= bottomOfPage;
      final shouldRender = isFocused || isInViewport;

      page.isRendered = shouldRender;
      if (shouldRender) {
        final Rect? pageLocalViewport = !isInViewport
            ? Rect.zero
            : CanvasViewportProjection.computePageLocalViewport(
                pageSize: page.size,
                pageWidth: pageWidth,
                topOfPage: topOfPage,
                containerWidth: containerWidth,
                boundingBox: boundingBox,
              );
        children.add(pageBuilder(context, pageIndex, pageLocalViewport));
      } else {
        children.add(placeholderPageBuilder(context, pageIndex));
      }

      children.add(const SizedBox.square(dimension: Editor.gapBetweenPages));
      topOfPage = bottomOfPage + Editor.gapBetweenPages;
    }

    children.add(const SizedBox.square(dimension: Editor.gapBetweenPages));
    return Column(children: children);
  }
}
