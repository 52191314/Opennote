/// 🤖 Modified with Google Antigravity
library;

import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart';

extension Matrix4Extensions on Matrix4 {
  /// A fast approximation of the matrix's scale factor.
  /// This makes the assumptions that the matrix has a uniform scale
  /// and no rotation or skewing.
  double get approxScale => entry(0, 0);

  /// Returns the maximum 2D X/Y basis vector scale, ignoring the Z axis so an
  /// unscaled Z component (`m[10] == 1.0`) never skews 2D zoom clamping.
  double get maxScale2D {
    final s = storage;
    if (s[1] == 0.0 && s[4] == 0.0) {
      return math.max(s[0].abs(), s[5].abs());
    }
    return math.sqrt(
      math.max(s[0] * s[0] + s[1] * s[1], s[4] * s[4] + s[5] * s[5]),
    );
  }
}
