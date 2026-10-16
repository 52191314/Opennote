/// 🤖 Generated wholely or partially with Claude Code (Claude Sonnet 5.5)
library;

import 'dart:math';
import 'dart:ui';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/data/editor/page.dart';

/// The vertical space left between pages when they are stacked into one.
const pageStackGap = 16.0;

/// Moves everything on [pages] after the first one onto the first page,
/// stacked below it in order, and removes the other pages.
///
/// An infinite canvas only shows the first page, so this has to run when
/// switching to it or the content of later pages would be hidden.
///
/// This does not touch any undo history, which refers to page indices
/// that no longer exist afterwards. Cancel any change listener on the first
/// page's [QuillStruct] beforehand, otherwise appended text is reported as
/// a user edit.
void mergePagesIntoFirst(List<EditorPage> pages) {
  if (pages.isEmpty) {
    pages.add(EditorPage());
    return;
  }

  final first = pages.first;
  _dropTrailingEmptyPages(pages);

  var top = first.size.height + pageStackGap;
  for (final page in pages.skip(1)) {
    _moveContent(from: page, to: first, offset: Offset(0, top));
    top += page.size.height + pageStackGap;
    page.dispose();
  }
  pages.removeRange(1, pages.length);
}

void _dropTrailingEmptyPages(List<EditorPage> pages) {
  while (pages.length > 1 && pages.last.isEmpty) {
    pages.removeLast().dispose();
  }
}

void _moveContent({
  required EditorPage from,
  required EditorPage to,
  required Offset offset,
}) {
  _moveStrokes(from: from, to: to, offset: offset);
  _moveImages(from: from, to: to, offset: offset);
  _appendText(from: from, to: to);
}

void _moveStrokes({
  required EditorPage from,
  required EditorPage to,
  required Offset offset,
}) {
  for (var i = 0; i < from.layers.length; i++) {
    final source = from.layers[i];
    while (to.layers.length <= i) {
      to.layers.add(Layer(name: source.name, visible: source.visible));
    }
    for (final stroke in source.strokes) {
      stroke.shift(offset);
      stroke.pageIndex = 0;
      stroke.page = to;
      to.layers[i].strokes.add(stroke);
    }
    source.strokes.clear();
  }
}

void _moveImages({
  required EditorPage from,
  required EditorPage to,
  required Offset offset,
}) {
  final images = [
    ...from.images,
    if (from.backgroundImage != null) from.backgroundImage!,
  ];
  for (final image in images) {
    _moveImage(image, to: to, offset: offset);
    to.images.add(image);
  }
  from.images.clear();
  from.backgroundImage = null;
}

void _moveImage(
  EditorImage image, {
  required EditorPage to,
  required Offset offset,
}) {
  image.dstRect = image.dstRect.shift(offset);
  image.pageIndex = 0;
  image.pageSize = to.size;
}

void _appendText({required EditorPage from, required EditorPage to}) {
  final source = from.quill.controller.document;
  if (source.isEmpty()) return;

  final target = to.quill.controller.document;
  final append = Delta();
  if (!target.isEmpty()) {
    append
      ..retain(target.length - 1)
      ..insert('\n');
  }
  _withoutTrailingNewline(source.toDelta()).toList().forEach(append.push);
  target.compose(append, ChangeSource.local);
}

/// [delta] without the plain newline every document ends with,
/// because the target document already has its own.
Delta _withoutTrailingNewline(Delta delta) {
  final operations = delta.toList();
  final last = operations.lastOrNull;
  final isPlainNewline =
      last != null &&
      last.isInsert &&
      last.data == '\n' &&
      last.attributes == null;
  if (!isPlainNewline) return delta;
  return Delta.fromOperations(operations.sublist(0, operations.length - 1));
}

/// Grows [page] and shifts its content so that all of it lies on the page.
///
/// A paged note clips to the page bounds, so this has to run when switching
/// from an infinite canvas, where content can sit at any coordinate.
/// The page never shrinks, and relative positions are kept.
void fitFirstPageToContent(EditorPage page) {
  final bounds = _contentBounds(page);
  if (bounds == null) return;

  final shift = Offset(max(0, -bounds.left), max(0, -bounds.top));
  if (shift != Offset.zero) _shiftContent(page, shift);

  page.size = Size(
    max(page.size.width, bounds.right + shift.dx),
    max(page.size.height, bounds.bottom + shift.dy),
  );
}

Rect? _contentBounds(EditorPage page) {
  Rect? bounds;
  for (final stroke in page.strokes) {
    final strokeBounds = stroke.highQualityPath.getBounds();
    bounds = bounds?.expandToInclude(strokeBounds) ?? strokeBounds;
  }
  for (final image in page.images) {
    bounds = bounds?.expandToInclude(image.dstRect) ?? image.dstRect;
  }
  return bounds;
}

void _shiftContent(EditorPage page, Offset offset) {
  for (final layer in page.layers) {
    for (final stroke in layer.strokes) {
      stroke.shift(offset);
    }
  }
  for (final image in page.images) {
    image.dstRect = image.dstRect.shift(offset);
  }
}
