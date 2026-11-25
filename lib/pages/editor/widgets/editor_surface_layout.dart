/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:collapsible/collapsible.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:saber/components/theming/dynamic_material_app.dart';

/// Responsive scaffold body composing the editing canvas surface, collapsible
/// toolbar (vertical or horizontal), and read-only banner.
class EditorSurfaceLayout extends StatelessWidget {
  /// Creates an [EditorSurfaceLayout].
  const EditorSurfaceLayout({
    super.key,
    required this.toolbarAlignment,
    required this.opennoteUiMode,
    required this.showToolbarInFullscreen,
    required this.editingSurface,
    required this.toolbarContent,
    required this.readonlyBanner,
  });

  /// Observable toolbar dock direction (top, bottom, left, or right).
  final ValueListenable<AxisDirection> toolbarAlignment;

  /// Whether the modern Opennote chrome mode is active.
  final bool opennoteUiMode;

  /// Whether the toolbar remains visible in fullscreen mode.
  final bool showToolbarInFullscreen;

  /// The primary canvas stack (canvas + floating menus + zoom window).
  final Widget editingSurface;

  /// The active toolbar widget (`OpennoteToolbar` or classic `Toolbar`).
  final Widget toolbarContent;

  /// Banner displayed when the note is read-only.
  final Widget readonlyBanner;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AxisDirection>(
      valueListenable: toolbarAlignment,
      builder: (context, alignment, _) {
        final isVertical =
            alignment == AxisDirection.left || alignment == AxisDirection.right;
        final isTop = alignment == AxisDirection.up;
        final isOpennoteTop =
            isTop && opennoteUiMode && !DynamicMaterialApp.isFullscreen;

        final toolbar = Collapsible(
          axis: isVertical
              ? CollapsibleAxis.horizontal
              : CollapsibleAxis.vertical,
          collapsed:
              DynamicMaterialApp.isFullscreen && !showToolbarInFullscreen,
          maintainState: true,
          child: SafeArea(
            top: isOpennoteTop,
            bottom: !isTop,
            child: Padding(
              padding: EdgeInsets.only(top: isOpennoteTop ? 54.0 : 0.0),
              child: toolbarContent,
            ),
          ),
        );

        if (isVertical) {
          return Row(
            textDirection: alignment == AxisDirection.left
                ? TextDirection.ltr
                : TextDirection.rtl,
            children: [
              toolbar,
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: editingSurface),
                    readonlyBanner,
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          verticalDirection: isTop
              ? VerticalDirection.up
              : VerticalDirection.down,
          children: [
            Expanded(child: editingSurface),
            toolbar,
            readonlyBanner,
          ],
        );
      },
    );
  }
}
