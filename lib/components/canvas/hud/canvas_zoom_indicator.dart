/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart' hide TransformationController;

/// A sleek Opennote Studio HUD capsule displaying the current canvas zoom
/// magnification with a 1-tap reset action.
class CanvasZoomIndicator extends StatelessWidget {
  const CanvasZoomIndicator({
    super.key,
    required this.scale,
    required this.resetZoom,
  });

  final double scale;
  final VoidCallback? resetZoom;

  /// Formats the zoom magnification: displays percentage for scale < 0.1
  /// and multiplier 'Xx' for scale >= 0.1.
  static String formatZoomText(double scale) {
    if (scale < 0.01) {
      return '${(scale * 100).toStringAsFixed(1)}%';
    } else if (scale < 0.1) {
      return '${(scale * 100).toStringAsFixed(0)}%';
    } else {
      return '${scale.toStringAsFixed(1)}x';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return InkWell(
      borderRadius: const .all(.circular(12)),
      onTap: resetZoom,
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.85),
          borderRadius: const .all(.circular(12)),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
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
        padding: const .symmetric(horizontal: 10, vertical: 5),
        child: Text(
          formatZoomText(scale),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
