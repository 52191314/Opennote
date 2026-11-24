/// 🤖 Generated wholely or partially with Google Antigravity
part of 'editor.dart';

extension EditorSelectionActions on EditorState {
  /// Updates selection handles (rotation, resize, and vertex handles) on [page]
  /// to match [select.selectResult].
  void _updateSelectionHandles(EditorPage page, Select select) =>
      page.showSelectionHandles(select);

  void _deleteSelection(Select select, EditorPage page) {
    final strokes = List<Stroke>.from(select.selectResult.strokes);
    final images = List<EditorImage>.from(select.selectResult.images);

    for (final stroke in strokes) {
      page.removeStroke(stroke);
    }
    for (final image in images) {
      page.images.remove(image);
    }
    if (select.selectResult.textSelected &&
        !page.quill.controller.document.isEmpty()) {
      page.quill.controller.clear();
    }

    page.clearSelectionHandles();
    select.unselect();
    page.redrawStrokes();

    history.recordChange(
      EditorHistoryItem(
        type: .erase,
        pageIndex: strokes.firstOrNull?.pageIndex ?? 0,
        strokes: strokes,
        images: images,
      ),
    );
    autosaveAfterDelay();
    _refreshUi();
  }

  void _onCircleToSelectDetected(Path path) {
    if (!mounted || dragPageIndex == null) return;
    final page = coreInfo.pages[dragPageIndex!];

    // Discard the pen stroke currently being drawn
    if (currentTool is Pen) {
      (currentTool as Pen).onDragEnd();
    }
    _activeStrokeNotifier.value = null;

    HapticFeedback.mediumImpact();

    final textRect = page.computeTextContentRect(
      coreInfo.lineHeight.toDouble(),
    );

    Select.currentSelect.selectFromPath(
      path: path,
      strokes: page.activeLayerStrokes,
      images: page.images,
      pageIndex: dragPageIndex!,
      textRect: textRect,
    );

    currentTool = Select.currentSelect;
    _updateSelectionHandles(page, Select.currentSelect);

    page.redrawStrokes();
    _refreshUi();
  }

  bool get currentPageHasTape {
    final idx = currentPageIndex;
    if (idx >= coreInfo.pages.length) return false;
    return coreInfo.pages[idx].strokes.any((s) => s is TapeStroke);
  }

  void _revealAllTapeOnCurrentPage() {
    final idx = currentPageIndex;
    if (idx >= coreInfo.pages.length) return;
    final page = coreInfo.pages[idx];
    var hasTape = false;
    for (final s in page.strokes) {
      if (s is TapeStroke) {
        s.isConcealed = false;
        hasTape = true;
      }
    }
    if (hasTape) HapticFeedback.mediumImpact();
    page.redrawStrokes();
    autosaveAfterDelay();
    _refreshUi();
  }

  void _concealAllTapeOnCurrentPage() {
    final idx = currentPageIndex;
    if (idx >= coreInfo.pages.length) return;
    final page = coreInfo.pages[idx];
    var hasTape = false;
    for (final s in page.strokes) {
      if (s is TapeStroke) {
        s.isConcealed = true;
        hasTape = true;
      }
    }
    if (hasTape) HapticFeedback.mediumImpact();
    page.redrawStrokes();
    autosaveAfterDelay();
    _refreshUi();
  }

  void _copySelection() {
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    _refreshUi(() {
      _clipboard = SelectionClipboard.copyOf(select.selectResult);
    });
  }

  void _duplicateSelection() {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;

    _refreshUi(() {
      final pageIndex = select.selectResult.pageIndex;
      const duplicationFeedbackOffset = Offset(25, -25);

      final duplicated = SelectionClipboard.copyOf(select.selectResult)
          .pasteOnto(
            coreInfo.pages[pageIndex],
            pageIndex: pageIndex,
            takeImageId: () => coreInfo.nextImageId++,
            offset: duplicationFeedbackOffset,
          );

      select.selectResult = select.selectResult.copyWith(
        strokes: duplicated.strokes,
        images: duplicated.images,
        path: select.selectResult.path.shift(duplicationFeedbackOffset),
      );

      coreInfo.pages[pageIndex].placeSelectionHandles(select.selectResult);
      history.recordChange(duplicated);
      autosaveAfterDelay();
    });
  }

  void _cutSelection() {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final page = coreInfo.pages[select.selectResult.pageIndex];
    _refreshUi(() {
      _copySelection();
      _deleteSelection(select, page);
    });
  }

  void _setSelectionColor(Color color) {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final strokes = select.selectResult.strokes;
    if (strokes.isEmpty) return;
    final page = coreInfo.pages[select.selectResult.pageIndex];

    _refreshUi(() {
      updateColorBar(color);

      final colorChange = <Stroke, Change<Color>>{};
      for (final stroke in strokes) {
        colorChange[stroke] = Change(previous: stroke.color, current: color);
        stroke.color = color;
      }

      page.redrawStrokes();
      history.recordChange(
        EditorHistoryItem(
          type: .changeColor,
          pageIndex: strokes.first.pageIndex,
          strokes: strokes,
          colorChange: colorChange,
          images: [],
        ),
      );
      autosaveAfterDelay();
    });
  }

  void _bringSelectionToFront() {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final page = coreInfo.pages[select.selectResult.pageIndex];
    final strokes = select.selectResult.strokes;
    final images = select.selectResult.images;
    if (strokes.isEmpty && images.isEmpty) return;

    _refreshUi(() {
      if (strokes.isNotEmpty) {
        page.activeLayerStrokes.removeWhere((s) => strokes.contains(s));
        page.activeLayerStrokes.addAll(strokes);
      }
      if (images.isNotEmpty) {
        page.images.removeWhere((img) => images.contains(img));
        page.images.addAll(images);
      }
      page.redrawStrokes();
      autosaveAfterDelay();
    });
  }

  void _sendSelectionToBack() {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final page = coreInfo.pages[select.selectResult.pageIndex];
    final strokes = select.selectResult.strokes;
    final images = select.selectResult.images;
    if (strokes.isEmpty && images.isEmpty) return;

    _refreshUi(() {
      if (strokes.isNotEmpty) {
        page.activeLayerStrokes.removeWhere((s) => strokes.contains(s));
        page.activeLayerStrokes.insertAll(0, strokes);
      }
      if (images.isNotEmpty) {
        page.images.removeWhere((img) => images.contains(img));
        page.images.insertAll(0, images);
      }
      page.redrawStrokes();
      autosaveAfterDelay();
    });
  }

  void _smoothenSelection() {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final page = coreInfo.pages[select.selectResult.pageIndex];
    final strokes = select.selectResult.strokes;
    if (strokes.isEmpty) return;

    _refreshUi(() {
      for (final stroke in strokes) {
        stroke.smoothen(iterations: 2);
      }
      page.redrawStrokes();
      autosaveAfterDelay();
    });
  }

  void _addToElements() {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final strokes = select.selectResult.strokes;
    if (strokes.isEmpty) return;

    final controller = TextEditingController(
      text: t.editor.elements.defaultName(
        n: ElementsManager.instance.items.length + 1,
      ),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.editor.elements.add),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: t.editor.elements.nameLabel,
            hintText: t.editor.elements.nameHint,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim().isNotEmpty
                  ? controller.text.trim()
                  : 'Element';
              ElementsManager.instance.addElement(
                name: name,
                strokes: strokes,
                category: 'My Elements',
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.editor.elements.added(name: name)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(t.editor.actions.save),
          ),
        ],
      ),
    );
  }

  void _toggleSelectionResize() {
    _refreshUi(() {
      Select.currentSelect.isResizeActive =
          !Select.currentSelect.isResizeActive;
    });
  }

  void _scaleSelectionSize(double factor) {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting || select.selectResult.isEmpty) return;

    final pageIndex = select.selectResult.pageIndex;
    if (pageIndex < 0 || pageIndex >= coreInfo.pages.length) return;
    final page = coreInfo.pages[pageIndex];

    final selection = select.selectResult;
    final bounds = selection.path.getBounds();
    if (bounds.isEmpty || bounds.width <= 0 || bounds.height <= 0) return;
    final center = bounds.center;

    _refreshUi(() {
      final transform = SelectionTransform.begin(page, selection);

      for (final stroke in selection.strokes) {
        stroke.scaleAround(factor, factor, center);
      }

      for (final image in selection.images) {
        final rect = image.dstRect;
        image.dstRect = Rect.fromCenter(
          center: center + (rect.center - center) * factor,
          width: rect.width * factor,
          height: rect.height * factor,
        );
      }

      if (selection.textSelected) {
        page.textContentOffset =
            center + (page.textContentOffset - center) * factor;
        page.textContentScale = (page.textContentScale * factor).clamp(
          0.2,
          5.0,
        );
      }

      selection.path = scalePathAround(selection.path, factor, factor, center);
      page.placeSelectionHandles(selection);
      page.redrawStrokes();
      history.recordChange(transform.finish(pageIndex: pageIndex));
      autosaveAfterDelay();
    });
  }

  void _reduceSelectionSize() => _scaleSelectionSize(0.85);
  void _enlargeSelectionSize() => _scaleSelectionSize(1.18);

  Future<void> _takeSelectionScreenshot() async {
    if (currentTool is! Select) return;
    final select = currentTool as Select;
    if (!select.doneSelecting || select.selectResult.isEmpty) return;

    final page = coreInfo.pages[select.selectResult.pageIndex];
    final bounds = select.selectResult.path.getBounds();
    if (bounds.isEmpty || bounds.width <= 0 || bounds.height <= 0) return;

    final renderBounds = bounds.inflate(14.0);
    final width = renderBounds.width.ceil().toDouble();
    final height = renderBounds.height.ceil().toDouble();

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Draw background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Translate coordinate system
    canvas.translate(-renderBounds.left, -renderBounds.top);

    final painter = CanvasPainter(
      page: page,
      strokes: select.selectResult.strokes,
      laserStrokes: const [],
      currentStroke: null,
      currentSelection: null,
      isDoneSelecting: true,
      primaryColor: Theme.of(context).colorScheme.primary,
      showPageIndicator: false,
      pageIndex: select.selectResult.pageIndex,
      totalPages: coreInfo.pages.length,
      currentScale: 1.0,
      defaultTextStyle:
          Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
      invert: false,
    );
    painter.paint(canvas, Size(renderBounds.right, renderBounds.bottom));

    final picture = recorder.endRecording();
    const scale = 2.0;
    final uiImage = await picture.toImage(
      (width * scale).toInt(),
      (height * scale).toInt(),
    );
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final bytes = byteData.buffer.asUint8List();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => LassoScreenshotDialog(
        imageBytes: bytes,
        onCopied: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.editor.lasso.screenshotCopied),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  /// Whether the current selection has exactly one image and no strokes,
  /// which makes the crop button available.
  bool get _cropPossible {
    if (currentTool is! Select) return false;
    final select = currentTool as Select;
    if (!select.doneSelecting) return false;
    return select.selectResult.images.length == 1 &&
        select.selectResult.strokes.isEmpty;
  }

  /// Whether crop mode is currently active on the single selected image.
  bool get _cropActive {
    if (!_cropPossible) return false;
    return (currentTool as Select).selectResult.images.first.cropMode;
  }

  /// Toggles crop mode on the single selected image.
  void _toggleCrop() {
    if (!_cropPossible) return;
    final select = currentTool as Select;
    final image = select.selectResult.images.first;
    _refreshUi(() {
      image.cropMode = !image.cropMode;
    });
  }

  void _pasteSelection() {
    final clipboard = _clipboard;
    if (clipboard == null || clipboard.isEmpty) return;
    _refreshUi(() {
      final pageIndex = dragPageIndex ?? currentPageIndex;
      history.recordChange(
        clipboard.pasteOnto(
          coreInfo.pages[pageIndex],
          pageIndex: pageIndex,
          takeImageId: () => coreInfo.nextImageId++,
        ),
      );
      autosaveAfterDelay();
    });
  }

  void _deleteCurrentSelection() {
    final select = currentTool as Select;
    if (!select.doneSelecting) return;
    final page = coreInfo.pages[select.selectResult.pageIndex];
    _refreshUi(() => _deleteSelection(select, page));
  }
}
