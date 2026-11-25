/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';

/// A crisp studio section header with an optional subtitle and trailing action.
class OpennoteSectionHeader extends StatelessWidget {
  /// Creates an [OpennoteSectionHeader].
  const OpennoteSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actionLabel,
    this.onAction,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(
      horizontal: OpennoteTokens.s1,
      vertical: OpennoteTokens.s2,
    ),
  });

  /// Section heading text.
  final String title;

  /// Optional supporting description beneath [title].
  final String? subtitle;

  /// Optional leading icon or badge before [title].
  final Widget? leading;

  /// Optional text label for a compact trailing action button.
  final String? actionLabel;

  /// Callback invoked when the trailing [actionLabel] button is tapped.
  final VoidCallback? onAction;

  /// Custom trailing widget; takes precedence over [actionLabel] if provided.
  final Widget? trailing;

  /// Outer padding around the header row.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);

    Widget? resolvedTrailing = trailing;
    if (resolvedTrailing == null && actionLabel != null) {
      resolvedTrailing = TextButton(
        onPressed: onAction,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: OpennoteTokens.s2 + 2,
            vertical: OpennoteTokens.s1,
          ),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const RoundedRectangleBorder(
            borderRadius: OpennoteTokens.borderRadiusSm,
          ),
        ),
        child: Text(
          actionLabel!,
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: onAction != null
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: OpennoteTokens.s2),
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
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.15,
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
          if (resolvedTrailing != null) ...[
            const SizedBox(width: OpennoteTokens.s2),
            resolvedTrailing,
          ],
        ],
      ),
    );
  }
}
