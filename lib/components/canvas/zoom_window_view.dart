/// 🤖 Generated wholely or partially with Grok 4.7
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/editor/zoom_window.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/i18n/strings.g.dart';

/// The on-page rectangle that marks the region [controller] magnifies.
class ZoomPageBox extends StatelessWidget {
  const ZoomPageBox({super.key, required this.controller});

  final ZoomWindowController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final box = controller.zoomBox;
        return Stack(
          children: [
            Positioned(
              key: ZoomWindowKeys.pageBox,
              left: box.left,
              top: box.top,
              width: box.width,
              height: box.height,
              child: _ZoomBoxChrome(controller: controller),
            ),
          ],
        );
      },
    );
  }
}

class _ZoomBoxChrome extends StatelessWidget {
  const _ZoomBoxChrome({required this.controller});

  final ZoomWindowController controller;

  @override
  Widget build(BuildContext context) {
    final color = ColorScheme.of(context).primary;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) => controller.moveZoomBoxBy(details.delta),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                border: Border.all(color: color, width: 1.5),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -10,
          height: 20,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) => controller.resizeHeight(details.delta.dy),
            child: const _HandleBar(),
          ),
        ),
        Positioned(
          right: -10,
          bottom: -10,
          width: 22,
          height: 22,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) => controller.resizeCorner(details.delta),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HandleBar extends StatelessWidget {
  const _HandleBar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 28,
        height: 4,
        decoration: BoxDecoration(
          color: ColorScheme.of(context).primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// The floating magnified view. Ink drawn here is stored on [page].
class ZoomWindowPanel extends StatefulWidget {
  const ZoomWindowPanel({
    super.key,
    required this.controller,
    required this.page,
    required this.pageIndex,
    required this.history,
    required this.pen,
    required this.onDismiss,
    this.onStrokeStarted,
    this.onStrokeCommitted,
  });

  final ZoomWindowController controller;
  final EditorPage page;
  final int pageIndex;
  final EditorHistory history;
  final Pen Function() pen;
  final VoidCallback onDismiss;
  final VoidCallback? onStrokeStarted;
  final VoidCallback? onStrokeCommitted;

  @override
  State<ZoomWindowPanel> createState() => _ZoomWindowPanelState();
}

class _ZoomWindowPanelState extends State<ZoomWindowPanel> {
  ZoomInk? _ink;

  Offset _windowPoint(Offset local) {
    return widget.controller.windowRect.topLeft + local;
  }

  void _start(DragStartDetails details) {
    final ink = ZoomInk(
      zoom: widget.controller,
      pen: widget.pen(),
      page: widget.page,
      pageIndex: widget.pageIndex,
      history: widget.history,
    );
    ink.begin(_windowPoint(details.localPosition));
    _ink = ink;
    widget.onStrokeStarted?.call();
    setState(() {});
  }

  void _update(DragUpdateDetails details) {
    _ink?.extend(_windowPoint(details.localPosition));
    setState(() {});
  }

  void _finish() {
    final stroke = _ink?.end();
    _ink = null;
    if (stroke != null) widget.onStrokeCommitted?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final rect = widget.controller.windowRect;
        final region = widget.controller.advanceRegion;
        final colorScheme = ColorScheme.of(context);

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              key: ZoomWindowKeys.window,
              left: rect.left,
              top: rect.top - ZoomWindowController.chromeHeight,
              width: rect.width,
              height: rect.height + ZoomWindowController.chromeHeight,
              child: Material(
                elevation: 8,
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _ZoomWindowChrome(
                      controller: widget.controller,
                      onDismiss: widget.onDismiss,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ZoomInkPainter(
                                page: widget.page,
                                zoomBox: widget.controller.zoomBox,
                                repaint: widget.page,
                              ),
                            ),
                          ),
                          if (region != null)
                            Positioned(
                              left: region.left - rect.left,
                              top: region.top - rect.top,
                              width: region.width,
                              height: region.height,
                              child: const IgnorePointer(
                                child: ColoredBox(
                                  key: ZoomWindowKeys.advanceRegion,
                                  color: Color(0x334C6FFF),
                                ),
                              ),
                            ),
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanStart: _start,
                              onPanUpdate: _update,
                              onPanEnd: (_) => _finish(),
                              onPanCancel: _finish,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ZoomWindowChrome extends StatelessWidget {
  const _ZoomWindowChrome({required this.controller, required this.onDismiss});

  final ZoomWindowController controller;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) => controller.moveWindowBy(details.delta),
      child: SizedBox(
        height: ZoomWindowController.chromeHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t.editor.zoomWindow.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: t.editor.zoomWindow.returnHeight,
                onPressed: () {
                  controller.returnHeight = math.max(
                    8,
                    controller.returnHeight - 4,
                  );
                },
                icon: const Icon(Icons.remove, size: 16),
              ),
              Text(
                controller.returnHeight.round().toString(),
                style: const TextStyle(fontSize: 12),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: t.editor.zoomWindow.returnHeight,
                onPressed: () =>
                    controller.returnHeight = controller.returnHeight + 4,
                icon: const Icon(Icons.add, size: 16),
              ),
              IconButton(
                key: ZoomWindowKeys.autoAdvance,
                visualDensity: VisualDensity.compact,
                tooltip: t.editor.zoomWindow.autoAdvance,
                isSelected: controller.autoAdvance,
                onPressed: () =>
                    controller.autoAdvance = !controller.autoAdvance,
                icon: Icon(
                  controller.autoAdvance
                      ? Icons.fast_forward
                      : Icons.fast_forward_outlined,
                  size: 18,
                  color: controller.autoAdvance ? colorScheme.primary : null,
                ),
              ),
              IconButton(
                key: ZoomWindowKeys.newLine,
                visualDensity: VisualDensity.compact,
                tooltip: t.editor.zoomWindow.newLine,
                onPressed: controller.newLine,
                icon: const Icon(Icons.keyboard_return, size: 18),
              ),
              IconButton(
                key: ZoomWindowKeys.dismiss,
                visualDensity: VisualDensity.compact,
                tooltip: t.editor.zoomWindow.dismiss,
                onPressed: onDismiss,
                icon: const Icon(Icons.close, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the zoom box and the zoom window while [open] is true.
class ZoomWindowLayer extends StatelessWidget {
  const ZoomWindowLayer({
    super.key,
    required this.open,
    required this.controller,
    required this.page,
    required this.pageIndex,
    required this.history,
    required this.pen,
    required this.onDismiss,
    this.onStrokeStarted,
    this.onStrokeCommitted,
  });

  final bool open;
  final ZoomWindowController controller;
  final EditorPage page;
  final int pageIndex;
  final EditorHistory history;
  final Pen Function() pen;
  final VoidCallback onDismiss;
  final VoidCallback? onStrokeStarted;
  final VoidCallback? onStrokeCommitted;

  @override
  Widget build(BuildContext context) {
    if (!open) return const SizedBox.expand();
    return Stack(
      children: [
        Positioned.fill(child: ZoomPageBox(controller: controller)),
        Positioned.fill(
          child: ZoomWindowPanel(
            controller: controller,
            page: page,
            pageIndex: pageIndex,
            history: history,
            pen: pen,
            onDismiss: onDismiss,
            onStrokeStarted: onStrokeStarted,
            onStrokeCommitted: onStrokeCommitted,
          ),
        ),
      ],
    );
  }
}

class _ZoomInkPainter extends CustomPainter {
  _ZoomInkPainter({
    required this.page,
    required this.zoomBox,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final EditorPage page;
  final Rect zoomBox;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFFDF8),
    );
    if (zoomBox.width == 0 || zoomBox.height == 0) return;

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(size.width / zoomBox.width, size.height / zoomBox.height);
    canvas.translate(-zoomBox.left, -zoomBox.top);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final stroke in page.strokes) {
      _draw(canvas, stroke, strokePaint);
    }
    final current = Pen.currentStroke;
    if (current != null) _draw(canvas, current, strokePaint);
    canvas.restore();
  }

  void _draw(Canvas canvas, Stroke stroke, Paint paint) {
    paint
      ..color = stroke.color
      ..strokeWidth = math.max(stroke.options.size, 1);
    canvas.drawPath(stroke.centerlinePath, paint);
  }

  @override
  bool shouldRepaint(covariant _ZoomInkPainter oldDelegate) {
    return oldDelegate.zoomBox != zoomBox || oldDelegate.page != page;
  }
}
