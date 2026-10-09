/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:saber/data/editor/gestures/tool_gesture.dart';
import 'package:saber/data/tools/laser_pointer.dart';

/// Draws a fading trail, or moves the spotlight, for the [LaserPointer] tool.
///
/// Nothing the laser pointer draws is saved in the note.
class LaserGesture implements ToolGesture {
  const LaserGesture();

  @override
  bool start(GesturePointer pointer) {
    LaserPointer.currentLaserPointer.onDragStart(
      pointer.position,
      pointer.page,
      pointer.pageIndex,
    );
    return true;
  }

  @override
  void update(GesturePointer pointer) {
    LaserPointer.currentLaserPointer.onDragUpdate(pointer.position);
    pointer.page.redrawStrokes();
  }

  @override
  bool end(GesturePointer pointer) {
    final page = pointer.page;
    final trail = LaserPointer.currentLaserPointer.onDragEnd(
      page.redrawStrokes,
      page.laserStrokes.remove,
    );
    if (trail != null) page.laserStrokes.add(trail);
    return false;
  }
}
