/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/editor/layer_manager.dart';
import 'package:saber/components/editor/sticker_picker.dart';
import 'package:saber/components/toolbar/bottom_sheet/sheet_primitives.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/extensions/list_extensions.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';

/// Quick-action bento grid (Presentation, Flashcards, Layers, Templates,
/// Clear Page, Clear All, Fit Content, Export) inside [EditorBottomSheet].
class QuickActionsBentoSection extends StatelessWidget {
  const QuickActionsBentoSection({
    super.key,
    required this.coreInfo,
    required this.currentPageIndex,
    required this.onOpenTemplatePicker,
    required this.clearPage,
    required this.clearAllPages,
    required this.redrawAndSave,
    this.onOpenPresentation,
    this.onOpenFlashcards,
    this.onFitContent,
    this.onExport,
  });

  final EditorCoreInfo coreInfo;
  final int? currentPageIndex;
  final VoidCallback onOpenTemplatePicker;
  final VoidCallback clearPage;
  final VoidCallback clearAllPages;
  final VoidCallback redrawAndSave;
  final VoidCallback? onOpenPresentation;
  final VoidCallback? onOpenFlashcards;
  final VoidCallback? onFitContent;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return StudioSectionCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 330;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isNarrow ? 2 : 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: isNarrow ? 1.55 : 0.95,
            children: [
              BentoActionCard(
                icon: Icons.present_to_all,
                label: t.editor.sheet.presentation,
                enabled: onOpenPresentation != null,
                onTap: () {
                  Navigator.pop(context);
                  onOpenPresentation?.call();
                },
              ),
              BentoActionCard(
                icon: Icons.auto_stories,
                label: t.editor.sheet.flashcards,
                enabled: onOpenFlashcards != null,
                onTap: () {
                  Navigator.pop(context);
                  onOpenFlashcards?.call();
                },
              ),
              BentoActionCard(
                icon: Icons.layers,
                label: t.editor.layers.title,
                onTap: () {
                  final page = coreInfo.pages.getOrNull(currentPageIndex ?? -1);
                  if (page == null) return;
                  showDialog(
                    context: context,
                    builder: (_) =>
                        LayerManager(page: page, onChanged: redrawAndSave),
                  );
                },
              ),
              BentoActionCard(
                icon: Icons.auto_awesome,
                label: t.editor.menu.templates,
                onTap: onOpenTemplatePicker,
              ),
              BentoActionCard(
                icon: Icons.cleaning_services,
                label: t.editor.menu.clearPage(
                  page: currentPageIndex == null ? '?' : currentPageIndex! + 1,
                  totalPages: coreInfo.pages.length,
                ),
                color: colorScheme.error,
                enabled: coreInfo.isNotEmpty,
                onTap: () {
                  clearPage();
                  Navigator.pop(context);
                },
              ),
              BentoActionCard(
                icon: Icons.cleaning_services,
                label: t.editor.menu.clearAllPages,
                color: colorScheme.error,
                enabled: coreInfo.isNotEmpty,
                onTap: () {
                  clearAllPages();
                  Navigator.pop(context);
                },
              ),
              BentoActionCard(
                icon: Icons.fit_screen_rounded,
                label: t.editor.canvasHud.fitContent,
                enabled: onFitContent != null,
                onTap: () {
                  Navigator.pop(context);
                  onFitContent?.call();
                },
              ),
              BentoActionCard(
                icon: Icons.ios_share,
                label: t.editor.toolbar.export,
                enabled: onExport != null,
                onTap: () {
                  Navigator.pop(context);
                  onExport?.call();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Page & Document Actions plus Media Import section for [EditorBottomSheet].
class DocumentActionsSection extends StatelessWidget {
  const DocumentActionsSection({
    super.key,
    required this.invert,
    required this.pickPhotos,
    required this.importPdf,
    required this.addStickyNote,
    required this.addSticker,
    required this.canRasterPdf,
    required this.getIsWatchingServer,
    required this.setIsWatchingServer,
    this.onInsertPage,
    this.onOpenPageGrid,
    this.onToggleDarkModePreview,
  });

  final bool invert;
  final Future<int> Function() pickPhotos;
  final Future<bool> Function() importPdf;
  final VoidCallback addStickyNote;
  final void Function(String emoji) addSticker;
  final bool canRasterPdf;
  final bool Function() getIsWatchingServer;
  final void Function(bool) setIsWatchingServer;
  final VoidCallback? onInsertPage;
  final VoidCallback? onOpenPageGrid;
  final VoidCallback? onToggleDarkModePreview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final actionButtonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
      foregroundColor: colorScheme.onSurface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StudioSectionCard(
          title: t.editor.menu.import,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (onInsertPage != null)
                    ElevatedButton.icon(
                      key: const ValueKey('doc_action_insert_page'),
                      style: actionButtonStyle,
                      onPressed: () {
                        Navigator.maybePop(context);
                        onInsertPage!();
                      },
                      icon: const Icon(Icons.note_add_outlined, size: 17),
                      label: const Text('Insert Page'),
                    ),
                  if (onOpenPageGrid != null)
                    ElevatedButton.icon(
                      key: const ValueKey('doc_action_page_grid'),
                      style: actionButtonStyle,
                      onPressed: () {
                        Navigator.maybePop(context);
                        onOpenPageGrid!();
                      },
                      icon: const Icon(Icons.grid_view_rounded, size: 17),
                      label: const Text('Page Grid'),
                    ),
                  ElevatedButton.icon(
                    style: actionButtonStyle,
                    onPressed: () async {
                      final photosPicked = await pickPhotos();
                      if (photosPicked > 0) {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.photo_outlined, size: 17),
                    label: Text(t.editor.toolbar.photo),
                  ),
                  if (canRasterPdf)
                    ElevatedButton.icon(
                      style: actionButtonStyle,
                      onPressed: () async {
                        final pdfImported = await importPdf();
                        if (pdfImported) {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 17),
                      label: const Text('PDF'),
                    ),
                  ElevatedButton.icon(
                    style: actionButtonStyle,
                    onPressed: () {
                      addStickyNote();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.sticky_note_2_outlined, size: 17),
                    label: Text(t.editor.sheet.stickyNote),
                  ),
                  ElevatedButton.icon(
                    style: actionButtonStyle,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            StickerPickerDialog(onStickerSelected: addSticker),
                      );
                    },
                    icon: const Icon(Icons.emoji_emotions_outlined, size: 17),
                    label: Text(t.editor.sheet.sticker),
                  ),
                ],
              ),
              if (onToggleDarkModePreview != null) ...[
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  key: const ValueKey('doc_action_dark_preview'),
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    invert ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  title: const Text(
                    'Dark Mode Preview',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: invert,
                  onChanged: (_) => onToggleDarkModePreview!(),
                ),
              ],
            ],
          ),
        ),
        if (stows.loggedIn) ...[
          const SizedBox(height: 14),
          StudioSectionCard(
            child: StatefulBuilder(
              builder: (context, setState) {
                final isWatchingServer = getIsWatchingServer();
                return CheckboxListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: isWatchingServer,
                  title: Text(t.editor.menu.watchServer),
                  subtitle: isWatchingServer
                      ? Text(t.editor.menu.watchServerReadOnly)
                      : null,
                  onChanged: (value) => setState(() {
                    setIsWatchingServer(value!);
                  }),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
