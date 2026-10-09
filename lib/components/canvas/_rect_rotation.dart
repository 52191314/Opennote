/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:math';
import 'dart:ui';

/// Rotates an axis-aligned rect in small steps without it growing.
///
/// Rectangle and tape strokes store only an upright [Rect], so a rotated one
/// is drawn as its bounding box. Taking the bounding box of the previous
/// bounding box on every step of a drag makes the rect balloon. This remembers
/// the size the rect had before the drag and how far it has turned since, and
/// always works the bounding box out from those.
class RectRotation {
  Size _unrotatedSize = Size.zero;
  double _angle = 0;
  Rect? _lastResult;

  /// Returns [rect] turned by [angleRadians] around [center].
  ///
  /// Pass the rect returned by the previous call to continue the same
  /// rotation. Any other rect starts a new rotation from its own size.
  Rect rotate(Rect rect, double angleRadians, Offset center) {
    if (rect != _lastResult) {
      _unrotatedSize = rect.size;
      _angle = 0;
    }
    _angle += angleRadians;

    final cosTotal = cos(_angle).abs();
    final sinTotal = sin(_angle).abs();
    return _lastResult = Rect.fromCenter(
      center: _turned(rect.center, angleRadians, center),
      width: _unrotatedSize.width * cosTotal + _unrotatedSize.height * sinTotal,
      height:
          _unrotatedSize.width * sinTotal + _unrotatedSize.height * cosTotal,
    );
  }

  static Offset _turned(Offset point, double angleRadians, Offset center) {
    final cosA = cos(angleRadians);
    final sinA = sin(angleRadians);
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    return Offset(
      center.dx + dx * cosA - dy * sinA,
      center.dy + dx * sinA + dy * cosA,
    );
  }
}
