/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Modified with Claude Code (Claude Sonnet 5.5)
/// 🤖 Modified with Grok 4.7
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/editor/template_picker_dialog.dart';
import 'package:saber/components/toolbar/bottom_sheet/document_actions_section.dart';
import 'package:saber/components/toolbar/bottom_sheet/export_hub_section.dart';
import 'package:saber/components/toolbar/bottom_sheet/paper_template_section.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/list_extensions.dart';
import 'package:saber/data/tools/page_templates.dart';
import 'package:sbn/canvas_background_pattern.dart';

/// Modular studio bottom sheet for Opennote's editor: quick actions bento grid,
/// visual paper & template picker, export hub, and document/media actions.
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
    this.onExportPdf,
    this.onExportSvg,
    this.onExportImage,
    this.onPrint,
    this.onShare,
    this.onInsertPage,
    this.onOpenPageGrid,
    this.onToggleDarkModePreview,
    this.isPro = false,
    this.onProFeatureRequested,
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
  final VoidCallback? onExportPdf;
  final VoidCallback? onExportSvg;
  final VoidCallback? onExportImage;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;
  final VoidCallback? onInsertPage;
  final VoidCallback? onOpenPageGrid;
  final VoidCallback? onToggleDarkModePreview;
  final bool isPro;
  final void Function(String featureId)? onProFeatureRequested;
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
    final page = widget.coreInfo.pages.getOrNull(widget.currentPageIndex ?? -1);
    final pageSize = page?.size ?? EditorPage.defaultSize;
    final hasBackgroundImage = page?.backgroundImage != null;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 12),
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
            QuickActionsBentoSection(
              coreInfo: widget.coreInfo,
              currentPageIndex: widget.currentPageIndex,
              onOpenTemplatePicker: _showTemplatePicker,
              clearPage: widget.clearPage,
              clearAllPages: widget.clearAllPages,
              redrawAndSave: widget.redrawAndSave,
              onOpenPresentation: widget.onOpenPresentation,
              onOpenFlashcards: widget.onOpenFlashcards,
              onFitContent: widget.onFitContent,
              onExport: widget.onExport,
            ),
            const SizedBox(height: 14),
            if (hasBackgroundImage) ...[
              BackgroundImageSection(
                invert: widget.invert,
                coreInfo: widget.coreInfo,
                page: page!,
                pageSize: pageSize,
                redrawImage: widget.redrawImage,
                redrawAndSave: widget.redrawAndSave,
                removeBackgroundImage: widget.removeBackgroundImage,
              ),
              const SizedBox(height: 14),
            ],
            PaperTemplateSection(
              invert: widget.invert,
              coreInfo: widget.coreInfo,
              page: page,
              pageSize: pageSize,
              setBackgroundPattern: widget.setBackgroundPattern,
              setLineHeight: widget.setLineHeight,
              setLineThickness: widget.setLineThickness,
              setInfiniteCanvas: widget.setInfiniteCanvas,
              redrawAndSave: widget.redrawAndSave,
              setPageSize: widget.setPageSize,
              onOpenTemplatePicker: _showTemplatePicker,
              isPro: widget.isPro,
              onProFeatureRequested: widget.onProFeatureRequested,
            ),
            const SizedBox(height: 14),
            ExportHubSection(
              onExport: widget.onExport,
              onExportPdf: widget.onExportPdf,
              onExportSvg: widget.onExportSvg,
              onExportImage: widget.onExportImage,
              onPrint: widget.onPrint,
              onShare: widget.onShare,
              isPro: widget.isPro,
              onProFeatureRequested: widget.onProFeatureRequested,
            ),
            const SizedBox(height: 14),
            DocumentActionsSection(
              invert: widget.invert,
              pickPhotos: widget.pickPhotos,
              importPdf: widget.importPdf,
              addStickyNote: widget.addStickyNote,
              addSticker: widget.addSticker,
              canRasterPdf: widget.canRasterPdf,
              getIsWatchingServer: widget.getIsWatchingServer,
              setIsWatchingServer: widget.setIsWatchingServer,
              onInsertPage: widget.onInsertPage,
              onOpenPageGrid: widget.onOpenPageGrid,
              onToggleDarkModePreview: widget.onToggleDarkModePreview,
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
