/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/theming/adaptive_switch_list_tile.dart';
import 'package:saber/components/toolbar/lasso_filter_popup.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';

void main() {
  setUpAll(() {
    FlavorConfig.setup();
  });

  setUp(() {
    stows.lassoSelectHandwriting.value = true;
    stows.lassoSelectImages.value = true;
    stows.lassoSelectText.value = true;
    stows.lassoSelectTape.value = true;
    stows.selectionRectMode.value = false;
    Select.currentSelect.unselect();
  });

  group('LassoFilterPopup', () {
    testWidgets('renders dialog title and all filter options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LassoFilterPopup())),
      );

      expect(find.text('Lasso Options'), findsOneWidget);
      expect(find.text('Handwriting'), findsOneWidget);
      expect(find.text('Images'), findsOneWidget);
      expect(find.text('Text Boxes'), findsOneWidget);
      expect(find.text('Study Tape'), findsOneWidget);
      expect(find.byType(AdaptiveSwitchListTile), findsNWidgets(4));
    });

    testWidgets('toggling Images switch updates stow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LassoFilterPopup())),
      );

      expect(stows.lassoSelectImages.value, isTrue);

      final imagesTile = find.widgetWithText(AdaptiveSwitchListTile, 'Images');
      expect(imagesTile, findsOneWidget);

      await tester.tap(imagesTile);
      await tester.pumpAndSettle();

      expect(stows.lassoSelectImages.value, isFalse);
    });

    testWidgets('safety constraint prevents disabling all toggles', (
      tester,
    ) async {
      stows.lassoSelectHandwriting.value = true;
      stows.lassoSelectImages.value = false;
      stows.lassoSelectText.value = false;
      stows.lassoSelectTape.value = false;

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LassoFilterPopup())),
      );

      final handwritingTile = find.widgetWithText(
        AdaptiveSwitchListTile,
        'Handwriting',
      );
      expect(handwritingTile, findsOneWidget);

      // Attempt to disable the last active toggle
      await tester.tap(handwritingTile);
      await tester.pumpAndSettle();

      // Must remain true to avoid all being disabled simultaneously
      expect(stows.lassoSelectHandwriting.value, isTrue);
    });

    testWidgets('toggling an option prunes active selection', (tester) async {
      Select.currentSelect.selectResult = SelectResult(
        pageIndex: 0,
        strokes: [],
        images: [],
        textSelected: true,
        path: Path(),
      );
      Select.currentSelect.doneSelecting = true;

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LassoFilterPopup())),
      );

      final textTile = find.widgetWithText(
        AdaptiveSwitchListTile,
        'Text Boxes',
      );
      await tester.tap(textTile);
      await tester.pumpAndSettle();

      expect(stows.lassoSelectText.value, isFalse);
      expect(Select.currentSelect.selectResult.textSelected, isFalse);
      expect(Select.currentSelect.doneSelecting, isFalse);
    });

    testWidgets('OK button dismisses dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const LassoFilterPopup(),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(LassoFilterPopup), findsOneWidget);

      // Tap OK button
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(LassoFilterPopup), findsNothing);
    });
  });
}
