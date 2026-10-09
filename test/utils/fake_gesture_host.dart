/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/gestures/tool_gesture.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/pen.dart';

/// Stands in for the editor in tests of a [ToolGesture],
/// and records what the gesture asked of it.
class FakeGestureHost implements EditorGestureHost {
  @override
  Tool currentTool = Pen.currentPen;

  @override
  final history = EditorHistory();

  @override
  var lineHeight = 40;

  /// The page indices [createPage] was called with.
  final createdPages = <int>[];

  /// How many times [autosaveAfterDelay] was called.
  var autosaves = 0;

  /// How many times [removeExcessPages] was called.
  var excessPageRemovals = 0;

  /// How many times [restoreToolAfterErasing] was called.
  var toolRestores = 0;

  /// The pages [deleteSelection] was called with.
  final deletedFrom = <EditorPage>[];

  @override
  void createPage(int pageIndex) => createdPages.add(pageIndex);

  @override
  void removeExcessPages() => excessPageRemovals++;

  @override
  void restoreToolAfterErasing() => toolRestores++;

  @override
  void autosaveAfterDelay() => autosaves++;

  @override
  void deleteSelection(EditorPage page) => deletedFrom.add(page);
}
