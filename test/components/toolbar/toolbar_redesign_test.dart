/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/toolbar/editor_bottom_sheet.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/opennote_toolbar.dart';
import 'package:saber/components/toolbar/toolbar.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/study_tape.dart';
import 'package:sbn/canvas_background_pattern.dart';

void main() {
  setUpAll(() {
    stows.penTray.value = 'ff000000:2,ff1565c0:3,ffc62828:4';
    stows.penTrayIndex.value = 0;
  });

  EditorToolbarActions buildActions({
    required Tool currentTool,
    required ValueChanged<Tool> onSetTool,
    required ValueChanged<Color> onSetColor,
    bool textEditing = false,
  }) {
    return EditorToolbarActions(
      readOnly: false,
      setTool: onSetTool,
      currentTool: currentTool,
      setColor: onSetColor,
      quillFocus: ValueNotifier<QuillStruct?>(null),
      textEditing: textEditing,
      toggleTextEditing: () {},
      pickPhoto: () {},
      pickShape: () {},
      paste: () {},
      copySelection: () {},
      pasteSelection: () {},
      duplicateSelection: () {},
      deleteSelection: () {},
      onRevealAllTape: () {},
      onConcealAllTape: () {},
    );
  }

  group('Tool singleton identity preservation', () {
    testWidgets(
      'Pen.currentPen identity is preserved across pen tray, quick color, and quick size switches',
      (tester) async {
        final originalPen = Pen.currentPen;
        Tool activeTool = originalPen;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => OpennoteToolbar(
                  actions: buildActions(
                    currentTool: activeTool,
                    onSetTool: (tool) => setState(() => activeTool = tool),
                    onSetColor: (color) => setState(() {
                      if (activeTool is Pen) {
                        (activeTool as Pen).color = color;
                      }
                    }),
                  ),
                ),
              ),
            ),
          ),
        );

        // Tap PenTray slot 1
        await tester.tap(find.byKey(const ValueKey('pen-tray-1')));
        await tester.pump();
        expect(identical(Pen.currentPen, originalPen), isTrue);
        expect(identical(activeTool, originalPen), isTrue);

        // Tap QuickPaletteBar color slot 2
        await tester.tap(find.byKey(const ValueKey('quick_color_2')));
        await tester.pumpAndSettle();
        expect(identical(Pen.currentPen, originalPen), isTrue);
        expect(identical(activeTool, originalPen), isTrue);

        // Tap QuickPaletteBar size slot 1
        await tester.tap(find.byKey(const ValueKey('quick_size_1')));
        await tester.pumpAndSettle();
        expect(identical(Pen.currentPen, originalPen), isTrue);
        expect(identical(activeTool, originalPen), isTrue);
      },
    );

    testWidgets(
      'Highlighter.currentHighlighter identity is preserved after quick palette changes',
      (tester) async {
        final originalHighlighter = Highlighter.currentHighlighter;
        Tool activeTool = originalHighlighter;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => OpennoteToolbar(
                  actions: buildActions(
                    currentTool: activeTool,
                    onSetTool: (tool) => setState(() => activeTool = tool),
                    onSetColor: (color) => setState(() {
                      if (activeTool is Pen) {
                        (activeTool as Pen).color = color;
                      }
                    }),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byKey(const ValueKey('quick_color_1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('quick_size_2')));
        await tester.pumpAndSettle();

        expect(
          identical(Highlighter.currentHighlighter, originalHighlighter),
          isTrue,
        );
        expect(identical(activeTool, originalHighlighter), isTrue);
      },
    );

    testWidgets(
      'Classic Toolbar selects StudyTapeTool.currentStudyTape and Select.currentSelect singletons',
      (tester) async {
        Tool activeTool = Pen.currentPen;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => Toolbar(
                  actions: buildActions(
                    currentTool: activeTool,
                    onSetTool: (tool) => setState(() => activeTool = tool),
                    onSetColor: (_) {},
                  ),
                  undo: () {},
                  isUndoPossible: false,
                  redo: () {},
                  isRedoPossible: false,
                  toggleFingerDrawing: () {},
                  exportAsSba: null,
                  exportAsPdf: null,
                  exportAsPng: null,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.view_headline_rounded));
        await tester.pump();
        expect(identical(activeTool, StudyTapeTool.currentStudyTape), isTrue);

        await tester.tap(find.byTooltip('Select'));
        await tester.pump();
        expect(identical(activeTool, Select.currentSelect), isTrue);
      },
    );
  });

  group('EditorBottomSheet redesign layout & PRO hooks', () {
    Widget buildBottomSheet({
      required EditorCoreInfo coreInfo,
      bool isPro = false,
      void Function(String featureId)? onProFeatureRequested,
      void Function(CanvasBackgroundPattern)? setBackgroundPattern,
      VoidCallback? onExportSvg,
      VoidCallback? onInsertPage,
      VoidCallback? onOpenPageGrid,
      VoidCallback? onToggleDarkModePreview,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: EditorBottomSheet(
            invert: false,
            coreInfo: coreInfo,
            currentPageIndex: 0,
            setBackgroundPattern: setBackgroundPattern ?? (_) {},
            setLineHeight: (_) {},
            setLineThickness: (_) {},
            setInfiniteCanvas: (_) {},
            removeBackgroundImage: () {},
            redrawImage: () {},
            clearPage: () {},
            clearAllPages: () {},
            redrawAndSave: () {},
            pickPhotos: () async => 0,
            importPdf: () async => false,
            addStickyNote: () {},
            addSticker: (_) {},
            canRasterPdf: true,
            getIsWatchingServer: () => false,
            setIsWatchingServer: (_) {},
            setPageSize: (_) {},
            onOpenPresentation: () {},
            onOpenFlashcards: () {},
            onFitContent: () {},
            onExport: () {},
            onExportSvg: onExportSvg,
            onInsertPage: onInsertPage,
            onOpenPageGrid: onOpenPageGrid,
            onToggleDarkModePreview: onToggleDarkModePreview,
            isPro: isPro,
            onProFeatureRequested: onProFeatureRequested,
          ),
        ),
      );
    }

    for (final viewport in [
      ('mobile 360px', const Size(360, 800)),
      ('tablet 1024px', const Size(1024, 768)),
    ]) {
      testWidgets('renders cleanly with zero overflow on ${viewport.$1}', (
        tester,
      ) async {
        tester.view.physicalSize = viewport.$2;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final coreInfo = EditorCoreInfo(filePath: '/test/note')
          ..pages.add(EditorPage());

        await tester.pumpWidget(
          buildBottomSheet(
            coreInfo: coreInfo,
            onProFeatureRequested: (_) {},
            onInsertPage: () {},
            onOpenPageGrid: () {},
            onToggleDarkModePreview: () {},
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final sheetScrollable = find.byType(Scrollable).first;
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('export_hub_pdf')),
          250,
          scrollable: sheetScrollable,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey('export_hub_pdf')), findsOneWidget);
        expect(find.byKey(const ValueKey('export_hub_svg')), findsOneWidget);
        expect(find.byKey(const ValueKey('export_hub_image')), findsOneWidget);
        expect(find.byKey(const ValueKey('export_hub_print')), findsOneWidget);
        expect(find.byKey(const ValueKey('export_hub_share')), findsOneWidget);
      });
    }

    testWidgets(
      'routes PRO paper patterns and SVG export to onProFeatureRequested when free',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final coreInfo = EditorCoreInfo(filePath: '/test/note')
          ..pages.add(EditorPage());

        final requestedFeatures = <String>[];
        CanvasBackgroundPattern? appliedPattern;
        var svgExported = false;

        await tester.pumpWidget(
          buildBottomSheet(
            coreInfo: coreInfo,
            isPro: false,
            onProFeatureRequested: requestedFeatures.add,
            setBackgroundPattern: (p) => appliedPattern = p,
            onExportSvg: () => svgExported = true,
          ),
        );
        await tester.pumpAndSettle();

        final sheetScrollable = find.byType(Scrollable).first;
        final patternListScrollable = find.descendant(
          of: find.byKey(const ValueKey('paper_pattern_list')),
          matching: find.byType(Scrollable),
        );

        // Scroll horizontally to Isometric pattern and tap
        final isoFinder = find.byKey(const ValueKey('paper_pattern_isometric'));
        await tester.scrollUntilVisible(
          isoFinder,
          200,
          scrollable: patternListScrollable,
        );
        await tester.ensureVisible(isoFinder);
        await tester.pumpAndSettle();
        await tester.tap(isoFinder);
        await tester.pumpAndSettle();
        expect(requestedFeatures, contains('paper_pattern_isometric'));
        expect(appliedPattern, isNull);

        // Scroll vertically to SVG export and tap
        final svgFinder = find.byKey(const ValueKey('export_hub_svg'));
        await tester.scrollUntilVisible(
          svgFinder,
          250,
          scrollable: sheetScrollable,
        );
        await tester.tap(svgFinder);
        await tester.pumpAndSettle();
        expect(requestedFeatures, contains('export_vector_svg'));
        expect(svgExported, isFalse);
      },
    );
  });

  group('OpennoteToolbar & Toolbar responsive overflow checks', () {
    for (final viewport in [
      ('mobile 360px', const Size(360, 800)),
      ('mobile 390px', const Size(390, 844)),
      ('tablet 1024px', const Size(1024, 768)),
    ]) {
      testWidgets(
        'OpennoteToolbar renders all sub-bars with zero overflow on ${viewport.$1}',
        (tester) async {
          tester.view.physicalSize = viewport.$2;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final tools = <Tool>[
            Pen.currentPen,
            Eraser(size: 30),
            Select.currentSelect,
            Ruler(),
            StudyTapeTool.currentStudyTape,
          ];

          for (final tool in tools) {
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: OpennoteToolbar(
                    actions: buildActions(
                      currentTool: tool,
                      onSetTool: (_) {},
                      onSetColor: (_) {},
                    ),
                    onClearPage: () {},
                  ),
                ),
              ),
            );
            await tester.pump();
            expect(
              tester.takeException(),
              isNull,
              reason:
                  'Unexpected layout error for ${tool.runtimeType} on ${viewport.$1}',
            );
          }
        },
      );

      testWidgets(
        'Classic Toolbar renders with zero overflow on ${viewport.$1}',
        (tester) async {
          tester.view.physicalSize = viewport.$2;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Toolbar(
                  actions: buildActions(
                    currentTool: Pen.currentPen,
                    onSetTool: (_) {},
                    onSetColor: (_) {},
                  ),
                  undo: () {},
                  isUndoPossible: true,
                  redo: () {},
                  isRedoPossible: false,
                  toggleFingerDrawing: () {},
                  exportAsSba: null,
                  exportAsPdf: null,
                  exportAsPng: null,
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
