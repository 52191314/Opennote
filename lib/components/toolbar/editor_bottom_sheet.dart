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
  });

  final bool invert;
  final EditorCoreInfo coreInfo;
  final int? currentPageIndex;
  final void Function(CanvasBackgroundPattern) setBackgroundPattern;
  final void Function(int) setLineHeight;
  final void Function(int) setLineThickness;
  final void Function(Size)? setPageSize;
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
          widget.setBackgroundPattern(template.backgroundPattern);
          widget.setLineHeight(template.lineHeight);
          widget.setLineThickness(template.lineThickness);

          if (template.initialContent != null) {
            final page = widget.coreInfo.pages
                .getOrNull(widget.currentPageIndex ?? -1);
            if (page != null) {
              page.quill.controller
                  .replaceText(0, 0, template.initialContent!, null);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.coreInfo.pages.getOrNull(widget.currentPageIndex ?? -1);
    final pageSize = page?.size ?? EditorPage.defaultSize;
    final backgroundImage = page?.backgroundImage;

    final previewSize = Size(
      CanvasBackgroundPreview.fixedWidth,
      pageSize.height / pageSize.width * CanvasBackgroundPreview.fixedWidth,
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
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final page = widget.coreInfo.pages
                        .getOrNull(widget.currentPageIndex ?? -1);
                    if (page == null) return;
                    showDialog(
                      context: context,
                      builder: (_) => LayerManager(
                        page: page,
                        onChanged: widget.redrawAndSave,
                      ),
                    );
                  },
                  child: const Wrap(
                    children: [
                      Icon(Icons.layers),
                      SizedBox(width: 8),
                      Text('Layers'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.coreInfo.isNotEmpty
                      ? () {
                          widget.clearPage();
                          Navigator.pop(context);
                        }
                      : null,
                  child: Wrap(
                    children: [
                      const Icon(Icons.cleaning_services),
                      const SizedBox(width: 8),
                      Text(
                        t.editor.menu.clearPage(
                          page: widget.currentPageIndex == null
                              ? '?'
                              : widget.currentPageIndex! + 1,
                          totalPages: widget.coreInfo.pages.length,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.coreInfo.isNotEmpty
                      ? () {
                          widget.clearAllPages();
                          Navigator.pop(context);
                        }
                      : null,
                  child: Wrap(
                    children: [
                      const Icon(Icons.cleaning_services),
                      const SizedBox(width: 8),
                      Text(t.editor.menu.clearAllPages),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showTemplatePicker(),
                  child: Wrap(
                    children: [
                      const Icon(Icons.auto_awesome),
                      const SizedBox(width: 8),
                      Text(t.editor.menu.templates),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (backgroundImage != null) ...[
              Text(
                t.editor.menu.backgroundImageFit,
                style: TextTheme.of(context).titleMedium,
              ),
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
                            selected: backgroundImage.backgroundFit == boxFit,
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
            ],
            Text(
              t.editor.menu.backgroundPattern,
              style: TextTheme.of(context).titleMedium,
            ),
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
                          backgroundImage: null, // focus on background pattern
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
              style: TextTheme.of(context).titleMedium,
            ),
            Text(
              t.editor.menu.lineHeightDescription,
              style: TextTheme.of(context).bodyMedium,
            ),
            Row(
              children: [
                Text(widget.coreInfo.lineHeight.toString()),
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
            Text(
              t.editor.menu.lineThickness,
              style: TextTheme.of(context).titleMedium,
            ),
            Text(
              t.editor.menu.lineThicknessDescription,
              style: TextTheme.of(context).bodyMedium,
            ),
            Row(
              children: [
                Text(widget.coreInfo.lineThickness.toString()),
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
            const SizedBox(height: 16),
            Text(
              'Bookmark',
              style: TextTheme.of(context).titleMedium,
            ),
            Row(
              children: [
                Switch(
                  value: page?.bookmarked ?? false,
                  onChanged: !widget.coreInfo.readOnly
                      ? (bool value) {
                          if (page == null) return;
                          page!.bookmarked = value;
                          page!.notifyListeners();
                          widget.redrawAndSave();
                        }
                      : null,
                ),
                const SizedBox(width: 8),
                Text(page?.bookmarked ?? false
                    ? 'Page is bookmarked'
                    : 'Not bookmarked'),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.setPageSize != null) ...[
              Text(
                'Page Size',
                style: TextTheme.of(context).titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Width',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: page?.size.width.toInt().toString() ?? '',
                      ),
                      onSubmitted: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed < 200 || parsed > 2000) {
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
                      decoration: const InputDecoration(
                        labelText: 'Height',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: page?.size.height.toInt().toString() ?? '',
                      ),
                      onSubmitted: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed < 200 || parsed > 2000) {
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
              const SizedBox(height: 8),
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
                      widget.setPageSize?.call(Size(750, 1000));
                    },
                  ),
                  ActionChip(
                    label: const Text('A4'),
                    onPressed: () {
                      if (page == null) return;
                      widget.setPageSize?.call(Size(842, 1191));
                    },
                  ),
                  ActionChip(
                    label: const Text('Square'),
                    onPressed: () {
                      if (page == null) return;
                      widget.setPageSize?.call(Size(1000, 1000));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Text(
              t.editor.menu.import,
              style: TextTheme.of(context).titleMedium,
            ),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
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
                  onPressed: () {
                    widget.addStickyNote();
                    Navigator.pop(context);
                  },
                  child: const Wrap(
                    children: [
                      Icon(Icons.note_add),
                      SizedBox(width: 8),
                      Text('Sticky Note'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => StickerPickerDialog(
                        onStickerSelected: widget.addSticker,
                      ),
                    );
                  },
                  child: const Wrap(
                    children: [
                      Icon(Icons.emoji_emotions),
                      SizedBox(width: 8),
                      Text('Sticker'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stows.loggedIn) ...[
              StatefulBuilder(
                builder: (context, setState) {
                  final isWatchingServer = widget.getIsWatchingServer();
                  return CheckboxListTile.adaptive(
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
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
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
