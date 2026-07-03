import 'package:flutter/material.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:sbn/tool_id.dart';

/// 🤖 Modified with DeepSeek v4 Flash
class Select extends Tool {
  Select._();

  static final _currentSelect = Select._();
  static Select get currentSelect => _currentSelect;

  /// The minimum ratio of points inside a stroke or image
  /// for it to be selected.
  static const minPercentInside = 0.7;

  /// The tap radius in pixels for hit-testing strokes on tap.
  static const double tapRadius = 15.0;

  var selectResult = SelectResult(
    pageIndex: -1,
    strokes: const [],
    images: const [],
    path: Path(),
  );
  var doneSelecting = false;

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
    selectResult.pageIndex = -1;
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
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromPoints(start, position),
          const Radius.circular(4),
        ));
    } else {
      // Lasso selection (freeform)
      selectResult.path.lineTo(position.dx, position.dy);
    }
  }

  /// Adds the indices of any [strokes] that are inside the selection area
  /// to [selectResult.indices].
  void onDragEnd(List<Stroke> strokes, List<EditorImage> images) {
    selectResult.path.close();
    doneSelecting = true;

    for (int i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      final percentInside = polygonPercentInside(
        selectResult.path,
        stroke.lowQualityPolygon,
      );
      if (percentInside > minPercentInside) {
        selectResult.strokes.add(stroke);
      }
    }

    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      final percentInside = rectPercentInside(selectResult.path, image.dstRect);
      if (percentInside >= minPercentInside) {
        selectResult.images.add(image);
      }
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

  /// Taps at the given [position] to select the nearest stroke or image.
  ///
  /// If the tap is within [tapRadius] pixels of any stroke vertex, that stroke
  /// is selected. Otherwise, if the tap is inside an image's [dstRect],
  /// that image is selected. If neither is found, the selection is cleared.
  void tapSelect(
    Offset position,
    List<Stroke> strokes,
    List<EditorImage> images,
    int pageIndex,
  ) {
    doneSelecting = true;

    // Check strokes first (more precise targeting)
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

    // Then check images
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

    // Nothing found, clear selection
    unselect();
  }

  /// Returns true if [point] is within [radius] of any vertex
  /// in [stroke]'s low-quality polygon.
  static bool _isPointNearStroke(
    Offset point,
    Stroke stroke,
    double radius,
  ) {
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
  static Path _createTightSelectionPath(List<Offset> polygon) {
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
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        bounds.inflate(8),
        const Radius.circular(4),
      ));
  }

  /// Creates a selection path around [rect], inflated by a small margin.
  static Path _createRectSelectionPath(Rect rect) {
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        rect.inflate(8),
        const Radius.circular(4),
      ));
  }
}

class SelectResult {
  int pageIndex;
  final List<Stroke> strokes;
  final List<EditorImage> images;
  Path path;

  SelectResult({
    required this.pageIndex,
    required this.strokes,
    required this.images,
    required this.path,
  });

  bool get isEmpty {
    return strokes.isEmpty && images.isEmpty;
  }

  SelectResult copyWith({
    int? pageIndex,
    List<Stroke>? strokes,
    List<EditorImage>? images,
    Path? path,
  }) {
    return SelectResult(
      pageIndex: pageIndex ?? this.pageIndex,
      strokes: strokes ?? this.strokes,
      images: images ?? this.images,
      path: path ?? this.path,
    );
  }
}
