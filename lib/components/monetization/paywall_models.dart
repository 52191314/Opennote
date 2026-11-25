/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';

/// Contextual feature trigger that opened a paywall or Pro gate surface.
enum PaywallTriggerContext {
  /// Triggered from engineering paper templates (isometric, schematic, Smith chart).
  engineeringTemplates,

  /// Triggered from multi-device encrypted cloud sync settings or prompts.
  infiniteCloudSync,

  /// Triggered from high-resolution SVG/PDF vector or batch notebook export.
  vectorBatchExport,

  /// Triggered from precision drafting tools (ruler, protractor, snap shapes).
  precisionDrafting,

  /// Triggered when creating beyond the free notebook limit.
  unlimitedNotebooks,

  /// Triggered during Day-0 onboarding trial offer.
  onboardingTrial,

  /// Triggered from Home or Settings Pro upgrade entry points.
  generalUpgrade,
}

/// Billing cadence for an Opennote Pro plan.
enum PaywallBillingPeriod {
  /// Yearly auto-renewing subscription.
  annual,

  /// Monthly auto-renewing subscription.
  monthly,

  /// One-time non-consumable lifetime purchase.
  lifetime,
}

/// Interactive purchase lifecycle state displayed by paywall CTAs.
enum PaywallPurchaseState {
  /// Ready for user interaction.
  idle,

  /// Currently processing a purchase with the store.
  purchasing,

  /// Currently restoring previous purchases.
  restoring,

  /// Purchase or restore succeeded.
  success,

  /// Purchase or restore failed; display error feedback.
  error,
}

/// Single benefit bullet rendered in paywall and contextual gate surfaces.
@immutable
class ProFeatureHighlight {
  /// Creates a [ProFeatureHighlight].
  const ProFeatureHighlight({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isPrimaryHighlight = false,
  });

  /// Material icon representing the feature.
  final IconData icon;

  /// Short scannable headline for the feature.
  final String title;

  /// Concise one-line value explanation.
  final String subtitle;

  /// Whether this highlight should receive subtle visual emphasis.
  final bool isPrimaryHighlight;
}

/// Presentation view-model for a selectable Opennote Pro plan card.
@immutable
class PaywallPlanViewModel {
  /// Creates a [PaywallPlanViewModel].
  const PaywallPlanViewModel({
    required this.id,
    required this.title,
    required this.billingPeriod,
    required this.priceDisplay,
    this.equivalentMonthlyDisplay,
    this.badgeText,
    this.savingsPill,
    this.freeTrialDays = 0,
    this.billingFootnote,
    this.isRecommended = false,
  });

  /// Store SKU or logical plan identifier.
  final String id;

  /// User-facing plan title (e.g. `Annual`, `Monthly`, `Lifetime`).
  final String title;

  /// Billing cadence for this plan.
  final PaywallBillingPeriod billingPeriod;

  /// Formatted primary price string (e.g. `$29.99/yr`).
  final String priceDisplay;

  /// Optional per-month breakdown or billing subtitle (e.g. `$2.50/mo`).
  final String? equivalentMonthlyDisplay;

  /// Optional top ribbon or callout label (e.g. `BEST VALUE · SAVE 50%`).
  final String? badgeText;

  /// Optional compact inline savings pill (e.g. `Save 50%`).
  final String? savingsPill;

  /// Number of free trial days offered before first charge (`0` if none).
  final int freeTrialDays;

  /// Clear billing disclosure shown beneath the primary CTA button.
  final String? billingFootnote;

  /// Whether this plan is anchored and pre-selected by default.
  final bool isRecommended;

  /// Whether this plan includes an introductory free trial.
  bool get hasFreeTrial => freeTrialDays > 0;

  /// Dynamic primary CTA button label matched to this plan.
  String get ctaLabel {
    if (hasFreeTrial) return 'Start $freeTrialDays-Day Free Trial';
    if (billingPeriod == PaywallBillingPeriod.lifetime) {
      return 'Unlock Lifetime Pro';
    }
    return 'Continue with $title';
  }

  /// Concise disclosure line rendered directly below the CTA button.
  String get effectiveFootnote {
    if (billingFootnote != null) return billingFootnote!;
    if (hasFreeTrial) {
      return '$freeTrialDays days free, then $priceDisplay · Cancel anytime';
    }
    if (billingPeriod == PaywallBillingPeriod.lifetime) {
      return 'One-time purchase ($priceDisplay) · No recurring fees';
    }
    return 'Billed at $priceDisplay · Cancel anytime';
  }

  /// Returns a copy of this plan with updated fields.
  PaywallPlanViewModel copyWith({
    String? id,
    String? title,
    PaywallBillingPeriod? billingPeriod,
    String? priceDisplay,
    String? equivalentMonthlyDisplay,
    String? badgeText,
    String? savingsPill,
    int? freeTrialDays,
    String? billingFootnote,
    bool? isRecommended,
  }) {
    return PaywallPlanViewModel(
      id: id ?? this.id,
      title: title ?? this.title,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      priceDisplay: priceDisplay ?? this.priceDisplay,
      equivalentMonthlyDisplay:
          equivalentMonthlyDisplay ?? this.equivalentMonthlyDisplay,
      badgeText: badgeText ?? this.badgeText,
      savingsPill: savingsPill ?? this.savingsPill,
      freeTrialDays: freeTrialDays ?? this.freeTrialDays,
      billingFootnote: billingFootnote ?? this.billingFootnote,
      isRecommended: isRecommended ?? this.isRecommended,
    );
  }
}

/// Contextual copy and benefits tailored to the feature trigger.
@immutable
class PaywallContext {
  /// Creates a [PaywallContext].
  const PaywallContext({
    required this.trigger,
    required this.headline,
    required this.subheadline,
    required this.highlights,
    this.eyebrow = 'OPENNOTE PRO',
    this.lockedFeatureName,
    this.lockedFeatureIcon,
  });

  /// Trigger that launched this paywall or feature gate.
  final PaywallTriggerContext trigger;

  /// Uppercase micro-label above the hero title.
  final String eyebrow;

  /// High-impact hero headline.
  final String headline;

  /// Concise supporting value proposition.
  final String subheadline;

  /// Tailored benefit bullets (4 recommended for full paywall, 3 for gate).
  final List<ProFeatureHighlight> highlights;

  /// Specific locked feature label used by contextual gate sheets.
  final String? lockedFeatureName;

  /// Specific icon representing the locked feature in gate sheets.
  final IconData? lockedFeatureIcon;

  /// Returns curated, high-converting copy for a given [trigger].
  factory PaywallContext.forTrigger(PaywallTriggerContext trigger) {
    return switch (trigger) {
      PaywallTriggerContext.engineeringTemplates => const PaywallContext(
        trigger: PaywallTriggerContext.engineeringTemplates,
        headline: 'Draft on Precision Engineering Paper',
        subheadline:
            'Unlock isometric grids, circuit schematics, logarithmic plots, and custom studio templates.',
        lockedFeatureName: 'Engineering Templates',
        lockedFeatureIcon: Icons.grid_4x4_rounded,
        highlights: [
          ProFeatureHighlight(
            icon: Icons.grid_4x4_rounded,
            title: 'Engineering & Isometric Templates',
            subtitle: 'Isometric, polar, Smith chart, and architectural grids.',
            isPrimaryHighlight: true,
          ),
          ProFeatureHighlight(
            icon: Icons.straighten_rounded,
            title: 'Precision Drafting Toolkit',
            subtitle: 'Magnetic ruler, protractor, and clean geometric snaps.',
          ),
          ProFeatureHighlight(
            icon: Icons.picture_as_pdf_rounded,
            title: 'Crisp Vector & Batch Export',
            subtitle: 'Publication-ready SVG and multi-notebook PDF exports.',
          ),
          ProFeatureHighlight(
            icon: Icons.cloud_done_rounded,
            title: 'Encrypted Multi-Device Sync',
            subtitle: 'Keep every diagram backed up and ready everywhere.',
          ),
        ],
      ),
      PaywallTriggerContext.infiniteCloudSync => const PaywallContext(
        trigger: PaywallTriggerContext.infiniteCloudSync,
        headline: 'Your Notes, Synced Everywhere',
        subheadline:
            'End-to-end encrypted cloud backup across iPad, phone, and desktop with zero setup friction.',
        lockedFeatureName: 'Infinite Cloud Sync',
        lockedFeatureIcon: Icons.cloud_sync_rounded,
        highlights: [
          ProFeatureHighlight(
            icon: Icons.cloud_sync_rounded,
            title: 'Automatic Encrypted Cloud Sync',
            subtitle: 'Seamless conflict-free sync with offline-first speed.',
            isPrimaryHighlight: true,
          ),
          ProFeatureHighlight(
            icon: Icons.history_rounded,
            title: 'Version History & Safe Backups',
            subtitle: 'Protect semesters and client diagrams from data loss.',
          ),
          ProFeatureHighlight(
            icon: Icons.all_inclusive_rounded,
            title: 'Unlimited Notebooks & Canvases',
            subtitle:
                'Create as many folders and infinite whiteboards as needed.',
          ),
          ProFeatureHighlight(
            icon: Icons.picture_as_pdf_rounded,
            title: 'Vector & Batch PDF Export',
            subtitle: 'Share sharp diagrams directly to teammates or courses.',
          ),
        ],
      ),
      PaywallTriggerContext.vectorBatchExport => const PaywallContext(
        trigger: PaywallTriggerContext.vectorBatchExport,
        headline: 'Export Razor-Sharp Vector Diagrams',
        subheadline:
            'Deliver crisp SVG schematics, high-DPI prints, and batch PDFs in a single tap.',
        lockedFeatureName: 'Vector & Batch Export',
        lockedFeatureIcon: Icons.ios_share_rounded,
        highlights: [
          ProFeatureHighlight(
            icon: Icons.ios_share_rounded,
            title: 'Scalable Vector SVG & HD PDF',
            subtitle:
                'Zero pixelation in lab reports, papers, and slide decks.',
            isPrimaryHighlight: true,
          ),
          ProFeatureHighlight(
            icon: Icons.library_books_rounded,
            title: 'One-Tap Batch Export',
            subtitle: 'Bundle entire project folders into clean deliverables.',
          ),
          ProFeatureHighlight(
            icon: Icons.straighten_rounded,
            title: 'Precision Drafting Suite',
            subtitle: 'Ruler, protractor, and instant shape straightening.',
          ),
          ProFeatureHighlight(
            icon: Icons.cloud_done_rounded,
            title: 'Encrypted Cloud Backup',
            subtitle: 'Access your notebooks seamlessly on every device.',
          ),
        ],
      ),
      PaywallTriggerContext.precisionDrafting => const PaywallContext(
        trigger: PaywallTriggerContext.precisionDrafting,
        headline: 'Sketch Like an Engineer',
        subheadline:
            'Master clean schematics with magnetic rulers, angle-locked protractors, and tactile studio tools.',
        lockedFeatureName: 'Precision Drafting Tools',
        lockedFeatureIcon: Icons.architecture_rounded,
        highlights: [
          ProFeatureHighlight(
            icon: Icons.architecture_rounded,
            title: 'Magnetic Ruler & Protractor',
            subtitle: 'Snap to 15° increments and measure exact proportions.',
            isPrimaryHighlight: true,
          ),
          ProFeatureHighlight(
            icon: Icons.grid_4x4_rounded,
            title: 'Full Engineering Paper Library',
            subtitle: 'Isometric, dot, blueprint, and technical graph papers.',
          ),
          ProFeatureHighlight(
            icon: Icons.auto_awesome_rounded,
            title: 'Instant Shape & Diagram Polish',
            subtitle: 'Turn quick stylus strokes into crisp technical lines.',
          ),
          ProFeatureHighlight(
            icon: Icons.picture_as_pdf_rounded,
            title: 'Vector SVG & Batch Export',
            subtitle: 'Export clean diagrams ready for docs and presentations.',
          ),
        ],
      ),
      PaywallTriggerContext.unlimitedNotebooks => const PaywallContext(
        trigger: PaywallTriggerContext.unlimitedNotebooks,
        headline: 'Create Without Limits',
        subheadline:
            'Organize every course, project, and engineering notebook with unlimited canvases and folders.',
        lockedFeatureName: 'Unlimited Notebooks',
        lockedFeatureIcon: Icons.book_rounded,
        highlights: [
          ProFeatureHighlight(
            icon: Icons.all_inclusive_rounded,
            title: 'Unlimited Notebooks & Folders',
            subtitle:
                'No caps on pages, infinite canvases, or nested subjects.',
            isPrimaryHighlight: true,
          ),
          ProFeatureHighlight(
            icon: Icons.grid_4x4_rounded,
            title: 'Pro Engineering Templates',
            subtitle: 'Switch between isometric, Cornell, and schematic grids.',
          ),
          ProFeatureHighlight(
            icon: Icons.cloud_sync_rounded,
            title: 'Encrypted Multi-Device Sync',
            subtitle: 'Pick up right where you left off on any screen.',
          ),
          ProFeatureHighlight(
            icon: Icons.ios_share_rounded,
            title: 'Vector & Batch PDF Export',
            subtitle: 'Turn full notebooks into sharp, shareable documents.',
          ),
        ],
      ),
      PaywallTriggerContext.onboardingTrial => const PaywallContext(
        trigger: PaywallTriggerContext.onboardingTrial,
        headline: 'Unlock Your Full Opennote Studio',
        subheadline:
            'Try every Pro drafting tool, engineering template, and export superpower free for 7 days.',
        lockedFeatureName: 'Opennote Pro',
        lockedFeatureIcon: Icons.workspace_premium_rounded,
        highlights: [
          ProFeatureHighlight(
            icon: Icons.all_inclusive_rounded,
            title: 'Unlimited Notebooks & Infinite Canvas',
            subtitle: 'Room for every lecture, system diagram, and brainstorm.',
            isPrimaryHighlight: true,
          ),
          ProFeatureHighlight(
            icon: Icons.architecture_rounded,
            title: 'Precision Drafting & Engineering Grids',
            subtitle: 'Ruler, protractor, isometric grids, and snap geometry.',
          ),
          ProFeatureHighlight(
            icon: Icons.ios_share_rounded,
            title: 'Razor-Sharp Vector & Batch Export',
            subtitle: 'Export crisp SVGs and multi-page PDFs without limits.',
          ),
          ProFeatureHighlight(
            icon: Icons.cloud_done_rounded,
            title: 'Private Encrypted Cloud Sync',
            subtitle: 'Local-first privacy with automatic multi-device backup.',
          ),
        ],
      ),
      PaywallTriggerContext.generalUpgrade => const PaywallContext(
        trigger: PaywallTriggerContext.generalUpgrade,
        headline: 'Upgrade to Opennote Pro',
        subheadline:
            'Everything you need to think, draft, and export at full studio speed.',
        lockedFeatureName: 'Opennote Pro',
        lockedFeatureIcon: Icons.workspace_premium_rounded,
        highlights: [
          ProFeatureHighlight(
            icon: Icons.architecture_rounded,
            title: 'Precision Drafting & Pro Templates',
            subtitle:
                'Magnetic ruler, protractor, isometric & schematic grids.',
            isPrimaryHighlight: true,
          ),
          ProFeatureHighlight(
            icon: Icons.all_inclusive_rounded,
            title: 'Unlimited Notebooks & Canvases',
            subtitle: 'Organize every project without arbitrary page caps.',
          ),
          ProFeatureHighlight(
            icon: Icons.ios_share_rounded,
            title: 'Vector SVG & Batch PDF Export',
            subtitle: 'Share publication-grade diagrams in one tap.',
          ),
          ProFeatureHighlight(
            icon: Icons.cloud_sync_rounded,
            title: 'Encrypted Cloud Sync',
            subtitle: 'Seamless backup and sync across all your devices.',
          ),
        ],
      ),
    };
  }
}

/// Default Opennote Pro plan catalog used when store pricing is not yet loaded.
abstract final class OpennotePaywallDefaults {
  /// Anchored recommended Annual plan with 7-day free trial.
  static const defaultAnnualPlan = PaywallPlanViewModel(
    id: 'opennote_pro_annual',
    title: 'Annual',
    billingPeriod: PaywallBillingPeriod.annual,
    priceDisplay: r'$29.99/yr',
    equivalentMonthlyDisplay: r'$2.50/mo',
    badgeText: 'BEST VALUE · SAVE 50%',
    savingsPill: 'Save 50%',
    freeTrialDays: 7,
    billingFootnote: r'7 days free, then $29.99/yr ($2.50/mo) · Cancel anytime',
    isRecommended: true,
  );

  /// Flexible Monthly subscription plan.
  static const defaultMonthlyPlan = PaywallPlanViewModel(
    id: 'opennote_pro_monthly',
    title: 'Monthly',
    billingPeriod: PaywallBillingPeriod.monthly,
    priceDisplay: r'$4.99/mo',
    equivalentMonthlyDisplay: 'Billed monthly',
    billingFootnote: r'$4.99/month · Cancel anytime in Store settings',
  );

  /// One-time Lifetime IAP unlock.
  static const defaultLifetimePlan = PaywallPlanViewModel(
    id: 'opennote_pro_lifetime',
    title: 'Lifetime',
    billingPeriod: PaywallBillingPeriod.lifetime,
    priceDisplay: r'$69.99',
    equivalentMonthlyDisplay: 'One-time',
    badgeText: 'PAY ONCE',
    billingFootnote: r'One-time purchase ($69.99) · Yours forever',
  );

  /// Ordered default plans with Annual pre-selected as the anchor.
  static const defaultPlans = <PaywallPlanViewModel>[
    defaultAnnualPlan,
    defaultMonthlyPlan,
    defaultLifetimePlan,
  ];
}
