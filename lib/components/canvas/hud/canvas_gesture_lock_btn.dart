/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';

/// A sleek Opennote Studio HUD toggle button with crisp 1px borders and
/// high-contrast active state (`primaryContainer` / `onPrimaryContainer`).
class CanvasGestureLockBtn extends StatelessWidget {
  /// Either [icon] or [child] must be provided.
  /// If both are provided, [child] will be used.
  /// If [child] is provided, you are required to handle the animation.
  const CanvasGestureLockBtn({
    super.key,
    required this.lock,
    required this.setLock,
    required this.tooltip,
    this.icon,
    this.child,
  }) : assert(icon != null || child != null);

  final bool lock;
  final ValueChanged<bool> setLock;
  final String tooltip;
  final IconData? icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final fgColor = lock
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    return GestureDetector(
      onTap: () => setLock(!lock),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: lock
              ? colorScheme.primaryContainer.withValues(alpha: 0.92)
              : colorScheme.surface.withValues(alpha: 0.85),
          borderRadius: const .all(.circular(12)),
          border: Border.all(
            color: lock
                ? colorScheme.primary.withValues(alpha: 0.6)
                : colorScheme.outlineVariant.withValues(alpha: 0.55),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const .all(5),
        child: Tooltip(
          message: tooltip,
          child: IconTheme.merge(
            data: IconThemeData(color: fgColor, size: 18),
            child:
                child ??
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    key: ValueKey(icon),
                    size: 18,
                    color: fgColor,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
