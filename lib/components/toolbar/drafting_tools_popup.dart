/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/arrow.dart';
import 'package:saber/data/tools/dimension.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:saber/i18n/strings.g.dart';

/// A sleek Goodnotes-style popup menu providing quick access to shapes,
/// the precision ruler, arrow strokes, and dimension lines.
class DraftingToolsPopup extends StatelessWidget {
  const DraftingToolsPopup({
    super.key,
    required this.currentTool,
    required this.onSelectTool,
    required this.onPickShape,
  });

  final Tool currentTool;
  final ValueChanged<Tool> onSelectTool;
  final VoidCallback onPickShape;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Shapes & Drafting',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              _DraftingOptionTile(
                icon: const FaIcon(FontAwesomeIcons.shapes, size: 16),
                title: 'Shape Library',
                subtitle: 'Insert geometric primitives & symbols',
                selected: false,
                onTap: () {
                  Navigator.of(context).pop();
                  onPickShape();
                },
              ),
              const SizedBox(height: 6),
              _DraftingOptionTile(
                icon: const FaIcon(Ruler.rulerIcon, size: 16),
                title: t.editor.pens.ruler,
                subtitle: 'On-screen straightedge guide',
                selected: currentTool is Ruler,
                onTap: () {
                  Navigator.of(context).pop();
                  onSelectTool(Ruler());
                },
              ),
              const SizedBox(height: 6),
              _DraftingOptionTile(
                icon: const Icon(Icons.arrow_right_alt, size: 20),
                title: 'Straight Arrow',
                subtitle: 'Direct pointer arrow',
                selected:
                    currentTool is ArrowTool &&
                    (currentTool as ArrowTool).connectorStyle ==
                        ConnectorStyle.straight,
                onTap: () {
                  Navigator.of(context).pop();
                  onSelectTool(
                    ArrowTool(connectorStyle: ConnectorStyle.straight),
                  );
                },
              ),
              const SizedBox(height: 6),
              _DraftingOptionTile(
                icon: const Icon(Icons.turn_right_rounded, size: 20),
                title: 'Elbow Connector',
                subtitle: 'Orthogonal stepped connector line',
                selected:
                    currentTool is ArrowTool &&
                    (currentTool as ArrowTool).connectorStyle ==
                        ConnectorStyle.elbow,
                onTap: () {
                  Navigator.of(context).pop();
                  onSelectTool(ArrowTool(connectorStyle: ConnectorStyle.elbow));
                },
              ),
              const SizedBox(height: 6),
              _DraftingOptionTile(
                icon: const Icon(Icons.gesture, size: 20),
                title: 'Curved Connector',
                subtitle: 'Smooth bezier spline connector',
                selected:
                    currentTool is ArrowTool &&
                    (currentTool as ArrowTool).connectorStyle ==
                        ConnectorStyle.curved,
                onTap: () {
                  Navigator.of(context).pop();
                  onSelectTool(
                    ArrowTool(connectorStyle: ConnectorStyle.curved),
                  );
                },
              ),
              const SizedBox(height: 6),
              _DraftingOptionTile(
                icon: const Icon(Icons.straighten, size: 18),
                title: 'Dimension Line',
                subtitle: 'Measured line with real-world dimensions',
                selected: currentTool is DimensionTool,
                onTap: () {
                  Navigator.of(context).pop();
                  onSelectTool(DimensionTool());
                },
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _DraftingOptionTile extends StatelessWidget {
  const _DraftingOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.7,
                      ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: IconTheme(
                data: IconThemeData(
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  size: 18,
                ),
                child: icon,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.75,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
