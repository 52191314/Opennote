/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/monetization/monetization_ui.dart';
import 'package:saber/components/onboarding/welcome_onboarding_dialog.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/monetization/monetization.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/pages/home/settings.dart';
import 'package:sbn/canvas_background_pattern.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  late LocalSimulationPurchaseGateway simulationGateway;
  late MonetizationCoordinator coordinator;

  setUp(() async {
    stows.hasSeenOnboarding.value = false;
    stows.onboardingCompleted.value = false;
    stows.onboardingPersona.value = '';
    stows.proTierCached.value = 'free';
    stows.proTrialStartEpochMs.value = 0;
    stows.proExpirationEpochMs.value = 0;
    stows.notesCreatedCount.value = 0;
    stows.exportsCompletedCount.value = 0;
    stows.lastReviewPromptEpochMs.value = 0;
    stows.hasRatedApp.value = false;
    stows.paywallImpressionsCount.value = 0;

    simulationGateway = LocalSimulationPurchaseGateway();
    final entitlementService = EntitlementService(
      gateway: simulationGateway,
      persistence: CallbackEntitlementPersistence(
        onRead: () {
          final tierKey = stows.proTierCached.value;
          if (tierKey.isEmpty || tierKey == 'free') return null;
          return {
            'tier': tierKey,
            'isInTrial': stows.proTrialStartEpochMs.value > 0,
          };
        },
        onWrite: (json) {
          stows.proTierCached.value = (json['tier'] as String?) ?? 'free';
          stows.proTrialStartEpochMs.value =
              (json['isInTrial'] as bool? ?? false)
              ? DateTime.now().toUtc().millisecondsSinceEpoch
              : 0;
        },
        onClear: () {
          stows.proTierCached.value = 'free';
          stows.proTrialStartEpochMs.value = 0;
        },
      ),
    );
    final reviewService = ReviewPromptService(
      onStateChanged: (state) {
        stows.notesCreatedCount.value = state.completedNotesCount;
        stows.exportsCompletedCount.value = state.completedPdfExportsCount;
        stows.hasRatedApp.value = state.hasRated;
        if (state.lastPromptedAt != null) {
          stows.lastReviewPromptEpochMs.value =
              state.lastPromptedAt!.millisecondsSinceEpoch;
        }
      },
    );

    coordinator = MonetizationCoordinator(
      entitlementService: entitlementService,
      reviewPromptService: reviewService,
    );
    MonetizationCoordinator.setInstanceForTesting(coordinator);
    await coordinator.initialize(verifyStore: false);
  });

  tearDown(() {
    MonetizationCoordinator.resetInstanceForTesting();
  });

  testWidgets(
    'End-to-end funnel: Onboarding -> Paywall -> Entitlement Unlock -> Pro Access -> Settings Status',
    (tester) async {
      tester.view.physicalSize = const Size(1024, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      late BuildContext hostContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              hostContext = context;
              return ListenableBuilder(
                listenable: coordinator.entitlementService,
                builder: (context, _) => SettingsPage(
                  isPro: coordinator.isPro,
                  planSummary: coordinator.planSummary,
                  onUpgradeTap: () => coordinator.showPaywall(
                    context,
                    trigger: PaywallTriggerContext.generalUpgrade,
                  ),
                  onRestorePurchasesTap: () =>
                      coordinator.restorePurchasesWithFeedback(context),
                  onRateAppTap: () =>
                      coordinator.showReviewPrompt(context, force: true),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify initial Free state on SettingsPage
      expect(coordinator.isPro, isFalse);
      expect(find.textContaining('Unlock Opennote Pro'), findsOneWidget);

      // 2. Onboarding completion saves persona & template and opens Paywall on trial intent
      const onboardingResult = OnboardingCompletionResult(
        persona: OnboardingPersona.universityNotes,
        startedTrial: true,
        selectedPlanSku: OnboardingPlanSku.annual,
      );
      final onboardingFuture = coordinator.handleOnboardingCompletion(
        hostContext,
        onboardingResult,
      );
      await tester.pumpAndSettle();

      expect(stows.onboardingCompleted.value, isTrue);
      expect(stows.onboardingPersona.value, 'universityNotes');
      expect(
        stows.lastBackgroundPattern.value,
        CanvasBackgroundPattern.cornell,
      );
      expect(stows.paywallImpressionsCount.value, 1);
      expect(find.byType(OpennotePaywallSheet), findsOneWidget);

      // 3. Tap primary CTA on Paywall -> unlocks Pro entitlement & closes sheet
      final ctaFinder = find.descendant(
        of: find.byType(OpennotePaywallSheet),
        matching: find.textContaining('Start 7-Day Free Trial'),
      );
      await tester.ensureVisible(ctaFinder);
      await tester.tap(ctaFinder);
      await tester.pumpAndSettle();
      await onboardingFuture;

      expect(coordinator.isPro, isTrue);
      expect(coordinator.isInTrial, isTrue);
      expect(stows.proTierCached.value, SubscriptionTier.proAnnual.storageKey);
      expect(find.byType(OpennotePaywallSheet), findsNothing);

      // 4. Pro feature gate immediately allows access without showing gate sheet
      final gateAllowed = await coordinator.handleFeatureRequest(
        hostContext,
        'vector_export',
      );
      expect(gateAllowed, isTrue);
      expect(find.byType(ProFeatureGateSheet), findsNothing);

      // 5. SettingsPage reactively reflects Pro Active state & trial summary
      await tester.pumpAndSettle();
      expect(find.text('PRO ACTIVE'), findsOneWidget);
      expect(find.textContaining('7-Day Free Trial'), findsOneWidget);
    },
  );

  testWidgets(
    'Free user feature gate routes to Paywall and Aha-moment PDF export triggers ReviewPromptSheet',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      late BuildContext hostContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                hostContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // 1. Free user tapping Pro feature opens ProFeatureGateSheet
      final gateFuture = coordinator.handleFeatureRequest(
        hostContext,
        'engineering_templates',
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProFeatureGateSheet), findsOneWidget);

      // Dismiss gate without buying
      final notNow = find.text('Not Now');
      await tester.ensureVisible(notNow);
      await tester.tap(notNow);
      await tester.pumpAndSettle();
      expect(await gateFuture, isFalse);

      // 2. Completing 1 PDF export hits the Aha moment and shows ReviewPromptSheet
      final exportFuture = coordinator.recordPdfExportCompleted(hostContext);
      await tester.pumpAndSettle();

      expect(stows.exportsCompletedCount.value, 1);
      expect(find.byType(ReviewPromptSheet), findsOneWidget);

      // Tap "Love it!" -> marks user as rated in stows
      await tester.tap(find.text('Love it!'));
      await tester.pumpAndSettle();
      expect(stows.hasRatedApp.value, isTrue);

      // Close sheet
      Navigator.of(hostContext).pop();
      await tester.pumpAndSettle();
      await exportFuture;

      // Subsequent note milestones do not nag after user rated
      expect(coordinator.reviewPromptService.shouldPromptReview(), isFalse);
    },
  );
}
