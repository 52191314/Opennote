/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_circle_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_rectangle_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/canvas_preview.dart';
import 'package:saber/components/canvas/inner_canvas.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/is_this_a_test.dart';
import 'package:screenshot/screenshot.dart';

abstract class EditorExporter {
  /// Most* strokes can be drawn to the PDF canvas as vector graphics.
  /// This function returns true if [stroke] is one of those strokes.
  ///
  /// Strokes that can't be drawn as vector graphics include:
  /// - Highlighter strokes, because PDFs don't support transparency
  /// - Pencil strokes, which need a special shader to look correct
  static bool shouldRasterizeStroke(Stroke stroke) {
    return stroke.toolId == .highlighter || stroke.toolId == .pencil;
  }

  /// Resolves the ordered list of page indices to export.
  ///
  /// When [pageIndices] is `null`, exports all pages except a single trailing
  /// empty page (the editor's auto-appended blank page). When [pageIndices] is
  /// provided, filters to valid in-range indices.
  @visibleForTesting
  static List<int> resolveExportPageIndices(
    EditorCoreInfo coreInfo, {
    Set<int>? pageIndices,
  }) {
    final pageCount = coreInfo.pages.length;
    if (pageCount == 0) return const [];

    if (pageIndices != null) {
      return pageIndices
          .where((index) => index >= 0 && index < pageCount)
          .toList(growable: false);
    }

    final effectiveCount = coreInfo.pages.last.isEmpty
        ? pageCount - 1
        : pageCount;
    return List.generate(effectiveCount, (i) => i, growable: false);
  }

  static Future<pw.Document> generatePdf(
    EditorCoreInfo coreInfo,
    BuildContext context, {
    Set<int>? pageIndices,
  }) async {
    final pdf = pw.Document();
    final exportIndices = resolveExportPageIndices(
      coreInfo,
      pageIndices: pageIndices,
    );

    // Rasterize and add one page at a time using compressed PNG bytes so
    // multi-page exports do not retain all raw RGBA bitmaps in RAM at once.
    for (final pageIndex in exportIndices) {
      final page = coreInfo.pages[pageIndex];
      final pageSize = page.size;
      final uiImage = await screenshotPage(
        coreInfo: coreInfo,
        pageIndex: pageIndex,
      );
      final pw.MemoryImage rasterBackground;
      try {
        final byteData = await uiImage.toByteData(
          format: ui.ImageByteFormat.png,
        );
        assert(
          byteData != null,
          'Judging by the code, this should never be null.',
        );
        rasterBackground = pw.MemoryImage(byteData!.buffer.asUint8List());
      } finally {
        uiImage.dispose();
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pageSize.width, pageSize.height),
          build: (pw.Context context) {
            return pw.SizedBox(
              width: pageSize.width,
              height: pageSize.height,
              child: pw.CustomPaint(
                foregroundPainter: (PdfGraphics pdfGraphics, PdfPoint size) {
                  final backgroundColor = PdfColor.fromInt(
                    coreInfo.backgroundColor?.toARGB32() ??
                        InnerCanvas.defaultBackgroundColor.toARGB32(),
                  ).flatten();

                  final strokes = [
                    for (final layer in page.layers)
                      if (layer.visible)
                        ...layer.strokes.where(
                          (stroke) => !shouldRasterizeStroke(stroke),
                        ),
                  ];
                  for (final stroke in strokes) {
                    final strokeColor = PdfColor.fromInt(
                      stroke.color.toARGB32(),
                    ).flatten(background: backgroundColor);

                    /// Whether we need to fill the shape, or draw its stroke
                    final bool shouldFillShape;
                    if (stroke is CircleStroke) {
                      shouldFillShape = false;
                      // Fill circle if fillColor is set
                      if (stroke.fillColor != null) {
                        final fillColor = PdfColor.fromInt(
                          stroke.fillColor!.toARGB32(),
                        ).flatten(background: backgroundColor);
                        pdfGraphics.setFillColor(fillColor);
                        pdfGraphics.drawEllipse(
                          stroke.center.dx,
                          pageSize.height - stroke.center.dy,
                          stroke.radius,
                          stroke.radius,
                          clockwise: false,
                        );
                        pdfGraphics.fillPath();
                      }
                      pdfGraphics.drawEllipse(
                        stroke.center.dx,
                        pageSize.height - stroke.center.dy,
                        stroke.radius,
                        stroke.radius,
                        clockwise: false,
                      );
                    } else if (stroke is RectangleStroke) {
                      shouldFillShape = false;
                      final strokeSize = stroke.options.size;
                      // Fill rect if fillColor is set
                      if (stroke.fillColor != null) {
                        final fillColor = PdfColor.fromInt(
                          stroke.fillColor!.toARGB32(),
                        ).flatten(background: backgroundColor);
                        pdfGraphics.setFillColor(fillColor);
                        pdfGraphics.drawRRect(
                          stroke.rect.left,
                          pageSize.height - stroke.rect.bottom,
                          stroke.rect.width,
                          stroke.rect.height,
                          strokeSize / 4,
                          strokeSize / 4,
                        );
                        pdfGraphics.fillPath();
                      }
                      pdfGraphics.drawRRect(
                        stroke.rect.left,
                        pageSize.height - stroke.rect.bottom,
                        stroke.rect.width,
                        stroke.rect.height,
                        strokeSize / 4,
                        strokeSize / 4,
                      );
                    } else if (stroke is ArrowStroke ||
                        stroke is DimensionStroke) {
                      shouldFillShape = false;
                      pdfGraphics.drawShape(stroke.toSvgPath());
                    } else {
                      shouldFillShape = true;
                      pdfGraphics.drawShape(stroke.toSvgPath());
                    }

                    if (shouldFillShape) {
                      // fill
                      pdfGraphics.setFillColor(strokeColor);
                      pdfGraphics.fillPath();
                    } else {
                      // stroke
                      pdfGraphics.setStrokeColor(strokeColor);
                      pdfGraphics.setLineWidth(stroke.options.size);
                      pdfGraphics.strokePath();
                    }

                    if (stroke is DimensionStroke && stroke.text.isNotEmpty) {
                      final font = pdfGraphics.defaultFont;
                      if (font != null) {
                        try {
                          const fontSize = 12.0;
                          final textPos = stroke.textPosition;
                          final textMetrics = font.stringMetrics(stroke.text);
                          final textWidth = textMetrics.width * fontSize;
                          final textX = textPos.dx - textWidth / 2;
                          final textY =
                              (pageSize.height - textPos.dy) -
                              (textMetrics.ascent + textMetrics.descent) /
                                  2 *
                                  fontSize;
                          pdfGraphics.setFillColor(strokeColor);
                          pdfGraphics.drawString(
                            font,
                            fontSize,
                            stroke.text,
                            textX,
                            textY,
                          );
                        } catch (_) {
                          // Fallback if font encoding fails
                        }
                      }
                    }
                  }
                },
                child: pw.Image(
                  rasterBackground,
                  width: pageSize.width,
                  height: pageSize.height,
                ),
              ),
            );
          },
        ),
      );
    }

    return pdf;
  }

  /// Returns a screenshot of the page at [pageIndex] in [coreInfo].
  ///
  /// Note that screenshots do not include most* strokes
  /// because they're added separately to the PDF as vector graphics.
  /// See [shouldRasterizeStroke] for more details, or set
  /// [rasterizeAllStrokes] to true to include all strokes in the screenshot.
  ///
  /// You must dispose this image when you're done.
  static Future<ui.Image> screenshotPage({
    required EditorCoreInfo coreInfo,
    required int pageIndex,
    bool rasterizeAllStrokes = false,
    Size? targetSize,
    double? cropHeight,
    double pixelRatio = 2,
  }) async {
    final page = coreInfo.pages[pageIndex].cloneForRasterization(
      rasterizeAllStrokes: rasterizeAllStrokes,
    );

    final imagesToLoad = [
      ?page.backgroundImage,
      ...page.images,
    ].where((image) => !image.loadedIn).toList(growable: false);
    await Future.wait(
      imagesToLoad.map((image) => image.loadIn()),
    ).timeout(const Duration(seconds: 10), onTimeout: () => const []);

    try {
      targetSize ??= page.size;
      coreInfo = coreInfo.copyWith(
        pages: [for (var i = 0; i < coreInfo.pages.length; ++i) page],
      );
      return await ScreenshotController.widgetToUiImage(
        EditorExporterTheme(
          targetSize: targetSize,
          child: CanvasPreview(
            pageIndex: pageIndex,
            height: cropHeight,
            coreInfo: coreInfo,
          ),
        ),
        pixelRatio: pixelRatio,
        targetSize: targetSize,
        delay: isThisATest ? .zero : const Duration(milliseconds: 200),
      );
    } finally {
      for (final image in imagesToLoad) unawaited(image.loadOut());
      page.disposeClonedData();
    }
  }
}

/// Applies a consistent theme to its [child] so that exports
/// look the same regardless of the user's current theme or device.
class EditorExporterTheme extends StatelessWidget {
  const EditorExporterTheme({
    super.key,
    required this.targetSize,
    required this.child,
  });

  final Size targetSize;
  final Widget child;

  static final theme = ThemeData(
    brightness: .light,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.red,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(size: targetSize),
      child: Localizations(
        // needed to avoid errors with Quill, but not actually used
        locale: const Locale('en', 'US'),
        delegates: GlobalMaterialLocalizations.delegates,
        child: Theme(
          data: theme,
          child: DefaultTextStyle(
            style: theme.textTheme.bodyMedium!,
            child: SizedBox(
              width: targetSize.width,
              height: targetSize.height,
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.topLeft,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
