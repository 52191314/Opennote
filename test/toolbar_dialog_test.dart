/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/toolbar/toolbar_dialog.dart';

void main() {
  group('ToolbarDialog', () {
    Future<void> open(WidgetTester tester, ToolbarDialog dialog) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showDialog(context: context, builder: (_) => dialog),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows its icon, title, and content', (tester) async {
      await open(
        tester,
        const ToolbarDialog(
          icon: Icons.palette_outlined,
          title: 'Colors',
          child: Text('Swatches'),
        ),
      );

      expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
      expect(find.text('Colors'), findsOneWidget);
      expect(find.text('Swatches'), findsOneWidget);
    });

    testWidgets('closes from its close button', (tester) async {
      await open(
        tester,
        const ToolbarDialog(
          icon: Icons.tune_rounded,
          title: 'Pen settings',
          child: Text('Sliders'),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Pen settings'), findsNothing);
    });

    testWidgets('is no wider than maxWidth', (tester) async {
      await open(
        tester,
        const ToolbarDialog(
          icon: Icons.ios_share,
          title: 'Export',
          maxWidth: 420,
          child: SizedBox(width: 2000, height: 10),
        ),
      );

      final box = find.descendant(
        of: find.byType(ToolbarDialog),
        matching: find.byType(Container),
      );
      expect(tester.getSize(box.first).width, lessThanOrEqualTo(420));
    });
  });
}
