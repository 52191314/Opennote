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
  /// [selection] itself, and remembers where its images and text are.
  ///
  /// Call this before the gesture changes anything.
  SelectionTransform.begin(this._page, this._selection)
    : _originalStrokes = List.of(_selection.strokes),
      _originalImageRects = {
        for (final image in _selection.images) image: image.dstRect,
      },
      _originalTextPlacement = _selection.textSelected
          ? _page.textPlacement
          : null {
    for (final (index, original) in _originalStrokes.indexed) {
      final copy = original.copy();
      if (!_page.replaceStroke(original, copy)) continue;
      _selection.strokes[index] = copy;
    }
  }

  final EditorPage _page;
  final SelectResult _selection;
  final List<Stroke> _originalStrokes;
  final Map<EditorImage, Rect> _originalImageRects;
  final TextPlacement? _originalTextPlacement;

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
    textPlacementChange: switch (_originalTextPlacement) {
      null => null,
      final original => Change(
        previous: original,
        current: _page.textPlacement,
      ),
    },
  );

  /// Undoes the transform recorded in [item], putting the previous strokes,
  /// image positions, and text placement back on [page].
  static void revert(EditorHistoryItem item, EditorPage page) {
    for (final (index, stroke) in item.strokes.indexed) {
      page.replaceStroke(stroke, item.replacedStrokes![index]);
    }
    for (final MapEntry(key: image, value: change)
        in item.imageRectChange!.entries) {
      image.dstRect = change.previous;
    }
    final textPlacementChange = item.textPlacementChange;
    if (textPlacementChange == null) return;
    page.textPlacement = textPlacementChange.previous;
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
    textPlacementChange: item.textPlacementChange?.reverse(),
  );
}
