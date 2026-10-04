/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';

/// An iPadOS / Goodnotes-styled toolbar button featuring soft rounded pill
/// backgrounds, refined primary accent indicators, and ergonomic touch states.
class ToolbarIconButton extends StatelessWidget {
  const ToolbarIconButton({
    super.key,
    this.tooltip,
    this.selected = false,
    this.enabled = true,
    required this.onPressed,
    this.onLongPress,
    required this.padding,
    required this.child,
  });

  final String? tooltip;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    final backgroundColor = WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.disabled)) {
        return Colors.transparent;
      }
      if (states.contains(WidgetState.selected)) {
        return colorScheme.primaryContainer.withValues(alpha: 0.7);
      }
      if (states.contains(WidgetState.hovered)) {
        return colorScheme.onSurface.withValues(alpha: 0.06);
      }
      if (states.contains(WidgetState.pressed)) {
        return colorScheme.onSurface.withValues(alpha: 0.12);
      }
      return Colors.transparent;
    });

    final foregroundColor = WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.disabled)) {
        return colorScheme.onSurface.withValues(alpha: 0.35);
      }
      if (states.contains(WidgetState.selected)) {
        return colorScheme.primary;
      }
      return colorScheme.onSurfaceVariant.withValues(alpha: 0.85);
    });

    final shape = WidgetStateProperty.all<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    final buttonStyle = ButtonStyle(
      backgroundColor: backgroundColor,
      iconColor: foregroundColor,
      foregroundColor: foregroundColor,
      shape: shape,
      iconSize: const WidgetStatePropertyAll(19),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: const WidgetStatePropertyAll(Size(38, 38)),
    );

    Widget buttonContent = child;
    if (selected) {
      buttonContent = Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            bottom: -5,
            child: Container(
              width: 14,
              height: 2.5,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: padding,
        child: IconButton.filled(
          style: buttonStyle,
          onPressed: enabled ? onPressed : null,
          tooltip: tooltip,
          isSelected: selected,
          icon: buttonContent,
        ),
      ),
    );
  }
}
