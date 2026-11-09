/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/inner_canvas.dart';
import 'package:saber/components/canvas/invert_widget.dart';
import 'package:saber/components/home/sync_indicator.dart';
import 'package:saber/data/extensions/color_extensions.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/is_this_a_test.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';
import 'package:yaru/yaru.dart';

class PreviewCard extends StatefulWidget {
  PreviewCard({
    required this.filePath,
    required this.toggleSelection,
    required this.selected,
    required this.isAnythingSelected,
  }) : super(key: ValueKey('PreviewCard$filePath'));

  final String filePath;
  final bool selected;
  final bool isAnythingSelected;
  final void Function(String, bool) toggleSelection;

  @override
  State<PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<PreviewCard> {
  static const _cardRadius = 14.0;

  final expanded = ValueNotifier(false);
  final thumbnail = _ThumbnailState();

  @override
  void initState() {
    fileWriteSubscription = FileManager.fileWriteStream.stream.listen(
      fileWriteListener,
    );

    expanded.value = widget.selected;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      expanded.value = widget.selected;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final imageFile = FileManager.getFile(
      '${widget.filePath}${Editor.extension}.p',
    );
    if (isThisATest) {
      // Avoid FileImages in tests
      thumbnail.image = imageFile.existsSync()
          ? MemoryImage(imageFile.readAsBytesSync())
          : null;
    } else {
      thumbnail.image = FileImage(imageFile);
    }
  }

  StreamSubscription? fileWriteSubscription;
  void fileWriteListener(FileOperation event) {
    if (event.filePath != widget.filePath) return;
    if (event.type == .delete) {
      thumbnail.image = null;
    } else if (event.type == .write) {
      thumbnail.image?.evict();
      thumbnail.markAsChanged();
    } else {
      throw Exception('Unknown file operation type: ${event.type}');
    }
  }

  void _toggleCardSelection() {
    expanded.value = !expanded.value;
    widget.toggleSelection(widget.filePath, expanded.value);
  }

  Timer? _refreshThumbnailTimer;
  void _refreshThumbnailAfterDelay() {
    _refreshThumbnailTimer?.cancel();
    _refreshThumbnailTimer = Timer(const Duration(milliseconds: 500), () {
      thumbnail.image?.evict();
      thumbnail.markAsChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final transitionDuration = Duration(
      milliseconds: disableAnimations ? 0 : 300,
    );
    final invert = theme.brightness == .dark && stows.editorAutoInvert.value;

    final Widget card = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isAnythingSelected ? _toggleCardSelection : null,
        onSecondaryTap: _toggleCardSelection,
        onLongPress: _toggleCardSelection,
        child: Column(
          mainAxisSize: stows.simplifiedHomeLayout.value ? .max : .min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              fit: stows.simplifiedHomeLayout.value ? .tight : .loose,
              child: Stack(
                children: [
                  Positioned.fill(
                    top: _cardRadius,
                    left: kYaruFocusBorderWidth,
                    right: kYaruFocusBorderWidth,
                    child: ColoredBox(
                      color: InnerCanvas.defaultBackgroundColor.withInversion(
                        invert,
                      ),
                    ),
                  ),
                  ListenableBuilder(
                    listenable: thumbnail,
                    builder: (context, _) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: ConstrainedBox(
                        key: ValueKey(thumbnail.updateCount),
                        constraints: const BoxConstraints(
                          minWidth: double.infinity,
                          minHeight: 112,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: kYaruFocusBorderWidth,
                            left: kYaruFocusBorderWidth,
                            right: kYaruFocusBorderWidth,
                          ),
                          child: ClipRRect(
                            borderRadius: const .only(
                              topLeft: .circular(
                                _cardRadius - kYaruFocusBorderWidth,
                              ),
                              topRight: .circular(
                                _cardRadius - kYaruFocusBorderWidth,
                              ),
                            ),
                            child: InvertWidget(
                              invert: invert,
                              child: thumbnail.doesImageExist
                                  ? Image(
                                      image: thumbnail.image!,
                                      alignment: .topCenter,
                                      fit: .cover,
                                    )
                                  : _FallbackThumbnail(
                                      filePath: widget.filePath,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    left: -1,
                    top: -1,
                    right: -1,
                    bottom: -1,
                    child: ValueListenableBuilder(
                      valueListenable: expanded,
                      builder: (context, expanded, child) => AnimatedOpacity(
                        opacity: expanded ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: !expanded,
                          child: child!,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: _toggleCardSelection,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: .topCenter,
                              end: .bottomCenter,
                              colors: [
                                colorScheme.primary.withValues(alpha: 0.14),
                                colorScheme.surface.withValues(alpha: 0.75),
                                colorScheme.surface.withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SyncIndicator(filePath: widget.filePath),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
              ),
              child: Text(
                widget.filePath.substring(widget.filePath.lastIndexOf('/') + 1),
                maxLines: 2,
                overflow: .ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final openContainerWidget = ValueListenableBuilder(
      valueListenable: expanded,
      builder: (context, expanded, _) {
        return OpenContainer(
          clipBehavior: Clip.none,
          closedColor: colorScheme.surface,
          closedShape: RoundedRectangleBorder(
            side: BorderSide(
              color: expanded
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.45),
              width: expanded ? kYaruFocusBorderWidth : 1.0,
            ),
            borderRadius: const .all(.circular(_cardRadius)),
          ),
          closedElevation: 0,
          closedBuilder: (context, action) => card,
          openColor: colorScheme.surface,
          openBuilder: (context, action) => Editor(path: widget.filePath),
          transitionDuration: transitionDuration,
          routeSettings: RouteSettings(
            name: RoutePaths.editFilePath(widget.filePath),
          ),
          onClosed: (_) => _refreshThumbnailAfterDelay(),
        );
      },
    );

    final String displayName = widget.filePath.substring(
      widget.filePath.lastIndexOf('/') + 1,
    );

    final feedbackWidget = Material(
      color: Colors.transparent,
      elevation: 8,
      borderRadius: BorderRadius.circular(_cardRadius),
      child: SizedBox(
        width: 140,
        height: 180,
        child: Transform.scale(
          scale: 0.9,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(_cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_cardRadius),
              child: Column(
                children: [
                  Expanded(
                    child: thumbnail.doesImageExist
                        ? Image(
                            image: thumbnail.image!,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          )
                        : _FallbackThumbnail(filePath: widget.filePath),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    color: colorScheme.surfaceContainerHigh,
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return LongPressDraggable<String>(
      data: widget.filePath,
      delay: const Duration(milliseconds: 200),
      feedback: feedbackWidget,
      childWhenDragging: Opacity(opacity: 0.4, child: openContainerWidget),
      child: openContainerWidget,
    );
  }

  @override
  void dispose() {
    _refreshThumbnailTimer?.cancel();
    fileWriteSubscription?.cancel();
    super.dispose();
  }
}

class _FallbackThumbnail extends StatelessWidget {
  const _FallbackThumbnail({this.filePath});

  final String? filePath;

  static const _notebookCoverColors = <Color>[
    Color(0xFF2B4C7E), // Royal Moleskine Navy
    Color(0xFF2E6F56), // Forest Sage
    Color(0xFF8C3A3A), // Wine Burgundy
    Color(0xFF7A4F82), // Plum Moleskine
    Color(0xFF8D5B2C), // Saddle Leather
    Color(0xFF37474F), // Slate Charcoal
    Color(0xFF1B6B76), // Deep Teal
  ];

  @override
  Widget build(BuildContext context) {
    if (stows.opennoteUiMode.value && filePath != null) {
      final name = filePath!.substring(filePath!.lastIndexOf('/') + 1);
      final colorIdx = filePath.hashCode.abs() % _notebookCoverColors.length;
      final coverColor = _notebookCoverColors[colorIdx];

      return DecoratedBox(
        decoration: BoxDecoration(
          color: coverColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14.0 - kYaruFocusBorderWidth),
            topRight: Radius.circular(14.0 - kYaruFocusBorderWidth),
          ),
        ),
        child: Stack(
          children: [
            // Left Spine Band with crease gradient
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: 14,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.28),
                      Colors.black.withValues(alpha: 0.14),
                    ],
                  ),
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            // Top Ribbon Bookmark Peek
            Positioned(
              top: 0,
              right: 20,
              width: 12,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            // Centered Notebook Label Card
            Center(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 20,
                  right: 14,
                  top: 16,
                  bottom: 16,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFBF7),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFFDCD6CA),
                    width: 0.75,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2A29),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ColoredBox(
      color: InnerCanvas.defaultBackgroundColor,
      child: Center(
        child: Text(
          t.home.noPreviewAvailable,
          style: TextTheme.of(context).bodyMedium?.copyWith(
            color: Stroke.defaultColor.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ThumbnailState extends ChangeNotifier {
  var updateCount = 0;
  ImageProvider? _image;

  void markAsChanged() {
    ++updateCount;
    notifyListeners();
  }

  ImageProvider? get image => _image;
  set image(ImageProvider? image) {
    _image = image;
    markAsChanged();
  }

  bool get doesImageExist => switch (image) {
    (final FileImage fileImage) => fileImage.file.existsSync(),
    null => false,
    _ => true,
  };
}
