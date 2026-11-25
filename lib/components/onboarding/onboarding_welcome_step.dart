/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:saber/i18n/strings.g.dart';

/// Step 1 hero screen introducing Opennote's speed, precision, and privacy.
class OnboardingWelcomeStep extends StatelessWidget {
  /// Creates the Step 1 welcome hero widget.
  const OnboardingWelcomeStep({super.key});

  static List<_WelcomeHighlight> get _highlights => [
    _WelcomeHighlight(
      icon: Icons.bolt_rounded,
      title: '120Hz Ink',
      subtitle: t.onboarding.flow.welcomeInkSubtitle,
    ),
    _WelcomeHighlight(
      icon: Icons.straighten_rounded,
      title: t.onboarding.flow.welcomeDraftingTitle,
      subtitle: t.onboarding.flow.welcomeDraftingSubtitle,
    ),
    _WelcomeHighlight(
      icon: Icons.all_inclusive_rounded,
      title: t.onboarding.flow.welcomeInfiniteTitle,
      subtitle: t.onboarding.flow.welcomeInfiniteSubtitle,
    ),
    _WelcomeHighlight(
      icon: Icons.lock_outline_rounded,
      title: t.onboarding.flow.welcomePrivacyTitle,
      subtitle: t.onboarding.flow.welcomePrivacySubtitle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        final graphicHeight = isCompact ? 156.0 : 184.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 20 : 28,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroDiagramBanner(height: graphicHeight),
              const SizedBox(height: 20),
              Text(
                'Notes & Diagrams at the Speed of Thought',
                textAlign: TextAlign.center,
                style:
                    (isCompact
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.headlineMedium)
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
              ),
              const SizedBox(height: 10),
              Text(
                'Built for engineers, students, and visual thinkers who want '
                'paper-grade ink without cloud lock-in.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              _HighlightsGrid(highlights: _highlights, twoColumns: !isCompact),
            ],
          ),
        );
      },
    );
  }
}

class _HeroDiagramBanner extends StatelessWidget {
  const _HeroDiagramBanner({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _HeroDiagramPainter(
              primary: colorScheme.primary,
              secondary: colorScheme.tertiary,
              gridColor: colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.28 : 0.45,
              ),
              nodeFill: isDark
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.surface,
              strokeColor: colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroDiagramPainter extends CustomPainter {
  const _HeroDiagramPainter({
    required this.primary,
    required this.secondary,
    required this.gridColor,
    required this.nodeFill,
    required this.strokeColor,
  });

  final Color primary;
  final Color secondary;
  final Color gridColor;
  final Color nodeFill;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBlueprintGrid(canvas, size);
    _paintPrecisionDiagram(canvas, size);
    _paintFluidInkCurve(canvas, size);
  }

  void _paintBlueprintGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    const spacing = 22.0;
    for (double x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _paintPrecisionDiagram(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final leftNode = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.24, h * 0.38),
        width: math.min(w * 0.24, 96),
        height: 36,
      ),
      const Radius.circular(10),
    );
    final rightNode = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.74, h * 0.34),
        width: math.min(w * 0.26, 108),
        height: 36,
      ),
      const Radius.circular(10),
    );
    final bottomNode = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.72),
        width: math.min(w * 0.28, 118),
        height: 34,
      ),
      const Radius.circular(10),
    );

    final connectorPaint = Paint()
      ..color = primary.withValues(alpha: 0.75)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(leftNode.right, leftNode.center.dy)
      ..cubicTo(
        w * 0.44,
        leftNode.center.dy,
        w * 0.50,
        rightNode.center.dy,
        rightNode.left,
        rightNode.center.dy,
      );
    canvas.drawPath(path, connectorPaint);

    final downPath = Path()
      ..moveTo(leftNode.center.dx, leftNode.bottom)
      ..quadraticBezierTo(
        leftNode.center.dx,
        bottomNode.center.dy,
        bottomNode.left,
        bottomNode.center.dy,
      );
    canvas.drawPath(downPath, connectorPaint);

    final fillPaint = Paint()..color = nodeFill;
    final borderPaint = Paint()
      ..color = primary
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    for (final node in [leftNode, rightNode, bottomNode]) {
      canvas.drawRRect(node, fillPaint);
      canvas.drawRRect(node, borderPaint);
    }

    final barPaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.45)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(leftNode.left + 12, leftNode.center.dy),
      Offset(leftNode.right - 14, leftNode.center.dy),
      barPaint,
    );
    canvas.drawLine(
      Offset(rightNode.left + 12, rightNode.center.dy),
      Offset(rightNode.right - 16, rightNode.center.dy),
      barPaint,
    );
    canvas.drawLine(
      Offset(bottomNode.left + 14, bottomNode.center.dy),
      Offset(bottomNode.right - 14, bottomNode.center.dy),
      barPaint,
    );

    final dotPaint = Paint()..color = primary;
    canvas.drawCircle(Offset(rightNode.left, rightNode.center.dy), 4, dotPaint);
    canvas.drawCircle(
      Offset(bottomNode.left, bottomNode.center.dy),
      4,
      dotPaint,
    );
  }

  void _paintFluidInkCurve(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final inkPaint = Paint()
      ..color = secondary
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final inkPath = Path()
      ..moveTo(w * 0.64, h * 0.76)
      ..cubicTo(w * 0.72, h * 0.58, w * 0.80, h * 0.86, w * 0.88, h * 0.66);
    canvas.drawPath(inkPath, inkPaint);

    final angleArcRect = Rect.fromCircle(
      center: Offset(w * 0.14, h * 0.78),
      radius: 18,
    );
    final draftPaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawArc(angleArcRect, -math.pi / 2, math.pi / 2, false, draftPaint);
    canvas.drawLine(
      Offset(w * 0.14, h * 0.78),
      Offset(w * 0.14, h * 0.78 - 22),
      draftPaint,
    );
    canvas.drawLine(
      Offset(w * 0.14, h * 0.78),
      Offset(w * 0.14 + 22, h * 0.78),
      draftPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HeroDiagramPainter oldDelegate) {
    return primary != oldDelegate.primary ||
        secondary != oldDelegate.secondary ||
        gridColor != oldDelegate.gridColor ||
        nodeFill != oldDelegate.nodeFill ||
        strokeColor != oldDelegate.strokeColor;
  }
}

class _HighlightsGrid extends StatelessWidget {
  const _HighlightsGrid({required this.highlights, required this.twoColumns});

  final List<_WelcomeHighlight> highlights;
  final bool twoColumns;

  @override
  Widget build(BuildContext context) {
    if (!twoColumns) {
      return Column(
        children: [
          for (var i = 0; i < highlights.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _HighlightTile(highlight: highlights[i]),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var i = 0; i < highlights.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _HighlightTile(highlight: highlights[i])),
              const SizedBox(width: 10),
              if (i + 1 < highlights.length)
                Expanded(child: _HighlightTile(highlight: highlights[i + 1]))
              else
                const Spacer(),
            ],
          ),
        ],
      ],
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({required this.highlight});

  final _WelcomeHighlight highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  highlight.icon,
                  size: 18,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    highlight.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    highlight.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHighlight {
  const _WelcomeHighlight({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
