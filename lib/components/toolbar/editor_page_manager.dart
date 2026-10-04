/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/components/editor/page_grid_overview.dart';
import 'package:saber/data/editor/editor_core_info.dart';

/// Page manager wrapper delegating to [PageGridOverviewDialog].
class EditorPageManager extends StatelessWidget {
  const EditorPageManager({
    super.key,
    required this.coreInfo,
    required this.currentPageIndex,
    required this.redrawAndSave,
    required this.insertPageAfter,
    required this.duplicatePage,
    required this.clearPage,
    required this.deletePage,
    required this.transformationController,
    this.initialFilter = PageGridFilter.all,
  });

  final EditorCoreInfo coreInfo;
  final int? currentPageIndex;
  final VoidCallback redrawAndSave;

  final void Function(int) insertPageAfter;
  final void Function(int) duplicatePage;
  final void Function(int) clearPage;
  final void Function(int) deletePage;

  final TransformationController transformationController;
  final PageGridFilter initialFilter;

  @override
  Widget build(BuildContext context) {
    return PageGridOverviewDialog(
      coreInfo: coreInfo,
      currentPageIndex: currentPageIndex ?? 0,
      initialFilter: initialFilter,
      scrollToPage: (pageIndex) => CanvasGestureDetector.scrollToPage(
        pageIndex: pageIndex,
        pages: coreInfo.pages,
        screenWidth: MediaQuery.sizeOf(context).width,
        transformationController: transformationController,
      ),
      redrawAndSave: redrawAndSave,
      insertPageAfter: insertPageAfter,
      duplicatePage: duplicatePage,
      deletePage: deletePage,
      clearPage: clearPage,
    );
  }
}
