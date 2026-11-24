/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/navbar/responsive_navbar.dart';
import 'package:saber/data/prefs.dart';

/// Index-based [TransformedStow] adapters for enum preferences displayed in
/// `SettingsSelection` widgets.
abstract class SettingsStows {
  static final appTheme = TransformedStow(
    stows.appTheme,
    (ThemeMode value) => value.index,
    (int value) => ThemeMode.values[value],
  );

  static final platform = TransformedStow(
    stows.platform,
    (TargetPlatform value) => value.index,
    (int value) => TargetPlatform.values[value],
  );

  static final layoutSize = TransformedStow(
    stows.layoutSize,
    (LayoutSize value) => value.index,
    (int value) => LayoutSize.values[value],
  );

  static final editorToolbarAlignment = TransformedStow(
    stows.editorToolbarAlignment,
    (AxisDirection value) => value.index,
    (int value) => AxisDirection.values[value],
  );
}
