/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/home/preview_card.dart';
import 'package:saber/components/home/preview_card/preview_card_footer.dart';
import 'package:saber/components/home/quick_template_strip.dart';
import 'package:saber/components/home/studio_filter_bar.dart';
import 'package:saber/components/home/welcome.dart';
import 'package:saber/components/navbar/horizontal_navbar.dart';
import 'package:saber/components/navbar/vertical_navbar.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/home/browse.dart';
import 'package:saber/pages/home/recent_notes.dart';

import '../../utils/test_mock_channel_handlers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    FlavorConfig.setup();
    setupMockPathProvider();
    stows.sentryConsent.value = .granted;
    await FileManager.init(shouldWatchRootDirectory: false);
  });

  Widget wrapWithApp(Widget child, {Size size = const Size(390, 844)}) {
    return TranslationProvider(
      child: MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  group('QuickTemplateStrip', () {
    testWidgets(
      'renders all 6 templates including PRO badge and fires callbacks',
      (tester) async {
        QuickTemplateKind? createdTemplate;
        QuickTemplateKind? proTemplate;

        await tester.pumpWidget(
          wrapWithApp(
            QuickTemplateStrip(
              onCreateTemplate: (kind) => createdTemplate = kind,
              onProTemplateTap: (kind) => proTemplate = kind,
            ),
            size: const Size(1024, 768),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Blank Page'), findsOneWidget);
        expect(find.text('Engineering Grid'), findsOneWidget);
        expect(find.text('Dot Matrix'), findsOneWidget);
        expect(find.text('Cornell Study'), findsOneWidget);
        expect(find.text('Infinite Canvas'), findsOneWidget);
        expect(find.text('Import PDF'), findsOneWidget);
        expect(find.text('PRO'), findsOneWidget);

        await tester.tap(
          find.byKey(const ValueKey('QuickTemplate_engineeringGrid')),
        );
        await tester.pump();
        expect(createdTemplate, QuickTemplateKind.engineeringGrid);

        await tester.tap(
          find.byKey(const ValueKey('QuickTemplate_infiniteCanvas')),
        );
        await tester.pump();
        expect(proTemplate, QuickTemplateKind.infiniteCanvas);
      },
    );

    testWidgets('renders cleanly without overflow on narrow mobile (360px)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrapWithApp(const QuickTemplateStrip(), size: const Size(360, 740)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Blank Page'), findsOneWidget);
    });
  });

  group('StudioFilterBar', () {
    testWidgets('fires filter, sort, view toggle, and search callbacks', (
      tester,
    ) async {
      var activeFilter = LibraryFilter.all;
      var sortOrder = LibrarySortOrder.recent;
      var studioMode = true;
      var searchTapped = false;

      await tester.pumpWidget(
        wrapWithApp(
          StatefulBuilder(
            builder: (context, setState) => StudioFilterBar(
              activeFilter: activeFilter,
              onFilterChanged: (f) => setState(() => activeFilter = f),
              sortOrder: sortOrder,
              onSortChanged: (s) => setState(() => sortOrder = s),
              isStudioMode: studioMode,
              onToggleViewMode: () => setState(() => studioMode = !studioMode),
              onSearchTap: () => searchTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Recent'));
      await tester.pump();
      expect(activeFilter, LibraryFilter.recent);

      await tester.tap(find.byKey(const ValueKey('StudioSortToggle')));
      await tester.pump();
      expect(sortOrder, LibrarySortOrder.name);

      await tester.tap(find.byKey(const ValueKey('StudioViewToggle')));
      await tester.pump();
      expect(studioMode, isFalse);

      await tester.tap(find.byKey(const ValueKey('StudioSearchPill')));
      await tester.pump();
      expect(searchTapped, isTrue);
    });
  });

  group('Welcome empty-state studio card', () {
    testWidgets(
      'renders Start Your First Notebook, welcome text, and templates',
      (tester) async {
        QuickTemplateKind? selectedTemplate;

        await tester.pumpWidget(
          wrapWithApp(
            SingleChildScrollView(
              child: Welcome(
                onCreateTemplate: (kind) => selectedTemplate = kind,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Start Your First Notebook'), findsOneWidget);
        expect(find.text(t.home.welcome), findsOneWidget);
        expect(find.byType(QuickTemplateStrip), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('QuickTemplate_blankPage')));
        await tester.pump();
        expect(selectedTemplate, QuickTemplateKind.blankPage);
      },
    );
  });

  group('PreviewCard remodularization', () {
    testWidgets(
      'renders title, folder metadata, action menu, and selection toggle',
      (tester) async {
        String? toggledPath;
        bool? toggledValue;

        await tester.pumpWidget(
          wrapWithApp(
            SizedBox(
              width: 200,
              child: PreviewCard(
                filePath: '/Physics/Thermodynamics',
                selected: false,
                isAnythingSelected: false,
                toggleSelection: (path, selected) {
                  toggledPath = path;
                  toggledValue = selected;
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('PreviewCard/Physics/Thermodynamics')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(PreviewCardFooter),
            matching: find.text('Thermodynamics'),
          ),
          findsOneWidget,
        );
        expect(find.text('Physics'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.more_vert_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Select'), findsOneWidget);
        expect(find.text(t.home.renameNote.renameNote), findsOneWidget);
        expect(
          find.text('${t.home.tooltips.exportNote} (PDF)'),
          findsOneWidget,
        );
        expect(find.text(t.home.deleteNote), findsOneWidget);

        await tester.tap(find.text('Select'));
        await tester.pumpAndSettle();

        expect(toggledPath, '/Physics/Thermodynamics');
        expect(toggledValue, isTrue);
      },
    );
  });

  group('Home & Browse banner slots', () {
    testWidgets('RecentPage renders proBannerBuilder slot', (tester) async {
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(
            home: RecentPage(
              proBannerBuilder: (_) => const Text('Upgrade to Opennote Pro'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upgrade to Opennote Pro'), findsOneWidget);
      expect(find.byType(StudioFilterBar), findsOneWidget);
    });

    testWidgets('BrowsePage renders topBanner slot with folders and files', (
      tester,
    ) async {
      BrowsePage.overrideChildren = DirectoryChildren(
        const ['Lecture Notes'],
        const ['Calculus'],
      );
      addTearDown(() => BrowsePage.overrideChildren = null);

      await tester.pumpWidget(
        TranslationProvider(
          child: const MaterialApp(
            home: BrowsePage(topBanner: Text('Pro Cloud Sync Banner')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pro Cloud Sync Banner'), findsOneWidget);
      expect(find.byType(StudioFilterBar), findsOneWidget);
      expect(find.text('Lecture Notes'), findsOneWidget);
    });
  });

  group('Navbar refinements', () {
    testWidgets('HorizontalNavbar renders destinations and fires selection', (
      tester,
    ) async {
      int? selected;
      const destinations = [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.folder), label: 'Browse'),
        NavigationDestination(icon: Icon(Icons.draw), label: 'Board'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ];

      await tester.pumpWidget(
        wrapWithApp(
          HorizontalNavbar(
            destinations: destinations,
            selectedIndex: 0,
            onDestinationSelected: (i) => selected = i,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();
      expect(selected, 3);
    });

    testWidgets('VerticalNavbar renders studio rail and fires selection', (
      tester,
    ) async {
      int? selected;
      const destinations = [
        NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
        NavigationRailDestination(
          icon: Icon(Icons.folder),
          label: Text('Browse'),
        ),
        NavigationRailDestination(icon: Icon(Icons.draw), label: Text('Board')),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ];

      await tester.pumpWidget(
        wrapWithApp(
          Row(
            children: [
              VerticalNavbar(
                destinations: destinations,
                selectedIndex: 1,
                onDestinationSelected: (i) => selected = i,
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          size: const Size(1100, 800),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Opennote'), findsOneWidget);
      await tester.tap(find.text('Settings'));
      await tester.pump();
      expect(selected, 3);
    });
  });
}
