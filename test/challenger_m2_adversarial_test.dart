/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/editor/page_grid_overview.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';

import 'e2e/e2e_test_fixtures.dart';
import 'utils/test_mock_channel_handlers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockPathProvider();
    setupMockPrinting();
    FlavorConfig.setup();
  });

  Widget buildTestDialog({
    required EditorCoreInfo coreInfo,
    int currentPageIndex = 0,
    void Function(int)? scrollToPage,
    VoidCallback? redrawAndSave,
    void Function(int)? duplicatePage,
    void Function(int)? deletePage,
    void Function(int)? insertPageAfter,
    void Function(int)? clearPage,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => PageGridOverviewDialog(
                    coreInfo: coreInfo,
                    currentPageIndex: currentPageIndex,
                    scrollToPage: scrollToPage ?? (_) {},
                    redrawAndSave: redrawAndSave ?? () {},
                    duplicatePage: duplicatePage ?? (_) {},
                    deletePage: deletePage ?? (_) {},
                    insertPageAfter: insertPageAfter ?? (_) {},
                    clearPage: clearPage,
                  ),
                );
              },
              child: const Text('Open Overview'),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // REQUIREMENT 1: TAP-TO-JUMP ON VARIOUS PAGE INDICES
  // =========================================================================
  group('Adversarial Stress Test: Tap-to-Jump Navigation', () {
    testWidgets(
      'tap-to-jump navigates correctly to first, middle, and last page',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        const totalPages = 9;
        final coreInfo = EditorCoreInfo.placeholder;
        coreInfo.pages.clear();
        for (int i = 0; i < totalPages; i++) {
          coreInfo.pages.add(EditorPage(size: const Size(1000, 1400)));
        }

        int? jumpedIndex;

        // 1. Test jump to first page (index 0)
        await tester.pumpWidget(
          buildTestDialog(
            coreInfo: coreInfo,
            scrollToPage: (idx) => jumpedIndex = idx,
          ),
        );
        await tester.tap(find.text('Open Overview'));
        await tester.pumpAndSettle();

        expect(find.byType(PageGridOverviewDialog), findsOneWidget);
        await tester.tap(find.byKey(const Key('page_jump_target_0')));
        await tester.pumpAndSettle();

        expect(jumpedIndex, equals(0), reason: 'Must jump to first page (0)');
        expect(
          find.byType(PageGridOverviewDialog),
          findsNothing,
          reason: 'Dialog must be dismissed',
        );

        // 2. Test jump to middle page (index 4)
        await tester.tap(find.text('Open Overview'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('page_jump_target_4')));
        await tester.pumpAndSettle();

        expect(jumpedIndex, equals(4), reason: 'Must jump to middle page (4)');
        expect(find.byType(PageGridOverviewDialog), findsNothing);

        // 3. Test jump to last page (index 8)
        await tester.tap(find.text('Open Overview'));
        await tester.pumpAndSettle();

        // Scroll grid to ensure last page is visible
        await tester.drag(find.byType(GridView), const Offset(0, -600));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('page_jump_target_8')));
        await tester.pumpAndSettle();

        expect(jumpedIndex, equals(8), reason: 'Must jump to last page (8)');
        expect(find.byType(PageGridOverviewDialog), findsNothing);
      },
    );

    testWidgets(
      'tap-to-jump in filtered Bookmarked tab correctly maps to true page index',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        // Pages: 0(unstarred), 1(starred), 2(unstarred), 3(starred), 4(starred)
        final coreInfo = EditorCoreInfo.placeholder;
        coreInfo.pages.clear();
        for (int i = 0; i < 5; i++) {
          coreInfo.pages.add(
            EditorPage(
              size: const Size(1000, 1400),
              bookmarked: i == 1 || i == 3 || i == 4,
            ),
          );
        }

        int? jumpedIndex;
        await tester.pumpWidget(
          buildTestDialog(
            coreInfo: coreInfo,
            scrollToPage: (idx) => jumpedIndex = idx,
          ),
        );
        await tester.tap(find.text('Open Overview'));
        await tester.pumpAndSettle();

        // Switch to Bookmarked tab
        await tester.tap(find.text('Bookmarked (3)'));
        await tester.pumpAndSettle();

        // Only cards 1, 3, 4 should exist in widget tree
        expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
        expect(find.byKey(const Key('page_thumbnail_card_3')), findsOneWidget);
        expect(find.byKey(const Key('page_thumbnail_card_4')), findsOneWidget);
        expect(find.byKey(const Key('page_thumbnail_card_0')), findsNothing);
        expect(find.byKey(const Key('page_thumbnail_card_2')), findsNothing);

        // Tapping card 3 in bookmarked view must jump to true index 3
        await tester.tap(find.byKey(const Key('page_jump_target_3')));
        await tester.pumpAndSettle();

        expect(
          jumpedIndex,
          equals(3),
          reason: 'Jump in filtered mode must jump to actual page index 3',
        );
        expect(find.byType(PageGridOverviewDialog), findsNothing);
      },
    );
  });

  // =========================================================================
  // REQUIREMENT 2: DRAG-AND-DROP REORDERING AND STROKE.PAGEINDEX INTEGRITY
  // =========================================================================
  group('Adversarial Stress Test: Drag-and-Drop Reordering', () {
    testWidgets(
      'reordering forward and backward updates all page indices and stroke.pageIndex',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final coreInfo = EditorCoreInfo.placeholder;
        coreInfo.pages.clear();

        // Create 4 pages each with distinct strokes across 2 layers
        final pageA = EditorPage(
          size: const Size(1000, 1400),
          layers: [
            Layer(
              name: 'L1',
              strokes: [createTestStroke(pageIndex: 0, color: Colors.red)],
            ),
            Layer(
              name: 'L2',
              strokes: [createTestStroke(pageIndex: 0, color: Colors.pink)],
            ),
          ],
        );
        final pageB = EditorPage(
          size: const Size(1000, 1400),
          layers: [
            Layer(
              name: 'L1',
              strokes: [createTestStroke(pageIndex: 1, color: Colors.blue)],
            ),
          ],
        );
        final pageC = EditorPage(
          size: const Size(1000, 1400),
          layers: [
            Layer(
              name: 'L1',
              strokes: [createTestStroke(pageIndex: 2, color: Colors.green)],
            ),
          ],
        );
        final pageD = EditorPage(
          size: const Size(1000, 1400),
          layers: [
            Layer(
              name: 'L1',
              strokes: [createTestStroke(pageIndex: 3, color: Colors.orange)],
            ),
          ],
        );

        coreInfo.pages.addAll([pageA, pageB, pageC, pageD]);

        var redrawAndSaveCount = 0;
        await tester.pumpWidget(
          buildTestDialog(
            coreInfo: coreInfo,
            redrawAndSave: () => redrawAndSaveCount++,
          ),
        );
        await tester.tap(find.text('Open Overview'));
        await tester.pumpAndSettle();

        // 1. Forward Drag: Drag Page A (index 0) onto Page C (index 2)
        // List changes: [A, B, C, D] -> remove(0) -> [B, C, D] -> insert(2) -> [B, C, A, D]
        final card0 = find.byKey(const Key('page_thumbnail_card_0'));
        final card2 = find.byKey(const Key('page_thumbnail_card_2'));

        final gesture1 = await tester.startGesture(tester.getCenter(card0));
        await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
        await gesture1.moveTo(tester.getCenter(card2));
        await tester.pump();
        await gesture1.up();
        await tester.pumpAndSettle();

        expect(redrawAndSaveCount, equals(1));
        expect(coreInfo.pages[0], equals(pageB));
        expect(coreInfo.pages[1], equals(pageC));
        expect(coreInfo.pages[2], equals(pageA));
        expect(coreInfo.pages[3], equals(pageD));

        // Empirically verify stroke.pageIndex on EVERY page and layer after reorder
        for (int i = 0; i < coreInfo.pages.length; i++) {
          final p = coreInfo.pages[i];
          for (final layer in p.layers) {
            for (final stroke in layer.strokes) {
              expect(
                stroke.pageIndex,
                equals(i),
                reason:
                    'Page $i (originally ${p == pageA
                        ? 'A'
                        : p == pageB
                        ? 'B'
                        : p == pageC
                        ? 'C'
                        : 'D'}) '
                    'must have stroke.pageIndex == $i',
              );
            }
          }
        }

        // 2. Backward Drag: Drag Page D (index 3) onto Page B (index 0)
        // List was [B, C, A, D] -> remove(3) -> [B, C, A] -> insert(0) -> [D, B, C, A]
        final currentCard3 = find.byKey(const Key('page_thumbnail_card_3'));
        final currentCard0 = find.byKey(const Key('page_thumbnail_card_0'));

        final gesture2 = await tester.startGesture(
          tester.getCenter(currentCard3),
        );
        await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
        await gesture2.moveTo(tester.getCenter(currentCard0));
        await tester.pump();
        await gesture2.up();
        await tester.pumpAndSettle();

        expect(redrawAndSaveCount, equals(2));
        expect(coreInfo.pages[0], equals(pageD));
        expect(coreInfo.pages[1], equals(pageB));
        expect(coreInfo.pages[2], equals(pageC));
        expect(coreInfo.pages[3], equals(pageA));

        // Verify stroke.pageIndex again after backward reorder
        for (int i = 0; i < coreInfo.pages.length; i++) {
          final p = coreInfo.pages[i];
          for (final layer in p.layers) {
            for (final stroke in layer.strokes) {
              expect(
                stroke.pageIndex,
                equals(i),
                reason:
                    'Page $i stroke.pageIndex must strictly match new index $i',
              );
            }
          }
        }
      },
    );

    testWidgets('dragging is strictly disabled when viewing Bookmarked tab', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.addAll([
        EditorPage(size: const Size(1000, 1400), bookmarked: true),
        EditorPage(size: const Size(1000, 1400), bookmarked: true),
      ]);

      await tester.pumpWidget(buildTestDialog(coreInfo: coreInfo));
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      // In All mode: LongPressDraggable and DragTarget exist
      expect(find.byType(LongPressDraggable<int>), findsNWidgets(2));
      expect(find.byType(DragTarget<int>), findsNWidgets(2));

      // Switch to Bookmarked mode
      await tester.tap(find.text('Bookmarked (2)'));
      await tester.pumpAndSettle();

      // In Bookmarked mode: LongPressDraggable and DragTarget must NOT exist to prevent ambiguous index corruption
      expect(
        find.byType(LongPressDraggable<int>),
        findsNothing,
        reason: 'Drag reordering must be disabled in filtered bookmarked view',
      );
      expect(
        find.byType(DragTarget<int>),
        findsNothing,
        reason: 'Drag targets must be disabled in filtered bookmarked view',
      );
    });
  });

  // =========================================================================
  // REQUIREMENT 3: PAGE DUPLICATION AND UNDO/REDO VERIFICATION
  // =========================================================================
  group('Adversarial Stress Test: Page Duplication & Undo/Redo', () {
    testWidgets(
      'EditorState.duplicatePage creates deep-copied strokes and undo removes duplicate',
      (tester) async {
        await tester.runAsync(FileManager.init);

        // Pump full Editor widget
        await tester.pumpWidget(
          TranslationProvider(child: MaterialApp(home: Editor())),
        );
        await tester.pumpAndSettle();

        final editorState = tester.state<EditorState>(find.byType(Editor));
        addTearDown(editorState.cancelAutosaveAndMarkSaved);

        // Add a stroke to page 0
        final initialStroke = createTestStroke(
          pageIndex: 0,
          color: Colors.blue,
          points: [const Offset(100, 100), const Offset(200, 200)],
        );
        editorState.coreInfo.pages[0].layers.first.strokes.add(initialStroke);

        expect(editorState.coreInfo.pages.length, equals(1));
        expect(editorState.coreInfo.pages[0].strokes.length, equals(1));

        // Execute duplicatePage(0)
        editorState.duplicatePage(0);
        await tester.pump();

        // Verify page count is now 2
        expect(editorState.coreInfo.pages.length, equals(2));
        final originalPage = editorState.coreInfo.pages[0];
        final duplicatedPage = editorState.coreInfo.pages[1];

        // Deep copy assertion: stroke lists must be different instances
        expect(
          identical(
            originalPage.layers.first.strokes,
            duplicatedPage.layers.first.strokes,
          ),
          isFalse,
          reason: 'Layer strokes list must be independently allocated',
        );

        // Deep copy assertion: strokes within the list must be different instances
        final originalStroke = originalPage.layers.first.strokes.first;
        final duplicatedStroke = duplicatedPage.layers.first.strokes.first;
        expect(
          identical(originalStroke, duplicatedStroke),
          isFalse,
          reason: 'Strokes must be deeply cloned',
        );

        // Stroke on duplicated page must have pageIndex = 1
        expect(duplicatedStroke.pageIndex, equals(1));
        expect(originalStroke.pageIndex, equals(0));

        // Mutate duplicated stroke - must not affect original
        duplicatedPage.layers.first.strokes.add(
          createTestStroke(pageIndex: 1, color: Colors.green),
        );
        expect(originalPage.layers.first.strokes.length, equals(1));
        expect(duplicatedPage.layers.first.strokes.length, equals(2));

        // UNDO: Calling undo must remove the DUPLICATE (pageIndex 1), NOT the original
        expect(editorState.history.canUndo, isTrue);
        editorState.undo();
        await tester.pump();

        expect(
          editorState.coreInfo.pages.length,
          equals(1),
          reason: 'Undoing page duplication must remove duplicate page',
        );
        expect(
          identical(editorState.coreInfo.pages[0], originalPage),
          isTrue,
          reason: 'Original page must remain intact',
        );
        expect(
          editorState.coreInfo.pages[0].strokes.first.color,
          equals(Colors.blue),
          reason: 'Original page strokes must remain unaffected',
        );

        // REDO: Calling redo must restore the duplicate page
        expect(editorState.history.canRedo, isTrue);
        editorState.redo();
        await tester.pump();

        expect(
          editorState.coreInfo.pages.length,
          greaterThanOrEqualTo(2),
          reason: 'Redoing page duplication must restore the duplicate page',
        );
        expect(
          editorState.coreInfo.pages[1].strokes.first.color,
          equals(Colors.blue),
          reason: 'Redone duplicate must contain original stroke data',
        );
        expect(
          editorState.coreInfo.pages[1].strokes.first.pageIndex,
          equals(1),
          reason: 'Redone duplicate must have correct pageIndex',
        );
      },
    );
  });

  // =========================================================================
  // REQUIREMENT 4: DELETION GUARD FOR SINGLE PAGE
  // =========================================================================
  group('Adversarial Stress Test: Page Deletion Guard', () {
    testWidgets('UI and EditorState block deleting the only remaining page', (
      tester,
    ) async {
      await tester.runAsync(FileManager.init);

      await tester.pumpWidget(
        TranslationProvider(child: MaterialApp(home: Editor())),
      );
      await tester.pumpAndSettle();

      final editorState = tester.state<EditorState>(find.byType(Editor));
      addTearDown(editorState.cancelAutosaveAndMarkSaved);

      // Ensure initially 1 page
      expect(editorState.coreInfo.pages.length, equals(1));

      // 1. Direct call to deletePage(0) on EditorState must be safely guarded
      editorState.deletePage(0);
      await tester.pump();

      expect(
        editorState.coreInfo.pages.length,
        equals(1),
        reason: 'deletePage must block deleting when only 1 page remains',
      );

      // 2. Open PageGridOverviewDialog in UI and verify delete menu item is disabled
      await tester.tap(find.byTooltip(t.editor.pages));
      await tester.pumpAndSettle();

      expect(find.byType(PageGridOverviewDialog), findsOneWidget);

      await tester.tap(find.byKey(const Key('page_menu_0')));
      await tester.pumpAndSettle();

      final deleteMenuItem = tester.widget<PopupMenuItem<String>>(
        find.byKey(const Key('delete_page_0')),
      );
      expect(
        deleteMenuItem.enabled,
        isFalse,
        reason:
            'Delete popup menu item must be disabled when only 1 page exists',
      );

      // Close menu & dialog
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('close_overview_button')));
      await tester.pumpAndSettle();

      // 3. Add a page, now 2 pages exist
      editorState.insertPageAfter(0);
      await tester.pump();
      expect(editorState.coreInfo.pages.length, equals(2));

      // Open overview dialog again
      await tester.tap(find.byTooltip(t.editor.pages));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('page_menu_0')));
      await tester.pumpAndSettle();

      final deleteMenuItemWithTwoPages = tester.widget<PopupMenuItem<String>>(
        find.byKey(const Key('delete_page_0')),
      );
      expect(
        deleteMenuItemWithTwoPages.enabled,
        isTrue,
        reason:
            'Delete popup menu item must be enabled when multiple pages exist',
      );

      // Tap delete on card 0
      await tester.tap(find.byKey(const Key('delete_page_0')));
      await tester.pumpAndSettle();

      expect(
        editorState.coreInfo.pages.length,
        equals(1),
        reason: 'Page 0 should be deleted',
      );

      // Now verify again with remaining 1 page
      await tester.tap(find.byKey(const Key('page_menu_0')));
      await tester.pumpAndSettle();

      final deleteMenuItemNowDisabled = tester.widget<PopupMenuItem<String>>(
        find.byKey(const Key('delete_page_0')),
      );
      expect(
        deleteMenuItemNowDisabled.enabled,
        isFalse,
        reason:
            'Delete must become disabled immediately upon reducing to 1 page',
      );
    });
  });

  // =========================================================================
  // REQUIREMENT 5: BOOKMARK TOGGLING AND PERSISTENCE
  // =========================================================================
  group('Adversarial Stress Test: Bookmark Toggling & Serialization', () {
    testWidgets(
      'bookmark star toggles state, calls redrawAndSave, and filters correctly',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final coreInfo = EditorCoreInfo.placeholder;
        coreInfo.pages.clear();
        final page0 = EditorPage(
          size: const Size(1000, 1400),
          bookmarked: false,
        );
        final page1 = EditorPage(
          size: const Size(1000, 1400),
          bookmarked: false,
        );
        coreInfo.pages.addAll([page0, page1]);

        var savedTimes = 0;
        await tester.pumpWidget(
          buildTestDialog(
            coreInfo: coreInfo,
            redrawAndSave: () => savedTimes++,
          ),
        );
        await tester.tap(find.text('Open Overview'));
        await tester.pumpAndSettle();

        // Check initial counts on segmented button
        expect(find.text('All (2)'), findsOneWidget);
        expect(find.text('Bookmarked (0)'), findsOneWidget);

        // Toggle bookmark on card 0
        await tester.tap(find.byKey(const Key('bookmark_star_0')));
        await tester.pumpAndSettle();

        expect(page0.bookmarked, isTrue);
        expect(savedTimes, equals(1));
        expect(find.text('Bookmarked (1)'), findsOneWidget);

        // Toggle bookmark on card 1
        await tester.tap(find.byKey(const Key('bookmark_star_1')));
        await tester.pumpAndSettle();

        expect(page1.bookmarked, isTrue);
        expect(savedTimes, equals(2));
        expect(find.text('Bookmarked (2)'), findsOneWidget);

        // Switch to Bookmarked tab
        await tester.tap(find.text('Bookmarked (2)'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
        expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);

        // Untoggle card 0 while in Bookmarked tab
        await tester.tap(find.byKey(const Key('bookmark_star_0')));
        await tester.pumpAndSettle();

        expect(page0.bookmarked, isFalse);
        expect(savedTimes, equals(3));
        expect(find.text('Bookmarked (1)'), findsOneWidget);
        // Card 0 should immediately disappear from bookmarked view
        expect(find.byKey(const Key('page_thumbnail_card_0')), findsNothing);
        expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);

        // Untoggle card 1 as well -> empty state must appear
        await tester.tap(find.byKey(const Key('bookmark_star_1')));
        await tester.pumpAndSettle();

        expect(page1.bookmarked, isFalse);
        expect(savedTimes, equals(4));
        expect(find.text('Bookmarked (0)'), findsOneWidget);
        expect(find.text('No bookmarked pages'), findsOneWidget);
      },
    );

    test('EditorPage serializes bm: true to JSON and deserializes cleanly', () {
      final assets = OrderedAssetCache();

      // Page with bookmark = true
      final bookmarkedPage = EditorPage(
        size: const Size(1000, 1400),
        bookmarked: true,
      );
      final jsonWithBookmark = bookmarkedPage.toJson(assets);
      expect(
        jsonWithBookmark['bm'],
        isTrue,
        reason: 'toJson must serialize bm: true',
      );

      // Deserialization check
      final deserializedPage = EditorPage.fromJson(
        jsonWithBookmark,
        inlineAssets: null,
        readOnly: false,
        fileVersion: 19,
        sbnPath: '',
        assetCache: AssetCache(),
      );
      expect(
        deserializedPage.bookmarked,
        isTrue,
        reason: 'fromJson must restore bookmarked: true',
      );

      // Page with bookmark = false
      final unbookmarkedPage = EditorPage(
        size: const Size(1000, 1400),
        bookmarked: false,
      );
      final jsonWithoutBookmark = unbookmarkedPage.toJson(assets);
      expect(
        jsonWithoutBookmark.containsKey('bm'),
        isFalse,
        reason: 'toJson must omit false bm key for compact serialization',
      );

      final deserializedUnbookmarkedPage = EditorPage.fromJson(
        jsonWithoutBookmark,
        inlineAssets: null,
        readOnly: false,
        fileVersion: 19,
        sbnPath: '',
        assetCache: AssetCache(),
      );
      expect(deserializedUnbookmarkedPage.bookmarked, isFalse);
    });
  });
}
