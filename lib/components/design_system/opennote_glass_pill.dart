/// 🤖 Generated wholely or partially with Google Antigravity
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
    this.enableBlur = true,
    this.blurSigma = 12.0,
    this.borderAlpha = 0.28,
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

  /// Whether to apply a `BackdropFilter` blur behind the pill.
  final bool enableBlur;

  /// Gaussian blur sigma when [enableBlur] is true.
  final double blurSigma;

  /// Opacity multiplier for the `1px` `outlineVariant` border.
  final double borderAlpha;

  /// Whether to render the ambient floating shadow.
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;
    final resolvedRadius =
        borderRadius ?? BorderRadius.circular(OpennoteTokens.radiusPill);
    final resolvedBg =
        backgroundColor ??
        (isDark
                ? OpennoteTokens.cardDarkSurface
                : OpennoteTokens.cardLightSurface)
            .withValues(alpha: enableBlur ? (isDark ? 0.82 : 0.88) : 1.0);

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
              border: Border.fromBorderSide(
                OpennoteTokens.subtleBorder(colorScheme, borderAlpha),
              ),
            ),
            child: Material(type: MaterialType.transparency, child: content),
          ),
        ),
      ),
    );
  }
}
