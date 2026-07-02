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
  Offset _position = const Offset(100, 100);
  double _radius = 120;

  @override
  Widget build(BuildContext context) {
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
          painter: _ProtractorPainter(radius: _radius),
        ),
      ),
    );
  }
}

class _ProtractorPainter extends CustomPainter {
  _ProtractorPainter({required this.radius});

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final paint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0x88FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Background semi-circle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      true,
      paint,
    );

    // Outer arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      strokePaint,
    );

    // Inner arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      pi,
      pi,
      false,
      strokePaint..color = const Color(0x44FFFFFF),
    );

    // Degree markings
    for (int deg = 0; deg <= 180; deg += 5) {
      final radians = pi + deg * pi / 180;
      final isMajor = deg % 30 == 0;
      final isMid = deg % 10 == 0;
      final innerR = isMajor ? radius - 20 : (isMid ? radius - 14 : radius - 10);
      final outerR = radius - 2;

      canvas.drawLine(
        center + Offset(cos(radians) * innerR, sin(radians) * innerR),
        center + Offset(cos(radians) * outerR, sin(radians) * outerR),
        strokePaint..color = isMajor ? const Color(0xCCFFFFFF) : const Color(0x66FFFFFF),
      );

      // Label every 30 degrees
      if (isMajor && deg > 0 && deg < 180) {
        final labelR = radius - 30;
        final tp = center + Offset(cos(radians) * labelR, sin(radians) * labelR);
        final textPainter = TextPainter(
          text: TextSpan(
            text: '$deg°',
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          tp - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }

    // Baseline (0° to 180° line)
    canvas.drawLine(
      center + Offset(-radius + 2, 0),
      center + Offset(radius - 2, 0),
      strokePaint..color = const Color(0x66FFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant _ProtractorPainter oldDelegate) =>
      oldDelegate.radius != radius;
}
