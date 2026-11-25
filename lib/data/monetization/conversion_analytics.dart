/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:collection';

import 'package:meta/meta.dart';

/// Privacy-first conversion funnel event types tracked locally in Opennote.
enum ConversionEventType {
  onboardingStarted,
  onboardingCompleted,
  personaSelected,
  paywallViewed,
  paywallDismissed,
  planSelected,
  trialStarted,
  purchaseSucceeded,
  purchaseFailed,
  restoreSucceeded,
  proGateTriggered,
  reviewPromptShown,
  reviewPromptAccepted,
}

/// Immutable, PII-free conversion funnel event.
@immutable
class ConversionEvent {
  ConversionEvent({
    required this.type,
    required this.timestamp,
    Map<String, Object?> properties = const {},
  }) : properties = Map.unmodifiable(_sanitizeProperties(properties));

  /// Reconstructs a [ConversionEvent] from a JSON map.
  factory ConversionEvent.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? '';
    final type = ConversionEventType.values.firstWhere(
      (value) => value.name == typeName,
      orElse: () => ConversionEventType.paywallViewed,
    );
    final rawProps = json['properties'];
    final props = rawProps is Map<String, dynamic>
        ? rawProps
        : const <String, Object?>{};
    return ConversionEvent(
      type: type,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      properties: props,
    );
  }

  /// Funnel stage event identifier.
  final ConversionEventType type;

  /// UTC timestamp when the event was recorded.
  final DateTime timestamp;

  /// Non-PII scalar context attributes (e.g. `skuId`, `feature`, `persona`).
  final Map<String, Object?> properties;

  /// Serializes this event to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'timestamp': timestamp.toUtc().toIso8601String(),
    if (properties.isNotEmpty) 'properties': properties,
  };

  static const _blockedKeys = {
    'email',
    'name',
    'fullName',
    'phone',
    'token',
    'password',
    'receipt',
    'userId',
    'ip',
    'ipAddress',
  };

  static Map<String, Object?> _sanitizeProperties(Map<String, Object?> raw) {
    if (raw.isEmpty) return const {};
    final sanitized = <String, Object?>{};
    for (final entry in raw.entries) {
      final lowerKey = entry.key.toLowerCase();
      if (_blockedKeys.any((blocked) => lowerKey.contains(blocked))) {
        continue;
      }
      final value = entry.value;
      if (value == null || value is String || value is num || value is bool) {
        sanitized[entry.key] = value;
      } else {
        sanitized[entry.key] = value.toString();
      }
    }
    return sanitized;
  }
}

/// Aggregated funnel conversion metrics computed from buffered events.
@immutable
class FunnelSummaryMetrics {
  const FunnelSummaryMetrics({
    required this.totalEvents,
    required this.countsByType,
    required this.onboardingCompletionRate,
    required this.paywallToTrialRate,
    required this.paywallToPurchaseRate,
    required this.proGateToPaywallRate,
    required this.reviewAcceptanceRate,
  });

  /// Total events currently retained in the ring buffer.
  final int totalEvents;

  /// Per-event-type occurrence counts.
  final Map<ConversionEventType, int> countsByType;

  /// Ratio of `onboardingCompleted` to `onboardingStarted` (clamped 0.0–1.0).
  final double onboardingCompletionRate;

  /// Ratio of `trialStarted` to `paywallViewed` (clamped 0.0–1.0).
  final double paywallToTrialRate;

  /// Ratio of `purchaseSucceeded` to `paywallViewed` (clamped 0.0–1.0).
  final double paywallToPurchaseRate;

  /// Ratio of `paywallViewed` to `proGateTriggered` (clamped 0.0–1.0).
  final double proGateToPaywallRate;

  /// Ratio of `reviewPromptAccepted` to `reviewPromptShown` (clamped 0.0–1.0).
  final double reviewAcceptanceRate;

  /// Convenience lookup for any [type]'s recorded count.
  int countOf(ConversionEventType type) => countsByType[type] ?? 0;

  /// Exports metrics as a JSON-compatible map for diagnostics or local reports.
  Map<String, dynamic> toJson() => {
    'totalEvents': totalEvents,
    'countsByType': {
      for (final entry in countsByType.entries) entry.key.name: entry.value,
    },
    'rates': {
      'onboardingCompletionRate': onboardingCompletionRate,
      'paywallToTrialRate': paywallToTrialRate,
      'paywallToPurchaseRate': paywallToPurchaseRate,
      'proGateToPaywallRate': proGateToPaywallRate,
      'reviewAcceptanceRate': reviewAcceptanceRate,
    },
  };
}

/// Privacy-first in-memory conversion funnel logger backed by a bounded ring buffer.
class ConversionAnalytics {
  ConversionAnalytics({this.maxEvents = 250, DateTime Function()? clock})
    : assert(maxEvents > 0, 'maxEvents must be positive'),
      _clock = clock ?? _utcNow;

  /// Maximum number of events retained in the ring buffer.
  final int maxEvents;

  final DateTime Function() _clock;
  final _buffer = Queue<ConversionEvent>();

  /// Snapshot of buffered events ordered oldest to newest.
  List<ConversionEvent> get events => List.unmodifiable(_buffer);

  /// Records a new [ConversionEventType] with optional non-PII [properties].
  ConversionEvent log(
    ConversionEventType type, {
    Map<String, Object?> properties = const {},
  }) {
    final event = ConversionEvent(
      type: type,
      timestamp: _clock().toUtc(),
      properties: properties,
    );
    if (_buffer.length >= maxEvents) {
      _buffer.removeFirst();
    }
    _buffer.addLast(event);
    return event;
  }

  /// Computes funnel conversion summary metrics across the current buffer.
  FunnelSummaryMetrics summarize() {
    final counts = <ConversionEventType, int>{
      for (final type in ConversionEventType.values) type: 0,
    };
    for (final event in _buffer) {
      counts[event.type] = (counts[event.type] ?? 0) + 1;
    }

    return FunnelSummaryMetrics(
      totalEvents: _buffer.length,
      countsByType: Map.unmodifiable(counts),
      onboardingCompletionRate: _safeRate(
        counts[ConversionEventType.onboardingCompleted]!,
        counts[ConversionEventType.onboardingStarted]!,
      ),
      paywallToTrialRate: _safeRate(
        counts[ConversionEventType.trialStarted]!,
        counts[ConversionEventType.paywallViewed]!,
      ),
      paywallToPurchaseRate: _safeRate(
        counts[ConversionEventType.purchaseSucceeded]!,
        counts[ConversionEventType.paywallViewed]!,
      ),
      proGateToPaywallRate: _safeRate(
        counts[ConversionEventType.paywallViewed]!,
        counts[ConversionEventType.proGateTriggered]!,
      ),
      reviewAcceptanceRate: _safeRate(
        counts[ConversionEventType.reviewPromptAccepted]!,
        counts[ConversionEventType.reviewPromptShown]!,
      ),
    );
  }

  /// Exports the aggregated summary and buffer metadata as JSON.
  Map<String, dynamic> exportSummaryJson({bool includeEvents = false}) {
    final summary = summarize();
    return {
      'generatedAt': _clock().toUtc().toIso8601String(),
      'maxEvents': maxEvents,
      'summary': summary.toJson(),
      if (includeEvents)
        'events': _buffer.map((event) => event.toJson()).toList(),
    };
  }

  /// Clears all buffered events.
  void clear() => _buffer.clear();

  static double _safeRate(int numerator, int denominator) {
    if (denominator <= 0) return 0.0;
    final ratio = numerator / denominator;
    return ratio.clamp(0.0, 1.0);
  }
}

DateTime _utcNow() => DateTime.now().toUtc();
