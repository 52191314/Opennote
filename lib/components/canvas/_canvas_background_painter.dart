/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saber/data/extensions/color_extensions.dart';
import 'package:sbn/canvas_background_pattern.dart';

class CanvasBackgroundPainter extends CustomPainter {
  const CanvasBackgroundPainter({
    required this.invert,
    required this.backgroundColor,
    this.backgroundPattern = .none,
    required this.lineHeight,
    required this.lineThickness,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.red,
    this.preview = false,
    this.isInfiniteCanvas = false,
  });

  final bool invert;
  final Color backgroundColor;

  /// The pattern to use for the background. See [CanvasBackgroundPatterns].
  final CanvasBackgroundPattern backgroundPattern;

  /// The height between each line in the background pattern
  final int lineHeight;
  final int lineThickness;
  final Color primaryColor, secondaryColor;

  /// Whether to draw the background pattern in a preview mode (more opaque).
  final bool preview;

  /// Whether to paint an unbounded 2D infinite canvas.
  final bool isInfiniteCanvas;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect visibleRect;
    if (isInfiniteCanvas) {
      final clip = canvas.getLocalClipBounds();
      if (_isValidViewport(clip)) {
        visibleRect = clip;
      } else {
        // Safe bounded canvas region around the page for infinite canvas
        const margin = 2000.0;
        final baseWidth = size.width.isFinite && size.width > 0 ? size.width : 1000.0;
        final baseHeight = size.height.isFinite && size.height > 0 ? size.height : 1400.0;
        visibleRect = Rect.fromLTRB(
          -margin,
          -margin,
          baseWidth + margin,
          baseHeight + margin,
        );
      }
    } else {
      visibleRect = Offset.zero & size;
    }
    final paint = Paint();

    paint.color = backgroundColor.withInversion(invert);
    canvas.drawRect(visibleRect, paint);

    if (!isInfiniteCanvas && backgroundPattern.requiresClipping) {
      canvas.save();
      canvas.clipRect(visibleRect);
    }

    for (final element in getPatternElements(
      pattern: backgroundPattern,
      size: size,
      lineHeight: lineHeight,
      lineThickness: lineThickness,
      bounds: isInfiniteCanvas ? visibleRect : null,
    )) {
      paint.strokeWidth = element.thickness ?? lineThickness.toDouble();

      if (element.secondaryColor) {
        paint.color = secondaryColor.withValues(alpha: preview ? 0.5 : 0.2);
      } else {
        paint.color = primaryColor.withValues(alpha: preview ? 0.5 : 0.2);
      }

      if (element.isLine) {
        canvas.drawLine(element.start, element.end, paint);
      } else {
        canvas.drawCircle(element.start, paint.strokeWidth * 4 / 3, paint);
      }
    }

    if (!isInfiniteCanvas && backgroundPattern.requiresClipping) {
      canvas.restore();
    }
  }

  /// Whether a clip rect represents a real, finite visible viewport rather
  /// than an unclipped Skia/Impeller sentinel (e.g. [-1e9, -1e9, 1e9, 1e9])
  /// or a runaway dimension.
  static bool _isValidViewport(Rect rect) {
    if (!rect.isFinite || rect.isEmpty) return false;
    // Skia unclipped sentinels use ±1e9. Any boundary beyond ±1e8
    // or span exceeding 15,000 pixels is unclipped/invalid.
    if (rect.left <= -1e8 ||
        rect.top <= -1e8 ||
        rect.right >= 1e8 ||
        rect.bottom >= 1e8) {
      return false;
    }
    if (rect.width > 15000 || rect.height > 15000) {
      return false;
    }
    return true;
  }

  @override
  bool shouldRepaint(CanvasBackgroundPainter oldDelegate) =>
      isInfiniteCanvas ||
      kDebugMode ||
      oldDelegate.invert != invert ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.backgroundPattern != backgroundPattern ||
      oldDelegate.lineHeight != lineHeight ||
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor ||
      oldDelegate.isInfiniteCanvas != isInfiniteCanvas;

  static Iterable<PatternElement> getPatternElements({
    required CanvasBackgroundPattern pattern,
    required Size size,
    required int lineHeight,
    int lineThickness = 3,
    Rect? bounds,
  }) sync* {
    if (lineHeight <= 0) return;
    if (bounds != null) {
      if (!bounds.isFinite || bounds.isEmpty) return;
      // Clamp bounds to prevent runaway memory allocation or freeze
      final clampedBounds = Rect.fromLTRB(
        bounds.left.clamp(-20000.0, 20000.0),
        bounds.top.clamp(-20000.0, 20000.0),
        bounds.right.clamp(-20000.0, 20000.0),
        bounds.bottom.clamp(-20000.0, 20000.0),
      );
      if (clampedBounds.isEmpty) return;

      switch (pattern) {
        case .none:
          return;
        case .collegeLtr:
        case .collegeRtl:
        case .lined:
          final startY =
              (clampedBounds.top / lineHeight).floor() * lineHeight.toDouble();
          final endY =
              (clampedBounds.bottom / lineHeight).ceil() * lineHeight.toDouble();
          final count = ((endY - startY) / lineHeight).ceil();
          if (count > 2000) return;
          for (double y = startY; y <= endY; y += lineHeight) {
            yield PatternElement(
              Offset(clampedBounds.left, y),
              Offset(clampedBounds.right, y),
              isLine: true,
            );
          }
          if (pattern == .collegeLtr) {
            yield PatternElement(
              Offset(lineHeight * 2, clampedBounds.top),
              Offset(lineHeight * 2, clampedBounds.bottom),
              isLine: true,
              secondaryColor: true,
            );
          } else if (pattern == .collegeRtl) {
            yield PatternElement(
              Offset(size.width - lineHeight * 2, clampedBounds.top),
              Offset(size.width - lineHeight * 2, clampedBounds.bottom),
              isLine: true,
              secondaryColor: true,
            );
          }
        case .grid:
          final startX =
              (clampedBounds.left / lineHeight).floor() * lineHeight.toDouble();
          final endX =
              (clampedBounds.right / lineHeight).ceil() * lineHeight.toDouble();
          final startY =
              (clampedBounds.top / lineHeight).floor() * lineHeight.toDouble();
          final endY =
              (clampedBounds.bottom / lineHeight).ceil() * lineHeight.toDouble();
          final countX = ((endX - startX) / lineHeight).ceil();
          final countY = ((endY - startY) / lineHeight).ceil();
          if (countX > 2000 || countY > 2000) return;
          for (double y = startY; y <= endY; y += lineHeight) {
            yield PatternElement(
              Offset(clampedBounds.left, y),
              Offset(clampedBounds.right, y),
              isLine: true,
            );
          }
          for (double x = startX; x <= endX; x += lineHeight) {
            yield PatternElement(
              Offset(x, clampedBounds.top),
              Offset(x, clampedBounds.bottom),
              isLine: true,
            );
          }
        case .dots:
          final startX =
              (clampedBounds.left / lineHeight).floor() * lineHeight.toDouble();
          final endX =
              (clampedBounds.right / lineHeight).ceil() * lineHeight.toDouble();
          final startY =
              (clampedBounds.top / lineHeight).floor() * lineHeight.toDouble();
          final endY =
              (clampedBounds.bottom / lineHeight).ceil() * lineHeight.toDouble();
          final countX = ((endX - startX) / lineHeight).ceil();
          final countY = ((endY - startY) / lineHeight).ceil();
          if (countX * countY > 30000) return;
          for (double y = startY; y <= endY; y += lineHeight) {
            for (double x = startX; x <= endX; x += lineHeight) {
              yield PatternElement(Offset(x, y), Offset(x, y), isLine: false);
            }
          }
        case .engineeringGrid:
          final startX =
              (clampedBounds.left / lineHeight).floor() * lineHeight.toDouble();
          final endX =
              (clampedBounds.right / lineHeight).ceil() * lineHeight.toDouble();
          final startY =
              (clampedBounds.top / lineHeight).floor() * lineHeight.toDouble();
          final endY =
              (clampedBounds.bottom / lineHeight).ceil() * lineHeight.toDouble();
          final countX = ((endX - startX) / lineHeight).ceil();
          final countY = ((endY - startY) / lineHeight).ceil();
          if (countX > 2000 || countY > 2000) return;
          for (double y = startY; y <= endY; y += lineHeight) {
            final isHeavy = (y / lineHeight).round() % 10 == 0;
            yield PatternElement(
              Offset(clampedBounds.left, y),
              Offset(clampedBounds.right, y),
              thickness: isHeavy ? lineThickness * 3.0 : null,
            );
          }
          for (double x = startX; x <= endX; x += lineHeight) {
            final isHeavy = (x / lineHeight).round() % 10 == 0;
            yield PatternElement(
              Offset(x, clampedBounds.top),
              Offset(x, clampedBounds.bottom),
              thickness: isHeavy ? lineThickness * 3.0 : null,
            );
          }
        case .isometric:
          final l = lineHeight.toDouble();
          final dx = l * (sqrt(3) / 2);
          if (dx <= 0) return;
          final tan30 = 1 / sqrt(3);

          final colMin = (clampedBounds.left / dx).floor();
          final colMax = (clampedBounds.right / dx).ceil();
          if (colMax - colMin > 2000) return;
          for (int col = colMin; col <= colMax; col++) {
            final x = col * dx;
            yield PatternElement(
              Offset(x, clampedBounds.top),
              Offset(x, clampedBounds.bottom),
            );
          }

          final mMin = ((clampedBounds.top - tan30 * clampedBounds.right) / l).floor();
          final mMax = ((clampedBounds.bottom - tan30 * clampedBounds.left) / l).ceil();
          if (mMax - mMin > 2000) return;
          for (int m = mMin; m <= mMax; m++) {
            final b = m * l;
            final x1 = (clampedBounds.top - b) / tan30;
            final x2 = (clampedBounds.bottom - b) / tan30;
            yield PatternElement(
              Offset(x1, clampedBounds.top),
              Offset(x2, clampedBounds.bottom),
            );
          }

          final kMin = ((clampedBounds.top + tan30 * clampedBounds.left) / l).floor();
          final kMax = ((clampedBounds.bottom + tan30 * clampedBounds.right) / l).ceil();
          if (kMax - kMin > 2000) return;
          for (int k = kMin; k <= kMax; k++) {
            final c = k * l;
            final x1 = (c - clampedBounds.top) / tan30;
            final x2 = (c - clampedBounds.bottom) / tan30;
            yield PatternElement(
              Offset(x1, clampedBounds.top),
              Offset(x2, clampedBounds.bottom),
            );
          }
        case .staffs:
        case .tablature:
        case .cornell:
          final startY =
              (clampedBounds.top / lineHeight).floor() * lineHeight.toDouble();
          final endY =
              (clampedBounds.bottom / lineHeight).ceil() * lineHeight.toDouble();
          final count = ((endY - startY) / lineHeight).ceil();
          if (count > 2000) return;
          for (double y = startY; y <= endY; y += lineHeight) {
            yield PatternElement(
              Offset(clampedBounds.left, y),
              Offset(clampedBounds.right, y),
              isLine: true,
            );
          }
      }
      return;
    }
    switch (pattern) {
      case .none:
        return;
      case .collegeLtr:
      case .collegeRtl:
      case .lined:
        // horizontal lines
        for (double y = lineHeight * 2; y < size.height; y += lineHeight) {
          yield PatternElement(
            Offset(0, y),
            Offset(size.width, y),
            isLine: true,
          );
        }

        // vertical line
        if (pattern == .collegeLtr) {
          yield PatternElement(
            Offset(lineHeight * 2, 0),
            Offset(lineHeight * 2, size.height),
            isLine: true,
            secondaryColor: true,
          );
        } else if (pattern == .collegeRtl) {
          yield PatternElement(
            Offset(size.width - lineHeight * 2, 0),
            Offset(size.width - lineHeight * 2, size.height),
            isLine: true,
            secondaryColor: true,
          );
        }
      case .grid:
        for (double y = lineHeight * 2; y < size.height; y += lineHeight) {
          yield PatternElement(
            Offset(0, y),
            Offset(size.width, y),
            isLine: true,
          );
        }
        for (double x = 0; x < size.width; x += lineHeight) {
          yield PatternElement(
            Offset(x, lineHeight * 2),
            Offset(x, size.height),
            isLine: true,
          );
        }
      case .dots:
        for (double y = lineHeight * 2; y <= size.height; y += lineHeight) {
          for (double x = 0; x <= size.width; x += lineHeight) {
            yield PatternElement(Offset(x, y), Offset(x, y), isLine: false);
          }
        }
      case .staffs:
      case .tablature:
        final staffSpaces = pattern == .staffs ? 4 : 5;
        final staffHeight = lineHeight * staffSpaces;
        final staffSpacing = lineHeight * 3;

        for (
          double topOfStaff = staffSpacing.toDouble() - lineHeight;
          topOfStaff + staffHeight < size.height;
          topOfStaff += staffHeight + staffSpacing
        ) {
          // horizontal lines
          for (int line = 0; line < staffSpaces + 1; line++) {
            yield PatternElement(
              Offset(lineHeight.toDouble(), topOfStaff + lineHeight * line),
              Offset(size.width - lineHeight, topOfStaff + lineHeight * line),
              isLine: true,
            );
          }

          // vertical lines on either side
          yield PatternElement(
            Offset(lineHeight.toDouble(), topOfStaff),
            Offset(lineHeight.toDouble(), topOfStaff + staffHeight),
            isLine: true,
          );
          yield PatternElement(
            Offset(size.width - lineHeight, topOfStaff),
            Offset(size.width - lineHeight, topOfStaff + staffHeight),
            isLine: true,
          );
        }
      case .isometric:
        if (lineHeight <= 0) return;
        final l = lineHeight.toDouble();
        final dx = l * (sqrt(3) / 2);
        final tan30 = 1 / sqrt(3); // tan(30°) = 1/√3

        // Vertical lines: x = col * dx
        for (double x = 0; x <= size.width + 1e-6; x += dx) {
          final clampedX = x.clamp(0.0, size.width);
          yield PatternElement(
            Offset(clampedX, 0),
            Offset(clampedX, size.height),
          );
        }

        // +30° lines (right-leaning): y = tan30 * x + m * l, for integer m
        final mMin = (-tan30 * size.width / l).floor();
        final mMax = (size.height / l).ceil();
        for (int m = mMin; m <= mMax; m++) {
          final b = m * l;
          final candidates = <Offset>[];

          // Edge x = 0
          if (b >= 0 && b <= size.height) {
            candidates.add(Offset(0, b));
          }
          // Edge y = 0: x = -b / tan30
          final xTop = -b / tan30;
          if (xTop > 0 && xTop < size.width) {
            candidates.add(Offset(xTop, 0));
          }
          // Edge x = size.width: y = tan30 * size.width + b
          final yRight = tan30 * size.width + b;
          if (yRight >= 0 && yRight <= size.height) {
            candidates.add(Offset(size.width, yRight));
          }
          // Edge y = size.height: x = (size.height - b) / tan30
          final xBottom = (size.height - b) / tan30;
          if (xBottom > 0 && xBottom < size.width) {
            candidates.add(Offset(xBottom, size.height));
          }

          if (candidates.length >= 2) {
            candidates.sort((a, b) => a.dx.compareTo(b.dx));
            final start = Offset(
              candidates.first.dx.clamp(0.0, size.width),
              candidates.first.dy.clamp(0.0, size.height),
            );
            final end = Offset(
              candidates.last.dx.clamp(0.0, size.width),
              candidates.last.dy.clamp(0.0, size.height),
            );
            if ((end.dx - start.dx).abs() > 1e-4 ||
                (end.dy - start.dy).abs() > 1e-4) {
              yield PatternElement(start, end);
            }
          }
        }

        // -30° lines (left-leaning): y = -tan30 * x + k * l, for integer k
        const kMin = 0;
        final kMax = ((size.height + tan30 * size.width) / l).ceil();
        for (int k = kMin; k <= kMax; k++) {
          final c = k * l;
          final candidates = <Offset>[];

          // Edge x = 0
          if (c >= 0 && c <= size.height) {
            candidates.add(Offset(0, c));
          }
          // Edge y = 0: x = c / tan30
          final xTop = c / tan30;
          if (xTop > 0 && xTop < size.width) {
            candidates.add(Offset(xTop, 0));
          }
          // Edge x = size.width: y = -tan30 * size.width + c
          final yRight = -tan30 * size.width + c;
          if (yRight >= 0 && yRight <= size.height) {
            candidates.add(Offset(size.width, yRight));
          }
          // Edge y = size.height: x = (c - size.height) / tan30
          final xBottom = (c - size.height) / tan30;
          if (xBottom > 0 && xBottom < size.width) {
            candidates.add(Offset(xBottom, size.height));
          }

          if (candidates.length >= 2) {
            candidates.sort((a, b) => a.dx.compareTo(b.dx));
            final start = Offset(
              candidates.first.dx.clamp(0.0, size.width),
              candidates.first.dy.clamp(0.0, size.height),
            );
            final end = Offset(
              candidates.last.dx.clamp(0.0, size.width),
              candidates.last.dy.clamp(0.0, size.height),
            );
            if ((end.dx - start.dx).abs() > 1e-4 ||
                (end.dy - start.dy).abs() > 1e-4) {
              yield PatternElement(start, end);
            }
          }
        }
      case .engineeringGrid:
        // Heavy grid lines every 10 lines calculated by integer index
        for (double y = lineHeight * 2; y < size.height; y += lineHeight) {
          final isHeavy = ((y - lineHeight * 2) / lineHeight).round() % 10 == 0;
          yield PatternElement(
            Offset(0, y),
            Offset(size.width, y),
            thickness: isHeavy ? lineThickness * 3.0 : null,
          );
        }
        for (double x = 0; x < size.width; x += lineHeight) {
          final isHeavy = (x / lineHeight).round() % 10 == 0;
          yield PatternElement(
            Offset(x, lineHeight * 2),
            Offset(x, size.height),
            thickness: isHeavy ? lineThickness * 3.0 : null,
          );
        }
      case .cornell:
        final headerBottom = lineHeight * 3.5;
        // half-width line for name field
        yield PatternElement(
          Offset(lineHeight.toDouble(), lineHeight * 2),
          Offset(size.width / 2 - lineHeight / 2, lineHeight * 2),
          isLine: true,
        );
        // half-width line for date field
        yield PatternElement(
          Offset(size.width / 2 + lineHeight / 2, lineHeight * 2),
          Offset(size.width - lineHeight, lineHeight * 2),
          isLine: true,
        );
        // full-width line for title field
        yield PatternElement(
          Offset(lineHeight.toDouble(), lineHeight * 3),
          Offset(size.width - lineHeight, lineHeight * 3),
          isLine: true,
        );

        // Standard Cornell dimensions: Cue column (28% width), Summary section (75% height)
        final cueRight = size.width * 0.28;
        final summaryTop = size.height * 0.75;

        // Vertical dividing line separating the Cue column from Main Notes
        yield PatternElement(
          Offset(cueRight, headerBottom),
          Offset(cueRight, summaryTop),
          isLine: true,
          thickness: lineThickness * 1.5,
          secondaryColor: true,
        );

        // Horizontal dividing line separating Notes from Summary
        yield PatternElement(
          Offset(lineHeight.toDouble(), summaryTop),
          Offset(size.width - lineHeight, summaryTop),
          isLine: true,
          thickness: lineThickness * 1.5,
          secondaryColor: true,
        );

        // Ruled lines for main notes
        for (double y = lineHeight * 5; y < summaryTop; y += lineHeight) {
          yield PatternElement(
            Offset(cueRight, y),
            Offset(size.width - lineHeight, y),
            isLine: true,
          );
        }

        // Ruled lines for bottom summary section
        for (
          double y = summaryTop + lineHeight;
          y < size.height - lineHeight;
          y += lineHeight
        ) {
          yield PatternElement(
            Offset(lineHeight.toDouble(), y),
            Offset(size.width - lineHeight, y),
            isLine: true,
          );
        }
    }
  }
}

class PatternElement {
  final Offset start, end;

  /// Whether this is a line or a dot
  final bool isLine;

  /// Whether this should use a secondary color
  final bool secondaryColor;

  /// Optional explicit thickness. If null, [CanvasBackgroundPainter.lineThickness] is used.
  final double? thickness;

  PatternElement(
    this.start,
    this.end, {
    this.isLine = true,
    this.secondaryColor = false,
    this.thickness,
  });
}
