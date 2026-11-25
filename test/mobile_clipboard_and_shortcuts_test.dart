/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/data/clipboard/mobile_clipboard.dart';
import 'package:saber/data/shortcuts/mobile_keybinder.dart';

const _clipboardChannel = MethodChannel('com.opennote.app/clipboard');

Uint8List? _extractSentBytes(Object? arguments) {
  if (arguments is Uint8List) return arguments;
  if (arguments is Map<Object?, Object?>) {
    final raw = arguments['bytes'];
    if (raw is Uint8List) return raw;
  }
  return null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final samplePngBytes = Uint8List.fromList(const [
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
  ]);

  final sampleJpegBytes = Uint8List.fromList(const [
    0xFF,
    0xD8,
    0xFF,
    0xE0,
    0x00,
    0x10,
    0x4A,
    0x46,
  ]);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_clipboardChannel, null);
  });

  group('MobileClipboard Platform Channel Contract', () {
    test(
      'copyImage sends copyImage method with image bytes and returns true',
      () async {
        final calls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_clipboardChannel, (call) async {
              calls.add(call);
              if (call.method == 'copyImage') return true;
              return null;
            });

        final copied = await MobileClipboard.copyImage(samplePngBytes);

        expect(copied, isTrue);
        expect(calls, hasLength(1));
        expect(calls.single.method, equals('copyImage'));
        expect(
          _extractSentBytes(calls.single.arguments),
          equals(samplePngBytes),
        );
      },
    );

    test(
      'copyImage returns false when native channel returns false or throws',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_clipboardChannel, (call) async => false);

        expect(await MobileClipboard.copyImage(samplePngBytes), isFalse);

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_clipboardChannel, (call) async {
              throw PlatformException(
                code: 'CLIPBOARD_WRITE_FAILED',
                message: 'Unable to access system pasteboard',
              );
            });

        expect(await MobileClipboard.copyImage(samplePngBytes), isFalse);
      },
    );

    test(
      'pasteImage decodes bytes and extension from pasteImage response',
      () async {
        final calls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_clipboardChannel, (call) async {
              calls.add(call);
              if (call.method == 'pasteImage') {
                return <String, Object?>{
                  'bytes': samplePngBytes,
                  'extension': '.png',
                };
              }
              return null;
            });

        final pastedPng = await MobileClipboard.pasteImage();

        expect(calls, hasLength(1));
        expect(calls.single.method, equals('pasteImage'));
        expect(pastedPng, isNotNull);
        expect(pastedPng!.bytes, equals(samplePngBytes));
        expect(pastedPng.extension, equals('.png'));

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(_clipboardChannel, (call) async {
              if (call.method == 'pasteImage') {
                return <String, Object?>{
                  'bytes': sampleJpegBytes,
                  'extension': '.jpeg',
                };
              }
              return null;
            });

        final pastedJpeg = await MobileClipboard.pasteImage();

        expect(pastedJpeg, isNotNull);
        expect(pastedJpeg!.bytes, equals(sampleJpegBytes));
        expect(pastedJpeg.extension, equals('.jpeg'));
      },
    );

    test('pasteImage returns null when clipboard is empty or throws', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_clipboardChannel, (call) async => null);

      expect(await MobileClipboard.pasteImage(), isNull);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_clipboardChannel, (call) async {
            throw PlatformException(
              code: 'CLIPBOARD_READ_FAILED',
              message: 'Clipboard unavailable',
            );
          });

      expect(await MobileClipboard.pasteImage(), isNull);
    });

    test('unmocked channel (null handler) gracefully returns false and null '
        'without throwing MissingPluginException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_clipboardChannel, null);

      expect(await MobileClipboard.copyImage(samplePngBytes), isFalse);
      expect(await MobileClipboard.pasteImage(), isNull);
    });
  });

  group('MobileKeybinder HardwareKeyboard Dispatcher', () {
    tearDown(MobileKeybinder.disposeAll);

    testWidgets('dispatches VoidCallback on matching Ctrl+Z key down', (
      tester,
    ) async {
      var undoCount = 0;
      final ctrlZ = Keybinding([
        KeyCode.ctrl,
        KeyCode.from(LogicalKeyboardKey.keyZ),
      ]);

      Keybinder.bind(ctrlZ, () => undoCount++);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      expect(undoCount, equals(1));

      Keybinder.remove(ctrlZ);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      expect(undoCount, equals(1));
    });

    testWidgets('dispatches ValueChanged<bool> state transitions on hold/up', (
      tester,
    ) async {
      final states = <bool>[];
      final leftArrow = Keybinding([
        KeyCode.from(LogicalKeyboardKey.arrowLeft),
      ], inclusive: true);

      Keybinder.bind(leftArrow, (bool pressed) => states.add(pressed));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowLeft);

      expect(states, equals(const [true, false]));
    });
  });
}
