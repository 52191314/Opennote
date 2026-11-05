/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:path/path.dart' as p;
import 'package:saber/components/canvas/pencil_shader.dart';
import 'package:saber/components/home/syncing_button.dart';
import 'package:saber/components/settings/nextcloud_profile.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/sentry/sentry_init.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';
import 'package:saber/pages/home/home.dart';
import 'package:yaru/yaru.dart';

import 'utils/test_mock_channel_handlers.dart';
import 'utils/test_user.dart';

Future<void> setupDemoFiles() async {
  const demoFiles = <String>[
    '/Annotate images and diagrams.sbn2',
    '/Golden ratio.sbn2',
    '/Import PDFs.sbn2',
    '/Metric Spaces Week 1.sbn2',
    '/DistSystems MapReduce.sbn2',
    '/You can type notes too!.sbn2',
  ];
  final fillerFiles = <String>[];
  final demoDir = Directory('test/demo_notes');
  for (final file in demoDir.listSync().whereType<File>()) {
    final baseName = p.basename(file.path);
    final fileName = '/$baseName';
    if (baseName.endsWith('.sbn2') || baseName.endsWith('.sbn')) {
      if (!demoFiles.contains(fileName)) fillerFiles.add(fileName);
    }
    final bytes = await file.readAsBytes();
    final dstFile = FileManager.getFile(fileName);
    await dstFile.create(recursive: true);
    await dstFile.writeAsBytes(bytes);
  }
  stows.recentFiles.value = [...demoFiles, ...fillerFiles..sort()];
}

void main() {
  group('PlayStoreScreenshots:', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    BackgroundIsolateBinaryMessenger.ensureInitialized(
      ServicesBinding.rootIsolateToken!,
    );

    setupMockPathProvider();
    setupMockPrinting();
    disableSentryForTesting();

    FlavorConfig.setup();
    SyncingButton.debugForceButtonActive = true;

    stows.lastStorageQuota.value = TestUser.getQuota();
    stows.username.value = 'engineering_vault';
    stows.sentryConsent.value = .granted;

    setUpAll(() async {
      await Future.wait([
        FileManager.init(shouldWatchRootDirectory: false),
        PencilShader.init(),
      ]);
      await setupDemoFiles();
    });

    const seedColor = YaruColors.blue;
    final lightTheme = SaberTheme.createThemeFromSeed(
      seedColor,
      .light,
      .android,
    );
    final darkTheme = SaberTheme.createThemeFromSeed(
      seedColor,
      .dark,
      .android,
    );

    void captureScreen({
      required String goldenFileName,
      required Widget child,
      ThemeData? themeOverride,
      bool isSettings = false,
    }) {
      testGoldens(goldenFileName, (tester) async {
        final device = GoldenScreenshotDevices.androidPhone.device;
        stows.platform.value = device.platform;
        await tester.runAsync(() => LocaleSettings.setLocaleRaw('en'));

        if (isSettings) {
          NextcloudProfile.forceLoginStep = .done;
          addTearDown(() => NextcloudProfile.forceLoginStep = null);
        }

        final theme = themeOverride ?? lightTheme;
        final widget = ScreenshotApp.withConditionalTitlebar(
          theme: theme,
          device: device,
          title: 'Opennote',
          home: TranslationProvider(child: child),
        );
        await tester.pumpWidget(widget);
        await tester.pump();

        for (final editorState in tester.stateList<EditorState>(
          find.byType(Editor),
        )) {
          int attempts = 0;
          while (editorState.coreInfo.isEmpty && attempts < 30) {
            attempts++;
            await tester.runAsync(
              () => Future.delayed(const Duration(milliseconds: 100)),
            );
            await tester.pump();
          }
        }

        await tester.loadAssets();
        await tester.pumpAndSettle();

        await tester.expectScreenshot(
          device,
          goldenFileName,
          langCode: 'en-US',
        );
      });
    }

    // 1. Home Shelf: Notebook shelf & recent engineering notebooks
    captureScreen(
      goldenFileName: '1_home',
      child: const HomePage(subpage: HomePage.recentSubpage, path: ''),
    );

    // 2. Editor: Engineering calculations & metric spaces
    captureScreen(
      goldenFileName: '2_editor',
      child: Editor(path: '/Metric Spaces Week 1'),
    );

    // 3. Technical diagrams and annotations
    captureScreen(
      goldenFileName: '3_diagrams',
      child: Editor(path: '/DistSystems MapReduce'),
    );

    // 4. Mathematical geometry & golden ratio
    captureScreen(
      goldenFileName: '4_math',
      child: Editor(path: '/Golden ratio'),
    );

    // 5. PDF Annotation & document markup
    captureScreen(
      goldenFileName: '5_pdf',
      child: Editor(path: '/Import PDFs'),
    );

    // 6. OLED Dark Mode with inverted ink
    captureScreen(
      goldenFileName: '6_dark_mode',
      themeOverride: darkTheme,
      child: Editor(path: '/Metric Spaces Week 1'),
    );

    // 7. Settings & Zero-Knowledge Encrypted Sync
    captureScreen(
      goldenFileName: '7_settings',
      isSettings: true,
      child: const HomePage(subpage: HomePage.settingsSubpage, path: ''),
    );
  });
}
