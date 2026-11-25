/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/monetization/paywall_models.dart';
import 'package:saber/components/monetization/pro_badge.dart';

/// Lightweight contextual bottom sheet for in-flow "Pro Moment" upsells.
///
/// Highlights the exact locked feature the user tapped, lists 3 crisp benefits,
/// and offers a 1-tap free trial CTA alongside a low-friction "Not Now" exit.
class ProFeatureGateSheet extends StatelessWidget {
  /// Creates a [ProFeatureGateSheet].
  const ProFeatureGateSheet({
    super.key,
    required this.paywallContext,
    this.ctaLabel = 'Try Pro Free for 7 Days',
    this.trialDisclosure = r'7 days free, then $29.99/yr · Cancel anytime',
    this.onTryPro,
    this.onComparePlans,
    this.onDismiss,
  });

  /// Contextual copy and benefits describing the locked Pro capability.
  final PaywallContext paywallContext;

  /// Primary call-to-action label.
  final String ctaLabel;

  /// Transparent billing disclosure shown below the CTA.
  final String trialDisclosure;

  /// Invoked when the user taps the primary "Try Pro Free" CTA.
  final VoidCallback? onTryPro;

  /// Optional callback to open the full plan comparison paywall.
  final VoidCallback? onComparePlans;

  /// Invoked when the user taps "Not Now" or closes the sheet.
  final VoidCallback? onDismiss;

  /// Presents [ProFeatureGateSheet] as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required PaywallContext paywallContext,
    String ctaLabel = 'Try Pro Free for 7 Days',
    String trialDisclosure = r'7 days free, then $29.99/yr · Cancel anytime',
    VoidCallback? onTryPro,
    VoidCallback? onComparePlans,
    VoidCallback? onDismiss,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => ProFeatureGateSheet(
        paywallContext: paywallContext,
        ctaLabel: ctaLabel,
        trialDisclosure: trialDisclosure,
        onTryPro: () {
          Navigator.of(sheetContext).pop();
          onTryPro?.call();
        },
        onComparePlans: onComparePlans == null
            ? null
            : () {
                Navigator.of(sheetContext).pop();
                onComparePlans();
              },
        onDismiss: () {
          Navigator.of(sheetContext).pop();
          onDismiss?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF91A7FF) : OpennoteTokens.brandSeed;
    final previewBenefits = paywallContext.highlights.take(3).toList();

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          OpennoteTokens.s5,
          OpennoteTokens.s3,
          OpennoteTokens.s5,
          OpennoteTokens.s5,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant.withValues(alpha: 0.55),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(OpennoteTokens.radiusPill),
                      ),
                    ),
                    child: const SizedBox(width: 36, height: 4),
                  ),
                ),
                const SizedBox(height: OpennoteTokens.s4),
                Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(OpennoteTokens.radiusMd),
                        ),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.30),
                        ),
                      ),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          paywallContext.lockedFeatureIcon ??
                              Icons.workspace_premium_rounded,
                          color: accent,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: OpennoteTokens.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ProBadge(label: 'OPENNOTE PRO', showIcon: true),
                          const SizedBox(height: 4),
                          Text(
                            paywallContext.lockedFeatureName ??
                                paywallContext.headline,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OpennoteTokens.s3),
                Text(
                  paywallContext.subheadline,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: OpennoteTokens.s4),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: isDark
                        ? OpennoteTokens.cardDarkSurface
                        : OpennoteTokens.studioLightSurface,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(OpennoteTokens.radiusMd),
                    ),
                    border: Border.fromBorderSide(
                      OpennoteTokens.subtleBorder(scheme, isDark ? 0.32 : 0.24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(OpennoteTokens.s4),
                    child: Column(
                      children: [
                        for (var i = 0; i < previewBenefits.length; i++) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18,
                                color: accent,
                              ),
                              const SizedBox(width: OpennoteTokens.s3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      previewBenefits[i].title,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: scheme.onSurface,
                                          ),
                                    ),
                                    Text(
                                      previewBenefits[i].subtitle,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (i < previewBenefits.length - 1)
                            const SizedBox(height: OpennoteTokens.s3),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: OpennoteTokens.s5),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    key: const Key('pro_gate_try_button'),
                    onPressed: onTryPro,
                    style: FilledButton.styleFrom(
                      backgroundColor: OpennoteTokens.brandSeed,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(OpennoteTokens.radiusMd),
                        ),
                      ),
                    ),
                    child: Text(
                      ctaLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: OpennoteTokens.s2),
                Text(
                  trialDisclosure,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: OpennoteTokens.s2),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: OpennoteTokens.s2,
                  runSpacing: OpennoteTokens.s1,
                  children: [
                    if (onComparePlans != null)
                      TextButton(
                        key: const Key('pro_gate_compare_button'),
                        onPressed: onComparePlans,
                        child: const Text('Compare all plans'),
                      ),
                    TextButton(
                      key: const Key('pro_gate_dismiss_button'),
                      onPressed:
                          onDismiss ?? () => Navigator.of(context).maybePop(),
                      child: const Text('Not Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
