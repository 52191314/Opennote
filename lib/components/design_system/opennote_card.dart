/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';

/// A clean bordered studio card with smooth hover and press elevation.
///
/// Uses a `1px` neutral hairline border and pure/elevated surface tier from
/// [OpennoteTokens]. When [onTap] or [onLongPress] is provided, hovering or
/// pressing animates the elevation and border subtly for tactile feedback.
class OpennoteCard extends StatefulWidget {
  /// Creates an [OpennoteCard].
  const OpennoteCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(OpennoteTokens.s4),
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.selected = false,
    this.elevated = true,
    this.clipBehavior = Clip.antiAlias,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
  });

  /// Content displayed inside the card.
  final Widget child;

  /// Inner padding around [child]. Defaults to `16px` (`OpennoteTokens.s4`).
  final EdgeInsetsGeometry? padding;

  /// Optional outer margin around the card.
  final EdgeInsetsGeometry? margin;

  /// Corner radius of the card. Defaults to [OpennoteTokens.borderRadiusMd].
  final BorderRadius? borderRadius;

  /// Optional override for the card surface color.
  final Color? backgroundColor;

  /// Optional override for the `1px` hairline border color.
  final Color? borderColor;

  /// Highlights the card with the primary accent border and subtle tint.
  final bool selected;

  /// Whether to render the subtle studio card shadow.
  final bool elevated;

  /// Clipping behavior for card contents.
  final Clip clipBehavior;

  /// Optional tap callback; enables interactive hover/press feedback.
  final VoidCallback? onTap;

  /// Optional long-press callback.
  final VoidCallback? onLongPress;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  @override
  State<OpennoteCard> createState() => _OpennoteCardState();
}

class _OpennoteCardState extends State<OpennoteCard> {
  var _hovered = false;
  var _pressed = false;

  bool get _isInteractive => widget.onTap != null || widget.onLongPress != null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final brightness = colorScheme.brightness;
    final resolvedRadius = widget.borderRadius ?? OpennoteTokens.borderRadiusMd;

    final baseBg =
        widget.backgroundColor ?? OpennoteTokens.cardSurface(brightness);
    final resolvedBg = widget.selected
        ? Color.alphaBlend(colorScheme.primary.withValues(alpha: 0.05), baseBg)
        : baseBg;

    final BorderSide resolvedBorder;
    if (widget.selected) {
      resolvedBorder = OpennoteTokens.focusBorder(colorScheme);
    } else if (widget.borderColor != null) {
      resolvedBorder = BorderSide(
        color: widget.borderColor!,
        width: OpennoteTokens.hairlineWidth,
      );
    } else {
      resolvedBorder = OpennoteTokens.hairlineBorder(
        colorScheme,
        alpha: _hovered ? 1.0 : 0.85,
      );
    }

    final List<BoxShadow>? shadows;
    if (!widget.elevated) {
      shadows = null;
    } else if (_hovered && !_pressed && _isInteractive) {
      shadows = OpennoteTokens.hoverCardShadow(brightness);
    } else {
      shadows = OpennoteTokens.cardShadow(brightness);
    }

    Widget content = widget.child;
    if (widget.padding != null) {
      content = Padding(padding: widget.padding!, child: content);
    }

    if (_isInteractive) {
      content = InkWell(
        borderRadius: resolvedRadius,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onHover: (hovered) => setState(() => _hovered = hovered),
        onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
        hoverColor: colorScheme.onSurface.withValues(alpha: 0.025),
        splashColor: colorScheme.primary.withValues(alpha: 0.06),
        child: content,
      );
    }

    Widget card = AnimatedScale(
      scale: _pressed && _isInteractive ? 0.992 : 1.0,
      duration: OpennoteTokens.durationInstant,
      curve: OpennoteTokens.curveStandard,
      child: AnimatedContainer(
        duration: OpennoteTokens.durationFast,
        curve: OpennoteTokens.curveStandard,
        decoration: BoxDecoration(
          color: resolvedBg,
          borderRadius: resolvedRadius,
          border: Border.fromBorderSide(resolvedBorder),
          boxShadow: shadows,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: resolvedRadius,
          clipBehavior: widget.clipBehavior,
          child: content,
        ),
      ),
    );

    if (widget.margin != null) {
      card = Padding(padding: widget.margin!, child: card);
    }

    if (widget.semanticLabel != null) {
      card = Semantics(
        label: widget.semanticLabel,
        selected: widget.selected,
        button: _isInteractive,
        child: card,
      );
    }

    return card;
  }
}
