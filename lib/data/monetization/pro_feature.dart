/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

/// Broad functional categories for Opennote Pro features.
enum ProFeatureCategory {
  organization,
  templates,
  drafting,
  study,
  export,
  sync,
  customization,
  ai,
}

/// High-value capabilities gated or enhanced by an Opennote Pro entitlement.
enum ProFeature {
  unlimitedNotebooks(
    displayTitle: 'Unlimited Notebooks',
    valueProposition:
        'Organize every class, project, and client without limits.',
    benefitBullets: [
      'Create unlimited notebooks and nested folders',
      'Keep full semester and project archives offline',
      'Instant search across your entire library',
    ],
    iconName: 'library_books',
    category: ProFeatureCategory.organization,
  ),
  proEngineeringTemplates(
    displayTitle: 'Pro Engineering Templates',
    valueProposition:
        'Isometric, logarithmic, circuit, and architectural grids built for technical work.',
    benefitBullets: [
      'Isometric, hex, polar, and Smith-chart paper templates',
      'Precision engineering title blocks and spec sheets',
      'Custom scale and grid spacing per page',
    ],
    iconName: 'grid_4x4',
    category: ProFeatureCategory.templates,
  ),
  precisionDraftingPack(
    displayTitle: 'Precision Drafting Pack',
    valueProposition:
        'CAD-inspired rulers, protractors, and angle snapping for crisp diagrams.',
    benefitBullets: [
      'Snap-to-angle ruler and calibrated protractor overlays',
      'Live dimension callouts and geometric compasses',
      'Perfect straight lines and arcs with stylus or finger',
    ],
    iconName: 'straighten',
    category: ProFeatureCategory.drafting,
  ),
  studyTapePro(
    displayTitle: 'Study Tape Pro',
    valueProposition:
        'Active-recall masking tape with custom colors and one-tap reveal modes.',
    benefitBullets: [
      'Hide formulas, labels, and definitions for active recall',
      'Batch reveal or hide all study tape across a page',
      'Color-coded tape palettes for exam prep',
    ],
    iconName: 'school',
    category: ProFeatureCategory.study,
  ),
  vectorSvgExport(
    displayTitle: 'Vector SVG Export',
    valueProposition:
        'Export razor-sharp, infinitely scalable vector diagrams for papers and slides.',
    benefitBullets: [
      'True vector paths ready for Figma, Illustrator, and LaTeX',
      'Transparent background support for presentations',
      'Lossless clarity at any zoom level or print size',
    ],
    iconName: 'polyline',
    category: ProFeatureCategory.export,
  ),
  batchPdfExport(
    displayTitle: 'Batch PDF Export',
    valueProposition:
        'Compile entire folders or multi-notebook packets into shareable PDFs in one tap.',
    benefitBullets: [
      'Export multiple notebooks or selected page ranges at once',
      'Preserve high-DPI ink fidelity and embedded backgrounds',
      'Fast export workflow for assignments and client deliverables',
    ],
    iconName: 'picture_as_pdf',
    category: ProFeatureCategory.export,
  ),
  pdfDarkModePro(
    displayTitle: 'PDF Dark Mode Pro',
    valueProposition:
        'Read and annotate technical PDFs comfortably at night with smart ink inversion.',
    benefitBullets: [
      'Adaptive dark rendering that preserves diagram contrast',
      'Eye-strain relief during late-night study sessions',
      'Per-document toggle without altering the exported PDF',
    ],
    iconName: 'dark_mode',
    category: ProFeatureCategory.export,
  ),
  unlimitedCloudSync(
    displayTitle: 'Unlimited Cloud Sync',
    valueProposition:
        'End-to-end encrypted sync across iPad, phone, and desktop with zero caps.',
    benefitBullets: [
      'Automatic background sync across all your devices',
      'End-to-end encrypted storage with conflict protection',
      'Seamless offline editing that reconciles when reconnected',
    ],
    iconName: 'cloud_sync',
    category: ProFeatureCategory.sync,
  ),
  customPenPresets(
    displayTitle: 'Custom Pen Presets',
    valueProposition:
        'Save unlimited tailored ink styles, nib pressures, and color palettes.',
    benefitBullets: [
      'Pin favorite pen, highlighter, and technical nib combos',
      'Switch between drafting and sketching kits in one tap',
      'Sync your custom toolbelt across every device',
    ],
    iconName: 'draw',
    category: ProFeatureCategory.customization,
  ),
  aiHandwritingTools(
    displayTitle: 'AI Handwriting Tools',
    valueProposition:
        'Smart handwriting search, equation recognition, and diagram cleanup.',
    benefitBullets: [
      'Convert handwritten math into clean LaTeX equations',
      'Search handwritten notes alongside typed text',
      'Roadmap early-access included with Opennote Pro',
    ],
    iconName: 'auto_awesome',
    category: ProFeatureCategory.ai,
    isRoadmap: true,
  ),
  priorityBackup(
    displayTitle: 'Priority Backup & Snapshots',
    valueProposition:
        'Automated version snapshots so critical engineering notes are never lost.',
    benefitBullets: [
      'Scheduled encrypted archive snapshots',
      'One-tap recovery of earlier notebook revisions',
      'Peace of mind before exams and major deadlines',
    ],
    iconName: 'backup',
    category: ProFeatureCategory.sync,
  );

  const ProFeature({
    required this.displayTitle,
    required this.valueProposition,
    required this.benefitBullets,
    required this.iconName,
    required this.category,
    this.isRoadmap = false,
  });

  /// Short user-facing feature title.
  final String displayTitle;

  /// One-line value proposition displayed on paywalls and feature gate sheets.
  final String valueProposition;

  /// Concise bullet points highlighting concrete user outcomes.
  final List<String> benefitBullets;

  /// Semantic icon identifier for UI layer mapping.
  final String iconName;

  /// Functional grouping for catalog presentation and analytics.
  final ProFeatureCategory category;

  /// Whether this capability is a roadmap early-access feature.
  final bool isRoadmap;

  /// All Pro features currently shipping in production (excludes roadmap items).
  static List<ProFeature> get shippingFeatures =>
      values.where((feature) => !feature.isRoadmap).toList(growable: false);

  /// Filters features belonging to [category].
  static List<ProFeature> byCategory(ProFeatureCategory category) => values
      .where((feature) => feature.category == category)
      .toList(growable: false);
}
