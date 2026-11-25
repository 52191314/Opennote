/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/navbar/responsive_navbar.dart';
import 'package:saber/data/prefs/stow_helpers.dart';
import 'package:stow_codecs/stow_codecs.dart';
import 'package:stow_plain/stow_plain.dart';

/// Application theme, layout density, typography, shell mode, and locale
/// preferences.
mixin AppearancePrefs {
  /// Selected Material theme mode (system, light, or dark).
  final appTheme = PlainStow(
    'appTheme',
    ThemeMode.system,
    codec: const EnumCodec(ThemeMode.values),
    volatile: StowIsolate.isVolatile,
  );

  /// The target platform used for adaptive theming.
  ///
  /// Defaults to [defaultTargetPlatform].
  final platform = PlainStow(
    'platform',
    defaultTargetPlatform,
    codec: const EnumCodec(TargetPlatform.values),
    volatile: StowIsolate.isVolatile,
  );

  /// Responsive layout size override.
  final layoutSize = PlainStow(
    'layoutSize',
    LayoutSize.auto,
    codec: LayoutSize.codec,
    volatile: StowIsolate.isVolatile,
  );

  /// The accent color of the app. If null or 0, the system accent color is used.
  final accentColor = PlainStow<Color?>(
    'accentColor',
    null,
    codec: const ColorCodec(),
    volatile: StowIsolate.isVolatile,
  );

  /// Whether Atkinson Hyperlegible font is enabled.
  final hyperlegibleFont = PlainStow(
    'hyperlegibleFont',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the simplified home screen layout is enabled.
  final simplifiedHomeLayout = PlainStow(
    'simplifiedHomeLayout',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// When true, enables the Opennote Studio dual-tier toolbar, shelf, and
  /// document header.
  late final opennoteUiMode = PlainStow(
    'opennoteUiMode',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// User-selected app locale tag, or empty string for system default.
  final locale = PlainStow('locale', '', volatile: StowIsolate.isVolatile);
}
