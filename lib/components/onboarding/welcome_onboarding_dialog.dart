/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber/data/is_this_a_test.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';

/// Interactive onboarding modal introducing users to gestures, study tape,
/// smooth inking, and elements.
class WelcomeOnboardingDialog extends StatefulWidget {
  const WelcomeOnboardingDialog({super.key});

  /// Shows the onboarding dialog if the user has not seen it yet.
  static Future<void> showIfNeeded(BuildContext context) async {
    if (isThisATest) return;
    if (stows.hasSeenOnboarding.value) return;
    stows.hasSeenOnboarding.value = true;
    await show(context);
  }

  /// Opens the onboarding dialog explicitly (e.g. from Settings).
  static Future<void> show(BuildContext context) {
    return showDialog(
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
            // Top bar with branding and Skip button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      t.onboarding.title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
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

            // Carousel
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
                          // Icon circle with soft gradient ring
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

                          // Title
                          Text(
                            data.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Description
                          Text(
                            data.description,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Feature tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: data.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  tag,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
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

            // Indicator dots and Navigation Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot indicators
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

                  // Action Buttons
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
