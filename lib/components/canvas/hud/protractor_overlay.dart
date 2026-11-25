/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math';

import 'package:flutter/material.dart';

/// A semi-transparent 180° protractor overlay for angle measurement.
///
/// Renders a circular protractor with degree markings from 0° to 180°.
/// The protractor can be repositioned by dragging.
class ProtractorOverlay extends StatefulWidget {
  const ProtractorOverlay({super.key});

  @override
  State<ProtractorOverlay> createState() => _ProtractorOverlayState();
}

class _ProtractorOverlayState extends State<ProtractorOverlay> {
  var _position = const Offset(100, 100);
  final double _radius = 120;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        child: CustomPaint(
          size: Size(_radius * 2 + 40, _radius + 40),
          painter: _ProtractorPainter(
            radius: _radius,
            surfaceColor: colorScheme.surfaceContainerHighest,
            inkColor: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _ProtractorPainter extends CustomPainter {
  _ProtractorPainter({
    required this.radius,
    required this.surfaceColor,
    required this.inkColor,
  });

  final double radius;
  final Color surfaceColor;
  final Color inkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final fillPaint = Paint()
      ..color = surfaceColor.withValues(alpha: 0.78)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = inkColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      true,
      fillPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      strokePaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      pi,
      pi,
      false,
      strokePaint..color = inkColor.withValues(alpha: 0.35),
    );

    for (int deg = 0; deg <= 180; deg += 5) {
      final radians = pi + deg * pi / 180;
      final isMajor = deg % 30 == 0;
      final isMid = deg % 10 == 0;
      final innerR = isMajor
          ? radius - 20
          : (isMid ? radius - 14 : radius - 10);
      final outerR = radius - 2;

      canvas.drawLine(
        center + Offset(cos(radians) * innerR, sin(radians) * innerR),
        center + Offset(cos(radians) * outerR, sin(radians) * outerR),
        strokePaint
          ..color = inkColor.withValues(
            alpha: isMajor ? 0.9 : (isMid ? 0.65 : 0.45),
          ),
      );

      if (isMajor && deg > 0 && deg < 180) {
        final labelR = radius - 30;
        final tp =
            center + Offset(cos(radians) * labelR, sin(radians) * labelR);
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$deg°',
            style: TextStyle(
              color: inkColor.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          tp - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }

    canvas.drawLine(
      center + Offset(-radius + 2, 0),
      center + Offset(radius - 2, 0),
      strokePaint..color = inkColor.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _ProtractorPainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.surfaceColor != surfaceColor ||
      oldDelegate.inkColor != inkColor;
}
