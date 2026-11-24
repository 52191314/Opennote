/// 🤖 Generated wholely or partially with Google Antigravity
part of 'editor.dart';

extension EditorMediaImport on EditorState {
  void updateColorBar(Color color) {
    if (stows.recentColorsDontSavePresets.value) {
      if (ColorBar.colorPresets.any(
        (colorPreset) => colorPreset.color == color,
      )) {
        return;
      }
    }

    final newColorString = color.toARGB32().toString();

    // migrate from old pref format
    if (stows.recentColorsChronological.value.length !=
        stows.recentColorsPositioned.value.length) {
      log.info(
        'MIGRATING recentColors: ${stows.recentColorsChronological.value.length} vs ${stows.recentColorsPositioned.value.length}',
      );
      stows.recentColorsChronological.value = List.of(
        stows.recentColorsPositioned.value,
      );
    }

    if (stows.pinnedColors.value.contains(newColorString)) {
      // do nothing, color is already pinned
    } else if (stows.recentColorsPositioned.value.contains(newColorString)) {
      // if it's already a recent color, move it to the top
      stows.recentColorsChronological.value.remove(newColorString);
      stows.recentColorsChronological.value.add(newColorString);
      stows.recentColorsChronological.notifyListeners();
    } else {
      if (stows.recentColorsPositioned.value.length >=
          stows.recentColorsLength.value) {
        // if full, replace the oldest color with the new one
        final removedColorString = stows.recentColorsChronological.value
            .removeAt(0);
        stows.recentColorsChronological.value.add(newColorString);
        final int removedColorPosition = stows.recentColorsPositioned.value
            .indexOf(removedColorString);
        stows.recentColorsPositioned.value[removedColorPosition] =
            newColorString;
      } else {
        // if not full, add the new color to the end
        stows.recentColorsChronological.value.add(newColorString);
        stows.recentColorsPositioned.value.insert(0, newColorString);
      }
      stows.recentColorsChronological.notifyListeners();
      stows.recentColorsPositioned.notifyListeners();
    }
  }

  /// Prompts the user to pick photos from their device.
  /// Returns the number of photos picked.
  ///
  /// If [photoInfos] is provided, it will be used instead of the file picker.
  Future<int> _pickPhotos([List<_PhotoInfo>? photoInfos]) async {
    if (coreInfo.readOnly) return 0;

    final currentPageIndex = this.currentPageIndex;

    photoInfos ??= await _pickPhotosWithFilePicker();
    if (photoInfos.isEmpty) return 0;

    // use the Select tool so that the user can move the new image
    currentTool = Select.currentSelect;

    final images = [
      for (final _PhotoInfo photoInfo in photoInfos)
        if (photoInfo.extension == '.svg')
          SvgEditorImage(
            id: coreInfo.nextImageId++,
            svgString: utf8.decode(photoInfo.bytes),
            svgFile: null,
            pageIndex: currentPageIndex,
            pageSize: coreInfo.pages[currentPageIndex].size,
            onMoveImage: onMoveImage,
            onDeleteImage: onDeleteImage,
            onMiscChange: autosaveAfterDelay,
            onLoad: _refreshUi,
            assetCache: coreInfo.assetCache,
          )
        else
          PngEditorImage(
            id: coreInfo.nextImageId++,
            extension: photoInfo.extension,
            imageProvider: MemoryImage(photoInfo.bytes),
            pageIndex: currentPageIndex,
            pageSize: coreInfo.pages[currentPageIndex].size,
            onMoveImage: onMoveImage,
            onDeleteImage: onDeleteImage,
            onMiscChange: autosaveAfterDelay,
            onLoad: _refreshUi,
            assetCache: coreInfo.assetCache,
          ),
    ];

    final center = _getPlacementCenter(currentPageIndex);
    for (int i = 0; i < images.length; i++) {
      final img = images[i];
      await img.loadIn();
      final offset = Offset(i * 20.0, i * 20.0);
      final imgCenter = center + offset;
      final w = img.dstRect.width > 0 ? img.dstRect.width : 200.0;
      final h = img.dstRect.height > 0 ? img.dstRect.height : 200.0;
      img.dstRect = Rect.fromCenter(center: imgCenter, width: w, height: h);
    }

    history.recordChange(
      EditorHistoryItem(
        type: .draw,
        pageIndex: currentPageIndex,
        strokes: [],
        images: images,
      ),
    );
    createPage(currentPageIndex);
    coreInfo.pages[currentPageIndex].images.addAll(images);
    Select.currentSelect.selectImages(images, currentPageIndex);
    _updateSelectionHandles(
      coreInfo.pages[currentPageIndex],
      Select.currentSelect,
    );
    _refreshUi();
    autosaveAfterDelay();

    return images.length;
  }

  Future<void> _insertShapeFromLibrary() async {
    if (coreInfo.readOnly) return;
    final currentPageIndex = this.currentPageIndex;

    final svgString = await ShapeLibraryDialog.show(context);
    if (svgString == null || svgString.isEmpty) return;

    currentTool = Select.currentSelect;

    final image = SvgEditorImage(
      id: coreInfo.nextImageId++,
      svgString: svgString,
      svgFile: null,
      pageIndex: currentPageIndex,
      pageSize: coreInfo.pages[currentPageIndex].size,
      onMoveImage: onMoveImage,
      onDeleteImage: onDeleteImage,
      onMiscChange: autosaveAfterDelay,
      onLoad: _refreshUi,
      assetCache: coreInfo.assetCache,
    );

    await image.loadIn();
    final center = _getPlacementCenter(currentPageIndex);
    final w = image.dstRect.width > 0 ? image.dstRect.width : 200.0;
    final h = image.dstRect.height > 0 ? image.dstRect.height : 200.0;
    image.dstRect = Rect.fromCenter(center: center, width: w, height: h);

    history.recordChange(
      EditorHistoryItem(
        type: .draw,
        pageIndex: currentPageIndex,
        strokes: [],
        images: [image],
      ),
    );
    createPage(currentPageIndex);
    coreInfo.pages[currentPageIndex].images.add(image);
    Select.currentSelect.selectImages([image], currentPageIndex);
    _updateSelectionHandles(
      coreInfo.pages[currentPageIndex],
      Select.currentSelect,
    );
    _refreshUi();
    autosaveAfterDelay();
  }

  void _addStickyNote() {
    if (coreInfo.readOnly) return;
    final currentPageIndex = this.currentPageIndex;

    // Use the Select tool so that the user can move the new image
    currentTool = Select.currentSelect;
    final center = _getPlacementCenter(currentPageIndex);

    final image = StickyNoteImage(
      id: coreInfo.nextImageId++,
      assetCache: coreInfo.assetCache,
      color: const Color(0xFFFFF59D), // yellow default
      text: t.editor.stickyNote.defaultText,
      pageIndex: currentPageIndex,
      pageSize: coreInfo.pages[currentPageIndex].size,
      onMoveImage: onMoveImage,
      onDeleteImage: onDeleteImage,
      onMiscChange: autosaveAfterDelay,
      onLoad: _refreshUi,
      dstRect: Rect.fromCenter(center: center, width: 200, height: 200),
    );

    history.recordChange(
      EditorHistoryItem(
        type: .draw,
        pageIndex: currentPageIndex,
        strokes: [],
        images: [image],
      ),
    );
    createPage(currentPageIndex);
    coreInfo.pages[currentPageIndex].images.add(image);
    Select.currentSelect.selectImages([image], currentPageIndex);
    _updateSelectionHandles(
      coreInfo.pages[currentPageIndex],
      Select.currentSelect,
    );
    _refreshUi();
    autosaveAfterDelay();
  }

  void _addSticker(String emoji) {
    if (coreInfo.readOnly) return;
    final currentPageIndex = this.currentPageIndex;

    // Use the Select tool so that the user can move the new image
    currentTool = Select.currentSelect;

    const double size = 64;
    final center = _getPlacementCenter(currentPageIndex);

    final image = StickerImage(
      id: coreInfo.nextImageId++,
      assetCache: coreInfo.assetCache,
      emoji: emoji,
      pageIndex: currentPageIndex,
      pageSize: coreInfo.pages[currentPageIndex].size,
      onMoveImage: onMoveImage,
      onDeleteImage: onDeleteImage,
      onMiscChange: autosaveAfterDelay,
      onLoad: _refreshUi,
      dstRect: Rect.fromCenter(center: center, width: size, height: size),
    );

    history.recordChange(
      EditorHistoryItem(
        type: .draw,
        pageIndex: currentPageIndex,
        strokes: [],
        images: [image],
      ),
    );
    createPage(currentPageIndex);
    coreInfo.pages[currentPageIndex].images.add(image);
    Select.currentSelect.selectImages([image], currentPageIndex);
    _updateSelectionHandles(
      coreInfo.pages[currentPageIndex],
      Select.currentSelect,
    );
    _refreshUi();
    autosaveAfterDelay();
  }

  Future<List<_PhotoInfo>> _pickPhotosWithFilePicker() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      // Taken from
      // https://github.com/brendan-duncan/image/blob/main/doc/formats.md
      // (plus .svg)
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'tiff',
        'bmp',
        'tga',
        'ico',
        'pvrtc',
        'svg',
        'webp',
        'psd',
        'exr',
      ],
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return const [];

    return [
      for (final PlatformFile file in result.files)
        if (file.bytes != null && file.extension != null)
          (bytes: file.bytes!, extension: '.${file.extension}'),
    ];
  }

  /// Prompts the user to pick a PDF to import.
  /// Returns whether a PDF was picked.
  Future<bool> importPdf() async {
    if (coreInfo.readOnly) return false;
    if (!Editor.canRasterPdf) return false;

    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null) return false;

    final PlatformFile file = result.files.single;
    return importPdfFromFilePath(file.path!);
  }

  Future<bool> importPdfFromFilePath(String path) async {
    final pdfDocument = await coreInfo.assetCache.pdfDocumentCache.load(path);

    final emptyPage = coreInfo.pages.removeLast();
    assert(emptyPage.isEmpty);

    for (final pdfPage in pdfDocument.pages) {
      assert(pdfPage.pageNumber >= 1, 'pdfrx page numbers start at 1');

      // resize to [defaultWidth] to keep pen sizes consistent
      final pageSize = Size(
        EditorPage.defaultWidth,
        EditorPage.defaultWidth * pdfPage.height / pdfPage.width,
      );

      final page = EditorPage(
        size: pageSize,
        backgroundImage: PdfEditorImage(
          id: coreInfo.nextImageId++,
          pdfBytes: null,
          pdfFile: File(path),
          pdfPage: pdfPage.pageNumber - 1,
          pageIndex: coreInfo.pages.length,
          pageSize: pageSize,
          naturalSize: pdfPage.size,
          onMoveImage: onMoveImage,
          onDeleteImage: onDeleteImage,
          onMiscChange: autosaveAfterDelay,
          onLoad: _refreshUi,
          assetCache: coreInfo.assetCache,
        ),
      );
      coreInfo.pages.add(page);
      // TODO(adil192): Group multiple pages into one atomic change
      history.recordChange(
        EditorHistoryItem(
          type: .insertPage,
          pageIndex: coreInfo.pages.length - 1,
          strokes: const [],
          images: const [],
          page: page,
        ),
      );
    }

    coreInfo.pages.add(emptyPage);
    if (mounted) _refreshUi();

    autosaveAfterDelay();

    return true;
  }

  Future paste() async {
    /// Maps image formats to their file extension.
    const Map<SimpleFileFormat, String> formats = {
      Formats.jpeg: '.jpeg',
      Formats.png: '.png',
      Formats.gif: '.gif',
      Formats.tiff: '.tiff',
      Formats.bmp: '.bmp',
      Formats.ico: '.ico',
      Formats.svg: '.svg',
      Formats.webp: '.webp',
    };

    final reader = await SystemClipboard.instance?.read();
    if (reader == null) return;

    final List<_PhotoInfo> photoInfos = [];
    final List<ReadProgress> progresses = [];

    for (final format in formats.keys) {
      if (!reader.canProvide(format)) continue;
      final progress = reader.getFile(format, (file) async {
        final stream = file.getStream();
        final List<int> bytes = [];
        await for (final chunk in stream) {
          bytes.addAll(chunk);
        }
        if (bytes.isEmpty) {
          log.warning('Pasted empty file: $file (${formats[format]})');
          return;
        }

        String extension;
        if (file.fileName != null) {
          extension = file.fileName!.substring(file.fileName!.lastIndexOf('.'));
        } else {
          extension = formats[format]!;
        }

        photoInfos.add((
          bytes: Uint8List.fromList(bytes),
          extension: extension,
        ));
      });
      if (progress != null) progresses.add(progress);
    }

    while (progresses.isNotEmpty) {
      progresses.removeWhere((progress) => progress.fraction.value == 1);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await _pickPhotos(photoInfos);
  }

  /// Calculates the target center for placing new elements, photos, or shapes.
  /// Prioritizes the user's most recent canvas tap if it occurred recently
  /// (within 30 seconds) on [pageIndex]. Otherwise, projects the center of
  /// the current visible screen/viewport into local page coordinates.
  Offset _getPlacementCenter(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= coreInfo.pages.length) {
      return const Offset(200, 200);
    }

    if (_lastCanvasTapPosition != null &&
        _lastCanvasTapPageIndex == pageIndex &&
        _lastCanvasTapTime != null &&
        DateTime.now().difference(_lastCanvasTapTime!).inSeconds < 30) {
      final tapPos = _lastCanvasTapPosition!;
      _lastCanvasTapPosition = null;
      _lastCanvasTapPageIndex = null;
      _lastCanvasTapTime = null;
      return tapPos;
    }

    final page = coreInfo.pages[pageIndex];
    if (page.renderBox != null && mounted) {
      try {
        final mediaQuery = MediaQuery.maybeSizeOf(context);
        final screenSize = mediaQuery ?? const Size(800, 600);
        final screenCenter = Offset(
          screenSize.width / 2,
          screenSize.height / 2,
        );
        final localCenter = page.renderBox!.globalToLocal(screenCenter);
        if (!coreInfo.isInfiniteCanvas) {
          final clampedX = localCenter.dx.clamp(
            50.0,
            (page.size.width - 50.0).clamp(50.0, double.infinity),
          );
          final clampedY = localCenter.dy.clamp(
            50.0,
            (page.size.height - 50.0).clamp(50.0, double.infinity),
          );
          return Offset(clampedX, clampedY);
        }
        return localCenter;
      } catch (_) {
        // Fallback below
      }
    }

    return Offset(page.size.width / 2, page.size.height / 2);
  }

  void _openElementsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ElementsSheet(onSelectElement: _stampElement),
    );
  }

  void _stampElement(ElementItem item) {
    if (coreInfo.readOnly) return;
    final pageIndex = currentPageIndex.clamp(0, coreInfo.pages.length - 1);
    final page = coreInfo.pages[pageIndex];
    if (page.activeLayer.locked) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.editor.elements.lockedLayer)));
      return;
    }

    final targetCenter = _getPlacementCenter(pageIndex);
    final newStrokes = item.instantiateStrokes(
      page: page,
      targetCenter: targetCenter,
    );
    if (newStrokes.isEmpty) return;

    for (final s in newStrokes) {
      s.pageIndex = pageIndex;
      page.insertStroke(s);
    }

    history.recordChange(
      EditorHistoryItem(
        type: .draw,
        pageIndex: pageIndex,
        strokes: newStrokes,
        images: [],
      ),
    );

    page.redrawStrokes();
    currentTool = Select.currentSelect;
    Select.currentSelect.selectStrokes(newStrokes, pageIndex);
    _updateSelectionHandles(page, Select.currentSelect);
    _refreshUi();
    autosaveAfterDelay();
  }

  Future exportAsPdf(BuildContext context) async {
    final pdf = await EditorExporter.generatePdf(coreInfo, context);
    final bytes = await pdf.save();
    if (!context.mounted) return;
    await FileManager.exportFile(
      '${coreInfo.fileName}.pdf',
      bytes,
      context: context,
    );
  }

  /// Exports the current note as an SBA (Saber Archive) file.
  Future exportAsSba(BuildContext context) async {
    final sba = await coreInfo.saveToSba(currentPageIndex: currentPageIndex);
    if (!context.mounted) return;
    await FileManager.exportFile(
      '${coreInfo.fileName}.sba',
      sba,
      context: context,
    );
  }

  /// Exports the current page as a PNG image file.
  ///
  /// This captures the canvas natively via [EditorExporter.screenshotPage],
  /// which guarantees the correct background color and omits UI elements
  /// like selection bounds or the text cursor. It computes a dynamic [pixelRatio]
  /// to ensure high quality while averting Out-Of-Memory exceptions on large canvases.
  Future exportAsPng(BuildContext context) async {
    final page = coreInfo.pages[currentPageIndex];

    const maxRasterizableSize = 3000.0;
    var targetPixelRatio = maxRasterizableSize / page.size.longestSide;
    if (targetPixelRatio > 1) targetPixelRatio = 1;

    try {
      final image = await EditorExporter.screenshotPage(
        coreInfo: coreInfo,
        pageIndex: currentPageIndex,
        rasterizeAllStrokes: true,
        pixelRatio: targetPixelRatio,
      );
      final pngBytes = await image.toByteData(format: .png);
      image.dispose();

      if (!context.mounted) return;
      await FileManager.exportFile(
        '${coreInfo.fileName}_page_${currentPageIndex + 1}.png',
        pngBytes!.buffer.asUint8List(),
        isImage: true,
        context: context,
      );
    } catch (e, st) {
      log.severe('Failed to export PNG', e, st);
    }
  }
}
