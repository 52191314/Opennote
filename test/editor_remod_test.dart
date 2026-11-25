/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutter_quill;
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/save_indicator.dart';
import 'package:saber/components/editor/page_grid/draggable_page_grid.dart';
import 'package:saber/components/editor/page_grid/page_grid_empty_state.dart';
import 'package:saber/components/editor/page_grid/page_grid_header.dart';
import 'package:saber/components/editor/page_grid/page_options_menu.dart';
import 'package:saber/components/editor/page_grid/page_outline_view.dart';
import 'package:saber/components/editor/page_grid_overview.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/widgets/editor_widgets.dart';

import 'utils/test_mock_channel_handlers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockPathProvider();
    setupMockPrinting();
    FlavorConfig.setup();
  });

  Widget wrapWithApp(Widget child) {
    return TranslationProvider(child: MaterialApp(home: child));
  }

  group('Editor decomposed widgets — phone & tablet viewports', () {
    for (final viewport in const [
      (label: 'phone', size: Size(375, 812)),
      (label: 'tablet', size: Size(1024, 768)),
    ]) {
      testWidgets(
        'EditorClassicAppBar and EditorPagePill render cleanly on ${viewport.label}',
        (tester) async {
          tester.view.physicalSize = viewport.size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          final formKey = GlobalKey<FormState>();
          final controller = TextEditingController(text: 'Physics Notes');
          final savingState = ValueNotifier<SavingState>(SavingState.saved);
          addTearDown(() {
            controller.dispose();
            savingState.dispose();
          });

          var pagesOpened = false;
          var bookmarkToggled = false;
          var undoCalled = false;

          await tester.pumpWidget(
            wrapWithApp(
              Scaffold(
                appBar: EditorClassicAppBar(
                  customTitle: null,
                  filenameFormKey: formKey,
                  filenameController: controller,
                  onRenameFile: (_) {},
                  needsNaming: false,
                  validateFilename: (_) => null,
                  savingState: savingState,
                  triggerSave: () {},
                  canUndo: true,
                  canRedo: false,
                  onUndo: () => undoCalled = true,
                  onRedo: () {},
                  isInfiniteCanvas: false,
                  currentPageIndex: 1,
                  totalPages: 4,
                  currentPageBookmarked: false,
                  onOpenPages: () => pagesOpened = true,
                  onToggleBookmark: () => bookmarkToggled = true,
                  onAddOrFit: () {},
                  onExport: () {},
                  onOpenMenu: () {},
                ),
                body: const SizedBox.expand(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text('2 / 4'), findsOneWidget);

          await tester.tap(find.text('2 / 4'));
          await tester.pump();
          expect(pagesOpened, isTrue);

          await tester.tap(find.byIcon(Icons.star_border));
          await tester.pump();
          expect(bookmarkToggled, isTrue);

          await tester.tap(find.byTooltip(t.editor.toolbar.undo));
          await tester.pump();
          expect(undoCalled, isTrue);
        },
      );

      testWidgets(
        'EditorSurfaceLayout renders horizontal and vertical alignments cleanly on ${viewport.label}',
        (tester) async {
          tester.view.physicalSize = viewport.size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          final alignment = ValueNotifier<AxisDirection>(AxisDirection.down);
          addTearDown(alignment.dispose);

          await tester.pumpWidget(
            wrapWithApp(
              Scaffold(
                body: EditorSurfaceLayout(
                  toolbarAlignment: alignment,
                  opennoteUiMode: true,
                  showToolbarInFullscreen: false,
                  editingSurface: const Center(child: Text('Canvas Surface')),
                  toolbarContent: const SizedBox(
                    height: 48,
                    width: 48,
                    child: Center(child: Text('Toolbar')),
                  ),
                  readonlyBanner: const SizedBox.shrink(),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('Canvas Surface'), findsOneWidget);
          expect(find.text('Toolbar'), findsOneWidget);

          alignment.value = AxisDirection.left;
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(Row), findsOneWidget);
        },
      );
    }

    testWidgets('EditorPagePill shows Infinite mode label', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          Scaffold(
            body: EditorPagePill(
              isInfiniteCanvas: true,
              currentPageIndex: 0,
              totalPages: 1,
              isBookmarked: true,
              isCompact: false,
              onOpenPages: () {},
              onToggleBookmark: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Infinite'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('EditorExportDialog renders and dismisses cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithApp(
          Scaffold(
            body: EditorExportDialog(
              exportAsSba: (_) async {},
              exportAsPdf: (_) async {},
              exportAsPng: (_) async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(t.editor.toolbar.export), findsOneWidget);
    });

    testWidgets('EditorFullscreenExitFab triggers callback', (tester) async {
      var exited = false;
      await tester.pumpWidget(
        wrapWithApp(
          Scaffold(
            floatingActionButton: EditorFullscreenExitFab(
              onExitFullscreen: () => exited = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(exited, isTrue);
    });
  });

  group('Page Grid decomposed widgets — phone & tablet viewports', () {
    for (final viewport in const [
      (label: 'phone', size: Size(375, 812)),
      (label: 'tablet', size: Size(1024, 768)),
    ]) {
      testWidgets(
        'PageGridOverviewDialog renders cleanly without overflow on ${viewport.label}',
        (tester) async {
          tester.view.physicalSize = viewport.size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);

          final coreInfo = EditorCoreInfo.placeholder;
          coreInfo.pages.clear();
          coreInfo.pages.addAll([
            EditorPage(size: const Size(1000, 1400), bookmarked: true),
            EditorPage(size: const Size(1000, 1400), bookmarked: false),
            EditorPage(size: const Size(1000, 1400), bookmarked: false),
          ]);

          await tester.pumpWidget(
            wrapWithApp(
              Scaffold(
                body: PageGridOverviewDialog(
                  coreInfo: coreInfo,
                  currentPageIndex: 0,
                  scrollToPage: (_) {},
                  redrawAndSave: () {},
                  duplicatePage: (_) {},
                  deletePage: (_) {},
                  insertPageAfter: (_) {},
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(PageGridHeader), findsOneWidget);
          expect(find.byType(DraggablePageGrid), findsOneWidget);
          expect(
            find.byKey(const Key('page_thumbnail_card_0')),
            findsOneWidget,
          );
          expect(find.byKey(const Key('active_page_badge_0')), findsOneWidget);
        },
      );
    }

    testWidgets('PageOutlineView extracts headings and jumps on tap', (
      tester,
    ) async {
      final controller = flutter_quill.QuillController.basic();
      controller.document.insert(0, 'Chapter 1: Kinematics\n');
      controller.formatText(0, 21, flutter_quill.Attribute.h1);

      final page = EditorPage(
        size: const Size(1000, 1400),
        quill: QuillStruct(controller: controller, focusNode: FocusNode()),
      );

      int? jumpedTo;
      await tester.pumpWidget(
        wrapWithApp(
          Scaffold(
            body: PageOutlineView(
              pages: [page],
              onJumpToPage: (idx) => jumpedTo = idx,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chapter 1: Kinematics'), findsOneWidget);
      await tester.tap(find.text('Chapter 1: Kinematics'));
      await tester.pump();
      expect(jumpedTo, equals(0));
    });

    testWidgets('PageGridEmptyState and PageOptionsMenu render cleanly', (
      tester,
    ) async {
      var duplicated = false;
      await tester.pumpWidget(
        wrapWithApp(
          Scaffold(
            appBar: AppBar(
              actions: [
                PageOptionsMenu(
                  pageIndex: 0,
                  totalPages: 2,
                  onDuplicate: () => duplicated = true,
                  onInsertAfter: () {},
                  onDelete: () {},
                ),
              ],
            ),
            body: const PageGridEmptyState(
              icon: Icons.star_outline_rounded,
              title: 'Empty Title',
              subtitle: 'Empty Subtitle',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Empty Title'), findsOneWidget);
      expect(find.text('Empty Subtitle'), findsOneWidget);

      await tester.tap(find.byKey(const Key('page_menu_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('duplicate_page_0')));
      await tester.pumpAndSettle();
      expect(duplicated, isTrue);
    });
  });

  group('EditorToolActions singleton identity invariant', () {
    test('selectTool toggles eraser back and preserves Pen.currentPen', () {
      final originalPen = Pen.currentPen;
      final eraser = Eraser();

      final switched = EditorToolActions.selectTool(
        requestedTool: eraser,
        currentTool: originalPen,
        lastNonEraserTool: originalPen,
      );
      expect(identical(switched, eraser), isTrue);

      final toggledBack = EditorToolActions.selectTool(
        requestedTool: eraser,
        currentTool: eraser,
        lastNonEraserTool: originalPen,
      );
      expect(identical(toggledBack, originalPen), isTrue);
      expect(identical(Pen.currentPen, originalPen), isTrue);
    });
  });
}
