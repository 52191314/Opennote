/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutter_quill;
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/editor/page_grid_overview.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_history.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/i18n/strings.g.dart';

import 'e2e/e2e_test_fixtures.dart';
import 'utils/test_mock_channel_handlers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockPathProvider();
    setupMockPrinting();
    FlavorConfig.setup();
  });

  /// Realistic stateful test harness that mirrors editor.dart page operations.
  Widget buildHarness({
    required EditorCoreInfo coreInfo,
    int currentPageIndex = 0,
    void Function(int)? onScrolledTo,
    VoidCallback? onRedrawAndSave,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            void duplicatePage(int pageIndex) {
              if (pageIndex < 0 || pageIndex >= coreInfo.pages.length) return;
              final page = coreInfo.pages[pageIndex];
              final newLayers = page.layers
                  .map((layer) => Layer(
                        name: layer.name,
                        visible: layer.visible,
                        strokes: layer.strokes
                            .map((stroke) => stroke.copy()..pageIndex = pageIndex + 1)
                            .toList(),
                      ))
                  .toList();
              final newPage = page.copyWith(
                layers: newLayers,
                images: page.images
                    .map((image) => image.copy()..pageIndex += 1)
                    .toList(),
                quill: QuillStruct(
                  controller: flutter_quill.QuillController.basic(),
                  focusNode: FocusNode(),
                ),
              );
              coreInfo.pages.insert(pageIndex + 1, newPage);
              setState(() {});
            }

            void deletePage(int pageIndex) {
              if (coreInfo.pages.length <= 1) return;
              if (pageIndex < 0 || pageIndex >= coreInfo.pages.length) return;
              coreInfo.pages.removeAt(pageIndex);
              setState(() {});
            }

            void insertPageAfter(int pageIndex) {
              final newPage = EditorPage(
                size: const Size(1000, 1400),
                layers: [Layer(name: 'Default', strokes: [])],
              );
              final targetIndex = (pageIndex < 0) ? 0 : pageIndex + 1;
              if (targetIndex >= coreInfo.pages.length) {
                coreInfo.pages.add(newPage);
              } else {
                coreInfo.pages.insert(targetIndex, newPage);
              }
              setState(() {});
            }

            return Scaffold(
              body: PageGridOverviewDialog(
                coreInfo: coreInfo,
                currentPageIndex: currentPageIndex,
                scrollToPage: (index) {
                  onScrolledTo?.call(index);
                },
                redrawAndSave: () {
                  onRedrawAndSave?.call();
                },
                duplicatePage: duplicatePage,
                deletePage: deletePage,
                insertPageAfter: insertPageAfter,
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================================================================
  // REQUIREMENT 1: FILTER TABS STRESS TESTING
  // =========================================================================
  group('Adversarial Stress Test: Filter Tabs', () {
    testWidgets('Case 1: No pages bookmarked — switching, empty state, and bookmark toggling', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.addAll([
        EditorPage(size: const Size(1000, 1400), bookmarked: false),
        EditorPage(size: const Size(1000, 1400), bookmarked: false),
        EditorPage(size: const Size(1000, 1400), bookmarked: false),
      ]);

      await tester.pumpWidget(buildHarness(coreInfo: coreInfo));
      await tester.pumpAndSettle();

      // Check initial tab counts
      expect(find.text('All (3)'), findsOneWidget);
      expect(find.text('Bookmarked (0)'), findsOneWidget);

      // Verify all 3 thumbnail cards visible in "All" tab
      expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);

      // Switch to "Bookmarked" tab
      await tester.tap(find.text('Bookmarked (0)'));
      await tester.pumpAndSettle();

      // Verify empty state is rendered
      expect(find.text('No bookmarked pages'), findsOneWidget);
      expect(find.text('Star pages to view them here'), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_0')), findsNothing);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsNothing);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsNothing);

      // Switch back to "All" tab
      await tester.tap(find.text('All (3)'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);

      // Bookmark page 1 while on "All" tab
      await tester.tap(find.byKey(const Key('bookmark_star_1')));
      await tester.pumpAndSettle();

      expect(coreInfo.pages[1].bookmarked, isTrue);
      expect(find.text('Bookmarked (1)'), findsOneWidget);

      // Switch to "Bookmarked (1)" tab
      await tester.tap(find.text('Bookmarked (1)'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_0')), findsNothing);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsNothing);

      // Now toggle bookmark off on page 1 WHILE on "Bookmarked" tab
      await tester.tap(find.byKey(const Key('bookmark_star_1')));
      await tester.pumpAndSettle();

      // It must immediately transition to the empty state without crashing
      expect(coreInfo.pages[1].bookmarked, isFalse);
      expect(find.text('Bookmarked (0)'), findsOneWidget);
      expect(find.text('No bookmarked pages'), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsNothing);

      // Switch back to "All (3)" tab
      await tester.tap(find.text('All (3)'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);
    });

    testWidgets('Case 2: Some pages bookmarked — index mapping, jump, drag-guard, and add page', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.addAll([
        EditorPage(size: const Size(1000, 1400), bookmarked: false), // index 0 (page 1)
        EditorPage(size: const Size(1000, 1400), bookmarked: true),  // index 1 (page 2)
        EditorPage(size: const Size(1000, 1400), bookmarked: false), // index 2 (page 3)
        EditorPage(size: const Size(1000, 1400), bookmarked: true),  // index 3 (page 4)
      ]);

      int? jumpedPageIndex;
      await tester.pumpWidget(
        buildHarness(
          coreInfo: coreInfo,
          currentPageIndex: 3,
          onScrolledTo: (index) => jumpedPageIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All (4)'), findsOneWidget);
      expect(find.text('Bookmarked (2)'), findsOneWidget);

      // Switch to "Bookmarked" tab
      await tester.tap(find.text('Bookmarked (2)'));
      await tester.pumpAndSettle();

      // Cards 1 and 3 are visible; cards 0 and 2 are hidden
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_3')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_0')), findsNothing);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsNothing);

      // Page numbers must show 1-based page numbers 2 and 4
      expect(find.byKey(const Key('page_number_1')), findsOneWidget);
      expect(find.text('2'), findsWidgets);
      expect(find.byKey(const Key('page_number_3')), findsOneWidget);
      expect(find.text('4'), findsWidgets);

      // Current page badge should be on card 3 (since currentPageIndex == 3)
      expect(find.byKey(const Key('active_page_badge_3')), findsOneWidget);
      expect(find.byKey(const Key('active_page_badge_1')), findsNothing);

      // LongPressDraggable should NOT be present in Bookmarked tab (reorder disabled)
      expect(find.byType(LongPressDraggable<int>), findsNothing);

      // Add a page while in Bookmarked tab via header "+" button
      await tester.tap(find.byKey(const Key('add_page_button')));
      await tester.pumpAndSettle();

      // Notebook now has 5 pages; new page is not bookmarked
      expect(coreInfo.pages.length, equals(5));
      expect(find.text('All (5)'), findsOneWidget);
      expect(find.text('Bookmarked (2)'), findsOneWidget);

      // Bookmarked view still correctly shows cards 1 and 3
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_3')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_4')), findsNothing);

      // Finally, tap card 3 jump target and verify navigation occurs
      await tester.tap(find.byKey(const Key('page_jump_target_3')));
      await tester.pumpAndSettle();
      expect(jumpedPageIndex, equals(3));
    });

    testWidgets('Case 3: All pages bookmarked — full toggle cycle to empty state and back', (
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
        EditorPage(size: const Size(1000, 1400), bookmarked: true),
      ]);

      await tester.pumpWidget(buildHarness(coreInfo: coreInfo));
      await tester.pumpAndSettle();

      expect(find.text('All (3)'), findsOneWidget);
      expect(find.text('Bookmarked (3)'), findsOneWidget);

      // Switch to "Bookmarked (3)"
      await tester.tap(find.text('Bookmarked (3)'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);

      // Unbookmark page 0
      await tester.tap(find.byKey(const Key('bookmark_star_0')));
      await tester.pumpAndSettle();

      expect(find.text('Bookmarked (2)'), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_0')), findsNothing);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);

      // Unbookmark page 1
      await tester.tap(find.byKey(const Key('bookmark_star_1')));
      await tester.pumpAndSettle();

      expect(find.text('Bookmarked (1)'), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsNothing);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);

      // Unbookmark page 2 (last remaining)
      await tester.tap(find.byKey(const Key('bookmark_star_2')));
      await tester.pumpAndSettle();

      expect(find.text('Bookmarked (0)'), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsNothing);
      expect(find.text('No bookmarked pages'), findsOneWidget);

      // Switch back to "All (3)" tab
      await tester.tap(find.text('All (3)'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);
    });
  });

  // =========================================================================
  // REQUIREMENT 2: RAPID OPERATIONS STRESS TESTING
  // =========================================================================
  group('Adversarial Stress Test: Rapid Operations', () {
    testWidgets('Rapid Operation 1: Duplicate then delete and single-page delete guard', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      final pageA = EditorPage(size: const Size(1000, 1400));
      final pageB = EditorPage(size: const Size(1000, 1400));
      coreInfo.pages.addAll([pageA, pageB]);

      await tester.pumpWidget(buildHarness(coreInfo: coreInfo));
      await tester.pumpAndSettle();

      expect(coreInfo.pages.length, equals(2));

      // Duplicate page 0 via card popup menu
      await tester.tap(find.byKey(const Key('page_menu_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('duplicate_page_0')));
      await tester.pumpAndSettle();

      // Pages: [pageA, duplicatedPage, pageB]
      expect(coreInfo.pages.length, equals(3));
      expect(coreInfo.pages[0], equals(pageA));
      expect(coreInfo.pages[2], equals(pageB));
      expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);

      // Rapidly delete the duplicated page at index 1
      await tester.tap(find.byKey(const Key('page_menu_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_page_1')));
      await tester.pumpAndSettle();

      // Pages: [pageA, pageB]
      expect(coreInfo.pages.length, equals(2));
      expect(coreInfo.pages[0], equals(pageA));
      expect(coreInfo.pages[1], equals(pageB));
      expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsNothing);

      // Now delete page 1 to leave only 1 page
      await tester.tap(find.byKey(const Key('page_menu_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_page_1')));
      await tester.pumpAndSettle();

      expect(coreInfo.pages.length, equals(1));
      expect(coreInfo.pages.first, equals(pageA));

      // On the single remaining page, verify delete is disabled
      await tester.tap(find.byKey(const Key('page_menu_0')));
      await tester.pumpAndSettle();

      final deleteMenuItem = tester.widget<PopupMenuItem<String>>(
        find.byKey(const Key('delete_page_0')),
      );
      expect(deleteMenuItem.enabled, isFalse);

      // Tapping disabled delete menuItem does not alter page count
      await tester.tap(find.byKey(const Key('delete_page_0')));
      await tester.pumpAndSettle();

      expect(coreInfo.pages.length, equals(1));
    });

    testWidgets('Rapid Operation 2: Reorder then duplicate preserves stroke isolation and indices', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();

      final strokeA = createTestStroke(pageIndex: 0);
      final pageA = EditorPage(
        size: const Size(1000, 1400),
        layers: [Layer(name: 'Default', strokes: [strokeA])],
      );

      final strokeB = createTestStroke(pageIndex: 1);
      final pageB = EditorPage(
        size: const Size(1000, 1400),
        layers: [Layer(name: 'Default', strokes: [strokeB])],
      );

      final strokeC = createTestStroke(pageIndex: 2);
      final pageC = EditorPage(
        size: const Size(1000, 1400),
        layers: [Layer(name: 'Default', strokes: [strokeC])],
      );

      coreInfo.pages.addAll([pageA, pageB, pageC]);

      await tester.pumpWidget(buildHarness(coreInfo: coreInfo));
      await tester.pumpAndSettle();

      // Drag card 0 onto card 2 to reorder: [pageB, pageC, pageA]
      final card0 = find.byKey(const Key('page_thumbnail_card_0'));
      final card2 = find.byKey(const Key('page_thumbnail_card_2'));

      final gesture = await tester.startGesture(tester.getCenter(card0));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await gesture.moveTo(tester.getCenter(card2));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(coreInfo.pages[0], equals(pageB));
      expect(coreInfo.pages[1], equals(pageC));
      expect(coreInfo.pages[2], equals(pageA));

      // Verify updatePageIndex updated stroke pageIndex fields
      expect(pageB.layers.first.strokes.first.pageIndex, equals(0));
      expect(pageC.layers.first.strokes.first.pageIndex, equals(1));
      expect(pageA.layers.first.strokes.first.pageIndex, equals(2));

      // Now duplicate the page at index 1 (which is pageC)
      await tester.tap(find.byKey(const Key('page_menu_1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('duplicate_page_1')));
      await tester.pumpAndSettle();

      // Pages: [pageB, pageC, duplicatedPageC, pageA] (length 4)
      expect(coreInfo.pages.length, equals(4));
      expect(coreInfo.pages[0], equals(pageB));
      expect(coreInfo.pages[1], equals(pageC));
      expect(coreInfo.pages[3], equals(pageA));

      final duplicatedPage = coreInfo.pages[2];
      expect(identical(pageC.layers.first.strokes, duplicatedPage.layers.first.strokes), isFalse);
      expect(duplicatedPage.layers.first.strokes.first.pageIndex, equals(2));

      // Verify mutating duplicated page does not affect pageC
      duplicatedPage.layers.first.strokes.add(createTestStroke(pageIndex: 2));
      expect(pageC.layers.first.strokes.length, equals(1));
      expect(duplicatedPage.layers.first.strokes.length, equals(2));

      // Grid shows 4 cards and page numbers 1..4
      expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_3')), findsOneWidget);
    });

    testWidgets('Rapid Operation 3: Add multiple pages rapidly via header button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.add(EditorPage(size: const Size(1000, 1400)));

      await tester.pumpWidget(buildHarness(coreInfo: coreInfo));
      await tester.pumpAndSettle();

      expect(coreInfo.pages.length, equals(1));
      expect(find.text('All (1)'), findsOneWidget);

      // Rapidly tap add_page_button 5 times
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const Key('add_page_button')));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Should now have 6 pages
      expect(coreInfo.pages.length, equals(6));
      expect(find.text('All (6)'), findsOneWidget);

      for (int i = 0; i < 6; i++) {
        expect(find.byKey(Key('page_thumbnail_card_$i')), findsOneWidget);
        expect(find.byKey(Key('page_number_$i')), findsOneWidget);
      }

      // Insert a page in the middle (after index 2) via menu
      await tester.tap(find.byKey(const Key('page_menu_2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('insert_page_2')));
      await tester.pumpAndSettle();

      expect(coreInfo.pages.length, equals(7));
      expect(find.text('All (7)'), findsOneWidget);
    });

    testWidgets('Rapid Operation 4: Complex multi-operation sequence torture test', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.addAll([
        EditorPage(size: const Size(1000, 1400), bookmarked: false),
        EditorPage(size: const Size(1000, 1400), bookmarked: true),
      ]);

      await tester.pumpWidget(buildHarness(coreInfo: coreInfo));
      await tester.pumpAndSettle();

      // Step 1: Add 2 pages
      await tester.tap(find.byKey(const Key('add_page_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add_page_button')));
      await tester.pumpAndSettle();
      expect(coreInfo.pages.length, equals(4));

      // Step 2: Duplicate page 0
      await tester.tap(find.byKey(const Key('page_menu_0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('duplicate_page_0')));
      await tester.pumpAndSettle();
      expect(coreInfo.pages.length, equals(5));

      // Step 3: Bookmark page 4
      await tester.tap(find.byKey(const Key('bookmark_star_4')));
      await tester.pumpAndSettle();
      expect(find.text('Bookmarked (2)'), findsOneWidget);

      // Step 4: Switch to Bookmarked tab
      await tester.tap(find.text('Bookmarked (2)'));
      await tester.pumpAndSettle();

      // Step 5: Delete page from Bookmarked tab
      // Visible bookmarked pages are index 2 and index 4
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_4')), findsOneWidget);

      await tester.tap(find.byKey(const Key('page_menu_4')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('delete_page_4')));
      await tester.pumpAndSettle();

      expect(coreInfo.pages.length, equals(4));
      expect(find.text('Bookmarked (1)'), findsOneWidget);

      // Step 6: Switch back to All tab
      await tester.tap(find.text('All (4)'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_3')), findsOneWidget);
    });

    test('Rapid Operation 5: Editor undo-redo stack round-trip with duplicate and delete', () {
      final pages = <EditorPage>[
        EditorPage(size: const Size(1000, 1400)),
        EditorPage(size: const Size(1000, 1400)),
      ];
      final history = EditorHistory();

      // Emulate duplicatePage(0)
      final originalPage = pages[0];
      final duplicatedPage = originalPage.copyWith(
        layers: originalPage.layers.map((l) => Layer(name: l.name, strokes: [])).toList(),
      );
      pages.insert(1, duplicatedPage);
      history.recordChange(
        EditorHistoryItem(
          type: EditorHistoryItemType.insertPage,
          pageIndex: 1,
          page: duplicatedPage,
          strokes: const [],
          images: const [],
        ),
      );

      expect(pages.length, equals(3));
      expect(history.canUndo, isTrue);

      // Undo duplicate: should remove pageIndex 1
      final undoItem = history.undo();
      expect(undoItem, isNotNull);
      pages.removeAt(undoItem.pageIndex);
      expect(pages.length, equals(2));
      expect(pages[0], equals(originalPage));

      // Redo duplicate: should re-insert at pageIndex 1
      final redoItem = history.redo();
      expect(redoItem, isNotNull);
      pages.insert(redoItem.pageIndex, redoItem.page!);
      expect(pages.length, equals(3));

      // Emulate deletePage(1)
      final removed = pages.removeAt(1);
      history.recordChange(
        EditorHistoryItem(
          type: EditorHistoryItemType.deletePage,
          pageIndex: 1,
          page: removed,
          strokes: const [],
          images: const [],
        ),
      );
      expect(pages.length, equals(2));

      // Undo delete: should re-insert at pageIndex 1
      final undoDelete = history.undo();
      expect(undoDelete, isNotNull);
      pages.insert(undoDelete.pageIndex, undoDelete.page!);
      expect(pages.length, equals(3));

      // Redo delete: should remove at pageIndex 1
      final redoDelete = history.redo();
      expect(redoDelete, isNotNull);
      pages.removeAt(redoDelete.pageIndex);
      expect(pages.length, equals(2));
    });
  });
}
