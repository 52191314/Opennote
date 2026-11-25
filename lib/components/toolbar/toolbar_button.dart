/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';

/// An Opennote Studio toolbar button featuring a crisp active-tool halo,
/// soft rounded pill states, and ergonomic touch targets across phone and iPad.
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
        return colorScheme.primaryContainer.withValues(alpha: 0.92);
      }
      if (states.contains(WidgetState.hovered)) {
        return colorScheme.onSurface.withValues(alpha: 0.07);
      }
      if (states.contains(WidgetState.pressed)) {
        return colorScheme.onSurface.withValues(alpha: 0.13);
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
      return colorScheme.onSurfaceVariant.withValues(alpha: 0.88);
    });

    final side = WidgetStateProperty.resolveWith<BorderSide>((states) {
      if (states.contains(WidgetState.selected)) {
        return BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.42),
          width: 1.15,
        );
      }
      return BorderSide.none;
    });

    final shape = WidgetStateProperty.all<OutlinedBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    final buttonStyle = ButtonStyle(
      backgroundColor: backgroundColor,
      iconColor: foregroundColor,
      foregroundColor: foregroundColor,
      side: side,
      shape: shape,
      visualDensity: VisualDensity.standard,
      iconSize: const WidgetStatePropertyAll(19),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: const WidgetStatePropertyAll(Size(34, 34)),
    );

    final Widget buttonContent = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          bottom: -5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            width: selected ? 14 : 0,
            height: 2.5,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: padding,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.18),
                      blurRadius: 8,
                      spreadRadius: 0.5,
                    ),
                  ]
                : null,
          ),
          child: IconButton.filled(
            style: buttonStyle,
            onPressed: enabled ? onPressed : null,
            tooltip: tooltip,
            isSelected: selected,
            icon: buttonContent,
          ),
        ),
      ),
    );
  }
}
