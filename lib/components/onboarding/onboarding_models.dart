/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';

/// Canonical subscription product identifiers offered during onboarding.
abstract final class OnboardingPlanSku {
  /// Annual Opennote Pro subscription with a 7-day free trial.
  static const annual = 'opennote_pro_annual';

  /// Monthly Opennote Pro subscription.
  static const monthly = 'opennote_pro_monthly';
}

/// A single capability highlight tailored to an [OnboardingPersona].
@immutable
class OnboardingSuperpower {
  /// Creates an immutable superpower highlight.
  const OnboardingSuperpower({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  /// Material icon representing the capability.
  final IconData icon;

  /// Short capability headline.
  final String title;

  /// Concise explanation of how this capability helps the user.
  final String subtitle;

  /// Compact badge label summarizing the benefit.
  final String badge;
}

/// Primary note-taking goal selected by the user during Day-0 onboarding.
enum OnboardingPersona {
  /// Technical schematics, architecture diagrams, and drafting.
  engineeringDiagrams(
    title: 'Engineering & Diagrams',
    subtitle: 'System schematics, circuit sketches, and precision drafting.',
    icon: Icons.architecture_rounded,
    recommendedPaperTemplate: 'Blueprint Engineering Grid',
    recommendedTemplateId: 'grid',
    accentPitch:
        'Precision drafting tools and infinite vector grids tuned for technical clarity.',
    starterNotebookTitle: 'System Architecture & Schematics',
    trialHeadline:
        'Unlock precision drafting, unlimited diagrams, and vector exports.',
    trialBenefits: [
      'Precision drafting ruler, compass & auto-snap geometry',
      'Infinite blueprint canvas with multi-layer vector ink',
      'High-resolution PDF & vector SVG exports for technical docs',
    ],
    superpowers: [
      OnboardingSuperpower(
        icon: Icons.straighten_rounded,
        title: 'Drafting Ruler & Snap Shapes',
        subtitle:
            'Draw razor-sharp straight lines, exact angles, and clean blocks that snap effortlessly.',
        badge: 'Precision',
      ),
      OnboardingSuperpower(
        icon: Icons.grid_4x4_rounded,
        title: 'Infinite Blueprint Canvas',
        subtitle:
            'Expand complex architecture flows in any direction without hitting page margins.',
        badge: 'Unbounded',
      ),
      OnboardingSuperpower(
        icon: Icons.gesture_rounded,
        title: '120Hz Vector Ink Engine',
        subtitle:
            'Zero-lag stylus response with crisp zoom-independent vector strokes.',
        badge: '120Hz Ink',
      ),
    ],
  ),

  /// University lectures, STEM coursework, and exam preparation.
  universityNotes(
    title: 'University & Lecture Notes',
    subtitle: 'Fast lecture capture, STEM formulas, and active-recall exams.',
    icon: Icons.school_rounded,
    recommendedPaperTemplate: 'Cornell Active-Recall Grid',
    recommendedTemplateId: 'cornell',
    accentPitch:
        'Capture lectures at full speed and turn notes into active-recall flashcards.',
    starterNotebookTitle: 'Semester Lecture Notes',
    trialHeadline:
        'Master every exam with Study Tape, Cornell templates, and unlimited notebooks.',
    trialBenefits: [
      'Study Tape for instant tap-to-reveal active recall',
      'Cornell, lined, and math grid templates ready out of the box',
      'Scribble-to-erase & circle-to-select keep up with fast lectures',
    ],
    superpowers: [
      OnboardingSuperpower(
        icon: Icons.visibility_off_rounded,
        title: 'Study Tape & Active Recall',
        subtitle:
            'Mask key formulas and definitions, then tap to reveal while quizzing yourself.',
        badge: 'Exam Mode',
      ),
      OnboardingSuperpower(
        icon: Icons.view_quilt_rounded,
        title: 'Cornell & STEM Templates',
        subtitle:
            'Structured cue columns, summary footers, and clean math grids for every course.',
        badge: 'Structured',
      ),
      OnboardingSuperpower(
        icon: Icons.auto_fix_high_rounded,
        title: 'Scribble-to-Erase Gestures',
        subtitle:
            'Scratch out mistakes naturally without ever switching tools mid-lecture.',
        badge: 'Zero Friction',
      ),
    ],
  ),

  /// Reading, highlighting, and marking up academic or work PDFs.
  pdfAnnotation(
    title: 'PDF & Paper Annotation',
    subtitle: 'Research papers, textbooks, contracts, and margin commentary.',
    icon: Icons.picture_as_pdf_rounded,
    recommendedPaperTemplate: 'Infinite-Margin PDF Sheet',
    recommendedTemplateId: 'blank',
    accentPitch:
        'Read comfortably at night and annotate dense documents without cramped margins.',
    starterNotebookTitle: 'Annotated Research Papers',
    trialHeadline:
        'Annotate unlimited PDFs with smart dark mode and lossless markup export.',
    trialBenefits: [
      'Smart PDF Dark Mode that keeps highlights and ink crisp',
      'Infinite margin expansion for deep paper commentary',
      'Lossless vector PDF export with searchable layers intact',
    ],
    superpowers: [
      OnboardingSuperpower(
        icon: Icons.dark_mode_rounded,
        title: 'PDF Dark Mode & Smart Ink',
        subtitle:
            'Invert harsh white pages for late-night reading while keeping ink legible.',
        badge: 'Eye Comfort',
      ),
      OnboardingSuperpower(
        icon: Icons.open_in_full_rounded,
        title: 'Infinite Margin Notes',
        subtitle:
            'Write spacious proofs and summaries beside dense PDF columns.',
        badge: 'Extra Space',
      ),
      OnboardingSuperpower(
        icon: Icons.layers_rounded,
        title: 'Non-Destructive Markup',
        subtitle:
            'Keep highlights, ink, and sticky notes cleanly organized and exportable.',
        badge: 'Clean Export',
      ),
    ],
  ),

  /// Freeform mindmaps, product ideation, and visual thinking.
  visualBrainstorming(
    title: 'Visual Brainstorming',
    subtitle: 'Mindmaps, product flows, moodboards, and freeform ideation.',
    icon: Icons.hub_rounded,
    recommendedPaperTemplate: 'Infinite Dot Canvas',
    recommendedTemplateId: 'dots',
    accentPitch:
        'Think spatially across an unbounded dot canvas with instant lasso organization.',
    starterNotebookTitle: 'Visual Mindmap & Ideas',
    trialHeadline:
        'Think without limits using infinite canvases, custom elements, and pro exports.',
    trialBenefits: [
      'Unbounded infinite dot canvas for sprawling mindmaps',
      'Reusable element & sticker tray for rapid visual framing',
      'Instant circle-to-select lasso for reorganizing ideas fast',
    ],
    superpowers: [
      OnboardingSuperpower(
        icon: Icons.all_inclusive_rounded,
        title: 'Unbounded Infinite Canvas',
        subtitle:
            'Pan and zoom freely across massive visual boards with zero frame drops.',
        badge: 'Infinite',
      ),
      OnboardingSuperpower(
        icon: Icons.polyline_rounded,
        title: 'Circle-to-Select Lasso',
        subtitle:
            'Draw a quick loop around any cluster of ideas to move, scale, or recolor it.',
        badge: 'Fluid Flow',
      ),
      OnboardingSuperpower(
        icon: Icons.dashboard_customize_rounded,
        title: 'Reusable Element Tray',
        subtitle:
            'Save diagrams, callouts, and visual blocks to stamp onto any future board.',
        badge: 'Reusable',
      ),
    ],
  );

  const OnboardingPersona({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.recommendedPaperTemplate,
    required this.recommendedTemplateId,
    required this.accentPitch,
    required this.starterNotebookTitle,
    required this.trialHeadline,
    required this.trialBenefits,
    required this.superpowers,
  });

  /// Display title of the persona.
  final String title;

  /// Short description shown on the persona selection card.
  final String subtitle;

  /// Icon representing this workflow.
  final IconData icon;

  /// Human-readable name of the recommended starter paper template.
  final String recommendedPaperTemplate;

  /// Internal template identifier aligned with Opennote paper patterns.
  final String recommendedTemplateId;

  /// Tailored pitch line shown on the superpower preview step.
  final String accentPitch;

  /// Suggested title for the user's Day-1 starter notebook.
  final String starterNotebookTitle;

  /// Tailored subheadline displayed on the Step 4 trial offer.
  final String trialHeadline;

  /// Tailored list of Pro benefits highlighted on the Step 4 trial offer.
  final List<String> trialBenefits;

  /// Three persona-specific capabilities previewed on Step 3.
  final List<OnboardingSuperpower> superpowers;
}

/// Outcome returned when [OpennoteOnboardingFlow] completes or is dismissed.
@immutable
class OnboardingCompletionResult {
  /// Creates a completion result describing the user's onboarding choices.
  const OnboardingCompletionResult({
    required this.persona,
    required this.startedTrial,
    this.selectedPlanSku,
    this.skipped = false,
    this.restoredPurchases = false,
  });

  /// The workflow persona chosen by the user (defaults to engineering if skipped).
  final OnboardingPersona persona;

  /// Whether the user initiated the 7-day Pro free trial or subscription.
  final bool startedTrial;

  /// Product SKU selected if [startedTrial] is true, otherwise null.
  final String? selectedPlanSku;

  /// Whether the user exited onboarding early via the Skip control.
  final bool skipped;

  /// Whether the user triggered Restore Purchases and restored an entitlement.
  final bool restoredPurchases;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingCompletionResult &&
        other.persona == persona &&
        other.startedTrial == startedTrial &&
        other.selectedPlanSku == selectedPlanSku &&
        other.skipped == skipped &&
        other.restoredPurchases == restoredPurchases;
  }

  @override
  int get hashCode => Object.hash(
    persona,
    startedTrial,
    selectedPlanSku,
    skipped,
    restoredPurchases,
  );

  @override
  String toString() =>
      'OnboardingCompletionResult(persona: $persona, '
      'startedTrial: $startedTrial, selectedPlanSku: $selectedPlanSku, '
      'skipped: $skipped, restoredPurchases: $restoredPurchases)';
}
