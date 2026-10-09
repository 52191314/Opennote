/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/onboarding/welcome_onboarding_dialog.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  group('Onboarding Guide Tests', () {
    setUp(() {
      stows.hasSeenOnboarding.value = false;
    });

    test('hasSeenOnboarding default is false', () {
      expect(stows.hasSeenOnboarding.value, isFalse);
    });

    testWidgets(
      'Renders WelcomeOnboardingDialog with carousel and navigation',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => WelcomeOnboardingDialog.show(context),
                  child: const Text('Show Onboarding'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Onboarding'));
        await tester.pumpAndSettle();

        // Check header and first card title
        expect(find.text('Welcome Guide'), findsOneWidget);
        expect(find.text('Silky Smooth Digital Paper'), findsOneWidget);
        expect(find.text('Pressure Sensitive'), findsOneWidget);

        // Verify Next button advances through carousel
        expect(find.text('Next'), findsOneWidget);
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Magic Stylus Gestures'), findsOneWidget);
        expect(find.text('Scribble to Erase'), findsOneWidget);

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Study Tape & Active Recall'), findsOneWidget);
        expect(find.text('Tap to Reveal'), findsOneWidget);

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Elements & Infinite Canvas'), findsOneWidget);
        expect(find.text('Try Playground'), findsOneWidget);
        expect(find.text('Get Started'), findsOneWidget);

        // Dismiss dialog
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        expect(find.text('Silky Smooth Digital Paper'), findsNothing);
        expect(stows.hasSeenOnboarding.value, isTrue);
      },
    );
  });
}
