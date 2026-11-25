/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';

/// A centered empty state placeholder used inside the page grid overview.
class PageGridEmptyState extends StatelessWidget {
  /// Creates an empty state with an [icon], [title], and [subtitle].
  const PageGridEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  /// Leading icon representing the empty view.
  final IconData icon;

  /// Primary message shown below the icon.
  final String title;

  /// Supporting hint text shown below the title.
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Icon(
                  icon,
                  size: 40,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
