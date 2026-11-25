/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:saber/data/monetization/monetization.dart';

void main() {
  group('ConversionAnalytics', () {
    test('enforces bounded ring buffer size', () {
      var tick = DateTime.utc(2026, 6, 1);
      final analytics = ConversionAnalytics(
        maxEvents: 3,
        clock: () => tick = tick.add(const Duration(seconds: 1)),
      );

      analytics.log(ConversionEventType.onboardingStarted);
      analytics.log(ConversionEventType.personaSelected);
      analytics.log(ConversionEventType.onboardingCompleted);
      analytics.log(ConversionEventType.paywallViewed);

      expect(analytics.events, hasLength(3));
      expect(analytics.events.first.type, ConversionEventType.personaSelected);
      expect(analytics.events.last.type, ConversionEventType.paywallViewed);
    });

    test('strips sensitive PII keys from event properties', () {
      final analytics = ConversionAnalytics(
        clock: () => DateTime.utc(2026, 6, 1),
      );
      final event = analytics.log(
        ConversionEventType.planSelected,
        properties: {
          'skuId': OpennoteSubscriptionCatalog.annualSkuId,
          'email': 'user@example.com',
          'userToken': 'secret',
          'receiptData': 'raw_receipt',
          'isRecommended': true,
        },
      );

      expect(
        event.properties['skuId'],
        OpennoteSubscriptionCatalog.annualSkuId,
      );
      expect(event.properties['isRecommended'], isTrue);
      expect(event.properties.containsKey('email'), isFalse);
      expect(event.properties.containsKey('userToken'), isFalse);
      expect(event.properties.containsKey('receiptData'), isFalse);

      final roundtripped = ConversionEvent.fromJson(event.toJson());
      expect(roundtripped.type, ConversionEventType.planSelected);
      expect(
        roundtripped.properties['skuId'],
        OpennoteSubscriptionCatalog.annualSkuId,
      );
    });

    test('computes funnel conversion rates and exports JSON summary', () {
      final analytics = ConversionAnalytics(
        clock: () => DateTime.utc(2026, 6, 1),
      );

      // Empty summary should have zero rates without NaN.
      final emptySummary = analytics.summarize();
      expect(emptySummary.totalEvents, 0);
      expect(emptySummary.onboardingCompletionRate, 0.0);
      expect(emptySummary.paywallToPurchaseRate, 0.0);

      analytics.log(ConversionEventType.onboardingStarted);
      analytics.log(ConversionEventType.onboardingStarted);
      analytics.log(ConversionEventType.onboardingCompleted);
      analytics.log(ConversionEventType.proGateTriggered);
      analytics.log(ConversionEventType.proGateTriggered);
      analytics.log(ConversionEventType.paywallViewed);
      analytics.log(ConversionEventType.paywallViewed);
      analytics.log(ConversionEventType.trialStarted);
      analytics.log(ConversionEventType.purchaseSucceeded);
      analytics.log(ConversionEventType.reviewPromptShown);
      analytics.log(ConversionEventType.reviewPromptShown);
      analytics.log(ConversionEventType.reviewPromptAccepted);

      final summary = analytics.summarize();
      expect(summary.totalEvents, 12);
      expect(summary.onboardingCompletionRate, closeTo(0.5, 0.001));
      expect(summary.proGateToPaywallRate, closeTo(1.0, 0.001));
      expect(summary.paywallToTrialRate, closeTo(0.5, 0.001));
      expect(summary.paywallToPurchaseRate, closeTo(0.5, 0.001));
      expect(summary.reviewAcceptanceRate, closeTo(0.5, 0.001));

      final exported = analytics.exportSummaryJson(includeEvents: true);
      expect(exported['maxEvents'], 250);
      expect((exported['events'] as List<dynamic>), hasLength(12));
      expect((exported['summary'] as Map<String, dynamic>)['totalEvents'], 12);
    });
  });
}
