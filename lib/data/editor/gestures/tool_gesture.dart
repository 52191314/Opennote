/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:ui';

import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/tools/_tool.dart';

/// How one tool responds to a pointer drawing on a page.
///
/// The editor calls [start] when the pointer goes down, [update] each time
/// it moves, and [end] when it lifts.
abstract interface class ToolGesture {
  /// Returns false if the editor should leave its drag tracking as it was,
  /// because the touch was not the start of an ordinary drag.
  bool start(GesturePointer pointer);

  /// Responds to the pointer moving to [GesturePointer.position].
  void update(GesturePointer pointer);

  /// Returns whether the gesture changed the note, so that it needs saving.
  bool end(GesturePointer pointer);
}

/// Where the pointer is during a draw gesture.
class GesturePointer {
  const GesturePointer({
    required this.page,
    required this.pageIndex,
    required this.position,
    this.delta = .zero,
    this.moved = .zero,
    this.pressure,
  });

  /// The page being drawn on.
  final EditorPage page;

  /// The index of [page] in the note.
  final int pageIndex;

  /// The pointer's position on [page].
  ///
  /// When the gesture ends, this is the last position the editor tracked.
  final Offset position;

  /// How far the pointer moved since the previous event.
  final Offset delta;

  /// How far the pointer had moved in total before this event.
  final Offset moved;

  /// The pointer's pressure, if the device reports it.
  final double? pressure;
}

/// What a [ToolGesture] needs from the editor it draws in.
abstract interface class EditorGestureHost {
  /// The tool the pointer is drawing with.
  Tool get currentTool;

  /// The undo history of the note.
  EditorHistory get history;

  /// The height of a ruled line in the note.
  int get lineHeight;

  /// Makes sure the note has a page at [pageIndex].
  void createPage(int pageIndex);

  /// Removes the blank pages left at the end of the note.
  void removeExcessPages();

  /// Switches back to the previous tool if the eraser was only borrowed,
  /// for example by holding the stylus button.
  void restoreToolAfterErasing();

  /// Saves the note once the user has stopped editing for a moment.
  void autosaveAfterDelay();

  /// Deletes the current selection from [page].
  void deleteSelection(EditorPage page);
}
