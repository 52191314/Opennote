/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Sonnet 5.5)
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:one_dollar_unistroke_recognizer/one_dollar_unistroke_recognizer.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/stroke/stroke_geometry.dart';
import 'package:saber/components/canvas/stroke/stroke_path_builder.dart'
    as path_builder;
import 'package:saber/components/canvas/stroke/stroke_serialization.dart';
import 'package:saber/components/canvas/stroke/stroke_simplifier.dart';
import 'package:saber/components/canvas/stroke/stroke_snapping.dart'
    as snapping;
import 'package:saber/data/extensions/list_extensions.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

/// The rendering style of a stroke's outline.
enum LineStyle {
  solid,
  dashed,
  dotted;

  static const defaultStyle = LineStyle.solid;
}

/// A freehand or geometric ink stroke belonging to a canvas page.
class Stroke {
  static final log = Logger('Stroke');

  @visibleForTesting
  @protected
  final List<PointVector> points = [];

  bool get isEmpty => points.isEmpty;
  int get length => points.length;

  /// Read-only view of points defining the stroke trajectory.
  List<PointVector> get rawPoints => points;

  /// The first point of the stroke, or null if empty.
  Offset? get firstPoint =>
      points.isNotEmpty ? Offset(points.first.x, points.first.y) : null;

  /// The last point of the stroke, or null if empty.
  Offset? get lastPoint =>
      points.isNotEmpty ? Offset(points.last.x, points.last.y) : null;

  Path? _centerlinePath;

  /// Returns a cached path along the center line of the stroke points.
  Path get centerlinePath =>
      _centerlinePath ??= path_builder.buildCenterlinePath(points);

  Rect? _boundingBox;

  /// Returns the axis-aligned bounding box of this stroke in page coordinates.
  Rect get boundingBox {
    final shapeBounds = computeShapeBoundingBox(this);
    if (shapeBounds != null) return shapeBounds;
    return _boundingBox ??= computePointsBoundingBox(points, options.size);
  }

  int pageIndex;
  HasSize page;
  final ToolId toolId;

  static const defaultColor = Colors.black;
  static const defaultPressureEnabled = true;

  Color color;
  bool pressureEnabled;
  final StrokeOptions options;

  /// Optional fill color for shape strokes (e.g. circles, rectangles).
  /// If null, the shape is not filled (outline only).
  Color? fillColor;

  /// The line style for this stroke (solid, dashed, dotted).
  LineStyle lineStyle;

  var _geometryRevision = 0;

  /// Monotonic counter incremented when this stroke's geometry is mutated.
  int get geometryRevision => _geometryRevision;

  /// Fast state fingerprint covering in-place mutations to this stroke.
  int get renderSignature =>
      computeStrokeRenderSignature(this, _geometryRevision);

  List<Offset>? _lowQualityPolygon, _highQualityPolygon;
  List<Offset> get lowQualityPolygon =>
      _lowQualityPolygon ??= getPolygon(quality: .low);
  List<Offset> get highQualityPolygon =>
      _highQualityPolygon ??= getPolygon(quality: .high);

  Path? _lowQualityPath, _highQualityPath;

  /// Whether [highQualityPath] has already been computed and cached.
  bool get hasCachedHighQualityPath => _highQualityPath != null;

  Path get lowQualityPath =>
      _lowQualityPath ??= getPath(lowQualityPolygon, smooth: true);
  Path get highQualityPath => _highQualityPath ??= getPath(highQualityPolygon);

  Path? _styledPath;
  LineStyle? _styledPathLineStyle;
  double? _styledPathSize;

  double get _safeStyledStrokeWidth =>
      options.size > 0 && options.size.isFinite ? options.size : 1.0;

  /// Returns a cached dashed or dotted [Path] for [lineStyle], or
  /// [highQualityPath] when [lineStyle] is [LineStyle.solid].
  Path get styledPath {
    if (lineStyle == LineStyle.solid) return highQualityPath;
    final safeSize = _safeStyledStrokeWidth;
    if (_styledPath != null &&
        _styledPathLineStyle == lineStyle &&
        _styledPathSize == safeSize) {
      return _styledPath!;
    }
    _styledPathLineStyle = lineStyle;
    _styledPathSize = safeSize;
    return _styledPath = path_builder.buildStyledPath(
      centerlinePath,
      lineStyle,
      safeSize,
    );
  }

  /// Translates all points and cached geometry by [offset].
  void shift(Offset offset) {
    if (offset == .zero) return;

    _geometryRevision++;
    points.shift(offset);
    _lowQualityPolygon?.shift(offset);
    _highQualityPolygon?.shift(offset);
    _lowQualityPath = _lowQualityPath?.shift(offset);
    _highQualityPath = _highQualityPath?.shift(offset);
    _centerlinePath = _centerlinePath?.shift(offset);
    if (_styledPath != null &&
        _styledPathLineStyle == lineStyle &&
        _styledPathSize == _safeStyledStrokeWidth) {
      _styledPath = _styledPath!.shift(offset);
    } else {
      _styledPath = null;
    }
    _boundingBox = _boundingBox?.shift(offset);
  }

  /// Rotates all vertices by [angleRadians] radians around [center].
  void rotateAround(double angleRadians, Offset center) {
    if (angleRadians == 0) return;

    _geometryRevision++;
    rotatePointVectors(points, angleRadians, center);
    if (_lowQualityPolygon != null) {
      rotateOffsets(_lowQualityPolygon!, angleRadians, center);
    }
    if (_highQualityPolygon != null) {
      rotateOffsets(_highQualityPolygon!, angleRadians, center);
    }

    _lowQualityPath = _lowQualityPolygon != null
        ? getPath(_lowQualityPolygon!, smooth: true)
        : null;
    _highQualityPath = _highQualityPolygon != null
        ? getPath(_highQualityPolygon!)
        : null;
    _centerlinePath = null;
    _styledPath = null;
    _boundingBox = null;
  }

  /// Scales all vertices by [scaleX]/[scaleY] around [pivot].
  void scaleAround(double scaleX, double scaleY, Offset pivot) {
    if (scaleX == 1 && scaleY == 1) return;

    _geometryRevision++;
    scalePointVectors(points, scaleX, scaleY, pivot);
    if (_lowQualityPolygon != null) {
      scaleOffsets(_lowQualityPolygon!, scaleX, scaleY, pivot);
    }
    if (_highQualityPolygon != null) {
      scaleOffsets(_highQualityPolygon!, scaleX, scaleY, pivot);
    }

    _lowQualityPath = _lowQualityPolygon != null
        ? getPath(_lowQualityPolygon!, smooth: false)
        : null;
    _highQualityPath = _highQualityPolygon != null
        ? getPath(_highQualityPolygon!)
        : null;
    _centerlinePath = null;
    _styledPath = null;
    _boundingBox = null;
  }

  /// Invalidates all cached polygons, paths, and bounds.
  void markPolygonNeedsUpdating() {
    _geometryRevision++;
    _lowQualityPolygon = null;
    _highQualityPolygon = null;
    _lowQualityPath = null;
    _highQualityPath = null;
    _centerlinePath = null;
    _styledPath = null;
    _boundingBox = null;
  }

  Stroke({
    required this.color,
    required this.pressureEnabled,
    required this.options,
    required this.pageIndex,
    required this.page,
    required this.toolId,
    this.fillColor,
    this.lineStyle = LineStyle.solid,
  });

  factory Stroke.fromJson(
    Map<String, dynamic> json, {
    required int fileVersion,
    required int pageIndex,
    required HasSize page,
  }) => parseStrokeFromJson(
    json,
    fileVersion: fileVersion,
    pageIndex: pageIndex,
    page: page,
    log: log,
  );

  /// Serializes this stroke into a JSON/BSON map.
  Map<String, dynamic> toJson() => serializeStrokeToJson(this);

  /// Appends [point] with optional [pressure] and invalidates cached geometry.
  void addPoint(Offset point, [double? pressure]) {
    if (!pressureEnabled) {
      pressure = null;
    } else if (pressure != null) {
      options.simulatePressure = false;
    }

    points.add(PointVector(point.dx, point.dy, pressure));
    markPolygonNeedsUpdating();
  }

  /// Appends all [points] to this stroke.
  void addPoints(List<Offset> points) {
    for (final point in points) {
      addPoint(point);
    }
  }

  /// Removes the first point of this stroke and invalidates cached geometry.
  void popFirstPoint() {
    points.removeAt(0);
    markPolygonNeedsUpdating();
  }

  /// Removes points that are too close together.
  ///
  /// This function is idempotent and does not invalidate cached polygons.
  void optimisePoints({
    double thresholdMultiplier = defaultOptimisePointsThreshold,
  }) => optimiseStrokePoints(
    points,
    options.size,
    thresholdMultiplier: thresholdMultiplier,
  );

  @protected
  List<Offset> getPolygon({required StrokeQuality quality}) =>
      path_builder.buildStrokePolygon(
        points: points,
        options: options,
        quality: quality,
        pressureEnabled: pressureEnabled,
        lowQualityTolerance: lowQualityTolerance,
        onSimulatedPressureApplied: optimisePoints,
      );

  /// Returns a [Path] that represents the stroke.
  ///
  /// If [smooth] is true, and the polygon has at least 3 points,
  /// the path will be a smooth curve between the points in [polygon].
  ///
  /// Otherwise, the path will use straight lines between each point
  /// in [polygon] for performance.
  @protected
  Path getPath(List<Offset> polygon, {bool smooth = true}) =>
      path_builder.buildPathFromPolygon(polygon, smooth: smooth);

  static const _lowQualityToleranceRatio = 0.1;
  static const _lowQualityMinTolerance = 1.0;

  /// The maximum distance that [simplifyPoints] may move this stroke
  /// when building the low quality polygon.
  double get lowQualityTolerance =>
      max(options.size * _lowQualityToleranceRatio, _lowQualityMinTolerance);

  /// Returns a subset of [points] that stays within [tolerance] of every
  /// dropped point (the Ramer–Douglas–Peucker algorithm).
  static List<PointVector> simplifyPoints(
    List<PointVector> points,
    double tolerance, {
    double pressureScale = 0,
  }) => simplifyStrokePoints(points, tolerance, pressureScale: pressureScale);

  /// Builds a smooth closed quadratic-bezier [Path] from [polygon].
  static Path smoothPathFromPolygon(List<Offset> polygon) =>
      path_builder.smoothPathFromPolygon(polygon);

  /// Converts [highQualityPolygon] to an SVG path string.
  String toSvgPath() =>
      path_builder.strokePolygonToSvgPath(highQualityPolygon, page.size.height);

  /// The maximum Y coordinate among raw points, or 0 if empty.
  double get maxY =>
      points.isEmpty ? 0 : points.map((point) => point.y).reduce(max);

  /// Recognizes a unistroke shape from this stroke's points.
  RecognizedUnistroke? detectShape() => detectStrokeShape(points);

  /// Uses the one_dollar_unistroke_recognizer package to recognize straight
  /// lines sufficiently long relative to [options.size].
  bool isStraightLine([int minLength = 5]) =>
      isStrokeStraightLine(points, options.size, minLength);

  /// Replaces the points in this stroke with a straight line, snapping close
  /// horizontal or vertical lines to the exact axis.
  void convertToLine() {
    assert(points.length >= 2);

    final pressure = points.map((point) => point.pressure ?? 0.5).average;
    var firstPoint = PointVector.fromOffset(
      offset: points.first,
      pressure: pressure,
    );
    var lastPoint = PointVector.fromOffset(
      offset: points.last,
      pressure: pressure,
    );

    (firstPoint, lastPoint) = snapLine(firstPoint, lastPoint);

    points
      ..clear()
      ..add(firstPoint)
      ..add(lastPoint)
      ..add(lastPoint);
    options.isComplete = true;
    options.start.taperEnabled = false;
    options.end.taperEnabled = false;
    markPolygonNeedsUpdating();
  }

  /// Sets this stroke to a straight line segment from [start] to [end].
  void setStraightLine(Offset start, Offset end) {
    points
      ..clear()
      ..add(PointVector(start.dx, start.dy, 0.5))
      ..add(PointVector(end.dx, end.dy, 0.5))
      ..add(PointVector(end.dx, end.dy, 0.5));
    markPolygonNeedsUpdating();
  }

  /// Applies Laplacian smoothing to the raw points of this stroke to beautify
  /// handwriting.
  void smoothen({int iterations = 2}) {
    if (points.length < 4) return;
    smoothenStrokePoints(points, iterations: iterations);
    markPolygonNeedsUpdating();
  }

  /// Snaps a [point] to the nearest Cartesian grid intersection with [gridSize].
  static Offset snapPointToGrid(Offset point, double gridSize) =>
      snapping.snapPointToGrid(point, gridSize);

  /// Snaps a [point] to the nearest vertex on an isometric triangular grid
  /// with vertical spacing [lineHeight].
  static Offset snapPointToIsometricGrid(Offset point, double lineHeight) =>
      snapping.snapPointToIsometricGrid(point, lineHeight);

  /// The 6 isometric grid directions (±30°, ±90°, ±150°) in radians.
  static const List<double> isometricAnglesRad = snapping.isometricAnglesRad;

  /// Snaps a line to horizontal/vertical, [angleStepDegrees], or isometric axes.
  static (PointVector firstPoint, PointVector lastPoint) snapLine(
    PointVector firstPoint,
    PointVector lastPoint, {
    double? angleStepDegrees,
    bool isIsometric = false,
  }) => snapping.snapStrokeLine(
    firstPoint,
    lastPoint,
    angleStepDegrees: angleStepDegrees,
    isIsometric: isIsometric,
  );

  /// Applies angle snap to the existing points in this line stroke.
  void snapToAngle(double stepDegrees, {bool isIsometric = false}) {
    if (points.length < 2) return;
    final first = points.first;
    final last = points.last;
    final (_, snappedLast) = snapLineToAngle(
      first,
      last,
      stepDegrees,
      isIsometric: isIsometric,
    );
    points
      ..clear()
      ..add(first)
      ..add(snappedLast)
      ..add(snappedLast);
    markPolygonNeedsUpdating();
  }

  /// Snaps a line to the nearest multiple of [stepDegrees] or isometric axes.
  static (PointVector firstPoint, PointVector lastPoint) snapLineToAngle(
    PointVector firstPoint,
    PointVector lastPoint,
    double stepDegrees, {
    bool isIsometric = false,
  }) => snapping.snapStrokeLineToAngle(
    firstPoint,
    lastPoint,
    stepDegrees,
    isIsometric: isIsometric,
  );

  /// Returns a deep copy of this stroke.
  Stroke copy() => Stroke(
    color: color,
    pressureEnabled: pressureEnabled,
    options: options.copyWith(),
    pageIndex: pageIndex,
    page: page,
    toolId: toolId,
    fillColor: fillColor,
    lineStyle: lineStyle,
  )..points.addAll(points);
}

/// Quality level used when generating stroke outline polygons.
enum StrokeQuality {
  low(4),
  high(1);

  const StrokeQuality(this.N);

  /// We use every Nth point for this quality level.
  final int N;
}
