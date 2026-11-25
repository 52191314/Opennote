/// 🤖 Generated wholely or partially with Google Antigravity
part of 'editor.dart';

int _getPageIndexFromScrollPosition({
  required double scrollY,
  required double screenWidth,
  required List<EditorPage> pages,
}) {
  if (pages.isEmpty) return 0;
  for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
    final bottomOfPage = CanvasGestureDetector.getTopOfPage(
      pageIndex: pageIndex + 1, // top of next page
      pages: pages,
      screenWidth: screenWidth,
    );

    if (scrollY < bottomOfPage) {
      return pageIndex;
    }
  }
  // below the last page
  return pages.length - 1;
}

extension EditorPageManagement on EditorState {
  /// Asks which paper to use, then inserts that page after the current one.
  void _addPageFromTemplate() {
    if (coreInfo.readOnly || coreInfo.pages.isEmpty) return;
    final brightness = Theme.brightnessOf(context);
    final invert =
        stows.editorAutoInvert.value && brightness == Brightness.dark;
    showDialog<void>(
      context: context,
      builder: (_) => TemplatePickerDialog(
        coreInfo: coreInfo,
        currentPageIndex: currentPageIndex,
        invert: invert,
        onTemplateSelected: (template) {
          final index = currentPageIndex;
          insertPageAfter(index, template: template);
          if (!mounted) return;
          CanvasGestureDetector.scrollToPage(
            pageIndex: index + 1,
            pages: coreInfo.pages,
            screenWidth: MediaQuery.sizeOf(context).width,
            transformationController: _transformationController,
          );
        },
      ),
    );
  }

  /// Opens or dismisses the zoom window on the current page.
  void _toggleZoomWindow() {
    if (coreInfo.readOnly || coreInfo.pages.isEmpty) return;
    _refreshUi(() {
      if (_zoomWindowOpen) {
        _zoomWindowOpen = false;
        return;
      }
      final pageIndex = currentPageIndex.clamp(0, coreInfo.pages.length - 1);
      _zoomPageIndex = pageIndex;
      _zoomWindow.openForPage(Offset.zero & coreInfo.pages[pageIndex].size);
      _zoomWindowOpen = true;
    });
  }

  /// Creates pages until the given page index exists,
  /// plus an extra blank page
  void _createPageImpl(int pageIndex) {
    if (coreInfo.isInfiniteCanvas) {
      if (coreInfo.pages.isEmpty) {
        final page = EditorPage();
        coreInfo.pages.add(page);
        listenToQuillChanges(page.quill, 0);
      }
      return;
    }
    while (pageIndex >= coreInfo.pages.length - 1) {
      final page = EditorPage();
      coreInfo.pages.add(page);
      listenToQuillChanges(page.quill, coreInfo.pages.length - 1);
    }
  }

  void _removeExcessPagesImpl() {
    if (coreInfo.isInfiniteCanvas) return;
    bool removedAPage = false;

    // remove excess pages if all pages >= this one are empty
    for (int i = coreInfo.pages.length - 1; i >= 1; --i) {
      final thisPage = coreInfo.pages[i];
      final prevPage = coreInfo.pages[i - 1];
      if (thisPage.isEmpty && prevPage.isEmpty) {
        final page = coreInfo.pages.removeAt(i);
        page.dispose();
        removedAPage = true;
      } else {
        break;
      }
    }

    if (removedAPage) {
      // scroll to the last page (only if we're below the last page)

      final scrollY = this.scrollY;
      late final topOfLastPage = -CanvasGestureDetector.getTopOfPage(
        pageIndex: coreInfo.pages.length - 1,
        pages: coreInfo.pages,
        screenWidth: MediaQuery.sizeOf(context).width,
      );
      final bottomOfLastPage = -CanvasGestureDetector.getTopOfPage(
        pageIndex: coreInfo.pages.length,
        pages: coreInfo.pages,
        screenWidth: MediaQuery.sizeOf(context).width,
      );

      if (scrollY < bottomOfLastPage) {
        final currentMatrix = _transformationController.value;
        final currentScale = currentMatrix.maxScale2D;
        final safeScale = (currentScale.isFinite && currentScale > 0)
            ? currentScale
            : 1.0;
        final currentTx = currentMatrix.getTranslation().x;
        _transformationController.value = Matrix4.identity()
          ..translateByDouble(currentTx, (topOfLastPage + 50) * safeScale, 0, 1)
          ..scaleByDouble(safeScale, safeScale, 1.0, 1.0);
      }
    }
  }

  /// Fits visible content within the screen viewport, or resets to origin (0, 0).
  void fitContentToView() {
    if (!mounted || coreInfo.pages.isEmpty) return;

    final gestureDetectorState = _canvasGestureDetectorKey.currentState;
    final containerBounds = gestureDetectorState?.containerBounds;
    final double viewportWidth;
    final double viewportHeight;

    if (containerBounds != null &&
        containerBounds.maxWidth.isFinite &&
        containerBounds.maxWidth > 0 &&
        containerBounds.maxHeight.isFinite &&
        containerBounds.maxHeight > 0) {
      viewportWidth = containerBounds.maxWidth;
      viewportHeight = containerBounds.maxHeight;
    } else {
      final size = MediaQuery.sizeOf(context);
      viewportWidth = size.width;
      viewportHeight = size.height;
    }

    final page = coreInfo.pages.first;
    final bounds = contentBounds(page);

    if (bounds == null || bounds.isEmpty) {
      _transformationController.value = Matrix4.identity();
      return;
    }

    // Comfortable margin on iPad / tablet screens
    const margin = 64.0;
    final targetWidth = math.max(100.0, viewportWidth - margin * 2);
    final targetHeight = math.max(100.0, viewportHeight - margin * 2);

    final scaleX = targetWidth / math.max(1.0, bounds.width);
    final scaleY = targetHeight / math.max(1.0, bounds.height);
    final minScale = CanvasGestureDetector.minScaleFor(
      isInfiniteCanvas: coreInfo.isInfiniteCanvas,
    );
    final fitScale = math
        .min(scaleX, scaleY)
        .clamp(minScale, CanvasGestureDetector.kMaxScale);

    final viewportCenterX = viewportWidth / 2;
    final viewportCenterY = viewportHeight / 2;

    final translationX = viewportCenterX - bounds.center.dx * fitScale;
    final translationY = viewportCenterY - bounds.center.dy * fitScale;

    _transformationController.value = Matrix4.identity()
      ..translateByDouble(translationX, translationY, 0, 1)
      ..scaleByDouble(fitScale, fitScale, 1, 1);
  }

  /// Switches between paged and infinite canvas without hiding any content.
  ///
  /// An infinite canvas only shows the first page, so later pages are merged
  /// into it. Going back to paged mode grows the first page to hold
  /// everything. Both rewrite page indices, so undo history is cleared.
  void setInfiniteCanvas(bool infinite) {
    if (coreInfo.readOnly) return;
    if (coreInfo.isInfiniteCanvas == infinite) return;

    _refreshUi(() {
      if (infinite) {
        _mergePagesForInfiniteCanvas();
      } else if (coreInfo.pages.isNotEmpty) {
        fitFirstPageToContent(coreInfo.pages.first);
      }
      coreInfo.isInfiniteCanvas = infinite;
      for (final page in coreInfo.pages) {
        page.clearRenderBoxCache();
      }
      createPage(0);
      history.clear();
      autosaveUntrackedChange();
    });

    if (mounted) {
      if (infinite) {
        fitContentToView();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.editor.canvasHud.switchedToInfinite),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: t.editor.canvasHud.resetView,
              onPressed: () =>
                  _transformationController.value = Matrix4.identity(),
            ),
          ),
        );
      } else {
        _transformationController.value = Matrix4.identity();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.editor.canvasHud.switchedToPaged),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _mergePagesForInfiniteCanvas() {
    final first = coreInfo.pages.firstOrNull;
    first?.quill.changeSubscription?.cancel();
    mergePagesIntoFirst(coreInfo.pages);
    listenToQuillChanges(coreInfo.pages.first.quill, 0);
  }

  void duplicatePage(int pageIndex) {
    if (coreInfo.readOnly) return;
    if (pageIndex < 0 || pageIndex >= coreInfo.pages.length) return;
    _refreshUi(() {
      final page = coreInfo.pages[pageIndex];
      final newLayers = page.layers
          .map(
            (layer) => Layer(
              name: layer.name,
              visible: layer.visible,
              strokes: layer.strokes
                  .map((stroke) => stroke.copy()..pageIndex = pageIndex + 1)
                  .toList(),
            ),
          )
          .toList();
      final newPage = page.copyWith(
        layers: newLayers,
        images: page.images
            .map((image) => image.copy()..pageIndex += 1)
            .toList(),
        quill: QuillStruct(
          controller: flutter_quill.QuillController(
            document: flutter_quill.Document.fromDelta(
              page.quill.controller.document.toDelta(),
            ),
            selection: const TextSelection.collapsed(offset: 0),
          ),
          focusNode: FocusNode(debugLabel: 'Quill Focus Node'),
        ),
        backgroundImage: page.backgroundImage?.copy()?..pageIndex += 1,
      );
      coreInfo.pages.insert(pageIndex + 1, newPage);
      listenToQuillChanges(newPage.quill, pageIndex + 1);
      history.recordChange(
        EditorHistoryItem(
          type: .insertPage,
          pageIndex: pageIndex + 1,
          strokes: const [],
          images: const [],
          page: newPage,
        ),
      );
      autosaveAfterDelay();
    });
  }

  void deletePage(int pageIndex) {
    if (coreInfo.readOnly) return;
    if (coreInfo.pages.length <= 1) return;
    if (pageIndex < 0 || pageIndex >= coreInfo.pages.length) return;
    _refreshUi(() {
      final page = coreInfo.pages.removeAt(pageIndex);
      createPage(pageIndex - 1);
      history.recordChange(
        EditorHistoryItem(
          type: .deletePage,
          pageIndex: pageIndex,
          strokes: const [],
          images: const [],
          page: page,
        ),
      );
      autosaveAfterDelay();
    });
  }

  void insertPageAfter(int pageIndex, {PageTemplate? template}) =>
      _refreshUi(() {
        if (coreInfo.readOnly) return;
        final page = EditorPage();
        template?.applyTo(page);
        coreInfo.pages.insert(pageIndex + 1, page);
        listenToQuillChanges(page.quill, pageIndex + 1);
        history.recordChange(
          EditorHistoryItem(
            type: .insertPage,
            pageIndex: pageIndex + 1,
            strokes: const [],
            images: const [],
            page: page,
          ),
        );
        autosaveAfterDelay();
      });

  void clearPage(int pageIndex) {
    if (coreInfo.readOnly) return;
    final page = coreInfo.pages[pageIndex];
    _refreshUi(() {
      final removedStrokes = page.strokes.toList();
      final removedImages = page.images.toList();
      for (final layer in page.layers) layer.strokes.clear();
      page.images.clear();
      removeExcessPages();
      history.recordChange(
        EditorHistoryItem(
          type: .erase,
          pageIndex: pageIndex,
          strokes: removedStrokes,
          images: removedImages,
        ),
      );
      autosaveAfterDelay();
    });
  }

  void clearAllPages() {
    if (coreInfo.readOnly) return;
    _refreshUi(() {
      final removedStrokes = <Stroke>[];
      final removedImages = <EditorImage>[];
      for (final page in coreInfo.pages) {
        removedStrokes.addAll(page.strokes);
        removedImages.addAll(page.images);
        for (final layer in page.layers) layer.strokes.clear();
        page.images.clear();
      }
      removeExcessPages();
      history.recordChange(
        EditorHistoryItem(
          type: .erase,
          pageIndex: 0,
          strokes: removedStrokes,
          images: removedImages,
        ),
      );
    });
    autosaveAfterDelay();
  }

  /// The index of the page that is currently centered on screen.
  int get currentPageIndex {
    if (!mounted) return _lastCurrentPageIndex;

    final screenWidth = MediaQuery.sizeOf(context).width;

    return _lastCurrentPageIndex = EditorState.getPageIndexFromScrollPosition(
      scrollY: -scrollY,
      screenWidth: screenWidth,
      pages: coreInfo.pages,
    );
  }
}
