/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';

/// A translucent frosted-glass pill container used for Opennote Studio
/// floating toolbars, HUD badges, and action bars.
class OpennoteGlassPill extends StatelessWidget {
  /// Creates an [OpennoteGlassPill].
  const OpennoteGlassPill({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.enableBlur = true,
    this.blurSigma = 14.0,
    this.borderAlpha = 0.72,
    this.showShadow = true,
  });

  /// The widget displayed inside the glass pill.
  final Widget child;

  /// Optional inner padding around [child].
  final EdgeInsetsGeometry? padding;

  /// Corner radius of the pill. Defaults to a full stadium pill (`radiusPill`).
  final BorderRadius? borderRadius;

  /// Optional custom background color before translucency is applied.
  final Color? backgroundColor;

  /// Optional override color for the crisp `1px` hairline border.
  final Color? borderColor;

  /// Whether to apply a `BackdropFilter` blur behind the pill.
  final bool enableBlur;

  /// Gaussian blur sigma when [enableBlur] is true.
  final double blurSigma;

  /// Opacity multiplier for the `1px` hairline border.
  final double borderAlpha;

  /// Whether to render the ambient floating shadow.
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;
    final resolvedRadius = borderRadius ?? OpennoteTokens.borderRadiusPill;
    final baseSurface = isDark
        ? OpennoteTokens.elevatedDarkSurface
        : OpennoteTokens.cardLightSurface;
    final resolvedBg =
        backgroundColor ??
        baseSurface.withValues(alpha: enableBlur ? (isDark ? 0.84 : 0.90) : 1);
    final resolvedBorderSide = borderColor != null
        ? BorderSide(
            color: borderColor!.withValues(alpha: borderAlpha),
            width: OpennoteTokens.hairlineWidth,
          )
        : OpennoteTokens.hairlineBorder(
            colorScheme,
            alpha: borderAlpha.clamp(0.0, 1.0),
          );

    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: resolvedRadius,
        boxShadow: showShadow
            ? OpennoteTokens.floatingShadow(colorScheme.brightness)
            : null,
      ),
      child: ClipRRect(
        borderRadius: resolvedRadius,
        child: BackdropFilter(
          enabled: enableBlur,
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: resolvedBg,
              borderRadius: resolvedRadius,
              border: Border.fromBorderSide(resolvedBorderSide),
            ),
            child: Material(type: MaterialType.transparency, child: content),
          ),
        ),
      ),
    );
  }
}
