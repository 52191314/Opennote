/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber/components/onboarding/onboarding_models.dart';
import 'package:saber/components/onboarding/opennote_onboarding_flow.dart';
import 'package:saber/data/is_this_a_test.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';

export 'package:saber/components/onboarding/onboarding_models.dart';
export 'package:saber/components/onboarding/opennote_onboarding_flow.dart';

/// Interactive onboarding modal for Opennote.
///
/// First-run launches via [showIfNeeded] present the personalized 4-step
/// [OpennoteOnboardingFlow]. Direct [show] calls remain backward compatible
/// with existing callers while supporting [personalized] mode.
class WelcomeOnboardingDialog extends StatefulWidget {
  /// Creates a welcome onboarding dialog.
  ///
  /// Set [usePersonalizedFlow] to `true` to embed [OpennoteOnboardingFlow].
  const WelcomeOnboardingDialog({
    super.key,
    this.usePersonalizedFlow = false,
    this.onCompleted,
    this.onStartTrial,
    this.onRestorePurchases,
  });

  /// Whether this dialog wraps [OpennoteOnboardingFlow] instead of the legacy
  /// feature carousel.
  final bool usePersonalizedFlow;

  /// Optional callback receiving the [OnboardingCompletionResult] when
  /// [usePersonalizedFlow] is `true`.
  final ValueChanged<OnboardingCompletionResult>? onCompleted;

  /// Optional trial purchase handler forwarded to [OpennoteOnboardingFlow].
  final OnboardingTrialStarter? onStartTrial;

  /// Optional restore-purchases handler forwarded to [OpennoteOnboardingFlow].
  final OnboardingPurchaseRestorer? onRestorePurchases;

  /// Shows the personalized 4-step onboarding flow if the user has not seen it.
  static Future<OnboardingCompletionResult?> showIfNeeded(
    BuildContext context, {
    OnboardingTrialStarter? onStartTrial,
    OnboardingPurchaseRestorer? onRestorePurchases,
  }) async {
    if (isThisATest) return null;
    if (stows.hasSeenOnboarding.value) return null;
    stows.hasSeenOnboarding.value = true;
    return showFlow(
      context,
      onStartTrial: onStartTrial,
      onRestorePurchases: onRestorePurchases,
    );
  }

  /// Opens the personalized 4-step [OpennoteOnboardingFlow] directly.
  static Future<OnboardingCompletionResult?> showFlow(
    BuildContext context, {
    OnboardingPersona initialPersona = OnboardingPersona.engineeringDiagrams,
    OnboardingTrialStarter? onStartTrial,
    OnboardingPurchaseRestorer? onRestorePurchases,
    VoidCallback? onOpenTerms,
    VoidCallback? onOpenPrivacy,
  }) async {
    final result = await OpennoteOnboardingFlow.show(
      context,
      initialPersona: initialPersona,
      onStartTrial: onStartTrial,
      onRestorePurchases: onRestorePurchases,
      onOpenTerms: onOpenTerms,
      onOpenPrivacy: onOpenPrivacy,
    );
    stows.hasSeenOnboarding.value = true;
    return result;
  }

  /// Opens the onboarding dialog explicitly (e.g. from Settings).
  ///
  /// Pass `personalized: true` to present the new 4-step onboarding-to-trial
  /// flow; defaults to `false` to preserve compatibility with existing callers.
  static Future<OnboardingCompletionResult?> show(
    BuildContext context, {
    bool personalized = false,
    OnboardingTrialStarter? onStartTrial,
    OnboardingPurchaseRestorer? onRestorePurchases,
  }) {
    if (personalized) {
      return showFlow(
        context,
        onStartTrial: onStartTrial,
        onRestorePurchases: onRestorePurchases,
      );
    }

    return showDialog<OnboardingCompletionResult>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const WelcomeOnboardingDialog(),
    );
  }

  @override
  State<WelcomeOnboardingDialog> createState() =>
      _WelcomeOnboardingDialogState();
}

class _WelcomeOnboardingDialogState extends State<WelcomeOnboardingDialog> {
  final _pageController = PageController();
  var _currentPage = 0;

  static List<_OnboardingCardData> get _pages => [
    _OnboardingCardData(
      icon: Icons.draw_rounded,
      accentColor: const Color(0xFF6750A4),
      title: t.onboarding.paper.title,
      description: t.onboarding.paper.description,
      tags: [
        t.onboarding.paper.tagPressure,
        t.onboarding.paper.tagCurves,
        t.onboarding.paper.tagTemplates,
      ],
    ),
    _OnboardingCardData(
      icon: Icons.auto_fix_high_rounded,
      accentColor: const Color(0xFF00677D),
      title: t.onboarding.gestures.title,
      description: t.onboarding.gestures.description,
      tags: [
        t.onboarding.gestures.tagScribble,
        t.onboarding.gestures.tagCircle,
        t.onboarding.gestures.tagUndo,
      ],
    ),
    _OnboardingCardData(
      icon: Icons.layers_rounded,
      accentColor: const Color(0xFFB52700),
      title: t.onboarding.tape.title,
      description: t.onboarding.tape.description,
      tags: [
        t.onboarding.tape.tagRecall,
        t.onboarding.tape.tagReveal,
        t.onboarding.tape.tagStudy,
      ],
    ),
    _OnboardingCardData(
      icon: Icons.dashboard_customize_rounded,
      accentColor: const Color(0xFF006C4C),
      title: t.onboarding.elements.title,
      description: t.onboarding.elements.description,
      tags: [
        t.onboarding.elements.tagTray,
        t.onboarding.elements.tagLayers,
        t.onboarding.elements.tagWorkspace,
      ],
    ),
  ];

  void _finishOnboarding([bool openPlayground = false]) {
    stows.hasSeenOnboarding.value = true;
    Navigator.of(context).pop();
    if (openPlayground) {
      context.push(RoutePaths.edit);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.usePersonalizedFlow) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
          child: OpennoteOnboardingFlow(
            onStartTrial: widget.onStartTrial,
            onRestorePurchases: widget.onRestorePurchases,
            onCompleted: (result) {
              stows.hasSeenOnboarding.value = true;
              widget.onCompleted?.call(result);
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop(result);
              }
            },
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLastPage = _currentPage == _pages.length - 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        t.onboarding.title,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _finishOnboarding(false),
                    child: Text(
                      MaterialLocalizations.of(context).closeButtonLabel,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: data.accentColor.withValues(alpha: 0.12),
                              border: Border.all(
                                color: data.accentColor.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                data.icon,
                                size: 34,
                                color: data.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.description,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: data.tags.map((tag) {
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    tag,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isSelected = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isSelected ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  if (!isLastPage) ...[
                    Row(
                      children: [
                        if (_currentPage > 0)
                          OutlinedButton(
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              );
                            },
                            child: Text(t.editor.actions.back),
                          ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(t.editor.actions.next),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.edit_note, size: 18),
                            label: Text(t.onboarding.tryPlayground),
                            onPressed: () => _finishOnboarding(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.check, size: 18),
                            label: Text(t.onboarding.getStarted),
                            onPressed: () => _finishOnboarding(false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingCardData {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;
  final List<String> tags;

  const _OnboardingCardData({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.tags,
  });
}
