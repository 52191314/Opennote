/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/toolbar/bottom_sheet/sheet_primitives.dart';
import 'package:saber/i18n/strings.g.dart';

/// Clean Export Hub section inside [EditorBottomSheet] providing quick access
/// to PDF, Vector/SVG (with Pro hook), Image, Print, and Share actions.
class ExportHubSection extends StatelessWidget {
  const ExportHubSection({
    super.key,
    this.onExport,
    this.onExportPdf,
    this.onExportSvg,
    this.onExportImage,
    this.onPrint,
    this.onShare,
    this.isPro = false,
    this.onProFeatureRequested,
  });

  final VoidCallback? onExport;
  final VoidCallback? onExportPdf;
  final VoidCallback? onExportSvg;
  final VoidCallback? onExportImage;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;
  final bool isPro;
  final void Function(String featureId)? onProFeatureRequested;

  void _trigger(BuildContext context, VoidCallback? callback) {
    if (callback == null) return;
    Navigator.maybePop(context);
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final pdfCallback = onExportPdf ?? onExport;
    final imageCallback = onExportImage ?? onExport;
    final printCallback = onPrint ?? onExport;
    final shareCallback = onShare ?? onExport;
    final svgGated = !isPro && onProFeatureRequested != null;
    final svgCallback = svgGated
        ? () => onProFeatureRequested!('export_vector_svg')
        : (onExportSvg ?? onExport);

    final items = <_ExportAction>[
      _ExportAction(
        key: const ValueKey('export_hub_pdf'),
        icon: Icons.picture_as_pdf_rounded,
        label: 'PDF',
        color: colorScheme.primary,
        onTap: pdfCallback != null
            ? () => _trigger(context, pdfCallback)
            : null,
      ),
      _ExportAction(
        key: const ValueKey('export_hub_svg'),
        icon: Icons.polyline_rounded,
        label: 'SVG',
        color: colorScheme.tertiary,
        showProBadge: svgGated,
        onTap: svgCallback != null
            ? () {
                if (svgGated) {
                  svgCallback();
                } else {
                  _trigger(context, svgCallback);
                }
              }
            : null,
      ),
      _ExportAction(
        key: const ValueKey('export_hub_image'),
        icon: Icons.image_rounded,
        label: 'Image',
        color: colorScheme.secondary,
        onTap: imageCallback != null
            ? () => _trigger(context, imageCallback)
            : null,
      ),
      _ExportAction(
        key: const ValueKey('export_hub_print'),
        icon: Icons.print_rounded,
        label: 'Print',
        color: colorScheme.onSurfaceVariant,
        onTap: printCallback != null
            ? () => _trigger(context, printCallback)
            : null,
      ),
      _ExportAction(
        key: const ValueKey('export_hub_share'),
        icon: Icons.ios_share_rounded,
        label: 'Share',
        color: colorScheme.primary,
        onTap: shareCallback != null
            ? () => _trigger(context, shareCallback)
            : null,
      ),
    ];

    return StudioSectionCard(
      title: t.editor.toolbar.export,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;
          final columns = isCompact ? 3 : 5;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: isCompact ? 1.15 : 0.95,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return BentoActionCard(
                key: item.key,
                icon: item.icon,
                label: item.label,
                color: item.color,
                enabled: item.onTap != null,
                showProBadge: item.showProBadge,
                onTap: item.onTap,
              );
            },
          );
        },
      ),
    );
  }
}

class _ExportAction {
  const _ExportAction({
    required this.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.showProBadge = false,
  });

  final Key key;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool showProBadge;
}
