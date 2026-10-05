/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';

import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';
import 'package:saber/components/canvas/_canvas_background_painter.dart';
import 'package:saber/components/canvas/_canvas_painter.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/canvas_image.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/components/canvas/lasso_callout_menu.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/quill_styles.dart';

class InnerCanvas extends StatefulWidget {
  const InnerCanvas({
    super.key,
    required this.pageIndex,
    this.redrawPageListenable,
    required this.width,
    required this.height,
    this.showPageIndicator = true,
    this.textEditing = false,
    required this.coreInfo,
    required this.currentStroke,
    required this.currentStrokeDetectedShape,
    required this.currentSelection,
    this.isDoneSelecting = false,
    this.onCutSelection,
    this.onCopySelection,
    this.onDuplicateSelection,
    this.onDeleteSelection,
    this.onSetColor,
    this.isResizeActive = false,
    this.onToggleResize,
    this.onTakeScreenshot,
    this.onAddToElements,
    this.onBringToFront,
    this.onSendToBack,
    this.onSmoothen,
    this.cropPossible = false,
    this.cropActive = false,
    this.onToggleCrop,
    this.setAsBackground,
    this.onRenderObjectChange,
    required this.currentToolIsSelect,
    required this.currentScale,
  });

  final int pageIndex;
  final Listenable? redrawPageListenable;
  final double width;
  final double height;
  final bool showPageIndicator;
  final bool textEditing;
  final EditorCoreInfo coreInfo;
  final Stroke? currentStroke;
  final RecognizedUnistroke? currentStrokeDetectedShape;
  final SelectResult? currentSelection;
  final bool isDoneSelecting;
  final VoidCallback? onCutSelection;
  final VoidCallback? onCopySelection;
  final VoidCallback? onDuplicateSelection;
  final VoidCallback? onDeleteSelection;
  final void Function(Color color)? onSetColor;
  final bool isResizeActive;
  final VoidCallback? onToggleResize;
  final VoidCallback? onTakeScreenshot;
  final VoidCallback? onAddToElements;
  final VoidCallback? onBringToFront;
  final VoidCallback? onSendToBack;
  final VoidCallback? onSmoothen;
  final bool cropPossible;
  final bool cropActive;
  final VoidCallback? onToggleCrop;
  final void Function(EditorImage image)? setAsBackground;
  final ValueChanged<RenderObject>? onRenderObjectChange;

  final bool currentToolIsSelect;

  final double currentScale;

  static const defaultBackgroundColor = Color(0xFFFCFCFC);

  @override
  State<InnerCanvas> createState() => _InnerCanvasState();
}

class _InnerCanvasState extends State<InnerCanvas> {
  @override
  void initState() {
    super.initState();
    widget.redrawPageListenable?.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.redrawPageListenable?.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    // Rebuild to reflect text offset/rotation changes
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final invert = stows.editorAutoInvert.value && brightness == .dark;
    final Color backgroundColor =
        widget.coreInfo.backgroundColor ?? InnerCanvas.defaultBackgroundColor;

    if (widget.coreInfo.pages.isEmpty) {
      return SizedBox(width: widget.width, height: widget.height);
    }

    final page = widget.coreInfo.pages[widget.pageIndex];

    final quillEditor = widget.coreInfo.pages.isNotEmpty
        ? QuillEditor(
            controller:
                widget.coreInfo.pages[widget.pageIndex].quill.controller,
            config: QuillEditorConfig(
              customStyles: SaberQuillStyles.get(
                invert: invert,
                secondary: colorScheme.secondary,
                lineHeight: widget.coreInfo.lineHeight,
              ),
              scrollable: false,
              autoFocus: false,
              expands: true,
              placeholder: widget.textEditing
                  ? t.editor.quill.typeSomething
                  : null,
              showCursor: true,
              keyboardAppearance: invert ? .dark : .light,
              padding: .only(
                top: widget.coreInfo.lineHeight * 1.2,
                left: widget.coreInfo.lineHeight * 0.5,
                right: widget.coreInfo.lineHeight * 0.5,
                bottom: widget.coreInfo.lineHeight * 0.5,
              ),
            ),
            scrollController: ScrollController(),
            focusNode: widget.coreInfo.pages[widget.pageIndex].quill.focusNode,
          )
        : null;

    final customPaint = CustomPaint(
      painter: CanvasBackgroundPainter(
        invert: invert,
        backgroundColor: () {
          if (page.backgroundImage != null) {
            return Colors.white;
          } else {
            return backgroundColor;
          }
        }(),
        backgroundPattern: () {
          if (page.backgroundImage != null) {
            return CanvasBackgroundPattern.none;
          } else {
            return widget.coreInfo.backgroundPattern;
          }
        }(),
        lineHeight: widget.coreInfo.lineHeight,
        lineThickness: widget.coreInfo.lineThickness,
        primaryColor: colorScheme.primary,
        secondaryColor: colorScheme.secondary,
        isInfiniteCanvas: widget.coreInfo.isInfiniteCanvas,
      ),
      foregroundPainter: CanvasPainter(
        repaint: widget.redrawPageListenable,
        invert: invert,
        strokes: page.strokes,
        laserStrokes: page.laserStrokes,
        currentStroke: widget.currentStroke,
        currentSelection: widget.currentSelection,
        isDoneSelecting: widget.isDoneSelecting,
        primaryColor: colorScheme.primary,
        page: page,
        showPageIndicator: widget.showPageIndicator,
        pageIndex: widget.pageIndex,
        totalPages: widget.coreInfo.pages.length,
        currentScale: widget.currentScale,
        defaultTextStyle: theme.textTheme.bodyMedium!,
        isInfiniteCanvas: widget.coreInfo.isInfiniteCanvas,
      ),
      isComplex: true,
      willChange: true,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: DeferredPointerHandler(
          child: Stack(
            children: [
              if (page.backgroundImage != null)
                CanvasImage(
                  filePath: widget.coreInfo.filePath,
                  image: page.backgroundImage!,
                  pageSize: Size(widget.width, widget.height),
                  setAsBackground: null,
                  isBackground: true,
                  readOnly: true,
                ),
              Positioned(
                top: 0,
                left: 0,
                width: widget.width,
                height: widget.height,
                child: IgnorePointer(
                  ignoring: widget.coreInfo.readOnly || !widget.textEditing,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..translateByDouble(
                        page.textContentOffset.dx,
                        page.textContentOffset.dy,
                        0,
                        1,
                      )
                      ..rotateZ(page.textContentRotation),
                    alignment: Alignment.topLeft,
                    child: quillEditor,
                  ),
                ),
              ),
              for (int i = 0; i < page.images.length; i++)
                CanvasImage(
                  filePath: widget.coreInfo.filePath,
                  image: page.images[i],
                  pageSize: Size(widget.width, widget.height),
                  setAsBackground: widget.setAsBackground,
                  readOnly:
                      widget.coreInfo.readOnly || !widget.currentToolIsSelect,
                  selected:
                      widget.currentSelection?.images.contains(
                        page.images[i],
                      ) ??
                      false,
                ),
              if (widget.currentToolIsSelect &&
                  widget.isDoneSelecting &&
                  widget.currentSelection != null &&
                  widget.currentSelection!.isNotEmpty &&
                  widget.onCopySelection != null &&
                  widget.onDeleteSelection != null)
                () {
                  final bounds = widget.currentSelection!.path.getBounds();
                  final left = (bounds.center.dx - 160.0)
                      .clamp(12.0, max(12.0, widget.width - 330.0))
                      .toDouble();
                  final top = bounds.top - 58 > 10
                      ? bounds.top - 58
                      : bounds.bottom + 14;

                  return Positioned(
                    left: left,
                    top: top,
                    child: DeferPointer(
                      child: LassoCalloutMenu(
                        onCut: widget.onCutSelection!,
                        onCopy: widget.onCopySelection!,
                        onDuplicate: widget.onDuplicateSelection ?? () {},
                        onDelete: widget.onDeleteSelection!,
                        onSetColor: widget.onSetColor ?? (_) {},
                        isResizeActive: widget.isResizeActive,
                        onToggleResize: widget.onToggleResize,
                        onTakeScreenshot: widget.onTakeScreenshot,
                        onAddToElements: widget.onAddToElements,
                        onBringToFront: widget.onBringToFront,
                        onSendToBack: widget.onSendToBack,
                        onSmoothen: widget.onSmoothen,
                        cropPossible: widget.cropPossible,
                        cropActive: widget.cropActive,
                        onToggleCrop: widget.onToggleCrop,
                        currentScale: widget.currentScale,
                      ),
                    ),
                  );
                }(),
            ],
          ),
        ),
      ),
    );

    if (widget.coreInfo.isInfiniteCanvas) {
      return customPaint;
    }
    return RepaintBoundary(child: customPaint);
  }
}
