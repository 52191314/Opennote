/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

/// The visual texture/pattern rendered on the tape when concealed.
enum TapePattern {
  solid,
  stripes,
  dots,
  grid;

  static const defaultPattern = TapePattern.solid;
}

/// A stroke representing an interactive masking tape strip used for active recall.
///
/// When [isConcealed] is true, the tape is drawn as an opaque colored strip
/// concealing the text/drawing underneath with an optional [pattern].
/// Tapping the tape toggles [isConcealed], rendering it as a translucent wash
/// with an outline to reveal the answer.
class TapeStroke extends Stroke {
  Rect rect;
  bool isConcealed;
  TapePattern pattern;

  TapeStroke({
    required super.color,
    required super.pressureEnabled,
    required super.options,
    required super.pageIndex,
    required super.page,
    required super.toolId,
    required this.rect,
    this.isConcealed = true,
    this.pattern = TapePattern.solid,
    super.fillColor,
    super.lineStyle,
  }) {
    options.isComplete = true;
  }

  factory TapeStroke.fromJson(
    Map<String, dynamic> json, {
    required int fileVersion,
    required int pageIndex,
    required HasSize page,
  }) {
    assert(json['shape'] == 'tape');
    assert(json['i'] == pageIndex || json['i'] == null);

    final Color color;
    switch (json['c']) {
      case (final int value):
        color = Color(value);
      case (final Int64 value):
        color = Color(value.toInt());
      case null:
        color = const Color(0xFFFFD54F); // Default pastel tape yellow
      default:
        throw Exception(
          'Invalid color value: (${json['c'].runtimeType}) ${json['c']}',
        );
    }

    final bool isConcealed = json['c_state'] as bool? ?? true;
    final TapePattern pattern = switch (json['tp'] as String?) {
      'stripes' => TapePattern.stripes,
      'dots' => TapePattern.dots,
      'grid' => TapePattern.grid,
      _ => TapePattern.solid,
    };

    return TapeStroke(
      color: color,
      pressureEnabled: json['pe'] ?? Stroke.defaultPressureEnabled,
      options: StrokeOptions.fromJson(json),
      pageIndex: pageIndex,
      page: page,
      toolId: ToolId.parsePenType(json['ty'], fallback: ToolId.studyTape),
      rect: Rect.fromLTWH(
        (json['rl'] as num?)?.toDouble() ?? 0,
        (json['rt'] as num?)?.toDouble() ?? 0,
        (json['rw'] as num?)?.toDouble() ?? 0,
        (json['rh'] as num?)?.toDouble() ?? 0,
      ),
      isConcealed: isConcealed,
      pattern: pattern,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'shape': 'tape',
      'i': pageIndex,
      'rl': rect.left,
      'rt': rect.top,
      'rw': rect.width,
      'rh': rect.height,
      'c_state': isConcealed,
      'tp': pattern.name,
      'pe': pressureEnabled,
      'c': color.toARGB32(),
      'ty': toolId.id,
    }..addAll(options.toJson());
  }

  /// Toggles the conceal/reveal state of the tape.
  void toggleConceal() {
    isConcealed = !isConcealed;
  }

  @override
  bool get isEmpty => rect.isEmpty;

  @override
  int get length => 100;

  @override
  List<Offset> getPolygon({required StrokeQuality quality}) => [
    for (int i = 0; i < 24 / quality.N; ++i)
      Offset(rect.left, rect.top + rect.height * i / 24),
    for (int i = 0; i < 24 / quality.N; ++i)
      Offset(rect.left + rect.width * i / 24, rect.bottom),
    for (int i = 0; i < 24 / quality.N; ++i)
      Offset(rect.right, rect.bottom - rect.height * i / 24),
    for (int i = 0; i < 24 / quality.N; ++i)
      Offset(rect.right - rect.width * i / 24, rect.top),
  ];

  @override
  Path getPath(List<Offset> polygon, {bool smooth = true}) =>
      Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)));

  @override
  @Deprecated('Cannot add points to a tape stroke.')
  void addPoint(Offset point, [double? pressure]) {
    throw UnsupportedError('Cannot add points to a tape stroke.');
  }

  @override
  @Deprecated('Cannot pop points from a tape stroke.')
  void popFirstPoint() {
    throw UnsupportedError('Cannot pop points from a tape stroke.');
  }

  @override
  void optimisePoints({double thresholdMultiplier = 0}) {
    // no-op
  }

  @override
  String toSvgPath() {
    return 'M${rect.left},${rect.top} '
        'L${rect.right},${rect.top} '
        'L${rect.right},${rect.bottom} '
        'L${rect.left},${rect.bottom} '
        'Z';
  }

  @override
  double get maxY => rect.bottom;

  @override
  void shift(Offset offset) {
    rect = rect.shift(offset);
    super.shift(offset);
  }

  @override
  void rotateAround(double angleRadians, Offset center) {
    if (angleRadians == 0) return;

    final cosA = cos(angleRadians);
    final sinA = sin(angleRadians);

    Offset rotatePoint(Offset p) {
      final dx = p.dx - center.dx;
      final dy = p.dy - center.dy;
      return Offset(
        center.dx + dx * cosA - dy * sinA,
        center.dy + dx * sinA + dy * cosA,
      );
    }

    final topLeft = rotatePoint(rect.topLeft);
    final topRight = rotatePoint(rect.topRight);
    final bottomRight = rotatePoint(rect.bottomRight);
    final bottomLeft = rotatePoint(rect.bottomLeft);

    final newLeft = min(topLeft.dx, min(topRight.dx, min(bottomRight.dx, bottomLeft.dx)));
    final newTop = min(topLeft.dy, min(topRight.dy, min(bottomRight.dy, bottomLeft.dy)));
    final newRight = max(topLeft.dx, max(topRight.dx, max(bottomRight.dx, bottomLeft.dx)));
    final newBottom = max(topLeft.dy, max(topRight.dy, max(bottomRight.dy, bottomLeft.dy)));

    rect = Rect.fromLTRB(newLeft, newTop, newRight, newBottom);
    super.rotateAround(angleRadians, center);
  }

  @override
  void scaleAround(double scaleX, double scaleY, Offset pivot) {
    if (scaleX == 0 || scaleY == 0) return;
    Offset scalePoint(Offset p) => Offset(
      pivot.dx + (p.dx - pivot.dx) * scaleX,
      pivot.dy + (p.dy - pivot.dy) * scaleY,
    );

    final p1 = scalePoint(rect.topLeft);
    final p2 = scalePoint(rect.bottomRight);
    rect = Rect.fromPoints(p1, p2);
    super.scaleAround(scaleX, scaleY, pivot);
  }

  @override
  TapeStroke copy() => TapeStroke(
    color: color,
    pressureEnabled: pressureEnabled,
    options: options.copyWith(),
    pageIndex: pageIndex,
    page: page,
    toolId: toolId,
    rect: rect,
    isConcealed: isConcealed,
    pattern: pattern,
    fillColor: fillColor,
    lineStyle: lineStyle,
  );
}
