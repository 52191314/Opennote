/// 🤖 Generated wholely or partially with Google Antigravity
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';

/// Standard padding shared by primary dock icon buttons.
const opennoteToolbarButtonPadding = EdgeInsets.symmetric(
  horizontal: 4,
  vertical: 3,
);

/// Vertical divider separating logical tool groups inside the toolbar capsules.
class ToolbarGroupDivider extends StatelessWidget {
  const ToolbarGroupDivider({super.key, required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 1,
      height: 18,
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

/// Compact pill button for selecting quick eraser preset sizes.
class EraserQuickSizeButton extends StatelessWidget {
  const EraserQuickSizeButton({
    super.key,
    required this.label,
    required this.size,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? colorScheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
