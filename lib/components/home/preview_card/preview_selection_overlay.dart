/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';

/// Translucent selection overlay with a crisp top-right check badge displayed
/// when a notebook preview card is selected.
class PreviewSelectionOverlay extends StatelessWidget {
  const PreviewSelectionOverlay({
    super.key,
    required this.selectedListenable,
    required this.onTap,
  });

  final ValueNotifier<bool> selectedListenable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);

    return Positioned.fill(
      left: -1,
      top: -1,
      right: -1,
      bottom: -1,
      child: ValueListenableBuilder<bool>(
        valueListenable: selectedListenable,
        builder: (context, isSelected, child) => AnimatedOpacity(
          opacity: isSelected ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: IgnorePointer(ignoring: !isSelected, child: child!),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.18),
                  colorScheme.surface.withValues(alpha: 0.65),
                  colorScheme.surface.withValues(alpha: 0.92),
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
