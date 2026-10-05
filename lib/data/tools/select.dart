/// 🤖 Modified with DeepSeek v4 Flash
/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/_arrow_stroke.dart';
import 'package:saber/components/canvas/_dimension_stroke.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/_tape_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:sbn/tool_id.dart';

class Select extends Tool {
  Select._();

  static final _currentSelect = Select._();
  static Select get currentSelect => _currentSelect;

  /// The minimum ratio of points inside a stroke or image
  /// for it to be selected.
  static const minPercentInside = 0.7;

  /// The tap radius in pixels for hit-testing strokes on tap.
  static const tapRadius = 15.0;

  var selectResult = SelectResult(
    pageIndex: -1,
    strokes: const [],
    images: const [],
    path: Path(),
  );
  var doneSelecting = false;

  /// Whether the transform/resize bounding box handles are actively shown.
  /// Follows Goodnotes mechanics where the selection contour is clean by default,
  /// and transform handles appear upon tapping 'Resize' in the callout menu.
  var isResizeActive = false;

  /// The starting position of the current drag (used for rectangle selection).
  Offset? _dragStartPosition;

  @override
  ToolId get toolId => .select;

  void unselect() {
    // Exit crop mode on all previously selected images
    for (final image in selectResult.images) {
      image.cropMode = false;
    }
    doneSelecting = false;
    isResizeActive = false;
    selectResult = SelectResult(
      pageIndex: -1,
      strokes: [],
      images: [],
      path: Path(),
    );
  }

  Color? getDominantStrokeColor() {
    if (!doneSelecting) return null;
    if (selectResult.strokes.isEmpty) return null;

    final colorDistribution = <Color, int>{};
    for (final stroke in selectResult.strokes) {
      colorDistribution.update(
        stroke.color,
        (value) => value + stroke.length,
        ifAbsent: () => stroke.length,
      );
    }
    assert(colorDistribution.isNotEmpty);

    return colorDistribution.entries.reduce((a, b) {
      return a.value > b.value ? a : b;
    }).key;
  }

  void onDragStart(Offset position, int pageIndex) {
    doneSelecting = false;
    isResizeActive = false;
    _dragStartPosition = position;
    selectResult = SelectResult(
      pageIndex: pageIndex,
      strokes: [],
      images: [],
      path: Path(),
    );
    _updateSelectionPath(position);
  }

  void onDragUpdate(Offset position) {
    _updateSelectionPath(position);
  }

  void _updateSelectionPath(Offset position) {
    final start = _dragStartPosition;
    if (start == null) {
      selectResult.path.lineTo(position.dx, position.dy);
      return;
    }

    if (stows.selectionRectMode.value) {
      // Rectangle selection
      selectResult.path = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(start, position),
            const Radius.circular(4),
          ),
        );
    } else {
      // Lasso selection (freeform)
      selectResult.path.lineTo(position.dx, position.dy);
    }
  }

  /// Populates the selection using a pre-constructed [path] (e.g. from circle-to-select).
  void selectFromPath({
    required Path path,
    required List<Stroke> strokes,
    required List<EditorImage> images,
    required int pageIndex,
    Rect textRect = Rect.zero,
  }) {
    selectResult = SelectResult(
      pageIndex: pageIndex,
      strokes: [],
      images: [],
      path: path,
    );
    onDragEnd(strokes, images, textRect: textRect);
  }

  /// Adds the indices of any [strokes] or [images] inside the selection area.
  /// [textRect] is the bounding rect of text content ([Rect.zero] if none).
  void onDragEnd(
    List<Stroke> strokes,
    List<EditorImage> images, {
    Rect textRect = Rect.zero,
  }) {
    selectResult.path.close();
    doneSelecting = true;

    for (int i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      final isTape = stroke is TapeStroke;
      if (isTape && !stows.lassoSelectTape.value) continue;
      if (!isTape && !stows.lassoSelectHandwriting.value) continue;

      final percentInside = polygonPercentInside(
        selectResult.path,
        stroke.lowQualityPolygon,
      );
      if (percentInside > minPercentInside ||
          (stroke.length <= 3 &&
              stroke.lowQualityPolygon.isNotEmpty &&
              selectResult.path.contains(stroke.lowQualityPolygon.first))) {
        selectResult.strokes.add(stroke);
      }
    }

    if (stows.lassoSelectImages.value) {
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        final percentInside = rectPercentInside(
          selectResult.path,
          image.dstRect,
        );
        if (percentInside >= minPercentInside) {
          selectResult.images.add(image);
        }
      }
    }

    // Check text overlap
    if (stows.lassoSelectText.value && textRect != Rect.zero) {
      final percentInside = rectPercentInside(selectResult.path, textRect);
      if (percentInside >= minPercentInside) {
        selectResult.textSelected = true;
      }
    }
  }

  /// Prunes any elements from the active selection whose filter is currently disabled.
  void pruneDisabledFilters() {
    if (!doneSelecting) return;

    var strokes = selectResult.strokes;
    var images = selectResult.images;
    var textSelected = selectResult.textSelected;

    if (!stows.lassoSelectHandwriting.value && strokes.isNotEmpty) {
      strokes = strokes.whereType<TapeStroke>().toList();
    }
    if (!stows.lassoSelectTape.value && strokes.isNotEmpty) {
      strokes = strokes.where((s) => s is! TapeStroke).toList();
    }
    if (!stows.lassoSelectImages.value && images.isNotEmpty) {
      for (final image in images) {
        image.cropMode = false;
      }
      images = [];
    }
    if (!stows.lassoSelectText.value && textSelected) {
      textSelected = false;
    }

    selectResult = selectResult.copyWith(
      strokes: strokes,
      images: images,
      textSelected: textSelected,
    );

    if (selectResult.isEmpty) {
      unselect();
    }
  }

  static double rectPercentInside(Path selection, Rect rect) {
    const int gridSize = 5;
    final gridCellWidth = rect.width / (gridSize - 1);
    final gridCellHeight = rect.height / (gridSize - 1);

    int pointsInside = 0;
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        if (selection.contains(
          Offset(rect.left + gridCellWidth * x, rect.top + gridCellHeight * y),
        )) {
          pointsInside++;
        }
      }
    }

    // times 1.25 because the grid is not very accurate
    return pointsInside / (gridSize * gridSize) * 1.25;
  }

  static double polygonPercentInside(Path selection, List<Offset> polygon) {
    int pointsInside = 0;
    for (final point in polygon) {
      if (selection.contains(point)) {
        pointsInside++;
      }
    }
    return pointsInside / polygon.length;
  }

  /// Taps at the given [position] to select the nearest stroke, image,
  /// or text region.
  ///
  /// [textRect] is the bounding rect of the text content on the page, or
  /// [Rect.zero] if there is no text.
  void tapSelect(
    Offset position,
    List<Stroke> strokes,
    List<EditorImage> images,
    int pageIndex, {
    Rect textRect = Rect.zero,
  }) {
    doneSelecting = true;

    // Check strokes first (most precise)
    if (stows.lassoSelectHandwriting.value) {
      for (final stroke in strokes) {
        if (_isPointNearStroke(position, stroke, tapRadius)) {
          selectResult = SelectResult(
            pageIndex: pageIndex,
            strokes: [stroke],
            images: [],
            path: _createTightSelectionPath(stroke.lowQualityPolygon),
          );
          return;
        }
      }
    }

    // Then check images
    if (stows.lassoSelectImages.value) {
      for (final image in images) {
        if (image.dstRect.contains(position)) {
          selectResult = SelectResult(
            pageIndex: pageIndex,
            strokes: [],
            images: [image],
            path: _createRectSelectionPath(image.dstRect),
          );
          return;
        }
      }
    }

    // Then check text region
    if (stows.lassoSelectText.value &&
        textRect != Rect.zero &&
        textRect.contains(position)) {
      selectResult = SelectResult(
        pageIndex: pageIndex,
        strokes: [],
        images: [],
        textSelected: true,
        path: _createRectSelectionPath(textRect),
      );
      return;
    }

    // Nothing found, clear selection
    unselect();
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final lengthSq = ab.dx * ab.dx + ab.dy * ab.dy;
    if (lengthSq < 0.0001) return (p - a).distance;
    final t = ((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / lengthSq;
    final clampedT = t.clamp(0.0, 1.0);
    final projection = Offset(a.dx + clampedT * ab.dx, a.dy + clampedT * ab.dy);
    return (p - projection).distance;
  }

  /// Returns true if [point] is within [radius] of any vertex
  /// or segment of [stroke].
  static bool _isPointNearStroke(Offset point, Stroke stroke, double radius) {
    if (stroke is ArrowStroke) {
      return _distanceToSegment(point, stroke.start, stroke.end) <= radius;
    }
    if (stroke is DimensionStroke) {
      final (unitDir, perp) = stroke.computeVectors();
      if (unitDir == Offset.zero) {
        return (point - stroke.start).distance <= radius;
      }
      final dimOffset = perp * stroke.offset;
      final dimStart = stroke.start + dimOffset;
      final dimEnd = stroke.end + dimOffset;
      if (_distanceToSegment(point, stroke.start, stroke.end) <= radius)
        return true;
      if (_distanceToSegment(point, dimStart, dimEnd) <= radius) return true;
      if (_distanceToSegment(point, stroke.start, dimStart) <= radius)
        return true;
      if (_distanceToSegment(point, stroke.end, dimEnd) <= radius) return true;
      if ((point - stroke.textPosition).distance <= radius + 10) return true;
      return false;
    }

    final polygon = stroke.lowQualityPolygon;
    if (polygon.isEmpty) return false;

    final sqrRadius = radius * radius;

    // Skip checking every few vertices for performance
    final int verticesToSkip = switch (polygon.length) {
      < 100 => 0,
      < 1000 => 1,
      _ => 2,
    };

    for (int i = 0; i < polygon.length; i += verticesToSkip + 1) {
      final dx = polygon[i].dx - point.dx;
      final dy = polygon[i].dy - point.dy;
      if (dx * dx + dy * dy <= sqrRadius) return true;
    }
    return false;
  }

  /// Creates a tight rounded-rect selection path around [polygon],
  /// inflated by a small margin so the selection boundary is visible.
  static Path createTightSelectionPath(List<Offset> polygon) {
    if (polygon.isEmpty) return Path();

    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;

    for (final point in polygon) {
      if (point.dx < minX) minX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy > maxY) maxY = point.dy;
    }

    final bounds = Rect.fromLTRB(minX, minY, maxX, maxY);
    return Path()..addRRect(
      RRect.fromRectAndRadius(bounds.inflate(8), const Radius.circular(4)),
    );
  }

  static Path _createTightSelectionPath(List<Offset> polygon) =>
      createTightSelectionPath(polygon);

  /// Creates a selection path around [rect], inflated by a small margin.
  static Path _createRectSelectionPath(Rect rect) {
    return Path()..addRRect(
      RRect.fromRectAndRadius(rect.inflate(8), const Radius.circular(4)),
    );
  }
}

class SelectResult {
  int pageIndex;
  final List<Stroke> strokes;
  final List<EditorImage> images;
  Path path;

  /// Whether the text content on the page is also selected.
  bool textSelected;

  SelectResult({
    required this.pageIndex,
    required this.strokes,
    required this.images,
    required this.path,
    this.textSelected = false,
  });

  bool get isEmpty {
    return strokes.isEmpty && images.isEmpty && !textSelected;
  }

  bool get isNotEmpty => !isEmpty;

  /// Returns endpoint vertex handles when a single drafting primitive is selected.
  List<Offset> get vertexHandles {
    if (strokes.length != 1) return const [];
    final stroke = strokes.first;
    if (stroke is ArrowStroke) {
      return [stroke.start, stroke.end];
    } else if (stroke is DimensionStroke) {
      return [stroke.start, stroke.end, stroke.textPosition];
    }
    return const [];
  }

  SelectResult copyWith({
    int? pageIndex,
    List<Stroke>? strokes,
    List<EditorImage>? images,
    Path? path,
    bool? textSelected,
  }) {
    return SelectResult(
      pageIndex: pageIndex ?? this.pageIndex,
      strokes: strokes ?? this.strokes,
      images: images ?? this.images,
      path: path ?? this.path,
      textSelected: textSelected ?? this.textSelected,
    );
  }
}

/// Extension on [EditorPage] providing vertex handles for drafting primitives.
extension EditorPageVertexHandlesExtension on EditorPage {
  static final _vertexHandlesExpando = Expando<List<Offset>>();

  List<Offset>? get selectionVertexHandles => _vertexHandlesExpando[this];
  set selectionVertexHandles(List<Offset>? handles) =>
      _vertexHandlesExpando[this] = handles;
}
