/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/theming/yaru_builder.dart';
import 'package:saber/data/prefs.dart';
import 'package:sbn/font_fallbacks.dart';
import 'package:yaru/yaru.dart';

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
    late final yaruVariant = YaruBuilder.getYaruVariant(seedColor);
    if (platform == .linux) {
      return getThemeFromYaru(
        YaruThemeData(variant: yaruVariant),
        brightness,
        platform,
        highContrast,
      );
    }

    final ColorScheme colorScheme;
    if (platform.usesYaruColors) {
      colorScheme = brightness == .light
          ? yaruVariant.theme.colorScheme
          : yaruVariant.darkTheme.colorScheme;
    } else {
      colorScheme = ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: seedColor,
      );
    }
    return createTheme(colorScheme, platform);
  }

  /// Adjusts certain colors in the [ColorScheme].
  static ColorScheme _adjustColorScheme(
    ColorScheme colorScheme,
    TargetPlatform platform,
  ) {
    return colorScheme.copyWith(
      surface: platform.isCupertino
          ? (colorScheme.brightness == .light
                ? CupertinoColors.white
                : CupertinoColors.darkBackgroundGray)
          : null,
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

  static ThemeData getThemeFromYaru(
    YaruThemeData yaru,
    Brightness brightness,
    TargetPlatform platform,
    bool highContrast,
  ) {
    final base = highContrast
        ? (brightness == .light ? yaruHighContrastLight : yaruHighContrastDark)
        : (brightness == .light ? yaru.theme : yaru.darkTheme);
    return getThemeFromYaruFixed(base, platform);
  }

  static ThemeData getThemeFromYaruFixed(
    ThemeData base,
    TargetPlatform platform,
  ) {
    final textTheme = _Components.textTheme(platform, base.colorScheme);
    final fontFamily = textTheme.bodyMedium!.fontFamily;
    final fontFamilyFallback = textTheme.bodyMedium!.fontFamilyFallback;
    return base.copyWith(
      platform: platform,
      textTheme: textTheme,
      progressIndicatorTheme: _Components.progressIndicatorTheme,
      cardTheme: _Components.cardTheme(base.colorScheme),
      dialogTheme: _Components.dialogTheme(base.colorScheme),
      bottomSheetTheme: _Components.bottomSheetTheme(base.colorScheme),
      navigationRailTheme: _Components.navigationRailTheme(base.colorScheme),
      cupertinoOverrideTheme: _Components.cupertinoOverrideTheme,
      listTileTheme: base.listTileTheme.copyWith(
        // Yaru forces list tiles to use Ubuntu font, fix that
        titleTextStyle: base.listTileTheme.titleTextStyle?.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
        ),
        subtitleTextStyle: base.listTileTheme.subtitleTextStyle?.copyWith(
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
        ),
        leadingAndTrailingTextStyle: base
            .listTileTheme
            .leadingAndTrailingTextStyle
            ?.copyWith(
              fontFamily: fontFamily,
              fontFamilyFallback: fontFamilyFallback,
            ),
      ),
      // Leave Yaru's app bar theme, since it adds a border bottom.
      // appBarTheme: _Components.appBarTheme,
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
    } else if (platform == .linux) {
      // Flutter picks Roboto but Adwaita Sans is a better default
      return textTheme.withFont(fontFamily: 'Adwaita Sans');
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
  /// iOS uses Yaru's colorscheme since it looks more native than M3.
  bool get usesYaruColors => switch (this) {
    .linux => true,
    .iOS => true,
    .macOS => true,
    _ => false,
  };

  bool get isCupertino => switch (this) {
    .iOS => true,
    .macOS => true,
    _ => false,
  };
}
