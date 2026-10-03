/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('Codemagic Packaging Pipeline (codemagic.yaml)', () {
    late File codemagicFile;
    late String codemagicContent;
    late YamlMap codemagicYaml;
    late YamlMap buildIosWorkflow;

    setUpAll(() {
      codemagicFile = File('codemagic.yaml');
      expect(
        codemagicFile.existsSync(),
        isTrue,
        reason: 'codemagic.yaml must exist in root project directory',
      );
      codemagicContent = codemagicFile.readAsStringSync();
      final parsed = loadYaml(codemagicContent);
      expect(parsed, isA<YamlMap>());
      codemagicYaml = parsed as YamlMap;

      expect(
        codemagicYaml.containsKey('workflows'),
        isTrue,
        reason: 'codemagic.yaml must contain workflows root key',
      );
      final workflows = codemagicYaml['workflows'] as YamlMap;
      expect(
        workflows.containsKey('build-ios'),
        isTrue,
        reason: 'workflows must define build-ios workflow',
      );
      buildIosWorkflow = workflows['build-ios'] as YamlMap;
    });

    test('validates build-ios workflow environment and runner configuration', () {
      expect(
        buildIosWorkflow['instance_type'],
        equals('mac_mini_m2'),
        reason: 'iOS builds require a macOS runner instance',
      );

      final maxDuration = buildIosWorkflow['max_build_duration'];
      expect(maxDuration, isNotNull);
      expect(
        (maxDuration as num).toInt(),
        lessThanOrEqualTo(60),
        reason: 'Build timeout should be capped appropriately',
      );

      final environment = buildIosWorkflow['environment'] as YamlMap;
      expect(
        environment['flutter'],
        equals('stable'),
        reason: 'Flutter channel should be pinned to stable',
      );
      expect(
        environment['xcode'],
        equals('latest'),
        reason: 'Xcode version should target latest for iOS 14+ SDK support',
      );
    });

    test('validates dependency retrieval script covers all nested packages', () {
      final scripts = buildIosWorkflow['scripts'] as YamlList;
      final depScript = scripts.firstWhere(
        (script) =>
            script is YamlMap &&
            (script['name']?.toString().toLowerCase().contains('dependenc') ??
                false),
        orElse: () => null,
      ) as YamlMap?;

      expect(
        depScript,
        isNotNull,
        reason: 'Scripts must contain a step for fetching dependencies',
      );

      final scriptBody = depScript!['script'].toString();
      expect(
        scriptBody,
        contains('flutter pub get'),
        reason: 'Must resolve root project dependencies',
      );
      expect(
        scriptBody,
        contains('flutter pub get --directory=packages/sbn'),
        reason: 'Must resolve packages/sbn dependencies',
      );
      expect(
        scriptBody,
        contains('flutter pub get --directory=packages/onyxsdk_pen'),
        reason: 'Must resolve packages/onyxsdk_pen dependencies',
      );
    });

    test('validates unsigned iOS build flags and IPA packaging commands', () {
      final scripts = buildIosWorkflow['scripts'] as YamlList;
      final buildScript = scripts.firstWhere(
        (script) =>
            script is YamlMap &&
            (script['name']?.toString().toLowerCase().contains('package') ??
                false),
        orElse: () => null,
      ) as YamlMap?;

      expect(
        buildScript,
        isNotNull,
        reason: 'Scripts must contain a step for building iOS & packaging IPA',
      );

      final scriptBody = buildScript!['script'].toString();

      // Assert --no-codesign build flag
      expect(
        scriptBody,
        contains('flutter build ios --release --no-codesign'),
        reason:
            'Must build release iOS app without codesigning for unsigned IPA',
      );

      // Assert Runner.app path resolution and fallback checks
      expect(
        scriptBody,
        contains('Runner.app'),
        reason: 'Must locate built Runner.app bundle',
      );
      expect(
        scriptBody,
        contains('if [ ! -d "\$APP" ]; then'),
        reason: 'Must verify Runner.app directory exists before packaging',
      );

      // Assert Payload staging structure
      expect(
        scriptBody,
        contains('mkdir -p Payload'),
        reason: 'Must stage Payload directory for IPA structure',
      );
      expect(
        scriptBody,
        contains('cp -R "\$APP" Payload/'),
        reason: 'Must copy Runner.app into Payload directory',
      );

      // Assert zip command into Opennote.ipa
      expect(
        scriptBody,
        contains('zip -r Opennote.ipa Payload/'),
        reason: 'Must compress Payload into Opennote.ipa',
      );

      // Assert cleanup of staging directory
      expect(
        scriptBody,
        contains('rm -rf Payload/'),
        reason: 'Must clean up temporary Payload directory',
      );
    });

    test('validates build artifact declaration', () {
      final artifacts = buildIosWorkflow['artifacts'] as YamlList;
      expect(
        artifacts,
        contains('Opennote.ipa'),
        reason: 'Artifacts must export Opennote.ipa for sideloading distribution',
      );
    });

    test('validates publishing email recipient', () {
      final publishing = buildIosWorkflow['publishing'] as YamlMap;
      expect(
        publishing.containsKey('email'),
        isTrue,
        reason: 'Publishing must configure email notifications',
      );
      final email = publishing['email'] as YamlMap;
      final recipients = email['recipients'] as YamlList;
      expect(
        recipients,
        isNotEmpty,
        reason: 'Email recipients list must have at least one recipient',
      );
    });
  });

  group('iOS CocoaPods Configuration (ios/Podfile)', () {
    late File podfile;
    late String podfileContent;

    setUpAll(() {
      podfile = File('ios/Podfile');
      expect(
        podfile.existsSync(),
        isTrue,
        reason: 'ios/Podfile must exist',
      );
      podfileContent = podfile.readAsStringSync();
    });

    test('uncomments platform :ios, 14.0 specification', () {
      final lines = podfileContent.split('\n');
      final activePlatformLines = lines.where(
        (line) =>
            line.trim().startsWith('platform :ios') ||
            line.trim().startsWith("platform :ios, '14.0'"),
      );

      expect(
        activePlatformLines,
        isNotEmpty,
        reason: 'ios/Podfile must have an active platform :ios line',
      );

      expect(
        activePlatformLines.first.trim(),
        equals("platform :ios, '14.0'"),
        reason: 'platform :ios must be uncommented and set to 14.0',
      );

      // Ensure commented platform is not left behind
      final commentedPlatformLines = lines.where(
        (line) => line.trim().startsWith("# platform :ios, '14.0'"),
      );
      expect(
        commentedPlatformLines,
        isEmpty,
        reason: 'The commented-out platform line must be removed or uncommented',
      );
    });

    test('contains essential CocoaPods settings', () {
      expect(
        podfileContent,
        contains("ENV['COCOAPODS_DISABLE_STATS'] = 'true'"),
        reason: 'Disables stats for fast build latency',
      );
      expect(
        podfileContent,
        contains('flutter_ios_podfile_setup'),
        reason: 'Must set up Flutter iOS pod helper',
      );
      expect(
        podfileContent,
        contains('use_frameworks!'),
        reason: 'Must use dynamic frameworks for Flutter plugins',
      );
    });
  });

  group('Xcode Project Settings (ios/Runner.xcodeproj/project.pbxproj)', () {
    late File pbxprojFile;
    late String pbxprojContent;

    setUpAll(() {
      pbxprojFile = File('ios/Runner.xcodeproj/project.pbxproj');
      expect(
        pbxprojFile.existsSync(),
        isTrue,
        reason: 'ios/Runner.xcodeproj/project.pbxproj must exist',
      );
      pbxprojContent = pbxprojFile.readAsStringSync();
    });

    test('sets IPHONEOS_DEPLOYMENT_TARGET to 14.0 across configurations', () {
      final targetMatches = RegExp(
        r'IPHONEOS_DEPLOYMENT_TARGET\s*=\s*14\.0;',
      ).allMatches(pbxprojContent);

      expect(
        targetMatches.length,
        greaterThanOrEqualTo(3),
        reason:
            'IPHONEOS_DEPLOYMENT_TARGET must be set to 14.0 in Debug, Release, and Profile',
      );
    });

    test('sets INFOPLIST_KEY_CFBundleDisplayName to Opennote', () {
      final opennoteMatches = RegExp(
        r'INFOPLIST_KEY_CFBundleDisplayName\s*=\s*Opennote;',
      ).allMatches(pbxprojContent);

      expect(
        opennoteMatches.length,
        greaterThanOrEqualTo(2),
        reason:
            'INFOPLIST_KEY_CFBundleDisplayName must be Opennote across Runner configurations',
      );

      final legacySaberMatches = RegExp(
        r'INFOPLIST_KEY_CFBundleDisplayName\s*=\s*Saber;',
      ).allMatches(pbxprojContent);

      expect(
        legacySaberMatches,
        isEmpty,
        reason:
            'Legacy Saber display name must be completely replaced by Opennote',
      );
    });

    test('defines correct bundle identifier and device family', () {
      expect(
        pbxprojContent,
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.opennote.app;'),
        reason: 'Bundle identifier must be com.opennote.app',
      );
      expect(
        pbxprojContent,
        contains('TARGETED_DEVICE_FAMILY = "1,2";'),
        reason: 'Targeted device family must include both iPhone (1) and iPad (2)',
      );
    });
  });

  group('App Metadata Consistency (ios/Runner/Info.plist)', () {
    late File infoPlistFile;
    late String infoPlistContent;

    setUpAll(() {
      infoPlistFile = File('ios/Runner/Info.plist');
      expect(
        infoPlistFile.existsSync(),
        isTrue,
        reason: 'ios/Runner/Info.plist must exist',
      );
      infoPlistContent = infoPlistFile.readAsStringSync();
    });

    test('aligns CFBundleDisplayName and CFBundleName with Opennote', () {
      expect(
        infoPlistContent,
        contains('<key>CFBundleDisplayName</key>\n\t<string>Opennote</string>'),
        reason: 'Info.plist CFBundleDisplayName must be Opennote',
      );
      expect(
        infoPlistContent,
        contains('<key>CFBundleName</key>\n\t<string>Opennote</string>'),
        reason: 'Info.plist CFBundleName must be Opennote',
      );
    });
  });

  group('onyxsdk_pen Platform Isolation & Gating', () {
    test('pubspec specifies only android platform and excludes ios', () {
      final onyxPubspecFile = File('packages/onyxsdk_pen/pubspec.yaml');
      expect(onyxPubspecFile.existsSync(), isTrue);

      final content = onyxPubspecFile.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;
      final flutterSection = yaml['flutter'] as YamlMap;
      final pluginSection = flutterSection['plugin'] as YamlMap;
      final platforms = pluginSection['platforms'] as YamlMap;

      expect(
        platforms.containsKey('android'),
        isTrue,
        reason: 'onyxsdk_pen must declare android platform support',
      );
      expect(
        platforms.containsKey('ios'),
        isFalse,
        reason:
            'onyxsdk_pen must NOT declare ios platform support to prevent CocoaPods linking issues',
      );
    });

    test('runtime code safely gates platform execution on non-Android', () {
      final areaFile = File(
        'packages/onyxsdk_pen/lib/src/onyxsdk_pen_area.dart',
      );
      expect(areaFile.existsSync(), isTrue);

      final content = areaFile.readAsStringSync();
      expect(
        content,
        contains('static bool? _isOnyxDevice = (kIsWeb || !Platform.isAndroid) ? false : null;'),
        reason:
            '_isOnyxDevice must immediately short-circuit to false on non-Android (iOS/web)',
      );
      expect(
        content,
        contains('if (_isOnyxDevice != null) return _isOnyxDevice!;'),
        reason: 'Must return cached false without calling native platform channels',
      );
    });
  });

  group('sbn Package Pure-Dart Verification', () {
    test('sbn pubspec has no native platform dependencies', () {
      final sbnPubspecFile = File('packages/sbn/pubspec.yaml');
      expect(sbnPubspecFile.existsSync(), isTrue);

      final content = sbnPubspecFile.readAsStringSync();
      final yaml = loadYaml(content) as YamlMap;

      expect(
        yaml['name'],
        equals('sbn'),
        reason: 'Package name must be sbn',
      );

      // Verify no flutter.plugin platform configuration exists
      final flutterSection = yaml['flutter'];
      if (flutterSection is YamlMap) {
        expect(
          flutterSection.containsKey('plugin'),
          isFalse,
          reason: 'sbn package must be pure Dart/Flutter without native plugins',
        );
      }

      final dependencies = yaml['dependencies'] as YamlMap;
      expect(dependencies.containsKey('stow_codecs'), isTrue);
      expect(dependencies.containsKey('flutter_quill'), isTrue);
      expect(dependencies.containsKey('logging'), isTrue);
    });
  });

  group('IPA Packaging Artifact Staging Simulation', () {
    test('simulates Payload staging and validates IPA archive hierarchy', () {
      // Simulate creating an unsigned IPA archive following Apple's bundle structure
      final archive = Archive();

      // Bundle structure: Payload/Runner.app/*
      final mockFiles = {
        'Payload/Runner.app/Info.plist': utf8.encode(
          '<?xml version="1.0" encoding="UTF-8"?><plist version="1.0"><dict><key>CFBundleDisplayName</key><string>Opennote</string></dict></plist>',
        ),
        'Payload/Runner.app/PkgInfo': utf8.encode('APPL????'),
        'Payload/Runner.app/Runner': utf8.encode('MOCK_BINARY_DATA'),
        'Payload/Runner.app/Frameworks/App.framework/App': utf8.encode(
          'MOCK_FRAMEWORK_DATA',
        ),
        'Payload/Runner.app/Frameworks/Flutter.framework/Flutter': utf8.encode(
          'MOCK_FLUTTER_DATA',
        ),
      };

      for (final entry in mockFiles.entries) {
        archive.addFile(
          ArchiveFile(entry.key, entry.value.length, entry.value),
        );
      }

      // Encode archive to zip bytes
      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive);
      expect(zipBytes, isNotNull);
      expect(zipBytes.length, greaterThan(0));

      // Decode the generated zip archive and verify structure
      final zipDecoder = ZipDecoder();
      final decodedArchive = zipDecoder.decodeBytes(zipBytes);

      expect(decodedArchive.length, equals(mockFiles.length));

      for (final file in decodedArchive) {
        expect(
          file.name.startsWith('Payload/'),
          isTrue,
          reason:
              'All entries in an iOS IPA must reside within the top-level Payload/ directory',
        );
      }

      final infoPlistEntry = decodedArchive.findFile(
        'Payload/Runner.app/Info.plist',
      );
      expect(
        infoPlistEntry,
        isNotNull,
        reason: 'IPA must contain Info.plist inside Payload/Runner.app',
      );

      final infoContent = utf8.decode(infoPlistEntry!.content as List<int>);
      expect(
        infoContent,
        contains('<string>Opennote</string>'),
        reason: 'Staged bundle must retain Opennote identity',
      );
    });
  });
}
