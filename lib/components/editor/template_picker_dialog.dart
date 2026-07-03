/// 🤖 Generated with DeepSeek v4 Flash
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/canvas_background_preview.dart';
import 'package:saber/components/canvas/inner_canvas.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/extensions/list_extensions.dart';
import 'package:saber/data/tools/page_templates.dart';
import 'package:saber/i18n/strings.g.dart';

/// A dialog that displays available page templates for the user to choose from.
///
/// Each template is shown as a card with a small preview of its background
/// pattern and the template name. When the user taps a template, the dialog
/// calls [onTemplateSelected] with the chosen template and closes.
class TemplatePickerDialog extends StatelessWidget {
  const TemplatePickerDialog({
    super.key,
    required this.coreInfo,
    required this.currentPageIndex,
    required this.invert,
    required this.onTemplateSelected,
  });

  /// Core editor info used to render previews.
  final EditorCoreInfo coreInfo;

  /// The current page index, used to render accurate previews.
  final int? currentPageIndex;

  /// Whether to render the preview inverted.
  final bool invert;

  /// Called when the user selects a template.
  final ValueChanged<PageTemplate> onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    final page = coreInfo.pages.getOrNull(currentPageIndex ?? -1);
    final pageSize = page?.size ?? EditorPage.defaultSize;

    return AlertDialog(
      title: Text(t.editor.menu.templates),
      content: SizedBox(
        width: 400,
        child: GridView.extent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          childAspectRatio: 0.85,
          children: [
            for (final template in PageTemplate.all)
              _TemplateCard(
                template: template,
                pageSize: pageSize,
                invert: invert,
                backgroundColor:
                    coreInfo.backgroundColor ?? InnerCanvas.defaultBackgroundColor,
                onTap: () {
                  onTemplateSelected(template);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.common.cancel),
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.pageSize,
    required this.invert,
    required this.backgroundColor,
    required this.onTap,
  });

  final PageTemplate template;
  final Size pageSize;
  final bool invert;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: CanvasBackgroundPreview.fixedWidth,
              height: pageSize.height / pageSize.width
                  * CanvasBackgroundPreview.fixedWidth,
              child: CanvasBackgroundPreview(
                selected: false,
                invert: invert,
                backgroundColor: backgroundColor,
                backgroundPattern: template.backgroundPattern,
                backgroundImage: null,
                pageSize: pageSize,
                lineHeight: template.lineHeight,
                lineThickness: template.lineThickness,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            template.name,
            style: TextTheme.of(context).bodyMedium,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
