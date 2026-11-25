/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saber/components/home/quick_template_strip.dart';
import 'package:saber/components/monetization/monetization_ui.dart';
import 'package:saber/components/onboarding/welcome_onboarding_dialog.dart';
import 'package:saber/data/monetization/conversion_analytics.dart';
import 'package:saber/data/monetization/entitlement_service.dart';
import 'package:saber/data/monetization/review_prompt_service.dart';
import 'package:saber/data/monetization/subscription_plan.dart';
import 'package:saber/data/prefs.dart';
import 'package:sbn/canvas_background_pattern.dart';

/// Application-wide coordinator binding [EntitlementService],
/// [ReviewPromptService], `stows` growth preferences, and monetization UI
/// surfaces ([OpennotePaywallSheet], [ProFeatureGateSheet],
/// [ReviewPromptSheet], [OpennoteOnboardingFlow]).
class MonetizationCoordinator {
  /// Creates a [MonetizationCoordinator] with optional injectable services.
  MonetizationCoordinator({
    EntitlementService? entitlementService,
    ReviewPromptService? reviewPromptService,
  }) : entitlementService =
           entitlementService ?? _createStowBoundEntitlementService(),
       reviewPromptService =
           reviewPromptService ?? _createStowBoundReviewPromptService();

  static MonetizationCoordinator? _instance;

  /// Shared application-wide [MonetizationCoordinator] singleton.
  static MonetizationCoordinator get instance =>
      _instance ??= MonetizationCoordinator();

  /// Replaces the shared singleton in tests.
  @visibleForTesting
  static void setInstanceForTesting(MonetizationCoordinator coordinator) {
    _instance = coordinator;
  }

  /// Resets the shared singleton so tests start from a clean state.
  @visibleForTesting
  static void resetInstanceForTesting() {
    _instance = null;
  }

  /// Reactive subscription & entitlement state controller.
  final EntitlementService entitlementService;

  /// Smart ASO rating velocity & Aha-moment review prompt engine.
  final ReviewPromptService reviewPromptService;

  var _initialized = false;

  /// Whether the user currently holds an active Opennote Pro entitlement.
  bool get isPro => entitlementService.isPro;

  /// Whether the user is currently in an active free trial window.
  bool get isInTrial => entitlementService.isInTrial;

  /// Whole days remaining in an active trial, or `null` when not in trial.
  int? get trialDaysRemainingOrNull =>
      isInTrial ? entitlementService.trialDaysRemaining : null;

  /// Human-readable plan summary for Settings & Home Pro status banners.
  String? get planSummary {
    if (!isPro) return null;
    if (isInTrial) {
      final days = entitlementService.trialDaysRemaining;
      final unit = days == 1 ? 'day' : 'days';
      return '7-Day Free Trial · $days $unit left';
    }
    return switch (entitlementService.state.tier) {
      SubscriptionTier.proAnnual => 'Annual Plan · Active',
      SubscriptionTier.proMonthly => 'Monthly Plan · Active',
      SubscriptionTier.proStudentAnnual => 'Student Annual · Active',
      SubscriptionTier.proLifetime => 'Lifetime Pro · Active',
      SubscriptionTier.free => null,
    };
  }

  /// Loads growth stows and hydrates [entitlementService] and
  /// [reviewPromptService] at application startup.
  Future<void> initialize({bool verifyStore = true}) async {
    if (_initialized) return;
    _initialized = true;

    final growthStows = [
      stows.onboardingCompleted,
      stows.onboardingPersona,
      stows.proTierCached,
      stows.proTrialStartEpochMs,
      stows.proExpirationEpochMs,
      stows.notesCreatedCount,
      stows.exportsCompletedCount,
      stows.lastReviewPromptEpochMs,
      stows.hasRatedApp,
      stows.paywallImpressionsCount,
    ];
    await Future.wait([
      for (final stow in growthStows)
        if (!stow.volatile && !stow.loaded) stow.waitUntilRead(),
    ]);

    _hydrateReviewStateFromStows();
    await entitlementService.initialize(verifyStore: verifyStore);
  }

  /// Maps the active [EntitlementService.catalog] into paywall view models.
  List<PaywallPlanViewModel> buildPlanViewModels() {
    final catalog = entitlementService.catalog;
    if (catalog.isEmpty) return OpennotePaywallDefaults.defaultPlans;

    final monthlyPlan = catalog
        .where((p) => p.tier == SubscriptionTier.proMonthly)
        .firstOrNull;
    final viewModels = <PaywallPlanViewModel>[];

    for (final plan in catalog) {
      if (plan.tier == SubscriptionTier.proStudentAnnual) continue;
      if (plan.billingPeriod == BillingPeriod.none) continue;
      final period = switch (plan.billingPeriod) {
        BillingPeriod.annual => PaywallBillingPeriod.annual,
        BillingPeriod.monthly => PaywallBillingPeriod.monthly,
        BillingPeriod.lifetime => PaywallBillingPeriod.lifetime,
        BillingPeriod.none => PaywallBillingPeriod.annual,
      };
      final savings = monthlyPlan == null
          ? 0
          : plan.savingsPercentAgainst(monthlyPlan);
      viewModels.add(
        PaywallPlanViewModel(
          id: plan.skuId,
          title: switch (period) {
            PaywallBillingPeriod.annual => 'Annual',
            PaywallBillingPeriod.monthly => 'Monthly',
            PaywallBillingPeriod.lifetime => 'Lifetime',
          },
          billingPeriod: period,
          priceDisplay: plan.formattedPriceWithPeriod,
          equivalentMonthlyDisplay: plan.formattedMonthlyEquivalent,
          badgeText: plan.badgeText,
          savingsPill: savings > 0 ? 'Save $savings%' : null,
          freeTrialDays: plan.trialDays,
          isRecommended: plan.isRecommended,
        ),
      );
    }

    return viewModels.isEmpty
        ? OpennotePaywallDefaults.defaultPlans
        : viewModels;
  }

  /// Builds a reactive [ProUpgradeBanner] suitable for Home/Browse slots.
  Widget buildHomeProBanner(BuildContext context) {
    return ListenableBuilder(
      listenable: entitlementService,
      builder: (context, _) => ProUpgradeBanner(
        isPro: isPro,
        trialDaysRemaining: trialDaysRemainingOrNull,
        activePlanLabel: planSummary,
        isCompact: true,
        onTap: () => unawaited(
          isPro
              ? entitlementService.openManageSubscriptions()
              : showPaywall(
                  context,
                  trigger: PaywallTriggerContext.generalUpgrade,
                ),
        ),
      ),
    );
  }

  /// Presents the flagship [OpennotePaywallSheet] bound to [entitlementService].
  ///
  /// Returns `true` if the user holds an active Pro entitlement when the sheet
  /// closes.
  Future<bool> showPaywall(
    BuildContext context, {
    PaywallTriggerContext trigger = PaywallTriggerContext.generalUpgrade,
    String? initialSelectedPlanId,
  }) async {
    stows.paywallImpressionsCount.value =
        stows.paywallImpressionsCount.value + 1;
    entitlementService.analytics.log(
      ConversionEventType.paywallViewed,
      properties: {'trigger': trigger.name},
    );

    final paywallContext = PaywallContext.forTrigger(trigger);
    final plans = buildPlanViewModels();
    final screenWidth = MediaQuery.sizeOf(context).width;

    Widget buildReactiveSheet(BuildContext sheetContext) {
      return _LivePaywallSheetHost(
        entitlementService: entitlementService,
        paywallContext: paywallContext,
        plans: plans,
        initialSelectedPlanId: initialSelectedPlanId,
        onDismiss: () {
          entitlementService.analytics.log(
            ConversionEventType.paywallDismissed,
            properties: {'trigger': trigger.name},
          );
          Navigator.of(sheetContext).maybePop();
        },
        onUnlocked: () => Navigator.of(sheetContext).maybePop(),
      );
    }

    if (screenWidth >= 680) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880, maxHeight: 740),
            child: buildReactiveSheet(dialogContext),
          ),
        ),
      );
    } else {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: true,
        builder: (sheetContext) => FractionallySizedBox(
          heightFactor: 0.94,
          child: buildReactiveSheet(sheetContext),
        ),
      );
    }

    return isPro;
  }

  /// Presents the lightweight contextual [ProFeatureGateSheet] for a locked
  /// Pro feature and routes "Try Pro Free" / "Compare Plans" to [showPaywall].
  ///
  /// Returns `true` immediately if the user is already Pro or after unlocking.
  Future<bool> showFeatureGate(
    BuildContext context, {
    required PaywallTriggerContext trigger,
  }) async {
    if (isPro) return true;

    entitlementService.analytics.log(
      ConversionEventType.proGateTriggered,
      properties: {'trigger': trigger.name},
    );

    var openFullPaywall = false;
    await ProFeatureGateSheet.show(
      context,
      paywallContext: PaywallContext.forTrigger(trigger),
      onTryPro: () => openFullPaywall = true,
      onComparePlans: () => openFullPaywall = true,
    );

    if (openFullPaywall && context.mounted) {
      return showPaywall(context, trigger: trigger);
    }
    return isPro;
  }

  /// Maps a string feature identifier (e.g. from [EditorBottomSheet]) to a
  /// contextual [ProFeatureGateSheet] trigger.
  Future<bool> handleFeatureRequest(
    BuildContext context,
    String featureId,
  ) async {
    final normalized = featureId.toLowerCase();
    final trigger = switch (normalized) {
      _
          when normalized.contains('vector') ||
              normalized.contains('svg') ||
              normalized.contains('export') =>
        PaywallTriggerContext.vectorBatchExport,
      _ when normalized.contains('sync') || normalized.contains('cloud') =>
        PaywallTriggerContext.infiniteCloudSync,
      _
          when normalized.contains('draft') ||
              normalized.contains('ruler') ||
              normalized.contains('protractor') =>
        PaywallTriggerContext.precisionDrafting,
      _
          when normalized.contains('notebook') ||
              normalized.contains('limit') ||
              normalized.contains('infinite') =>
        PaywallTriggerContext.unlimitedNotebooks,
      _ => PaywallTriggerContext.engineeringTemplates,
    };
    return showFeatureGate(context, trigger: trigger);
  }

  /// Handles a Pro-badged quick template tap on Home/Browse.
  Future<bool> handleProTemplateTap(
    BuildContext context,
    QuickTemplateKind kind,
  ) {
    final trigger = kind == QuickTemplateKind.infiniteCanvas
        ? PaywallTriggerContext.unlimitedNotebooks
        : PaywallTriggerContext.engineeringTemplates;
    return showFeatureGate(context, trigger: trigger);
  }

  /// Persists onboarding persona/template choices and opens [OpennotePaywallSheet]
  /// if the user requested a free trial without yet unlocking Pro.
  Future<void> handleOnboardingCompletion(
    BuildContext context,
    OnboardingCompletionResult result,
  ) async {
    stows.hasSeenOnboarding.value = true;
    stows.onboardingCompleted.value = true;
    stows.onboardingPersona.value = result.persona.name;

    final recommendedPattern = _patternForTemplateId(
      result.persona.recommendedTemplateId,
    );
    if (recommendedPattern != null) {
      stows.lastBackgroundPattern.value = recommendedPattern;
    }

    entitlementService.analytics.log(
      ConversionEventType.personaSelected,
      properties: {'persona': result.persona.name},
    );
    entitlementService.analytics.log(
      ConversionEventType.onboardingCompleted,
      properties: {
        'persona': result.persona.name,
        'startedTrial': result.startedTrial,
        'skipped': result.skipped,
      },
    );

    if (result.startedTrial && !isPro && context.mounted) {
      final sku = _mapOnboardingSkuToCatalogSku(result.selectedPlanSku);
      await showPaywall(
        context,
        trigger: PaywallTriggerContext.onboardingTrial,
        initialSelectedPlanId: sku,
      );
    }
  }

  /// Handles Step-4 trial start directly inside [OpennoteOnboardingFlow].
  Future<bool> startTrialFromOnboarding(
    String onboardingSku,
    OnboardingPersona persona,
  ) async {
    final skuId = _mapOnboardingSkuToCatalogSku(onboardingSku);
    final result = await entitlementService.purchasePlan(skuId);
    return result.isSuccess || isPro;
  }

  /// Restores purchases and shows user-friendly confirmation feedback.
  Future<bool> restorePurchasesWithFeedback(BuildContext context) async {
    final results = await entitlementService.restorePurchases();
    final restored = results.any((r) => r.isSuccess) || isPro;
    if (!context.mounted) return restored;

    final firstError = results
        .where((r) => !r.isSuccess && r.errorMessage != null)
        .map((r) => r.errorMessage!)
        .firstOrNull;
    final message = restored
        ? 'Opennote Pro purchases restored!'
        : (firstError ?? 'No previous Pro purchases found.');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    return restored;
  }

  /// Records a completed note milestone and triggers [ReviewPromptSheet] if
  /// the user reached an Aha moment and passed cooldown guards.
  Future<void> recordNoteCreated(BuildContext context) async {
    stows.notesCreatedCount.value = stows.notesCreatedCount.value + 1;
    await reviewPromptService.recordNoteCompleted();
    if (reviewPromptService.shouldPromptReview() && context.mounted) {
      await showReviewPrompt(context);
    }
  }

  /// Records a completed PDF export milestone and triggers [ReviewPromptSheet]
  /// when eligible.
  Future<void> recordPdfExportCompleted(BuildContext context) async {
    stows.exportsCompletedCount.value = stows.exportsCompletedCount.value + 1;
    await reviewPromptService.recordPdfExportCompleted();
    if (reviewPromptService.shouldPromptReview() && context.mounted) {
      await showReviewPrompt(context);
    }
  }

  /// Opens the two-step ASO [ReviewPromptSheet] and persists rating outcome.
  Future<void> showReviewPrompt(
    BuildContext context, {
    bool force = false,
  }) async {
    if (!force && !reviewPromptService.shouldPromptReview()) return;

    await reviewPromptService.recordPromptShown();
    if (!context.mounted) return;

    await ReviewPromptSheet.show(
      context,
      onRequestStoreReview: () {
        unawaited(reviewPromptService.recordUserRated());
      },
      onSubmitFeedback: (message, topics) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanks for helping make Opennote better!'),
          ),
        );
      },
    );
  }

  void _hydrateReviewStateFromStows() {
    final lastPromptMs = stows.lastReviewPromptEpochMs.value;
    reviewPromptService.hydrateFromJson({
      'completedNotesCount': stows.notesCreatedCount.value,
      'completedPdfExportsCount': stows.exportsCompletedCount.value,
      'lastPromptedAt': lastPromptMs > 0
          ? DateTime.fromMillisecondsSinceEpoch(
              lastPromptMs,
              isUtc: true,
            ).toIso8601String()
          : null,
      'hasRated': stows.hasRatedApp.value,
      'promptCount': lastPromptMs > 0 ? 1 : 0,
    });
  }

  static CanvasBackgroundPattern? _patternForTemplateId(String templateId) =>
      switch (templateId) {
        'grid' => CanvasBackgroundPattern.engineeringGrid,
        'cornell' => CanvasBackgroundPattern.cornell,
        'dots' => CanvasBackgroundPattern.dots,
        'lined' => CanvasBackgroundPattern.lined,
        'blank' => CanvasBackgroundPattern.none,
        _ => null,
      };

  static String _mapOnboardingSkuToCatalogSku(String? onboardingSku) =>
      switch (onboardingSku) {
        OnboardingPlanSku.monthly => OpennoteSubscriptionCatalog.monthlySkuId,
        OnboardingPlanSku.annual => OpennoteSubscriptionCatalog.annualSkuId,
        _ => OpennoteSubscriptionCatalog.annualSkuId,
      };

  static EntitlementService _createStowBoundEntitlementService() {
    return EntitlementService(
      persistence: CallbackEntitlementPersistence(
        onRead: () {
          final tierKey = stows.proTierCached.value;
          if (tierKey.isEmpty || tierKey == SubscriptionTier.free.storageKey) {
            return null;
          }
          final expiresMs = stows.proExpirationEpochMs.value;
          final trialStartMs = stows.proTrialStartEpochMs.value;
          return {
            'tier': tierKey,
            'isInTrial': trialStartMs > 0,
            'expiresAt': expiresMs > 0
                ? DateTime.fromMillisecondsSinceEpoch(
                    expiresMs,
                    isUtc: true,
                  ).toIso8601String()
                : null,
          };
        },
        onWrite: (json) {
          stows.proTierCached.value =
              (json['tier'] as String?) ?? SubscriptionTier.free.storageKey;
          final isTrial = json['isInTrial'] as bool? ?? false;
          if (isTrial && stows.proTrialStartEpochMs.value == 0) {
            stows.proTrialStartEpochMs.value = DateTime.now()
                .toUtc()
                .millisecondsSinceEpoch;
          } else if (!isTrial) {
            stows.proTrialStartEpochMs.value = 0;
          }
          final expiresIso = json['expiresAt'] as String?;
          final expiresAt = expiresIso == null
              ? null
              : DateTime.tryParse(expiresIso)?.toUtc();
          stows.proExpirationEpochMs.value =
              expiresAt?.millisecondsSinceEpoch ?? 0;
        },
        onClear: () {
          stows.proTierCached.value = SubscriptionTier.free.storageKey;
          stows.proTrialStartEpochMs.value = 0;
          stows.proExpirationEpochMs.value = 0;
        },
      ),
    );
  }

  static ReviewPromptService _createStowBoundReviewPromptService() {
    return ReviewPromptService(
      onStateChanged: (state) {
        stows.notesCreatedCount.value = state.completedNotesCount;
        stows.exportsCompletedCount.value = state.completedPdfExportsCount;
        stows.hasRatedApp.value = state.hasRated;
        if (state.lastPromptedAt != null) {
          stows.lastReviewPromptEpochMs.value =
              state.lastPromptedAt!.millisecondsSinceEpoch;
        }
      },
    );
  }
}

class _LivePaywallSheetHost extends StatefulWidget {
  const _LivePaywallSheetHost({
    required this.entitlementService,
    required this.paywallContext,
    required this.plans,
    this.initialSelectedPlanId,
    required this.onDismiss,
    required this.onUnlocked,
  });

  final EntitlementService entitlementService;
  final PaywallContext paywallContext;
  final List<PaywallPlanViewModel> plans;
  final String? initialSelectedPlanId;
  final VoidCallback onDismiss;
  final VoidCallback onUnlocked;

  @override
  State<_LivePaywallSheetHost> createState() => _LivePaywallSheetHostState();
}

class _LivePaywallSheetHostState extends State<_LivePaywallSheetHost> {
  var _purchaseState = PaywallPurchaseState.idle;
  String? _errorMessage;

  Future<void> _handlePurchase(PaywallPlanViewModel plan) async {
    setState(() {
      _purchaseState = PaywallPurchaseState.purchasing;
      _errorMessage = null;
    });

    final result = await widget.entitlementService.purchasePlan(plan.id);
    if (!mounted) return;

    if (result.isSuccess || widget.entitlementService.isPro) {
      setState(() => _purchaseState = PaywallPurchaseState.success);
      widget.onUnlocked();
      return;
    }

    setState(() {
      _purchaseState = PaywallPurchaseState.error;
      _errorMessage = result.errorMessage ?? 'Purchase could not be completed.';
    });
  }

  Future<void> _handleRestore() async {
    setState(() {
      _purchaseState = PaywallPurchaseState.restoring;
      _errorMessage = null;
    });

    final results = await widget.entitlementService.restorePurchases();
    if (!mounted) return;

    final restored =
        results.any((r) => r.isSuccess) || widget.entitlementService.isPro;
    if (restored) {
      setState(() => _purchaseState = PaywallPurchaseState.success);
      widget.onUnlocked();
      return;
    }

    final firstError = results
        .where((r) => !r.isSuccess && r.errorMessage != null)
        .map((r) => r.errorMessage!)
        .firstOrNull;
    setState(() {
      _purchaseState = PaywallPurchaseState.error;
      _errorMessage =
          firstError ?? 'No active Pro subscription found to restore.';
    });
  }

  Future<void> _handleStudentDiscount() async {
    setState(() {
      _purchaseState = PaywallPurchaseState.purchasing;
      _errorMessage = null;
    });

    final result = await widget.entitlementService.purchasePlan(
      OpennoteSubscriptionCatalog.studentAnnualSkuId,
    );
    if (!mounted) return;

    if (result.isSuccess || widget.entitlementService.isPro) {
      setState(() => _purchaseState = PaywallPurchaseState.success);
      widget.onUnlocked();
      return;
    }

    setState(() {
      _purchaseState = PaywallPurchaseState.error;
      _errorMessage =
          result.errorMessage ?? 'Student plan could not be activated.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return OpennotePaywallSheet(
      paywallContext: widget.paywallContext,
      plans: widget.plans,
      initialSelectedPlanId: widget.initialSelectedPlanId,
      purchaseState: _purchaseState,
      errorMessage: _errorMessage,
      onSelectPlan: (plan) {
        widget.entitlementService.analytics.log(
          ConversionEventType.planSelected,
          properties: {'skuId': plan.id},
        );
      },
      onPurchase: _handlePurchase,
      onRestore: _handleRestore,
      onDismiss: widget.onDismiss,
      onStudentDiscount: _handleStudentDiscount,
    );
  }
}
