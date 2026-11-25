/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/navbar/responsive_navbar.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/prefs/stow_helpers.dart';
import 'package:saber/data/sentry/sentry_consent.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/palm_rejection.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/tool_id.dart';
import 'package:stow/stow.dart';
import 'package:stow_plain/stow_plain.dart';

class _GrowthPrefsHarness with GrowthPrefs {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('Stows modular composition & backward compatibility', () {
    test('stows singleton mixes in all five domain preference modules', () {
      expect(stows, isA<Stows>());
      expect(stows, isA<SyncPrefs>());
      expect(stows, isA<AppearancePrefs>());
      expect(stows, isA<EditorPrefs>());
      expect(stows, isA<CanvasToolsPrefs>());
      expect(stows, isA<GrowthPrefs>());
    });

    test('Stows static constants preserve original values', () {
      expect(Stows.defaultLineHeight, 40);
      expect(Stows.defaultLineThickness, 3);
      expect(Stows.snapAngleStepIso30, -30);
    });

    test('SyncPrefs keys, types, defaults, and loggedIn getter match', () {
      final prefs = Stows();
      expect(prefs.customDataDir.key, 'customDataDir');
      expect(prefs.customDataDir.defaultValue, isNull);
      expect(prefs.allowInsecureConnections.key, 'allowInsecureConnections');
      expect(prefs.allowInsecureConnections.defaultValue, isFalse);
      expect(prefs.url.key, 'url');
      expect(prefs.url.defaultValue, '');
      expect(prefs.username.key, 'username');
      expect(prefs.ncPassword.key, 'ncPassword');
      expect(prefs.encPassword.key, 'encPassword');
      expect(prefs.key.key, 'key');
      expect(prefs.iv.key, 'iv');
      expect(prefs.pfp.key, 'pfp');
      expect(prefs.pfp.defaultValue, isNull);
      expect(prefs.syncInBackground.key, 'syncInBackground');
      expect(prefs.syncInBackground.defaultValue, isTrue);
      expect(prefs.recentFiles.key, 'recentFiles');
      expect(prefs.recentFiles.defaultValue, isEmpty);
      expect(prefs.fileSyncAlreadyDeleted.key, 'fileSyncAlreadyDeleted');
      expect(prefs.fileSyncCorruptFiles.key, 'fileSyncCorruptFiles');
      expect(
        prefs.fileSyncResyncEverythingDate.defaultValue,
        DateTime.parse('2023-12-10T10:06:31.000Z'),
      );
      expect(prefs.lastStorageQuota.defaultValue, isNull);
      expect(prefs.sentryConsent.defaultValue, SentryConsent.unknown);

      expect(prefs.loggedIn, isFalse);
      prefs.username.value = 'alice';
      prefs.ncPassword.value = 'secret';
      expect(prefs.loggedIn, isFalse);
      prefs.encPassword.value = 'enc';
      expect(prefs.loggedIn, isTrue);
    });

    test('AppearancePrefs keys and defaults match', () {
      final prefs = Stows();
      expect(prefs.appTheme.key, 'appTheme');
      expect(prefs.appTheme.defaultValue, ThemeMode.system);
      expect(prefs.platform.key, 'platform');
      expect(prefs.platform.defaultValue, defaultTargetPlatform);
      expect(prefs.layoutSize.key, 'layoutSize');
      expect(prefs.layoutSize.defaultValue, LayoutSize.auto);
      expect(prefs.accentColor.key, 'accentColor');
      expect(prefs.accentColor.defaultValue, isNull);
      expect(prefs.hyperlegibleFont.key, 'hyperlegibleFont');
      expect(prefs.hyperlegibleFont.defaultValue, isFalse);
      expect(prefs.simplifiedHomeLayout.key, 'simplifiedHomeLayout');
      expect(prefs.simplifiedHomeLayout.defaultValue, isFalse);
      expect(prefs.opennoteUiMode.key, 'opennoteUiMode');
      expect(prefs.opennoteUiMode.defaultValue, isTrue);
      expect(prefs.locale.key, 'locale');
      expect(prefs.locale.defaultValue, '');
    });

    test('EditorPrefs keys and defaults match', () {
      final prefs = Stows();
      expect(prefs.editorToolbarAlignment.defaultValue, AxisDirection.down);
      expect(prefs.floatingPenMenuEdge.defaultValue, 'right');
      expect(prefs.editorToolbarShowInFullscreen.defaultValue, isTrue);
      expect(prefs.editorFingerDrawing.defaultValue, isTrue);
      expect(prefs.editorAutoInvert.defaultValue, isTrue);
      expect(prefs.preferGreyscale.defaultValue, isFalse);
      expect(prefs.editorPromptRename.defaultValue, isFalse);
      expect(prefs.autosaveDelay.defaultValue, 10000);
      expect(prefs.shapeRecognitionDelay.defaultValue, 500);
      expect(prefs.autoStraightenLines.defaultValue, isTrue);
      expect(prefs.printPageIndicators.defaultValue, isFalse);
      expect(prefs.maxImageSize.defaultValue, 1000.0);
      expect(prefs.autoClearWhiteboardOnExit.defaultValue, isFalse);
      expect(prefs.defaultInfiniteCanvas.defaultValue, isFalse);
      expect(prefs.showFloatingLayersHud.defaultValue, isTrue);
      expect(prefs.elementsJson.defaultValue, '');
      expect(prefs.twoFingerTapUndo.defaultValue, isTrue);
      expect(prefs.hideFingerDrawingToggle.defaultValue, isFalse);
      expect(
        prefs.autoDisableFingerDrawingWhenStylusDetected.defaultValue,
        isTrue,
      );
      expect(prefs.writingPosture.defaultValue, WritingPosture.rightBelow);
      expect(
        prefs.palmRejectionSensitivity.defaultValue,
        PalmRejectionSensitivity.medium,
      );
      expect(
        prefs.lastBackgroundPattern.defaultValue,
        CanvasBackgroundPattern.none,
      );
      expect(prefs.lastLineHeight.defaultValue, 40);
      expect(prefs.lastLineThickness.defaultValue, 3);
      expect(prefs.lastZoomLock.defaultValue, isFalse);
      expect(prefs.lastSingleFingerPanLock.defaultValue, isFalse);
      expect(prefs.lastAxisAlignedPanLock.defaultValue, isFalse);
      expect(prefs.snapToGrid.defaultValue, isFalse);
      expect(prefs.gridSize.defaultValue, 20.0);
      expect(prefs.snapToAngle.defaultValue, isFalse);
      expect(prefs.snapAngleStep.defaultValue, 15);
    });

    test('CanvasToolsPrefs keys, defaults, and codecs match', () {
      final prefs = Stows();
      expect(prefs.disableEraserAfterUse.defaultValue, isFalse);
      expect(prefs.eraserSize.defaultValue, 30.0);
      expect(prefs.scribbleToErase.defaultValue, isTrue);
      expect(prefs.selectionRectMode.defaultValue, isFalse);
      expect(prefs.lassoSelectHandwriting.defaultValue, isTrue);
      expect(prefs.lassoSelectImages.defaultValue, isTrue);
      expect(prefs.lassoSelectText.defaultValue, isTrue);
      expect(prefs.lassoSelectTape.defaultValue, isTrue);
      expect(prefs.lassoSelectPartial.defaultValue, isTrue);
      expect(prefs.lassoSelectConnected.defaultValue, isTrue);
      expect(prefs.studyTapePattern.defaultValue, 'solid');
      expect(prefs.eraserEraseHighlighterOnly.defaultValue, isFalse);
      expect(prefs.eraserEraseTapeOnly.defaultValue, isFalse);
      expect(prefs.eraserMode.defaultValue, 'object');
      expect(prefs.highlighterDrawInStraightLine.defaultValue, isFalse);
      expect(prefs.circleToSelect.defaultValue, isTrue);
      expect(prefs.laserPointerMode.defaultValue, 'trail');
      expect(prefs.penLineStyle.defaultValue, 'solid');
      expect(
        prefs.penTray.defaultValue,
        'ff000000:2,ff1565c0:3,ffc62828:4,ff2e7d32:3,ff6a1b9a:5,ff5d4037:8',
      );
      expect(prefs.penTrayIndex.defaultValue, 0);
      expect(prefs.quickColorsPen.defaultValue, <int>[
        0xFF000000,
        0xFF1976D2,
        0xFFD32F2F,
      ]);
      expect(prefs.quickColorsHighlighter.defaultValue, <int>[
        0xFFFFF176,
        0xFFA5D6A7,
        0xFFF48FB1,
      ]);
      expect(prefs.quickSizesPen.defaultValue, <double>[2.0, 4.0, 8.0]);
      expect(prefs.quickSizesHighlighter.defaultValue, <double>[
        15.0,
        25.0,
        40.0,
      ]);
      expect(prefs.penPressureCurve.defaultValue, 1.0);
      expect(prefs.recentColorsDontSavePresets.key, 'dontSavePresetColors');
      expect(prefs.recentColorsLength.defaultValue, 5);
      expect(prefs.lastTool.defaultValue, ToolId.fountainPen);
      expect(prefs.lastFountainPenColor.defaultValue, Colors.black.toARGB32());
      expect(
        prefs.lastHighlighterColor.defaultValue,
        Colors.yellow.withAlpha(Highlighter.alpha).toARGB32(),
      );

      const intCodec = IntListCsvCodec();
      expect(intCodec.decode(intCodec.encode([1, 2, 3])), [1, 2, 3]);

      const doubleCodec = DoubleListCsvCodec();
      expect(doubleCodec.decode(doubleCodec.encode([1.5, 2.5, 4.0])), [
        1.5,
        2.5,
        4.0,
      ]);
    });

    test('recentColorsLength listener truncates oldest recent colors', () {
      final prefs = Stows();
      prefs.recentColorsChronological.value = ['a', 'b', 'c', 'd'];
      prefs.recentColorsPositioned.value = ['d', 'b', 'a', 'c'];

      prefs.recentColorsLength.value = 2;

      expect(prefs.recentColorsChronological.value, ['c', 'd']);
      expect(prefs.recentColorsPositioned.value, ['d', 'c']);
    });

    test('TransformedStow transforms reads and writes symmetrically', () async {
      final parent = PlainStow<int>('testParent', 5, volatile: true);
      final transformed = TransformedStow<int, String>(
        parent,
        (v) => v.toString(),
        int.parse,
      );
      await parent.waitUntilRead();
      await transformed.waitUntilRead();

      expect(transformed.value, '5');
      transformed.value = '42';
      expect(parent.value, 42);
      expect(transformed.value, '42');

      transformed.dispose();
      parent.dispose();
    });
  });

  group('GrowthPrefs defaults, mutations, and persistence', () {
    test('all new growth stow keys and defaults match specification', () {
      final prefs = Stows();

      expect(prefs.hasSeenOnboarding.key, 'hasSeenOnboarding');
      expect(prefs.hasSeenOnboarding.defaultValue, isFalse);

      expect(prefs.onboardingCompleted.key, 'onboardingCompleted');
      expect(prefs.onboardingCompleted.defaultValue, isFalse);
      expect(prefs.onboardingCompleted.value, isFalse);

      expect(prefs.onboardingPersona.key, 'onboardingPersona');
      expect(prefs.onboardingPersona.defaultValue, '');
      expect(prefs.onboardingPersona.value, '');

      expect(prefs.proTierCached.key, 'proTierCached');
      expect(prefs.proTierCached.defaultValue, 'free');
      expect(prefs.proTierCached.value, 'free');

      expect(prefs.proTrialStartEpochMs.key, 'proTrialStartEpochMs');
      expect(prefs.proTrialStartEpochMs.defaultValue, 0);
      expect(prefs.proTrialStartEpochMs.value, 0);

      expect(prefs.proExpirationEpochMs.key, 'proExpirationEpochMs');
      expect(prefs.proExpirationEpochMs.defaultValue, 0);
      expect(prefs.proExpirationEpochMs.value, 0);

      expect(prefs.notesCreatedCount.key, 'notesCreatedCount');
      expect(prefs.notesCreatedCount.defaultValue, 0);
      expect(prefs.notesCreatedCount.value, 0);

      expect(prefs.exportsCompletedCount.key, 'exportsCompletedCount');
      expect(prefs.exportsCompletedCount.defaultValue, 0);
      expect(prefs.exportsCompletedCount.value, 0);

      expect(prefs.lastReviewPromptEpochMs.key, 'lastReviewPromptEpochMs');
      expect(prefs.lastReviewPromptEpochMs.defaultValue, 0);
      expect(prefs.lastReviewPromptEpochMs.value, 0);

      expect(prefs.hasRatedApp.key, 'hasRatedApp');
      expect(prefs.hasRatedApp.defaultValue, isFalse);
      expect(prefs.hasRatedApp.value, isFalse);

      expect(prefs.paywallImpressionsCount.key, 'paywallImpressionsCount');
      expect(prefs.paywallImpressionsCount.defaultValue, 0);
      expect(prefs.paywallImpressionsCount.value, 0);
    });

    test('growth prefs notify listeners and update in-memory values', () {
      final prefs = Stows();
      var notifications = 0;
      prefs.onboardingCompleted.addListener(() => notifications++);

      prefs.onboardingCompleted.value = true;
      prefs.onboardingPersona.value = 'engineering_student';
      prefs.proTierCached.value = 'pro_annual';
      prefs.proTrialStartEpochMs.value = 1735689600000;
      prefs.proExpirationEpochMs.value = 1767225600000;
      prefs.notesCreatedCount.value = 12;
      prefs.exportsCompletedCount.value = 4;
      prefs.lastReviewPromptEpochMs.value = 1736000000000;
      prefs.hasRatedApp.value = true;
      prefs.paywallImpressionsCount.value = 3;

      expect(notifications, 1);
      expect(prefs.onboardingCompleted.value, isTrue);
      expect(prefs.onboardingPersona.value, 'engineering_student');
      expect(prefs.proTierCached.value, 'pro_annual');
      expect(prefs.proTrialStartEpochMs.value, 1735689600000);
      expect(prefs.proExpirationEpochMs.value, 1767225600000);
      expect(prefs.notesCreatedCount.value, 12);
      expect(prefs.exportsCompletedCount.value, 4);
      expect(prefs.lastReviewPromptEpochMs.value, 1736000000000);
      expect(prefs.hasRatedApp.value, isTrue);
      expect(prefs.paywallImpressionsCount.value, 3);
    });

    test('growth prefs persist and reload via SharedPreferences', () async {
      final backingStore = <String, Object>{};
      const channel = MethodChannel('plugins.flutter.io/shared_preferences');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            switch (call.method) {
              case 'getAll':
                return Map<String, Object>.from(backingStore);
              case 'setBool':
              case 'setInt':
              case 'setDouble':
              case 'setString':
              case 'setStringList':
                final args = call.arguments as Map<Object?, Object?>;
                backingStore[args['key'] as String] = args['value'] as Object;
                return true;
              case 'remove':
                final args = call.arguments as Map<Object?, Object?>;
                backingStore.remove(args['key'] as String);
                return true;
              case 'clear':
                backingStore.clear();
                return true;
              default:
                return null;
            }
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      Stows.markAsOnMainIsolate();
      Stow.volatileInTests = false;
      try {
        final writer = _GrowthPrefsHarness();
        await Future.wait([
          writer.onboardingCompleted.waitUntilRead(),
          writer.onboardingPersona.waitUntilRead(),
          writer.proTierCached.waitUntilRead(),
          writer.proTrialStartEpochMs.waitUntilRead(),
          writer.proExpirationEpochMs.waitUntilRead(),
          writer.notesCreatedCount.waitUntilRead(),
          writer.exportsCompletedCount.waitUntilRead(),
          writer.lastReviewPromptEpochMs.waitUntilRead(),
          writer.hasRatedApp.waitUntilRead(),
          writer.paywallImpressionsCount.waitUntilRead(),
        ]);

        writer.onboardingCompleted.value = true;
        writer.onboardingPersona.value = 'architect';
        writer.proTierCached.value = 'pro';
        writer.proTrialStartEpochMs.value = 1700000000000;
        writer.proExpirationEpochMs.value = 1702592000000;
        writer.notesCreatedCount.value = 7;
        writer.exportsCompletedCount.value = 2;
        writer.lastReviewPromptEpochMs.value = 1701000000000;
        writer.hasRatedApp.value = true;
        writer.paywallImpressionsCount.value = 5;

        await Future.wait([
          writer.onboardingCompleted.waitUntilWritten(),
          writer.onboardingPersona.waitUntilWritten(),
          writer.proTierCached.waitUntilWritten(),
          writer.proTrialStartEpochMs.waitUntilWritten(),
          writer.proExpirationEpochMs.waitUntilWritten(),
          writer.notesCreatedCount.waitUntilWritten(),
          writer.exportsCompletedCount.waitUntilWritten(),
          writer.lastReviewPromptEpochMs.waitUntilWritten(),
          writer.hasRatedApp.waitUntilWritten(),
          writer.paywallImpressionsCount.waitUntilWritten(),
        ]);

        final reader = _GrowthPrefsHarness();
        await Future.wait([
          reader.onboardingCompleted.waitUntilRead(),
          reader.onboardingPersona.waitUntilRead(),
          reader.proTierCached.waitUntilRead(),
          reader.proTrialStartEpochMs.waitUntilRead(),
          reader.proExpirationEpochMs.waitUntilRead(),
          reader.notesCreatedCount.waitUntilRead(),
          reader.exportsCompletedCount.waitUntilRead(),
          reader.lastReviewPromptEpochMs.waitUntilRead(),
          reader.hasRatedApp.waitUntilRead(),
          reader.paywallImpressionsCount.waitUntilRead(),
        ]);

        expect(reader.onboardingCompleted.value, isTrue);
        expect(reader.onboardingPersona.value, 'architect');
        expect(reader.proTierCached.value, 'pro');
        expect(reader.proTrialStartEpochMs.value, 1700000000000);
        expect(reader.proExpirationEpochMs.value, 1702592000000);
        expect(reader.notesCreatedCount.value, 7);
        expect(reader.exportsCompletedCount.value, 2);
        expect(reader.lastReviewPromptEpochMs.value, 1701000000000);
        expect(reader.hasRatedApp.value, isTrue);
        expect(reader.paywallImpressionsCount.value, 5);
      } finally {
        Stow.volatileInTests = true;
      }
    });
  });
}
