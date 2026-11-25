/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';

/// Supported one-tap quick-start notebook templates in [QuickTemplateStrip].
enum QuickTemplateKind {
  blankPage,
  engineeringGrid,
  dotMatrix,
  cornellStudy,
  infiniteCanvas,
  importPdf,
}

/// Metadata describing a single quick-start template card.
class QuickTemplateItem {
  const QuickTemplateItem({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    this.isPro = false,
  });

  final QuickTemplateKind kind;
  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final bool isPro;

  /// Canonical gallery of quick-start notebook templates.
  static const defaults = [
    QuickTemplateItem(
      kind: QuickTemplateKind.blankPage,
      title: 'Blank Page',
      subtitle: 'Clean studio sheet',
      accentColor: OpennoteTokens.brandSeed,
      icon: Icons.note_add_outlined,
    ),
    QuickTemplateItem(
      kind: QuickTemplateKind.engineeringGrid,
      title: 'Engineering Grid',
      subtitle: '5mm precision grid',
      accentColor: Color(0xFF1B6B76),
      icon: Icons.grid_4x4_rounded,
    ),
    QuickTemplateItem(
      kind: QuickTemplateKind.dotMatrix,
      title: 'Dot Matrix',
      subtitle: 'Bullet & sketch dots',
      accentColor: Color(0xFF2E6F56),
      icon: Icons.grain_rounded,
    ),
    QuickTemplateItem(
      kind: QuickTemplateKind.cornellStudy,
      title: 'Cornell Study',
      subtitle: 'Cues, notes & summary',
      accentColor: Color(0xFF8D5B2C),
      icon: Icons.view_sidebar_outlined,
    ),
    QuickTemplateItem(
      kind: QuickTemplateKind.infiniteCanvas,
      title: 'Infinite Canvas',
      subtitle: 'Boundless diagram board',
      accentColor: Color(0xFF6B4E84),
      icon: Icons.all_inclusive_rounded,
      isPro: true,
    ),
    QuickTemplateItem(
      kind: QuickTemplateKind.importPdf,
      title: 'Import PDF',
      subtitle: 'Annotate documents',
      accentColor: Color(0xFFB54738),
      icon: Icons.picture_as_pdf_outlined,
    ),
  ];
}

/// Horizontal quick-start gallery strip that lets users create a templated
/// notebook or import a PDF in one tap.
class QuickTemplateStrip extends StatelessWidget {
  const QuickTemplateStrip({
    super.key,
    this.createPath,
    this.onCreateTemplate,
    this.onProTemplateTap,
    this.onImportPdf,
    this.compact = false,
    this.showHeader = true,
  });

  /// Optional directory path in which new notebooks should be created.
  final String? createPath;

  /// Called when the user selects a free template (excluding Pro templates).
  final ValueChanged<QuickTemplateKind>? onCreateTemplate;

  /// Called when the user taps a Pro-badged template (e.g. Infinite Canvas)
  /// so integrators can route to the Opennote Pro paywall.
  final ValueChanged<QuickTemplateKind>? onProTemplateTap;

  /// Optional custom handler for the "Import PDF" card.
  final VoidCallback? onImportPdf;

  /// Uses a tighter height suitable for compact headers or empty-state cards.
  final bool compact;

  /// Whether to render the "Quick Start" section header above the strip.
  final bool showHeader;

  Future<void> _handleTap(BuildContext context, QuickTemplateItem item) async {
    if (item.isPro) {
      if (onProTemplateTap != null) {
        onProTemplateTap!(item.kind);
        return;
      }
      if (item.kind == QuickTemplateKind.infiniteCanvas) {
        context.go(HomeRoutes.getRoute(2));
        return;
      }
    }

    if (item.kind == QuickTemplateKind.importPdf) {
      if (onImportPdf != null) {
        onImportPdf!();
        return;
      }
      if (onCreateTemplate != null) {
        onCreateTemplate!(item.kind);
        return;
      }
      await _defaultImportPdf(context);
      return;
    }

    if (onCreateTemplate != null) {
      onCreateTemplate!(item.kind);
      return;
    }

    await _defaultCreateNote(context);
  }

  Future<void> _defaultCreateNote(BuildContext context) async {
    if (createPath == null || createPath!.isEmpty) {
      context.push(RoutePaths.edit);
      return;
    }
    final newFilePath = await FileManager.newFilePath('$createPath/');
    if (!context.mounted) return;
    context.push(RoutePaths.editFilePath(newFilePath));
  }

  Future<void> _defaultImportPdf(BuildContext context) async {
    if (!Editor.canRasterPdf) return;
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null) return;
    final filePath = result.files.single.path;
    final fileName = result.files.single.name;
    if (filePath == null) return;

    final baseName = fileName.toLowerCase().endsWith('.pdf')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;
    final sbnFilePath = await FileManager.suffixFilePathToMakeItUnique(
      '${createPath ?? ''}/$baseName',
    );
    if (!context.mounted) return;
    context.push(RoutePaths.editImportPdf(sbnFilePath, filePath));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final cardHeight = compact ? 104.0 : 122.0;
    final cardWidth = compact ? 124.0 : 138.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
            child: Row(
              children: [
                Text(
                  'Quick Start',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  t.home.create.newNote,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: QuickTemplateItem.defaults.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = QuickTemplateItem.defaults[index];
              return SizedBox(
                width: cardWidth,
                child: _QuickTemplateCard(
                  item: item,
                  compact: compact,
                  onTap: () => _handleTap(context, item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickTemplateCard extends StatelessWidget {
  const _QuickTemplateCard({
    required this.item,
    required this.compact,
    required this.onTap,
  });

  final QuickTemplateItem item;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;
    final surface = isDark
        ? OpennoteTokens.cardDarkSurface
        : OpennoteTokens.cardLightSurface;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(OpennoteTokens.radiusMd),
      child: InkWell(
        key: ValueKey('QuickTemplate_${item.kind.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(OpennoteTokens.radiusMd),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OpennoteTokens.radiusMd),
            border: Border.all(
              color: item.isPro
                  ? item.accentColor.withValues(alpha: isDark ? 0.55 : 0.35)
                  : colorScheme.outlineVariant.withValues(alpha: 0.36),
              width: 1,
            ),
            boxShadow: OpennoteTokens.cardShadow(colorScheme.brightness),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(OpennoteTokens.radiusMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: _TemplateMiniaturePainter(
                          kind: item.kind,
                          accentColor: item.accentColor,
                          isDark: isDark,
                        ),
                      ),
                      Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: item.accentColor.withValues(
                              alpha: isDark ? 0.24 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(
                              OpennoteTokens.radiusSm,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              item.icon,
                              size: compact ? 18 : 20,
                              color: item.accentColor,
                            ),
                          ),
                        ),
                      ),
                      if (item.isPro)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.accentColor,
                              borderRadius: BorderRadius.circular(
                                OpennoteTokens.radiusPill,
                              ),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: compact ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.24,
                        ),
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 1),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateMiniaturePainter extends CustomPainter {
  const _TemplateMiniaturePainter({
    required this.kind,
    required this.accentColor,
    required this.isDark,
  });

  final QuickTemplateKind kind;
  final Color accentColor;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF212329) : const Color(0xFFFAF9F6);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: isDark ? 0.22 : 0.16)
      ..strokeWidth = 0.8;

    switch (kind) {
      case QuickTemplateKind.blankPage:
        return;
      case QuickTemplateKind.engineeringGrid:
        const step = 12.0;
        for (double x = step; x < size.width; x += step) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
        }
        for (double y = step; y < size.height; y += step) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        }
      case QuickTemplateKind.dotMatrix:
        const step = 12.0;
        final dotPaint = Paint()
          ..color = accentColor.withValues(alpha: isDark ? 0.34 : 0.28);
        for (double x = step; x < size.width; x += step) {
          for (double y = step; y < size.height; y += step) {
            canvas.drawCircle(Offset(x, y), 1.1, dotPaint);
          }
        }
      case QuickTemplateKind.cornellStudy:
        final cueX = size.width * 0.28;
        final summaryY = size.height * 0.74;
        canvas.drawLine(Offset(cueX, 0), Offset(cueX, summaryY), linePaint);
        canvas.drawLine(
          Offset(0, summaryY),
          Offset(size.width, summaryY),
          linePaint,
        );
        for (double y = 14; y < summaryY; y += 11) {
          canvas.drawLine(
            Offset(cueX + 6, y),
            Offset(size.width - 8, y),
            linePaint,
          );
        }
      case QuickTemplateKind.infiniteCanvas:
        const step = 16.0;
        final dotPaint = Paint()
          ..color = accentColor.withValues(alpha: isDark ? 0.30 : 0.22);
        for (double x = step / 2; x < size.width; x += step) {
          for (double y = step / 2; y < size.height; y += step) {
            canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
          }
        }
      case QuickTemplateKind.importPdf:
        final docRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: size.center(Offset.zero),
            width: size.width * 0.44,
            height: size.height * 0.72,
          ),
          const Radius.circular(4),
        );
        canvas.drawRRect(docRect, linePaint..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _TemplateMiniaturePainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.isDark != isDark;
}
