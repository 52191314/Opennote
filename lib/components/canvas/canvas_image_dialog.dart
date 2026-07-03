import 'dart:convert';

import 'package:flutter/cupertino.dart' show CupertinoDialogAction, CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/components/theming/adaptive_alert_dialog.dart';
import 'package:saber/components/theming/adaptive_icon.dart';
import 'package:saber/components/theming/adaptive_switch.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

class CanvasImageDialog extends StatefulWidget {
  const CanvasImageDialog({
    super.key,
    required this.filePath,
    required this.image,
    required this.redrawImage,
    required this.isBackground,
    required this.toggleAsBackground,
    this.singleRow = false,
  });

  final String filePath;
  final EditorImage image;
  final VoidCallback redrawImage;

  final bool isBackground;
  final VoidCallback? toggleAsBackground;

  final bool singleRow;

  @override
  State<CanvasImageDialog> createState() => _CanvasImageDialogState();
}

class _CanvasImageDialogState extends State<CanvasImageDialog> {
  void setInvertible([bool? value]) => setState(() {
    widget.image.invertible = value ?? !widget.image.invertible;
    widget.image.onMiscChange?.call();
    widget.redrawImage();
  });

  /// The preset colors available for sticky notes.
  static const List<Color> stickyNoteColors = [
    Color(0xFFFFF59D), // yellow
    Color(0xFFFFCDD2), // pink
    Color(0xFFC8E6C9), // green
    Color(0xFFBBDEFB), // blue
    Color(0xFFFFE0B2), // orange
    Color(0xFFE1BEE7), // purple
    Color(0xFFB2EBF2), // cyan
    Color(0xFFD7CCC8), // brown
  ];

  /// Shows a dialog to edit the sticky note text content and color.
  void _showStickyNoteEditor() {
    final sticky = widget.image as StickyNoteImage;
    final controller = TextEditingController(text: sticky.text);
    Color selectedColor = sticky.color;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AdaptiveAlertDialog(
              title: const Text('Edit Sticky Note'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Text:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    maxLines: 5,
                    minLines: 1,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type your note here...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Color:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: stickyNoteColors.map((color) {
                      final isSelected = color == selectedColor;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedColor = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade400,
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    sticky.text = controller.text;
                    sticky.color = selectedColor;
                    sticky.onMiscChange?.call();
                    widget.redrawImage();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final children = <Widget>[
      if (widget.image is StickyNoteImage)
        _CanvasImageDialogItem(
          onTap: () {
            _showStickyNoteEditor();
          },
          title: 'Edit Text',
          child: const Icon(Icons.edit),
        ),
      MergeSemantics(
        child: _CanvasImageDialogItem(
          onTap: stows.editorAutoInvert.value ? setInvertible : null,
          title: t.editor.imageOptions.invertible,
          child: AdaptiveSwitch(
            value: widget.image.invertible,
            onChanged: stows.editorAutoInvert.value ? setInvertible : null,
            thumbIcon: WidgetStateProperty.all(
              widget.image.invertible
                  ? const Icon(Icons.invert_colors)
                  : const Icon(Icons.invert_colors_off),
            ),
          ),
        ),
      ),
      _CanvasImageDialogItem(
        onTap: () async {
          final filePathSanitized = widget.filePath.replaceAll(
            RegExp(r'[^a-zA-Z\d]'),
            '_',
          );
          final imageFileName =
              'image$filePathSanitized${widget.image.id}${widget.image.extension}';
          final List<int> bytes;
          switch (widget.image) {
            case final PdfEditorImage image:
              bytes =
                  image.pdfBytes ??
                  await image.pdfFile?.readAsBytes() ??
                  (throw ArgumentError.value(
                    image,
                    'image',
                    'PDF image has no bytes or file',
                  ));
            case final SvgEditorImage image:
              bytes = switch (image.svgLoader) {
                (final SvgStringLoader loader) => utf8.encode(
                  loader.provideSvg(null),
                ),
                (final SvgFileLoader loader) => await loader.file.readAsBytes(),
                (_) => throw ArgumentError.value(
                  image.svgLoader,
                  'svgLoader',
                  'Unknown SVG loader type',
                ),
              };
            case final PngEditorImage image:
              if (image.imageProvider is MemoryImage) {
                bytes = (image.imageProvider as MemoryImage).bytes;
              } else if (image.imageProvider is FileImage) {
                bytes = await (image.imageProvider as FileImage).file
                    .readAsBytes();
              } else {
                throw ArgumentError.value(
                  image.imageProvider,
                  'imageProvider',
                  'Unknown image provider type',
                );
              }
            case final StickyNoteImage image:
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sticky notes cannot be downloaded'),
                ),
              );
              Navigator.of(context).pop();
              return;
            case final StickerImage image:
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stickers cannot be downloaded'),
                ),
              );
              Navigator.of(context).pop();
              return;
          }
          if (!context.mounted) return;
          FileManager.exportFile(
            imageFileName,
            bytes,
            isImage: true,
            context: context,
          );
          Navigator.of(context).pop();
        },
        title: t.editor.imageOptions.download,
        child: const AdaptiveIcon(
          icon: Icons.download,
          cupertinoIcon: CupertinoIcons.arrow_down_circle_fill,
        ),
      ),
      _CanvasImageDialogItem(
        onTap: () {
          widget.toggleAsBackground?.call();
          Navigator.of(context).pop();
        },
        title: widget.isBackground
            ? t.editor.imageOptions.removeAsBackground
            : t.editor.imageOptions.setAsBackground,
        child: const AdaptiveIcon(
          icon: Icons.wallpaper,
          cupertinoIcon: CupertinoIcons.photo_fill_on_rectangle_fill,
        ),
      ),
      _CanvasImageDialogItem(
        onTap: () {
          widget.image.onDeleteImage?.call(widget.image);
          widget.redrawImage();
          Navigator.of(context).pop();
        },
        title: t.editor.imageOptions.delete,
        child: const AdaptiveIcon(
          icon: Icons.delete,
          cupertinoIcon: CupertinoIcons.trash_fill,
        ),
      ),
    ];

    final gridView = GridView.count(
      crossAxisCount: widget.singleRow ? children.length : 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      children: children,
    );
    // issues with intrinsic sizes with each type of dialog
    if (platform.isCupertino) {
      return AspectRatio(
        aspectRatio: widget.singleRow ? children.length / 1 : 2,
        child: gridView,
      );
    } else {
      return SizedBox(width: 250, child: gridView);
    }
  }
}

class _CanvasImageDialogItem extends StatelessWidget {
  const _CanvasImageDialogItem({
    // ignore: unused_element_parameter
    super.key,
    required this.onTap,
    required this.title,
    required this.child,
  });

  final VoidCallback? onTap;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Material(
      color: colorScheme.primary.withValues(alpha: 0.05),
      borderRadius: const .all(.circular(8)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const .symmetric(horizontal: 8, vertical: 16),
          child: Column(
            children: [
              Expanded(child: child),
              Text(title, textAlign: .center),
            ],
          ),
        ),
      ),
    );
  }
}
