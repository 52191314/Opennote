/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:meta/meta.dart';

/// Entitlement tiers supported by Opennote.
enum SubscriptionTier {
  free('free'),
  proMonthly('pro_monthly'),
  proAnnual('pro_annual'),
  proStudentAnnual('pro_student_annual'),
  proLifetime('pro_lifetime');

  const SubscriptionTier(this.storageKey);

  /// Stable serialization identifier for persistence and analytics.
  final String storageKey;

  /// Whether this tier unlocks Opennote Pro features.
  bool get isPro => this != SubscriptionTier.free;

  /// Whether this tier bills on a recurring cycle.
  bool get isRecurring =>
      this == SubscriptionTier.proMonthly ||
      this == SubscriptionTier.proAnnual ||
      this == SubscriptionTier.proStudentAnnual;

  /// Whether this tier is a permanent one-time purchase.
  bool get isLifetime => this == SubscriptionTier.proLifetime;

  /// Whether this tier represents discounted academic/student pricing.
  bool get isStudent => this == SubscriptionTier.proStudentAnnual;

  /// Resolves a [SubscriptionTier] from its [storageKey], defaulting to [free].
  static SubscriptionTier fromStorageKey(String? key) {
    if (key == null) return SubscriptionTier.free;
    for (final tier in SubscriptionTier.values) {
      if (tier.storageKey == key) return tier;
    }
    return SubscriptionTier.free;
  }
}

/// Billing cadence for a [SubscriptionPlan].
enum BillingPeriod {
  none('none', ''),
  monthly('monthly', '/mo'),
  annual('annual', '/yr'),
  lifetime('lifetime', ' one-time');

  const BillingPeriod(this.storageKey, this.shortSuffix);

  /// Stable serialization key.
  final String storageKey;

  /// Compact display suffix appended to formatted prices.
  final String shortSuffix;

  /// Number of months covered by one billing cycle, or null for non-recurring.
  int? get monthsInCycle => switch (this) {
    BillingPeriod.monthly => 1,
    BillingPeriod.annual => 12,
    BillingPeriod.none || BillingPeriod.lifetime => null,
  };

  /// Resolves a [BillingPeriod] from its [storageKey].
  static BillingPeriod fromStorageKey(String? key) {
    for (final period in BillingPeriod.values) {
      if (period.storageKey == key) return period;
    }
    return BillingPeriod.none;
  }
}

/// Immutable representation of a purchasable Opennote subscription or IAP plan.
@immutable
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.skuId,
    required this.tier,
    required this.displayName,
    required this.tagline,
    required this.priceUsd,
    required this.billingPeriod,
    this.currencyCode = 'USD',
    this.currencySymbol = r'$',
    this.localizedPrice,
    this.trialDays = 0,
    this.isRecommended = false,
    this.badgeText,
  });

  /// Reconstructs a [SubscriptionPlan] from a JSON map.
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      skuId: json['skuId'] as String,
      tier: SubscriptionTier.fromStorageKey(json['tier'] as String?),
      displayName: json['displayName'] as String,
      tagline: json['tagline'] as String? ?? '',
      priceUsd: (json['priceUsd'] as num).toDouble(),
      billingPeriod: BillingPeriod.fromStorageKey(
        json['billingPeriod'] as String?,
      ),
      currencyCode: json['currencyCode'] as String? ?? 'USD',
      currencySymbol: json['currencySymbol'] as String? ?? r'$',
      localizedPrice: json['localizedPrice'] as String?,
      trialDays: (json['trialDays'] as num?)?.toInt() ?? 0,
      isRecommended: json['isRecommended'] as bool? ?? false,
      badgeText: json['badgeText'] as String?,
    );
  }

  /// Store product identifier (App Store Connect & Google Play Console).
  final String skuId;

  /// Entitlement tier granted when this SKU is active.
  final SubscriptionTier tier;

  /// User-facing plan title (e.g. "Pro Annual").
  final String displayName;

  /// Short supporting copy beneath the plan title.
  final String tagline;

  /// Reference price in USD (or store currency when updated from gateway).
  final double priceUsd;

  /// Billing cadence for this plan.
  final BillingPeriod billingPeriod;

  /// ISO 4217 currency code.
  final String currencyCode;

  /// Currency symbol used when [localizedPrice] is not supplied by the store.
  final String currencySymbol;

  /// Store-provided localized price string (e.g. "€29,99" or "$29.99").
  final String? localizedPrice;

  /// Introductory free trial duration in days (0 when no trial applies).
  final int trialDays;

  /// Whether the paywall should highlight and pre-select this plan.
  final bool isRecommended;

  /// Optional promotional badge label (e.g. "BEST VALUE · SAVE 50%").
  final String? badgeText;

  /// Whether this plan includes an introductory free trial.
  bool get hasFreeTrial => trialDays > 0;

  /// Formatted base price without billing suffix (e.g. "$29.99").
  String get formattedPrice =>
      localizedPrice ?? '$currencySymbol${priceUsd.toStringAsFixed(2)}';

  /// Formatted price including billing cadence (e.g. "$29.99/yr").
  String get formattedPriceWithPeriod =>
      '$formattedPrice${billingPeriod.shortSuffix}';

  /// Equivalent monthly cost for recurring plans, or null for lifetime/free.
  double? get monthlyEquivalentPrice {
    final months = billingPeriod.monthsInCycle;
    if (months == null || months <= 0) return null;
    return priceUsd / months;
  }

  /// Formatted monthly equivalent price (e.g. "$2.50/mo"), or null if non-recurring.
  String? get formattedMonthlyEquivalent {
    final monthly = monthlyEquivalentPrice;
    if (monthly == null) return null;
    return '$currencySymbol${monthly.toStringAsFixed(2)}/mo';
  }

  /// Computes integer percentage savings relative to [baselineMonthlyPlan].
  ///
  /// Returns 0 for non-recurring plans or if the plan is not cheaper per month.
  int savingsPercentAgainst(SubscriptionPlan baselineMonthlyPlan) {
    final baselineMonthly = baselineMonthlyPlan.monthlyEquivalentPrice;
    final thisMonthly = monthlyEquivalentPrice;
    if (baselineMonthly == null ||
        thisMonthly == null ||
        baselineMonthly <= 0) {
      return 0;
    }
    final ratio = 1.0 - (thisMonthly / baselineMonthly);
    if (ratio <= 0) return 0;
    return (ratio * 100).round();
  }

  /// Returns a copy with updated store pricing or metadata.
  SubscriptionPlan copyWith({
    String? displayName,
    String? tagline,
    double? priceUsd,
    String? currencyCode,
    String? currencySymbol,
    String? localizedPrice,
    int? trialDays,
    bool? isRecommended,
    String? badgeText,
  }) {
    return SubscriptionPlan(
      skuId: skuId,
      tier: tier,
      displayName: displayName ?? this.displayName,
      tagline: tagline ?? this.tagline,
      priceUsd: priceUsd ?? this.priceUsd,
      billingPeriod: billingPeriod,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      localizedPrice: localizedPrice ?? this.localizedPrice,
      trialDays: trialDays ?? this.trialDays,
      isRecommended: isRecommended ?? this.isRecommended,
      badgeText: badgeText ?? this.badgeText,
    );
  }

  /// Serializes this plan to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'skuId': skuId,
    'tier': tier.storageKey,
    'displayName': displayName,
    'tagline': tagline,
    'priceUsd': priceUsd,
    'billingPeriod': billingPeriod.storageKey,
    'currencyCode': currencyCode,
    'currencySymbol': currencySymbol,
    'localizedPrice': localizedPrice,
    'trialDays': trialDays,
    'isRecommended': isRecommended,
    'badgeText': badgeText,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionPlan &&
        other.skuId == skuId &&
        other.tier == tier &&
        other.displayName == displayName &&
        other.tagline == tagline &&
        other.priceUsd == priceUsd &&
        other.billingPeriod == billingPeriod &&
        other.currencyCode == currencyCode &&
        other.currencySymbol == currencySymbol &&
        other.localizedPrice == localizedPrice &&
        other.trialDays == trialDays &&
        other.isRecommended == isRecommended &&
        other.badgeText == badgeText;
  }

  @override
  int get hashCode => Object.hash(
    skuId,
    tier,
    displayName,
    tagline,
    priceUsd,
    billingPeriod,
    currencyCode,
    currencySymbol,
    localizedPrice,
    trialDays,
    isRecommended,
    badgeText,
  );
}

/// Canonical Opennote Pro SKU identifiers and fallback catalog definitions.
abstract final class OpennoteSubscriptionCatalog {
  /// StoreKit / Play Billing subscription group identifier.
  static const subscriptionGroupId = 'com.opennote.pro.group';

  /// Monthly auto-renewing subscription SKU ($4.99/mo).
  static const monthlySkuId = 'com.opennote.pro.monthly';

  /// Annual auto-renewing subscription SKU ($29.99/yr, 7-day free trial).
  static const annualSkuId = 'com.opennote.pro.annual';

  /// Student annual auto-renewing subscription SKU ($14.99/yr, 7-day free trial).
  static const studentAnnualSkuId = 'com.opennote.pro.student.annual';

  /// Permanent one-time non-consumable IAP SKU ($69.99).
  static const lifetimeSkuId = 'com.opennote.pro.lifetime';

  /// Default monthly plan definition.
  static const proMonthly = SubscriptionPlan(
    skuId: monthlySkuId,
    tier: SubscriptionTier.proMonthly,
    displayName: 'Pro Monthly',
    tagline: 'Flexible month-to-month access. Cancel anytime.',
    priceUsd: 4.99,
    billingPeriod: BillingPeriod.monthly,
  );

  /// Default annual plan definition (recommended anchor with 7-day free trial).
  static const proAnnual = SubscriptionPlan(
    skuId: annualSkuId,
    tier: SubscriptionTier.proAnnual,
    displayName: 'Pro Annual',
    tagline: '7-day free trial, then billed annually.',
    priceUsd: 29.99,
    billingPeriod: BillingPeriod.annual,
    trialDays: 7,
    isRecommended: true,
    badgeText: 'BEST VALUE · SAVE 50%',
  );

  /// Default student annual plan definition.
  static const proStudentAnnual = SubscriptionPlan(
    skuId: studentAnnualSkuId,
    tier: SubscriptionTier.proStudentAnnual,
    displayName: 'Student Annual',
    tagline: '7-day free trial with verified academic discount.',
    priceUsd: 14.99,
    billingPeriod: BillingPeriod.annual,
    trialDays: 7,
    badgeText: 'STUDENT · SAVE 75%',
  );

  /// Default lifetime one-time IAP plan definition.
  static const proLifetime = SubscriptionPlan(
    skuId: lifetimeSkuId,
    tier: SubscriptionTier.proLifetime,
    displayName: 'Pro Lifetime',
    tagline: 'One-time purchase. Own Opennote Pro forever.',
    priceUsd: 69.99,
    billingPeriod: BillingPeriod.lifetime,
    badgeText: 'PAY ONCE',
  );

  /// Complete default catalog ordered by conversion priority.
  static const List<SubscriptionPlan> defaultPlans = [
    proAnnual,
    proMonthly,
    proLifetime,
    proStudentAnnual,
  ];

  /// Standard consumer plans displayed on the primary paywall.
  static const List<SubscriptionPlan> standardPlans = [
    proAnnual,
    proMonthly,
    proLifetime,
  ];

  /// Looks up a plan by [skuId], returning null if unknown.
  static SubscriptionPlan? planForSku(String skuId) {
    for (final plan in defaultPlans) {
      if (plan.skuId == skuId) return plan;
    }
    return null;
  }

  /// Looks up a plan by [tier], returning null for [SubscriptionTier.free].
  static SubscriptionPlan? planForTier(SubscriptionTier tier) {
    for (final plan in defaultPlans) {
      if (plan.tier == tier) return plan;
    }
    return null;
  }
}
