/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/data/prefs.dart';
import 'package:sbn/font_fallbacks.dart';

abstract class SaberTheme {
  static ThemeData createTheme(
    ColorScheme colorScheme,
    TargetPlatform platform,
  ) {
    colorScheme = _adjustColorScheme(colorScheme, platform);
    final isDark = colorScheme.brightness == .dark;
    final scaffoldBg = Color.lerp(
      colorScheme.surface,
      isDark
          ? OpennoteTokens.studioDarkSurface
          : OpennoteTokens.studioLightSurface,
      0.45,
    )!;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: _Components.textTheme(platform, colorScheme),
      platform: platform,
      progressIndicatorTheme: _Components.progressIndicatorTheme,
      cardColor: colorScheme.surface,
      cardTheme: _Components.cardTheme(colorScheme),
      dialogTheme: _Components.dialogTheme(colorScheme),
      bottomSheetTheme: _Components.bottomSheetTheme(colorScheme),
      navigationRailTheme: _Components.navigationRailTheme(colorScheme),
      cupertinoOverrideTheme: _Components.cupertinoOverrideTheme,
      appBarTheme: _Components.appBarTheme,
    );
  }

  static ThemeData createThemeFromSeed(
    Color seedColor,
    Brightness brightness,
    TargetPlatform platform, {
    @Deprecated(
      'High contrast is not implemented here. '
      'Use ColorScheme.withHighContrast() instead',
    )
    bool highContrast = false,
  }) {
    final colorScheme = platform.isCupertino
        ? _cupertinoColorScheme(seedColor, brightness)
        : ColorScheme.fromSeed(brightness: brightness, seedColor: seedColor);
    return createTheme(colorScheme, platform);
  }

  /// Creates a clean, native-feeling iOS [ColorScheme] seeded from [seedColor].
  static ColorScheme _cupertinoColorScheme(
    Color seedColor,
    Brightness brightness,
  ) {
    final base = ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: seedColor,
    );
    return _applyCupertinoSurfaces(base);
  }

  /// Applies iOS Human Interface Guidelines grouped surface hierarchy colors.
  static ColorScheme _applyCupertinoSurfaces(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == .dark;
    return colorScheme.copyWith(
      surface: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      surfaceContainerLowest: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFFFFFFF),
      surfaceContainerLow: isDark
          ? const Color(0xFF1C1C1E)
          : const Color(0xFFFFFFFF),
      surfaceContainer: isDark
          ? const Color(0xFF2C2C2E)
          : const Color(0xFFF9F9FB),
      surfaceContainerHigh: isDark
          ? const Color(0xFF3A3A3C)
          : const Color(0xFFE5E5EA),
      outlineVariant: isDark
          ? const Color(0x52545458)
          : const Color(0x333C3C43),
    );
  }

  /// Adjusts certain colors in the [ColorScheme].
  static ColorScheme _adjustColorScheme(
    ColorScheme colorScheme,
    TargetPlatform platform,
  ) {
    if (platform.isCupertino) {
      return _applyCupertinoSurfaces(colorScheme);
    }
    return colorScheme.copyWith(
      // Hack: Mimic Material 3 Expressive color schemes by making
      // surfaceContainer much closer to surface.
      // Remove this when Flutter supports M3E natively.
      surfaceContainer: Color.lerp(
        colorScheme.surface,
        colorScheme.surfaceTint,
        0.02,
      )!,
    );
  }
}

abstract class _Components {
  static TextTheme textTheme(TargetPlatform platform, ColorScheme colorScheme) {
    final typography = Typography.material2021(
      platform: platform,
      colorScheme: colorScheme,
    );
    final textTheme = colorScheme.brightness == .dark
        ? typography.white
        : typography.black;

    if (stows.hyperlegibleFont.value) {
      return textTheme.withFont(
        fontFamily: 'AtkinsonHyperlegibleNext',
        fontFamilyFallback: saberSansSerifFontFallbacks,
      );
    } else {
      return textTheme;
    }
  }

  static const progressIndicatorTheme = ProgressIndicatorThemeData(
    // ignore: deprecated_member_use
    year2023: false,
    stopIndicatorColor: Colors.transparent,
  );

  static CardThemeData cardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 0,
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: const .all(.circular(OpennoteTokens.radiusMd)),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
    );
  }

  static DialogThemeData dialogTheme(ColorScheme colorScheme) {
    return DialogThemeData(
      elevation: 4,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: const .all(.circular(OpennoteTokens.radiusLg)),
        side: OpennoteTokens.subtleBorder(colorScheme, 0.28),
      ),
    );
  }

  static BottomSheetThemeData bottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      elevation: 4,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(OpennoteTokens.radiusLg)),
      ),
    );
  }

  static NavigationRailThemeData navigationRailTheme(ColorScheme colorScheme) {
    return NavigationRailThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
      selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 22),
      unselectedIconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 22,
      ),
      selectedLabelTextStyle: TextStyle(
        color: colorScheme.primary,
        fontWeight: .w600,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontWeight: .w500,
        fontSize: 13,
      ),
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: .all(.circular(OpennoteTokens.radiusSm)),
      ),
    );
  }

  static const cupertinoOverrideTheme = NoDefaultCupertinoThemeData(
    applyThemeToAll: true,
  );

  static const appBarTheme = AppBarTheme(
    centerTitle: false,
    scrolledUnderElevation: 0,
  );
}

extension SaberThemePlatform on TargetPlatform {
  bool get isCupertino => switch (this) {
    .iOS => true,
    .macOS => true,
    _ => false,
  };
}
