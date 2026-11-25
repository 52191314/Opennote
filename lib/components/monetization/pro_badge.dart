/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';

/// Visual size preset for [ProBadge].
enum ProBadgeSize {
  /// Ultra-compact micro pill for inline toolbars and list tiles.
  compact,

  /// Standard pill for headers, banners, and feature gate sheets.
  standard,
}

/// Tasteful `PRO` micro-pill badge aligned with Opennote's studio aesthetic.
class ProBadge extends StatelessWidget {
  /// Creates a [ProBadge].
  const ProBadge({
    super.key,
    this.label = 'PRO',
    this.size = ProBadgeSize.standard,
    this.showIcon = false,
  });

  /// Short uppercase label rendered inside the pill.
  final String label;

  /// Sizing preset for compact vs standard surfaces.
  final ProBadgeSize size;

  /// Whether to show a subtle leading sparkle/star icon.
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final isCompact = size == ProBadgeSize.compact;

    final backgroundColor = isDark
        ? OpennoteTokens.brandSeed.withValues(alpha: 0.24)
        : OpennoteTokens.brandSeed.withValues(alpha: 0.12);
    final borderColor = isDark
        ? const Color(0xFF748FFC).withValues(alpha: 0.45)
        : OpennoteTokens.brandSeed.withValues(alpha: 0.30);
    final foregroundColor = isDark
        ? const Color(0xFFBAC8FF)
        : OpennoteTokens.brandSeed;

    return Semantics(
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(OpennoteTokens.radiusPill),
          ),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 6 : 8,
            vertical: isCompact ? 2 : 3,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                Icon(
                  Icons.auto_awesome_rounded,
                  size: isCompact ? 10 : 12,
                  color: foregroundColor,
                ),
                const SizedBox(width: 3),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: isCompact ? 10 : 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sleek status pill showing remaining free-trial days or active Pro status.
class TrialCountdownPill extends StatelessWidget {
  /// Creates a [TrialCountdownPill].
  const TrialCountdownPill({
    super.key,
    required this.daysRemaining,
    this.onTap,
  });

  /// Number of days remaining in the free trial.
  ///
  /// Values `<= 0` render an ending-today urgency message.
  final int daysRemaining;

  /// Optional tap callback (e.g. to open subscription management or paywall).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final isUrgent = daysRemaining <= 2;

    final accentColor = isUrgent
        ? (isDark ? const Color(0xFFFFB74D) : const Color(0xFFD97706))
        : (isDark ? const Color(0xFF8CE99A) : const Color(0xFF15803D));
    final backgroundColor = accentColor.withValues(alpha: isDark ? 0.18 : 0.11);
    final borderColor = accentColor.withValues(alpha: isDark ? 0.42 : 0.28);

    final label = switch (daysRemaining) {
      <= 0 => 'Trial ends today',
      1 => '1 day left in trial',
      _ => '$daysRemaining days left in trial',
    };

    final chip = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(OpennoteTokens.radiusPill),
        ),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: OpennoteTokens.s2 + 2,
          vertical: OpennoteTokens.s1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: const SizedBox(width: 6, height: 6),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return chip;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(
          Radius.circular(OpennoteTokens.radiusPill),
        ),
        child: chip,
      ),
    );
  }
}
