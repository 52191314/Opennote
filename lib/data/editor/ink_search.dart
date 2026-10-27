/// 🤖 Generated wholely or partially with Grok 4.7
library;

import 'dart:typed_data';
import 'dart:ui' show Offset;

import 'package:bson/bson.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';

/// One page of a note: typed text plus the ink strokes on it.
class NotePage {
  const NotePage({required this.ink, this.typedText = ''});

  /// Each stroke is the polyline the pen actually drew.
  final List<List<Offset>> ink;

  final String typedText;
}

/// A note the search can read without opening the editor.
class NoteDocument {
  const NoteDocument({
    required this.filePath,
    required this.fileName,
    required this.pages,
  });

  final String filePath;
  final String fileName;
  final List<NotePage> pages;
}

/// A search hit, including where to open it.
class NoteHit {
  const NoteHit({
    required this.filePath,
    required this.fileName,
    required this.pageIndex,
    required this.matchKind,
    required this.preview,
  });

  final String filePath;
  final String fileName;
  final int pageIndex;

  /// `filename`, `text`, or `ink`.
  final String matchKind;
  final String preview;

  /// Editor route for this note, opened on [pageIndex].
  String get openRoute =>
      RoutePaths.editFilePath(filePath, pageIndex: pageIndex);
}

/// Finds notes by file name, typed text, and words read from ink.
class NoteSearch {
  /// [query] is matched case-insensitively.
  ///
  /// Ink hits come from [InkReader] looking at stroke points. A file-name
  /// hit uses the note name. A text hit uses [NotePage.typedText].
  static List<NoteHit> search({
    required String query,
    required List<NoteDocument> notes,
    bool fileNames = true,
  }) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const [];

    final hits = <NoteHit>[];
    for (final note in notes) {
      if (fileNames && note.fileName.toLowerCase().contains(needle)) {
        hits.add(
          NoteHit(
            filePath: note.filePath,
            fileName: note.fileName,
            pageIndex: 0,
            matchKind: 'filename',
            preview: note.fileName,
          ),
        );
      }

      for (var index = 0; index < note.pages.length; index++) {
        final page = note.pages[index];
        final typed = page.typedText;
        if (typed.toLowerCase().contains(needle)) {
          hits.add(
            NoteHit(
              filePath: note.filePath,
              fileName: note.fileName,
              pageIndex: index,
              matchKind: 'text',
              preview: t.searchResults.textMatch(
                page: index + 1,
                snippet: typed,
              ),
            ),
          );
        }

        final word = InkReader.read(page.ink);
        if (word.isEmpty || !word.toLowerCase().contains(needle)) continue;
        hits.add(
          NoteHit(
            filePath: note.filePath,
            fileName: note.fileName,
            pageIndex: index,
            matchKind: 'ink',
            preview: t.searchResults.inkMatch(page: index + 1, word: word),
          ),
        );
      }
    }
    return hits;
  }
}

/// Reads clearly separated block capitals from pen strokes.
///
/// Letters are split by the gap between strokes, then classified from the
/// stroke shapes: verticals, horizontals, and closed loops.
class InkReader {
  static const _letterGap = 24.0;

  /// Points stored on a stroke, either as `{x, y}` maps or float binaries.
  static List<Offset> pointsFrom(dynamic raw) {
    if (raw is! List) return const [];
    final points = <Offset>[];
    for (final item in raw) {
      if (item is Map) {
        final x = item['x'];
        final y = item['y'];
        if (x is num && y is num) {
          points.add(Offset(x.toDouble(), y.toDouble()));
        }
      } else if (item is BsonBinary) {
        final bytes = Uint8List.fromList(item.byteList);
        if (bytes.length < 8) continue;
        final floats = bytes.buffer.asFloat32List(0, bytes.length ~/ 4);
        if (floats.length >= 2) points.add(Offset(floats[0], floats[1]));
      }
    }
    return points;
  }

  static String read(List<List<Offset>> strokes) {
    final letters = _groupLetters(strokes);
    final buffer = StringBuffer();
    for (final letter in letters) {
      final glyph = _classify(letter);
      if (glyph != null) buffer.write(glyph);
    }
    return buffer.toString();
  }

  static List<List<List<Offset>>> _groupLetters(List<List<Offset>> strokes) {
    final usable = [
      for (final stroke in strokes)
        if (stroke.length >= 2) stroke,
    ];
    usable.sort((a, b) => _bounds(a).left.compareTo(_bounds(b).left));

    final groups = <List<List<Offset>>>[];
    var groupRight = double.negativeInfinity;
    for (final stroke in usable) {
      final bounds = _bounds(stroke);
      final startsNewLetter =
          groups.isEmpty || bounds.left > groupRight + _letterGap;
      if (startsNewLetter) {
        groups.add([stroke]);
        groupRight = bounds.right;
      } else {
        groups.last.add(stroke);
        if (bounds.right > groupRight) groupRight = bounds.right;
      }
    }
    return groups;
  }

  static String? _classify(List<List<Offset>> strokes) {
    final verticals = strokes
        .where((stroke) => _isStraight(stroke, vertical: true))
        .length;
    final horizontals = strokes
        .where((stroke) => _isStraight(stroke, vertical: false))
        .length;
    final loops = strokes.where(_isLoop).length;

    if (loops == 1 && strokes.length == 1) return 'O';
    if (verticals == 2 && horizontals == 1) return 'H';
    if (horizontals == 1 && verticals == 1) {
      final bar = strokes.firstWhere(
        (stroke) => _isStraight(stroke, vertical: false),
      );
      final bounds = _bounds(strokes.expand((stroke) => stroke).toList());
      final barY = _bounds(bar).center.dy;
      if (barY <= bounds.top + bounds.height * 0.35) return 'T';
      if (barY >= bounds.top + bounds.height * 0.65) return 'L';
    }
    if (verticals == 1 && horizontals == 0 && loops == 0) {
      final bounds = _bounds(strokes.expand((stroke) => stroke).toList());
      if (bounds.width <= bounds.height * 0.45) return 'I';
    }
    return null;
  }

  static bool _isStraight(List<Offset> stroke, {required bool vertical}) {
    final bounds = _bounds(stroke);
    if (vertical) {
      return bounds.height >= 12 && bounds.width <= bounds.height * 0.35;
    }
    return bounds.width >= 12 && bounds.height <= bounds.width * 0.35;
  }

  static bool _isLoop(List<Offset> stroke) {
    if (stroke.length < 8) return false;
    final bounds = _bounds(stroke);
    if (bounds.width < 8 || bounds.height < 8) return false;
    final closed =
        (stroke.first - stroke.last).distance <= 0.35 * bounds.longestSide;
    if (!closed) return false;

    var top = false;
    var bottom = false;
    var left = false;
    var right = false;
    for (final point in stroke) {
      if (point.dy <= bounds.top + bounds.height * 0.25) top = true;
      if (point.dy >= bounds.bottom - bounds.height * 0.25) bottom = true;
      if (point.dx <= bounds.left + bounds.width * 0.25) left = true;
      if (point.dx >= bounds.right - bounds.width * 0.25) right = true;
    }
    return top && bottom && left && right;
  }

  static _InkBounds _bounds(List<Offset> points) {
    var left = points.first.dx;
    var right = left;
    var top = points.first.dy;
    var bottom = top;
    for (final point in points.skip(1)) {
      if (point.dx < left) left = point.dx;
      if (point.dx > right) right = point.dx;
      if (point.dy < top) top = point.dy;
      if (point.dy > bottom) bottom = point.dy;
    }
    return _InkBounds.fromLTRB(left, top, right, bottom);
  }
}

/// A rectangle of stroke points. Local so this file does not import widgets.
class _InkBounds {
  const _InkBounds.fromLTRB(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;
  double get longestSide => width > height ? width : height;
  Offset get center => Offset((left + right) / 2, (top + bottom) / 2);
}
