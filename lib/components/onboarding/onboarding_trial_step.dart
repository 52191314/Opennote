/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/onboarding/onboarding_models.dart';
import 'package:saber/i18n/strings.g.dart';

/// Step 4 ethical soft-paywall presenting a transparent 7-day Opennote Pro trial.
class OnboardingTrialStep extends StatelessWidget {
  /// Creates the Step 4 trial conversion screen.
  const OnboardingTrialStep({
    super.key,
    required this.persona,
    required this.selectedPlanSku,
    required this.onPlanSelected,
    required this.onStartTrial,
    required this.onContinueFree,
    this.onRestorePurchases,
    this.onOpenTerms,
    this.onOpenPrivacy,
    this.isBusy = false,
  });

  /// Persona chosen in Step 2 used to tailor the value proposition.
  final OnboardingPersona persona;

  /// Currently highlighted subscription SKU.
  final String selectedPlanSku;

  /// Invoked when the user switches between Annual and Monthly plans.
  final ValueChanged<String> onPlanSelected;

  /// Invoked when the user taps the primary free-trial CTA.
  final VoidCallback onStartTrial;

  /// Invoked when the user chooses the zero-pressure Free tier option.
  final VoidCallback onContinueFree;

  /// Optional callback for restoring previous store purchases.
  final VoidCallback? onRestorePurchases;

  /// Optional callback to open Terms of Service.
  final VoidCallback? onOpenTerms;

  /// Optional callback to open Privacy Policy.
  final VoidCallback? onOpenPrivacy;

  /// Disables actions while a purchase or restore call is in flight.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAnnual = selectedPlanSku == OnboardingPlanSku.annual;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 400;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 20 : 28,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    child: Text(
                      'OPENNOTE PRO • 7-DAY FREE TRIAL',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Try Opennote Pro Free for 7 Days',
                textAlign: TextAlign.center,
                style:
                    (isCompact
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.headlineMedium)
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
              ),
              const SizedBox(height: 6),
              Text(
                persona.trialHeadline,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              _TrialTimelineCard(benefits: persona.trialBenefits),
              const SizedBox(height: 14),
              _PlanSelectorRow(
                selectedPlanSku: selectedPlanSku,
                onPlanSelected: onPlanSelected,
                stackVertically: isCompact,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: isBusy ? null : onStartTrial,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isAnnual
                            ? 'Start 7-Day Free Trial'
                            : 'Start Pro Monthly',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Text(
                isAnnual
                    ? 'Free for 7 days, then \$29.99/yr (\$2.50/mo). Cancel anytime.'
                    : '\$4.99/mo billed monthly. Cancel anytime.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: isBusy ? null : onContinueFree,
                  child: Text(t.onboarding.flow.continueWithFree),
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  TextButton(
                    onPressed: isBusy ? null : onRestorePurchases,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      textStyle: theme.textTheme.labelSmall,
                    ),
                    child: Text(t.onboarding.flow.restorePurchases),
                  ),
                  Text(
                    '•',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  TextButton(
                    onPressed: isBusy ? null : onOpenTerms,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      textStyle: theme.textTheme.labelSmall,
                    ),
                    child: Text(t.onboarding.flow.terms),
                  ),
                  Text(
                    '•',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  TextButton(
                    onPressed: isBusy ? null : onOpenPrivacy,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      textStyle: theme.textTheme.labelSmall,
                    ),
                    child: Text(t.onboarding.flow.privacy),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrialTimelineCard extends StatelessWidget {
  const _TrialTimelineCard({required this.benefits});

  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimelineItem(
              icon: Icons.lock_open_rounded,
              title: t.onboarding.flow.timelineTodayTitle,
              subtitle: 'Every Pro tool unlocked with \$0 due today.',
            ),
            const SizedBox(height: 8),
            _TimelineItem(
              icon: Icons.notifications_active_outlined,
              title: t.onboarding.flow.timelineDay5Title,
              subtitle: t.onboarding.flow.timelineDay5Subtitle,
            ),
            const SizedBox(height: 8),
            _TimelineItem(
              icon: Icons.verified_outlined,
              title: t.onboarding.flow.timelineDay7Title,
              subtitle: t.onboarding.flow.timelineDay7Subtitle,
            ),
            Divider(
              height: 20,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            for (var i = 0; i < benefits.length; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefits[i],
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanSelectorRow extends StatelessWidget {
  const _PlanSelectorRow({
    required this.selectedPlanSku,
    required this.onPlanSelected,
    required this.stackVertically,
  });

  final String selectedPlanSku;
  final ValueChanged<String> onPlanSelected;
  final bool stackVertically;

  @override
  Widget build(BuildContext context) {
    final annualCard = _PlanOptionCard(
      title: t.onboarding.flow.annual,
      priceLabel: '\$29.99/yr',
      subPriceLabel: '\$2.50/mo • 7-day free trial',
      badge: 'SAVE 50%',
      isSelected: selectedPlanSku == OnboardingPlanSku.annual,
      onTap: () => onPlanSelected(OnboardingPlanSku.annual),
    );

    final monthlyCard = _PlanOptionCard(
      title: t.onboarding.flow.monthly,
      priceLabel: '\$4.99/mo',
      subPriceLabel: 'Flexible monthly billing',
      isSelected: selectedPlanSku == OnboardingPlanSku.monthly,
      onTap: () => onPlanSelected(OnboardingPlanSku.monthly),
    );

    if (stackVertically) {
      return Column(
        children: [annualCard, const SizedBox(height: 10), monthlyCard],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: annualCard),
          const SizedBox(width: 10),
          Expanded(child: monthlyCard),
        ],
      ),
    );
  }
}

class _PlanOptionCard extends StatelessWidget {
  const _PlanOptionCard({
    required this.title,
    required this.priceLabel,
    required this.subPriceLabel,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String priceLabel;
  final String subPriceLabel;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title $priceLabel',
      child: Material(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.4)
            : colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.7),
            width: isSelected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Text(
                            badge!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  priceLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subPriceLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
