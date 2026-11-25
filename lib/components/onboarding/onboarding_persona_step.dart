/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/onboarding/onboarding_models.dart';

/// Step 2 interactive goal picker that tailors the starter workspace and pitch.
class OnboardingPersonaStep extends StatelessWidget {
  /// Creates the persona selection step.
  const OnboardingPersonaStep({
    super.key,
    required this.selectedPersona,
    required this.onPersonaSelected,
  });

  /// Currently selected user workflow persona.
  final OnboardingPersona selectedPersona;

  /// Invoked when the user taps a persona card.
  final ValueChanged<OnboardingPersona> onPersonaSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        final isCompact = constraints.maxWidth < 400;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 20 : 28,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How will you use Opennote?',
                textAlign: TextAlign.center,
                style:
                    (isCompact
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.headlineMedium)
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick your primary workflow to tailor your starter notebook '
                'and paper template.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              _PersonaCardsLayout(
                selectedPersona: selectedPersona,
                onPersonaSelected: onPersonaSelected,
                twoColumns: isWide,
              ),
              const SizedBox(height: 16),
              _StarterWorkspacePreview(persona: selectedPersona),
            ],
          ),
        );
      },
    );
  }
}

class _PersonaCardsLayout extends StatelessWidget {
  const _PersonaCardsLayout({
    required this.selectedPersona,
    required this.onPersonaSelected,
    required this.twoColumns,
  });

  final OnboardingPersona selectedPersona;
  final ValueChanged<OnboardingPersona> onPersonaSelected;
  final bool twoColumns;

  @override
  Widget build(BuildContext context) {
    const personas = OnboardingPersona.values;
    if (!twoColumns) {
      return Column(
        children: [
          for (var i = 0; i < personas.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _PersonaCard(
              persona: personas[i],
              isSelected: personas[i] == selectedPersona,
              onTap: () => onPersonaSelected(personas[i]),
            ),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var i = 0; i < personas.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _PersonaCard(
                    persona: personas[i],
                    isSelected: personas[i] == selectedPersona,
                    onTap: () => onPersonaSelected(personas[i]),
                  ),
                ),
                const SizedBox(width: 12),
                if (i + 1 < personas.length)
                  Expanded(
                    child: _PersonaCard(
                      persona: personas[i + 1],
                      isSelected: personas[i + 1] == selectedPersona,
                      onTap: () => onPersonaSelected(personas[i + 1]),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PersonaCard extends StatelessWidget {
  const _PersonaCard({
    required this.persona,
    required this.isSelected,
    required this.onTap,
  });

  final OnboardingPersona persona;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: persona.title,
      child: Material(
        color: isSelected
            ? colorScheme.primaryContainer.withValues(alpha: 0.42)
            : colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.7),
            width: isSelected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      persona.icon,
                      size: 20,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        persona.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          child: Text(
                            persona.recommendedPaperTemplate,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarterWorkspacePreview extends StatelessWidget {
  const _StarterWorkspacePreview({required this.persona});

  final OnboardingPersona persona;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Starter notebook: ${persona.starterNotebookTitle}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
