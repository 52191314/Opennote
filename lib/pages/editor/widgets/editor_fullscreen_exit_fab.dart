/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/theming/dynamic_material_app.dart';
import 'package:saber/components/theming/saber_theme.dart';

/// Floating action button shown in fullscreen mode when the toolbar is hidden,
/// allowing the user to exit fullscreen cleanly.
class EditorFullscreenExitFab extends StatelessWidget {
  /// Creates an [EditorFullscreenExitFab].
  const EditorFullscreenExitFab({super.key, this.onExitFullscreen});

  /// Optional override callback; defaults to clearing [DynamicMaterialApp] fullscreen.
  final VoidCallback? onExitFullscreen;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return FloatingActionButton(
      shape: platform.isCupertino ? const CircleBorder() : null,
      onPressed:
          onExitFullscreen ??
          () => DynamicMaterialApp.setFullscreen(false, updateSystem: true),
      child: const Icon(Icons.fullscreen_exit),
    );
  }
}
