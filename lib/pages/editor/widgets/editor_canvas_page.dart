/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/canvas.dart';
import 'package:saber/components/canvas/canvas_image.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/change_notifier_extensions.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/shape_pen.dart';

/// Renders a single editor page [Canvas] wired to the active stroke notifier
/// and selection action callbacks.
class EditorCanvasPage extends StatelessWidget {
  /// Creates an [EditorCanvasPage].
  const EditorCanvasPage({
    super.key,
    required this.coreInfo,
    required this.page,
    required this.pageIndex,
    required this.activeStrokeNotifier,
    required this.currentTool,
    required this.currentScale,
    required this.actions,
    required this.onDeleteSelection,
    required this.onTakeScreenshot,
    required this.onBackgroundImageChanged,
    this.foreground,
    this.viewportRect,
  });

  /// Document core info.
  final EditorCoreInfo coreInfo;

  /// The page model being rendered.
  final EditorPage page;

  /// Zero-based index of [page] in [coreInfo].
  final int pageIndex;

  /// Live in-flight stroke notifier.
  final ValueListenable<Stroke?> activeStrokeNotifier;

  /// Currently selected editor tool singleton.
  final Tool currentTool;

  /// Current canvas zoom scale.
  final double currentScale;

  /// Shared editor toolbar/selection action callbacks.
  final EditorToolbarActions actions;

  /// Deletes the active selection on [page].
  final void Function(Select select, EditorPage page) onDeleteSelection;

  /// Captures a screenshot of the current selection.
  final VoidCallback onTakeScreenshot;

  /// Triggered after an image is promoted to the page background.
  final VoidCallback onBackgroundImageChanged;

  /// Optional overlay rendered above the page canvas (e.g. zoom window box).
  final Widget? foreground;

  /// Visible viewport rect in page coordinates for infinite-canvas culling.
  final Rect? viewportRect;

  /// Builds a lightweight placeholder [Canvas] for offscreen pages.
  static Widget buildPlaceholder({
    required EditorCoreInfo coreInfo,
    required int pageIndex,
    required Tool currentTool,
  }) => Canvas(
    path: coreInfo.filePath,
    page: coreInfo.pages[pageIndex],
    pageIndex: 0,
    textEditing: false,
    coreInfo: EditorCoreInfo.placeholder,
    currentStroke: null,
    currentStrokeDetectedShape: null,
    currentSelection: null,
    placeholder: true,
    setAsBackground: null,
    currentTool: currentTool,
    currentScale: double.minPositive,
  );

  @override
  Widget build(BuildContext context) {
    final select = currentTool is Select ? currentTool as Select : null;
    final isCurrentPageSelected = select?.selectResult.pageIndex == pageIndex;

    return ValueListenableBuilder<Stroke?>(
      valueListenable: activeStrokeNotifier,
      builder: (context, activeStroke, _) {
        final effectiveStroke = activeStroke ?? Pen.currentStroke;
        final currentStroke = effectiveStroke?.pageIndex == pageIndex
            ? effectiveStroke
            : null;

        return Canvas(
          path: coreInfo.filePath,
          page: page,
          pageIndex: pageIndex,
          textEditing: currentTool == Tool.textEditing,
          coreInfo: coreInfo,
          currentStroke: currentStroke,
          currentStrokeDetectedShape:
              currentTool is ShapePen && currentStroke != null
              ? ShapePen.detectedShape
              : null,
          currentSelection: isCurrentPageSelected ? select?.selectResult : null,
          isDoneSelecting:
              isCurrentPageSelected && (select?.doneSelecting ?? false),
          onCutSelection: isCurrentPageSelected ? actions.cutSelection : null,
          onCopySelection: isCurrentPageSelected ? actions.copySelection : null,
          onDuplicateSelection: isCurrentPageSelected
              ? actions.duplicateSelection
              : null,
          onDeleteSelection: isCurrentPageSelected
              ? () {
                  if (select != null) onDeleteSelection(select, page);
                }
              : null,
          onSetColor: isCurrentPageSelected ? actions.onSetColor : null,
          isResizeActive:
              isCurrentPageSelected && (select?.isResizeActive ?? false),
          onToggleResize: isCurrentPageSelected ? actions.toggleResize : null,
          onReduceTextSize: isCurrentPageSelected
              ? actions.reduceSelectionSize
              : null,
          onEnlargeTextSize: isCurrentPageSelected
              ? actions.enlargeSelectionSize
              : null,
          onTakeScreenshot: isCurrentPageSelected ? onTakeScreenshot : null,
          onAddToElements: isCurrentPageSelected ? actions.addToElements : null,
          onBringToFront: isCurrentPageSelected ? actions.bringToFront : null,
          onSendToBack: isCurrentPageSelected ? actions.sendToBack : null,
          onSmoothen: isCurrentPageSelected ? actions.smoothen : null,
          cropPossible: isCurrentPageSelected && actions.cropPossible,
          cropActive: isCurrentPageSelected && actions.cropActive,
          onToggleCrop: isCurrentPageSelected ? actions.toggleCrop : null,
          setAsBackground: _setAsBackground,
          currentTool: currentTool,
          currentScale: currentScale,
          foreground: foreground,
          viewportRect: viewportRect,
        );
      },
    );
  }

  void _setAsBackground(EditorImage image) {
    if (page.backgroundImage != null) {
      page.images.add(page.backgroundImage!);
    }
    page.images.remove(image);
    page.backgroundImage = image;
    CanvasImage.activeListener.notifyListenersPlease();
    onBackgroundImageChanged();
  }
}
