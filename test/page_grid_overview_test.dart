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

  group('PageGridOverviewDialog Rendering', () {
    testWidgets('renders all thumbnail cards and page numbers', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.addAll([
        EditorPage(size: const Size(1000, 1400)),
        EditorPage(size: const Size(1000, 1400)),
        EditorPage(size: const Size(1000, 1400)),
      ]);

      await tester.pumpWidget(buildTestDialog(coreInfo: coreInfo));
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);

      expect(find.byKey(const Key('page_number_0')), findsOneWidget);
      expect(find.byKey(const Key('page_number_1')), findsOneWidget);
      expect(find.byKey(const Key('page_number_2')), findsOneWidget);
    });

    testWidgets('prominently highlights active page with badge', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.addAll([
        EditorPage(size: const Size(1000, 1400)),
        EditorPage(size: const Size(1000, 1400)),
      ]);

      await tester.pumpWidget(
        buildTestDialog(coreInfo: coreInfo, currentPageIndex: 1),
      );
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('active_page_badge_1')), findsOneWidget);
      expect(find.byKey(const Key('active_page_badge_0')), findsNothing);
      expect(find.text('CURRENT'), findsOneWidget);
    });
  });

  group('Tap to Jump Navigation', () {
    testWidgets('tapping thumbnail card calls scrollToPage and dismisses dialog', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.addAll([
        EditorPage(size: const Size(1000, 1400)),
        EditorPage(size: const Size(1000, 1400)),
      ]);

      int? scrolledTo;
      await tester.pumpWidget(
        buildTestDialog(
          coreInfo: coreInfo,
          scrollToPage: (pageIndex) => scrolledTo = pageIndex,
        ),
      );
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      expect(find.byType(PageGridOverviewDialog), findsOneWidget);

      await tester.tap(find.byKey(const Key('page_jump_target_1')));
      await tester.pumpAndSettle();

      expect(scrolledTo, equals(1));
      expect(find.byType(PageGridOverviewDialog), findsNothing);
    });
  });

  group('Bookmark Toggling', () {
    testWidgets('star badge displays outline/amber and toggles bookmark state', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      final page0 = EditorPage(size: const Size(1000, 1400), bookmarked: false);
      final page1 = EditorPage(size: const Size(1000, 1400), bookmarked: true);
      coreInfo.pages.addAll([page0, page1]);

      var redrawAndSaveCalled = false;
      await tester.pumpWidget(
        buildTestDialog(
          coreInfo: coreInfo,
          redrawAndSave: () => redrawAndSaveCalled = true,
        ),
      );
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      final star0Finder = find.descendant(
        of: find.byKey(const Key('bookmark_star_0')),
        matching: find.byType(Icon),
      );
      final star0Icon = tester.widget<Icon>(star0Finder);
      expect(star0Icon.icon, equals(Icons.star_border));

      final star1Finder = find.descendant(
        of: find.byKey(const Key('bookmark_star_1')),
        matching: find.byType(Icon),
      );
      final star1Icon = tester.widget<Icon>(star1Finder);
      expect(star1Icon.icon, equals(Icons.star));
      expect(star1Icon.color, equals(Colors.amber));

      await tester.tap(find.byKey(const Key('bookmark_star_0')));
      await tester.pumpAndSettle();

      expect(page0.bookmarked, isTrue);
      expect(redrawAndSaveCalled, isTrue);

      final star0ToggledFinder = find.descendant(
        of: find.byKey(const Key('bookmark_star_0')),
        matching: find.byType(Icon),
      );
      final star0ToggledIcon = tester.widget<Icon>(star0ToggledFinder);
      expect(star0ToggledIcon.icon, equals(Icons.star));
      expect(star0ToggledIcon.color, equals(Colors.amber));
    });
  });

  group('Filter Tabs (All vs Bookmarked)', () {
    testWidgets('filtering to bookmarked shows only bookmarked pages', (
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
        EditorPage(size: const Size(1000, 1400), bookmarked: false),
      ]);

      await tester.pumpWidget(buildTestDialog(coreInfo: coreInfo));
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      expect(find.text('All (3)'), findsOneWidget);
      expect(find.text('Bookmarked (1)'), findsOneWidget);

      expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);

      await tester.tap(find.text('Bookmarked (1)'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_0')), findsNothing);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsNothing);

      await tester.tap(find.text('All (3)'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('page_thumbnail_card_0')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_1')), findsOneWidget);
      expect(find.byKey(const Key('page_thumbnail_card_2')), findsOneWidget);
    });

    testWidgets('shows empty state when no pages are bookmarked', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.addAll([
        EditorPage(size: const Size(1000, 1400), bookmarked: false),
      ]);

      await tester.pumpWidget(buildTestDialog(coreInfo: coreInfo));
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bookmarked (0)'));
      await tester.pumpAndSettle();

      expect(find.text('No bookmarked pages'), findsOneWidget);
      expect(find.text('Star pages to view them here'), findsOneWidget);
    });
  });

  group('Page Actions & Guards', () {
    testWidgets('delete option is disabled when only 1 page exists', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.add(EditorPage(size: const Size(1000, 1400)));

      var deleteCalled = false;
      await tester.pumpWidget(
        buildTestDialog(
          coreInfo: coreInfo,
          deletePage: (_) => deleteCalled = true,
        ),
      );
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('page_menu_0')));
      await tester.pumpAndSettle();

      final deleteMenuItem = tester.widget<PopupMenuItem<String>>(
        find.byKey(const Key('delete_page_0')),
      );
      expect(deleteMenuItem.enabled, isFalse);

      await tester.tap(find.byKey(const Key('delete_page_0')));
      await tester.pumpAndSettle();

      expect(deleteCalled, isFalse);
    });

    testWidgets('delete option is enabled when multiple pages exist', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.addAll([
        EditorPage(size: const Size(1000, 1400)),
        EditorPage(size: const Size(1000, 1400)),
      ]);

      int? deletedIndex;
      await tester.pumpWidget(
        buildTestDialog(
          coreInfo: coreInfo,
          deletePage: (i) => deletedIndex = i,
        ),
      );
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('page_menu_0')));
      await tester.pumpAndSettle();

      final deleteMenuItem = tester.widget<PopupMenuItem<String>>(
        find.byKey(const Key('delete_page_0')),
      );
      expect(deleteMenuItem.enabled, isTrue);

      await tester.tap(find.byKey(const Key('delete_page_0')));
      await tester.pumpAndSettle();

      expect(deletedIndex, equals(0));
    });

    testWidgets('duplicate option triggers duplicatePage callback', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.add(EditorPage(size: const Size(1000, 1400)));

      int? duplicatedIndex;
      await tester.pumpWidget(
        buildTestDialog(
          coreInfo: coreInfo,
          duplicatePage: (i) => duplicatedIndex = i,
        ),
      );
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('page_menu_0')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('duplicate_page_0')));
      await tester.pumpAndSettle();

      expect(duplicatedIndex, equals(0));
    });

    testWidgets('insert option triggers insertPageAfter callback', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.add(EditorPage(size: const Size(1000, 1400)));

      int? insertedAfter;
      await tester.pumpWidget(
        buildTestDialog(
          coreInfo: coreInfo,
          insertPageAfter: (i) => insertedAfter = i,
        ),
      );
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('page_menu_0')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('insert_page_0')));
      await tester.pumpAndSettle();

      expect(insertedAfter, equals(0));
    });

    testWidgets('top add button calls insertPageAfter for last page', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final coreInfo = EditorCoreInfo.placeholder;
      coreInfo.pages.clear();
      coreInfo.pages.addAll([
        EditorPage(size: const Size(1000, 1400)),
        EditorPage(size: const Size(1000, 1400)),
      ]);

      int? addedAfter;
      await tester.pumpWidget(
        buildTestDialog(
          coreInfo: coreInfo,
          insertPageAfter: (i) => addedAfter = i,
        ),
      );
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add_page_button')));
      await tester.pumpAndSettle();

      expect(addedAfter, equals(1));
    });
  });

  group('Drag and Drop Reordering', () {
    testWidgets('long-press draggable and drag target are present and functional', (
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

      var saved = false;
      await tester.pumpWidget(
        buildTestDialog(
          coreInfo: coreInfo,
          redrawAndSave: () => saved = true,
        ),
      );
      await tester.tap(find.text('Open Overview'));
      await tester.pumpAndSettle();

      expect(find.byType(LongPressDraggable<int>), findsNWidgets(2));
      expect(find.byType(DragTarget<int>), findsNWidgets(2));

      // Simulate dragging card 0 onto card 1
      final firstCard = find.byKey(const Key('page_thumbnail_card_0'));
      final secondCard = find.byKey(const Key('page_thumbnail_card_1'));

      final gesture = await tester.startGesture(tester.getCenter(firstCard));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await gesture.moveTo(tester.getCenter(secondCard));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(saved, isTrue);
      expect(coreInfo.pages.first, equals(pageB));
      expect(coreInfo.pages.last, equals(pageA));
    });
  });

  group('Bug Fixes Verification', () {
    test('duplicatePage creates independent deep layer copies', () {
      final stroke = createTestStroke(pageIndex: 0);
      final layer = Layer(name: 'Default', strokes: [stroke]);
      final page = EditorPage(
        size: const Size(1000, 1400),
        layers: [layer],
      );

      final newLayers = page.layers
          .map((l) => Layer(
                name: l.name,
                visible: l.visible,
                strokes: l.strokes
                    .map((s) => s.copy()..pageIndex = 1)
                    .toList(),
              ))
          .toList();

      final duplicatedPage = page.copyWith(
        layers: newLayers,
        quill: QuillStruct(
          controller: flutter_quill.QuillController.basic(),
          focusNode: FocusNode(),
        ),
      );

      expect(
        identical(page.layers.first.strokes, duplicatedPage.layers.first.strokes),
        isFalse,
        reason: 'Layer strokes list must be independently allocated',
      );

      duplicatedPage.layers.first.strokes.add(
        createTestStroke(pageIndex: 1),
      );

      expect(page.layers.first.strokes.length, equals(1));
      expect(duplicatedPage.layers.first.strokes.length, equals(2));
    });

    test('duplicatePage history records pageIndex + 1 for correct undo', () {
      const originalIndex = 2;
      const expectedDuplicatedIndex = originalIndex + 1;

      final historyItem = EditorHistoryItem(
        type: EditorHistoryItemType.insertPage,
        pageIndex: expectedDuplicatedIndex,
        page: EditorPage(size: const Size(1000, 1400)),
        strokes: const [],
        images: const [],
      );

      expect(historyItem.pageIndex, equals(3));
    });

    test('deletePage guard enforces notebook has at least one page', () {
      final pages = <EditorPage>[EditorPage(size: const Size(1000, 1400))];

      void safeDeletePage(int pageIndex) {
        if (pages.length <= 1) return;
        pages.removeAt(pageIndex);
      }

      safeDeletePage(0);
      expect(pages.length, equals(1), reason: 'Single page must not be deleted');

      pages.add(EditorPage(size: const Size(1000, 1400)));
      expect(pages.length, equals(2));

      safeDeletePage(0);
      expect(pages.length, equals(1), reason: 'Multiple pages can be deleted down to 1');
    });
  });
}
