/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';

/// Descriptor for a single segment item in an [OpennoteSegmentedBar].
class OpennoteSegmentItem<T> {
  /// Creates an [OpennoteSegmentItem].
  const OpennoteSegmentItem({
    required this.value,
    this.label,
    this.icon,
    this.tooltip,
  }) : assert(
         label != null || icon != null,
         'Either label or icon must be provided.',
       );

  /// The value represented by this segment.
  final T value;

  /// Optional text label displayed inside the segment.
  final String? label;

  /// Optional icon displayed inside the segment.
  final IconData? icon;

  /// Optional tooltip message for accessibility and hover.
  final String? tooltip;
}

/// A tactile animated segmented pill control for switching views, tabs, or filters.
class OpennoteSegmentedBar<T> extends StatelessWidget {
  /// Creates an [OpennoteSegmentedBar].
  const OpennoteSegmentedBar({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onChanged,
    this.compact = false,
  });

  /// The list of segments to display.
  final List<OpennoteSegmentItem<T>> segments;

  /// The currently selected segment value.
  final T selectedValue;

  /// Callback invoked when the user selects a segment.
  final ValueChanged<T> onChanged;

  /// Whether to use compact padding and typography.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;
    final trackRadius = BorderRadius.circular(OpennoteTokens.radiusSm);
    final thumbRadius = BorderRadius.circular(OpennoteTokens.radiusXs + 2);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.55 : 0.65,
        ),
        borderRadius: trackRadius,
        border: Border.fromBorderSide(
          OpennoteTokens.subtleBorder(colorScheme, 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            for (final segment in segments)
              _SegmentButton<T>(
                segment: segment,
                isSelected: segment.value == selectedValue,
                compact: compact,
                thumbRadius: thumbRadius,
                onTap: () => onChanged(segment.value),
              ),
          ],
        ),
      ),
    );
  }
}

class _SegmentButton<T> extends StatelessWidget {
  const _SegmentButton({
    required this.segment,
    required this.isSelected,
    required this.compact,
    required this.thumbRadius,
    required this.onTap,
  });

  final OpennoteSegmentItem<T> segment;
  final bool isSelected;
  final bool compact;
  final BorderRadius thumbRadius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;
    final fgColor = isSelected
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;
    final bgColor = isSelected
        ? (isDark
              ? OpennoteTokens.cardDarkSurface
              : OpennoteTokens.cardLightSurface)
        : Colors.transparent;

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: thumbRadius,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: thumbRadius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? OpennoteTokens.s2 : OpennoteTokens.s3,
              vertical: compact ? 5 : 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                if (segment.icon != null)
                  Icon(
                    segment.icon,
                    size: compact ? 15 : 17,
                    color: isSelected ? colorScheme.primary : fgColor,
                  ),
                if (segment.label != null)
                  Text(
                    segment.label!,
                    style: TextTheme.of(context).labelMedium?.copyWith(
                      fontSize: compact ? 12 : 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: fgColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (segment.tooltip != null) {
      button = Tooltip(message: segment.tooltip!, child: button);
    }

    return button;
  }
}
