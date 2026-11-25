/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/onboarding/welcome_onboarding_dialog.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.setup();

  setUp(() {
    stows.hasSeenOnboarding.value = false;
  });

  Widget buildHarness({
    required Widget child,
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1D4ED8),
        brightness: brightness,
      ),
      home: Scaffold(body: child),
    );
  }

  Future<void> setViewport(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('OpennoteOnboardingFlow', () {
    testWidgets(
      'traverses all 4 steps, supports Back navigation, and starts Annual trial',
      (tester) async {
        await setViewport(tester, const Size(390, 844));
        OnboardingCompletionResult? completionResult;
        String? startedSku;
        OnboardingPersona? startedPersona;

        await tester.pumpWidget(
          buildHarness(
            child: OpennoteOnboardingFlow(
              onStartTrial: (sku, persona) async {
                startedSku = sku;
                startedPersona = persona;
                return true;
              },
              onCompleted: (result) => completionResult = result,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Step 1: Welcome hero
        expect(find.text('Step 1 of 4'), findsOneWidget);
        expect(
          find.text('Notes & Diagrams at the Speed of Thought'),
          findsOneWidget,
        );
        expect(find.text('120Hz Ink'), findsOneWidget);
        expect(find.text('Precision Drafting'), findsOneWidget);
        expect(find.text('Infinite Canvas'), findsOneWidget);
        expect(find.text('Local-First Privacy'), findsOneWidget);

        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();

        // Step 2: Persona picker
        expect(find.text('Step 2 of 4'), findsOneWidget);
        expect(find.text('How will you use Opennote?'), findsOneWidget);

        await tester.tap(find.text('University & Lecture Notes'));
        await tester.pumpAndSettle();
        expect(
          find.text('Starter notebook: Semester Lecture Notes'),
          findsOneWidget,
        );

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 3: Tailored superpowers for University persona
        expect(find.text('Step 3 of 4'), findsOneWidget);
        expect(find.text('Study Tape & Active Recall'), findsOneWidget);
        expect(find.text('Cornell & STEM Templates'), findsOneWidget);
        expect(find.text('Scribble-to-Erase Gestures'), findsOneWidget);

        // Verify Back returns to Step 2 with selection preserved
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        expect(find.text('Step 2 of 4'), findsOneWidget);

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Step 4: Soft-paywall trial offer
        expect(find.text('Step 4 of 4'), findsOneWidget);
        expect(find.text('Try Opennote Pro Free for 7 Days'), findsOneWidget);
        expect(find.text('\$29.99/yr'), findsOneWidget);
        expect(find.text('Continue with Free'), findsOneWidget);
        expect(find.text('Restore Purchases'), findsOneWidget);

        final ctaFinder = find.text('Start 7-Day Free Trial');
        await tester.ensureVisible(ctaFinder);
        await tester.tap(ctaFinder);
        await tester.pumpAndSettle();

        expect(startedSku, OnboardingPlanSku.annual);
        expect(startedPersona, OnboardingPersona.universityNotes);
        expect(
          completionResult,
          const OnboardingCompletionResult(
            persona: OnboardingPersona.universityNotes,
            startedTrial: true,
            selectedPlanSku: OnboardingPlanSku.annual,
          ),
        );
      },
    );

    testWidgets(
      'allows switching to Monthly plan, Continue with Free, and Restore Purchases',
      (tester) async {
        await setViewport(tester, const Size(1024, 768));
        OnboardingCompletionResult? result;
        var restoreTapped = false;

        await tester.pumpWidget(
          buildHarness(
            child: OpennoteOnboardingFlow(
              initialPersona: OnboardingPersona.pdfAnnotation,
              onRestorePurchases: () async {
                restoreTapped = true;
                return false;
              },
              onCompleted: (value) => result = value,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Advance to Step 4
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Verify PDF persona superpowers on Step 3
        expect(find.text('PDF Dark Mode & Smart Ink'), findsOneWidget);
        expect(find.text('Infinite Margin Notes'), findsOneWidget);

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Switch to Monthly plan
        final monthlyFinder = find.text('Monthly');
        await tester.ensureVisible(monthlyFinder);
        await tester.tap(monthlyFinder);
        await tester.pumpAndSettle();
        expect(find.text('Start Pro Monthly'), findsOneWidget);

        // Tap Restore Purchases
        final restoreFinder = find.text('Restore Purchases');
        await tester.ensureVisible(restoreFinder);
        await tester.tap(restoreFinder);
        await tester.pumpAndSettle();
        expect(restoreTapped, isTrue);
        expect(result, isNull);

        // Tap zero-pressure Continue with Free
        final freeFinder = find.text('Continue with Free');
        await tester.ensureVisible(freeFinder);
        await tester.tap(freeFinder);
        await tester.pumpAndSettle();

        expect(
          result,
          const OnboardingCompletionResult(
            persona: OnboardingPersona.pdfAnnotation,
            startedTrial: false,
            skipped: false,
          ),
        );
      },
    );

    testWidgets('Skip control completes immediately with skipped=true', (
      tester,
    ) async {
      await setViewport(tester, const Size(390, 844));
      OnboardingCompletionResult? result;

      await tester.pumpWidget(
        buildHarness(
          child: OpennoteOnboardingFlow(
            initialPersona: OnboardingPersona.visualBrainstorming,
            onCompleted: (value) => result = value,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(
        result,
        const OnboardingCompletionResult(
          persona: OnboardingPersona.visualBrainstorming,
          startedTrial: false,
          skipped: true,
        ),
      );
    });

    testWidgets(
      'renders all 4 steps with zero RenderFlex overflow on phone and tablet in light and dark themes',
      (tester) async {
        final configs = <(Size, Brightness)>[
          (const Size(360, 640), Brightness.light),
          (const Size(390, 844), Brightness.light),
          (const Size(390, 844), Brightness.dark),
          (const Size(1024, 768), Brightness.light),
          (const Size(1024, 768), Brightness.dark),
        ];

        for (final (size, brightness) in configs) {
          await setViewport(tester, size);
          await tester.pumpWidget(
            buildHarness(
              brightness: brightness,
              child: OpennoteOnboardingFlow(key: ValueKey('$size-$brightness')),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          await tester.tap(find.text('Get Started'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'WelcomeOnboardingDialog.showFlow returns completion result and marks onboarding seen',
      (tester) async {
        await setViewport(tester, const Size(1024, 768));
        OnboardingCompletionResult? flowResult;

        await tester.pumpWidget(
          buildHarness(
            child: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  flowResult = await WelcomeOnboardingDialog.showFlow(context);
                },
                child: const Text('Launch Flow'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Launch Flow'));
        await tester.pumpAndSettle();

        expect(
          find.text('Notes & Diagrams at the Speed of Thought'),
          findsOneWidget,
        );

        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        expect(flowResult?.skipped, isTrue);
        expect(stows.hasSeenOnboarding.value, isTrue);
      },
    );
  });
}
