/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'dart:ui';

import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/tools/select.dart';

/// Copies of a selection's strokes and images,
/// kept so that they can be pasted onto any page later.
class SelectionClipboard {
  /// Copies everything in [selection] so that later edits to the originals
  /// don't change what gets pasted.
  SelectionClipboard.copyOf(SelectResult selection)
    : strokes = [for (final stroke in selection.strokes) stroke.copy()],
      images = [for (final image in selection.images) image.copy()];

  /// The copied strokes. These are never added to a page themselves.
  final List<Stroke> strokes;

  /// The copied images. These are never added to a page themselves.
  final List<EditorImage> images;

  /// Whether there is nothing to paste.
  bool get isEmpty => strokes.isEmpty && images.isEmpty;

  /// How far pasted items are moved from where they were copied,
  /// so that they don't sit exactly on top of the originals.
  static const pasteOffset = Offset(30, -30);

  /// Adds fresh copies of the clipboard's contents to [page],
  /// moved by [offset].
  ///
  /// [takeImageId] must return a new unique image id each time it is called.
  ///
  /// Returns the history item for the paste. It holds the copies that are now
  /// on the page, so undoing it removes exactly what was pasted.
  EditorHistoryItem pasteOnto(
    EditorPage page, {
    required int pageIndex,
    required int Function() takeImageId,
    Offset offset = pasteOffset,
  }) {
    final pastedStrokes = [
      for (final stroke in strokes)
        stroke.copy()
          ..shift(offset)
          ..pageIndex = pageIndex,
    ];
    final pastedImages = [
      for (final image in images)
        image.copy()
          ..id = takeImageId()
          ..pageIndex = pageIndex
          ..dstRect = image.dstRect.shift(offset),
    ];
    page.activeLayerStrokes.addAll(pastedStrokes);
    page.images.addAll(pastedImages);
    return EditorHistoryItem(
      type: .draw,
      pageIndex: pageIndex,
      strokes: pastedStrokes,
      images: pastedImages,
    );
  }
}
