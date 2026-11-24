/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';

/// An Icon widget that wraps an [IconData] (accepting [Object] for backwards
/// compatibility with callers that pass typed or untyped icon objects).
class UniIcon extends Icon {
  const UniIcon(
    this.uniIcon, {
    super.key,
    super.size,
    super.color,
    super.semanticLabel,
  }) : super(null);

  final Object uniIcon;

  @override
  Widget build(BuildContext context) {
    final uniIcon = this.uniIcon;
    if (uniIcon is IconData) {
      return Icon(
        uniIcon,
        key: ValueKey(uniIcon),
        size: size,
        color: color,
        semanticLabel: semanticLabel,
      );
    }
    throw ArgumentError.value(
      uniIcon,
      'uniIcon',
      'uniIcon must be an IconData',
    );
  }

  @override
  @Deprecated('Use uniIcon directly')
  IconData get icon {
    if (uniIcon is IconData) return uniIcon as IconData;
    throw ArgumentError.value(
      uniIcon,
      'uniIcon',
      'uniIcon must be an IconData',
    );
  }
}
