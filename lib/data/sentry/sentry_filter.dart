/// 🤖 Modified with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saber/data/prefs.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Scrubs user credentials, file paths, and server identifiers from Sentry
/// telemetry events before transmission.
abstract class SentryFilter {
  /// Patterns to redact in Sentry events.
  ///
  /// Note: When editing these, also update the server-side filters in
  /// https://saber-yf.sentry.io/settings/security-and-privacy/
  /// so users on older versions of Saber still get their data scrubbed.
  @visibleForTesting
  static final replacements = <Pattern, String>{
    // SaberSyncFile(...)
    RegExp(r'SaberSyncFile\(.+\)'): 'SaberSyncFile([redacted])',
    // Remote file paths
    RegExp(r'[a-zA-Z0-9]+\.sbe'): 'abef1289.sbe',
    // Local file paths
    RegExp(r'[/\\][^/\\]+\.sbn2'): '/somefile.sbn2',
    // Domain names
    RegExp(r'://[a-zA-Z0-9.-]+'): '://example.com',
    // Login flow token
    RegExp(r'/flow/[a-zA-Z0-9/-]+'): '/flow/XXXXXXXXXX',
    // Session passphrase
    RegExp(r'oc_sessionPassphrase=[^;)}]+'): 'oc_sessionPassphrase=XXXXXXXXXX',
    // WebDAV paths
    RegExp(r'/webdav/[^ ;)\],]+'): '/webdav/path/to/something',
    // Windows user folder (see https://stackoverflow.com/a/31976060)
    RegExp(r':[/\\]Users[/\\][^<>"/\\|?*]+'): ':\\Users\\[USER]',
    // Linux user folder
    RegExp(r'/home/[^/]+'): '/home/[USER]',
    // macOS user folder
    RegExp(r'/Users/[^/]+'): '/Users/[USER]',
  };

  /// A list of known user credentials that should be redacted.
  /// This includes current user credentials and any other credentials we've
  /// seen since starting the app.
  @visibleForTesting
  static Set<String> getSecrets() => _previousSecrets
    ..add(stows.username.value)
    ..add(stows.ncPassword.value)
    ..add(stows.encPassword.value)
    ..add(stows.key.value)
    ..add(stows.iv.value);

  static final _previousSecrets = <String>{};

  /// Redacts known sensitive patterns and user credentials from [input].
  @visibleForTesting
  static String scrubString(String input) {
    var result = input;
    for (final entry in replacements.entries) {
      if (result.contains(entry.key)) {
        result = result.replaceAll(entry.key, entry.value);
      }
    }
    for (final secret in getSecrets()) {
      if (secret.isEmpty) continue;
      if (result.contains(secret)) {
        result = result.replaceAll(secret, '[redacted]');
      }
    }
    return result;
  }

  static Map<String, dynamic>? _scrubDataMap(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return data;
    var changed = false;
    final scrubbed = <String, dynamic>{};
    for (final entry in data.entries) {
      final value = entry.value;
      if (value is String) {
        final next = scrubString(value);
        if (next != value) changed = true;
        scrubbed[entry.key] = next;
      } else {
        scrubbed[entry.key] = value;
      }
    }
    return changed ? scrubbed : data;
  }

  /// Scrubs sensitive data from [event] messages, exceptions, and breadcrumbs.
  static FutureOr<SentryEvent?> beforeSend(SentryEvent event, Hint hint) async {
    if (stows.sentryConsent.value != .granted) {
      return null;
    }

    if (event.message != null) {
      final original = event.message!.formatted;
      final scrubbed = scrubString(original);
      if (scrubbed != original) {
        event.message = SentryMessage(scrubbed);
      }
    }

    final exceptions = event.exceptions;
    if (exceptions != null && exceptions.isNotEmpty) {
      for (final exception in exceptions) {
        final value = exception.value;
        if (value == null) continue;
        final scrubbed = scrubString(value);
        if (scrubbed != value) {
          exception.value = scrubbed;
        }
      }
    }

    final breadcrumbs = event.breadcrumbs;
    if (breadcrumbs != null && breadcrumbs.isNotEmpty) {
      for (final breadcrumb in breadcrumbs) {
        final message = breadcrumb.message;
        if (message != null) {
          final scrubbed = scrubString(message);
          if (scrubbed != message) {
            breadcrumb.message = scrubbed;
          }
        }
        final scrubbedData = _scrubDataMap(breadcrumb.data);
        if (!identical(scrubbedData, breadcrumb.data)) {
          breadcrumb.data = scrubbedData;
        }
      }
    }

    return event;
  }
}
