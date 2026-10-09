/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/image/editor_image.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

// Paper Color Constants (PROJECT.md § Interface Contracts)
const paperColorPureWhite = Color(0xFFFFFFFF);
const paperColorCleanWhite = Color(0xFFFCFCFC);
const paperColorWarmCream = Color(0xFFFAF4E8);
const paperColorLegalPad = Color(0xFFFFF9B0);
const paperColorDarkSlate = Color(0xFF1E1E1E);

const standardPageSize = Size(1000, 1400);
const standardPageDef = HasSize(standardPageSize);

/// Test double for EditorImage to test lasso selection and rendering.
// ignore: missing_override_of_must_be_overridden
class E2ETestImage extends PngEditorImage {
  static final _assetCache = AssetCache();

  E2ETestImage({
    required super.dstRect,
    super.pageIndex = 0,
    Size pageSize = standardPageSize,
  }) : super(
         id: -1,
         extension: '.png',
         imageProvider: null,
         pageSize: pageSize,
         onMoveImage: null,
         onDeleteImage: null,
         onMiscChange: null,
         assetCache: _assetCache,
       );

  @override
  Future<void> firstLoad() async {}

  @override
  Future<void> loadIn() async {
    await super.loadIn();
  }

  @override
  Map<String, dynamic> toJson(OrderedAssetCache assets) {
    return {
      ...super.toJson(assets),
      'd': [dstRect.left, dstRect.top, dstRect.width, dstRect.height],
      'i': pageIndex,
    };
  }
}

/// Helper to create EditorCoreInfo with pages for testing.
EditorCoreInfo createTestCoreInfo({
  List<EditorPage>? pages,
  Color? backgroundColor,
  String filePath = 'test.sbn',
}) {
  final coreInfo = EditorCoreInfo(filePath: filePath);
  if (backgroundColor != null) coreInfo.backgroundColor = backgroundColor;
  if (pages != null) coreInfo.pages.addAll(pages);
  return coreInfo;
}

/// Factory to construct test strokes.
Stroke createTestStroke({
  int pageIndex = 0,
  HasSize page = standardPageDef,
  ToolId toolId = ToolId.fountainPen,
  Color color = Colors.black,
  List<Offset>? points,
  double size = 4.0,
}) {
  final stroke = Stroke(
    color: color,
    pressureEnabled: false,
    options: StrokeOptions(size: size),
    pageIndex: pageIndex,
    page: page,
    toolId: toolId,
  );
  final pts = points ?? [const Offset(100, 100), const Offset(120, 120)];
  for (final pt in pts) {
    stroke.addPoint(pt);
  }
  return stroke;
}

/// Factory to construct test highlighter strokes.
Stroke createHighlighterStroke({
  int pageIndex = 0,
  HasSize page = standardPageDef,
  Color color = const Color(0x66FFFF00),
  List<Offset>? points,
  double size = 20.0,
}) {
  return createTestStroke(
    pageIndex: pageIndex,
    page: page,
    toolId: ToolId.highlighter,
    color: color,
    points: points ?? [const Offset(50, 100), const Offset(250, 100)],
    size: size,
  );
}

/// Implementation of the Study Tape stroke contract specified in PROJECT.md.
/// Extends [Stroke] and encapsulates conceal/reveal state and BSON persistence.
class TapeStrokeContract extends Stroke {
  TapeStrokeContract({
    required super.color,
    required super.pageIndex,
    required super.page,
    required this.start,
    required this.end,
    this.tapeWidth = 32.0,
    this.isConcealed = true,
  }) : super(
         pressureEnabled: false,
         options: StrokeOptions(size: tapeWidth),
         toolId: ToolId.highlighter,
       ) {
    addPoint(start);
    addPoint(end);
  }

  final Offset start;
  final Offset end;
  final double tapeWidth;
  bool isConcealed;

  void toggleConceal() {
    isConcealed = !isConcealed;
  }

  /// Calculates the 4-corner polygon bounding box of the tape strip.
  List<Offset> getMaskPolygon() {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = sqrt(dx * dx + dy * dy);
    if (len < 0.001) {
      final half = tapeWidth / 2;
      return [
        Offset(start.dx - half, start.dy - half),
        Offset(start.dx + half, start.dy - half),
        Offset(start.dx + half, start.dy + half),
        Offset(start.dx - half, start.dy + half),
      ];
    }
    final nx = -dy / len * (tapeWidth / 2);
    final ny = dx / len * (tapeWidth / 2);
    return [
      Offset(start.dx + nx, start.dy + ny),
      Offset(end.dx + nx, end.dy + ny),
      Offset(end.dx - nx, end.dy - ny),
      Offset(start.dx - nx, start.dy - ny),
    ];
  }

  @override
  List<Offset> getPolygon({required StrokeQuality quality}) {
    return getMaskPolygon();
  }

  /// Hit test to check if tap coordinates fall inside the tape strip.
  bool containsPoint(Offset point) {
    final poly = getMaskPolygon();
    int crossings = 0;
    for (int i = 0; i < poly.length; i++) {
      final a = poly[i];
      final b = poly[(i + 1) % poly.length];
      if (((a.dy <= point.dy && point.dy < b.dy) ||
              (b.dy <= point.dy && point.dy < a.dy)) &&
          (point.dx <
              (b.dx - a.dx) * (point.dy - a.dy) / (b.dy - a.dy) + a.dx)) {
        crossings++;
      }
    }
    return (crossings % 2) != 0;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['shape'] = 'tape';
    json['c_state'] = isConcealed;
    json['tape_w'] = tapeWidth;
    json['sx'] = start.dx;
    json['sy'] = start.dy;
    json['ex'] = end.dx;
    json['ey'] = end.dy;
    return json;
  }

  static TapeStrokeContract fromJson(
    Map<String, dynamic> json, {
    required int pageIndex,
    required HasSize page,
  }) {
    final colorVal = json['c'];
    final int? colorInt = colorVal is int
        ? colorVal
        : (colorVal is num
              ? colorVal.toInt()
              : (colorVal != null ? int.tryParse(colorVal.toString()) : null));
    final color = colorInt != null ? Color(colorInt) : const Color(0xFFFFEB3B);
    final isConcealed = json['c_state'] as bool? ?? true;
    final tapeW = (json['tape_w'] as num?)?.toDouble() ?? 32.0;
    final sx = (json['sx'] as num?)?.toDouble() ?? 0.0;
    final sy = (json['sy'] as num?)?.toDouble() ?? 0.0;
    final ex = (json['ex'] as num?)?.toDouble() ?? 100.0;
    final ey = (json['ey'] as num?)?.toDouble() ?? 0.0;

    return TapeStrokeContract(
      color: color,
      pageIndex: pageIndex,
      page: page,
      start: Offset(sx, sy),
      end: Offset(ex, ey),
      tapeWidth: tapeW,
      isConcealed: isConcealed,
    );
  }
}

/// Helper methods for Page Grid and Document manipulation.
class E2EPageManagerHelper {
  /// Reorders pages and updates page indices.
  static void reorderPages(
    EditorCoreInfo coreInfo,
    int oldIndex,
    int newIndex,
  ) {
    if (oldIndex < 0 ||
        oldIndex >= coreInfo.pages.length ||
        newIndex < 0 ||
        newIndex >= coreInfo.pages.length) {
      return;
    }
    final page = coreInfo.pages.removeAt(oldIndex);
    coreInfo.pages.insert(newIndex, page);
    for (int i = 0; i < coreInfo.pages.length; i++) {
      coreInfo.pages[i].updatePageIndex(i);
    }
  }

  /// Deep duplicate page ensuring layers are copied without shared list references.
  static void duplicatePageDeep(EditorCoreInfo coreInfo, int pageIndex) {
    if (pageIndex < 0 || pageIndex >= coreInfo.pages.length) return;
    final original = coreInfo.pages[pageIndex];

    final newLayers = <Layer>[];
    for (final layer in original.layers) {
      final newStrokes = <Stroke>[];
      for (final s in layer.strokes) {
        final strokeCopy = Stroke(
          color: s.color,
          pressureEnabled: s.pressureEnabled,
          options: s.options,
          pageIndex: pageIndex + 1,
          page: s.page,
          toolId: s.toolId,
        );
        for (final pt in s.points) {
          strokeCopy.addPoint(pt);
        }
        newStrokes.add(strokeCopy);
      }
      newLayers.add(
        Layer(name: layer.name, strokes: newStrokes, visible: layer.visible),
      );
    }

    final newPage = EditorPage(
      size: original.size,
      bookmarked: original.bookmarked,
      layers: newLayers,
    );
    newPage.updatePageIndex(pageIndex + 1);
    coreInfo.pages.insert(pageIndex + 1, newPage);
    for (int i = 0; i < coreInfo.pages.length; i++) {
      coreInfo.pages[i].updatePageIndex(i);
    }
  }

  /// Deletes a page with single-page guard.
  static bool deletePageGuarded(EditorCoreInfo coreInfo, int pageIndex) {
    if (coreInfo.pages.length <= 1) return false;
    if (pageIndex < 0 || pageIndex >= coreInfo.pages.length) return false;
    coreInfo.pages.removeAt(pageIndex);
    for (int i = 0; i < coreInfo.pages.length; i++) {
      coreInfo.pages[i].updatePageIndex(i);
    }
    return true;
  }
}

/// Helper for Cornell Notes template geometry verification.
class CornellGeometryOracle {
  static const cueRatio = 0.28;
  static const summaryRatio = 0.75;

  static double getVerticalCueX(double width) => width * cueRatio;
  static double getHorizontalSummaryY(double height) => height * summaryRatio;

  static bool isDividingLine(Offset start, Offset end, Size pageSize) {
    final cueX = getVerticalCueX(pageSize.width);
    final sumY = getHorizontalSummaryY(pageSize.height);

    final isVerticalCue =
        (start.dx - cueX).abs() < 1.0 && (end.dx - cueX).abs() < 1.0;
    final isHorizontalSummary =
        (start.dy - sumY).abs() < 1.0 && (end.dy - sumY).abs() < 1.0;

    return isVerticalCue || isHorizontalSummary;
  }
}

/// Helper to reset test environment state cleanly.
void setupE2EEnvironment() {
  FlavorConfig.setup();
  stows.lassoSelectHandwriting.value = true;
  stows.lassoSelectImages.value = true;
  stows.lassoSelectText.value = true;
  Select.currentSelect.unselect();
}
