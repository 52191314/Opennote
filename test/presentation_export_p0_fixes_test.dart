/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/editor/presentation_mode.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/editor_exporter.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';
import 'package:sbn/tool_id.dart';

EditorPage _nonEmptyPage() {
  final page = EditorPage();
  final stroke = Stroke(
    color: Colors.black,
    pressureEnabled: false,
    options: StrokeOptions(size: 5),
    pageIndex: 0,
    page: page,
    toolId: ToolId.fountainPen,
  )..addPoint(const Offset(20, 20));
  page.insertStroke(stroke);
  return page;
}

EditorCoreInfo _coreInfoWithPages(String path, List<EditorPage> pages) {
  return EditorCoreInfo(filePath: path)..pages = pages;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    FlavorConfig.setup();
    stows.editorPromptRename.value = false;
  });

  group('PresentationMode touch & flashcard P0 fixes', () {
    testWidgets('Exit button is tappable and pops PresentationMode', (
      tester,
    ) async {
      final coreInfo = _coreInfoWithPages('/test_presentation', [
        _nonEmptyPage(),
        _nonEmptyPage(),
      ]);
      addTearDown(coreInfo.dispose);

      var popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PresentationMode(
                      coreInfo: coreInfo,
                      mode: DisplayMode.presentation,
                    ),
                  ),
                );
                popped = true;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(PresentationMode), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(find.byType(PresentationMode), findsNothing);
    });

    testWidgets(
      'Flashcard Know, Dont Know, and Reset buttons receive taps and track state distinctly',
      (tester) async {
        final coreInfo = _coreInfoWithPages('/test_flashcards', [
          _nonEmptyPage(),
          _nonEmptyPage(),
          _nonEmptyPage(),
        ]);
        addTearDown(coreInfo.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: PresentationMode(
              coreInfo: coreInfo,
              mode: DisplayMode.flashcard,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap center to flip card 1 face-up.
        await tester.tapAt(tester.getCenter(find.byType(PresentationMode)));
        await tester.pumpAndSettle();

        expect(find.text(t.editor.presentation.dontKnow), findsOneWidget);
        expect(find.text(t.editor.presentation.know), findsOneWidget);

        // Tap "Don't Know" on page 1 -> should NOT increment studied/known count
        // and should advance to page 2.
        await tester.tap(find.text(t.editor.presentation.dontKnow));
        await tester.pumpAndSettle();

        expect(
          find.text(
            t.editor.presentation.flashcardProgress(
              current: 2,
              total: 3,
              studied: 0,
            ),
          ),
          findsOneWidget,
        );

        // Flip page 2 and tap "Know" -> increments studied/known count to 1
        // and advances to page 3.
        await tester.tapAt(tester.getCenter(find.byType(PresentationMode)));
        await tester.pumpAndSettle();
        await tester.tap(find.text(t.editor.presentation.know));
        await tester.pumpAndSettle();

        expect(
          find.text(
            t.editor.presentation.flashcardProgress(
              current: 3,
              total: 3,
              studied: 1,
            ),
          ),
          findsOneWidget,
        );

        // Navigate back to page 1 via swipe right twice and confirm review-again icon.
        await tester.fling(
          find.byType(PresentationMode),
          const Offset(300, 0),
          1000,
        );
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check_circle), findsOneWidget);

        await tester.fling(
          find.byType(PresentationMode),
          const Offset(300, 0),
          1000,
        );
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.replay_circle_filled), findsOneWidget);

        // Tap Reset button -> clears both known and review-again indicators.
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.replay_circle_filled), findsNothing);
        expect(
          find.text(
            t.editor.presentation.flashcardProgress(
              current: 1,
              total: 3,
              studied: 0,
            ),
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('EditorExporter P0 fixes', () {
    test('resolveExportPageIndices strips trailing empty page only once', () {
      final twoTrailingEmpty = _coreInfoWithPages('/two_empty', [
        _nonEmptyPage(),
        EditorPage(),
        EditorPage(),
      ]);
      addTearDown(twoTrailingEmpty.dispose);

      // Must strip only the last trailing empty page once (indices 0 and 1),
      // avoiding the duplicated removal that previously caused RangeError.
      expect(
        EditorExporter.resolveExportPageIndices(twoTrailingEmpty),
        equals([0, 1]),
      );

      final singleTrailingEmpty = _coreInfoWithPages('/one_empty', [
        _nonEmptyPage(),
        EditorPage(),
      ]);
      addTearDown(singleTrailingEmpty.dispose);
      expect(
        EditorExporter.resolveExportPageIndices(singleTrailingEmpty),
        equals([0]),
      );

      final noTrailingEmpty = _coreInfoWithPages('/no_empty', [
        _nonEmptyPage(),
        _nonEmptyPage(),
      ]);
      addTearDown(noTrailingEmpty.dispose);
      expect(
        EditorExporter.resolveExportPageIndices(noTrailingEmpty),
        equals([0, 1]),
      );

      // Explicit pageIndices are respected and out-of-range indices filtered.
      expect(
        EditorExporter.resolveExportPageIndices(
          twoTrailingEmpty,
          pageIndices: {-1, 0, 2, 99},
        ),
        equals([0, 2]),
      );
    });
  });

  group('EditorMediaImport PNG export pixelRatio P0 fix', () {
    test(
      'computes Retina pixelRatio (>1x) for standard pages and clamps large canvases',
      () {
        // Standard 1000x1400 page gets full 2.5x default (2500x3500 px <= 4096).
        expect(
          EditorMediaImport.computePngExportPixelRatio(const Size(1000, 1400)),
          closeTo(2.5, 1e-6),
        );

        // Configurable 3.0x on 1000x1200 yields 3.0x (3600 <= 4096).
        expect(
          EditorMediaImport.computePngExportPixelRatio(
            const Size(1000, 1200),
            desiredPixelRatio: 3.0,
          ),
          closeTo(3.0, 1e-6),
        );

        // 3.0x on 1000x1400 clamps to 4096 / 1400 to stay within OOM ceiling.
        expect(
          EditorMediaImport.computePngExportPixelRatio(
            const Size(1000, 1400),
            desiredPixelRatio: 3.0,
          ),
          closeTo(4096.0 / 1400.0, 1e-6),
        );

        // Oversized infinite canvas scales down safely without OOM.
        expect(
          EditorMediaImport.computePngExportPixelRatio(
            const Size(10000, 10000),
          ),
          closeTo(0.4096, 1e-6),
        );

        // Extreme canvas respects safe minimum floor.
        expect(
          EditorMediaImport.computePngExportPixelRatio(
            const Size(100000, 100000),
          ),
          equals(0.25),
        );

        // Zero/invalid size falls back cleanly.
        expect(
          EditorMediaImport.computePngExportPixelRatio(Size.zero),
          equals(2.5),
        );
      },
    );
  });
}
