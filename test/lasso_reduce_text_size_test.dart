/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/lasso_callout_menu.dart';
import 'package:saber/components/toolbar/selection_bar.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/editor/selection_resize.dart';
import 'package:saber/data/editor/selection_transform.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/i18n/strings.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FlavorConfig.setup();
    LocaleSettings.setLocale(AppLocale.en);
  });

  group('LassoCalloutMenu reduce and enlarge size controls', () {
    testWidgets(
      'renders Reduce Size and Enlarge Size buttons and triggers callbacks',
      (tester) async {
        var reduceCalled = 0;
        var enlargeCalled = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LassoCalloutMenu(
                onCut: () {},
                onCopy: () {},
                onDuplicate: () {},
                onDelete: () {},
                onSetColor: (_) {},
                onReduceTextSize: () => reduceCalled++,
                onEnlargeTextSize: () => enlargeCalled++,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final reduceFinder = find.byIcon(Icons.text_decrease_rounded);
        expect(reduceFinder, findsOneWidget);

        await tester.tap(reduceFinder);
        await tester.pumpAndSettle();
        expect(reduceCalled, equals(1));

        final enlargeFinder = find.byIcon(Icons.text_increase_rounded);
        expect(enlargeFinder, findsOneWidget);

        await tester.tap(enlargeFinder);
        await tester.pumpAndSettle();
        expect(enlargeCalled, equals(1));
      },
    );
  });

  group('SelectionBar reduce and enlarge size controls', () {
    testWidgets(
      'renders reduceTextSize and enlargeTextSize icons and triggers callbacks',
      (tester) async {
        var reduceCalled = 0;
        var enlargeCalled = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionBar(
                copySelection: () {},
                pasteSelection: () {},
                duplicateSelection: () {},
                deleteSelection: () {},
                reduceTextSize: () => reduceCalled++,
                enlargeTextSize: () => enlargeCalled++,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final reduceFinder = find.byIcon(Icons.text_decrease_rounded);
        expect(reduceFinder, findsOneWidget);

        await tester.tap(reduceFinder);
        await tester.pumpAndSettle();
        expect(reduceCalled, equals(1));

        final enlargeFinder = find.byIcon(Icons.text_increase_rounded);
        expect(enlargeFinder, findsOneWidget);

        await tester.tap(enlargeFinder);
        await tester.pumpAndSettle();
        expect(enlargeCalled, equals(1));
      },
    );
  });

  group('Text size scaling logic on lasso selection', () {
    test(
      'reducing text size scales textContentScale and updates textContentOffset towards center',
      () {
        final page = EditorPage(
          textContentOffset: const Offset(100, 100),
          textContentScale: 1.0,
        );

        final rect = const Rect.fromLTWH(50, 50, 200, 200);
        final selection = SelectResult(
          pageIndex: 0,
          strokes: [],
          images: [],
          textSelected: true,
          path: Path()..addRect(rect),
        );

        final factor = 0.85;
        final center = rect.center; // (150, 150)

        final transform = SelectionTransform.begin(page, selection);

        // Apply reduction
        page.textContentOffset =
            center + (page.textContentOffset - center) * factor;
        page.textContentScale = (page.textContentScale * factor).clamp(
          0.2,
          5.0,
        );
        selection.path = scalePathAround(
          selection.path,
          factor,
          factor,
          center,
        );

        final historyItem = transform.finish(pageIndex: 0);

        expect(page.textContentScale, closeTo(0.85, 0.001));
        // Offset was (100, 100). Center is (150, 150).
        // New offset = 150 + (100 - 150) * 0.85 = 150 - 42.5 = 107.5
        expect(page.textContentOffset.dx, closeTo(107.5, 0.001));
        expect(page.textContentOffset.dy, closeTo(107.5, 0.001));

        // Path bounds should also be scaled by 0.85
        final newBounds = selection.path.getBounds();
        expect(newBounds.width, closeTo(200 * 0.85, 0.001));
        expect(newBounds.height, closeTo(200 * 0.85, 0.001));
        expect(newBounds.center.dx, closeTo(150, 0.001));
        expect(newBounds.center.dy, closeTo(150, 0.001));

        // Revert should bring everything back
        SelectionTransform.revert(historyItem, page);
        expect(page.textContentScale, equals(1.0));
        expect(page.textContentOffset, equals(const Offset(100, 100)));
      },
    );

    test(
      'textContentScale clamping prevents reducing below minimum bound 0.2',
      () {
        final page = EditorPage(textContentScale: 0.22);
        const factor = 0.85;

        page.textContentScale = (page.textContentScale * factor).clamp(
          0.2,
          5.0,
        );
        expect(page.textContentScale, closeTo(0.2, 0.001));

        page.textContentScale = (page.textContentScale * factor).clamp(
          0.2,
          5.0,
        );
        expect(page.textContentScale, equals(0.2));
      },
    );
  });
}
