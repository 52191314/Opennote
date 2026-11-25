/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/design_system/design_system.dart';
import 'package:saber/components/theming/saber_theme.dart';

double _contrastRatio(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

Widget _wrapWithTheme(
  Widget child, {
  Brightness brightness = Brightness.light,
  TargetPlatform platform = TargetPlatform.android,
}) {
  final theme = SaberTheme.createThemeFromSeed(
    OpennoteTokens.brandSeed,
    brightness,
    platform,
  );
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('OpennoteTokens', () {
    test('defines refined studio light and dark surface tiers', () {
      expect(OpennoteTokens.studioLightSurface, const Color(0xFFFAF9F6));
      expect(OpennoteTokens.cardLightSurface, const Color(0xFFFFFFFF));
      expect(OpennoteTokens.studioDarkSurface, const Color(0xFF0F1115));
      expect(OpennoteTokens.cardDarkSurface, const Color(0xFF181B22));

      expect(
        OpennoteTokens.studioSurface(Brightness.light),
        OpennoteTokens.studioLightSurface,
      );
      expect(
        OpennoteTokens.studioSurface(Brightness.dark),
        OpennoteTokens.studioDarkSurface,
      );
      expect(
        OpennoteTokens.cardSurface(Brightness.light),
        OpennoteTokens.cardLightSurface,
      );
      expect(
        OpennoteTokens.cardSurface(Brightness.dark),
        OpennoteTokens.cardDarkSurface,
      );
    });

    test('spacing, radius, motion, and breakpoint scales are monotonic', () {
      expect([
        OpennoteTokens.s0,
        OpennoteTokens.s0_5,
        OpennoteTokens.s1,
        OpennoteTokens.s2,
        OpennoteTokens.s3,
        OpennoteTokens.s4,
        OpennoteTokens.s5,
        OpennoteTokens.s6,
        OpennoteTokens.s7,
        OpennoteTokens.s8,
        OpennoteTokens.s10,
        OpennoteTokens.s12,
        OpennoteTokens.s16,
      ], orderedEquals(const [0, 2, 4, 8, 12, 16, 20, 24, 28, 32, 40, 48, 64]));

      expect(OpennoteTokens.radiusXs, lessThan(OpennoteTokens.radiusSm));
      expect(OpennoteTokens.radiusSm, lessThan(OpennoteTokens.radiusMd));
      expect(OpennoteTokens.radiusMd, lessThan(OpennoteTokens.radiusLg));
      expect(OpennoteTokens.radiusLg, lessThan(OpennoteTokens.radiusXl));
      expect(OpennoteTokens.radiusXl, lessThan(OpennoteTokens.radiusPill));

      expect(
        OpennoteTokens.durationInstant,
        lessThan(OpennoteTokens.durationFast),
      );
      expect(
        OpennoteTokens.durationFast,
        lessThan(OpennoteTokens.durationMedium),
      );
      expect(
        OpennoteTokens.durationMedium,
        lessThan(OpennoteTokens.durationSlow),
      );

      expect(OpennoteTokens.isCompactWidth(390), isTrue);
      expect(OpennoteTokens.isMediumWidth(720), isTrue);
      expect(OpennoteTokens.isExpandedWidth(1280), isTrue);
    });

    test('maintains accessible contrast for brand and Pro accents', () {
      // Primary indigo on light card meets AA (>= 4.5:1)
      expect(
        _contrastRatio(
          OpennoteTokens.primaryAccent,
          OpennoteTokens.cardLightSurface,
        ),
        greaterThanOrEqualTo(4.5),
      );

      // Luminous cobalt on dark card meets AA (>= 4.5:1)
      expect(
        _contrastRatio(
          OpennoteTokens.primaryAccentDark,
          OpennoteTokens.cardDarkSurface,
        ),
        greaterThanOrEqualTo(4.5),
      );

      // Pro CTA foreground/background contrast in light and dark modes
      expect(
        _contrastRatio(
          OpennoteTokens.onProAccentFor(Brightness.light),
          OpennoteTokens.proAccentFor(Brightness.light),
        ),
        greaterThanOrEqualTo(3.0),
      );
      expect(
        _contrastRatio(
          OpennoteTokens.onProAccentFor(Brightness.dark),
          OpennoteTokens.proAccentFor(Brightness.dark),
        ),
        greaterThanOrEqualTo(7.0),
      );
    });

    test('preserves backward-compatible border and shadow helpers', () {
      final lightScheme = ColorScheme.fromSeed(
        seedColor: OpennoteTokens.brandSeed,
        brightness: Brightness.light,
      );
      final darkScheme = ColorScheme.fromSeed(
        seedColor: OpennoteTokens.brandSeed,
        brightness: Brightness.dark,
      );

      expect(OpennoteTokens.subtleBorder(lightScheme).width, 1.0);
      expect(OpennoteTokens.hairlineBorder(darkScheme).width, 1.0);
      expect(OpennoteTokens.floatingShadow(Brightness.light), hasLength(2));
      expect(OpennoteTokens.floatingShadow(Brightness.dark), hasLength(2));
      expect(OpennoteTokens.cardShadow(Brightness.light), hasLength(1));
      expect(OpennoteTokens.hoverCardShadow(Brightness.dark), hasLength(2));
    });
  });

  group('SaberTheme studio refinement', () {
    for (final brightness in Brightness.values) {
      test('configures studio component themes in ${brightness.name} mode', () {
        final theme = SaberTheme.createThemeFromSeed(
          OpennoteTokens.brandSeed,
          brightness,
          TargetPlatform.android,
        );

        expect(theme.useMaterial3, isTrue);
        expect(theme.cardTheme.elevation, 0);
        expect(theme.cardTheme.color, OpennoteTokens.cardSurface(brightness));
        expect(theme.appBarTheme.scrolledUnderElevation, 0);
        expect(theme.appBarTheme.surfaceTintColor, Colors.transparent);
        expect(theme.inputDecorationTheme.filled, isTrue);
        expect(
          theme.inputDecorationTheme.fillColor,
          OpennoteTokens.subtleSurface(brightness),
        );
        expect(theme.chipTheme.elevation, 0);
        expect(
          theme.bottomSheetTheme.backgroundColor,
          OpennoteTokens.cardSurface(brightness),
        );
        expect(theme.filledButtonTheme.style, isNotNull);
        expect(theme.outlinedButtonTheme.style, isNotNull);
        expect(theme.dividerTheme.thickness, OpennoteTokens.hairlineWidth);
      });
    }
  });

  group('OpennoteGlassPill', () {
    testWidgets('renders child in light and dark modes with blur toggled', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          _wrapWithTheme(
            const OpennoteGlassPill(
              padding: EdgeInsets.all(OpennoteTokens.s3),
              child: Text('Studio Pill'),
            ),
            brightness: brightness,
          ),
        );
        expect(find.text('Studio Pill'), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
      }

      await tester.pumpWidget(
        _wrapWithTheme(
          const OpennoteGlassPill(
            enableBlur: false,
            showShadow: false,
            child: Text('Flat Pill'),
          ),
        ),
      );
      expect(find.text('Flat Pill'), findsOneWidget);
    });
  });

  group('OpennoteSegmentedBar', () {
    testWidgets('renders segments and notifies onChanged on tap', (
      tester,
    ) async {
      var selected = 'notes';
      await tester.pumpWidget(
        _wrapWithTheme(
          StatefulBuilder(
            builder: (context, setState) {
              return OpennoteSegmentedBar<String>(
                selectedValue: selected,
                onChanged: (value) => setState(() => selected = value),
                segments: const [
                  OpennoteSegmentItem(
                    value: 'notes',
                    label: 'Notes',
                    icon: Icons.edit_note_rounded,
                  ),
                  OpennoteSegmentItem(
                    value: 'folders',
                    label: 'Folders',
                    icon: Icons.folder_outlined,
                    tooltip: 'Browse folders',
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Folders'), findsOneWidget);

      await tester.tap(find.text('Folders'));
      await tester.pumpAndSettle();
      expect(selected, 'folders');
    });
  });

  group('OpennoteCard', () {
    testWidgets('handles tap, long-press, and selected state', (tester) async {
      var tapped = false;
      var longPressed = false;

      await tester.pumpWidget(
        _wrapWithTheme(
          OpennoteCard(
            selected: true,
            semanticLabel: 'Notebook card',
            onTap: () => tapped = true,
            onLongPress: () => longPressed = true,
            child: const Text('Architecture Notes'),
          ),
          brightness: Brightness.dark,
        ),
      );

      expect(find.text('Architecture Notes'), findsOneWidget);
      await tester.tap(find.text('Architecture Notes'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);

      await tester.longPress(find.text('Architecture Notes'));
      await tester.pumpAndSettle();
      expect(longPressed, isTrue);
    });
  });

  group('OpennoteSheetHeader', () {
    testWidgets('renders title, subtitle, drag handle, and close action', (
      tester,
    ) async {
      var closed = false;

      await tester.pumpWidget(
        _wrapWithTheme(
          OpennoteSheetHeader(
            title: 'Page Templates',
            subtitle: 'Choose a studio paper layout',
            onClose: () => closed = true,
          ),
        ),
      );

      expect(find.text('Page Templates'), findsOneWidget);
      expect(find.text('Choose a studio paper layout'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(closed, isTrue);
    });
  });

  group('OpennoteSectionHeader', () {
    testWidgets('renders title, subtitle, and triggers trailing action', (
      tester,
    ) async {
      var actionPressed = false;

      await tester.pumpWidget(
        _wrapWithTheme(
          OpennoteSectionHeader(
            title: 'Quick Start',
            subtitle: 'Create in one tap',
            actionLabel: 'See all',
            onAction: () => actionPressed = true,
          ),
        ),
      );

      expect(find.text('Quick Start'), findsOneWidget);
      expect(find.text('Create in one tap'), findsOneWidget);
      expect(find.text('See all'), findsOneWidget);

      await tester.tap(find.text('See all'));
      await tester.pumpAndSettle();
      expect(actionPressed, isTrue);
    });
  });

  group('OpennoteCtaButton', () {
    testWidgets('renders all variants and invokes onPressed', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        _wrapWithTheme(
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: OpennoteTokens.s2,
            children: [
              OpennoteCtaButton(
                label: 'Primary CTA',
                icon: Icons.add_rounded,
                variant: OpennoteCtaVariant.primary,
                onPressed: () => tapCount++,
              ),
              OpennoteCtaButton(
                label: 'Secondary CTA',
                variant: OpennoteCtaVariant.secondary,
                size: OpennoteCtaSize.compact,
                onPressed: () => tapCount++,
              ),
              OpennoteCtaButton(
                label: 'Upgrade to Pro',
                icon: Icons.workspace_premium_rounded,
                variant: OpennoteCtaVariant.pro,
                size: OpennoteCtaSize.large,
                onPressed: () => tapCount++,
              ),
              OpennoteCtaButton(
                label: 'Ghost CTA',
                variant: OpennoteCtaVariant.ghost,
                onPressed: () => tapCount++,
              ),
            ],
          ),
          brightness: Brightness.dark,
        ),
      );

      for (final label in [
        'Primary CTA',
        'Secondary CTA',
        'Upgrade to Pro',
        'Ghost CTA',
      ]) {
        await tester.tap(find.text(label));
      }
      await tester.pumpAndSettle();
      expect(tapCount, 4);
    });

    testWidgets('blocks taps and shows spinner when isLoading is true', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrapWithTheme(
          OpennoteCtaButton(
            label: 'Saving',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Saving'));
      await tester.pump();
      expect(tapped, isFalse);
    });
  });
}
