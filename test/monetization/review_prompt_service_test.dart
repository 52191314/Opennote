/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:saber/data/monetization/monetization.dart';

void main() {
  group('ReviewPromptService', () {
    late DateTime now;
    late ConversionAnalytics analytics;
    late ReviewPromptService service;

    setUp(() {
      now = DateTime.utc(2026, 6, 1, 9);
      analytics = ConversionAnalytics(clock: () => now);
      service = ReviewPromptService(clock: () => now, analytics: analytics);
    });

    test(
      'blocks prompt before Aha moment and unlocks at 3 notes or 1 PDF export',
      () async {
        expect(service.shouldPromptReview(), isFalse);
        expect(
          service.evaluateEligibility(),
          ReviewPromptBlockReason.noAhaMomentYet,
        );

        await service.recordNoteCompleted();
        await service.recordNoteCompleted();
        expect(service.shouldPromptReview(), isFalse);

        await service.recordNoteCompleted();
        expect(service.shouldPromptReview(), isTrue);
        expect(service.evaluateEligibility(), ReviewPromptBlockReason.eligible);

        // Fresh service unlocks immediately after 1 completed PDF export.
        final exportService = ReviewPromptService(clock: () => now);
        await exportService.recordPdfExportCompleted();
        expect(exportService.shouldPromptReview(), isTrue);
      },
    );

    test('enforces 45-day cooldown between prompts and lifetime cap', () async {
      await service.recordPdfExportCompleted();
      expect(service.shouldPromptReview(), isTrue);

      await service.recordPromptShown();
      expect(
        analytics.summarize().countOf(ConversionEventType.reviewPromptShown),
        1,
      );
      expect(service.shouldPromptReview(), isFalse);
      expect(
        service.evaluateEligibility(),
        ReviewPromptBlockReason.inPromptCooldown,
      );

      // 44 days later -> still in cooldown.
      now = now.add(const Duration(days: 44));
      expect(service.shouldPromptReview(), isFalse);

      // 45 days later -> eligible again.
      now = now.add(const Duration(days: 1));
      expect(service.shouldPromptReview(), isTrue);

      // Prompt 2 and 3 reach maxLifetimePrompts (3).
      await service.recordPromptShown();
      now = now.add(const Duration(days: 46));
      await service.recordPromptShown();
      now = now.add(const Duration(days: 46));
      expect(service.shouldPromptReview(), isFalse);
      expect(
        service.evaluateEligibility(),
        ReviewPromptBlockReason.maxPromptsReached,
      );
    });

    test('suppresses prompt after an error for 24 hours', () async {
      await service.recordPdfExportCompleted();
      await service.recordError();

      expect(service.shouldPromptReview(), isFalse);
      expect(
        service.evaluateEligibility(),
        ReviewPromptBlockReason.recentError,
      );

      now = now.add(const Duration(hours: 23));
      expect(service.shouldPromptReview(), isFalse);

      now = now.add(const Duration(hours: 1));
      expect(service.shouldPromptReview(), isTrue);
    });

    test(
      'never prompts again once user has rated and supports JSON persistence',
      () async {
        Map<String, dynamic>? saved;
        final persistentService = ReviewPromptService(
          clock: () => now,
          analytics: analytics,
          onStateChanged: (state) => saved = state.toJson(),
        );

        await persistentService.recordPdfExportCompleted();
        await persistentService.recordPromptShown();
        await persistentService.recordUserRated();

        expect(persistentService.shouldPromptReview(), isFalse);
        expect(
          persistentService.evaluateEligibility(),
          ReviewPromptBlockReason.alreadyRated,
        );
        expect(
          analytics.summarize().countOf(
            ConversionEventType.reviewPromptAccepted,
          ),
          1,
        );
        expect(saved, isNotNull);

        final rehydrated = ReviewPromptService(clock: () => now);
        rehydrated.hydrateFromJson(saved!);
        expect(rehydrated.state.hasRated, isTrue);
        expect(rehydrated.shouldPromptReview(), isFalse);
      },
    );
  });
}
