/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';

/// Visual hierarchy variants for [OpennoteCtaButton].
enum OpennoteCtaVariant {
  /// High-emphasis primary action using the Precision Indigo/Cobalt accent.
  primary,

  /// Clean bordered studio surface action for secondary flows.
  secondary,

  /// High-craft Warm Amber/Gold action reserved exclusively for Opennote Pro.
  pro,

  /// Low-emphasis borderless action with subtle hover tint.
  ghost,
}

/// Size tiers for [OpennoteCtaButton].
enum OpennoteCtaSize {
  /// Compact button height (36px) for toolbars, banners, and dense cards.
  compact,

  /// Standard studio button height (44px) for forms and sheets.
  medium,

  /// Prominent hero button height (50px) for onboarding and paywall CTAs.
  large,
}

/// A tactile studio call-to-action button supporting primary, secondary,
/// Opennote Pro, and ghost variants with built-in loading state.
class OpennoteCtaButton extends StatefulWidget {
  /// Creates an [OpennoteCtaButton].
  const OpennoteCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = OpennoteCtaVariant.primary,
    this.size = OpennoteCtaSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = false,
    this.tooltip,
  });

  /// Button label text.
  final String label;

  /// Callback invoked on tap. Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// Visual style variant. Defaults to [OpennoteCtaVariant.primary].
  final OpennoteCtaVariant variant;

  /// Button height and padding tier. Defaults to [OpennoteCtaSize.medium].
  final OpennoteCtaSize size;

  /// Optional leading icon displayed before [label].
  final IconData? icon;

  /// Optional trailing icon displayed after [label].
  final IconData? trailingIcon;

  /// Displays a loading indicator and blocks interactions when `true`.
  final bool isLoading;

  /// Whether the button expands horizontally to fill available width.
  final bool expand;

  /// Optional tooltip displayed on hover or long press.
  final String? tooltip;

  @override
  State<OpennoteCtaButton> createState() => _OpennoteCtaButtonState();
}

class _OpennoteCtaButtonState extends State<OpennoteCtaButton> {
  var _pressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  double get _minHeight => switch (widget.size) {
    OpennoteCtaSize.compact => 36,
    OpennoteCtaSize.medium => 44,
    OpennoteCtaSize.large => 50,
  };

  double get _iconSize => switch (widget.size) {
    OpennoteCtaSize.compact => 16,
    OpennoteCtaSize.medium => 18,
    OpennoteCtaSize.large => 20,
  };

  EdgeInsets get _padding => switch (widget.size) {
    OpennoteCtaSize.compact => const EdgeInsets.symmetric(
      horizontal: OpennoteTokens.s3,
    ),
    OpennoteCtaSize.medium => const EdgeInsets.symmetric(
      horizontal: OpennoteTokens.s4,
    ),
    OpennoteCtaSize.large => const EdgeInsets.symmetric(
      horizontal: OpennoteTokens.s6,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final brightness = colorScheme.brightness;
    final textTheme = TextTheme.of(context);

    final (bgColor, fgColor, borderSide) = _resolveColors(
      colorScheme,
      brightness,
    );

    final effectiveBg = _isEnabled ? bgColor : bgColor.withValues(alpha: 0.48);
    final effectiveFg = _isEnabled ? fgColor : fgColor.withValues(alpha: 0.52);

    final radius = widget.size == OpennoteCtaSize.large
        ? OpennoteTokens.borderRadiusMd
        : OpennoteTokens.borderRadiusSm;

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: OpennoteTokens.s2,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        else if (widget.icon != null)
          Icon(widget.icon, size: _iconSize, color: effectiveFg),
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(
              fontSize: switch (widget.size) {
                OpennoteCtaSize.compact => 13,
                OpennoteCtaSize.medium => 14,
                OpennoteCtaSize.large => 15,
              },
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
              color: effectiveFg,
            ),
          ),
        ),
        if (!widget.isLoading && widget.trailingIcon != null)
          Icon(widget.trailingIcon, size: _iconSize, color: effectiveFg),
      ],
    );

    Widget button = Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.label,
      child: AnimatedScale(
        scale: _pressed && _isEnabled ? 0.98 : 1.0,
        duration: OpennoteTokens.durationInstant,
        curve: OpennoteTokens.curveStandard,
        child: AnimatedContainer(
          duration: OpennoteTokens.durationFast,
          curve: OpennoteTokens.curveStandard,
          constraints: BoxConstraints(
            minHeight: _minHeight,
            minWidth: widget.expand ? double.infinity : 0,
          ),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: radius,
            border: borderSide != null
                ? Border.fromBorderSide(borderSide)
                : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: radius,
              onTap: _isEnabled ? widget.onPressed : null,
              onHighlightChanged: (pressed) {
                if (_isEnabled || !pressed) {
                  setState(() => _pressed = pressed);
                }
              },
              hoverColor: fgColor.withValues(alpha: 0.08),
              splashColor: fgColor.withValues(alpha: 0.12),
              child: Padding(padding: _padding, child: content),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }

  (Color, Color, BorderSide?) _resolveColors(
    ColorScheme scheme,
    Brightness brightness,
  ) {
    return switch (widget.variant) {
      OpennoteCtaVariant.primary => (scheme.primary, scheme.onPrimary, null),
      OpennoteCtaVariant.secondary => (
        OpennoteTokens.cardSurface(brightness),
        scheme.onSurface,
        OpennoteTokens.hairlineBorder(scheme),
      ),
      OpennoteCtaVariant.pro => (
        OpennoteTokens.proAccentFor(brightness),
        OpennoteTokens.onProAccentFor(brightness),
        BorderSide(
          color: OpennoteTokens.proAccentFor(
            brightness,
          ).withValues(alpha: 0.28),
          width: OpennoteTokens.hairlineWidth,
        ),
      ),
      OpennoteCtaVariant.ghost => (Colors.transparent, scheme.primary, null),
    };
  }
}
