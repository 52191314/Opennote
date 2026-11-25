/// 🤖 Generated wholely or partially with Google Antigravity
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';

/// A styled Bento section card used to group related settings.
class BentoSectionCard extends StatelessWidget {
  const BentoSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.subtitle,
    this.badge,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final String? badge;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: margin,
      child: Material(
        color: isDark
            ? OpennoteTokens.cardDarkSurface
            : OpennoteTokens.cardLightSurface,
        borderRadius: BorderRadius.circular(OpennoteTokens.radiusMd + 2),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OpennoteTokens.radiusMd + 2),
            border: Border.fromBorderSide(
              OpennoteTokens.subtleBorder(colorScheme, isDark ? 0.32 : 0.42),
            ),
            boxShadow: OpennoteTokens.cardShadow(colorScheme.brightness),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow.withValues(
                    alpha: isDark ? 0.55 : 0.65,
                  ),
                  border: Border(
                    bottom: OpennoteTokens.subtleBorder(
                      colorScheme,
                      isDark ? 0.24 : 0.3,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(
                          alpha: isDark ? 0.22 : 0.11,
                        ),
                        borderRadius: BorderRadius.circular(
                          OpennoteTokens.radiusSm,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(7),
                        child: Icon(icon, size: 18, color: colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 1),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withValues(
                            alpha: 0.7,
                          ),
                          borderRadius: BorderRadius.circular(
                            OpennoteTokens.radiusPill,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
