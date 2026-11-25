/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/monetization/pro_badge.dart';

/// Compact, high-craft Opennote Pro status and upgrade banner for Home and
/// Settings surfaces.
class ProUpgradeBanner extends StatelessWidget {
  /// Creates a [ProUpgradeBanner].
  const ProUpgradeBanner({
    super.key,
    this.isPro = false,
    this.trialDaysRemaining,
    this.activePlanLabel,
    this.isCompact = false,
    this.onTap,
    this.onDismiss,
  });

  /// Whether the user currently holds an active Opennote Pro entitlement.
  final bool isPro;

  /// Remaining free-trial days when the user is on an active trial.
  final int? trialDaysRemaining;

  /// Optional subscribed plan label (e.g. `Annual Plan`, `Lifetime Pro`).
  final String? activePlanLabel;

  /// Uses a tighter single-row layout suited for Home headers or sidebars.
  final bool isCompact;

  /// Invoked when the banner is tapped (e.g. open paywall or manage plan).
  final VoidCallback? onTap;

  /// Optional dismiss callback shown only for free-tier banners.
  final VoidCallback? onDismiss;

  bool get _isInTrial => trialDaysRemaining != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF91A7FF) : OpennoteTokens.brandSeed;

    final backgroundColor = isDark
        ? OpennoteTokens.cardDarkSurface
        : OpennoteTokens.cardLightSurface;
    final borderColor = (isPro || _isInTrial)
        ? scheme.outlineVariant.withValues(alpha: isDark ? 0.36 : 0.28)
        : accent.withValues(alpha: isDark ? 0.42 : 0.30);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('pro_upgrade_banner'),
        onTap: onTap,
        borderRadius: const BorderRadius.all(
          Radius.circular(OpennoteTokens.radiusMd),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(OpennoteTokens.radiusMd),
            ),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: OpennoteTokens.cardShadow(scheme.brightness),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              isCompact ? OpennoteTokens.s3 : OpennoteTokens.s4,
            ),
            child: _isInTrial
                ? _buildTrialContent(theme, scheme, accent)
                : isPro
                ? _buildProActiveContent(theme, scheme)
                : _buildFreeUpgradeContent(theme, scheme, accent),
          ),
        ),
      ),
    );
  }

  Widget _buildFreeUpgradeContent(
    ThemeData theme,
    ColorScheme scheme,
    Color accent,
  ) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            borderRadius: const BorderRadius.all(
              Radius.circular(OpennoteTokens.radiusSm),
            ),
          ),
          child: SizedBox(
            width: isCompact ? 36 : 42,
            height: isCompact ? 36 : 42,
            child: Icon(
              Icons.workspace_premium_rounded,
              color: accent,
              size: isCompact ? 20 : 22,
            ),
          ),
        ),
        const SizedBox(width: OpennoteTokens.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Upgrade to Opennote Pro · 7 Days Free',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const ProBadge(size: ProBadgeSize.compact),
                ],
              ),
              if (!isCompact) ...[
                const SizedBox(height: 3),
                Text(
                  'Engineering templates, precision drafting, vector export & cloud sync.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: OpennoteTokens.s2),
        if (onDismiss != null)
          IconButton(
            key: const Key('pro_banner_dismiss_button'),
            tooltip: 'Dismiss',
            onPressed: onDismiss,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
          )
        else
          Icon(Icons.chevron_right_rounded, color: accent),
      ],
    );
  }

  Widget _buildTrialContent(ThemeData theme, ColorScheme scheme, Color accent) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: OpennoteTokens.s2,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const ProBadge(label: 'PRO TRIAL', showIcon: true),
                  TrialCountdownPill(daysRemaining: trialDaysRemaining!),
                ],
              ),
              if (!isCompact) ...[
                const SizedBox(height: OpennoteTokens.s2),
                Text(
                  'All Opennote Pro tools are unlocked. Manage or switch plans anytime.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: OpennoteTokens.s2),
        Icon(Icons.chevron_right_rounded, color: accent),
      ],
    );
  }

  Widget _buildProActiveContent(ThemeData theme, ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final successColor = isDark
        ? const Color(0xFF8CE99A)
        : const Color(0xFF15803D);

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: successColor.withValues(alpha: 0.14),
            borderRadius: const BorderRadius.all(
              Radius.circular(OpennoteTokens.radiusSm),
            ),
          ),
          child: SizedBox(
            width: isCompact ? 34 : 40,
            height: isCompact ? 34 : 40,
            child: Icon(Icons.verified_rounded, color: successColor, size: 20),
          ),
        ),
        const SizedBox(width: OpennoteTokens.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Opennote Pro Active',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const ProBadge(size: ProBadgeSize.compact),
                ],
              ),
              if (activePlanLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  activePlanLabel!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onTap != null)
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
      ],
    );
  }
}
