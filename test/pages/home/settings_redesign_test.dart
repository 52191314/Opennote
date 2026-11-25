/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/settings/app_info.dart';
import 'package:saber/components/settings/nextcloud_profile.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/home/settings.dart';
import 'package:saber/pages/user/login.dart';

import '../../utils/test_mock_channel_handlers.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockPathProvider();
    FlavorConfig.setup();
    FileManager.documentsDirectory = '/test_documents';
    stows.sentryConsent.value = .granted;
  });

  tearDown(() {
    NextcloudProfile.forceLoginStep = null;
  });

  Widget wrapSettings(
    Widget child, {
    Size size = const Size(390, 844),
    ThemeMode themeMode = ThemeMode.light,
    TargetPlatform platform = TargetPlatform.android,
  }) {
    return TranslationProvider(
      child: MaterialApp(
        theme: ThemeData.light(useMaterial3: true).copyWith(platform: platform),
        darkTheme: ThemeData.dark(
          useMaterial3: true,
        ).copyWith(platform: platform),
        themeMode: themeMode,
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: SizedBox(width: size.width, height: size.height, child: child),
        ),
      ),
    );
  }

  group('Opennote Pro Membership Card', () {
    testWidgets('renders Free trial upgrade card and fires callbacks', (
      tester,
    ) async {
      var upgradeTapped = false;
      var restoreTapped = false;
      NextcloudProfile.forceLoginStep = .nc;

      await tester.pumpWidget(
        wrapSettings(
          SettingsPage(
            isPro: false,
            onUpgradeTap: () => upgradeTapped = true,
            onRestorePurchasesTap: () => restoreTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Unlock Opennote Pro · 7-Day Free Trial'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('pro-active-badge')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('pro-upgrade-button')));
      await tester.pump();
      expect(upgradeTapped, isTrue);

      await tester.tap(find.byKey(const ValueKey('pro-card-restore-button')));
      await tester.pump();
      expect(restoreTapped, isTrue);

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders active Pro badge, plan summary, and manage button', (
      tester,
    ) async {
      var manageTapped = false;
      NextcloudProfile.forceLoginStep = .nc;

      await tester.pumpWidget(
        wrapSettings(
          SettingsPage(
            isPro: true,
            planSummary: 'Annual Pro · Renews Nov 2027',
            onUpgradeTap: () => manageTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('pro-active-badge')), findsOneWidget);
      expect(find.text('PRO ACTIVE'), findsOneWidget);
      expect(find.text('Annual Pro · Renews Nov 2027'), findsOneWidget);
      expect(find.text('Unlock Opennote Pro · 7-Day Free Trial'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('pro-manage-button')));
      await tester.pump();
      expect(manageTapped, isTrue);

      expect(tester.takeException(), isNull);
    });
  });

  group('Support & Community callbacks and Bento sections', () {
    testWidgets('fires Rate, Share, Restore, and Welcome Tour callbacks', (
      tester,
    ) async {
      var rateTapped = false;
      var shareTapped = false;
      var restoreTapped = false;
      var tourTapped = false;
      NextcloudProfile.forceLoginStep = .nc;

      await tester.pumpWidget(
        wrapSettings(
          SettingsPage(
            onRateAppTap: () => rateTapped = true,
            onShareAppTap: () => shareTapped = true,
            onRestorePurchasesTap: () => restoreTapped = true,
            onRevisitWelcomeTourTap: () => tourTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Filter directly to Support & Community so all 4 rows are immediately visible
      final supportChip = find.byKey(
        const ValueKey('settings-category-supportCommunity'),
      );
      await tester.ensureVisible(supportChip);
      await tester.pumpAndSettle();
      await tester.tap(supportChip);
      await tester.pumpAndSettle();

      expect(find.text('Rate Opennote on Play Store'), findsOneWidget);
      expect(find.text('Share Opennote'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);
      expect(find.text('Revisit Welcome Tour'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('settings-rate-opennote')));
      await tester.tap(find.byKey(const ValueKey('settings-share-opennote')));
      await tester.tap(
        find.byKey(const ValueKey('settings-restore-purchases')),
      );
      await tester.tap(
        find.byKey(const ValueKey('settings-revisit-welcome-tour')),
      );
      await tester.pump();

      expect(rateTapped, isTrue);
      expect(shareTapped, isTrue);
      expect(restoreTapped, isTrue);
      expect(tourTapped, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses App Store copy on iOS platform', (tester) async {
      NextcloudProfile.forceLoginStep = .nc;

      await tester.pumpWidget(
        wrapSettings(const SettingsPage(), platform: TargetPlatform.iOS),
      );
      await tester.pumpAndSettle();

      final supportChip = find.byKey(
        const ValueKey('settings-category-supportCommunity'),
      );
      await tester.ensureVisible(supportChip);
      await tester.pumpAndSettle();
      await tester.tap(supportChip);
      await tester.pumpAndSettle();

      expect(find.text('Rate Opennote on App Store'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Responsive Mobile & Tablet Layouts (Zero Overflow)', () {
    const viewports = [
      ('Mobile Compact 360x640 Light', Size(360, 640), ThemeMode.light),
      ('Mobile Modern 390x844 Dark', Size(390, 844), ThemeMode.dark),
      ('Tablet 800x1280 Light', Size(800, 1280), ThemeMode.light),
      ('Wide Tablet 1280x900 Dark', Size(1280, 900), ThemeMode.dark),
    ];

    for (final (label, size, themeMode) in viewports) {
      testWidgets('renders $label with zero overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        NextcloudProfile.forceLoginStep = .nc;

        await tester.pumpWidget(
          wrapSettings(
            const SettingsPage(isPro: false),
            size: size,
            themeMode: themeMode,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('opennote-pro-membership-card')),
          findsOneWidget,
        );
        expect(find.text('Cloud Sync (Nextcloud / WebDAV)'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Opennote Brand Hygiene Audit', () {
    test('AppInfo and NcLoginPage URLs contain no legacy Saber leaks', () {
      final urls = [
        AppInfo.sponsorUrl,
        AppInfo.privacyPolicyUrl,
        AppInfo.licenseUrl,
        AppInfo.releasesUrl,
        NcLoginPage.signupUrl,
      ];

      for (final uri in urls) {
        expect(uri.toString().toLowerCase(), isNot(contains('saber')));
        expect(uri.toString().toLowerCase(), isNot(contains('adil192')));
      }
    });
  });
}
