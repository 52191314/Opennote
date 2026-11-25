/// 🤖 Generated wholely or partially with Google Antigravity
part of 'editor.dart';

extension EditorUiBuilders on EditorState {
  /// Switches to [tool]. Choosing the eraser while it is already in use
  /// switches back to the tool used before it.
  void _setTool(Tool tool) {
    if (tool is Eraser && currentTool is Eraser) tool = _lastNonEraserTool;
    currentTool = tool;
    if (tool is Highlighter) {
      Highlighter.currentHighlighter = tool;
    } else if (tool is Pencil) {
      Pencil.currentPencil = tool;
    } else if (Pen.isWritingPen(tool)) {
      Pen.currentPen = tool as Pen;
    }
    if (mounted) _refreshUi();
  }

  /// Gives [color] to the current pen, or to the strokes in the selection.
  void _setToolColor(Color color) {
    _refreshUi(() {
      updateColorBar(color);
      switch (currentTool) {
        case final Highlighter highlighter:
          highlighter.color = color.withAlpha(Highlighter.alpha);
        case final Pen pen:
          pen.color = color;
          if (Pen.isWritingPen(pen)) PenTray.remember(pen);
        case Select():
          _setSelectionColor(color);
        default:
      }
    });
  }

  /// Starts typing on the current page, or goes back to the pen.
  void _toggleTextEditing() {
    _refreshUi(() {
      if (currentTool != Tool.textEditing) {
        currentTool = Tool.textEditing;
        quillFocus.value = coreInfo.pages[currentPageIndex].quill
          ..focusNode.requestFocus();
        return;
      }
      currentTool = Pen.currentPen;
      for (final page in coreInfo.pages) {
        page.quill.controller.moveCursorToPosition(
          page.quill.controller.selection.extentOffset,
        );
        page.quill.focusNode.unfocus();
      }
    });
  }

  void _toggleFingerDrawing() {
    stows.editorFingerDrawing.value = !stows.editorFingerDrawing.value;
    lastSeenPointerCount = 0;
  }

  /// Describes the editor to whichever toolbar is showing.
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

  Widget _buildEditor(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final platform = Theme.of(context).platform;
    final isToolbarVertical =
        stows.editorToolbarAlignment.value == AxisDirection.left ||
        stows.editorToolbarAlignment.value == AxisDirection.right;

    final int currentPageIdx = currentPageIndex;
    final bool currentPageBookmarked =
        coreInfo.pages.isNotEmpty &&
        currentPageIdx < coreInfo.pages.length &&
        coreInfo.pages[currentPageIdx].bookmarked;

    final Widget canvas = CanvasGestureDetector(
      key: _canvasGestureDetectorKey,
      filePath: coreInfo.filePath,
      isDrawGesture: isDrawGesture,
      onInteractionEnd: onInteractionEnd,
      onDrawStart: onDrawStart,
      onDrawUpdate: onDrawUpdate,
      onDrawEnd: onDrawEnd,
      onHovering: onHovering,
      onHoveringEnd: onHoveringEnd,
      onStylusButtonChanged: onStylusButtonChanged,
      updatePointerData: updatePointerData,
      undo: undo,
      redo: redo,
      pages: coreInfo.pages,
      initialPageIndex: coreInfo.initialPageIndex,
      explicitPageIndex: widget.initialPageIndex,
      pageBuilder: pageBuilder,
      isTextEditing: () => currentTool == Tool.textEditing,
      bookmarked: currentPageBookmarked,
      onToggleBookmarked: () => _refreshUi(() {
        if (coreInfo.readOnly) return;
        final pageIdx = currentPageIndex;
        if (pageIdx >= coreInfo.pages.length) return;
        final page = coreInfo.pages[pageIdx];
        page.bookmarked = !page.bookmarked;
        page.redrawStrokes();
        autosaveAfterDelay();
      }),
      hasTape: currentPageHasTape,
      onRevealAllTape: _revealAllTapeOnCurrentPage,
      onConcealAllTape: _concealAllTapeOnCurrentPage,
      activePage: coreInfo.pages.isNotEmpty
          ? coreInfo.pages[currentPageIndex.clamp(0, coreInfo.pages.length - 1)]
          : null,
      onLayersChanged: () => _refreshUi(() {
        autosaveAfterDelay();
      }),
      isInfiniteCanvas: coreInfo.isInfiniteCanvas,
      onFitContent: fitContentToView,
      placeholderPageBuilder: (BuildContext context, int pageIndex) {
        return Canvas(
          path: coreInfo.filePath,
          page: coreInfo.pages[pageIndex],
          pageIndex: 0,
          textEditing: false,
          coreInfo: EditorCoreInfo.placeholder,
          currentStroke: null,
          currentStrokeDetectedShape: null,
          currentSelection: null,
          placeholder: true,
          setAsBackground: null,
          currentTool: currentTool,
          currentScale: double.minPositive,
        );
      },
      transformationController: _transformationController,
    );

    final readonlyBanner = ReadOnlyBanner(
      coreInfo.readOnlyReason,
      action: coreInfo.readOnlyReason == .versionTooNew
          ? showVersionTooNewDialog
          : null,
    );

    final toolbarActions = _toolbarActions();
    final Widget toolbarContent = stows.opennoteUiMode.value
        ? RepaintBoundary(
            child: OpennoteToolbar(
              actions: toolbarActions,
              onClearPage: () => clearPage(currentPageIndex),
              zoomWindowOpen: _zoomWindowOpen,
              onToggleZoomWindow: _toggleZoomWindow,
            ),
          )
        : Toolbar(
            actions: toolbarActions,
            undo: undo,
            isUndoPossible: history.canUndo,
            redo: redo,
            isRedoPossible: history.canRedo,
            toggleFingerDrawing: _toggleFingerDrawing,
            exportAsSba: exportAsSba,
            exportAsPdf: exportAsPdf,
            exportAsPng: exportAsPng,
          );

    final Widget toolbar = ValueListenableBuilder<AxisDirection>(
      valueListenable: stows.editorToolbarAlignment,
      builder: (context, alignment, _) {
        final isTop = alignment == AxisDirection.up;
        final isOpennoteTop =
            isTop &&
            stows.opennoteUiMode.value &&
            !DynamicMaterialApp.isFullscreen;
        return Collapsible(
          axis: isToolbarVertical
              ? CollapsibleAxis.horizontal
              : CollapsibleAxis.vertical,
          collapsed:
              DynamicMaterialApp.isFullscreen &&
              !stows.editorToolbarShowInFullscreen.value,
          maintainState: true,
          child: SafeArea(
            top: isOpennoteTop,
            bottom: !isTop,
            child: Padding(
              padding: EdgeInsets.only(top: isOpennoteTop ? 54.0 : 0.0),
              child: toolbarContent,
            ),
          ),
        );
      },
    );

    final int? zoomPageIndex = coreInfo.pages.isEmpty
        ? null
        : _zoomPageIndex.clamp(0, coreInfo.pages.length - 1);
    final Widget editingSurface = Stack(
      children: [
        canvas,
        if (!stows.opennoteUiMode.value && Pen.isWritingPen(currentTool))
          Positioned.fill(
            child: WritingPenMenu(tool: currentTool, onChanged: _refreshUi),
          ),
        if (_zoomWindowOpen && zoomPageIndex != null)
          ZoomWindowPanel(
            controller: _zoomWindow,
            page: coreInfo.pages[zoomPageIndex],
            pageIndex: zoomPageIndex,
            history: history,
            pen: () => penForZoomWindow(currentTool),
            onDismiss: () => _refreshUi(() => _zoomWindowOpen = false),
            onStrokeStarted: () {
              if (mounted) _refreshUi();
            },
            onStrokeCommitted: () {
              autosaveAfterDelay();
              if (mounted) _refreshUi();
            },
          ),
      ],
    );

    final Widget body = ValueListenableBuilder<AxisDirection>(
      valueListenable: stows.editorToolbarAlignment,
      builder: (context, alignment, _) {
        if (isToolbarVertical) {
          return Row(
            textDirection: alignment == AxisDirection.left
                ? TextDirection.ltr
                : TextDirection.rtl,
            children: [
              toolbar,
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: editingSurface),
                    readonlyBanner,
                  ],
                ),
              ),
            ],
          );
        } else {
          return Column(
            verticalDirection: alignment == AxisDirection.up
                ? VerticalDirection.up
                : VerticalDirection.down,
            children: [
              Expanded(child: editingSurface),
              toolbar,
              readonlyBanner,
            ],
          );
        }
      },
    );

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isCompact = screenWidth < 500;
    final bool isVeryCompact = screenWidth < 400;

    return ValueListenableBuilder(
      valueListenable: savingState,
      builder: (context, savingState, child) {
        // don't allow user to go back until saving is done
        return PopScope(
          canPop: savingState == .saved,
          onPopInvokedWithResult: (didPop, _) {
            switch (savingState) {
              case .waitingToSave:
                assert(!didPop);
                saveToFile(); // trigger save now
                snackBarNeedsToSaveBeforeExiting();
              case .saving:
                assert(!didPop);
                snackBarNeedsToSaveBeforeExiting();
              case .saved:
                break;
            }
          },
          child: child!,
        );
      },
      child: Scaffold(
        extendBodyBehindAppBar:
            stows.opennoteUiMode.value && !DynamicMaterialApp.isFullscreen,
        backgroundColor: coreInfo.isInfiniteCanvas
            ? (coreInfo.backgroundColor ?? const Color(0xFFFCFCFC))
                  .withInversion(
                    stows.editorAutoInvert.value &&
                        Theme.brightnessOf(context) == Brightness.dark,
                  )
            : stows.opennoteUiMode.value
            ? (Theme.brightnessOf(context) == Brightness.dark
                  ? const Color(0xFF161618)
                  : const Color(0xFFF3F2EE))
            : null,
        appBar: DynamicMaterialApp.isFullscreen
            ? null
            : stows.opennoteUiMode.value
            ? OpennoteHeaderBar(
                filePath: coreInfo.filePath,
                customTitle: widget.customTitle,
                filenameTextEditingController: filenameTextEditingController,
                filenameFormKey: _filenameFormKey,
                renameFile: renameFile,
                validateFilename: _validateFilenameTextField,
                needsNaming: needsNaming,
                savingState: savingState,
                triggerSave: saveToFile,
                onBack: () => Navigator.of(context).maybePop(),
                onOpenThumbnails: () {
                  if (coreInfo.isInfiniteCanvas) {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => bottomSheet(context),
                      isScrollControlled: true,
                      showDragHandle: true,
                      backgroundColor: colorScheme.surface,
                      constraints: const BoxConstraints(maxWidth: 500),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => pageManager(context),
                    );
                  }
                },
                currentPageIndex: currentPageIdx,
                totalPages: coreInfo.pages.length,
                isInfiniteCanvas: coreInfo.isInfiniteCanvas,
                onFitContent: fitContentToView,
                isBookmarked: currentPageBookmarked,
                onToggleBookmark: () => _refreshUi(() {
                  if (coreInfo.readOnly) return;
                  final pageIdx = currentPageIndex;
                  if (pageIdx >= coreInfo.pages.length) return;
                  final page = coreInfo.pages[pageIdx];
                  page.bookmarked = !page.bookmarked;
                  page.redrawStrokes();
                  autosaveUntrackedChange();
                }),
                onInsertPage: _addPageFromTemplate,
                undo: undo,
                canUndo: !coreInfo.readOnly && history.canUndo,
                redo: redo,
                canRedo: !coreInfo.readOnly && history.canRedo,
                onExport: () => _showExportDialog(context),
                isHandScrollMode: _isHandScrollOnlyMode,
                onToggleHandScrollMode: () => _refreshUi(() {
                  _isHandScrollOnlyMode = !_isHandScrollOnlyMode;
                }),
                onOpenMenu: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => bottomSheet(context),
                    isScrollControlled: true,
                    showDragHandle: true,
                    backgroundColor: colorScheme.surface,
                    constraints: const BoxConstraints(maxWidth: 500),
                  );
                },
                readOnly: coreInfo.readOnly,
              )
            : _buildClassicAppBar(
                context: context,
                colorScheme: colorScheme,
                screenWidth: screenWidth,
                isCompact: isCompact,
                isVeryCompact: isVeryCompact,
                currentPageIdx: currentPageIdx,
                currentPageBookmarked: currentPageBookmarked,
              ),
        body: body,
        floatingActionButton:
            (DynamicMaterialApp.isFullscreen &&
                !stows.editorToolbarShowInFullscreen.value)
            ? FloatingActionButton(
                shape: platform.isCupertino ? const CircleBorder() : null,
                onPressed: () {
                  DynamicMaterialApp.setFullscreen(false, updateSystem: true);
                },
                child: const Icon(Icons.fullscreen_exit),
              )
            : null,
      ),
    );
  }

  AppBar _buildClassicAppBar({
    required BuildContext context,
    required ColorScheme colorScheme,
    required double screenWidth,
    required bool isCompact,
    required bool isVeryCompact,
    required int currentPageIdx,
    required bool currentPageBookmarked,
  }) => AppBar(
    toolbarHeight: kToolbarHeight,
    leadingWidth: isCompact ? 44.0 : null,
    titleSpacing: isCompact ? 6.0 : NavigationToolbar.kMiddleSpacing,
    title: widget.customTitle != null
        ? Text(widget.customTitle!)
        : Form(
            key: _filenameFormKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: TextFormField(
              decoration: const InputDecoration(border: InputBorder.none),
              controller: filenameTextEditingController,
              onChanged: renameFile,
              autofocus: needsNaming,
              validator: _validateFilenameTextField,
            ),
          ),
    leading: SaveIndicator(savingState: savingState, triggerSave: saveToFile),
    actions: [
      // Undo & Redo Navigation Bar controls
      IconButton(
        visualDensity: isCompact ? VisualDensity.compact : null,
        padding: isCompact ? const EdgeInsets.symmetric(horizontal: 4) : null,
        icon: const AdaptiveIcon(
          icon: Icons.undo,
          cupertinoIcon: CupertinoIcons.arrow_uturn_left,
        ),
        tooltip: t.editor.toolbar.undo,
        onPressed: (!coreInfo.readOnly && history.canUndo) ? undo : null,
      ),
      IconButton(
        visualDensity: isCompact ? VisualDensity.compact : null,
        padding: isCompact ? const EdgeInsets.symmetric(horizontal: 4) : null,
        icon: const AdaptiveIcon(
          icon: Icons.redo,
          cupertinoIcon: CupertinoIcons.arrow_uturn_right,
        ),
        tooltip: t.editor.toolbar.redo,
        onPressed: (!coreInfo.readOnly && history.canRedo) ? redo : null,
      ),
      SizedBox(width: isCompact ? 2 : 4),

      // Opennote Document Hub & Page Pill: Page X / Y ⭐
      Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: isCompact ? 2 : 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 0.75,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: t.editor.pages,
                child: InkWell(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  onTap: () {
                    if (coreInfo.isInfiniteCanvas) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => bottomSheet(context),
                        isScrollControlled: true,
                        showDragHandle: true,
                        backgroundColor: colorScheme.surface,
                        constraints: const BoxConstraints(maxWidth: 500),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => pageManager(context),
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 6 : 8,
                      vertical: isCompact ? 4 : 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (coreInfo.isInfiniteCanvas) ...[
                          Icon(
                            Icons.all_inclusive_rounded,
                            size: isCompact ? 13 : 15,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: isCompact ? 3 : 5),
                          Text(
                            'Infinite',
                            style: TextStyle(
                              fontSize: isCompact ? 11.5 : 12.5,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.grid_view_rounded,
                            size: isCompact ? 13 : 15,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: isCompact ? 3 : 5),
                          Text(
                            '${currentPageIdx + 1} / ${coreInfo.pages.length}',
                            style: TextStyle(
                              fontSize: isCompact ? 11.5 : 12.5,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: isCompact ? 12 : 16,
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              Tooltip(
                message: currentPageBookmarked
                    ? t.editor.bookmark.remove
                    : t.editor.bookmark.add,
                child: InkResponse(
                  radius: 16,
                  onTap: () => _refreshUi(() {
                    if (coreInfo.readOnly) return;
                    final pageIdx = currentPageIndex;
                    if (pageIdx >= coreInfo.pages.length) return;
                    final page = coreInfo.pages[pageIdx];
                    page.bookmarked = !page.bookmarked;
                    page.redrawStrokes();
                    autosaveUntrackedChange();
                  }),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 5 : 7,
                      vertical: isCompact ? 4 : 6,
                    ),
                    child: Icon(
                      currentPageBookmarked ? Icons.star : Icons.star_border,
                      size: isCompact ? 14 : 16,
                      color: currentPageBookmarked
                          ? Colors.amber.shade700
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Add Page (or Fit Content in Infinite Canvas mode)
      if (!isVeryCompact)
        IconButton(
          visualDensity: isCompact ? VisualDensity.compact : null,
          padding: isCompact ? const EdgeInsets.symmetric(horizontal: 4) : null,
          icon: AdaptiveIcon(
            icon: coreInfo.isInfiniteCanvas
                ? Icons.fit_screen_rounded
                : Icons.add,
            cupertinoIcon: coreInfo.isInfiniteCanvas
                ? Icons.fit_screen_rounded
                : CupertinoIcons.add,
          ),
          tooltip: coreInfo.isInfiniteCanvas
              ? t.editor.canvasHud.fitContent
              : t.editor.menu.insertPage,
          onPressed: coreInfo.isInfiniteCanvas
              ? fitContentToView
              : _addPageFromTemplate,
        ),

      // Share / Export
      if (screenWidth >= 450)
        IconButton(
          visualDensity: isCompact ? VisualDensity.compact : null,
          padding: isCompact ? const EdgeInsets.symmetric(horizontal: 4) : null,
          icon: const AdaptiveIcon(
            icon: Icons.ios_share,
            cupertinoIcon: CupertinoIcons.share,
          ),
          tooltip: t.editor.toolbar.export,
          onPressed: () => _showExportDialog(context),
        ),

      // More (...) menu
      IconButton(
        visualDensity: isCompact ? VisualDensity.compact : null,
        padding: isCompact ? const EdgeInsets.symmetric(horizontal: 4) : null,
        icon: const AdaptiveIcon(
          icon: Icons.more_vert,
          cupertinoIcon: CupertinoIcons.ellipsis_vertical,
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => bottomSheet(context),
            isScrollControlled: true,
            showDragHandle: true,
            backgroundColor: colorScheme.surface,
            constraints: const BoxConstraints(maxWidth: 500),
          );
        },
      ),
    ],
  );

  void snackBarNeedsToSaveBeforeExiting() {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.editor.needsToSaveBeforeExiting)));
  }

  void _showExportDialog(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.ios_share, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    t.editor.toolbar.export,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ExportBar(
                axis: Axis.horizontal,
                toggleExportBar: () => Navigator.of(context).pop(),
                exportAsSba: exportAsSba,
                exportAsPdf: exportAsPdf,
                exportAsPng: exportAsPng,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSheet(BuildContext context) {
    final Brightness brightness = Theme.brightnessOf(context);
    final invert = stows.editorAutoInvert.value && brightness == .dark;
    final int currentPageIndex = this.currentPageIndex;

    return EditorBottomSheet(
      invert: invert,
      coreInfo: coreInfo,
      currentPageIndex: currentPageIndex,
      setBackgroundPattern: (pattern) => _refreshUi(() {
        if (coreInfo.readOnly) return;
        final previous = coreInfo.backgroundPattern;
        coreInfo.backgroundPattern = pattern;
        stows.lastBackgroundPattern.value = pattern;
        history.recordChange(
          EditorHistoryItem(
            type: .backgroundPattern,
            pageIndex: currentPageIndex,
            backgroundPatternChange: Change(
              previous: previous,
              current: pattern,
            ),
            strokes: [],
            images: [],
          ),
        );
        autosaveAfterDelay();
      }),
      setLineHeight: (lineHeight) => _refreshUi(() {
        if (coreInfo.readOnly) return;
        coreInfo.lineHeight = lineHeight;
        stows.lastLineHeight.value = lineHeight;
        autosaveUntrackedChange();
      }),
      setLineThickness: (lineThickness) => _refreshUi(() {
        if (coreInfo.readOnly) return;
        coreInfo.lineThickness = lineThickness;
        stows.lastLineThickness.value = lineThickness;
        autosaveUntrackedChange();
      }),
      setPageSize: (Size newSize) => _refreshUi(() {
        if (coreInfo.readOnly) return;
        if (currentPageIndex >= coreInfo.pages.length) return;
        final page = coreInfo.pages[currentPageIndex];
        page.size = newSize;
        page.redrawStrokes();
        autosaveUntrackedChange();
      }),
      setInfiniteCanvas: setInfiniteCanvas,
      onFitContent: fitContentToView,
      removeBackgroundImage: () => _refreshUi(() {
        if (coreInfo.readOnly) return;

        final page = coreInfo.pages[currentPageIndex];
        if (page.backgroundImage == null) return;
        page.images.add(page.backgroundImage!);
        page.backgroundImage = null;

        autosaveUntrackedChange();
      }),
      redrawImage: _refreshUi,
      clearPage: () {
        clearPage(currentPageIndex);
      },
      clearAllPages: clearAllPages,
      redrawAndSave: () => _refreshUi(() {
        if (coreInfo.readOnly) return;
        autosaveUntrackedChange();
      }),
      pickPhotos: _pickPhotos,
      importPdf: importPdf,
      canRasterPdf: Editor.canRasterPdf,
      addStickyNote: _addStickyNote,
      addSticker: _addSticker,
      getIsWatchingServer: () => _watchServerTimer?.isActive ?? false,
      setIsWatchingServer: (bool watch) {
        if (watch) {
          _watchServerTimer ??= Timer.periodic(
            const Duration(seconds: 5),
            (_) => _refreshCurrentNote(),
          );
          if (coreInfo.readOnlyReason != .watchingServer) {
            assert(coreInfo.readOnlyReason == null);
            coreInfo.readOnlyReason = .watchingServer;
            if (mounted) _refreshUi();
          }
        } else {
          _watchServerTimer?.cancel();
          _watchServerTimer = null;
          if (coreInfo.readOnlyReason == .watchingServer) {
            coreInfo.readOnlyReason = null;
            if (mounted) _refreshUi();
          }
        }
      },
      onOpenPresentation: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PresentationMode(
              coreInfo: coreInfo,
              initialPageIndex: currentPageIndex,
            ),
            fullscreenDialog: true,
          ),
        );
      },
      onOpenFlashcards: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PresentationMode(
              coreInfo: coreInfo,
              initialPageIndex: currentPageIndex,
              mode: DisplayMode.flashcard,
            ),
            fullscreenDialog: true,
          ),
        );
      },
      onExport: () => _showExportDialog(context),
    );
  }

  Widget pageBuilder(
    BuildContext context,
    int pageIndex, [
    Rect? viewportRect,
  ]) {
    final page = coreInfo.pages[pageIndex];
    final isSelect = currentTool is Select;
    final select = isSelect ? currentTool as Select : null;
    final isCurrentPageSelected = select?.selectResult.pageIndex == pageIndex;

    return ValueListenableBuilder<Stroke?>(
      valueListenable: _activeStrokeNotifier,
      builder: (context, activeStroke, _) {
        final effectiveStroke = activeStroke ?? Pen.currentStroke;
        final currentStroke = effectiveStroke?.pageIndex == pageIndex
            ? effectiveStroke
            : null;
        return Canvas(
          path: coreInfo.filePath,
          page: page,
          pageIndex: pageIndex,
          textEditing: currentTool == Tool.textEditing,
          coreInfo: coreInfo,
          currentStroke: currentStroke,
          currentStrokeDetectedShape:
              currentTool is ShapePen && currentStroke != null
              ? ShapePen.detectedShape
              : null,
          currentSelection: isCurrentPageSelected ? select?.selectResult : null,
          isDoneSelecting:
              isCurrentPageSelected && (select?.doneSelecting ?? false),
          onCutSelection: isCurrentPageSelected ? _cutSelection : null,
          onCopySelection: isCurrentPageSelected ? _copySelection : null,
          onDuplicateSelection: isCurrentPageSelected
              ? _duplicateSelection
              : null,
          onDeleteSelection: isCurrentPageSelected
              ? () {
                  if (select != null) _deleteSelection(select, page);
                }
              : null,
          onSetColor: isCurrentPageSelected ? _setSelectionColor : null,
          isResizeActive:
              isCurrentPageSelected && (select?.isResizeActive ?? false),
          onToggleResize: isCurrentPageSelected ? _toggleSelectionResize : null,
          onReduceTextSize: isCurrentPageSelected ? _reduceSelectionSize : null,
          onEnlargeTextSize: isCurrentPageSelected
              ? _enlargeSelectionSize
              : null,
          onTakeScreenshot: isCurrentPageSelected
              ? _takeSelectionScreenshot
              : null,
          onAddToElements: isCurrentPageSelected ? _addToElements : null,
          onBringToFront: isCurrentPageSelected ? _bringSelectionToFront : null,
          onSendToBack: isCurrentPageSelected ? _sendSelectionToBack : null,
          onSmoothen: isCurrentPageSelected ? _smoothenSelection : null,
          cropPossible: isCurrentPageSelected && _cropPossible,
          cropActive: isCurrentPageSelected && _cropActive,
          onToggleCrop: isCurrentPageSelected ? _toggleCrop : null,
          setAsBackground: (EditorImage image) {
            if (page.backgroundImage != null) {
              // restore previous background image as normal image
              page.images.add(page.backgroundImage!);
            }
            page.images.remove(image);
            page.backgroundImage = image;

            CanvasImage.activeListener
                .notifyListenersPlease(); // un-select active image

            autosaveAfterDelay();
            _refreshUi();
          },
          currentTool: currentTool,
          currentScale: _transformationController.value.maxScale2D,
          foreground: _zoomWindowOpen && pageIndex == _zoomPageIndex
              ? ZoomPageBox(controller: _zoomWindow)
              : null,
          viewportRect: viewportRect,
        );
      },
    );
  }

  Widget pageManager(BuildContext context) {
    return PageGridOverviewDialog(
      coreInfo: coreInfo,
      currentPageIndex: currentPageIndex,
      scrollToPage: (int pageIndex) {
        CanvasGestureDetector.scrollToPage(
          pageIndex: pageIndex,
          pages: coreInfo.pages,
          screenWidth: MediaQuery.sizeOf(context).width,
          transformationController: _transformationController,
        );
      },
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
}
