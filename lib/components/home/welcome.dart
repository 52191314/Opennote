/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/home/quick_template_strip.dart';
import 'package:saber/i18n/strings.g.dart';

/// Inspiring empty-state studio card shown on Home when no notebooks exist yet,
/// pairing the welcome greeting with one-tap starter template buttons.
class Welcome extends StatelessWidget {
  const Welcome({
    super.key,
    this.onCreateTemplate,
    this.onProTemplateTap,
    this.onImportPdf,
  });

  final ValueChanged<QuickTemplateKind>? onCreateTemplate;
  final ValueChanged<QuickTemplateKind>? onProTemplateTap;
  final VoidCallback? onImportPdf;

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
          decoration: BoxDecoration(
            color: isDark
                ? OpennoteTokens.cardDarkSurface
                : OpennoteTokens.cardLightSurface,
            borderRadius: BorderRadius.circular(OpennoteTokens.radiusLg),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.38),
            ),
            boxShadow: OpennoteTokens.cardShadow(colorScheme.brightness),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/images/undraw_learning_sketching_nd4f.svg',
                width: 210,
                height: 132,
                excludeFromSemantics: true,
              ),
              const SizedBox(height: 20),
              Text(
                'Start Your First Notebook',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                t.home.welcome,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
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
              const SizedBox(height: 20),
              QuickTemplateStrip(
                compact: true,
                showHeader: false,
                onCreateTemplate: onCreateTemplate,
                onProTemplateTap: onProTemplateTap,
                onImportPdf: onImportPdf,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
