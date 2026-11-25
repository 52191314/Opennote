/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Sonnet 5.5)
/// 🤖 Modified with Grok 4.7
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:logging/logging.dart';
import 'package:saber/data/prefs/appearance_prefs.dart';
import 'package:saber/data/prefs/canvas_tools_prefs.dart';
import 'package:saber/data/prefs/editor_prefs.dart';
import 'package:saber/data/prefs/growth_prefs.dart';
import 'package:saber/data/prefs/stow_helpers.dart';
import 'package:saber/data/prefs/sync_prefs.dart';

export 'package:saber/data/prefs/appearance_prefs.dart';
export 'package:saber/data/prefs/canvas_tools_prefs.dart';
export 'package:saber/data/prefs/editor_prefs.dart';
export 'package:saber/data/prefs/growth_prefs.dart';
export 'package:saber/data/prefs/stow_helpers.dart' show TransformedStow;
export 'package:saber/data/prefs/sync_prefs.dart';

/// Singleton preference store composed of cohesive domain preference mixins.
final stows = Stows();

/// Central application preferences container.
///
/// Individual preference groups live in modular mixins under `lib/data/prefs/`:
/// [SyncPrefs], [AppearancePrefs], [EditorPrefs], [CanvasToolsPrefs], and
/// [GrowthPrefs].
class Stows
    with
        SyncPrefs,
        AppearancePrefs,
        EditorPrefs,
        CanvasToolsPrefs,
        GrowthPrefs {
  /// Creates a [Stows] instance and registers cross-preference listeners.
  Stows() {
    recentColorsLength.addListener(_truncateRecentColors);
  }

  /// Call this before `runApp` to enable persistent storage on the main isolate.
  static void markAsOnMainIsolate() => StowIsolate.markAsOnMainIsolate();

  /// Default line height for lined/grid canvas backgrounds.
  static const defaultLineHeight = EditorPrefs.defaultLineHeight;

  /// Default line thickness for lined/grid canvas backgrounds.
  static const defaultLineThickness = EditorPrefs.defaultLineThickness;

  /// Constant representing 3-axis isometric 30-degree snapping mode for
  /// [snapAngleStep].
  static const snapAngleStepIso30 = EditorPrefs.snapAngleStepIso30;

  /// Logger for preference operations.
  final log = Logger('Stows');

  void _truncateRecentColors() {
    while (recentColorsLength.value < recentColorsPositioned.value.length) {
      if (recentColorsChronological.value.isEmpty) break;
      final removed = recentColorsChronological.value.removeAt(0);
      recentColorsPositioned.value.remove(removed);
    }
  }
}
