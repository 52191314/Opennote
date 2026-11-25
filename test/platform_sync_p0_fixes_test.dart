/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saber/data/codecs/quota_codec.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/nextcloud/nextcloud_client_extension.dart';
import 'package:saber/data/nextcloud/saber_syncer.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/sentry/sentry_filter.dart';
import 'package:saber/i18n/extensions/canvas_background_pattern_localized.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('Gallery transfer & Android 13+ permission fixes', () {
    test('photo export album name is Opennote', () {
      expect(photoExportAlbumName, 'Opennote');
    });

    test(
      'requiresLegacyAndroidGalleryPermission skips MediaStore API 29+ & 33+',
      () {
        expect(requiresLegacyAndroidGalleryPermission(26), isTrue);
        expect(requiresLegacyAndroidGalleryPermission(28), isTrue);
        expect(requiresLegacyAndroidGalleryPermission(29), isFalse);
        expect(requiresLegacyAndroidGalleryPermission(32), isFalse);
        expect(requiresLegacyAndroidGalleryPermission(33), isFalse);
        expect(requiresLegacyAndroidGalleryPermission(34), isFalse);
        expect(requiresLegacyAndroidGalleryPermission(35), isFalse);
      },
    );
  });

  group('QuotaCodec division-by-zero protection', () {
    const codec = QuotaCodec();

    test('decode handles total == 0 with used == 0 without NaN', () {
      final quota = codec.decode(['0', '0']);
      expect(quota.used, 0);
      expect(quota.total, 0);
      expect(quota.relative, 0.0);
      expect(quota.relative.isNaN, isFalse);
      expect(quota.relative.isFinite, isTrue);
    });

    test('decode handles total == 0 with used > 0 without Infinity', () {
      final quota = codec.decode(['512', '0']);
      expect(quota.used, 512);
      expect(quota.total, 0);
      expect(quota.relative, 0.0);
      expect(quota.relative.isFinite, isTrue);
    });

    test('decode computes valid percentage when total > 0', () {
      final quota = codec.decode(['250', '1000']);
      expect(quota.used, 250);
      expect(quota.total, 1000);
      expect(quota.free, 750);
      expect(quota.relative, 25.0);
      expect(codec.encode(quota), ['250', '1000']);
    });
  });

  group('SaberSyncInterface config.sbc path handling', () {
    test(
      'writeLocalFile ignores full path ending in config.sbc without deleting',
      () async {
        const syncInterface = SaberSyncInterface();
        stows.fileSyncAlreadyDeleted.value.clear();

        final configSyncFile = SaberSyncFile(
          remoteFile: null,
          localFile: File(
            '/virtual/documents/Opennote/${NextcloudClientExtension.configFileName}',
          ),
          remotePath: '/Saber/${NextcloudClientExtension.configFileName}',
        );

        await syncInterface.writeLocalFile(configSyncFile, Uint8List(0));
        expect(stows.fileSyncAlreadyDeleted.value, isEmpty);
      },
    );
  });

  group('SentryFilter scrubs exceptions and breadcrumbs', () {
    setUp(() {
      stows.sentryConsent.value = .granted;
      stows.username.value = 'alice.engineer';
      stows.ncPassword.value = 'super-nc-pass';
      stows.encPassword.value = 'super-enc-pass';
    });

    test('scrubs secrets and paths in event exceptions', () async {
      final event = SentryEvent(
        exceptions: [
          SentryException(
            type: 'SyncException',
            value:
                'Failed for alice.engineer at https://private.cloud/remote.php/webdav/secret.sbe '
                'using super-nc-pass and /home/alice/notes/private.sbn2',
          ),
        ],
      );

      final filtered = await SentryFilter.beforeSend(event, Hint());
      final scrubbedValue = filtered?.exceptions?.first.value ?? '';

      expect(scrubbedValue, isNot(contains('alice.engineer')));
      expect(scrubbedValue, isNot(contains('super-nc-pass')));
      expect(scrubbedValue, isNot(contains('private.cloud')));
      expect(scrubbedValue, isNot(contains('private.sbn2')));
      expect(scrubbedValue, contains('[redacted]'));
      expect(scrubbedValue, contains('https://example.com'));
      expect(scrubbedValue, contains('/home/[USER]'));
    });

    test('scrubs secrets and paths in breadcrumb message and data', () async {
      final event = SentryEvent(
        breadcrumbs: [
          Breadcrumb(
            message:
                'Uploading /Users/alice/Documents/diary.sbn2 for alice.engineer',
            data: <String, dynamic>{
              'url': 'https://my.nextcloud.org/index.php/login/v2/flow/tok123',
              'secret': 'super-enc-pass',
              'statusCode': 500,
            },
          ),
        ],
      );

      final filtered = await SentryFilter.beforeSend(event, Hint());
      final crumb = filtered?.breadcrumbs?.first;

      expect(crumb?.message, isNot(contains('diary.sbn2')));
      expect(crumb?.message, isNot(contains('alice.engineer')));
      expect(crumb?.message, contains('/Users/[USER]'));
      expect(crumb?.message, contains('[redacted]'));
      expect(
        crumb?.data?['url'],
        'https://example.com/index.php/login/v2/flow/XXXXXXXXXX',
      );
      expect(crumb?.data?['secret'], '[redacted]');
      expect(crumb?.data?['statusCode'], 500);
    });
  });

  group('CanvasBackgroundPatternLocalized labels', () {
    test('every pattern returns a non-empty localizedName', () {
      for (final pattern in CanvasBackgroundPattern.values) {
        expect(pattern.localizedName, isNotEmpty);
      }
      expect(CanvasBackgroundPattern.isometric.localizedName, 'Isometric');
      expect(
        CanvasBackgroundPattern.engineeringGrid.localizedName,
        'Engineering Grid',
      );
    });
  });

  group('Native store readiness manifests', () {
    test('iOS Info.plist includes NSPhotoLibraryAddUsageDescription', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(plist, contains('<key>NSPhotoLibraryAddUsageDescription</key>'));
      expect(plist, contains('<string>Opennote</string>'));
    });

    test('iOS Podfile targets iOS 15.0 for StoreKit 2 readiness', () {
      final podfile = File('ios/Podfile').readAsStringSync();
      expect(podfile, contains("platform :ios, '15.0'"));
      expect(podfile, isNot(contains("platform :ios, '14.0'")));
    });

    test(
      'AndroidManifest removes application launchMode and fixes PDF pattern',
      () {
        final manifest = File(
          'android/app/src/main/AndroidManifest.xml',
        ).readAsStringSync();
        expect(manifest, isNot(contains('android:launchMode="singleTask"')));
        expect(manifest, contains(r'<data android:pathPattern=".*\.pdf"/>'));
        expect(manifest, isNot(contains(r'android:pathPattern=".*\\.pdf"')));
      },
    );
  });
}
