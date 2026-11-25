/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:saber/data/monetization/monetization.dart';

void main() {
  group('EntitlementService', () {
    late DateTime now;
    late LocalSimulationPurchaseGateway gateway;
    late InMemoryEntitlementPersistence persistence;
    late ConversionAnalytics analytics;
    late EntitlementService service;

    setUp(() {
      now = DateTime.utc(2026, 6, 1, 10);
      gateway = LocalSimulationPurchaseGateway(clock: () => now);
      persistence = InMemoryEntitlementPersistence();
      analytics = ConversionAnalytics(clock: () => now);
      service = EntitlementService(
        gateway: gateway,
        persistence: persistence,
        analytics: analytics,
        clock: () => now,
      );
    });

    test('starts free with softPromptOnly enabled by default', () {
      expect(service.isPro, isFalse);
      expect(service.state.tier, SubscriptionTier.free);
      expect(service.softPromptOnly, isTrue);
      expect(service.freeNotebookLimit, 5);

      // Soft prompt allows action while signaling upsell.
      final result = service.evaluateFeature(
        ProFeature.vectorSvgExport,
        logGateEvent: true,
      );
      expect(result.decision, FeatureAccessDecision.softPrompt);
      expect(result.isAllowed, isTrue);
      expect(result.shouldShowUpsell, isTrue);
      expect(
        analytics.summarize().countOf(ConversionEventType.proGateTriggered),
        1,
      );
    });

    test(
      'enforces free notebook limit and hardGate when softPromptOnly=false',
      () {
        service.setSoftPromptOnly(false);

        // Below 5 notebooks is allowed on free tier.
        expect(service.hasReachedFreeNotebookLimit(4), isFalse);
        expect(
          service.canUseFeature(
            ProFeature.unlimitedNotebooks,
            currentNotebookCount: 4,
          ),
          isTrue,
        );

        // At 5 notebooks hits hard gate.
        expect(service.hasReachedFreeNotebookLimit(5), isTrue);
        final gated = service.evaluateFeature(
          ProFeature.unlimitedNotebooks,
          currentNotebookCount: 5,
        );
        expect(gated.decision, FeatureAccessDecision.hardGate);
        expect(gated.isAllowed, isFalse);
        expect(
          service.canUseFeature(ProFeature.precisionDraftingPack),
          isFalse,
        );
      },
    );

    test(
      'grantTrial unlocks Pro, tracks days remaining, and expires cleanly',
      () async {
        var notifications = 0;
        service.addListener(() => notifications++);

        final granted = await service.grantTrial(days: 7);
        expect(granted, isTrue);
        expect(service.isPro, isTrue);
        expect(service.isInTrial, isTrue);
        expect(service.trialDaysRemaining, 7);
        expect(notifications, 1);

        service.setSoftPromptOnly(false);
        expect(service.canUseFeature(ProFeature.vectorSvgExport), isTrue);

        // Advance 3 days and 1 hour -> 4 days remaining (ceil).
        now = now.add(const Duration(days: 3, hours: 1));
        expect(service.trialDaysRemaining, 4);
        expect(service.isPro, isTrue);

        // Advance past trial end -> auto-downgrades to free.
        now = now.add(const Duration(days: 4));
        expect(service.isPro, isFalse);
        expect(service.isInTrial, isFalse);
        expect(service.trialDaysRemaining, 0);
        expect(service.state.tier, SubscriptionTier.free);
        expect(service.canUseFeature(ProFeature.vectorSvgExport), isFalse);
      },
    );

    test(
      'purchasePlan updates state, persists, and logs funnel events',
      () async {
        final result = await service.purchasePlan(
          OpennoteSubscriptionCatalog.annualSkuId,
        );
        expect(result.isSuccess, isTrue);
        expect(service.isPro, isTrue);
        expect(service.isInTrial, isTrue);
        expect(
          service.state.activeSkuId,
          OpennoteSubscriptionCatalog.annualSkuId,
        );

        final persisted = persistence.read();
        expect(persisted, isNotNull);
        expect(persisted!['tier'], SubscriptionTier.proAnnual.storageKey);

        final summary = analytics.summarize();
        expect(summary.countOf(ConversionEventType.trialStarted), 1);
        expect(summary.countOf(ConversionEventType.purchaseSucceeded), 1);
      },
    );

    test('purchasePlan logs failure without mutating entitlement', () async {
      gateway.nextPurchaseErrorCode = 'network_error';
      final result = await service.purchasePlan(
        OpennoteSubscriptionCatalog.monthlySkuId,
      );
      expect(result.isSuccess, isFalse);
      expect(service.isPro, isFalse);
      expect(
        analytics.summarize().countOf(ConversionEventType.purchaseFailed),
        1,
      );
    });

    test('restorePurchases picks highest-priority non-expired tier', () async {
      final restoreGateway = LocalSimulationPurchaseGateway(
        clock: () => now,
        initialRestorablePurchases: [
          PurchaseResult(
            status: PurchaseStatus.restored,
            skuId: OpennoteSubscriptionCatalog.monthlySkuId,
            tier: SubscriptionTier.proMonthly,
            expiresAt: now.add(const Duration(days: 15)),
          ),
          const PurchaseResult(
            status: PurchaseStatus.restored,
            skuId: OpennoteSubscriptionCatalog.lifetimeSkuId,
            tier: SubscriptionTier.proLifetime,
          ),
          PurchaseResult(
            status: PurchaseStatus.restored,
            skuId: OpennoteSubscriptionCatalog.annualSkuId,
            tier: SubscriptionTier.proAnnual,
            expiresAt: now.subtract(const Duration(days: 2)),
          ),
        ],
      );

      final restoreService = EntitlementService(
        gateway: restoreGateway,
        persistence: persistence,
        analytics: analytics,
        clock: () => now,
      );

      final restored = await restoreService.restorePurchases();
      expect(restored, hasLength(3));
      expect(restoreService.state.tier, SubscriptionTier.proLifetime);
      expect(restoreService.isPro, isTrue);
      expect(
        analytics.summarize().countOf(ConversionEventType.restoreSucceeded),
        1,
      );

      // Cannot overwrite paid lifetime Pro with a trial.
      expect(await restoreService.grantTrial(), isFalse);
    });

    test('initialize hydrates from CallbackEntitlementPersistence', () async {
      Map<String, dynamic>? backingStore = EntitlementState(
        tier: SubscriptionTier.proAnnual,
        isInTrial: false,
        expiresAt: now.add(const Duration(days: 120)),
        activeSkuId: OpennoteSubscriptionCatalog.annualSkuId,
        lastVerifiedAt: now,
      ).toJson();

      final callbackPersistence = CallbackEntitlementPersistence(
        onRead: () => backingStore,
        onWrite: (json) => backingStore = json,
        onClear: () => backingStore = null,
      );

      final hydrated = EntitlementService(
        gateway: gateway,
        persistence: callbackPersistence,
        clock: () => now,
      );

      await hydrated.initialize(verifyStore: false);
      expect(hydrated.isPro, isTrue);
      expect(hydrated.state.tier, SubscriptionTier.proAnnual);

      await hydrated.clearEntitlement();
      expect(hydrated.isPro, isFalse);
      expect(backingStore, isNull);
    });
  });
}
