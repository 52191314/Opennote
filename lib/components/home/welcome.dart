/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saber/i18n/strings.g.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    final colorScheme = ColorScheme.of(context);
    return Center(
      child: Padding(
        padding: const .all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const .symmetric(horizontal: 28, vertical: 36),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow.withValues(alpha: 0.7),
            borderRadius: const .all(.circular(20)),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .center,
            children: [
              SvgPicture.asset(
                'assets/images/undraw_learning_sketching_nd4f.svg',
                width: 260,
                height: 164,
                excludeFromSemantics: true,
              ),
              const SizedBox(height: 36),
              Text(
                t.home.welcome,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                t.home.createNewNote,
                style: textTheme.bodyLarge?.copyWith(
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
