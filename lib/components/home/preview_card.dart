/// 🤖 Generated wholely or partially with Claude Code; Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/home/preview_card/preview_card_footer.dart';
import 'package:saber/components/home/preview_card/preview_selection_overlay.dart';
import 'package:saber/components/home/preview_card/preview_thumbnail_state.dart';
import 'package:saber/components/home/preview_card/preview_thumbnail_surface.dart';
import 'package:saber/components/home/sync_indicator.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/file_manager/item_drag_state.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/pages/editor/editor.dart';

const _focusBorderWidth = 2.0;

/// Displays a notebook cover / page preview card with selection overlay,
/// drag-and-drop support, and contextual actions.
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
  static const _cardRadius = OpennoteTokens.radiusMd;

  final expanded = ValueNotifier(false);
  final thumbnail = PreviewThumbnailState();
  StreamSubscription? _fileWriteSubscription;
  Timer? _refreshThumbnailTimer;

  @override
  void initState() {
    _fileWriteSubscription = FileManager.fileWriteStream.stream.listen(
      _onFileWrite,
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
    thumbnail.bindFile(imageFile, isMounted: () => mounted);
  }

  void _onFileWrite(FileOperation event) {
    if (event.filePath != widget.filePath) return;
    if (event.type == .delete) {
      thumbnail.setImage(null, exists: false);
    } else if (event.type == .write) {
      thumbnail.refresh(isMounted: () => mounted);
    } else {
      throw Exception('Unknown file operation type: ${event.type}');
    }
  }

  void _toggleCardSelection() {
    expanded.value = !expanded.value;
    widget.toggleSelection(widget.filePath, expanded.value);
  }

  void _refreshThumbnailAfterDelay() {
    _refreshThumbnailTimer?.cancel();
    _refreshThumbnailTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      thumbnail.refresh(isMounted: () => mounted);
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
    final displayName = widget.filePath.substring(
      widget.filePath.lastIndexOf('/') + 1,
    );

    final card = MouseRegion(
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
                  PreviewThumbnailSurface(
                    filePath: widget.filePath,
                    thumbnail: thumbnail,
                    invert: invert,
                    cardRadius: _cardRadius,
                    borderWidth: _focusBorderWidth,
                  ),
                  PreviewSelectionOverlay(
                    selectedListenable: expanded,
                    onTap: _toggleCardSelection,
                  ),
                  SyncIndicator(filePath: widget.filePath),
                ],
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: expanded,
              builder: (context, isSelected, _) => PreviewCardFooter(
                filePath: widget.filePath,
                displayName: displayName,
                subtitle: PreviewThumbnailState.folderLabelFor(widget.filePath),
                isSelected: isSelected,
                onToggleSelection: _toggleCardSelection,
              ),
            ),
          ],
        ),
      ),
    );

    final openContainerWidget = ValueListenableBuilder<bool>(
      valueListenable: expanded,
      builder: (context, isSelected, _) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(_cardRadius)),
          boxShadow: OpennoteTokens.cardShadow(colorScheme.brightness),
        ),
        child: OpenContainer(
          clipBehavior: Clip.none,
          closedColor: colorScheme.brightness == Brightness.dark
              ? OpennoteTokens.cardDarkSurface
              : OpennoteTokens.cardLightSurface,
          closedShape: RoundedRectangleBorder(
            side: BorderSide(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.42),
              width: isSelected ? _focusBorderWidth : 1.0,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(_cardRadius)),
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
        ),
      ),
    );

    return RepaintBoundary(
      child: LongPressDraggable<String>(
        data: widget.filePath,
        delay: const Duration(milliseconds: 200),
        onDragStarted: () => ItemDragState.startDrag(widget.filePath),
        onDragEnd: (_) => ItemDragState.endDrag(),
        onDraggableCanceled: (_, _) => ItemDragState.endDrag(),
        onDragCompleted: () => ItemDragState.endDrag(),
        feedback: PreviewDragFeedback(
          filePath: widget.filePath,
          displayName: displayName,
          thumbnail: thumbnail,
          cardRadius: _cardRadius,
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: openContainerWidget),
        child: openContainerWidget,
      ),
    );
  }

  @override
  void dispose() {
    _refreshThumbnailTimer?.cancel();
    _fileWriteSubscription?.cancel();
    expanded.dispose();
    thumbnail.dispose();
    super.dispose();
  }
}
