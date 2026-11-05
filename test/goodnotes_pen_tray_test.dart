/// 🤖 Generated wholely or partially with Grok 4.7
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/toolbar/editor_toolbar_actions.dart';
import 'package:saber/components/toolbar/goodnotes_toolbar.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pen_tray.dart';
import 'package:saber/i18n/strings.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FlavorConfig.setup();
    LocaleSettings.setLocale(AppLocale.en);
    FileManager.documentsDirectory = Directory.systemTemp.path;
  });

  setUp(() {
    stows.penTray.value = PenTray.encodedDefaults;
    stows.penTrayIndex.value = 0;
  });

  test('the tray starts with six saved pens', () {
    expect(PenTray.presets, hasLength(6));
    expect(PenTray.presets.first.color, 0xFF000000);
    expect(PenTray.presets.first.size, 2);
    expect(PenTray.selectedIndex, 0);
    expect(PenTray.encode(PenTray.defaultPresets), PenTray.encodedDefaults);
  });

  test('selecting a saved pen changes the current pen in place', () {
    final pen = Pen.currentPen;
    final blue = PenTray.presets[1];

    PenTray.select(1, pen);

    expect(identical(pen, Pen.currentPen), isTrue);
    expect(pen.color.toARGB32(), blue.color);
    expect(pen.options.size, blue.size);
    expect(PenTray.selectedIndex, 1);
    expect(PenTray.presets[0].color, 0xFF000000);
  });

  test('editing the pen updates only the selected saved pen', () {
    final pen = Pen.currentPen;
    PenTray.select(2, pen);
    pen.color = const Color(0xFF00ACC1);
    pen.options.size = 7.5;

    PenTray.remember(pen);

    expect(PenTray.selectedIndex, 2);
    expect(PenTray.presets[2].color, 0xFF00ACC1);
    expect(PenTray.presets[2].size, 7.5);
    expect(PenTray.presets[0].color, 0xFF000000);
    expect(PenTray.presets[0].size, 2);
    expect(identical(pen, Pen.currentPen), isTrue);
  });

  test('a broken tray falls back to the default pens', () {
    stows.penTray.value = 'not-a-pen';
    expect(PenTray.presets.map((pen) => pen.color), [
      for (final pen in PenTray.defaultPresets) pen.color,
    ]);
  });

  testWidgets('the pen toolbar shows the tray and applies the tapped pen', (
    tester,
  ) async {
    final pen = Pen.currentPen;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoodnotesToolbar(
            actions: _actions(pen),
            onToggleZoomWindow: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('pen-tray-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('pen-tray-5')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('pen-tray-4')));
    await tester.pump();

    final chosen = PenTray.defaultPresets[4];
    expect(identical(pen, Pen.currentPen), isTrue);
    expect(pen.color.toARGB32(), chosen.color);
    expect(pen.options.size, chosen.size);
    expect(PenTray.selectedIndex, 4);
  });

  testWidgets('the highlighter toolbar does not show the pen tray', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoodnotesToolbar(
            actions: _actions(Highlighter.currentHighlighter),
            onToggleZoomWindow: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('pen-tray-0')), findsNothing);
  });
}

EditorToolbarActions _actions(Tool currentTool) {
  return EditorToolbarActions(
    readOnly: false,
    setTool: (_) {},
    currentTool: currentTool,
    setColor: (_) {},
    quillFocus: ValueNotifier(null),
    textEditing: false,
    toggleTextEditing: () {},
    pickPhoto: () {},
    pickShape: () {},
    paste: () {},
    copySelection: () {},
    pasteSelection: () {},
    duplicateSelection: () {},
    deleteSelection: () {},
  );
}
