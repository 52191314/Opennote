/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';

/// Top-of-settings membership hero card for Opennote Pro.
///
/// Displays an active Pro membership status card when [isPro] is true, or an
/// inviting 7-day free trial upgrade card when [isPro] is false.
class ProMembershipCard extends StatelessWidget {
  const ProMembershipCard({
    super.key,
    this.isPro = false,
    this.planSummary,
    this.onUpgradeTap,
    this.onRestorePurchasesTap,
    this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 8),
  });

  /// Whether the user currently holds an active Opennote Pro entitlement.
  final bool isPro;

  /// Optional short description of the active plan or trial status.
  final String? planSummary;

  /// Called when the user taps the primary upgrade or manage subscription CTA.
  final VoidCallback? onUpgradeTap;

  /// Called when the user taps "Restore Purchases".
  final VoidCallback? onRestorePurchasesTap;

  /// Outer padding around the card.
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: margin,
      child: Material(
        key: const ValueKey('opennote-pro-membership-card'),
        color: isDark
            ? OpennoteTokens.cardDarkSurface
            : OpennoteTokens.cardLightSurface,
        borderRadius: BorderRadius.circular(OpennoteTokens.radiusMd + 2),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OpennoteTokens.radiusMd + 2),
            border: Border.all(
              color: isPro
                  ? colorScheme.primary.withValues(alpha: isDark ? 0.55 : 0.4)
                  : colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.28),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPro
                  ? [
                      colorScheme.primary.withValues(
                        alpha: isDark ? 0.22 : 0.09,
                      ),
                      colorScheme.surfaceContainerLow.withValues(alpha: 0.4),
                    ]
                  : [
                      colorScheme.primary.withValues(
                        alpha: isDark ? 0.18 : 0.07,
                      ),
                      colorScheme.secondaryContainer.withValues(
                        alpha: isDark ? 0.16 : 0.22,
                      ),
                    ],
            ),
            boxShadow: OpennoteTokens.cardShadow(colorScheme.brightness),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: isPro
                ? _ProActiveContent(
                    planSummary: planSummary,
                    onManageTap: onUpgradeTap,
                  )
                : _FreeUpgradeContent(
                    planSummary: planSummary,
                    onUpgradeTap: onUpgradeTap,
                    onRestorePurchasesTap: onRestorePurchasesTap,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ProActiveContent extends StatelessWidget {
  const _ProActiveContent({
    required this.planSummary,
    required this.onManageTap,
  });

  final String? planSummary;
  final VoidCallback? onManageTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _BrandIconBadge(
              icon: Icons.workspace_premium_rounded,
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Opennote Pro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      DecoratedBox(
                        key: const ValueKey('pro-active-badge'),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(
                            OpennoteTokens.radiusPill,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Text(
                            'PRO ACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    planSummary ??
                        'Unlimited drafting tools, high-res exports, and studio templates unlocked.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          key: const ValueKey('pro-manage-button'),
          onPressed: onManageTap,
          icon: const Icon(Icons.tune_rounded, size: 16),
          label: const Text('Manage Subscription'),
        ),
      ],
    );
  }
}

class _FreeUpgradeContent extends StatelessWidget {
  const _FreeUpgradeContent({
    required this.planSummary,
    required this.onUpgradeTap,
    required this.onRestorePurchasesTap,
  });

  final String? planSummary;
  final VoidCallback? onUpgradeTap;
  final VoidCallback? onRestorePurchasesTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BrandIconBadge(
              icon: Icons.auto_awesome_rounded,
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlock Opennote Pro · 7-Day Free Trial',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    planSummary ??
                        'Precision drafting tools, unlimited cloud templates, and crisp vector PDF exports.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              key: const ValueKey('pro-upgrade-button'),
              onPressed: onUpgradeTap,
              icon: const Icon(Icons.rocket_launch_rounded, size: 16),
              label: const Text('Start 7-Day Free Trial'),
            ),
            TextButton(
              key: const ValueKey('pro-card-restore-button'),
              onPressed: onRestorePurchasesTap,
              child: const Text('Restore Purchases'),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandIconBadge extends StatelessWidget {
  const _BrandIconBadge({required this.icon, required this.colorScheme});

  final IconData icon;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(OpennoteTokens.radiusSm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 22, color: colorScheme.primary),
      ),
    );
  }
}
