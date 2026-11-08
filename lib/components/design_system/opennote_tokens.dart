/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';

/// Design tokens for the Opennote Tactile Studio aesthetic.
abstract final class OpennoteTokens {
  /// Primary brand seed color (Ink Indigo).
  static const brandSeed = Color(0xFF3B5BDB);

  /// Warm Alabaster Paper surface for light studio mode.
  static const studioLightSurface = Color(0xFFF6F5F1);

  /// Deep Obsidian Studio surface for dark studio mode.
  static const studioDarkSurface = Color(0xFF121316);

  /// Crisp white surface for cards in light studio mode.
  static const cardLightSurface = Color(0xFFFFFFFF);

  /// Elevated charcoal surface for cards in dark studio mode.
  static const cardDarkSurface = Color(0xFF1B1C20);

  /// Extra-small corner radius (6px).
  static const radiusXs = 6.0;

  /// Small corner radius (10px).
  static const radiusSm = 10.0;

  /// Medium corner radius (14px).
  static const radiusMd = 14.0;

  /// Large corner radius (20px).
  static const radiusLg = 20.0;

  /// Full pill corner radius (999px).
  static const radiusPill = 999.0;

  /// 4px spacing unit.
  static const s1 = 4.0;

  /// 8px spacing unit.
  static const s2 = 8.0;

  /// 12px spacing unit.
  static const s3 = 12.0;

  /// 16px spacing unit.
  static const s4 = 16.0;

  /// 20px spacing unit.
  static const s5 = 20.0;

  /// 24px spacing unit.
  static const s6 = 24.0;

  /// 32px spacing unit.
  static const s8 = 32.0;

  /// Returns a crisp 1px border side using [scheme.outlineVariant].
  static BorderSide subtleBorder(ColorScheme scheme, [double alpha = 0.22]) {
    return BorderSide(
      color: scheme.outlineVariant.withValues(alpha: alpha),
      width: 1,
    );
  }

  /// Soft ambient shadow for floating toolbars, pills, and HUD panels.
  static List<BoxShadow> floatingShadow(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.36 : 0.08),
        blurRadius: isDark ? 20 : 16,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
        blurRadius: 4,
        spreadRadius: 0,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Subtle elevation shadow for notebook cards and surface tiles.
  static List<BoxShadow> cardShadow(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
        blurRadius: isDark ? 12 : 10,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ];
  }
}
