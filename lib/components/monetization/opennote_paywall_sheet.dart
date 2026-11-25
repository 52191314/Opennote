/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/monetization/paywall_models.dart';
import 'package:saber/components/monetization/pro_badge.dart';

/// Flagship responsive subscription and IAP paywall for Opennote Pro.
///
/// Adapts across compact phone portrait, landscape, and tablet/desktop
/// viewports in both light and dark modes. Binds cleanly to any entitlement
/// backend via typed callbacks and immutable view-models.
class OpennotePaywallSheet extends StatefulWidget {
  /// Creates an [OpennotePaywallSheet].
  const OpennotePaywallSheet({
    super.key,
    required this.paywallContext,
    this.plans = OpennotePaywallDefaults.defaultPlans,
    this.initialSelectedPlanId,
    this.purchaseState = PaywallPurchaseState.idle,
    this.errorMessage,
    this.onSelectPlan,
    this.onPurchase,
    this.onRestore,
    this.onDismiss,
    this.onOpenTerms,
    this.onOpenPrivacy,
    this.onStudentDiscount,
  });

  /// Contextual headline, subheadline, and feature highlights for this trigger.
  final PaywallContext paywallContext;

  /// Available subscription and lifetime plans.
  final List<PaywallPlanViewModel> plans;

  /// Optional plan ID to pre-select; defaults to the first recommended plan.
  final String? initialSelectedPlanId;

  /// Current purchase or restore lifecycle state.
  final PaywallPurchaseState purchaseState;

  /// Optional inline error message displayed above the CTA button.
  final String? errorMessage;

  /// Invoked whenever the user taps a plan card.
  final ValueChanged<PaywallPlanViewModel>? onSelectPlan;

  /// Invoked when the user taps the primary purchase CTA button.
  final ValueChanged<PaywallPlanViewModel>? onPurchase;

  /// Invoked when the user taps "Restore Purchases".
  final VoidCallback? onRestore;

  /// Invoked when the user taps the close button.
  final VoidCallback? onDismiss;

  /// Invoked when the user taps "Terms".
  final VoidCallback? onOpenTerms;

  /// Invoked when the user taps "Privacy".
  final VoidCallback? onOpenPrivacy;

  /// Invoked when the user taps the subtle student discount link.
  final VoidCallback? onStudentDiscount;

  /// Presents [OpennotePaywallSheet] as a responsive full-screen sheet on
  /// phones and a centered studio dialog on tablets and desktops.
  static Future<void> show(
    BuildContext context, {
    required PaywallContext paywallContext,
    List<PaywallPlanViewModel> plans = OpennotePaywallDefaults.defaultPlans,
    String? initialSelectedPlanId,
    PaywallPurchaseState purchaseState = PaywallPurchaseState.idle,
    String? errorMessage,
    ValueChanged<PaywallPlanViewModel>? onSelectPlan,
    ValueChanged<PaywallPlanViewModel>? onPurchase,
    VoidCallback? onRestore,
    VoidCallback? onOpenTerms,
    VoidCallback? onOpenPrivacy,
    VoidCallback? onStudentDiscount,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth >= 680) {
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.all(OpennoteTokens.s6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880, maxHeight: 740),
            child: OpennotePaywallSheet(
              paywallContext: paywallContext,
              plans: plans,
              initialSelectedPlanId: initialSelectedPlanId,
              purchaseState: purchaseState,
              errorMessage: errorMessage,
              onSelectPlan: onSelectPlan,
              onPurchase: onPurchase,
              onRestore: onRestore,
              onDismiss: () => Navigator.of(dialogContext).maybePop(),
              onOpenTerms: onOpenTerms,
              onOpenPrivacy: onOpenPrivacy,
              onStudentDiscount: onStudentDiscount,
            ),
          ),
        ),
      );
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.96,
        child: OpennotePaywallSheet(
          paywallContext: paywallContext,
          plans: plans,
          initialSelectedPlanId: initialSelectedPlanId,
          purchaseState: purchaseState,
          errorMessage: errorMessage,
          onSelectPlan: onSelectPlan,
          onPurchase: onPurchase,
          onRestore: onRestore,
          onDismiss: () => Navigator.of(sheetContext).maybePop(),
          onOpenTerms: onOpenTerms,
          onOpenPrivacy: onOpenPrivacy,
          onStudentDiscount: onStudentDiscount,
        ),
      ),
    );
  }

  @override
  State<OpennotePaywallSheet> createState() => _OpennotePaywallSheetState();
}

class _OpennotePaywallSheetState extends State<OpennotePaywallSheet> {
  late String _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _selectedPlanId = _resolveInitialPlanId();
  }

  @override
  void didUpdateWidget(covariant OpennotePaywallSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    final stillExists = widget.plans.any((p) => p.id == _selectedPlanId);
    if (!stillExists) {
      _selectedPlanId = _resolveInitialPlanId();
    }
  }

  String _resolveInitialPlanId() {
    if (widget.initialSelectedPlanId != null &&
        widget.plans.any((p) => p.id == widget.initialSelectedPlanId)) {
      return widget.initialSelectedPlanId!;
    }
    for (final plan in widget.plans) {
      if (plan.isRecommended) return plan.id;
    }
    return widget.plans.isNotEmpty
        ? widget.plans.first.id
        : OpennotePaywallDefaults.defaultAnnualPlan.id;
  }

  PaywallPlanViewModel get _selectedPlan {
    for (final plan in widget.plans) {
      if (plan.id == _selectedPlanId) return plan;
    }
    return widget.plans.isNotEmpty
        ? widget.plans.first
        : OpennotePaywallDefaults.defaultAnnualPlan;
  }

  void _selectPlan(PaywallPlanViewModel plan) {
    if (plan.id == _selectedPlanId) return;
    setState(() => _selectedPlanId = plan.id);
    widget.onSelectPlan?.call(plan);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final surfaceBg = isDark
        ? OpennoteTokens.studioDarkSurface
        : OpennoteTokens.studioLightSurface;

    return ColoredBox(
      color: surfaceBg,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSplitTablet =
                constraints.maxWidth >= 760 && constraints.maxHeight >= 520;
            final isCompactHeight = constraints.maxHeight < 500;

            return Column(
              children: [
                _PaywallTopBar(
                  eyebrow: widget.paywallContext.eyebrow,
                  onDismiss: widget.onDismiss,
                ),
                Expanded(
                  child: isSplitTablet
                      ? _buildSplitTabletBody(context)
                      : _buildSingleColumnBody(
                          context,
                          maxContentWidth: constraints.maxWidth >= 600
                              ? 540
                              : double.infinity,
                          isCompactHeight: isCompactHeight,
                        ),
                ),
                _StickyPaywallFooter(
                  selectedPlan: _selectedPlan,
                  purchaseState: widget.purchaseState,
                  errorMessage: widget.errorMessage,
                  isCompactHeight: isCompactHeight,
                  onPurchase: () => widget.onPurchase?.call(_selectedPlan),
                  onRestore: widget.onRestore,
                  onOpenTerms: widget.onOpenTerms,
                  onOpenPrivacy: widget.onOpenPrivacy,
                  onStudentDiscount: widget.onStudentDiscount,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSingleColumnBody(
    BuildContext context, {
    required double maxContentWidth,
    required bool isCompactHeight,
  }) {
    final selectedPlan = _selectedPlan;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        OpennoteTokens.s5,
        isCompactHeight ? OpennoteTokens.s1 : OpennoteTokens.s2,
        OpennoteTokens.s5,
        OpennoteTokens.s5,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PaywallHeroHeader(
                paywallContext: widget.paywallContext,
                compact: isCompactHeight,
              ),
              SizedBox(
                height: isCompactHeight ? OpennoteTokens.s4 : OpennoteTokens.s5,
              ),
              _BenefitShowcase(highlights: widget.paywallContext.highlights),
              const SizedBox(height: OpennoteTokens.s4),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: selectedPlan.hasFreeTrial
                    ? Padding(
                        padding: const EdgeInsets.only(
                          bottom: OpennoteTokens.s4,
                        ),
                        child: _TrialTimelineCard(
                          trialDays: selectedPlan.freeTrialDays,
                          planTitle: selectedPlan.title,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              _PlanSelectorList(
                plans: widget.plans,
                selectedPlanId: selectedPlan.id,
                onSelect: _selectPlan,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitTabletBody(BuildContext context) {
    final selectedPlan = _selectedPlan;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        OpennoteTokens.s6,
        OpennoteTokens.s2,
        OpennoteTokens.s6,
        OpennoteTokens.s5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PaywallHeroHeader(
                  paywallContext: widget.paywallContext,
                  compact: false,
                  alignStart: true,
                ),
                const SizedBox(height: OpennoteTokens.s5),
                _BenefitShowcase(highlights: widget.paywallContext.highlights),
              ],
            ),
          ),
          const SizedBox(width: OpennoteTokens.s6),
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: selectedPlan.hasFreeTrial
                      ? Padding(
                          padding: const EdgeInsets.only(
                            bottom: OpennoteTokens.s4,
                          ),
                          child: _TrialTimelineCard(
                            trialDays: selectedPlan.freeTrialDays,
                            planTitle: selectedPlan.title,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                _PlanSelectorList(
                  plans: widget.plans,
                  selectedPlanId: selectedPlan.id,
                  onSelect: _selectPlan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaywallTopBar extends StatelessWidget {
  const _PaywallTopBar({required this.eyebrow, required this.onDismiss});

  final String eyebrow;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        OpennoteTokens.s5,
        OpennoteTokens.s2,
        OpennoteTokens.s3,
        OpennoteTokens.s1,
      ),
      child: Row(
        children: [
          ProBadge(label: eyebrow, showIcon: true),
          const Spacer(),
          IconButton(
            key: const Key('paywall_close_button'),
            tooltip: 'Close',
            onPressed: onDismiss ?? () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _PaywallHeroHeader extends StatelessWidget {
  const _PaywallHeroHeader({
    required this.paywallContext,
    required this.compact,
    this.alignStart = false,
  });

  final PaywallContext paywallContext;
  final bool compact;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final alignment = alignStart
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final textAlign = alignStart ? TextAlign.start : TextAlign.center;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (!compact) ...[
          const _OpennoteProCrest(size: 68),
          const SizedBox(height: OpennoteTokens.s4),
        ],
        Text(
          paywallContext.headline,
          textAlign: textAlign,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.18,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: OpennoteTokens.s2),
        Text(
          paywallContext.subheadline,
          textAlign: textAlign,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.42,
          ),
        ),
      ],
    );
  }
}

/// Crisp custom-painted geometric crest for Opennote Pro.
class _OpennoteProCrest extends StatelessWidget {
  const _OpennoteProCrest({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Opennote Pro emblem',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _OpennoteProCrestPainter(isDark: isDark)),
      ),
    );
  }
}

class _OpennoteProCrestPainter extends CustomPainter {
  const _OpennoteProCrestPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0xFF283566), Color(0xFF1A1F36)]
            : const [Color(0xFFEEF2FF), Color(0xFFDCE4FF)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.shortestSide * 0.28),
    );
    canvas.drawRRect(rrect, bgPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..color = isDark
          ? const Color(0xFF748FFC).withValues(alpha: 0.45)
          : OpennoteTokens.brandSeed.withValues(alpha: 0.28);
    canvas.drawRRect(rrect.deflate(0.6), borderPaint);

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = (isDark ? Colors.white : OpennoteTokens.brandSeed).withValues(
        alpha: 0.14,
      );
    canvas.drawCircle(center, radius * 0.68, gridPaint);

    final accentColor = isDark
        ? const Color(0xFF91A7FF)
        : OpennoteTokens.brandSeed;
    final prismPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..color = accentColor;

    final hexPath = Path();
    final hexRadius = radius * 0.46;
    for (var i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final point = Offset(
        center.dx + hexRadius * math.cos(angle),
        center.dy + hexRadius * math.sin(angle),
      );
      if (i == 0) {
        hexPath.moveTo(point.dx, point.dy);
      } else {
        hexPath.lineTo(point.dx, point.dy);
      }
    }
    hexPath.close();
    canvas.drawPath(hexPath, prismPaint);

    final nibPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = isDark ? const Color(0xFFFFD43B) : const Color(0xFFD97706);

    canvas.drawLine(
      Offset(center.dx, center.dy - hexRadius * 0.65),
      Offset(center.dx, center.dy + hexRadius * 0.65),
      nibPaint,
    );
    canvas.drawCircle(
      center,
      radius * 0.09,
      Paint()
        ..color = isDark ? const Color(0xFFFFD43B) : const Color(0xFFD97706),
    );
  }

  @override
  bool shouldRepaint(covariant _OpennoteProCrestPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class _BenefitShowcase extends StatelessWidget {
  const _BenefitShowcase({required this.highlights});

  final List<ProFeatureHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final cardBg = isDark
        ? OpennoteTokens.cardDarkSurface
        : OpennoteTokens.cardLightSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.all(
          Radius.circular(OpennoteTokens.radiusMd),
        ),
        border: Border.fromBorderSide(
          OpennoteTokens.subtleBorder(scheme, isDark ? 0.30 : 0.24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(OpennoteTokens.s4),
        child: Column(
          children: [
            for (var i = 0; i < highlights.length; i++) ...[
              _BenefitRow(highlight: highlights[i]),
              if (i < highlights.length - 1)
                const SizedBox(height: OpennoteTokens.s3),
            ],
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.highlight});

  final ProFeatureHighlight highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF91A7FF) : OpennoteTokens.brandSeed;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: accent.withValues(
              alpha: highlight.isPrimaryHighlight ? 0.18 : 0.10,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(OpennoteTokens.radiusSm),
            ),
          ),
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(highlight.icon, size: 18, color: accent),
          ),
        ),
        const SizedBox(width: OpennoteTokens.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                highlight.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                highlight.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrialTimelineCard extends StatelessWidget {
  const _TrialTimelineCard({required this.trialDays, required this.planTitle});

  final int trialDays;
  final String planTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final cardBg = isDark
        ? OpennoteTokens.cardDarkSurface
        : OpennoteTokens.cardLightSurface;
    final reminderDay = math.max(1, trialDays - 2);

    return DecoratedBox(
      key: const Key('paywall_trial_timeline'),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.all(
          Radius.circular(OpennoteTokens.radiusMd),
        ),
        border: Border.fromBorderSide(
          OpennoteTokens.subtleBorder(scheme, isDark ? 0.30 : 0.24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(OpennoteTokens.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How your free trial works',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: OpennoteTokens.s3),
            _TimelineStepRow(
              icon: Icons.lock_open_rounded,
              accent: isDark
                  ? const Color(0xFF91A7FF)
                  : OpennoteTokens.brandSeed,
              title: 'Today: Unlock all Pro tools (\$0)',
              subtitle: 'Instant access to every template, tool, and export.',
              showConnector: true,
            ),
            _TimelineStepRow(
              icon: Icons.notifications_active_outlined,
              accent: isDark
                  ? const Color(0xFFFFB74D)
                  : const Color(0xFFD97706),
              title: 'Day $reminderDay: Friendly reminder',
              subtitle: 'We remind you before your trial ends — no surprises.',
              showConnector: true,
            ),
            _TimelineStepRow(
              icon: Icons.verified_rounded,
              accent: isDark
                  ? const Color(0xFF8CE99A)
                  : const Color(0xFF15803D),
              title: 'Day $trialDays: $planTitle plan begins · Cancel anytime',
              subtitle: 'Stay Pro automatically or cancel in 1 tap beforehand.',
              showConnector: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineStepRow extends StatelessWidget {
  const _TimelineStepRow({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.showConnector,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(icon, size: 14, color: accent),
                  ),
                ),
                if (showConnector)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: ColoredBox(
                        color: scheme.outlineVariant.withValues(alpha: 0.45),
                        child: const SizedBox(width: 1.5, height: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: OpennoteTokens.s3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: showConnector ? OpennoteTokens.s3 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanSelectorList extends StatelessWidget {
  const _PlanSelectorList({
    required this.plans,
    required this.selectedPlanId,
    required this.onSelect,
  });

  final List<PaywallPlanViewModel> plans;
  final String selectedPlanId;
  final ValueChanged<PaywallPlanViewModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < plans.length; i++) ...[
          _PlanCard(
            plan: plans[i],
            isSelected: plans[i].id == selectedPlanId,
            onTap: () => onSelect(plans[i]),
          ),
          if (i < plans.length - 1) const SizedBox(height: OpennoteTokens.s3),
        ],
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final PaywallPlanViewModel plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF748FFC) : OpennoteTokens.brandSeed;
    final cardBg = isSelected
        ? accent.withValues(alpha: isDark ? 0.16 : 0.08)
        : (isDark
              ? OpennoteTokens.cardDarkSurface
              : OpennoteTokens.cardLightSurface);
    final borderColor = isSelected
        ? accent
        : scheme.outlineVariant.withValues(alpha: isDark ? 0.34 : 0.28);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${plan.title}, ${plan.priceDisplay}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('paywall_plan_${plan.id}'),
          onTap: onTap,
          borderRadius: const BorderRadius.all(
            Radius.circular(OpennoteTokens.radiusMd),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.all(
                Radius.circular(OpennoteTokens.radiusMd),
              ),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            ),
            padding: const EdgeInsets.all(OpennoteTokens.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan.badgeText != null) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accent
                          : accent.withValues(alpha: isDark ? 0.24 : 0.12),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(OpennoteTokens.radiusXs),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      child: Text(
                        plan.badgeText!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: isSelected
                              ? (isDark
                                    ? const Color(0xFF0B1020)
                                    : Colors.white)
                              : accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: OpennoteTokens.s2),
                ],
                Row(
                  children: [
                    _SelectionIndicator(isSelected: isSelected, accent: accent),
                    const SizedBox(width: OpennoteTokens.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: OpennoteTokens.s2,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                plan.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              if (plan.savingsPill != null)
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color:
                                        (isDark
                                                ? const Color(0xFF8CE99A)
                                                : const Color(0xFF15803D))
                                            .withValues(alpha: 0.14),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(
                                        OpennoteTokens.radiusPill,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      plan.savingsPill!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? const Color(0xFF8CE99A)
                                            : const Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (plan.hasFreeTrial) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${plan.freeTrialDays}-day free trial included',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: OpennoteTokens.s2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          plan.priceDisplay,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (plan.equivalentMonthlyDisplay != null)
                          Text(
                            plan.equivalentMonthlyDisplay!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
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

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected, required this.accent});

  final bool isSelected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? accent : Colors.transparent,
        border: Border.all(
          color: isSelected ? accent : scheme.outlineVariant,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}

class _StickyPaywallFooter extends StatelessWidget {
  const _StickyPaywallFooter({
    required this.selectedPlan,
    required this.purchaseState,
    required this.errorMessage,
    required this.isCompactHeight,
    required this.onPurchase,
    required this.onRestore,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
    required this.onStudentDiscount,
  });

  final PaywallPlanViewModel selectedPlan;
  final PaywallPurchaseState purchaseState;
  final String? errorMessage;
  final bool isCompactHeight;
  final VoidCallback onPurchase;
  final VoidCallback? onRestore;
  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenPrivacy;
  final VoidCallback? onStudentDiscount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final isBusy =
        purchaseState == PaywallPurchaseState.purchasing ||
        purchaseState == PaywallPurchaseState.restoring;
    final isSuccess = purchaseState == PaywallPurchaseState.success;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? OpennoteTokens.cardDarkSurface
            : OpennoteTokens.cardLightSurface,
        border: Border(
          top: OpennoteTokens.subtleBorder(scheme, isDark ? 0.32 : 0.22),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          OpennoteTokens.s5,
          isCompactHeight ? OpennoteTokens.s2 : OpennoteTokens.s3,
          OpennoteTokens.s5,
          isCompactHeight ? OpennoteTokens.s2 : OpennoteTokens.s3,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: OpennoteTokens.s2),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                SizedBox(
                  height: isCompactHeight ? 44 : 52,
                  child: FilledButton(
                    key: const Key('paywall_primary_cta'),
                    onPressed: isBusy || isSuccess ? null : onPurchase,
                    style: FilledButton.styleFrom(
                      backgroundColor: isSuccess
                          ? const Color(0xFF15803D)
                          : OpennoteTokens.brandSeed,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: isSuccess
                          ? const Color(0xFF15803D)
                          : OpennoteTokens.brandSeed.withValues(alpha: 0.65),
                      disabledForegroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(OpennoteTokens.radiusMd),
                        ),
                      ),
                    ),
                    child: _CtaButtonContent(
                      label: selectedPlan.ctaLabel,
                      purchaseState: purchaseState,
                    ),
                  ),
                ),
                const SizedBox(height: OpennoteTokens.s2),
                Text(
                  selectedPlan.effectiveFootnote,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isCompactHeight) ...[
                  const SizedBox(height: 2),
                  Text(
                    'No commitment · Cancel anytime in App Store / Play Store',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                    ),
                  ),
                ],
                const SizedBox(height: OpennoteTokens.s1),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: OpennoteTokens.s2,
                  runSpacing: 2,
                  children: [
                    _FooterTextLink(
                      key: const Key('paywall_restore_button'),
                      label: purchaseState == PaywallPurchaseState.restoring
                          ? 'Restoring...'
                          : 'Restore Purchases',
                      onPressed: isBusy ? null : onRestore,
                    ),
                    _FooterTextLink(
                      key: const Key('paywall_terms_button'),
                      label: 'Terms',
                      onPressed: onOpenTerms,
                    ),
                    _FooterTextLink(
                      key: const Key('paywall_privacy_button'),
                      label: 'Privacy',
                      onPressed: onOpenPrivacy,
                    ),
                    if (onStudentDiscount != null)
                      _FooterTextLink(
                        key: const Key('paywall_student_button'),
                        label: 'Student? Get 50% off',
                        onPressed: onStudentDiscount,
                        emphasized: true,
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

class _CtaButtonContent extends StatelessWidget {
  const _CtaButtonContent({required this.label, required this.purchaseState});

  final String label;
  final PaywallPurchaseState purchaseState;

  @override
  Widget build(BuildContext context) {
    if (purchaseState == PaywallPurchaseState.purchasing) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              'Processing...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    }

    if (purchaseState == PaywallPurchaseState.success) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Welcome to Opennote Pro!',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    }

    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _FooterTextLink extends StatelessWidget {
  const _FooterTextLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final textColor = emphasized
        ? (isDark ? const Color(0xFF91A7FF) : OpennoteTokens.brandSeed)
        : scheme.onSurfaceVariant;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        minimumSize: const Size(0, 28),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: TextStyle(
          fontSize: 12,
          fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      child: Text(label),
    );
  }
}
