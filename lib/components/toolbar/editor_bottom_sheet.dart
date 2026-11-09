/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Modified with Claude Code (Claude Sonnet 5.5)
/// 🤖 Modified with Grok 4.7
library;

import 'dart:math' show min;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/canvas/canvas_background_preview.dart';
import 'package:saber/components/canvas/canvas_image_dialog.dart';
import 'package:saber/components/canvas/inner_canvas.dart';
import 'package:saber/components/editor/layer_manager.dart';
import 'package:saber/components/editor/sticker_picker.dart';
import 'package:saber/components/editor/template_picker_dialog.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/list_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/page_templates.dart';
import 'package:saber/i18n/extensions/box_fit_localized.dart';
import 'package:saber/i18n/extensions/canvas_background_pattern_localized.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:sbn/canvas_background_pattern.dart';

class EditorBottomSheet extends StatefulWidget {
  const EditorBottomSheet({
    super.key,
    required this.invert,
    required this.coreInfo,
    required this.currentPageIndex,
    required this.setBackgroundPattern,
    required this.setLineHeight,
    required this.setLineThickness,
    required this.setInfiniteCanvas,
    this.onFitContent,
    required this.removeBackgroundImage,
    required this.redrawImage,
    required this.clearPage,
    required this.clearAllPages,
    required this.redrawAndSave,
    required this.pickPhotos,
    required this.importPdf,
    required this.addStickyNote,
    required this.addSticker,
    required this.canRasterPdf,
    required this.getIsWatchingServer,
    required this.setIsWatchingServer,
    this.setPageSize,
    this.onOpenPresentation,
    this.onOpenFlashcards,
    this.onExport,
  });

  final bool invert;
  final EditorCoreInfo coreInfo;
  final int? currentPageIndex;
  final void Function(CanvasBackgroundPattern) setBackgroundPattern;
  final void Function(int) setLineHeight;
  final void Function(int) setLineThickness;
  final void Function(bool infinite) setInfiniteCanvas;
  final VoidCallback? onFitContent;
  final void Function(Size)? setPageSize;
  final VoidCallback? onOpenPresentation;
  final VoidCallback? onOpenFlashcards;
  final VoidCallback? onExport;
  final VoidCallback removeBackgroundImage;
  final VoidCallback redrawImage;
  final VoidCallback clearPage;
  final VoidCallback clearAllPages;
  final VoidCallback redrawAndSave;
  final Future<int> Function() pickPhotos;
  final Future<bool> Function() importPdf;
  final VoidCallback addStickyNote;
  final void Function(String emoji) addSticker;
  final bool canRasterPdf;
  final bool Function() getIsWatchingServer;
  final void Function(bool) setIsWatchingServer;

  @override
  State<EditorBottomSheet> createState() => _EditorBottomSheetState();
}

class _EditorBottomSheetState extends State<EditorBottomSheet> {
  static const imageBoxFits = <BoxFit>[.fill, .cover, .contain];

  void _showTemplatePicker() {
    showDialog(
      context: context,
      builder: (_) => TemplatePickerDialog(
        coreInfo: widget.coreInfo,
        currentPageIndex: widget.currentPageIndex,
        invert: widget.invert,
        onTemplateSelected: (PageTemplate template) {
          final page = widget.coreInfo.pages.getOrNull(
            widget.currentPageIndex ?? -1,
          );
          if (page == null) return;
          template.applyTo(page);
          widget.redrawAndSave();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    final page = widget.coreInfo.pages.getOrNull(widget.currentPageIndex ?? -1);
    final pageSize = page?.size ?? EditorPage.defaultSize;
    final backgroundImage = page?.backgroundImage;

    final previewSize = Size(
      CanvasBackgroundPreview.fixedWidth,
      pageSize.height / pageSize.width * CanvasBackgroundPreview.fixedWidth,
    );

    final actionButtonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: colorScheme.surfaceContainerLow,
      foregroundColor: colorScheme.onSurface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          width: 1,
        ),
      ),
    );

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        // Enable drag scrolling on all devices (including mouse)
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 16),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 12),
            // Studio drag pill indicator
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // 1. Studio Quick-Action 2x4 Bento Grid
            _StudioSectionCard(
              colorScheme: colorScheme,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.95,
                children: [
                  // 1. Presentation
                  _BentoActionCard(
                    icon: Icons.present_to_all,
                    label: t.editor.sheet.presentation,
                    enabled: widget.onOpenPresentation != null,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onOpenPresentation?.call();
                    },
                  ),
                  // 2. Flashcards
                  _BentoActionCard(
                    icon: Icons.auto_stories,
                    label: t.editor.sheet.flashcards,
                    enabled: widget.onOpenFlashcards != null,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onOpenFlashcards?.call();
                    },
                  ),
                  // 3. Layers
                  _BentoActionCard(
                    icon: Icons.layers,
                    label: t.editor.layers.title,
                    onTap: () {
                      final page = widget.coreInfo.pages.getOrNull(
                        widget.currentPageIndex ?? -1,
                      );
                      if (page == null) return;
                      showDialog(
                        context: context,
                        builder: (_) => LayerManager(
                          page: page,
                          onChanged: widget.redrawAndSave,
                        ),
                      );
                    },
                  ),
                  // 4. Templates
                  _BentoActionCard(
                    icon: Icons.auto_awesome,
                    label: t.editor.menu.templates,
                    onTap: _showTemplatePicker,
                  ),
                  // 5. Clear Page
                  _BentoActionCard(
                    icon: Icons.cleaning_services,
                    label: t.editor.menu.clearPage(
                      page: widget.currentPageIndex == null
                          ? '?'
                          : widget.currentPageIndex! + 1,
                      totalPages: widget.coreInfo.pages.length,
                    ),
                    color: colorScheme.error,
                    enabled: widget.coreInfo.isNotEmpty,
                    onTap: () {
                      widget.clearPage();
                      Navigator.pop(context);
                    },
                  ),
                  // 6. Clear All
                  _BentoActionCard(
                    icon: Icons.cleaning_services,
                    label: t.editor.menu.clearAllPages,
                    color: colorScheme.error,
                    enabled: widget.coreInfo.isNotEmpty,
                    onTap: () {
                      widget.clearAllPages();
                      Navigator.pop(context);
                    },
                  ),
                  // 7. Fit Content
                  _BentoActionCard(
                    icon: Icons.fit_screen_rounded,
                    label: t.editor.canvasHud.fitContent,
                    enabled: widget.onFitContent != null,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onFitContent?.call();
                    },
                  ),
                  // 8. Export
                  _BentoActionCard(
                    icon: Icons.ios_share,
                    label: t.editor.toolbar.export,
                    enabled: widget.onExport != null,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onExport?.call();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Background Image Card (if present)
            if (backgroundImage != null) ...[
              _StudioSectionCard(
                colorScheme: colorScheme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.editor.menu.backgroundImageFit,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: previewSize.height,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageBoxFits.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final boxFit = imageBoxFits[index];
                          return InkWell(
                            borderRadius: const .all(.circular(8)),
                            onTap: () => setState(() {
                              backgroundImage.backgroundFit = boxFit;
                              widget.redrawAndSave();
                            }),
                            child: Stack(
                              children: [
                                CanvasBackgroundPreview(
                                  selected:
                                      backgroundImage.backgroundFit == boxFit,
                                  invert: widget.invert,
                                  backgroundColor:
                                      widget.coreInfo.backgroundColor ??
                                      InnerCanvas.defaultBackgroundColor,
                                  backgroundPattern:
                                      widget.coreInfo.backgroundPattern,
                                  backgroundImage: backgroundImage,
                                  overrideBoxFit: boxFit,
                                  pageSize: pageSize,
                                  lineHeight: widget.coreInfo.lineHeight,
                                  lineThickness: widget.coreInfo.lineThickness,
                                ),
                                Positioned(
                                  bottom: previewSize.height * 0.1,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: _PermanentTooltip(
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
              ),
              const SizedBox(height: 14),
            ],

            // 3. Paper & Background Pattern Studio Card
            _StudioSectionCard(
              colorScheme: colorScheme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.editor.menu.backgroundPattern,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: previewSize.height,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: CanvasBackgroundPattern.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final backgroundPattern =
                            CanvasBackgroundPattern.values[index];
                        return InkWell(
                          borderRadius: const .all(.circular(8)),
                          onTap: () => setState(() {
                            widget.setBackgroundPattern(backgroundPattern);
                          }),
                          child: Stack(
                            children: [
                              CanvasBackgroundPreview(
                                selected:
                                    widget.coreInfo.backgroundPattern ==
                                    backgroundPattern,
                                invert: widget.invert,
                                backgroundColor:
                                    widget.coreInfo.backgroundColor ??
                                    InnerCanvas.defaultBackgroundColor,
                                backgroundPattern: backgroundPattern,
                                backgroundImage:
                                    null, // focus on background pattern
                                pageSize: pageSize,
                                lineHeight: widget.coreInfo.lineHeight,
                                lineThickness: widget.coreInfo.lineThickness,
                              ),
                              Positioned(
                                bottom: previewSize.height * 0.1,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: _PermanentTooltip(
                                    text: backgroundPattern.localizedName,
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
                  Text(
                    t.editor.menu.lineHeight,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    t.editor.menu.lineHeightDescription,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.coreInfo.lineHeight.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: Slider(
                          value: widget.coreInfo.lineHeight.toDouble(),
                          min: 20,
                          max: 100,
                          divisions: 8,
                          onChanged: (double value) => setState(() {
                            widget.setLineHeight(value.toInt());
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.editor.menu.lineThickness,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    t.editor.menu.lineThicknessDescription,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.coreInfo.lineThickness.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: Slider(
                          value: widget.coreInfo.lineThickness.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          onChanged: (double value) => setState(() {
                            widget.setLineThickness(value.toInt());
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Canvas Mode & Page Dimensions Studio Card
            _StudioSectionCard(
              colorScheme: colorScheme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.editor.sheet.canvasMode,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(t.editor.sheet.paged),
                        icon: const Icon(Icons.description_outlined),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(t.editor.sheet.infiniteCanvas),
                        icon: const Icon(Icons.all_inclusive_rounded),
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
                  if (!widget.coreInfo.isInfiniteCanvas) ...[
                    const SizedBox(height: 16),
                    Text(
                      t.editor.sheet.bookmark,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Switch(
                          value: page?.bookmarked ?? false,
                          onChanged: !widget.coreInfo.readOnly
                              ? (bool value) {
                                  if (page == null) return;
                                  page.bookmarked = value;
                                  widget.redrawAndSave();
                                }
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          page?.bookmarked ?? false
                              ? t.editor.sheet.pageIsBookmarked
                              : t.editor.sheet.notBookmarked,
                        ),
                      ],
                    ),
                  ],
                  if (!widget.coreInfo.isInfiniteCanvas &&
                      widget.setPageSize != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      t.editor.sheet.pageSize,
                      style: textTheme.titleMedium?.copyWith(
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
                            controller: TextEditingController(
                              text: page?.size.width.toInt().toString() ?? '',
                            ),
                            onSubmitted: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed == null ||
                                  parsed < 200 ||
                                  parsed > 2000) {
                                return;
                              }
                              if (page == null) return;
                              final newSize = Size(
                                parsed.roundToDouble(),
                                page.size.height,
                              );
                              widget.setPageSize?.call(newSize);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
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
                            controller: TextEditingController(
                              text: page?.size.height.toInt().toString() ?? '',
                            ),
                            onSubmitted: (value) {
                              final parsed = double.tryParse(value);
                              if (parsed == null ||
                                  parsed < 200 ||
                                  parsed > 2000) {
                                return;
                              }
                              if (page == null) return;
                              final newSize = Size(
                                page.size.width,
                                parsed.roundToDouble(),
                              );
                              widget.setPageSize?.call(newSize);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('1:1'),
                          onPressed: () {
                            if (page == null) return;
                            final size = page.size;
                            final side = min(size.width, size.height);
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
            const SizedBox(height: 14),

            // 5. Import & Media Studio Card
            _StudioSectionCard(
              colorScheme: colorScheme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.editor.menu.import,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        style: actionButtonStyle,
                        onPressed: () async {
                          final photosPicked = await widget.pickPhotos();
                          if (photosPicked > 0) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          }
                        },
                        child: Text(t.editor.toolbar.photo),
                      ),
                      if (widget.canRasterPdf)
                        ElevatedButton(
                          style: actionButtonStyle,
                          onPressed: () async {
                            final pdfImported = await widget.importPdf();
                            if (pdfImported) {
                              if (!context.mounted) return;
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('PDF'),
                        ),
                      ElevatedButton(
                        style: actionButtonStyle,
                        onPressed: () {
                          widget.addStickyNote();
                          Navigator.pop(context);
                        },
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.note_add, size: 18),
                            const SizedBox(width: 8),
                            Text(t.editor.sheet.stickyNote),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: actionButtonStyle,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => StickerPickerDialog(
                              onStickerSelected: widget.addSticker,
                            ),
                          );
                        },
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.emoji_emotions, size: 18),
                            const SizedBox(width: 8),
                            Text(t.editor.sheet.sticker),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (stows.loggedIn) ...[
              _StudioSectionCard(
                colorScheme: colorScheme,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final isWatchingServer = widget.getIsWatchingServer();
                    return CheckboxListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: isWatchingServer,
                      title: Text(t.editor.menu.watchServer),
                      subtitle: isWatchingServer
                          ? Text(t.editor.menu.watchServerReadOnly)
                          : null,
                      onChanged: (value) => setState(() {
                        widget.setIsWatchingServer(value!);
                      }),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudioSectionCard extends StatelessWidget {
  const _StudioSectionCard({required this.colorScheme, required this.child});

  final ColorScheme colorScheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class _PermanentTooltip extends StatelessWidget {
  const _PermanentTooltip({
    // ignore: unused_element_parameter
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const .all(.circular(8)),
        color: colorScheme.surface.withValues(alpha: 0.8),
      ),
      child: Padding(
        padding: const .symmetric(horizontal: 8),
        child: Text(
          text,
          textAlign: .center,
          textWidthBasis: TextWidthBasis.longestLine,
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
    );
  }
}

/// A tactile bento grid action card with an icon and label.
class _BentoActionCard extends StatelessWidget {
  const _BentoActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final effectiveColor = color ?? colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: enabled
                    ? effectiveColor
                    : colorScheme.onSurface.withValues(alpha: 0.38),
              ),
              const SizedBox(height: 5),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
