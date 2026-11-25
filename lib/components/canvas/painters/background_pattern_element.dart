/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';

/// A single geometric primitive (line segment or dot) in a canvas background pattern.
class PatternElement {
  final Offset start;
  final Offset end;

  /// Whether this element is a line segment (`true`) or a dot (`false`).
  final bool isLine;

  /// Whether this element should use the secondary accent color.
  final bool secondaryColor;

  /// Optional explicit stroke thickness. If null, the default line thickness is used.
  final double? thickness;

  const PatternElement(
    this.start,
    this.end, {
    this.isLine = true,
    this.secondaryColor = false,
    this.thickness,
  });
}
