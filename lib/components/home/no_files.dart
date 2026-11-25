/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/i18n/strings.g.dart';

/// Empty-folder studio card shown in Browse when a directory has no notebooks.
class NoFiles extends StatelessWidget {
  const NoFiles({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: isDark
                ? OpennoteTokens.cardDarkSurface
                : OpennoteTokens.cardLightSurface,
            borderRadius: BorderRadius.circular(OpennoteTokens.radiusLg),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.36),
            ),
            boxShadow: OpennoteTokens.cardShadow(colorScheme.brightness),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/undraw_researching_re_fuod.svg',
                width: 220,
                height: 138,
                excludeFromSemantics: true,
              ),
              const SizedBox(height: 24),
              Text(
                t.home.noFiles,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t.home.createNewNote,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
