/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:saber/data/monetization/conversion_analytics.dart';
import 'package:saber/data/monetization/pro_feature.dart';
import 'package:saber/data/monetization/purchase_gateway.dart';
import 'package:saber/data/monetization/subscription_plan.dart';

/// Immutable snapshot of the user's current Opennote subscription entitlement.
@immutable
class EntitlementState {
  const EntitlementState({
    required this.tier,
    this.isInTrial = false,
    this.expiresAt,
    this.activeSkuId,
    this.lastVerifiedAt,
  });

  /// Default free-tier entitlement state.
  const EntitlementState.free()
    : tier = SubscriptionTier.free,
      isInTrial = false,
      expiresAt = null,
      activeSkuId = null,
      lastVerifiedAt = null;

  /// Reconstructs an [EntitlementState] from persisted JSON.
  factory EntitlementState.fromJson(Map<String, dynamic> json) {
    return EntitlementState(
      tier: SubscriptionTier.fromStorageKey(json['tier'] as String?),
      isInTrial: json['isInTrial'] as bool? ?? false,
      expiresAt: _parseIsoDate(json['expiresAt']),
      activeSkuId: json['activeSkuId'] as String?,
      lastVerifiedAt: _parseIsoDate(json['lastVerifiedAt']),
    );
  }

  /// Current entitlement tier.
  final SubscriptionTier tier;

  /// Whether the active entitlement is currently inside a free trial window.
  final bool isInTrial;

  /// UTC expiration timestamp for recurring/trial entitlements, or null for
  /// free and lifetime entitlements.
  final DateTime? expiresAt;

  /// Store SKU backing the active entitlement, if any.
  final String? activeSkuId;

  /// Last UTC timestamp when the entitlement was verified or updated.
  final DateTime? lastVerifiedAt;

  /// Whether the user currently holds an active (non-expired) Pro entitlement.
  bool get isPro => isProAt(DateTime.now().toUtc());

  /// Evaluates whether the Pro entitlement is active at [referenceTime].
  bool isProAt(DateTime referenceTime) {
    if (!tier.isPro) return false;
    if (tier.isLifetime || expiresAt == null) return true;
    return expiresAt!.isAfter(referenceTime.toUtc());
  }

  /// Whether a time-bound entitlement has passed [referenceTime].
  bool isExpiredAt(DateTime referenceTime) {
    if (!tier.isPro || tier.isLifetime || expiresAt == null) return false;
    return !expiresAt!.isAfter(referenceTime.toUtc());
  }

  /// Whole days remaining in an active trial (rounded up), or 0 if not in trial.
  int get trialDaysRemaining => trialDaysRemainingAt(DateTime.now().toUtc());

  /// Whole days remaining in an active trial relative to [referenceTime].
  int trialDaysRemainingAt(DateTime referenceTime) {
    if (!isInTrial || expiresAt == null) return 0;
    final remaining = expiresAt!.difference(referenceTime.toUtc());
    if (remaining <= Duration.zero) return 0;
    return (remaining.inSeconds / Duration.secondsPerDay).ceil();
  }

  /// Serializes this entitlement snapshot for local storage (e.g. `stows`).
  Map<String, dynamic> toJson() => {
    'tier': tier.storageKey,
    'isInTrial': isInTrial,
    'expiresAt': expiresAt?.toUtc().toIso8601String(),
    'activeSkuId': activeSkuId,
    'lastVerifiedAt': lastVerifiedAt?.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntitlementState &&
        other.tier == tier &&
        other.isInTrial == isInTrial &&
        other.expiresAt == expiresAt &&
        other.activeSkuId == activeSkuId &&
        other.lastVerifiedAt == lastVerifiedAt;
  }

  @override
  int get hashCode =>
      Object.hash(tier, isInTrial, expiresAt, activeSkuId, lastVerifiedAt);
}

/// Policy outcome for a [ProFeature] access check.
enum FeatureAccessDecision {
  /// Feature is unlocked and can be used without interruption.
  allowed,

  /// Feature is usable, but the UI should present a non-blocking Pro upsell.
  softPrompt,

  /// Feature is locked and requires an Opennote Pro entitlement to proceed.
  hardGate,
}

/// Structured evaluation returned by [EntitlementService.evaluateFeature].
@immutable
class FeatureAccessResult {
  const FeatureAccessResult({
    required this.feature,
    required this.decision,
    required this.reason,
  });

  /// Evaluated Pro feature.
  final ProFeature feature;

  /// Policy decision for the current user state.
  final FeatureAccessDecision decision;

  /// Short diagnostic explanation for UI banners and analytics.
  final String reason;

  /// Whether the caller should allow the user to proceed with the action.
  bool get isAllowed => decision != FeatureAccessDecision.hardGate;

  /// Whether the UI should surface a contextual Pro upgrade prompt.
  bool get shouldShowUpsell => decision != FeatureAccessDecision.allowed;
}

/// Persistence contract allowing `integrator` to bind [EntitlementService]
/// to `stows` or any local key-value store without adding dependencies.
abstract interface class EntitlementPersistenceAdapter {
  /// Loads the previously persisted entitlement JSON map, or null if absent.
  FutureOr<Map<String, dynamic>?> read();

  /// Persists the serialized entitlement JSON map.
  FutureOr<void> write(Map<String, dynamic> json);

  /// Clears any persisted entitlement state.
  FutureOr<void> clear();
}

/// Callback-based [EntitlementPersistenceAdapter] for lightweight `stows` binding.
class CallbackEntitlementPersistence implements EntitlementPersistenceAdapter {
  const CallbackEntitlementPersistence({
    required this._onRead,
    required this._onWrite,
    this._onClear,
  });

  final FutureOr<Map<String, dynamic>?> Function() _onRead;
  final FutureOr<void> Function(Map<String, dynamic> json) _onWrite;
  final FutureOr<void> Function()? _onClear;

  @override
  FutureOr<Map<String, dynamic>?> read() => _onRead();

  @override
  FutureOr<void> write(Map<String, dynamic> json) => _onWrite(json);

  @override
  FutureOr<void> clear() => _onClear?.call();
}

/// In-memory [EntitlementPersistenceAdapter] used by default and in unit tests.
class InMemoryEntitlementPersistence implements EntitlementPersistenceAdapter {
  Map<String, dynamic>? _stored;

  @override
  Map<String, dynamic>? read() => _stored == null ? null : Map.of(_stored!);

  @override
  void write(Map<String, dynamic> json) {
    _stored = Map.of(json);
  }

  @override
  void clear() {
    _stored = null;
  }
}

/// Reactive subscription & entitlement state controller for Opennote.
class EntitlementService extends ChangeNotifier {
  EntitlementService({
    PurchaseGateway? gateway,
    EntitlementPersistenceAdapter? persistence,
    ConversionAnalytics? analytics,
    DateTime Function()? clock,
    this.freeNotebookLimit = defaultFreeNotebookLimit,
    this._softPromptOnly = true,
  }) : _gateway = gateway ?? StoreKitPlayBillingBridge(),
       _persistence = persistence ?? InMemoryEntitlementPersistence(),
       _analytics = analytics ?? ConversionAnalytics(clock: clock),
       _clock = clock ?? _utcNow;

  /// Default number of notebooks allowed on the free tier before prompting.
  static const defaultFreeNotebookLimit = 5;

  static EntitlementService? _instance;

  /// Shared application-wide [EntitlementService] singleton.
  static EntitlementService get instance => _instance ??= EntitlementService();

  /// Replaces the shared singleton (primarily for DI setup and unit tests).
  @visibleForTesting
  static void setInstanceForTesting(EntitlementService service) {
    _instance = service;
  }

  /// Resets the shared singleton so tests start from a clean state.
  @visibleForTesting
  static void resetInstanceForTesting() {
    _instance = null;
  }

  final PurchaseGateway _gateway;
  final EntitlementPersistenceAdapter _persistence;
  final ConversionAnalytics _analytics;
  final DateTime Function() _clock;

  /// Maximum notebooks included on the free tier before Pro upsell triggers.
  final int freeNotebookLimit;

  var _state = const EntitlementState.free();
  List<SubscriptionPlan> _catalog = OpennoteSubscriptionCatalog.defaultPlans;
  var _isBusy = false;
  bool _softPromptOnly;

  /// Current entitlement snapshot (automatically downgrades if expired).
  EntitlementState get state {
    if (_state.isExpiredAt(_clock())) {
      return const EntitlementState.free();
    }
    return _state;
  }

  /// Whether the user currently has an active Opennote Pro entitlement.
  bool get isPro => state.isProAt(_clock());

  /// Whether the user is currently in an active free trial.
  bool get isInTrial => isPro && state.isInTrial;

  /// Whole days remaining in the active trial, or 0 if not in trial.
  int get trialDaysRemaining =>
      isInTrial ? state.trialDaysRemainingAt(_clock()) : 0;

  /// Available subscription and IAP plans loaded from the gateway or fallback.
  List<SubscriptionPlan> get catalog => List.unmodifiable(_catalog);

  /// Whether a purchase, restore, or verification request is currently in flight.
  bool get isBusy => _isBusy;

  /// When true, gated features emit [FeatureAccessDecision.softPrompt] instead
  /// of [FeatureAccessDecision.hardGate] so core free flows never break.
  bool get softPromptOnly => _softPromptOnly;

  /// Funnel analytics instance recording monetization lifecycle events.
  ConversionAnalytics get analytics => _analytics;

  /// Loads persisted entitlement state, refreshes the store catalog, and
  /// optionally verifies active store receipts.
  Future<void> initialize({bool verifyStore = true}) async {
    final stored = await _persistence.read();
    if (stored != null) {
      final restored = EntitlementState.fromJson(stored);
      _state = restored.isExpiredAt(_clock())
          ? const EntitlementState.free()
          : restored;
    }

    _catalog = await _gateway.fetchCatalog();

    if (verifyStore) {
      await verifyWithStore(notifyOnUnchanged: false);
    }

    notifyListeners();
  }

  /// Refreshes the product catalog from the configured [PurchaseGateway].
  Future<List<SubscriptionPlan>> loadCatalog() async {
    _catalog = await _gateway.fetchCatalog();
    notifyListeners();
    return catalog;
  }

  /// Updates the soft-prompt vs hard-gate enforcement policy.
  void setSoftPromptOnly(bool value) {
    if (_softPromptOnly == value) return;
    _softPromptOnly = value;
    notifyListeners();
  }

  /// Returns whether [currentNotebookCount] has reached [freeNotebookLimit].
  bool hasReachedFreeNotebookLimit(int currentNotebookCount) {
    if (isPro) return false;
    return currentNotebookCount >= freeNotebookLimit;
  }

  /// Evaluates access policy for [feature], optionally considering
  /// [currentNotebookCount] for [ProFeature.unlimitedNotebooks].
  FeatureAccessResult evaluateFeature(
    ProFeature feature, {
    int? currentNotebookCount,
    bool logGateEvent = false,
  }) {
    refreshExpiration(notify: false);

    if (isPro) {
      return FeatureAccessResult(
        feature: feature,
        decision: FeatureAccessDecision.allowed,
        reason: 'Active ${state.tier.storageKey} entitlement.',
      );
    }

    if (feature == ProFeature.unlimitedNotebooks &&
        currentNotebookCount != null &&
        currentNotebookCount < freeNotebookLimit) {
      return FeatureAccessResult(
        feature: feature,
        decision: FeatureAccessDecision.allowed,
        reason:
            'Within free allowance ($currentNotebookCount/$freeNotebookLimit notebooks).',
      );
    }

    if (logGateEvent) {
      _analytics.log(
        ConversionEventType.proGateTriggered,
        properties: {
          'feature': feature.name,
          'mode': _softPromptOnly ? 'soft_prompt' : 'hard_gate',
        },
      );
    }

    return FeatureAccessResult(
      feature: feature,
      decision: _softPromptOnly
          ? FeatureAccessDecision.softPrompt
          : FeatureAccessDecision.hardGate,
      reason: _softPromptOnly
          ? 'Free tier soft-prompt for ${feature.displayTitle}.'
          : 'Opennote Pro required for ${feature.displayTitle}.',
    );
  }

  /// Convenience boolean check for whether [feature] may be used right now.
  ///
  /// Returns true when Pro is active, when within free notebook allowance,
  /// or when [softPromptOnly] is enabled.
  bool canUseFeature(ProFeature feature, {int? currentNotebookCount}) =>
      evaluateFeature(
        feature,
        currentNotebookCount: currentNotebookCount,
      ).isAllowed;

  /// Purchases the plan identified by [skuId] through the [PurchaseGateway].
  Future<PurchaseResult> purchasePlan(String skuId) async {
    _setBusy(true);
    try {
      final result = await _gateway.purchase(skuId);
      if (result.isSuccess && result.tier.isPro) {
        final now = _clock().toUtc();
        _state = EntitlementState(
          tier: result.tier,
          isInTrial: result.isInTrial,
          expiresAt: result.expiresAt,
          activeSkuId: result.skuId,
          lastVerifiedAt: now,
        );
        await _persistence.write(_state.toJson());
        if (result.isInTrial) {
          _analytics.log(
            ConversionEventType.trialStarted,
            properties: {'skuId': result.skuId, 'tier': result.tier.storageKey},
          );
        }
        _analytics.log(
          ConversionEventType.purchaseSucceeded,
          properties: {
            'skuId': result.skuId,
            'tier': result.tier.storageKey,
            'isInTrial': result.isInTrial,
          },
        );
        notifyListeners();
      } else if (result.status == PurchaseStatus.failed) {
        _analytics.log(
          ConversionEventType.purchaseFailed,
          properties: {
            'skuId': skuId,
            'errorCode': result.errorCode ?? 'unknown',
          },
        );
      }
      return result;
    } finally {
      _setBusy(false);
    }
  }

  /// Restores prior purchases from the store and activates the highest-priority
  /// non-expired Pro entitlement found.
  Future<List<PurchaseResult>> restorePurchases() async {
    _setBusy(true);
    try {
      final results = await _gateway.restorePurchases();
      final now = _clock().toUtc();
      final best = _selectBestRestoredPurchase(results, now);
      if (best != null) {
        _state = EntitlementState(
          tier: best.tier,
          isInTrial: best.isInTrial,
          expiresAt: best.expiresAt,
          activeSkuId: best.skuId,
          lastVerifiedAt: now,
        );
        await _persistence.write(_state.toJson());
        _analytics.log(
          ConversionEventType.restoreSucceeded,
          properties: {'skuId': best.skuId, 'tier': best.tier.storageKey},
        );
        notifyListeners();
      }
      return results;
    } finally {
      _setBusy(false);
    }
  }

  /// Grants a local introductory free trial (e.g. from onboarding or preview).
  ///
  /// Returns false if the user already has an active non-trial Pro entitlement.
  Future<bool> grantTrial({
    int days = 7,
    String skuId = OpennoteSubscriptionCatalog.annualSkuId,
  }) async {
    if (days <= 0) return false;
    if (isPro && !isInTrial) return false;

    final plan = OpennoteSubscriptionCatalog.planForSku(skuId);
    final tier = plan?.tier ?? SubscriptionTier.proAnnual;
    final now = _clock().toUtc();

    _state = EntitlementState(
      tier: tier,
      isInTrial: true,
      expiresAt: now.add(Duration(days: days)),
      activeSkuId: skuId,
      lastVerifiedAt: now,
    );
    await _persistence.write(_state.toJson());
    _analytics.log(
      ConversionEventType.trialStarted,
      properties: {'skuId': skuId, 'trialDays': days},
    );
    notifyListeners();
    return true;
  }

  /// Queries [PurchaseGateway.verifyEntitlement] and synchronizes local state.
  Future<void> verifyWithStore({bool notifyOnUnchanged = true}) async {
    final verified = await _gateway.verifyEntitlement();
    if (verified == null) {
      refreshExpiration(notify: notifyOnUnchanged);
      return;
    }

    final nextState = EntitlementState(
      tier: verified.tier,
      isInTrial: verified.isInTrial,
      expiresAt: verified.expiresAt,
      activeSkuId: verified.activeSkuId,
      lastVerifiedAt: verified.verifiedAt,
    );

    if (nextState.isExpiredAt(_clock())) {
      await _downgradeToFree(notify: notifyOnUnchanged);
      return;
    }

    final changed = nextState != _state;
    _state = nextState;
    await _persistence.write(_state.toJson());
    if (changed || notifyOnUnchanged) {
      notifyListeners();
    }
  }

  /// Opens the platform's native subscription management screen.
  Future<bool> openManageSubscriptions() => _gateway.openManageSubscriptions();

  /// Checks whether the current entitlement has expired and downgrades to free.
  void refreshExpiration({bool notify = true}) {
    if (!_state.isExpiredAt(_clock())) return;
    _state = const EntitlementState.free();
    unawaited(Future<void>.value(_persistence.write(_state.toJson())));
    if (notify) notifyListeners();
  }

  /// Resets the user's entitlement to [SubscriptionTier.free] and clears storage.
  Future<void> clearEntitlement() async {
    _state = const EntitlementState.free();
    await _persistence.clear();
    notifyListeners();
  }

  Future<void> _downgradeToFree({required bool notify}) async {
    final changed = _state.tier != SubscriptionTier.free;
    _state = const EntitlementState.free();
    await _persistence.write(_state.toJson());
    if (changed || notify) notifyListeners();
  }

  void _setBusy(bool value) {
    if (_isBusy == value) return;
    _isBusy = value;
    notifyListeners();
  }

  static PurchaseResult? _selectBestRestoredPurchase(
    List<PurchaseResult> results,
    DateTime now,
  ) {
    PurchaseResult? best;
    var bestPriority = -1;

    for (final result in results) {
      if (!result.isSuccess || !result.tier.isPro) continue;
      if (!result.tier.isLifetime &&
          result.expiresAt != null &&
          !result.expiresAt!.isAfter(now)) {
        continue;
      }
      final priority = _tierPriority(result.tier);
      if (priority > bestPriority) {
        best = result;
        bestPriority = priority;
      }
    }
    return best;
  }

  static int _tierPriority(SubscriptionTier tier) => switch (tier) {
    SubscriptionTier.proLifetime => 4,
    SubscriptionTier.proAnnual => 3,
    SubscriptionTier.proStudentAnnual => 2,
    SubscriptionTier.proMonthly => 1,
    SubscriptionTier.free => 0,
  };
}

DateTime _utcNow() => DateTime.now().toUtc();

DateTime? _parseIsoDate(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toUtc();
  }
  return null;
}
