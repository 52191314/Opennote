/// 🤖 Generated wholely or partially with Google Antigravity
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
part of 'editor.dart';

extension EditorUiBuilders on EditorState {
  /// Switches to [tool]. Choosing the eraser while it is already in use
  /// switches back to the tool used before it.
  void _setTool(Tool tool) {
    currentTool = EditorToolActions.selectTool(
      requestedTool: tool,
      currentTool: currentTool,
      lastNonEraserTool: _lastNonEraserTool,
    );
    if (mounted) _refreshUi();
  }

  /// Gives [color] to the current pen, or to the strokes in the selection.
  void _setToolColor(Color color) => _refreshUi(
    () => EditorToolActions.applyToolColor(
      currentTool: currentTool,
      color: color,
      onUpdateColorBar: updateColorBar,
      onSelectionColor: _setSelectionColor,
    ),
  );

  /// Starts typing on the current page, or goes back to the pen.
  void _toggleTextEditing() => _refreshUi(() {
    currentTool = EditorToolActions.toggleTextEditing(
      currentTool: currentTool,
      pages: coreInfo.pages,
      currentPageIndex: currentPageIndex,
      quillFocus: quillFocus,
    );
  });

  void _toggleFingerDrawing() {
    stows.editorFingerDrawing.value = !stows.editorFingerDrawing.value;
    lastSeenPointerCount = 0;
  }

  void _toggleCurrentPageBookmark({bool delayAutosave = false}) =>
      _refreshUi(() {
        final toggled = EditorToolActions.toggleBookmark(
          coreInfo: coreInfo,
          currentPageIndex: currentPageIndex,
        );
        if (!toggled) return;
        delayAutosave ? autosaveAfterDelay() : autosaveUntrackedChange();
      });

  void _openPagesOrMenu(BuildContext context) => coreInfo.isInfiniteCanvas
      ? EditorBottomSheetHost.showModal(context, bottomSheet)
      : showDialog(context: context, builder: pageManager);

  EditorToolbarActions _toolbarActions() => EditorToolbarActions(
    readOnly: coreInfo.readOnly,
    setTool: _setTool,
    currentTool: currentTool,
    setColor: _setToolColor,
    quillFocus: quillFocus,
    textEditing: currentTool == Tool.textEditing,
    toggleTextEditing: _toggleTextEditing,
    pickPhoto: _pickPhotos,
    pickShape: _insertShapeFromLibrary,
    paste: paste,
    cutSelection: _cutSelection,
    copySelection: _copySelection,
    pasteSelection: _pasteSelection,
    duplicateSelection: _duplicateSelection,
    deleteSelection: _deleteCurrentSelection,
    onSetColor: _setSelectionColor,
    cropPossible: _cropPossible,
    cropActive: _cropActive,
    toggleCrop: _toggleCrop,
    toggleResize: _toggleSelectionResize,
    isResizeActive:
        currentTool is Select && (currentTool as Select).isResizeActive,
    bringToFront: _bringSelectionToFront,
    sendToBack: _sendSelectionToBack,
    smoothen: _smoothenSelection,
    addToElements: _addToElements,
    openElementsSheet: _openElementsSheet,
    onRevealAllTape: _revealAllTapeOnCurrentPage,
    onConcealAllTape: _concealAllTapeOnCurrentPage,
    reduceSelectionSize: _reduceSelectionSize,
    enlargeSelectionSize: _enlargeSelectionSize,
  );

  Widget _buildEditor(BuildContext context) => EditorWorkspaceScaffold(
    coreInfo: coreInfo,
    opennoteUiMode: stows.opennoteUiMode.value,
    autoInvert: stows.editorAutoInvert.value,
    toolbarAlignment: stows.editorToolbarAlignment,
    showToolbarInFullscreen: stows.editorToolbarShowInFullscreen.value,
    savingState: savingState,
    onTriggerSave: saveToFile,
    onNeedsSaveNotice: snackBarNeedsToSaveBeforeExiting,
    onShowVersionTooNewDialog: showVersionTooNewDialog,
    canvasKey: _canvasGestureDetectorKey,
    explicitPageIndex: widget.initialPageIndex,
    currentPageIndex: currentPageIndex,
    currentTool: currentTool,
    hasTape: currentPageHasTape,
    history: history,
    actions: _toolbarActions(),
    gestures: EditorCanvasGestures(
      isDrawGesture: isDrawGesture,
      onInteractionEnd: onInteractionEnd,
      onDrawStart: onDrawStart,
      onDrawUpdate: onDrawUpdate,
      onDrawEnd: onDrawEnd,
      onHovering: onHovering,
      onHoveringEnd: onHoveringEnd,
      onStylusButtonChanged: onStylusButtonChanged,
      updatePointerData: updatePointerData,
    ),
    transformationController: _transformationController,
    pageBuilder: pageBuilder,
    customTitle: widget.customTitle,
    filenameController: filenameTextEditingController,
    filenameFormKey: _filenameFormKey,
    onRenameFile: renameFile,
    validateFilename: _validateFilenameTextField,
    needsNaming: needsNaming,
    isHandScrollMode: _isHandScrollOnlyMode,
    onToggleHandScrollMode: () =>
        _refreshUi(() => _isHandScrollOnlyMode = !_isHandScrollOnlyMode),
    onOpenPages: () => _openPagesOrMenu(context),
    onToggleBookmark: _toggleCurrentPageBookmark,
    onInsertPage: _addPageFromTemplate,
    onFitContent: fitContentToView,
    onUndo: undo,
    onRedo: redo,
    onExport: () => _showExportDialog(context),
    onOpenMenu: () => EditorBottomSheetHost.showModal(context, bottomSheet),
    onLayersChanged: () => _refreshUi(autosaveAfterDelay),
    onRefreshUi: _refreshUi,
    zoomWindowOpen: _zoomWindowOpen,
    zoomWindowController: _zoomWindow,
    zoomPageIndex: coreInfo.pages.isEmpty
        ? null
        : _zoomPageIndex.clamp(0, coreInfo.pages.length - 1),
    zoomPenProvider: () => penForZoomWindow(currentTool),
    onDismissZoomWindow: () => _refreshUi(() => _zoomWindowOpen = false),
    onZoomStrokeStarted: () => mounted ? _refreshUi() : null,
    onZoomStrokeCommitted: () {
      autosaveAfterDelay();
      if (mounted) _refreshUi();
    },
    onClearPage: () => clearPage(currentPageIndex),
    onToggleZoomWindow: _toggleZoomWindow,
    onToggleFingerDrawing: _toggleFingerDrawing,
    exportAsSba: exportAsSba,
    exportAsPdf: exportAsPdf,
    exportAsPng: exportAsPng,
  );

  void snackBarNeedsToSaveBeforeExiting() {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.editor.needsToSaveBeforeExiting)));
  }

  void _showExportDialog(BuildContext context) => showDialog(
    context: context,
    builder: (_) => EditorExportDialog(
      exportAsSba: exportAsSba,
      exportAsPdf: exportAsPdf,
      exportAsPng: exportAsPng,
    ),
  );

  Widget bottomSheet(BuildContext context) => EditorBottomSheetHost(
    coreInfo: coreInfo,
    history: history,
    currentPageIndex: currentPageIndex,
    canRasterPdf: Editor.canRasterPdf,
    onRefreshUi: _refreshUi,
    onAutosaveAfterDelay: autosaveAfterDelay,
    onAutosaveUntracked: autosaveUntrackedChange,
    onSetInfiniteCanvas: setInfiniteCanvas,
    onFitContent: fitContentToView,
    onClearPage: () => clearPage(currentPageIndex),
    onClearAllPages: clearAllPages,
    onPickPhotos: _pickPhotos,
    onImportPdf: importPdf,
    onAddStickyNote: _addStickyNote,
    onAddSticker: _addSticker,
    getIsWatchingServer: () => _watchServerTimer?.isActive ?? false,
    setIsWatchingServer: (watch) =>
        _watchServerTimer = EditorToolActions.updateServerWatch(
          watch: watch,
          existingTimer: _watchServerTimer,
          coreInfo: coreInfo,
          onPoll: _refreshCurrentNote,
          onChanged: () => mounted ? _refreshUi() : null,
        ),
    onExport: () => _showExportDialog(context),
  );

  Widget pageBuilder(
    BuildContext context,
    int pageIndex, [
    Rect? viewportRect,
  ]) => EditorCanvasPage(
    coreInfo: coreInfo,
    page: coreInfo.pages[pageIndex],
    pageIndex: pageIndex,
    activeStrokeNotifier: _activeStrokeNotifier,
    currentTool: currentTool,
    currentScale: _transformationController.value.maxScale2D,
    actions: _toolbarActions(),
    onDeleteSelection: _deleteSelection,
    onTakeScreenshot: _takeSelectionScreenshot,
    onBackgroundImageChanged: () {
      autosaveAfterDelay();
      _refreshUi();
    },
    foreground: _zoomWindowOpen && pageIndex == _zoomPageIndex
        ? ZoomPageBox(controller: _zoomWindow)
        : null,
    viewportRect: viewportRect,
  );

  Widget pageManager(BuildContext context) => PageGridOverviewDialog(
    coreInfo: coreInfo,
    currentPageIndex: currentPageIndex,
    scrollToPage: (int pageIndex) => CanvasGestureDetector.scrollToPage(
      pageIndex: pageIndex,
      pages: coreInfo.pages,
      screenWidth: MediaQuery.sizeOf(context).width,
      transformationController: _transformationController,
    ),
    redrawAndSave: () => _refreshUi(() {
      if (coreInfo.readOnly) return;
      autosaveUntrackedChange();
    }),
    insertPageAfter: insertPageAfter,
    duplicatePage: duplicatePage,
    clearPage: clearPage,
    deletePage: deletePage,
  );
}
