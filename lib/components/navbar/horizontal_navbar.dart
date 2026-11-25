/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/navbar/responsive_navbar.dart';
import 'package:saber/components/theming/saber_theme.dart';

/// Floating frosted bottom navigation bar used on compact/mobile viewports.
class HorizontalNavbar extends StatelessWidget {
  const HorizontalNavbar({
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
  });

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  /// The height that should be cleared at the bottom of the screen,
  /// excluding padding/safe area, to avoid overlapping the navbar.
  static double clearanceHeightOf(BuildContext context) {
    if (ResponsiveNavbar.isLargeScreen) return 0;
    final platform = Theme.of(context).platform;
    MediaQuery.sizeOf(context); // ensure context is listening to size changes
    return _heightForPlatform(platform) + 16 + 16 - 8;
  }

  static double _heightForPlatform(TargetPlatform platform) {
    return platform.isCupertino ? 58.0 : 62.0;
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GlassyContainer(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Semantics(
                role: SemanticsRole.tabBar,
                explicitChildNodes: true,
                container: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: platform.isCupertino ? 2 : 4,
                  children: [
                    for (int i = 0; i < destinations.length; i++)
                      MergeSemantics(
                        child: Semantics(
                          role: SemanticsRole.tab,
                          selected: i == selectedIndex,
                          child: _ToolbarButton(
                            destination: destinations[i],
                            selected: i == selectedIndex,
                            select: () => onDestinationSelected?.call(i),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating frosted capsule container used by [HorizontalNavbar] and the
/// floating new-note action button.
class GlassyContainer extends StatelessWidget {
  const GlassyContainer({
    super.key,
    required this.child,
    this.height,
    this.borderRadius,
  });

  final Widget child;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;
    final height = this.height ?? HorizontalNavbar._heightForPlatform(platform);
    final borderRadius = this.borderRadius ?? BorderRadius.circular(height / 2);

    final background =
        (isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface)
            .withValues(alpha: platform.isCupertino ? 0.78 : 0.90);

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: borderRadius,
          boxShadow: OpennoteTokens.floatingShadow(colorScheme.brightness),
        ),
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: platform.isCupertino ? 14 : 10,
              sigmaY: platform.isCupertino ? 14 : 10,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: (platform.isCupertino && isDark)
                    ? _GlintBorder(width: 1)
                    : Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: isDark ? 0.35 : 0.45,
                        ),
                        width: 1,
                      ),
                borderRadius: borderRadius,
              ),
              child: Material(
                type: MaterialType.transparency,
                color: Colors.transparent,
                borderRadius: borderRadius,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.destination,
    required this.selected,
    this.select,
  });

  final NavigationDestination destination;
  final bool selected;
  final VoidCallback? select;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final platform = Theme.of(context).platform;
    final isDark = colorScheme.brightness == Brightness.dark;
    const borderRadius = BorderRadius.all(Radius.circular(28));

    final selectedBgColor = colorScheme.primary.withValues(
      alpha: isDark ? 0.24 : 0.13,
    );
    final fgColor = selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return AspectRatio(
      aspectRatio: platform.isCupertino ? 1.48 : 1.42,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? selectedBgColor : Colors.transparent,
          borderRadius: borderRadius,
        ),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: select,
          hoverColor: colorScheme.primary.withValues(alpha: 0.08),
          focusColor: colorScheme.primary.withValues(alpha: 0.12),
          splashColor: platform.isCupertino
              ? CupertinoColors.systemBlue.withValues(alpha: 0.25)
              : colorScheme.primary.withValues(alpha: 0.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 7,
                child: IconTheme.merge(
                  data: IconThemeData(color: fgColor, size: 21),
                  child: destination.icon,
                ),
              ),
              const SizedBox(height: 1),
              Flexible(
                flex: 3,
                child: Text(
                  destination.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    height: 1,
                    overflow: TextOverflow.clip,
                    color: fgColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A border that lights up the top-left and bottom-right corners.
class _GlintBorder extends Border {
  _GlintBorder({double width = 1})
    : super.fromBorderSide(
        BorderSide(color: const Color(0x33FFFFFF), width: width),
      );

  static const gradient = LinearGradient(
    colors: [
      Color(0x77FFFFFF),
      Color(0x33FFFFFF),
      Color(0x00FFFFFF),
      Color(0x33FFFFFF),
      Color(0x77FFFFFF),
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
    begin: Alignment(-0.5, -1.5),
    end: Alignment(0.5, 1.5),
  );

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = .rectangle,
    BorderRadius? borderRadius,
  }) {
    borderRadius ??= .zero;
    assert(top.style != .none);
    final paint = Paint()
      ..color = Colors.white
      ..shader = gradient.createShader(rect);
    if (top.width == 0.0) {
      paint
        ..style = .stroke
        ..strokeWidth = 0.0;
      canvas.drawRRect(borderRadius.toRRect(rect), paint);
    } else {
      final borderRect = borderRadius.toRRect(rect);
      final inner = borderRect.deflate(top.strokeInset);
      final outer = borderRect.inflate(top.strokeOutset);
      canvas.drawDRRect(outer, inner, paint);
    }
  }

  @override
  bool get isUniform => true;

  @override
  Border scale(double t) => _GlintBorder(width: top.width * t);
}
