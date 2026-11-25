/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:saber/data/monetization/conversion_analytics.dart';

/// Configurable thresholds governing when Opennote prompts for a store review.
@immutable
class ReviewPromptPolicy {
  const ReviewPromptPolicy({
    this.minNotesForAha = 3,
    this.minPdfExportsForAha = 1,
    this.cooldownDays = 45,
    this.errorCooldownHours = 24,
    this.maxLifetimePrompts = 3,
  });

  /// Minimum completed notes required to count as an "Aha" moment.
  final int minNotesForAha;

  /// Minimum completed PDF exports required to count as an "Aha" moment.
  final int minPdfExportsForAha;

  /// Minimum days between consecutive review prompts.
  final int cooldownDays;

  /// Minimum hours to suppress prompts after a recorded error or crash.
  final int errorCooldownHours;

  /// Lifetime cap on review prompts so users are never nagged.
  final int maxLifetimePrompts;
}

/// Explanation returned by [ReviewPromptService.evaluateEligibility].
enum ReviewPromptBlockReason {
  eligible,
  alreadyRated,
  maxPromptsReached,
  noAhaMomentYet,
  inPromptCooldown,
  recentError,
}

/// Persisted user milestone & cooldown state for ASO review prompts.
@immutable
class ReviewPromptState {
  const ReviewPromptState({
    this.completedNotesCount = 0,
    this.completedPdfExportsCount = 0,
    this.lastPromptedAt,
    this.lastErrorAt,
    this.hasRated = false,
    this.promptCount = 0,
  });

  /// Reconstructs [ReviewPromptState] from a JSON map.
  factory ReviewPromptState.fromJson(Map<String, dynamic> json) {
    return ReviewPromptState(
      completedNotesCount: (json['completedNotesCount'] as num?)?.toInt() ?? 0,
      completedPdfExportsCount:
          (json['completedPdfExportsCount'] as num?)?.toInt() ?? 0,
      lastPromptedAt: _parseIsoDate(json['lastPromptedAt']),
      lastErrorAt: _parseIsoDate(json['lastErrorAt']),
      hasRated: json['hasRated'] as bool? ?? false,
      promptCount: (json['promptCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Number of notes the user has meaningfully created or edited.
  final int completedNotesCount;

  /// Number of PDF exports the user has successfully completed.
  final int completedPdfExportsCount;

  /// UTC timestamp of the most recent review prompt shown.
  final DateTime? lastPromptedAt;

  /// UTC timestamp of the most recent user-visible error.
  final DateTime? lastErrorAt;

  /// Whether the user has already accepted and rated Opennote.
  final bool hasRated;

  /// Total number of review prompts shown over the install lifetime.
  final int promptCount;

  /// Returns a copy with selectively updated fields.
  ReviewPromptState copyWith({
    int? completedNotesCount,
    int? completedPdfExportsCount,
    DateTime? lastPromptedAt,
    DateTime? lastErrorAt,
    bool? hasRated,
    int? promptCount,
  }) {
    return ReviewPromptState(
      completedNotesCount: completedNotesCount ?? this.completedNotesCount,
      completedPdfExportsCount:
          completedPdfExportsCount ?? this.completedPdfExportsCount,
      lastPromptedAt: lastPromptedAt ?? this.lastPromptedAt,
      lastErrorAt: lastErrorAt ?? this.lastErrorAt,
      hasRated: hasRated ?? this.hasRated,
      promptCount: promptCount ?? this.promptCount,
    );
  }

  /// Serializes this state for local persistence (e.g. `stows`).
  Map<String, dynamic> toJson() => {
    'completedNotesCount': completedNotesCount,
    'completedPdfExportsCount': completedPdfExportsCount,
    'lastPromptedAt': lastPromptedAt?.toUtc().toIso8601String(),
    'lastErrorAt': lastErrorAt?.toUtc().toIso8601String(),
    'hasRated': hasRated,
    'promptCount': promptCount,
  };
}

/// Smart ASO rating velocity engine that triggers store review prompts only
/// after genuine "Aha" moments and enforces strict anti-nag & post-error guards.
class ReviewPromptService {
  ReviewPromptService({
    ReviewPromptState initialState = const ReviewPromptState(),
    this.policy = const ReviewPromptPolicy(),
    DateTime Function()? clock,
    this._analytics,
    this._onStateChanged,
  }) : _state = initialState,
       _clock = clock ?? _utcNow;

  /// Active eligibility thresholds and cooldown durations.
  final ReviewPromptPolicy policy;

  final DateTime Function() _clock;
  final ConversionAnalytics? _analytics;
  final FutureOr<void> Function(ReviewPromptState state)? _onStateChanged;

  ReviewPromptState _state;

  /// Current milestone and cooldown state.
  ReviewPromptState get state => _state;

  /// Returns true when all ASO eligibility criteria and cooldowns are satisfied.
  bool shouldPromptReview({DateTime? now}) =>
      evaluateEligibility(now: now) == ReviewPromptBlockReason.eligible;

  /// Evaluates why a review prompt is eligible or currently suppressed.
  ReviewPromptBlockReason evaluateEligibility({DateTime? now}) {
    final currentTime = (now ?? _clock()).toUtc();

    if (_state.hasRated) {
      return ReviewPromptBlockReason.alreadyRated;
    }

    if (_state.promptCount >= policy.maxLifetimePrompts) {
      return ReviewPromptBlockReason.maxPromptsReached;
    }

    final reachedAhaMoment =
        _state.completedNotesCount >= policy.minNotesForAha ||
        _state.completedPdfExportsCount >= policy.minPdfExportsForAha;
    if (!reachedAhaMoment) {
      return ReviewPromptBlockReason.noAhaMomentYet;
    }

    if (_state.lastErrorAt != null) {
      final sinceError = currentTime.difference(_state.lastErrorAt!);
      if (sinceError < Duration(hours: policy.errorCooldownHours)) {
        return ReviewPromptBlockReason.recentError;
      }
    }

    if (_state.lastPromptedAt != null) {
      final sincePrompt = currentTime.difference(_state.lastPromptedAt!);
      if (sincePrompt < Duration(days: policy.cooldownDays)) {
        return ReviewPromptBlockReason.inPromptCooldown;
      }
    }

    return ReviewPromptBlockReason.eligible;
  }

  /// Records that the user completed a meaningful note session.
  Future<void> recordNoteCompleted() => _update(
    _state.copyWith(completedNotesCount: _state.completedNotesCount + 1),
  );

  /// Records that the user successfully exported a PDF.
  Future<void> recordPdfExportCompleted() => _update(
    _state.copyWith(
      completedPdfExportsCount: _state.completedPdfExportsCount + 1,
    ),
  );

  /// Records a user-visible error, suppressing review prompts during cooldown.
  Future<void> recordError() =>
      _update(_state.copyWith(lastErrorAt: _clock().toUtc()));

  /// Records that the review prompt UI was shown to the user.
  Future<void> recordPromptShown() async {
    await _update(
      _state.copyWith(
        lastPromptedAt: _clock().toUtc(),
        promptCount: _state.promptCount + 1,
      ),
    );
    _analytics?.log(
      ConversionEventType.reviewPromptShown,
      properties: {'promptCount': _state.promptCount},
    );
  }

  /// Records that the user accepted the review prompt and rated Opennote.
  Future<void> recordUserRated() async {
    await _update(
      _state.copyWith(
        hasRated: true,
        lastPromptedAt: _state.lastPromptedAt ?? _clock().toUtc(),
      ),
    );
    _analytics?.log(ConversionEventType.reviewPromptAccepted);
  }

  /// Restores state from persisted JSON (e.g. loaded from `stows`).
  void hydrateFromJson(Map<String, dynamic> json) {
    _state = ReviewPromptState.fromJson(json);
  }

  Future<void> _update(ReviewPromptState next) async {
    _state = next;
    await _onStateChanged?.call(_state);
  }
}

DateTime _utcNow() => DateTime.now().toUtc();

DateTime? _parseIsoDate(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toUtc();
  }
  return null;
}
