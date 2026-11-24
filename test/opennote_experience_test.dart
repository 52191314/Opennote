/// 🤖 Generated wholely or partially with Grok 4.7
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/components/home/notebook_shelf.dart';
import 'package:saber/components/toolbar/floating_pen_menu.dart';
import 'package:saber/data/editor/ink_search.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pen_tray.dart';
import 'package:saber/i18n/strings.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FlavorConfig.setup();
    LocaleSettings.setLocale(AppLocale.en);
  });

  setUp(() {
    stows.penTray.value = PenTray.encodedDefaults;
    stows.penTrayIndex.value = 0;
    stows.floatingPenMenuEdge.value = 'right';
  });

  group('Notebook shelf', () {
    testWidgets('a cover opens its notebook and a new notebook appears', (
      tester,
    ) async {
      final opened = <String>[];
      final folders = <String>[];
      await tester.pumpWidget(_ShelfHost(opened: opened, folders: folders));

      expect(
        find.byKey(const ValueKey('shelf-cover-/Physics')),
        findsOneWidget,
      );
      expect(find.text('Physics'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('shelf-cover-/Physics')));
      await tester.pump();
      expect(opened, ['/Physics']);

      await tester.tap(find.byKey(const ValueKey('shelf-new-notebook')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('shelf-notebook-name')),
        'Biology',
      );
      await tester.tap(find.byKey(const ValueKey('shelf-create-confirm')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('shelf-cover-/Biology')),
        findsOneWidget,
      );
      expect(find.text('Biology'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('shelf-folder-Seminar')));
      await tester.pump();
      expect(folders, ['Seminar']);
      expect(opened, ['/Physics']);
    });
  });

  group('Floating pen menu', () {
    testWidgets('the menu parks on each edge and keeps the last one', (
      tester,
    ) async {
      final pen = Pen.currentPen;
      Future<void> pumpMenu() {
        return tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WritingPenMenu(tool: pen, onChanged: () {}),
            ),
          ),
        );
      }

      await pumpMenu();
      final screen = tester.getSize(find.byType(Scaffold));

      for (final edge in PenMenuEdge.values) {
        await tester.tap(find.byKey(ValueKey('pen-menu-edge-${edge.name}')));
        await tester.pump();
        expect(PenMenuPlacement.edge, edge);
        _expectOnEdge(
          tester.getRect(find.byKey(const ValueKey('pen-menu'))),
          screen,
          edge,
        );
      }

      await pumpMenu();
      expect(PenMenuPlacement.edge, PenMenuEdge.left);
      _expectOnEdge(
        tester.getRect(find.byKey(const ValueKey('pen-menu'))),
        screen,
        PenMenuEdge.left,
      );

      final before = pen;
      await tester.tap(find.byKey(const ValueKey('pen-tray-3')));
      await tester.pump();
      final saved = PenTray.presets[3];
      expect(identical(before, Pen.currentPen), isTrue);
      expect(pen.color.toARGB32(), saved.color);
      expect(pen.options.size, saved.size);
    });

    testWidgets('a non-writing tool hides the menu', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WritingPenMenu(
              tool: Highlighter.currentHighlighter,
              onChanged: () {},
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('pen-menu')), findsNothing);
    });
  });

  group('Ink search', () {
    test('handwriting, file names, and typed text each match', () {
      final lecture = NoteDocument(
        filePath: '/Class/Lecture',
        fileName: 'Lecture',
        pages: [
          NotePage(ink: _wordHi()),
          NotePage(ink: _wordTo(), typedText: 'chlorophyll'),
        ],
      );
      const biology = NoteDocument(
        filePath: '/Biology',
        fileName: 'Biology',
        pages: [NotePage(ink: [])],
      );
      final notes = [lecture, biology];

      final hi = NoteSearch.search(
        query: 'hi',
        notes: notes,
      ).where((hit) => hit.matchKind == 'ink').toList();
      final to = NoteSearch.search(
        query: 'to',
        notes: notes,
      ).where((hit) => hit.matchKind == 'ink').toList();

      expect(hi, hasLength(1));
      expect(hi.single.pageIndex, 0);
      expect(hi.single.filePath, '/Class/Lecture');
      expect(to, hasLength(1));
      expect(to.single.pageIndex, 1);
      expect(hi.single.pageIndex, isNot(to.single.pageIndex));

      expect(
        NoteSearch.search(query: 'bio', notes: notes).any(
          (hit) => hit.matchKind == 'filename' && hit.filePath == '/Biology',
        ),
        isTrue,
      );
      expect(
        NoteSearch.search(
          query: 'chlor',
          notes: notes,
        ).any((hit) => hit.matchKind == 'text' && hit.pageIndex == 1),
        isTrue,
      );

      final uri = Uri.parse('https://notes.local${hi.single.openRoute}');
      expect(uri.queryParameters['path'], '/Class/Lecture');
      expect(RoutePaths.pageIndexFromUri(uri), 0);
    });

    test('an explicit page beats a cached scroll position', () {
      const path = '/Class/Lecture';
      final cached = Matrix4.translationValues(0, -900, 0);
      CanvasTransformCache.clear();
      CanvasTransformCache.add(path, cached);
      final seeded = CanvasTransformCache.get(path);
      addTearDown(CanvasTransformCache.clear);

      final openedAtPage = chooseCanvasOpenTarget(
        noteLoaded: true,
        userHasScrolled: false,
        cachedTransform: seeded?.transform,
        isInfiniteCanvas: false,
        explicitPageIndex: 2,
        savedPageIndex: 0,
      );
      expect(seeded, isNotNull);
      expect(openedAtPage.scroll, CanvasOpenScroll.scrollToPage);
      expect(openedAtPage.pageIndex, 2);

      final reopened = chooseCanvasOpenTarget(
        noteLoaded: true,
        userHasScrolled: false,
        cachedTransform: seeded?.transform,
        isInfiniteCanvas: false,
        explicitPageIndex: null,
        savedPageIndex: 0,
      );
      expect(reopened.scroll, CanvasOpenScroll.restoreCache);
    });

    test('stroke maps are read as the points that were written', () {
      final points = InkReader.pointsFrom([
        {'x': 10, 'y': 0},
        {'x': 10, 'y': 48},
      ]);
      expect(points.first, const Offset(10, 0));
      expect(points.last, const Offset(10, 48));
      expect(InkReader.read([points]), 'I');
    });
  });
}

void _expectOnEdge(Rect menu, Size screen, PenMenuEdge edge) {
  switch (edge) {
    case PenMenuEdge.top:
      expect(menu.top, lessThan(screen.height * 0.25));
    case PenMenuEdge.bottom:
      expect(menu.bottom, greaterThan(screen.height * 0.75));
    case PenMenuEdge.left:
      expect(menu.left, lessThan(screen.width * 0.25));
    case PenMenuEdge.right:
      expect(menu.right, greaterThan(screen.width * 0.75));
  }
}

List<Offset> _vertical(double x) => [Offset(x, 0), Offset(x, 48)];

List<Offset> _horizontal(double y, double left, double right) => [
  Offset(left, y),
  Offset(right, y),
];

List<List<Offset>> _wordHi() => [
  _vertical(10),
  _vertical(26),
  _horizontal(24, 10, 26),
  _vertical(80),
];

List<List<Offset>> _wordTo() => [
  _horizontal(0, 0, 40),
  _vertical(20),
  _circle(const Offset(110, 24), 18),
];

List<Offset> _circle(Offset center, double radius) {
  const steps = 16;
  return [
    for (var step = 0; step <= steps; step++)
      center +
          Offset(
            radius * math.cos(2 * math.pi * step / steps),
            radius * math.sin(2 * math.pi * step / steps),
          ),
  ];
}

class _ShelfHost extends StatefulWidget {
  const _ShelfHost({required this.opened, required this.folders});

  final List<String> opened;
  final List<String> folders;

  @override
  State<_ShelfHost> createState() => _ShelfHostState();
}

class _ShelfHostState extends State<_ShelfHost> {
  var _notes = const ['/Physics'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: NotebookShelf(
          notes: _notes,
          folders: const ['Seminar'],
          onOpenNote: widget.opened.add,
          onOpenFolder: widget.folders.add,
          onCreateNote: (path) => setState(() => _notes = [..._notes, path]),
        ),
      ),
    );
  }
}
