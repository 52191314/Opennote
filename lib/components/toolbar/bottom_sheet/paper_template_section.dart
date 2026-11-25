/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/canvas_background_preview.dart';
import 'package:saber/components/canvas/canvas_image_dialog.dart';
import 'package:saber/components/canvas/inner_canvas.dart';
import 'package:saber/components/toolbar/bottom_sheet/sheet_primitives.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/i18n/extensions/box_fit_localized.dart';
import 'package:saber/i18n/extensions/canvas_background_pattern_localized.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:sbn/canvas_background_pattern.dart';

/// Visual Paper & Template Picker, Line Spacing sliders, Canvas Mode toggle,
/// and Page Dimensions section for [EditorBottomSheet].
class PaperTemplateSection extends StatefulWidget {
  const PaperTemplateSection({
    super.key,
    required this.invert,
    required this.coreInfo,
    required this.page,
    required this.pageSize,
    required this.setBackgroundPattern,
    required this.setLineHeight,
    required this.setLineThickness,
    required this.setInfiniteCanvas,
    required this.redrawAndSave,
    this.setPageSize,
    this.onOpenTemplatePicker,
    this.isPro = false,
    this.onProFeatureRequested,
  });

  final bool invert;
  final EditorCoreInfo coreInfo;
  final EditorPage? page;
  final Size pageSize;
  final void Function(CanvasBackgroundPattern) setBackgroundPattern;
  final void Function(int) setLineHeight;
  final void Function(int) setLineThickness;
  final void Function(bool infinite) setInfiniteCanvas;
  final VoidCallback redrawAndSave;
  final void Function(Size)? setPageSize;
  final VoidCallback? onOpenTemplatePicker;
  final bool isPro;
  final void Function(String featureId)? onProFeatureRequested;

  /// Patterns highlighted as Opennote Pro templates when [isPro] is false.
  static const proPatterns = <CanvasBackgroundPattern>{
    CanvasBackgroundPattern.cornell,
    CanvasBackgroundPattern.isometric,
    CanvasBackgroundPattern.engineeringGrid,
    CanvasBackgroundPattern.staffs,
    CanvasBackgroundPattern.tablature,
  };

  @override
  State<PaperTemplateSection> createState() => _PaperTemplateSectionState();
}

class _PaperTemplateSectionState extends State<PaperTemplateSection> {
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(
      text: widget.page?.size.width.toInt().toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.page?.size.height.toInt().toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant PaperTemplateSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newWidth = widget.page?.size.width.toInt().toString() ?? '';
    final newHeight = widget.page?.size.height.toInt().toString() ?? '';
    if (_widthController.text != newWidth) _widthController.text = newWidth;
    if (_heightController.text != newHeight) _heightController.text = newHeight;
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _handlePatternTap(CanvasBackgroundPattern pattern) {
    final isGated =
        !widget.isPro &&
        widget.onProFeatureRequested != null &&
        PaperTemplateSection.proPatterns.contains(pattern);
    if (isGated) {
      widget.onProFeatureRequested!('paper_pattern_${pattern.name}');
      return;
    }
    setState(() {
      widget.setBackgroundPattern(pattern);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    final page = widget.page;
    final previewSize = Size(
      CanvasBackgroundPreview.fixedWidth,
      widget.pageSize.height /
          widget.pageSize.width *
          CanvasBackgroundPreview.fixedWidth,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Visual Paper & Template Picker
        StudioSectionCard(
          title: t.editor.menu.backgroundPattern,
          trailing: widget.onOpenTemplatePicker != null
              ? TextButton.icon(
                  onPressed: widget.onOpenTemplatePicker,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                  label: Text(
                    t.editor.menu.templates,
                    style: const TextStyle(fontSize: 12),
                  ),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: previewSize.height,
                child: ListView.separated(
                  key: const ValueKey('paper_pattern_list'),
                  scrollDirection: Axis.horizontal,
                  itemCount: CanvasBackgroundPattern.values.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final pattern = CanvasBackgroundPattern.values[index];
                    final isProPattern =
                        !widget.isPro &&
                        widget.onProFeatureRequested != null &&
                        PaperTemplateSection.proPatterns.contains(pattern);

                    return InkWell(
                      key: ValueKey('paper_pattern_${pattern.name}'),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      onTap: () => _handlePatternTap(pattern),
                      child: Stack(
                        children: [
                          CanvasBackgroundPreview(
                            selected:
                                widget.coreInfo.backgroundPattern == pattern,
                            invert: widget.invert,
                            backgroundColor:
                                widget.coreInfo.backgroundColor ??
                                InnerCanvas.defaultBackgroundColor,
                            backgroundPattern: pattern,
                            backgroundImage: null,
                            pageSize: widget.pageSize,
                            lineHeight: widget.coreInfo.lineHeight,
                            lineThickness: widget.coreInfo.lineThickness,
                          ),
                          if (isProPattern)
                            const Positioned(
                              top: 6,
                              right: 6,
                              child: ProFeatureBadge(compact: true),
                            ),
                          Positioned(
                            bottom: previewSize.height * 0.08,
                            left: 4,
                            right: 4,
                            child: Center(
                              child: PermanentThumbnailLabel(
                                text: pattern.localizedName,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _SliderRow(
                title: t.editor.menu.lineHeight,
                description: t.editor.menu.lineHeightDescription,
                valueLabel: '${widget.coreInfo.lineHeight} px',
                value: widget.coreInfo.lineHeight.toDouble().clamp(20, 100),
                min: 20,
                max: 100,
                divisions: 8,
                onChanged: (value) => setState(() {
                  widget.setLineHeight(value.toInt());
                }),
              ),
              const SizedBox(height: 8),
              _SliderRow(
                title: t.editor.menu.lineThickness,
                description: t.editor.menu.lineThicknessDescription,
                valueLabel: '${widget.coreInfo.lineThickness} pt',
                value: widget.coreInfo.lineThickness.toDouble().clamp(1, 5),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (value) => setState(() {
                  widget.setLineThickness(value.toInt());
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Canvas Mode & Page Dimensions
        StudioSectionCard(
          title: t.editor.sheet.canvasMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(
                        t.editor.sheet.paged,
                        overflow: TextOverflow.ellipsis,
                      ),
                      icon: const Icon(Icons.description_outlined, size: 18),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text(
                        t.editor.sheet.infiniteCanvas,
                        overflow: TextOverflow.ellipsis,
                      ),
                      icon: const Icon(Icons.all_inclusive_rounded, size: 18),
                    ),
                  ],
                  selected: {widget.coreInfo.isInfiniteCanvas},
                  onSelectionChanged: !widget.coreInfo.readOnly
                      ? (newSelection) {
                          setState(() {
                            widget.setInfiniteCanvas(newSelection.first);
                          });
                        }
                      : null,
                ),
              ),
              if (!widget.coreInfo.isInfiniteCanvas) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Switch.adaptive(
                      value: page?.bookmarked ?? false,
                      onChanged: !widget.coreInfo.readOnly
                          ? (bool value) {
                              if (page == null) return;
                              setState(() {
                                page.bookmarked = value;
                                widget.redrawAndSave();
                              });
                            }
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.editor.sheet.bookmark,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            page?.bookmarked ?? false
                                ? t.editor.sheet.pageIsBookmarked
                                : t.editor.sheet.notBookmarked,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (!widget.coreInfo.isInfiniteCanvas &&
                  widget.setPageSize != null) ...[
                const SizedBox(height: 14),
                Text(
                  t.editor.sheet.pageSize,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: t.editor.sheet.width,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        controller: _widthController,
                        onSubmitted: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed < 200 || parsed > 2000) {
                            return;
                          }
                          if (page == null) return;
                          widget.setPageSize?.call(
                            Size(parsed.roundToDouble(), page.size.height),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: t.editor.sheet.height,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        controller: _heightController,
                        onSubmitted: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed < 200 || parsed > 2000) {
                            return;
                          }
                          if (page == null) return;
                          widget.setPageSize?.call(
                            Size(page.size.width, parsed.roundToDouble()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('1:1'),
                      onPressed: () {
                        if (page == null) return;
                        final side = min(page.size.width, page.size.height);
                        widget.setPageSize?.call(Size(side, side));
                      },
                    ),
                    ActionChip(
                      label: const Text('3:4'),
                      onPressed: () {
                        if (page == null) return;
                        widget.setPageSize?.call(const Size(750, 1000));
                      },
                    ),
                    ActionChip(
                      label: const Text('A4'),
                      onPressed: () {
                        if (page == null) return;
                        widget.setPageSize?.call(const Size(842, 1191));
                      },
                    ),
                    ActionChip(
                      label: Text(t.editor.sheet.square),
                      onPressed: () {
                        if (page == null) return;
                        widget.setPageSize?.call(const Size(1000, 1000));
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Background image fit picker and management controls shown when the active
/// page has a background image.
class BackgroundImageSection extends StatefulWidget {
  const BackgroundImageSection({
    super.key,
    required this.invert,
    required this.coreInfo,
    required this.page,
    required this.pageSize,
    required this.redrawImage,
    required this.redrawAndSave,
    required this.removeBackgroundImage,
  });

  final bool invert;
  final EditorCoreInfo coreInfo;
  final EditorPage page;
  final Size pageSize;
  final VoidCallback redrawImage;
  final VoidCallback redrawAndSave;
  final VoidCallback removeBackgroundImage;

  @override
  State<BackgroundImageSection> createState() => _BackgroundImageSectionState();
}

class _BackgroundImageSectionState extends State<BackgroundImageSection> {
  static const _imageBoxFits = <BoxFit>[.fill, .cover, .contain];

  @override
  Widget build(BuildContext context) {
    final backgroundImage = widget.page.backgroundImage;
    if (backgroundImage == null) return const SizedBox.shrink();

    final previewSize = Size(
      CanvasBackgroundPreview.fixedWidth,
      widget.pageSize.height /
          widget.pageSize.width *
          CanvasBackgroundPreview.fixedWidth,
    );

    return StudioSectionCard(
      title: t.editor.menu.backgroundImageFit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: previewSize.height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _imageBoxFits.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final boxFit = _imageBoxFits[index];
                return InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  onTap: () => setState(() {
                    backgroundImage.backgroundFit = boxFit;
                    widget.redrawAndSave();
                  }),
                  child: Stack(
                    children: [
                      CanvasBackgroundPreview(
                        selected: backgroundImage.backgroundFit == boxFit,
                        invert: widget.invert,
                        backgroundColor:
                            widget.coreInfo.backgroundColor ??
                            InnerCanvas.defaultBackgroundColor,
                        backgroundPattern: widget.coreInfo.backgroundPattern,
                        backgroundImage: backgroundImage,
                        overrideBoxFit: boxFit,
                        pageSize: widget.pageSize,
                        lineHeight: widget.coreInfo.lineHeight,
                        lineThickness: widget.coreInfo.lineThickness,
                      ),
                      Positioned(
                        bottom: previewSize.height * 0.08,
                        left: 4,
                        right: 4,
                        child: Center(
                          child: PermanentThumbnailLabel(
                            text: boxFit.localizedName,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          CanvasImageDialog(
            filePath: widget.coreInfo.filePath,
            image: backgroundImage,
            redrawImage: () => setState(() {
              widget.redrawImage();
            }),
            isBackground: true,
            toggleAsBackground: widget.removeBackgroundImage,
            singleRow: true,
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.title,
    required this.description,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String title;
  final String description;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                valueLabel,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        Text(
          description,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
