/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:ui';

import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/tools/select.dart';
import 'package:sbn/change.dart';

/// A resize, rotation, or vertex edit of a selection,
/// tracked from before its first change so that it can be undone.
///
/// Those gestures edit strokes in place, which leaves nothing to restore
/// them from. So [SelectionTransform.begin] swaps each selected stroke for a
/// copy: the gesture edits the copies, and the untouched originals go into
/// the history item that [finish] returns.
class SelectionTransform {
  /// Swaps the strokes in [selection] for copies, on [page] and in
  /// [selection] itself, and remembers where its images are.
  ///
  /// Call this before the gesture changes anything.
  SelectionTransform.begin(EditorPage page, this._selection)
    : _originalStrokes = List.of(_selection.strokes),
      _originalImageRects = {
        for (final image in _selection.images) image: image.dstRect,
      } {
    for (final (index, original) in _originalStrokes.indexed) {
      final copy = original.copy();
      if (!page.replaceStroke(original, copy)) continue;
      _selection.strokes[index] = copy;
    }
  }

  final SelectResult _selection;
  final List<Stroke> _originalStrokes;
  final Map<EditorImage, Rect> _originalImageRects;

  /// Returns the history item for everything the gesture changed.
  EditorHistoryItem finish({required int pageIndex}) => EditorHistoryItem(
    type: .transform,
    pageIndex: pageIndex,
    strokes: List.of(_selection.strokes),
    images: List.of(_originalImageRects.keys),
    replacedStrokes: _originalStrokes,
    imageRectChange: {
      for (final MapEntry(key: image, value: rect)
          in _originalImageRects.entries)
        image: Change(previous: rect, current: image.dstRect),
    },
  );

  /// Undoes the transform recorded in [item],
  /// putting the previous strokes and image positions back on [page].
  static void revert(EditorHistoryItem item, EditorPage page) {
    for (final (index, stroke) in item.strokes.indexed) {
      page.replaceStroke(stroke, item.replacedStrokes![index]);
    }
    for (final MapEntry(key: image, value: change)
        in item.imageRectChange!.entries) {
      image.dstRect = change.previous;
    }
  }

  /// Returns the opposite of [item]: reverting the result redoes [item].
  static EditorHistoryItem reversed(EditorHistoryItem item) => item.copyWith(
    strokes: item.replacedStrokes,
    replacedStrokes: item.strokes,
    imageRectChange: {
      for (final MapEntry(key: image, value: change)
          in item.imageRectChange!.entries)
        image: change.reverse(),
    },
  );
}
