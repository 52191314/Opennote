/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:saber/data/prefs/stow_helpers.dart';
import 'package:stow_plain/stow_plain.dart';

/// Onboarding, monetization entitlement caching, usage milestones, and
/// in-app review prompt preferences.
mixin GrowthPrefs {
  /// Whether the user has completed or dismissed the initial onboarding guide.
  final hasSeenOnboarding = PlainStow<bool>(
    'hasSeenOnboarding',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the user has completed the new persona-driven onboarding flow.
  final onboardingCompleted = PlainStow<bool>(
    'onboardingCompleted',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Persona identifier selected during onboarding (empty when unset).
  final onboardingPersona = PlainStow<String>(
    'onboardingPersona',
    '',
    volatile: StowIsolate.isVolatile,
  );

  /// Cached subscription tier identifier (e.g. `'free'`, `'pro'`).
  final proTierCached = PlainStow<String>(
    'proTierCached',
    'free',
    volatile: StowIsolate.isVolatile,
  );

  /// Epoch timestamp (ms) when the user's Pro trial started, or `0` if none.
  final proTrialStartEpochMs = PlainStow<int>(
    'proTrialStartEpochMs',
    0,
    volatile: StowIsolate.isVolatile,
  );

  /// Epoch timestamp (ms) when the cached Pro entitlement expires, or `0`.
  final proExpirationEpochMs = PlainStow<int>(
    'proExpirationEpochMs',
    0,
    volatile: StowIsolate.isVolatile,
  );

  /// Cumulative count of notes created by the user.
  final notesCreatedCount = PlainStow<int>(
    'notesCreatedCount',
    0,
    volatile: StowIsolate.isVolatile,
  );

  /// Cumulative count of completed note exports (PDF, PNG, etc.).
  final exportsCompletedCount = PlainStow<int>(
    'exportsCompletedCount',
    0,
    volatile: StowIsolate.isVolatile,
  );

  /// Epoch timestamp (ms) of the last in-app review prompt, or `0` if never.
  final lastReviewPromptEpochMs = PlainStow<int>(
    'lastReviewPromptEpochMs',
    0,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the user has already rated the app.
  final hasRatedApp = PlainStow<bool>(
    'hasRatedApp',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Total number of times the paywall has been shown to the user.
  final paywallImpressionsCount = PlainStow<int>(
    'paywallImpressionsCount',
    0,
    volatile: StowIsolate.isVolatile,
  );
}
