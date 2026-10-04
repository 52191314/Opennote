/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/editor/page_grid_overview.dart';
import 'package:saber/components/editor/template_picker_dialog.dart';
import 'package:saber/components/toolbar/drafting_tools_popup.dart';
import 'package:saber/components/toolbar/eraser_size_popup.dart';
import 'package:saber/components/toolbar/lasso_filter_popup.dart';
import 'package:saber/components/toolbar/selection_bar.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';
import 'package:saber/pages/home/home.dart';
import 'package:saber/pages/logs.dart';
import 'package:saber/pages/user/login.dart';

import 'utils/test_mock_channel_handlers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockPathProvider();
    setupMockPrinting();
    FlavorConfig.setup();
    FileManager.documentsDirectory = '/test_documents';
    stows.sentryConsent.value = .granted;
  });

  Widget wrapWithApp(
    Widget child, {
    Size size = const Size(360, 640),
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: themeMode,
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: child,
          ),
        ),
      ),
    );
  }

  group('Home Page Subpages UI Tests (Phone 360x640 & Tablet 800x1280)', () {
    const phoneSize = Size(360, 640);
    const tabletSize = Size(800, 1280);

    for (final subpage in HomePage.subpages) {
      testWidgets('HomePage $subpage on phone ($phoneSize)', (tester) async {
        tester.view.physicalSize = phoneSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          wrapWithApp(HomePage(subpage: subpage, path: ''), size: phoneSize),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(tester.takeException(), isNull);
      });

      testWidgets('HomePage $subpage on tablet ($tabletSize)', (tester) async {
        tester.view.physicalSize = tabletSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          wrapWithApp(HomePage(subpage: subpage, path: ''), size: tabletSize),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Logs Page & Login Page UI Tests', () {
    const phoneSize = Size(360, 640);

    testWidgets('LogsPage on phone renders without error', (tester) async {
      tester.view.physicalSize = phoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithApp(const LogsPage(), size: phoneSize));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    });

    testWidgets('NcLoginPage on phone renders without error', (tester) async {
      tester.view.physicalSize = phoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(wrapWithApp(const NcLoginPage(), size: phoneSize));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    });
  });

  group('Dialogs & Popups UI Tests', () {
    const phoneSize = Size(360, 640);

    testWidgets('DraftingToolsPopup renders without error', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          DraftingToolsPopup(
            currentTool: Pen.currentPen,
            onSelectTool: (_) {},
            onPickShape: () {},
          ),
          size: phoneSize,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('EraserSizePopup renders without error', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          const EraserSizePopup(),
          size: phoneSize,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('LassoFilterPopup renders without error', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          const LassoFilterPopup(),
          size: phoneSize,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('TemplatePickerDialog renders without error', (tester) async {
      final coreInfo = EditorCoreInfo(filePath: 'test.sbn2');
      coreInfo.pages.add(EditorPage());
      await tester.pumpWidget(
        wrapWithApp(
          TemplatePickerDialog(
            coreInfo: coreInfo,
            currentPageIndex: 0,
            invert: false,
            onTemplateSelected: (_) {},
          ),
          size: phoneSize,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('PageGridOverviewDialog renders without error', (tester) async {
      final coreInfo = EditorCoreInfo(filePath: 'test.sbn2');
      coreInfo.pages.add(EditorPage());
      await tester.pumpWidget(
        wrapWithApp(
          PageGridOverviewDialog(
            coreInfo: coreInfo,
            currentPageIndex: 0,
            scrollToPage: (_) {},
            redrawAndSave: () {},
            duplicatePage: (_) {},
            deletePage: (_) {},
            insertPageAfter: (_) {},
          ),
          size: phoneSize,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('SelectionBar (Floating Lasso Callout Bar) renders without error', (tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          Scaffold(
            body: SelectionBar(
              duplicateSelection: () {},
              deleteSelection: () {},
              copySelection: () {},
              pasteSelection: () {},
              cropPossible: false,
              cropActive: false,
              toggleCrop: () {},
            ),
          ),
          size: phoneSize,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('Editor UI Tests Across Form Factors', () {
    const testCases = [
      ('Phone Compact (360x640)', Size(360, 640)),
      ('iPhone / Modern Phone (390x844)', Size(390, 844)),
      ('Tablet (800x1280)', Size(800, 1280)),
      ('Desktop (1920x1080)', Size(1920, 1080)),
    ];

    for (final (label, size) in testCases) {
      testWidgets('Editor renders cleanly on $label', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          wrapWithApp(
            Editor(
              path: '/test_responsive_note',
              customTitle: 'My Lecture Notes',
            ),
            size: size,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Dark Mode Theme Tests across Key Screens', () {
    const phoneSize = Size(360, 640);

    testWidgets('Editor renders cleanly in Dark Theme', (tester) async {
      tester.view.physicalSize = phoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        wrapWithApp(
          Editor(
            path: '/test_dark_note',
            customTitle: 'Dark Mode Notes',
          ),
          size: phoneSize,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    });

    testWidgets('TemplatePickerDialog renders cleanly in Dark Theme', (tester) async {
      final coreInfo = EditorCoreInfo(filePath: 'test_dark.sbn2');
      coreInfo.pages.add(EditorPage());
      await tester.pumpWidget(
        wrapWithApp(
          TemplatePickerDialog(
            coreInfo: coreInfo,
            currentPageIndex: 0,
            invert: true,
            onTemplateSelected: (_) {},
          ),
          size: phoneSize,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('PageGridOverviewDialog renders cleanly in Dark Theme', (tester) async {
      final coreInfo = EditorCoreInfo(filePath: 'test_dark.sbn2');
      coreInfo.pages.add(EditorPage());
      await tester.pumpWidget(
        wrapWithApp(
          PageGridOverviewDialog(
            coreInfo: coreInfo,
            currentPageIndex: 0,
            scrollToPage: (_) {},
            redrawAndSave: () {},
            duplicatePage: (_) {},
            deletePage: (_) {},
            insertPageAfter: (_) {},
          ),
          size: phoneSize,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
