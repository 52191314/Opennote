/// 🤖 Generated with DeepSeek v4 Flash
library;

import 'package:flutter/material.dart';

/// Paints a semi-transparent grey circle at the eraser's current position.
///
/// Shows the user where the eraser will act and how large the eraser area is.
class EraserCursorPainter extends CustomPainter {
  final Offset? position;
  final double radius;

  const EraserCursorPainter({
    required this.position,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (position == null) return;

    canvas.drawCircle(
      position!,
      radius,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      position!,
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant EraserCursorPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.radius != radius;
  }
}
