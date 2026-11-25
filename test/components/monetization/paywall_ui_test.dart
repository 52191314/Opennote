/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/monetization/monetization_ui.dart';

void main() {
  Widget wrapWithTheme(
    Widget child, {
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B5BDB),
          brightness: brightness,
        ),
      ),
      home: Scaffold(body: child),
    );
  }

  Future<void> setSurfaceSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('PaywallContext & OpennotePaywallDefaults', () {
    test('provides tailored copy and 4 highlights for every trigger', () {
      for (final trigger in PaywallTriggerContext.values) {
        final ctx = PaywallContext.forTrigger(trigger);
        expect(ctx.headline, isNotEmpty);
        expect(ctx.subheadline, isNotEmpty);
        expect(ctx.highlights.length, 4);
      }
    });

    test('default plans anchor Annual with 7-day trial and 50% savings', () {
      const plans = OpennotePaywallDefaults.defaultPlans;
      expect(plans.length, 3);
      expect(plans.first.id, 'opennote_pro_annual');
      expect(plans.first.isRecommended, isTrue);
      expect(plans.first.hasFreeTrial, isTrue);
      expect(plans.first.freeTrialDays, 7);
      expect(plans.first.ctaLabel, 'Start 7-Day Free Trial');
      expect(plans[1].ctaLabel, 'Continue with Monthly');
      expect(plans[2].ctaLabel, 'Unlock Lifetime Pro');
    });
  });

  group('OpennotePaywallSheet', () {
    testWidgets(
      'renders without overflow on phone portrait, landscape, and tablet in light & dark themes',
      (tester) async {
        final viewports = <Size>[
          const Size(360, 640),
          const Size(390, 844),
          const Size(844, 390),
          const Size(1024, 768),
        ];

        for (final size in viewports) {
          for (final brightness in Brightness.values) {
            await setSurfaceSize(tester, size);
            await tester.pumpWidget(
              wrapWithTheme(
                OpennotePaywallSheet(
                  paywallContext: PaywallContext.forTrigger(
                    PaywallTriggerContext.engineeringTemplates,
                  ),
                  onStudentDiscount: () {},
                ),
                brightness: brightness,
              ),
            );
            await tester.pumpAndSettle();

            expect(
              tester.takeException(),
              isNull,
              reason: 'Overflow or exception at $size ($brightness)',
            );
            expect(
              find.text('Draft on Precision Engineering Paper'),
              findsOneWidget,
            );
          }
        }
      },
    );

    testWidgets(
      'switches plans, updates CTA label dynamically, and toggles trial timeline',
      (tester) async {
        await setSurfaceSize(tester, const Size(412, 915));
        PaywallPlanViewModel? lastSelected;
        PaywallPlanViewModel? purchasedPlan;

        await tester.pumpWidget(
          wrapWithTheme(
            OpennotePaywallSheet(
              paywallContext: PaywallContext.forTrigger(
                PaywallTriggerContext.precisionDrafting,
              ),
              onSelectPlan: (plan) => lastSelected = plan,
              onPurchase: (plan) => purchasedPlan = plan,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Annual is pre-selected with trial timeline visible.
        expect(find.text('Start 7-Day Free Trial'), findsOneWidget);
        expect(find.byKey(const Key('paywall_trial_timeline')), findsOneWidget);
        expect(find.text('Today: Unlock all Pro tools (\$0)'), findsOneWidget);

        // Select Lifetime plan.
        final lifetimeCard = find.byKey(
          const Key('paywall_plan_opennote_pro_lifetime'),
        );
        await tester.ensureVisible(lifetimeCard);
        await tester.tap(lifetimeCard);
        await tester.pumpAndSettle();

        expect(lastSelected?.id, 'opennote_pro_lifetime');
        expect(find.text('Unlock Lifetime Pro'), findsOneWidget);
        expect(find.byKey(const Key('paywall_trial_timeline')), findsNothing);

        // Tap primary CTA and verify purchased plan.
        await tester.tap(find.byKey(const Key('paywall_primary_cta')));
        await tester.pump();
        expect(purchasedPlan?.id, 'opennote_pro_lifetime');

        // Switch to Monthly plan.
        final monthlyCard = find.byKey(
          const Key('paywall_plan_opennote_pro_monthly'),
        );
        await tester.ensureVisible(monthlyCard);
        await tester.tap(monthlyCard);
        await tester.pumpAndSettle();
        expect(find.text('Continue with Monthly'), findsOneWidget);
      },
    );

    testWidgets('wires restore, terms, privacy, student, and close callbacks', (
      tester,
    ) async {
      await setSurfaceSize(tester, const Size(412, 915));
      var restored = false;
      var termsOpened = false;
      var privacyOpened = false;
      var studentTapped = false;
      var dismissed = false;

      await tester.pumpWidget(
        wrapWithTheme(
          OpennotePaywallSheet(
            paywallContext: PaywallContext.forTrigger(
              PaywallTriggerContext.infiniteCloudSync,
            ),
            onRestore: () => restored = true,
            onOpenTerms: () => termsOpened = true,
            onOpenPrivacy: () => privacyOpened = true,
            onStudentDiscount: () => studentTapped = true,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('paywall_restore_button')));
      await tester.tap(find.byKey(const Key('paywall_terms_button')));
      await tester.tap(find.byKey(const Key('paywall_privacy_button')));
      await tester.tap(find.byKey(const Key('paywall_student_button')));
      await tester.tap(find.byKey(const Key('paywall_close_button')));
      await tester.pump();

      expect(restored, isTrue);
      expect(termsOpened, isTrue);
      expect(privacyOpened, isTrue);
      expect(studentTapped, isTrue);
      expect(dismissed, isTrue);
    });

    testWidgets('displays purchasing, success, and error states cleanly', (
      tester,
    ) async {
      await setSurfaceSize(tester, const Size(412, 915));

      await tester.pumpWidget(
        wrapWithTheme(
          OpennotePaywallSheet(
            paywallContext: PaywallContext.forTrigger(
              PaywallTriggerContext.generalUpgrade,
            ),
            purchaseState: PaywallPurchaseState.purchasing,
          ),
        ),
      );
      expect(find.text('Processing...'), findsOneWidget);

      await tester.pumpWidget(
        wrapWithTheme(
          OpennotePaywallSheet(
            paywallContext: PaywallContext.forTrigger(
              PaywallTriggerContext.generalUpgrade,
            ),
            purchaseState: PaywallPurchaseState.success,
          ),
        ),
      );
      expect(find.text('Welcome to Opennote Pro!'), findsOneWidget);

      await tester.pumpWidget(
        wrapWithTheme(
          OpennotePaywallSheet(
            paywallContext: PaywallContext.forTrigger(
              PaywallTriggerContext.generalUpgrade,
            ),
            purchaseState: PaywallPurchaseState.error,
            errorMessage: 'Purchase cancelled by user.',
          ),
        ),
      );
      expect(find.text('Purchase cancelled by user.'), findsOneWidget);
    });
  });

  group('ProFeatureGateSheet', () {
    testWidgets('renders locked feature, 3 benefits, and triggers callbacks', (
      tester,
    ) async {
      await setSurfaceSize(tester, const Size(390, 844));
      var triedPro = false;
      var comparedPlans = false;
      var dismissed = false;

      await tester.pumpWidget(
        wrapWithTheme(
          ProFeatureGateSheet(
            paywallContext: PaywallContext.forTrigger(
              PaywallTriggerContext.vectorBatchExport,
            ),
            onTryPro: () => triedPro = true,
            onComparePlans: () => comparedPlans = true,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vector & Batch Export'), findsOneWidget);
      expect(find.text('Try Pro Free for 7 Days'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(3));

      await tester.tap(find.byKey(const Key('pro_gate_try_button')));
      await tester.tap(find.byKey(const Key('pro_gate_compare_button')));
      await tester.tap(find.byKey(const Key('pro_gate_dismiss_button')));
      await tester.pump();

      expect(triedPro, isTrue);
      expect(comparedPlans, isTrue);
      expect(dismissed, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('ProUpgradeBanner & ProBadge', () {
    testWidgets('renders Free, Trial, and Active Pro states without overflow', (
      tester,
    ) async {
      await setSurfaceSize(tester, const Size(360, 640));
      var tapped = false;
      var dismissed = false;

      // Free tier banner.
      await tester.pumpWidget(
        wrapWithTheme(
          Padding(
            padding: const EdgeInsets.all(16),
            child: ProUpgradeBanner(
              onTap: () => tapped = true,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );
      expect(
        find.text('Upgrade to Opennote Pro · 7 Days Free'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('pro_upgrade_banner')));
      await tester.tap(find.byKey(const Key('pro_banner_dismiss_button')));
      expect(tapped, isTrue);
      expect(dismissed, isTrue);

      // Active trial banner.
      await tester.pumpWidget(
        wrapWithTheme(
          const Padding(
            padding: EdgeInsets.all(16),
            child: ProUpgradeBanner(isPro: true, trialDaysRemaining: 4),
          ),
          brightness: Brightness.dark,
        ),
      );
      expect(find.text('PRO TRIAL'), findsOneWidget);
      expect(find.text('4 days left in trial'), findsOneWidget);

      // Subscribed Pro active banner.
      await tester.pumpWidget(
        wrapWithTheme(
          const Padding(
            padding: EdgeInsets.all(16),
            child: ProUpgradeBanner(
              isPro: true,
              activePlanLabel: 'Annual Plan',
            ),
          ),
        ),
      );
      expect(find.text('Opennote Pro Active'), findsOneWidget);
      expect(find.text('Annual Plan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('TrialCountdownPill handles 0, 1, and multi-day labels', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const Column(
            children: [
              TrialCountdownPill(daysRemaining: 0),
              TrialCountdownPill(daysRemaining: 1),
              TrialCountdownPill(daysRemaining: 5),
            ],
          ),
        ),
      );
      expect(find.text('Trial ends today'), findsOneWidget);
      expect(find.text('1 day left in trial'), findsOneWidget);
      expect(find.text('5 days left in trial'), findsOneWidget);
    });
  });

  group('ReviewPromptSheet', () {
    testWidgets('Love it! routes to Store Review callback and thank-you view', (
      tester,
    ) async {
      await setSurfaceSize(tester, const Size(390, 844));
      var storeReviewRequested = false;
      var dismissed = false;

      await tester.pumpWidget(
        wrapWithTheme(
          ReviewPromptSheet(
            onRequestStoreReview: () => storeReviewRequested = true,
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('How is Opennote working for you?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('review_love_it_button')));
      await tester.pumpAndSettle();

      expect(storeReviewRequested, isTrue);
      expect(find.text('Thank you for supporting Opennote!'), findsOneWidget);

      await tester.tap(find.byKey(const Key('review_done_button')));
      await tester.pump();
      expect(dismissed, isTrue);
    });

    testWidgets(
      'Could be better routes to private feedback without triggering Store Review',
      (tester) async {
        await setSurfaceSize(tester, const Size(390, 844));
        var storeReviewRequested = false;
        String? capturedFeedback;
        Set<String>? capturedTopics;

        await tester.pumpWidget(
          wrapWithTheme(
            ReviewPromptSheet(
              onRequestStoreReview: () => storeReviewRequested = true,
              onSubmitFeedback: (message, topics) {
                capturedFeedback = message;
                capturedTopics = topics;
              },
            ),
            brightness: Brightness.dark,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('review_could_be_better_button')),
        );
        await tester.pumpAndSettle();

        expect(storeReviewRequested, isFalse);
        expect(find.text('How can we make Opennote better?'), findsOneWidget);

        await tester.tap(find.text('Cloud Sync'));
        await tester.enterText(
          find.byKey(const Key('review_feedback_textfield')),
          'Would love faster background sync.',
        );
        await tester.tap(find.byKey(const Key('review_send_feedback_button')));
        await tester.pumpAndSettle();

        expect(capturedFeedback, 'Would love faster background sync.');
        expect(capturedTopics, contains('Cloud Sync'));
        expect(find.text('Thanks — we heard you!'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
