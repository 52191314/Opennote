/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/foundation.dart';
import 'package:saber/components/settings/nextcloud_profile.dart';
import 'package:saber/data/codecs/base64_codec.dart';
import 'package:saber/data/codecs/quota_codec.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs/stow_helpers.dart';
import 'package:saber/data/sentry/sentry_consent.dart';
import 'package:stow_codecs/stow_codecs.dart';
import 'package:stow_plain/stow_plain.dart';
import 'package:stow_secure/stow_secure.dart';

/// Account credentials, Nextcloud sync state, storage paths, updates,
/// and crash-reporting preferences.
mixin SyncPrefs {
  /// Optional user-selected directory for storing notes.
  final customDataDir = PlainStow<String?>(
    'customDataDir',
    null,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether self-signed or insecure Nextcloud connections are allowed.
  final allowInsecureConnections = SecureStow.bool(
    'allowInsecureConnections',
    false,
    volatile: StowIsolate.isVolatile,
  );

  /// Nextcloud server URL.
  final url = SecureStow('url', '', volatile: StowIsolate.isVolatile);

  /// Nextcloud account username.
  final username = SecureStow('username', '', volatile: StowIsolate.isVolatile);

  /// The password used to log in to Nextcloud.
  final ncPassword = SecureStow(
    'ncPassword',
    '',
    volatile: StowIsolate.isVolatile,
  );

  /// The password used to encrypt and decrypt notes.
  final encPassword = SecureStow(
    'encPassword',
    '',
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the user is logged in and has provided both passwords.
  ///
  /// Ensure that the relevant stows are loaded before reading this getter.
  bool get loggedIn =>
      username.value.isNotEmpty &&
      ncPassword.value.isNotEmpty &&
      encPassword.value.isNotEmpty;

  /// Cached encryption key.
  final key = SecureStow('key', '', volatile: StowIsolate.isVolatile);

  /// Cached encryption initialization vector.
  final iv = SecureStow('iv', '', volatile: StowIsolate.isVolatile);

  /// Cached Nextcloud profile picture bytes.
  final pfp = PlainStow<Uint8List?>(
    'pfp',
    null,
    codec: const Base64StowCodec(),
    volatile: StowIsolate.isVolatile,
  );

  /// Whether background sync is enabled.
  final syncInBackground = PlainStow(
    'syncInBackground',
    true,
    volatile: StowIsolate.isVolatile,
  );

  /// Recently opened note file paths.
  final recentFiles = PlainStow(
    'recentFiles',
    <String>[],
    volatile: StowIsolate.isVolatile,
  );

  /// File paths that have been deleted locally.
  final fileSyncAlreadyDeleted = PlainStow(
    'fileSyncAlreadyDeleted',
    <String>{},
    volatile: StowIsolate.isVolatile,
  );

  /// File paths that are known to be corrupted on Nextcloud.
  final fileSyncCorruptFiles = PlainStow(
    'fileSyncCorruptFiles',
    <String>{},
    volatile: StowIsolate.isVolatile,
  );

  /// Cutoff date for forcing a full resync of older server files.
  ///
  /// Files on the server older than this date are re-uploaded from the local
  /// version. Defaults to v0.18.4, before which uploads could produce 0B files.
  final fileSyncResyncEverythingDate = PlainStow(
    'fileSyncResyncEverythingDate',
    DateTime.parse('2023-12-10T10:06:31.000Z'),
    codec: const DateTimeCodec(),
    volatile: StowIsolate.isVolatile,
  );

  /// The last storage quota fetched from Nextcloud.
  final lastStorageQuota = PlainStow<Quota?>(
    'lastStorageQuota',
    null,
    codec: const QuotaCodec(),
    volatile: StowIsolate.isVolatile,
  );

  /// Whether the app checks for updates on startup.
  final shouldCheckForUpdates = PlainStow(
    'shouldCheckForUpdates',
    FlavorConfig.shouldCheckForUpdatesByDefault,
    volatile: StowIsolate.isVolatile,
  );

  /// Whether update alerts are shown even for non-critical releases.
  final shouldAlwaysAlertForUpdates = PlainStow(
    'shouldAlwaysAlertForUpdates',
    kDebugMode ? true : false,
    volatile: StowIsolate.isVolatile,
  );

  /// User consent state for Sentry error reporting.
  final sentryConsent = PlainStow(
    'sentryConsent',
    SentryConsent.unknown,
    codec: SentryConsent.codec,
    volatile: StowIsolate.isVolatile,
  );
}
