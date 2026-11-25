/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';

/// A consistent studio header for bottom sheets and modal dialogs.
///
/// Renders an optional top drag handle, title, optional subtitle, optional
/// leading/trailing widgets, a crisp close action, and a hairline divider.
class OpennoteSheetHeader extends StatelessWidget {
  /// Creates an [OpennoteSheetHeader].
  const OpennoteSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onClose,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.showDivider = true,
    this.closeTooltip = 'Close',
    this.padding = const EdgeInsets.fromLTRB(
      OpennoteTokens.s5,
      OpennoteTokens.s3,
      OpennoteTokens.s4,
      OpennoteTokens.s3,
    ),
  });

  /// Primary title displayed in the sheet header.
  final String title;

  /// Optional supporting subtitle beneath [title].
  final String? subtitle;

  /// Optional leading icon or badge before [title].
  final Widget? leading;

  /// Optional custom trailing widget placed before the close button.
  final Widget? trailing;

  /// Callback invoked when the close button is tapped.
  ///
  /// When [showCloseButton] is `true` and [onClose] is null, tapping the close
  /// button calls `Navigator.maybePop(context)`.
  final VoidCallback? onClose;

  /// Whether to display the centered studio drag handle above the header row.
  final bool showDragHandle;

  /// Whether to show the circular hairline close button.
  final bool showCloseButton;

  /// Whether to draw a crisp `1px` bottom hairline divider.
  final bool showDivider;

  /// Tooltip and semantic label for the close button.
  final String closeTooltip;

  /// Padding around the title row.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDragHandle)
          Padding(
            padding: const EdgeInsets.only(top: OpennoteTokens.s2 + 2),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.28),
                  borderRadius: OpennoteTokens.borderRadiusPill,
                ),
              ),
            ),
          ),
        Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: OpennoteTokens.s3),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: OpennoteTokens.s0_5),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: OpennoteTokens.s2),
                trailing!,
              ],
              if (showCloseButton) ...[
                const SizedBox(width: OpennoteTokens.s2),
                _SheetCloseButton(
                  tooltip: closeTooltip,
                  onTap: onClose ?? () => Navigator.of(context).maybePop(),
                ),
              ],
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: OpennoteTokens.hairlineWidth,
            color: OpennoteTokens.hairlineColor(colorScheme),
          ),
      ],
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: OpennoteTokens.subtleSurface(colorScheme.brightness),
        shape: CircleBorder(side: OpennoteTokens.hairlineBorder(colorScheme)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
