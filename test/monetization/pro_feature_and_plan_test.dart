/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:saber/data/monetization/monetization.dart';

void main() {
  group('ProFeature', () {
    test('every ProFeature has non-empty copy, bullets, and iconName', () {
      for (final feature in ProFeature.values) {
        expect(feature.displayTitle, isNotEmpty);
        expect(feature.valueProposition, isNotEmpty);
        expect(feature.benefitBullets, hasLength(greaterThanOrEqualTo(3)));
        expect(feature.iconName, isNotEmpty);
      }
    });

    test('shippingFeatures excludes roadmap-only aiHandwritingTools', () {
      expect(ProFeature.aiHandwritingTools.isRoadmap, isTrue);
      expect(
        ProFeature.shippingFeatures,
        isNot(contains(ProFeature.aiHandwritingTools)),
      );
      expect(ProFeature.shippingFeatures.length, ProFeature.values.length - 1);
    });

    test('byCategory filters features accurately', () {
      final exportFeatures = ProFeature.byCategory(ProFeatureCategory.export);
      expect(
        exportFeatures,
        containsAll([
          ProFeature.vectorSvgExport,
          ProFeature.batchPdfExport,
          ProFeature.pdfDarkModePro,
        ]),
      );
    });
  });

  group('SubscriptionTier', () {
    test('storageKey roundtrip and tier predicates', () {
      for (final tier in SubscriptionTier.values) {
        expect(SubscriptionTier.fromStorageKey(tier.storageKey), tier);
      }
      expect(SubscriptionTier.fromStorageKey('unknown'), SubscriptionTier.free);
      expect(SubscriptionTier.fromStorageKey(null), SubscriptionTier.free);

      expect(SubscriptionTier.free.isPro, isFalse);
      expect(SubscriptionTier.proMonthly.isRecurring, isTrue);
      expect(SubscriptionTier.proAnnual.isRecurring, isTrue);
      expect(SubscriptionTier.proStudentAnnual.isStudent, isTrue);
      expect(SubscriptionTier.proLifetime.isLifetime, isTrue);
      expect(SubscriptionTier.proLifetime.isRecurring, isFalse);
    });
  });

  group('SubscriptionPlan pricing math', () {
    test(
      'calculates monthly equivalent and savings percentages accurately',
      () {
        const monthly = OpennoteSubscriptionCatalog.proMonthly;
        const annual = OpennoteSubscriptionCatalog.proAnnual;
        const student = OpennoteSubscriptionCatalog.proStudentAnnual;
        const lifetime = OpennoteSubscriptionCatalog.proLifetime;

        expect(monthly.formattedPrice, r'$4.99');
        expect(monthly.formattedPriceWithPeriod, r'$4.99/mo');
        expect(monthly.monthlyEquivalentPrice, closeTo(4.99, 0.001));
        expect(monthly.savingsPercentAgainst(monthly), 0);

        expect(annual.formattedPrice, r'$29.99');
        expect(annual.formattedPriceWithPeriod, r'$29.99/yr');
        expect(annual.monthlyEquivalentPrice, closeTo(2.499, 0.002));
        expect(annual.formattedMonthlyEquivalent, r'$2.50/mo');
        expect(annual.savingsPercentAgainst(monthly), 50);
        expect(annual.hasFreeTrial, isTrue);
        expect(annual.trialDays, 7);
        expect(annual.isRecommended, isTrue);

        expect(student.formattedPriceWithPeriod, r'$14.99/yr');
        expect(student.formattedMonthlyEquivalent, r'$1.25/mo');
        expect(student.savingsPercentAgainst(monthly), 75);

        expect(lifetime.formattedPriceWithPeriod, r'$69.99 one-time');
        expect(lifetime.monthlyEquivalentPrice, isNull);
        expect(lifetime.formattedMonthlyEquivalent, isNull);
        expect(lifetime.savingsPercentAgainst(monthly), 0);
        expect(lifetime.hasFreeTrial, isFalse);
      },
    );

    test('supports localized store price override and JSON roundtrip', () {
      final eurPlan = OpennoteSubscriptionCatalog.proAnnual.copyWith(
        currencyCode: 'EUR',
        currencySymbol: '€',
        localizedPrice: '€29,99',
      );
      expect(eurPlan.formattedPrice, '€29,99');
      expect(eurPlan.formattedPriceWithPeriod, '€29,99/yr');

      final roundtripped = SubscriptionPlan.fromJson(eurPlan.toJson());
      expect(roundtripped, eurPlan);
    });

    test('catalog lookups resolve known SKUs and tiers', () {
      expect(
        OpennoteSubscriptionCatalog.planForSku(
          OpennoteSubscriptionCatalog.annualSkuId,
        ),
        OpennoteSubscriptionCatalog.proAnnual,
      );
      expect(
        OpennoteSubscriptionCatalog.planForTier(SubscriptionTier.proLifetime),
        OpennoteSubscriptionCatalog.proLifetime,
      );
      expect(
        OpennoteSubscriptionCatalog.planForTier(SubscriptionTier.free),
        isNull,
      );
      expect(OpennoteSubscriptionCatalog.planForSku('invalid'), isNull);
    });
  });

  group('StoreKit & Catalog JSON parity', () {
    test('OpennoteProducts.storekit defines all canonical SKUs and trials', () {
      final file = File('ios/Runner/OpennoteProducts.storekit');
      expect(file.existsSync(), isTrue);

      final parsed =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final products = parsed['products'] as List<dynamic>;
      final groups = parsed['subscriptionGroups'] as List<dynamic>;
      final group = groups.first as Map<String, dynamic>;
      final subs = group['subscriptions'] as List<dynamic>;

      expect(group['name'], 'Opennote Pro');

      final allSkus = <String>{
        for (final p in products)
          (p as Map<String, dynamic>)['productID'] as String,
        for (final s in subs)
          (s as Map<String, dynamic>)['productID'] as String,
      };
      expect(
        allSkus,
        containsAll([
          OpennoteSubscriptionCatalog.monthlySkuId,
          OpennoteSubscriptionCatalog.annualSkuId,
          OpennoteSubscriptionCatalog.studentAnnualSkuId,
          OpennoteSubscriptionCatalog.lifetimeSkuId,
        ]),
      );

      final annualSub = subs.cast<Map<String, dynamic>>().firstWhere(
        (s) => s['productID'] == OpennoteSubscriptionCatalog.annualSkuId,
      );
      final intro = annualSub['introductoryOffer'] as Map<String, dynamic>;
      expect(intro['paymentMode'], 'free');
      expect(intro['subscriptionPeriod'], 'P1W');
    });

    test('docs/monetization/iap_product_catalog.json matches Dart catalog', () {
      final file = File('docs/monetization/iap_product_catalog.json');
      expect(file.existsSync(), isTrue);

      final parsed =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final products = (parsed['products'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final skus = products.map((p) => p['skuId'] as String).toSet();
      expect(
        skus,
        containsAll([
          OpennoteSubscriptionCatalog.monthlySkuId,
          OpennoteSubscriptionCatalog.annualSkuId,
          OpennoteSubscriptionCatalog.studentAnnualSkuId,
          OpennoteSubscriptionCatalog.lifetimeSkuId,
        ]),
      );

      final features = (parsed['proFeaturesUnlocked'] as List<dynamic>)
          .cast<String>()
          .toSet();
      expect(features, ProFeature.values.map((f) => f.name).toSet());
    });
  });
}
