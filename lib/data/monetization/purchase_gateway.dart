/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:saber/data/monetization/subscription_plan.dart';

/// Outcome of a store purchase or restore attempt.
enum PurchaseStatus { purchased, restored, cancelled, pending, failed }

/// Immutable result returned by [PurchaseGateway.purchase] or [PurchaseGateway.restorePurchases].
@immutable
class PurchaseResult {
  const PurchaseResult({
    required this.status,
    required this.skuId,
    required this.tier,
    this.transactionId,
    this.purchasedAt,
    this.expiresAt,
    this.isInTrial = false,
    this.errorCode,
    this.errorMessage,
  });

  /// Creates a failed [PurchaseResult].
  const PurchaseResult.failed({
    required this.skuId,
    required String this.errorCode,
    this.errorMessage,
  }) : status = PurchaseStatus.failed,
       tier = SubscriptionTier.free,
       transactionId = null,
       purchasedAt = null,
       expiresAt = null,
       isInTrial = false;

  /// Creates a user-cancelled [PurchaseResult].
  const PurchaseResult.cancelled({required this.skuId})
    : status = PurchaseStatus.cancelled,
      tier = SubscriptionTier.free,
      transactionId = null,
      purchasedAt = null,
      expiresAt = null,
      isInTrial = false,
      errorCode = null,
      errorMessage = null;

  /// Parses a native channel payload into a [PurchaseResult].
  factory PurchaseResult.fromMap(Map<Object?, Object?> map) {
    final statusName = map['status'] as String? ?? 'failed';
    final status = PurchaseStatus.values.firstWhere(
      (value) => value.name == statusName,
      orElse: () => PurchaseStatus.failed,
    );
    final skuId = map['skuId'] as String? ?? '';
    final plan = OpennoteSubscriptionCatalog.planForSku(skuId);
    final tierKey = map['tier'] as String?;
    final tier = tierKey != null
        ? SubscriptionTier.fromStorageKey(tierKey)
        : (plan?.tier ?? SubscriptionTier.free);

    return PurchaseResult(
      status: status,
      skuId: skuId,
      tier: tier,
      transactionId: map['transactionId'] as String?,
      purchasedAt: _parseIsoDate(map['purchasedAt']),
      expiresAt: _parseIsoDate(map['expiresAt']),
      isInTrial: map['isInTrial'] as bool? ?? false,
      errorCode: map['errorCode'] as String?,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  /// Final purchase status.
  final PurchaseStatus status;

  /// SKU identifier targeted by the transaction.
  final String skuId;

  /// Entitlement tier unlocked by the transaction.
  final SubscriptionTier tier;

  /// Store transaction identifier (StoreKit 2 transaction ID or Play order ID).
  final String? transactionId;

  /// UTC timestamp when the purchase occurred.
  final DateTime? purchasedAt;

  /// UTC timestamp when the subscription or trial expires, or null for lifetime.
  final DateTime? expiresAt;

  /// Whether the transaction is currently inside an introductory free trial.
  final bool isInTrial;

  /// Structured error code if [status] is [PurchaseStatus.failed].
  final String? errorCode;

  /// Human-readable error details for diagnostics.
  final String? errorMessage;

  /// Whether this transaction grants an active entitlement.
  bool get isSuccess =>
      status == PurchaseStatus.purchased || status == PurchaseStatus.restored;
}

/// Verified entitlement snapshot returned by the native store or receipt validator.
@immutable
class VerifiedEntitlement {
  const VerifiedEntitlement({
    required this.tier,
    required this.activeSkuId,
    required this.verifiedAt,
    this.expiresAt,
    this.isInTrial = false,
    this.originalTransactionId,
  });

  /// Parses a native channel payload into a [VerifiedEntitlement].
  factory VerifiedEntitlement.fromMap(Map<Object?, Object?> map) {
    final skuId = map['activeSkuId'] as String? ?? '';
    final plan = OpennoteSubscriptionCatalog.planForSku(skuId);
    final tierKey = map['tier'] as String?;
    final tier = tierKey != null
        ? SubscriptionTier.fromStorageKey(tierKey)
        : (plan?.tier ?? SubscriptionTier.free);

    return VerifiedEntitlement(
      tier: tier,
      activeSkuId: skuId,
      verifiedAt: _parseIsoDate(map['verifiedAt']) ?? DateTime.now().toUtc(),
      expiresAt: _parseIsoDate(map['expiresAt']),
      isInTrial: map['isInTrial'] as bool? ?? false,
      originalTransactionId: map['originalTransactionId'] as String?,
    );
  }

  /// Active subscription or IAP tier.
  final SubscriptionTier tier;

  /// SKU identifier backing this entitlement.
  final String activeSkuId;

  /// UTC timestamp when the store verified this entitlement.
  final DateTime verifiedAt;

  /// Expiration UTC timestamp, or null for permanent lifetime entitlements.
  final DateTime? expiresAt;

  /// Whether the active entitlement is currently in its introductory trial.
  final bool isInTrial;

  /// Original store transaction identifier for renewal tracking.
  final String? originalTransactionId;
}

/// Zero-dependency abstraction over native StoreKit 2 and Google Play Billing.
abstract interface class PurchaseGateway {
  /// Fetches available subscription and IAP plans with localized store prices.
  Future<List<SubscriptionPlan>> fetchCatalog();

  /// Initiates a native purchase flow for [skuId].
  Future<PurchaseResult> purchase(String skuId);

  /// Restores prior purchases associated with the user's store account.
  Future<List<PurchaseResult>> restorePurchases();

  /// Queries the store for the user's currently active verified entitlement.
  Future<VerifiedEntitlement?> verifyEntitlement();

  /// Opens the platform's native subscription management sheet or URL.
  Future<bool> openManageSubscriptions();
}

/// Platform [MethodChannel] bridge ready for StoreKit 2 (iOS/macOS) and
/// Google Play Billing (Android) native handlers.
class StoreKitPlayBillingBridge implements PurchaseGateway {
  StoreKitPlayBillingBridge({
    MethodChannel? channel,
    this._fallbackCatalog = OpennoteSubscriptionCatalog.defaultPlans,
  }) : _channel = channel ?? const MethodChannel(defaultChannelName);

  /// Default platform channel name bound by native iOS/Android handlers.
  static const defaultChannelName = 'com.opennote.app/monetization';

  final MethodChannel _channel;
  final List<SubscriptionPlan> _fallbackCatalog;

  @override
  Future<List<SubscriptionPlan>> fetchCatalog() async {
    try {
      final skuIds = _fallbackCatalog.map((plan) => plan.skuId).toList();
      final response = await _channel.invokeMethod<List<Object?>>(
        'fetchCatalog',
        {'skuIds': skuIds},
      );
      if (response == null || response.isEmpty) {
        return List.unmodifiable(_fallbackCatalog);
      }

      final storeBySku = <String, Map<Object?, Object?>>{};
      for (final item in response) {
        if (item is Map<Object?, Object?>) {
          final skuId = item['skuId'] as String?;
          if (skuId != null) storeBySku[skuId] = item;
        }
      }

      final merged = _fallbackCatalog.map((fallback) {
        final storeItem = storeBySku[fallback.skuId];
        if (storeItem == null) return fallback;
        return fallback.copyWith(
          displayName: storeItem['displayName'] as String?,
          priceUsd: (storeItem['price'] as num?)?.toDouble(),
          currencyCode: storeItem['currencyCode'] as String?,
          currencySymbol: storeItem['currencySymbol'] as String?,
          localizedPrice: storeItem['localizedPrice'] as String?,
          trialDays: (storeItem['trialDays'] as num?)?.toInt(),
        );
      }).toList();

      return List.unmodifiable(merged);
    } on MissingPluginException {
      return List.unmodifiable(_fallbackCatalog);
    } on PlatformException {
      return List.unmodifiable(_fallbackCatalog);
    }
  }

  @override
  Future<PurchaseResult> purchase(String skuId) async {
    try {
      final response = await _channel.invokeMethod<Map<Object?, Object?>>(
        'purchase',
        {'skuId': skuId},
      );
      if (response == null) {
        return PurchaseResult.failed(
          skuId: skuId,
          errorCode: 'empty_response',
          errorMessage: 'Native billing returned an empty purchase response.',
        );
      }
      return PurchaseResult.fromMap(response);
    } on MissingPluginException {
      return PurchaseResult.failed(
        skuId: skuId,
        errorCode: 'store_unavailable',
        errorMessage: 'In-app purchases are unavailable on this platform.',
      );
    } on PlatformException catch (error) {
      if (error.code == 'user_cancelled' || error.code == 'cancelled') {
        return PurchaseResult.cancelled(skuId: skuId);
      }
      return PurchaseResult.failed(
        skuId: skuId,
        errorCode: error.code,
        errorMessage: error.message,
      );
    }
  }

  @override
  Future<List<PurchaseResult>> restorePurchases() async {
    try {
      final response = await _channel.invokeMethod<List<Object?>>(
        'restorePurchases',
      );
      if (response == null) return const [];
      return response
          .whereType<Map<Object?, Object?>>()
          .map(PurchaseResult.fromMap)
          .toList(growable: false);
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
  }

  @override
  Future<VerifiedEntitlement?> verifyEntitlement() async {
    try {
      final response = await _channel.invokeMethod<Map<Object?, Object?>>(
        'verifyEntitlement',
      );
      if (response == null) return null;
      return VerifiedEntitlement.fromMap(response);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<bool> openManageSubscriptions() async {
    try {
      final opened = await _channel.invokeMethod<bool>(
        'openManageSubscriptions',
      );
      return opened ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}

/// Deterministic in-memory [PurchaseGateway] for local development, previews,
/// and offline automated tests.
class LocalSimulationPurchaseGateway implements PurchaseGateway {
  LocalSimulationPurchaseGateway({
    List<SubscriptionPlan> catalog = OpennoteSubscriptionCatalog.defaultPlans,
    DateTime Function()? clock,
    this.simulatedDelay = Duration.zero,
    List<PurchaseResult> initialRestorablePurchases = const [],
  }) : _catalog = List.unmodifiable(catalog),
       _clock = clock ?? _utcNow,
       _restorablePurchases = List.of(initialRestorablePurchases);

  final List<SubscriptionPlan> _catalog;
  final DateTime Function() _clock;

  /// Optional artificial latency for simulating network/store sheets.
  final Duration simulatedDelay;

  final List<PurchaseResult> _restorablePurchases;
  VerifiedEntitlement? _activeEntitlement;
  var _transactionCounter = 0;

  /// When set, the next [purchase] call fails with this error code.
  String? nextPurchaseErrorCode;

  /// When true, the next [purchase] call returns [PurchaseStatus.cancelled].
  var cancelNextPurchase = false;

  /// Number of times [openManageSubscriptions] was invoked.
  var manageSubscriptionsOpenCount = 0;

  @override
  Future<List<SubscriptionPlan>> fetchCatalog() async {
    await _maybeDelay();
    return _catalog;
  }

  @override
  Future<PurchaseResult> purchase(String skuId) async {
    await _maybeDelay();

    if (cancelNextPurchase) {
      cancelNextPurchase = false;
      return PurchaseResult.cancelled(skuId: skuId);
    }

    if (nextPurchaseErrorCode != null) {
      final code = nextPurchaseErrorCode!;
      nextPurchaseErrorCode = null;
      return PurchaseResult.failed(
        skuId: skuId,
        errorCode: code,
        errorMessage: 'Simulated purchase failure ($code).',
      );
    }

    final plan = _findPlan(skuId);
    if (plan == null) {
      return PurchaseResult.failed(
        skuId: skuId,
        errorCode: 'unknown_sku',
        errorMessage: 'SKU "$skuId" is not in the Opennote catalog.',
      );
    }

    final now = _clock().toUtc();
    final expiresAt = _computeExpiration(plan, now);
    final transactionId = 'sim_tx_${++_transactionCounter}';

    final result = PurchaseResult(
      status: PurchaseStatus.purchased,
      skuId: plan.skuId,
      tier: plan.tier,
      transactionId: transactionId,
      purchasedAt: now,
      expiresAt: expiresAt,
      isInTrial: plan.hasFreeTrial,
    );

    _activeEntitlement = VerifiedEntitlement(
      tier: plan.tier,
      activeSkuId: plan.skuId,
      verifiedAt: now,
      expiresAt: expiresAt,
      isInTrial: plan.hasFreeTrial,
      originalTransactionId: transactionId,
    );

    _restorablePurchases
      ..removeWhere((existing) => existing.skuId == plan.skuId)
      ..add(
        PurchaseResult(
          status: PurchaseStatus.restored,
          skuId: plan.skuId,
          tier: plan.tier,
          transactionId: transactionId,
          purchasedAt: now,
          expiresAt: expiresAt,
          isInTrial: plan.hasFreeTrial,
        ),
      );

    return result;
  }

  @override
  Future<List<PurchaseResult>> restorePurchases() async {
    await _maybeDelay();
    return List.unmodifiable(_restorablePurchases);
  }

  @override
  Future<VerifiedEntitlement?> verifyEntitlement() async {
    await _maybeDelay();
    final entitlement = _activeEntitlement;
    if (entitlement == null) return null;

    final now = _clock().toUtc();
    if (entitlement.expiresAt != null && !entitlement.expiresAt!.isAfter(now)) {
      _activeEntitlement = null;
      return null;
    }

    return VerifiedEntitlement(
      tier: entitlement.tier,
      activeSkuId: entitlement.activeSkuId,
      verifiedAt: now,
      expiresAt: entitlement.expiresAt,
      isInTrial: entitlement.isInTrial,
      originalTransactionId: entitlement.originalTransactionId,
    );
  }

  @override
  Future<bool> openManageSubscriptions() async {
    await _maybeDelay();
    manageSubscriptionsOpenCount++;
    return true;
  }

  /// Seeds a verified entitlement directly for test setup.
  void seedVerifiedEntitlement(VerifiedEntitlement? entitlement) {
    _activeEntitlement = entitlement;
  }

  SubscriptionPlan? _findPlan(String skuId) {
    for (final plan in _catalog) {
      if (plan.skuId == skuId) return plan;
    }
    return null;
  }

  DateTime? _computeExpiration(SubscriptionPlan plan, DateTime now) {
    if (plan.hasFreeTrial) {
      return now.add(Duration(days: plan.trialDays));
    }
    return switch (plan.billingPeriod) {
      BillingPeriod.monthly => now.add(const Duration(days: 30)),
      BillingPeriod.annual => now.add(const Duration(days: 365)),
      BillingPeriod.lifetime || BillingPeriod.none => null,
    };
  }

  Future<void> _maybeDelay() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
  }
}

DateTime _utcNow() => DateTime.now().toUtc();

DateTime? _parseIsoDate(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value)?.toUtc();
  }
  return null;
}
