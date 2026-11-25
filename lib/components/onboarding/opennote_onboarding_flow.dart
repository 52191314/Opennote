/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/onboarding/onboarding_models.dart';
import 'package:saber/components/onboarding/onboarding_persona_step.dart';
import 'package:saber/components/onboarding/onboarding_superpowers_step.dart';
import 'package:saber/components/onboarding/onboarding_trial_step.dart';
import 'package:saber/components/onboarding/onboarding_welcome_step.dart';

/// Callback invoked when the user starts a trial or subscription in Step 4.
///
/// Returns `true` if the purchase or trial initiation succeeded.
typedef OnboardingTrialStarter =
    Future<bool> Function(String planSku, OnboardingPersona persona);

/// Callback invoked when the user taps Restore Purchases in Step 4.
///
/// Returns `true` if an existing Pro entitlement was restored.
typedef OnboardingPurchaseRestorer = Future<bool> Function();

/// Personalized 4-step Onboarding-to-Trial experience for Opennote.
class OpennoteOnboardingFlow extends StatefulWidget {
  /// Creates the 4-step onboarding flow widget.
  const OpennoteOnboardingFlow({
    super.key,
    this.initialPersona = OnboardingPersona.engineeringDiagrams,
    this.onCompleted,
    this.onStartTrial,
    this.onRestorePurchases,
    this.onOpenTerms,
    this.onOpenPrivacy,
  });

  /// Default persona pre-selected on Step 2.
  final OnboardingPersona initialPersona;

  /// Invoked with the final [OnboardingCompletionResult] when the flow finishes.
  final ValueChanged<OnboardingCompletionResult>? onCompleted;

  /// Optional async handler for initiating the selected trial/plan SKU.
  final OnboardingTrialStarter? onStartTrial;

  /// Optional async handler for restoring previous store purchases.
  final OnboardingPurchaseRestorer? onRestorePurchases;

  /// Optional callback for viewing Terms of Service.
  final VoidCallback? onOpenTerms;

  /// Optional callback for viewing the Privacy Policy.
  final VoidCallback? onOpenPrivacy;

  /// Total number of steps in the onboarding flow.
  static const stepCount = 4;

  /// Presents [OpennoteOnboardingFlow] responsively as a full-screen view on
  /// phones and a centered modal dialog on tablets and desktops.
  static Future<OnboardingCompletionResult?> show(
    BuildContext context, {
    OnboardingPersona initialPersona = OnboardingPersona.engineeringDiagrams,
    OnboardingTrialStarter? onStartTrial,
    OnboardingPurchaseRestorer? onRestorePurchases,
    VoidCallback? onOpenTerms,
    VoidCallback? onOpenPrivacy,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isPhone = screenWidth < 600;

    return showDialog<OnboardingCompletionResult>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final flow = OpennoteOnboardingFlow(
          initialPersona: initialPersona,
          onStartTrial: onStartTrial,
          onRestorePurchases: onRestorePurchases,
          onOpenTerms: onOpenTerms,
          onOpenPrivacy: onOpenPrivacy,
          onCompleted: (result) {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop(result);
            }
          },
        );

        if (isPhone) {
          return Dialog.fullscreen(child: flow);
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
            child: flow,
          ),
        );
      },
    );
  }

  @override
  State<OpennoteOnboardingFlow> createState() => _OpennoteOnboardingFlowState();
}

class _OpennoteOnboardingFlowState extends State<OpennoteOnboardingFlow> {
  final _pageController = PageController();
  var _currentStep = 0;
  late OnboardingPersona _selectedPersona = widget.initialPersona;
  var _selectedPlanSku = OnboardingPlanSku.annual;
  var _isBusy = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int index) {
    if (index < 0 || index >= OpennoteOnboardingFlow.stepCount) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _complete(OnboardingCompletionResult result) {
    widget.onCompleted?.call(result);
  }

  Future<void> _handleStartTrial() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    var succeeded = true;
    try {
      if (widget.onStartTrial != null) {
        succeeded = await widget.onStartTrial!(
          _selectedPlanSku,
          _selectedPersona,
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }

    if (!mounted || !succeeded) return;
    _complete(
      OnboardingCompletionResult(
        persona: _selectedPersona,
        startedTrial: true,
        selectedPlanSku: _selectedPlanSku,
      ),
    );
  }

  Future<void> _handleRestorePurchases() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    var restored = false;
    try {
      if (widget.onRestorePurchases != null) {
        restored = await widget.onRestorePurchases!();
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }

    if (!mounted || !restored) return;
    _complete(
      OnboardingCompletionResult(
        persona: _selectedPersona,
        startedTrial: false,
        restoredPurchases: true,
      ),
    );
  }

  void _handleContinueFree() {
    _complete(
      OnboardingCompletionResult(
        persona: _selectedPersona,
        startedTrial: false,
      ),
    );
  }

  void _handleSkip() {
    _complete(
      OnboardingCompletionResult(
        persona: _selectedPersona,
        startedTrial: false,
        skipped: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLastStep = _currentStep == OpennoteOnboardingFlow.stepCount - 1;

    return ColoredBox(
      color: colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(
              currentStep: _currentStep,
              stepCount: OpennoteOnboardingFlow.stepCount,
              onBack: _currentStep > 0
                  ? () => _goToStep(_currentStep - 1)
                  : null,
              onSkip: _handleSkip,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  const OnboardingWelcomeStep(),
                  OnboardingPersonaStep(
                    selectedPersona: _selectedPersona,
                    onPersonaSelected: (persona) {
                      setState(() => _selectedPersona = persona);
                    },
                  ),
                  OnboardingSuperpowersStep(persona: _selectedPersona),
                  OnboardingTrialStep(
                    persona: _selectedPersona,
                    selectedPlanSku: _selectedPlanSku,
                    onPlanSelected: (sku) {
                      setState(() => _selectedPlanSku = sku);
                    },
                    onStartTrial: _handleStartTrial,
                    onContinueFree: _handleContinueFree,
                    onRestorePurchases: _handleRestorePurchases,
                    onOpenTerms: widget.onOpenTerms,
                    onOpenPrivacy: widget.onOpenPrivacy,
                    isBusy: _isBusy,
                  ),
                ],
              ),
            ),
            if (!isLastStep)
              _OnboardingBottomBar(
                currentStep: _currentStep,
                onBack: _currentStep > 0
                    ? () => _goToStep(_currentStep - 1)
                    : null,
                onContinue: () => _goToStep(_currentStep + 1),
              ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.currentStep,
    required this.stepCount,
    required this.onSkip,
    this.onBack,
  });

  final int currentStep;
  final int stepCount;
  final VoidCallback? onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLastStep = currentStep == stepCount - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              if (isLastStep && onBack != null)
                IconButton(
                  onPressed: onBack,
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      'Opennote',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Step ${currentStep + 1} of $stepCount',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(onPressed: onSkip, child: const Text('Skip')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < stepCount; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= currentStep
                          ? colorScheme.primary
                          : colorScheme.outlineVariant.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingBottomBar extends StatelessWidget {
  const _OnboardingBottomBar({
    required this.currentStep,
    required this.onContinue,
    this.onBack,
  });

  final int currentStep;
  final VoidCallback? onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Row(
          children: [
            if (onBack != null)
              OutlinedButton(onPressed: onBack, child: const Text('Back')),
            const Spacer(),
            FilledButton(
              onPressed: onContinue,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currentStep == 0 ? 'Get Started' : 'Continue'),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
