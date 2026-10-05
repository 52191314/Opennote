/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Feature 10: iOS Packaging Pipeline & Unsigned IPA (ORIGINAL_REQUEST § R4)',
    () {
      late String codemagicContent;
      late String podfileContent;
      late String infoPlistContent;
      late String projectPbxprojContent;

      setUpAll(() {
        final codemagicFile = File('codemagic.yaml');
        expect(
          codemagicFile.existsSync(),
          isTrue,
          reason: 'codemagic.yaml must exist',
        );
        codemagicContent = codemagicFile.readAsStringSync();

        final podfile = File('ios/Podfile');
        expect(podfile.existsSync(), isTrue, reason: 'ios/Podfile must exist');
        podfileContent = podfile.readAsStringSync();

        final infoPlist = File('ios/Runner/Info.plist');
        expect(
          infoPlist.existsSync(),
          isTrue,
          reason: 'ios/Runner/Info.plist must exist',
        );
        infoPlistContent = infoPlist.readAsStringSync();

        final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj');
        expect(
          pbxproj.existsSync(),
          isTrue,
          reason: 'project.pbxproj must exist',
        );
        projectPbxprojContent = pbxproj.readAsStringSync();
      });

      // -------------------------------------------------------------
      // Tier 1: Feature Coverage (>=5 tests)
      // -------------------------------------------------------------
      test(
        'T1.1: codemagic.yaml defines build-ios workflow with mac_mini_m2',
        () {
          expect(codemagicContent, contains('build-ios:'));
          expect(codemagicContent, contains('name: Build iOS IPA'));
          expect(codemagicContent, contains('instance_type: mac_mini_m2'));
          expect(codemagicContent, contains('max_build_duration: 60'));
        },
      );

      test('T1.2: codemagic.yaml resolves root and nested dependencies', () {
        expect(codemagicContent, contains('flutter pub get'));
        expect(codemagicContent, contains('--directory=packages/sbn'));
        expect(codemagicContent, contains('--directory=packages/onyxsdk_pen'));
      });

      test('T1.3: codemagic.yaml executes release unsigned build', () {
        expect(
          codemagicContent,
          contains('flutter build ios --release --no-codesign'),
        );
      });

      test(
        'T1.4: codemagic.yaml packages Opennote.ipa from Payload staging',
        () {
          expect(codemagicContent, contains('mkdir -p Payload'));
          expect(codemagicContent, contains(r'cp -R "$APP" Payload/'));
          expect(codemagicContent, contains('zip -r Opennote.ipa Payload/'));
          expect(codemagicContent, contains('- Opennote.ipa'));
        },
      );

      test('T1.5: ios/Podfile platform declaration configuration', () {
        // Podfile should reference ios platform target (e.g. 14.0)
        expect(podfileContent, contains("platform :ios, '14.0'"));
      });

      // -------------------------------------------------------------
      // Tier 2: Boundary & Corner Cases (>=5 tests)
      // -------------------------------------------------------------
      test('T2.1: Info.plist sets CFBundleDisplayName to Opennote', () {
        expect(infoPlistContent, contains('<key>CFBundleDisplayName</key>'));
        expect(infoPlistContent, contains('<string>Opennote</string>'));
        expect(infoPlistContent, contains('<key>CFBundleName</key>'));
      });

      test('T2.2: project.pbxproj defines IPHONEOS_DEPLOYMENT_TARGET 14.0', () {
        expect(
          projectPbxprojContent,
          contains('IPHONEOS_DEPLOYMENT_TARGET = 14.0;'),
        );
      });

      test(
        'T2.3: project.pbxproj specifies INFOPLIST_KEY_CFBundleDisplayName',
        () {
          expect(
            projectPbxprojContent,
            contains('INFOPLIST_KEY_CFBundleDisplayName = Opennote;'),
          );
        },
      );

      test(
        'T2.4: codemagic.yaml guards against missing Runner.app with exit 1',
        () {
          expect(codemagicContent, contains(r'if [ ! -d "$APP" ]; then'));
          expect(codemagicContent, contains('ERROR: Runner.app not found!'));
          expect(codemagicContent, contains('exit 1'));
        },
      );

      test(
        'T2.5: Info.plist defines full iPad interface orientation support',
        () {
          expect(
            infoPlistContent,
            contains('<key>UISupportedInterfaceOrientations~ipad</key>'),
          );
          expect(
            infoPlistContent,
            contains('<string>UIInterfaceOrientationPortrait</string>'),
          );
          expect(
            infoPlistContent,
            contains('<string>UIInterfaceOrientationLandscapeLeft</string>'),
          );
          expect(
            infoPlistContent,
            contains('<string>UIInterfaceOrientationLandscapeRight</string>'),
          );
        },
      );
    },
  );
}
