/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Lightweight mobile clipboard bridge communicating with native Android and
/// iOS clipboard handlers over `com.opennote.app/clipboard`.
abstract final class MobileClipboard {
  /// Platform method channel shared with `MainActivity.kt` and `AppDelegate.swift`.
  static const channel = MethodChannel('com.opennote.app/clipboard');

  /// Optional test hook overriding [copyImage] without invoking platform channels.
  @visibleForTesting
  static Future<bool> Function(Uint8List pngBytes)? copyImageOverride;

  /// Optional test hook overriding [pasteImage] without invoking platform channels.
  @visibleForTesting
  static Future<({Uint8List bytes, String extension})?> Function()?
  pasteImageOverride;

  /// Copies [pngBytes] to the system clipboard as a PNG image.
  ///
  /// Returns `true` when the native clipboard write succeeds, or `false` if
  /// [pngBytes] is empty or the platform plugin is unavailable.
  static Future<bool> copyImage(Uint8List pngBytes) async {
    final override = copyImageOverride;
    if (override != null) return override(pngBytes);
    if (pngBytes.isEmpty) return false;

    try {
      final copied = await channel.invokeMethod<bool>('copyImage', {
        'bytes': pngBytes,
      });
      return copied ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Reads an image payload and normalized file extension (e.g. `'.png'`) from
  /// the system clipboard, or returns `null` if no image is available.
  static Future<({Uint8List bytes, String extension})?> pasteImage() async {
    final override = pasteImageOverride;
    if (override != null) return override();

    try {
      final result = await channel.invokeMapMethod<String, dynamic>(
        'pasteImage',
      );
      if (result == null) return null;

      final rawBytes = result['bytes'];
      final Uint8List? bytes = switch (rawBytes) {
        final Uint8List data => data,
        final List<int> data => Uint8List.fromList(data),
        _ => null,
      };
      if (bytes == null || bytes.isEmpty) return null;

      final rawExtension = result['extension'];
      final extension = _normalizeExtension(
        rawExtension is String ? rawExtension : null,
      );
      return (bytes: bytes, extension: extension);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  static String _normalizeExtension(String? raw) {
    final trimmed = raw?.trim().toLowerCase() ?? '';
    if (trimmed.isEmpty) return '.png';
    return trimmed.startsWith('.') ? trimmed : '.$trimmed';
  }
}
