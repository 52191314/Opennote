/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/data/prefs.dart';
import 'package:sbn/font_fallbacks.dart';

abstract class SaberTheme {
  /// Builds the flagship Opennote Studio [ThemeData] from [colorScheme] and [platform].
  static ThemeData createTheme(
    ColorScheme colorScheme,
    TargetPlatform platform,
  ) {
    colorScheme = _adjustColorScheme(colorScheme, platform);
    final brightness = colorScheme.brightness;
    final scaffoldBg = Color.lerp(
      colorScheme.surface,
      OpennoteTokens.studioSurface(brightness),
      0.72,
    )!;
    final textTheme = _Components.textTheme(platform, colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      platform: platform,
      progressIndicatorTheme: _Components.progressIndicatorTheme,
      cardColor: OpennoteTokens.cardSurface(brightness),
      cardTheme: _Components.cardTheme(colorScheme),
      dialogTheme: _Components.dialogTheme(colorScheme),
      bottomSheetTheme: _Components.bottomSheetTheme(colorScheme),
      navigationRailTheme: _Components.navigationRailTheme(colorScheme),
      cupertinoOverrideTheme: _Components.cupertinoOverrideTheme,
      appBarTheme: _Components.appBarTheme(colorScheme, textTheme),
      inputDecorationTheme: _Components.inputDecorationTheme(colorScheme),
      chipTheme: _Components.chipTheme(colorScheme, textTheme),
      filledButtonTheme: _Components.filledButtonTheme(colorScheme),
      outlinedButtonTheme: _Components.outlinedButtonTheme(colorScheme),
      textButtonTheme: _Components.textButtonTheme(colorScheme),
      dividerTheme: _Components.dividerTheme(colorScheme),
    );
  }

  /// Creates a [ThemeData] seeded from [seedColor], [brightness], and [platform].
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

  /// Applies studio-harmonized Cupertino grouped surface hierarchy colors.
  static ColorScheme _applyCupertinoSurfaces(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return colorScheme.copyWith(
      surface: isDark
          ? OpennoteTokens.studioDarkSurface
          : OpennoteTokens.studioLightSurface,
      surfaceContainerLowest: isDark
          ? OpennoteTokens.studioDarkSurface
          : OpennoteTokens.cardLightSurface,
      surfaceContainerLow: isDark
          ? OpennoteTokens.cardDarkSurface
          : OpennoteTokens.cardLightSurface,
      surfaceContainer: isDark
          ? OpennoteTokens.elevatedDarkSurface
          : OpennoteTokens.subtleLightSurface,
      surfaceContainerHigh: isDark
          ? OpennoteTokens.hoverDarkSurface
          : OpennoteTokens.hoverLightSurface,
      outlineVariant: isDark
          ? OpennoteTokens.hairlineDark
          : OpennoteTokens.hairlineLight,
    );
  }

  /// Adjusts surface hierarchy tokens in the [ColorScheme] for studio clarity.
  static ColorScheme _adjustColorScheme(
    ColorScheme colorScheme,
    TargetPlatform platform,
  ) {
    if (platform.isCupertino) {
      return _applyCupertinoSurfaces(colorScheme);
    }
    final brightness = colorScheme.brightness;
    return colorScheme.copyWith(
      surface: Color.lerp(
        colorScheme.surface,
        OpennoteTokens.studioSurface(brightness),
        0.55,
      )!,
      surfaceContainerLowest: OpennoteTokens.cardSurface(brightness),
      surfaceContainerLow: OpennoteTokens.cardSurface(brightness),
      surfaceContainer: Color.lerp(
        OpennoteTokens.subtleSurface(brightness),
        colorScheme.surfaceTint,
        0.02,
      )!,
      surfaceContainerHigh: OpennoteTokens.elevatedSurface(brightness),
    );
  }
}

abstract class _Components {
  static TextTheme textTheme(TargetPlatform platform, ColorScheme colorScheme) {
    final typography = Typography.material2021(
      platform: platform,
      colorScheme: colorScheme,
    );
    final base = colorScheme.brightness == Brightness.dark
        ? typography.white
        : typography.black;

    final refined = base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.15,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.45,
        height: 1.2,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.35,
        height: 1.25,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.28,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.32,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
      ),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
      bodySmall: base.bodySmall?.copyWith(height: 1.4),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.05,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.05,
      ),
    );

    if (stows.hyperlegibleFont.value) {
      return refined.withFont(
        fontFamily: 'AtkinsonHyperlegibleNext',
        fontFamilyFallback: saberSansSerifFontFallbacks,
      );
    }
    return refined;
  }

  static const progressIndicatorTheme = ProgressIndicatorThemeData(
    // ignore: deprecated_member_use
    year2023: false,
    stopIndicatorColor: Colors.transparent,
  );

  static CardThemeData cardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 0,
      color: OpennoteTokens.cardSurface(colorScheme.brightness),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: OpennoteTokens.borderRadiusMd,
        side: OpennoteTokens.hairlineBorder(colorScheme),
      ),
    );
  }

  static DialogThemeData dialogTheme(ColorScheme colorScheme) {
    return DialogThemeData(
      elevation: 4,
      backgroundColor: OpennoteTokens.cardSurface(colorScheme.brightness),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: OpennoteTokens.borderRadiusLg,
        side: OpennoteTokens.hairlineBorder(colorScheme),
      ),
    );
  }

  static BottomSheetThemeData bottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      elevation: 4,
      backgroundColor: OpennoteTokens.cardSurface(colorScheme.brightness),
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.28),
      dragHandleSize: const Size(36, 4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(OpennoteTokens.radiusLg),
        ),
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
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      indicatorShape: const RoundedRectangleBorder(
        borderRadius: OpennoteTokens.borderRadiusSm,
      ),
    );
  }

  static const cupertinoOverrideTheme = NoDefaultCupertinoThemeData(
    applyThemeToAll: true,
  );

  static AppBarTheme appBarTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
    );
  }

  static InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) {
    final hairline = OpennoteTokens.hairlineBorder(colorScheme);
    final errorBorder = BorderSide(
      color: colorScheme.error,
      width: OpennoteTokens.hairlineWidth,
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: OpennoteTokens.subtleSurface(colorScheme.brightness),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: OpennoteTokens.s3 + 2,
        vertical: OpennoteTokens.s3,
      ),
      border: OutlineInputBorder(
        borderRadius: OpennoteTokens.borderRadiusSm,
        borderSide: hairline,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: OpennoteTokens.borderRadiusSm,
        borderSide: hairline,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: OpennoteTokens.borderRadiusSm,
        borderSide: OpennoteTokens.focusBorder(colorScheme),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: OpennoteTokens.borderRadiusSm,
        borderSide: errorBorder,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: OpennoteTokens.borderRadiusSm,
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
    );
  }

  static ChipThemeData chipTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return ChipThemeData(
      elevation: 0,
      pressElevation: 0,
      backgroundColor: OpennoteTokens.cardSurface(colorScheme.brightness),
      selectedColor: colorScheme.primary.withValues(alpha: 0.14),
      surfaceTintColor: Colors.transparent,
      side: OpennoteTokens.hairlineBorder(colorScheme),
      shape: const RoundedRectangleBorder(
        borderRadius: OpennoteTokens.borderRadiusSm,
      ),
      labelStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: OpennoteTokens.s2,
        vertical: OpennoteTokens.s1,
      ),
    );
  }

  static FilledButtonThemeData filledButtonTheme(ColorScheme colorScheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(
          horizontal: OpennoteTokens.s4,
          vertical: OpennoteTokens.s2 + 2,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: OpennoteTokens.borderRadiusSm,
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData outlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 44),
        foregroundColor: colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(
          horizontal: OpennoteTokens.s4,
          vertical: OpennoteTokens.s2 + 2,
        ),
        side: OpennoteTokens.hairlineBorder(colorScheme),
        shape: const RoundedRectangleBorder(
          borderRadius: OpennoteTokens.borderRadiusSm,
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  static TextButtonThemeData textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(
          horizontal: OpennoteTokens.s3,
          vertical: OpennoteTokens.s2,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: OpennoteTokens.borderRadiusSm,
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
      ),
    );
  }

  static DividerThemeData dividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: OpennoteTokens.hairlineColor(colorScheme),
      thickness: OpennoteTokens.hairlineWidth,
      space: 1,
    );
  }
}

extension SaberThemePlatform on TargetPlatform {
  bool get isCupertino => switch (this) {
    TargetPlatform.iOS => true,
    TargetPlatform.macOS => true,
    _ => false,
  };
}
