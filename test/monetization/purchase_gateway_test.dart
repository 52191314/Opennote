/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/data/monetization/monetization.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalSimulationPurchaseGateway', () {
    late DateTime now;
    late LocalSimulationPurchaseGateway gateway;

    setUp(() {
      now = DateTime.utc(2026, 6, 1, 12);
      gateway = LocalSimulationPurchaseGateway(clock: () => now);
    });

    test('fetchCatalog returns default Opennote plans', () async {
      final catalog = await gateway.fetchCatalog();
      expect(catalog, hasLength(4));
      expect(catalog.first.skuId, OpennoteSubscriptionCatalog.annualSkuId);
    });

    test(
      'annual purchase starts 7-day trial and sets verified entitlement',
      () async {
        final result = await gateway.purchase(
          OpennoteSubscriptionCatalog.annualSkuId,
        );
        expect(result.isSuccess, isTrue);
        expect(result.status, PurchaseStatus.purchased);
        expect(result.tier, SubscriptionTier.proAnnual);
        expect(result.isInTrial, isTrue);
        expect(result.expiresAt, now.add(const Duration(days: 7)));

        final verified = await gateway.verifyEntitlement();
        expect(verified, isNotNull);
        expect(verified!.tier, SubscriptionTier.proAnnual);
        expect(verified.isInTrial, isTrue);

        now = now.add(const Duration(days: 8));
        expect(await gateway.verifyEntitlement(), isNull);
      },
    );

    test('lifetime purchase never expires and is restorable', () async {
      final result = await gateway.purchase(
        OpennoteSubscriptionCatalog.lifetimeSkuId,
      );
      expect(result.isSuccess, isTrue);
      expect(result.tier, SubscriptionTier.proLifetime);
      expect(result.expiresAt, isNull);
      expect(result.isInTrial, isFalse);

      now = now.add(const Duration(days: 3650));
      final verified = await gateway.verifyEntitlement();
      expect(verified?.tier, SubscriptionTier.proLifetime);

      final restored = await gateway.restorePurchases();
      expect(restored, hasLength(1));
      expect(restored.first.status, PurchaseStatus.restored);
      expect(restored.first.skuId, OpennoteSubscriptionCatalog.lifetimeSkuId);
    });

    test('handles simulated cancellation, failure, and unknown SKU', () async {
      gateway.cancelNextPurchase = true;
      final cancelled = await gateway.purchase(
        OpennoteSubscriptionCatalog.monthlySkuId,
      );
      expect(cancelled.status, PurchaseStatus.cancelled);
      expect(cancelled.isSuccess, isFalse);

      gateway.nextPurchaseErrorCode = 'payment_declined';
      final failed = await gateway.purchase(
        OpennoteSubscriptionCatalog.monthlySkuId,
      );
      expect(failed.status, PurchaseStatus.failed);
      expect(failed.errorCode, 'payment_declined');

      final unknown = await gateway.purchase('com.opennote.unknown');
      expect(unknown.status, PurchaseStatus.failed);
      expect(unknown.errorCode, 'unknown_sku');
    });

    test(
      'openManageSubscriptions increments counter and returns true',
      () async {
        expect(await gateway.openManageSubscriptions(), isTrue);
        expect(gateway.manageSubscriptionsOpenCount, 1);
      },
    );
  });

  group('StoreKitPlayBillingBridge', () {
    const channel = MethodChannel('com.opennote.test/monetization');

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('gracefully falls back when native plugin is missing', () async {
      final bridge = StoreKitPlayBillingBridge(channel: channel);
      final catalog = await bridge.fetchCatalog();
      expect(catalog, OpennoteSubscriptionCatalog.defaultPlans);

      final purchase = await bridge.purchase(
        OpennoteSubscriptionCatalog.annualSkuId,
      );
      expect(purchase.status, PurchaseStatus.failed);
      expect(purchase.errorCode, 'store_unavailable');

      expect(await bridge.restorePurchases(), isEmpty);
      expect(await bridge.verifyEntitlement(), isNull);
      expect(await bridge.openManageSubscriptions(), isFalse);
    });

    test(
      'merges native localized prices and handles method channel calls',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              switch (call.method) {
                case 'fetchCatalog':
                  return [
                    {
                      'skuId': OpennoteSubscriptionCatalog.annualSkuId,
                      'localizedPrice': '£24.99',
                      'currencyCode': 'GBP',
                      'currencySymbol': '£',
                      'price': 24.99,
                    },
                  ];
                case 'purchase':
                  return {
                    'status': 'purchased',
                    'skuId': OpennoteSubscriptionCatalog.annualSkuId,
                    'transactionId': 'apple_tx_42',
                    'purchasedAt': '2026-06-01T12:00:00Z',
                    'expiresAt': '2026-06-08T12:00:00Z',
                    'isInTrial': true,
                  };
                case 'verifyEntitlement':
                  return {
                    'activeSkuId': OpennoteSubscriptionCatalog.annualSkuId,
                    'verifiedAt': '2026-06-01T12:05:00Z',
                    'expiresAt': '2026-06-08T12:00:00Z',
                    'isInTrial': true,
                  };
                case 'openManageSubscriptions':
                  return true;
                default:
                  return null;
              }
            });

        final bridge = StoreKitPlayBillingBridge(channel: channel);
        final catalog = await bridge.fetchCatalog();
        final annual = catalog.firstWhere(
          (plan) => plan.skuId == OpennoteSubscriptionCatalog.annualSkuId,
        );
        expect(annual.formattedPrice, '£24.99');
        expect(annual.currencyCode, 'GBP');

        final purchase = await bridge.purchase(
          OpennoteSubscriptionCatalog.annualSkuId,
        );
        expect(purchase.isSuccess, isTrue);
        expect(purchase.tier, SubscriptionTier.proAnnual);
        expect(purchase.transactionId, 'apple_tx_42');

        final verified = await bridge.verifyEntitlement();
        expect(verified?.tier, SubscriptionTier.proAnnual);
        expect(verified?.isInTrial, isTrue);

        expect(await bridge.openManageSubscriptions(), isTrue);
      },
    );
  });
}
