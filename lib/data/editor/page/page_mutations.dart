/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
/// 🤖 Modified with Grok 4.7
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
part of '../page.dart';

/// Stroke, layer, cache, page-index, and cloning members for [EditorPage].
mixin _EditorPageMutations {
  EditorPage get _page => this as EditorPage;

  /// All strokes from all visible layers, flattened for rendering.
  List<Stroke> get strokes {
    if (_page.layers.length == 1) {
      return _page.layers.first.visible ? _page.layers.first.strokes : const [];
    }
    return [
      for (final layer in _page.layers)
        if (layer.visible) ...layer.strokes,
    ];
  }

  /// Strokes in the currently active layer (for mutation).
  List<Stroke> get activeLayerStrokes => activeLayer.strokes;

  /// The currently active layer instance, creating a default layer if empty.
  Layer get activeLayer {
    if (_page.layers.isEmpty) {
      _page.layers.add(Layer(name: 'Default'));
    }
    return _page.layers[_page.activeLayerIndex.clamp(
      0,
      _page.layers.length - 1,
    )];
  }

  /// Disposes and clears any cached static stroke [Picture]s on this page.
  ///
  /// When called mid-frame, disposal is deferred until after the frame completes
  /// so in-flight GPU display lists remain valid on the raster thread.
  void invalidateStrokePictureCache({bool immediate = false}) {
    final oldHl = _page.cachedHighlighterPicture;
    final oldNonHl = _page.cachedNonHighlighterPicture;
    _page.cachedHighlighterPicture = null;
    _page.cachedNonHighlighterPicture = null;
    _page.strokePictureCacheKey = null;

    if (oldHl == null && oldNonHl == null) return;

    if (!immediate) {
      try {
        final scheduler = SchedulerBinding.instance;
        if (scheduler.schedulerPhase != SchedulerPhase.idle) {
          scheduler.addPostFrameCallback((_) {
            oldHl?.dispose();
            oldNonHl?.dispose();
          });
          return;
        }
      } on Object {
        // Binding not initialized in pure unit tests; dispose immediately.
      }
    }
    oldHl?.dispose();
    oldNonHl?.dispose();
  }

  /// Removes a stroke from whichever unlocked layer contains it.
  /// Returns `true` if the stroke was found and removed.
  bool removeStroke(Stroke stroke) {
    for (final layer in _page.layers) {
      if (layer.locked) continue;
      if (layer.strokes.remove(stroke)) {
        _page.strokesVersion++;
        invalidateStrokePictureCache();
        return true;
      }
    }
    return false;
  }

  /// Swaps [oldStroke] for [newStroke], keeping its layer and stacking order.
  /// Returns `false` if [oldStroke] isn't on this page.
  bool replaceStroke(Stroke oldStroke, Stroke newStroke) {
    for (final layer in _page.layers) {
      final index = layer.strokes.indexOf(oldStroke);
      if (index == -1) continue;
      layer.strokes[index] = newStroke;
      _page.strokesVersion++;
      invalidateStrokePictureCache();
      return true;
    }
    return false;
  }

  /// Inserts [newStroke] into the active layer, keeping strokes sorted by
  /// pen type and highlighter color.
  void insertStroke(Stroke newStroke) {
    if (_page.layers.isEmpty) {
      _page.layers.add(Layer(name: 'Default'));
    }
    final layer =
        _page.layers[_page.activeLayerIndex.clamp(0, _page.layers.length - 1)];
    if (layer.locked) return;

    final newStrokeColor = newStroke.color.toARGB32();
    int index = 0;
    for (final stroke in layer.strokes) {
      final penTypeComparison = stroke.toolId.id.compareTo(newStroke.toolId.id);
      final color = stroke.color.toARGB32();
      if (penTypeComparison > 0) {
        break;
      }
      if (stroke.toolId == .highlighter &&
          penTypeComparison == 0 &&
          color > newStrokeColor) {
        break;
      }
      index++;
    }

    layer.strokes.insert(index, newStroke);
    _page.strokesVersion++;
    invalidateStrokePictureCache();
  }

  /// Sorts the strokes in each layer by pen type and highlighter color.
  void sortStrokes() {
    for (final layer in _page.layers) {
      layer.strokes.sort((Stroke a, Stroke b) {
        final penTypeComparison = a.toolId.id.compareTo(b.toolId.id);
        if (penTypeComparison != 0) return penTypeComparison;
        if (a.toolId != .highlighter) return 0;
        return a.color.toARGB32().compareTo(b.color.toARGB32());
      });
    }
    _page.strokesVersion++;
    invalidateStrokePictureCache();
  }

  /// Updates the `pageIndex` fields of this page's strokes and images.
  void updatePageIndex(int pageIndex) {
    for (final layer in _page.layers) {
      for (final stroke in layer.strokes) {
        stroke.pageIndex = pageIndex;
      }
    }
    for (final stroke in _page.laserStrokes) {
      stroke.pageIndex = pageIndex;
    }
    for (final image in _page.images) {
      image.pageIndex = pageIndex;
    }
    _page.backgroundImage?.pageIndex = pageIndex;
  }

  /// Returns a copy of this page with the provided fields overridden.
  EditorPage copyWith({
    Size? size,
    List<Stroke>? strokes,
    List<Layer>? layers,
    List<EditorImage>? images,
    QuillStruct? quill,
    EditorImage? backgroundImage,
    int? activeLayerIndex,
    bool? bookmarked,
    CanvasBackgroundPattern? paperPattern,
    Color? paperColor,
    int? paperLineHeight,
    int? paperLineThickness,
    Offset? textContentOffset,
    double? textContentRotation,
    double? textContentScale,
  }) => EditorPage(
    size: size ?? _page.size,
    strokes: strokes,
    layers: layers ?? _page.layers,
    images: images ?? _page.images,
    quill: quill ?? _page.quill,
    backgroundImage: backgroundImage ?? _page.backgroundImage,
    activeLayerIndex: activeLayerIndex ?? _page.activeLayerIndex,
    bookmarked: bookmarked ?? _page.bookmarked,
    paperPattern: paperPattern ?? _page.paperPattern,
    paperColor: paperColor ?? _page.paperColor,
    paperLineHeight: paperLineHeight ?? _page.paperLineHeight,
    paperLineThickness: paperLineThickness ?? _page.paperLineThickness,
    textContentOffset: textContentOffset ?? _page.textContentOffset,
    textContentRotation: textContentRotation ?? _page.textContentRotation,
    textContentScale: textContentScale ?? _page.textContentScale,
  );

  /// Clones this page for use in a screenshot.
  ///
  /// Avoids bugs caused by the quill editor being attached to multiple
  /// contexts, and filters out strokes that shouldn't be rasterized.
  ///
  /// Make sure to call [EditorPage.disposeClonedData] on the returned page
  /// when you're done with it.
  EditorPage cloneForRasterization({bool rasterizeAllStrokes = false}) {
    return copyWith(
      layers: _page.layers
          .map(
            (layer) => Layer(
              name: layer.name,
              visible: layer.visible,
              locked: layer.locked,
              strokes: rasterizeAllStrokes
                  ? layer.strokes
                  : layer.strokes
                        .where(EditorExporter.shouldRasterizeStroke)
                        .toList(),
            ),
          )
          .toList(),
      quill: _page.quill.cloneForScreenshot(),
    );
  }
}
