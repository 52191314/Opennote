/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/lasso_callout_menu.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/select.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('SelectResult isNotEmpty Tests', () {
    test('SelectResult reports isNotEmpty correctly', () {
      final emptyResult = SelectResult(
        pageIndex: 0,
        strokes: const [],
        images: const [],
        path: Path(),
        textSelected: false,
      );
      expect(emptyResult.isEmpty, isTrue);
      expect(emptyResult.isNotEmpty, isFalse);

      final textResult = SelectResult(
        pageIndex: 0,
        strokes: const [],
        images: const [],
        path: Path(),
        textSelected: true,
      );
      expect(textResult.isEmpty, isFalse);
      expect(textResult.isNotEmpty, isTrue);
    });
  });

  group('LassoCalloutMenu Widget Tests', () {
    testWidgets('Renders all standard action buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LassoCalloutMenu(
              onCut: () {},
              onCopy: () {},
              onDuplicate: () {},
              onDelete: () {},
              onSetColor: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Cut'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Duplicate'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Crop'), findsNothing);
    });

    testWidgets('Invokes callbacks on action tap', (tester) async {
      bool cutTapped = false;
      bool copyTapped = false;
      bool duplicateTapped = false;
      bool deleteTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LassoCalloutMenu(
              onCut: () => cutTapped = true,
              onCopy: () => copyTapped = true,
              onDuplicate: () => duplicateTapped = true,
              onDelete: () => deleteTapped = true,
              onSetColor: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cut'));
      await tester.pump();
      expect(cutTapped, isTrue);

      await tester.tap(find.text('Copy'));
      await tester.pump();
      expect(copyTapped, isTrue);

      await tester.tap(find.text('Duplicate'));
      await tester.pump();
      expect(duplicateTapped, isTrue);

      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(deleteTapped, isTrue);
    });

    testWidgets('Tapping Color opens palette and picking color triggers onSetColor', (tester) async {
      Color? pickedColor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LassoCalloutMenu(
              onCut: () {},
              onCopy: () {},
              onDuplicate: () {},
              onDelete: () {},
              onSetColor: (color) => pickedColor = color,
            ),
          ),
        ),
      );

      // Tap Color
      await tester.tap(find.text('Color'));
      await tester.pumpAndSettle();

      // Should show back arrow and color discs
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.text('Cut'), findsNothing);

      // Tap the first color disc (GestureDetector or InkWell)
      final discFinder = find.byType(GestureDetector);
      expect(discFinder, findsWidgets);

      // Tap one of the discs
      await tester.tap(discFinder.at(1));
      await tester.pump();

      expect(pickedColor, isNotNull);

      // Back arrow returns to action pill
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Cut'), findsOneWidget);
    });

    testWidgets('Renders Crop button when cropPossible is true', (tester) async {
      bool cropToggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LassoCalloutMenu(
              onCut: () {},
              onCopy: () {},
              onDuplicate: () {},
              onDelete: () {},
              onSetColor: (_) {},
              cropPossible: true,
              cropActive: false,
              onToggleCrop: () => cropToggled = true,
            ),
          ),
        ),
      );

      expect(find.text('Crop'), findsOneWidget);
      await tester.tap(find.text('Crop'));
      await tester.pump();
      expect(cropToggled, isTrue);
    });
  });
}
