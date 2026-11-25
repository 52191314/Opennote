/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';

/// Design tokens for the Opennote Tactile Studio aesthetic.
///
/// Defines a disciplined neutral surface hierarchy (warm crisp paper in light
/// mode, deep graphite in dark mode), a single primary brand accent (Precision
/// Indigo/Cobalt), and a dedicated Warm Amber/Gold Pro accent.
abstract final class OpennoteTokens {
  // ---------------------------------------------------------------------------
  // Brand & Disciplined Accent Palette
  // ---------------------------------------------------------------------------

  /// Primary brand seed color (Precision Indigo/Cobalt).
  static const brandSeed = Color(0xFF3B5BDB);

  /// Primary interactive accent for light studio surfaces.
  static const primaryAccent = Color(0xFF3B5BDB);

  /// Elevated luminous cobalt accent for dark studio surfaces.
  static const primaryAccentDark = Color(0xFF748FFC);

  /// Warm Amber/Gold Pro accent for light surfaces (high legibility).
  static const proAccent = Color(0xFFD97706);

  /// Luminous Warm Gold Pro accent for dark surfaces.
  static const proAccentDark = Color(0xFFF59E0B);

  /// Soft warm amber container tint for Pro badges in light mode.
  static const proContainerLight = Color(0xFFFEF3C7);

  /// Deep warm amber container tint for Pro badges in dark mode.
  static const proContainerDark = Color(0xFF36250B);

  /// Foreground color rendered on top of [proAccent] in light mode.
  static const onProAccentLight = Color(0xFFFFFFFF);

  /// Foreground color rendered on top of [proAccentDark] in dark mode.
  static const onProAccentDark = Color(0xFF1A1205);

  /// Semantic success accent (light mode).
  static const successLight = Color(0xFF15803D);

  /// Semantic success accent (dark mode).
  static const successDark = Color(0xFF4ADE80);

  /// Semantic danger/destructive accent (light mode).
  static const dangerLight = Color(0xFFDC2626);

  /// Semantic danger/destructive accent (dark mode).
  static const dangerDark = Color(0xFFF87171);

  // ---------------------------------------------------------------------------
  // Studio Surface Tiers (Light: Warm Crisp Paper, Dark: Deep Graphite)
  // ---------------------------------------------------------------------------

  /// Warm crisp paper canvas surface for light studio mode (`#FAF9F6`).
  static const studioLightSurface = Color(0xFFFAF9F6);

  /// Deep graphite studio canvas surface for dark studio mode (`#0F1115`).
  static const studioDarkSurface = Color(0xFF0F1115);

  /// Pure white surface for cards and sheets in light studio mode (`#FFFFFF`).
  static const cardLightSurface = Color(0xFFFFFFFF);

  /// Elevated graphite surface for cards and sheets in dark studio mode (`#181B22`).
  static const cardDarkSurface = Color(0xFF181B22);

  /// Highest elevated surface for popovers, menus, and active thumbs (light).
  static const elevatedLightSurface = Color(0xFFFFFFFF);

  /// Highest elevated surface for popovers, menus, and active thumbs (dark).
  static const elevatedDarkSurface = Color(0xFF21252F);

  /// Subtle recessed surface for input wells and segmented tracks (light).
  static const subtleLightSurface = Color(0xFFF2F0EA);

  /// Subtle recessed surface for input wells and segmented tracks (dark).
  static const subtleDarkSurface = Color(0xFF14171D);

  /// Hover tint surface for interactive cards and rows (light).
  static const hoverLightSurface = Color(0xFFECEAE3);

  /// Hover tint surface for interactive cards and rows (dark).
  static const hoverDarkSurface = Color(0xFF262B36);

  // ---------------------------------------------------------------------------
  // Hairline Borders
  // ---------------------------------------------------------------------------

  /// Standard crisp hairline border width (`1.0px`).
  static const hairlineWidth = 1.0;

  /// Neutral warm hairline border color for light mode.
  static const hairlineLight = Color(0xFFE5E2DA);

  /// Neutral cool-graphite hairline border color for dark mode.
  static const hairlineDark = Color(0xFF282D38);

  // ---------------------------------------------------------------------------
  // Corner Radius Scale
  // ---------------------------------------------------------------------------

  /// Extra-small corner radius (6px).
  static const radiusXs = 6.0;

  /// Small corner radius (10px).
  static const radiusSm = 10.0;

  /// Medium corner radius (14px).
  static const radiusMd = 14.0;

  /// Large corner radius (20px).
  static const radiusLg = 20.0;

  /// Extra-large corner radius (28px).
  static const radiusXl = 28.0;

  /// Full pill corner radius (999px).
  static const radiusPill = 999.0;

  /// Reusable [BorderRadius] for [radiusXs].
  static const borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));

  /// Reusable [BorderRadius] for [radiusSm].
  static const borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));

  /// Reusable [BorderRadius] for [radiusMd].
  static const borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));

  /// Reusable [BorderRadius] for [radiusLg].
  static const borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));

  /// Reusable [BorderRadius] for [radiusXl].
  static const borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));

  /// Reusable [BorderRadius] for [radiusPill].
  static const borderRadiusPill = BorderRadius.all(Radius.circular(radiusPill));

  // ---------------------------------------------------------------------------
  // Spacing Scale (4px base grid)
  // ---------------------------------------------------------------------------

  /// 0px spacing unit.
  static const s0 = 0.0;

  /// 2px micro spacing unit.
  static const s0_5 = 2.0;

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

  /// 28px spacing unit.
  static const s7 = 28.0;

  /// 32px spacing unit.
  static const s8 = 32.0;

  /// 40px spacing unit.
  static const s10 = 40.0;

  /// 48px spacing unit.
  static const s12 = 48.0;

  /// 64px spacing unit.
  static const s16 = 64.0;

  // ---------------------------------------------------------------------------
  // Motion Durations & Curves
  // ---------------------------------------------------------------------------

  /// Instant tactile micro-feedback (90ms).
  static const durationInstant = Duration(milliseconds: 90);

  /// Fast state transitions such as hover, selection, and tabs (150ms).
  static const durationFast = Duration(milliseconds: 150);

  /// Standard layout and surface transitions (220ms).
  static const durationMedium = Duration(milliseconds: 220);

  /// Deliberate modal, sheet, and page emphasis transitions (320ms).
  static const durationSlow = Duration(milliseconds: 320);

  /// Crisp decelerating studio curve for everyday UI motion.
  static const Curve curveStandard = Curves.easeOutCubic;

  /// Expressive ease-in-out curve for prominent state changes.
  static const Curve curveEmphasized = Curves.easeInOutCubicEmphasized;

  /// Subtle spring-like overshoot for tactile confirmation moments.
  static const Curve curveSpring = Curves.easeOutBack;

  // ---------------------------------------------------------------------------
  // Responsive Breakpoints & Layout Constraints
  // ---------------------------------------------------------------------------

  /// Compact phone breakpoint upper bound (`600px`).
  static const breakpointCompact = 600.0;

  /// Medium tablet breakpoint upper bound (`840px`).
  static const breakpointMedium = 840.0;

  /// Expanded desktop studio breakpoint (`1200px`).
  static const breakpointExpanded = 1200.0;

  /// Recommended max content width for centered studio layouts.
  static const maxContentWidth = 1120.0;

  /// Recommended max width for modal sheets and dialogs.
  static const maxSheetWidth = 560.0;

  /// Returns `true` when [width] falls in the compact (phone) layout tier.
  static bool isCompactWidth(double width) => width < breakpointCompact;

  /// Returns `true` when [width] falls in the medium (tablet) layout tier.
  static bool isMediumWidth(double width) =>
      width >= breakpointCompact && width < breakpointMedium;

  /// Returns `true` when [width] falls in the expanded (desktop) layout tier.
  static bool isExpandedWidth(double width) => width >= breakpointMedium;

  // ---------------------------------------------------------------------------
  // Brightness-Aware Token Resolvers
  // ---------------------------------------------------------------------------

  /// Returns the studio canvas background color for [brightness].
  static Color studioSurface(Brightness brightness) =>
      brightness == Brightness.dark ? studioDarkSurface : studioLightSurface;

  /// Returns the primary card surface color for [brightness].
  static Color cardSurface(Brightness brightness) =>
      brightness == Brightness.dark ? cardDarkSurface : cardLightSurface;

  /// Returns the elevated popover/thumb surface color for [brightness].
  static Color elevatedSurface(Brightness brightness) =>
      brightness == Brightness.dark
      ? elevatedDarkSurface
      : elevatedLightSurface;

  /// Returns the subtle recessed fill color for [brightness].
  static Color subtleSurface(Brightness brightness) =>
      brightness == Brightness.dark ? subtleDarkSurface : subtleLightSurface;

  /// Returns the hover surface tint for [brightness].
  static Color hoverSurface(Brightness brightness) =>
      brightness == Brightness.dark ? hoverDarkSurface : hoverLightSurface;

  /// Returns the Pro accent color tuned for [brightness].
  static Color proAccentFor(Brightness brightness) =>
      brightness == Brightness.dark ? proAccentDark : proAccent;

  /// Returns the Pro container tint tuned for [brightness].
  static Color proContainerFor(Brightness brightness) =>
      brightness == Brightness.dark ? proContainerDark : proContainerLight;

  /// Returns the foreground color for text/icons on a Pro accent fill.
  static Color onProAccentFor(Brightness brightness) =>
      brightness == Brightness.dark ? onProAccentDark : onProAccentLight;

  /// Returns a crisp neutral hairline color harmonized with [scheme].
  static Color hairlineColor(ColorScheme scheme) {
    final base = scheme.brightness == Brightness.dark
        ? hairlineDark
        : hairlineLight;
    return Color.lerp(base, scheme.outlineVariant, 0.25)!;
  }

  /// Returns a crisp `1px` hairline [BorderSide] harmonized with [scheme].
  static BorderSide hairlineBorder(ColorScheme scheme, {double alpha = 1.0}) {
    return BorderSide(
      color: hairlineColor(scheme).withValues(alpha: alpha),
      width: hairlineWidth,
    );
  }

  /// Returns a focused/selected accent [BorderSide] using [scheme.primary].
  static BorderSide focusBorder(ColorScheme scheme, {double width = 1.5}) {
    return BorderSide(color: scheme.primary, width: width);
  }

  /// Returns a crisp `1px` border side using [scheme.outlineVariant].
  static BorderSide subtleBorder(ColorScheme scheme, [double alpha = 0.22]) {
    return BorderSide(
      color: scheme.outlineVariant.withValues(alpha: alpha),
      width: hairlineWidth,
    );
  }

  // ---------------------------------------------------------------------------
  // Elevation Shadows
  // ---------------------------------------------------------------------------

  /// Soft ambient shadow for floating toolbars, pills, and HUD panels.
  static List<BoxShadow> floatingShadow(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.42 : 0.08),
        blurRadius: isDark ? 24 : 18,
        spreadRadius: 0,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.04),
        blurRadius: 4,
        spreadRadius: 0,
        offset: const Offset(0, 1),
      ),
    ];
  }

  /// Subtle resting elevation shadow for notebook cards and surface tiles.
  static List<BoxShadow> cardShadow(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.045),
        blurRadius: isDark ? 12 : 10,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Elevated hover/active shadow for interactive studio cards.
  static List<BoxShadow> hoverCardShadow(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.09),
        blurRadius: isDark ? 20 : 16,
        spreadRadius: 0,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
        blurRadius: 4,
        spreadRadius: 0,
        offset: const Offset(0, 1),
      ),
    ];
  }
}
