/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/save_indicator.dart';
import 'package:saber/components/home/preview_card.dart';
import 'package:saber/components/toolbar/goodnotes_header_bar.dart';
import 'package:saber/components/toolbar/goodnotes_toolbar.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/arrow.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/study_tape.dart';
import 'package:saber/i18n/strings.g.dart';

void main() {
  setUpAll(() {
    FlavorConfig.setup();
    LocaleSettings.setLocale(AppLocale.en);
    FileManager.documentsDirectory = Directory.systemTemp.path;
  });

  group('Goodnotes UI Mode Preference Tests', () {
    test('goodnotesUiMode is true by default on feat/goodnotes-ui branch', () {
      expect(stows.goodnotesUiMode.value, isTrue);
    });

    test('goodnotesUiMode can be toggled', () {
      stows.goodnotesUiMode.value = false;
      expect(stows.goodnotesUiMode.value, isFalse);
      stows.goodnotesUiMode.value = true;
      expect(stows.goodnotesUiMode.value, isTrue);
    });
  });

  group('GoodnotesHeaderBar Widget Tests', () {
    testWidgets(
      'Renders all document navigation controls, tabs, and action icons',
      (tester) async {
        bool backPressed = false;
        bool openThumbnailsPressed = false;
        bool toggleBookmarkPressed = false;
        bool insertPagePressed = false;
        bool undoPressed = false;
        bool redoPressed = false;
        bool exportPressed = false;
        bool toggleHandModePressed = false;
        bool openMenuPressed = false;

        final filenameController = TextEditingController(text: 'Physics Notes');
        final filenameFormKey = GlobalKey<FormState>();
        final savingState = ValueNotifier(SavingState.saved);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: GoodnotesHeaderBar(
                filePath: '/notes/Physics Notes.sba',
                filenameTextEditingController: filenameController,
                filenameFormKey: filenameFormKey,
                renameFile: (_) {},
                validateFilename: (_) => null,
                needsNaming: false,
                savingState: savingState,
                triggerSave: () {},
                onBack: () => backPressed = true,
                onOpenThumbnails: () => openThumbnailsPressed = true,
                currentPageIndex: 0,
                totalPages: 5,
                isInfiniteCanvas: false,
                isBookmarked: false,
                onToggleBookmark: () => toggleBookmarkPressed = true,
                onInsertPage: () => insertPagePressed = true,
                undo: () => undoPressed = true,
                canUndo: true,
                redo: () => redoPressed = true,
                canRedo: true,
                onExport: () => exportPressed = true,
                isHandScrollMode: false,
                onToggleHandScrollMode: () => toggleHandModePressed = true,
                onOpenMenu: () => openMenuPressed = true,
              ),
            ),
          ),
        );

        // Verify Back button
        expect(find.byIcon(CupertinoIcons.chevron_back), findsOneWidget);
        await tester.tap(find.byIcon(CupertinoIcons.chevron_back));
        expect(backPressed, isTrue);

        // Verify Document Hub (page count 1 / 5)
        expect(find.text('1 / 5'), findsOneWidget);
        await tester.tap(find.text('1 / 5'));
        expect(openThumbnailsPressed, isTrue);

        // Verify Document Tab Title
        expect(find.text('Physics Notes'), findsOneWidget);

        // Verify Add Page button
        expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
        await tester.tap(find.byIcon(CupertinoIcons.add));
        expect(insertPagePressed, isTrue);

        // Verify Undo & Redo buttons
        expect(find.byIcon(Icons.undo), findsOneWidget);
        expect(find.byIcon(Icons.redo), findsOneWidget);
        await tester.tap(find.byIcon(Icons.undo));
        expect(undoPressed, isTrue);
        await tester.tap(find.byIcon(Icons.redo));
        expect(redoPressed, isTrue);

        // Verify Bookmark button
        expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
        await tester.tap(find.byIcon(Icons.star_border_rounded));
        expect(toggleBookmarkPressed, isTrue);

        // Verify Export button
        expect(find.byIcon(CupertinoIcons.share), findsOneWidget);
        await tester.tap(find.byIcon(CupertinoIcons.share));
        expect(exportPressed, isTrue);

        // Verify Hand Scroll Mode toggle
        expect(find.byIcon(CupertinoIcons.hand_raised), findsOneWidget);
        await tester.tap(find.byIcon(CupertinoIcons.hand_raised));
        expect(toggleHandModePressed, isTrue);

        // Verify More (...) button
        expect(find.byIcon(CupertinoIcons.ellipsis), findsOneWidget);
        await tester.tap(find.byIcon(CupertinoIcons.ellipsis));
        expect(openMenuPressed, isTrue);
      },
    );

    testWidgets('Bookmarked page shows filled amber star', (tester) async {
      final filenameController = TextEditingController(text: 'Bookmarked Note');
      final filenameFormKey = GlobalKey<FormState>();
      final savingState = ValueNotifier(SavingState.saved);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: GoodnotesHeaderBar(
              filePath: '/notes/Bookmarked.sba',
              filenameTextEditingController: filenameController,
              filenameFormKey: filenameFormKey,
              renameFile: (_) {},
              validateFilename: (_) => null,
              needsNaming: false,
              savingState: savingState,
              triggerSave: () {},
              onBack: () {},
              onOpenThumbnails: () {},
              currentPageIndex: 2,
              totalPages: 3,
              isInfiniteCanvas: false,
              isBookmarked: true,
              onToggleBookmark: () {},
              onInsertPage: () {},
              undo: () {},
              canUndo: false,
              redo: () {},
              canRedo: false,
              onExport: () {},
              isHandScrollMode: false,
              onToggleHandScrollMode: () {},
              onOpenMenu: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('Hand scroll mode shows filled hand icon indicator', (
      tester,
    ) async {
      final filenameController = TextEditingController(
        text: 'Reading Mode Note',
      );
      final filenameFormKey = GlobalKey<FormState>();
      final savingState = ValueNotifier(SavingState.saved);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: GoodnotesHeaderBar(
              filePath: '/notes/Reading.sba',
              filenameTextEditingController: filenameController,
              filenameFormKey: filenameFormKey,
              renameFile: (_) {},
              validateFilename: (_) => null,
              needsNaming: false,
              savingState: savingState,
              triggerSave: () {},
              onBack: () {},
              onOpenThumbnails: () {},
              currentPageIndex: 0,
              totalPages: 1,
              isInfiniteCanvas: false,
              isBookmarked: false,
              onToggleBookmark: () {},
              onInsertPage: () {},
              undo: () {},
              canUndo: false,
              redo: () {},
              canRedo: false,
              onExport: () {},
              isHandScrollMode: true,
              onToggleHandScrollMode: () {},
              onOpenMenu: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.hand_raised_fill), findsOneWidget);
    });
  });

  group('GoodnotesToolbar Dual-Tier Widget Tests', () {
    testWidgets('Tier 1 renders all 11 core note-taking tools', (tester) async {
      final quillFocus = ValueNotifier(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoodnotesToolbar(
              readOnly: false,
              setTool: (_) {},
              currentTool: Pen.currentPen,
              setColor: (_) {},
              quillFocus: quillFocus,
              textEditing: false,
              toggleTextEditing: () {},
              pickPhoto: () {},
              pickShape: () {},
              paste: () {},
              copySelection: () {},
              pasteSelection: () {},
              duplicateSelection: () {},
              deleteSelection: () {},
            ),
          ),
        ),
      );

      // Verify Tier 1 tools
      expect(find.byTooltip(Pen.currentPen.name), findsOneWidget);
      expect(find.byTooltip(t.editor.pens.pencil), findsOneWidget);
      expect(find.byTooltip(t.editor.toolbar.toggleEraser), findsOneWidget);
      expect(find.byTooltip(t.editor.pens.highlighter), findsOneWidget);
      expect(find.byTooltip('Shapes & Drafting'), findsOneWidget);
      expect(find.byTooltip(t.editor.toolbar.select), findsOneWidget);
      expect(find.byTooltip('Elements (Stickers)'), findsOneWidget);
      expect(find.byTooltip(t.editor.toolbar.photo), findsOneWidget);
      expect(find.byTooltip(t.editor.toolbar.text), findsOneWidget);
      expect(find.byTooltip('Study Tape (Active Recall)'), findsOneWidget);
      expect(
        find.byTooltip(
          stows.laserPointerMode.value == 'spotlight'
              ? 'Laser Pointer (Spotlight Mode)'
              : t.editor.pens.laserPointer,
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'Tier 2 dynamically shows quick colors & sizes when Pen is active',
      (tester) async {
        final quillFocus = ValueNotifier(null);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GoodnotesToolbar(
                readOnly: false,
                setTool: (_) {},
                currentTool: Pen.currentPen,
                setColor: (_) {},
                quillFocus: quillFocus,
                textEditing: false,
                toggleTextEditing: () {},
                pickPhoto: () {},
                pickShape: () {},
                paste: () {},
                copySelection: () {},
                pasteSelection: () {},
                duplicateSelection: () {},
                deleteSelection: () {},
              ),
            ),
          ),
        );

        // Verify 3 quick color slots are rendered
        expect(find.byKey(const ValueKey('quick_color_0')), findsOneWidget);
        expect(find.byKey(const ValueKey('quick_color_1')), findsOneWidget);
        expect(find.byKey(const ValueKey('quick_color_2')), findsOneWidget);

        // Verify 3 quick size slots are rendered
        expect(find.byKey(const ValueKey('quick_size_0')), findsOneWidget);
        expect(find.byKey(const ValueKey('quick_size_1')), findsOneWidget);
        expect(find.byKey(const ValueKey('quick_size_2')), findsOneWidget);

        // Verify full palette wheel button is present
        expect(find.byTooltip(t.editor.toolbar.toggleColors), findsOneWidget);
      },
    );

    testWidgets(
      'Tier 2 dynamically shows eraser quick sizes, clear page, and toggles when Eraser is active',
      (tester) async {
        final quillFocus = ValueNotifier(null);
        bool clearPageCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GoodnotesToolbar(
                readOnly: false,
                setTool: (_) {},
                currentTool: Eraser(size: 30),
                setColor: (_) {},
                quillFocus: quillFocus,
                textEditing: false,
                toggleTextEditing: () {},
                pickPhoto: () {},
                pickShape: () {},
                paste: () {},
                copySelection: () {},
                pasteSelection: () {},
                duplicateSelection: () {},
                deleteSelection: () {},
                onClearPage: () => clearPageCalled = true,
              ),
            ),
          ),
        );

        // Verify Eraser sizes: Fine, Medium, Broad
        expect(find.text('Fine'), findsOneWidget);
        expect(find.text('Medium'), findsOneWidget);
        expect(find.text('Broad'), findsOneWidget);

        // Verify Contextual Toggles
        expect(find.text('Highlighter Only'), findsOneWidget);
        expect(find.text('Entire Stroke'), findsOneWidget);
        expect(find.text('Clear Page'), findsOneWidget);

        // Tap Clear Page and verify confirmation dialog opens
        await tester.tap(find.text('Clear Page'));
        await tester.pumpAndSettle();
        expect(find.text('Clear Page?'), findsOneWidget);
        expect(find.text('Clear'), findsOneWidget);

        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        expect(clearPageCalled, isTrue);
      },
    );

    testWidgets(
      'Tier 2 dynamically shows lasso filter chips when Lasso is active',
      (tester) async {
        final quillFocus = ValueNotifier(null);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GoodnotesToolbar(
                readOnly: false,
                setTool: (_) {},
                currentTool: Select.currentSelect,
                setColor: (_) {},
                quillFocus: quillFocus,
                textEditing: false,
                toggleTextEditing: () {},
                pickPhoto: () {},
                pickShape: () {},
                paste: () {},
                copySelection: () {},
                pasteSelection: () {},
                duplicateSelection: () {},
                deleteSelection: () {},
              ),
            ),
          ),
        );

        expect(find.text('Handwriting'), findsOneWidget);
        expect(find.text('Images'), findsOneWidget);
        expect(find.text('Text Boxes'), findsOneWidget);
        expect(find.text('Tape'), findsOneWidget);
      },
    );

    testWidgets(
      'Tier 2 dynamically shows Study Tape recall actions when Tape is active',
      (tester) async {
        final quillFocus = ValueNotifier(null);
        bool concealCalled = false;
        bool revealCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GoodnotesToolbar(
                readOnly: false,
                setTool: (_) {},
                currentTool: StudyTapeTool(),
                setColor: (_) {},
                quillFocus: quillFocus,
                textEditing: false,
                toggleTextEditing: () {},
                pickPhoto: () {},
                pickShape: () {},
                paste: () {},
                copySelection: () {},
                pasteSelection: () {},
                duplicateSelection: () {},
                deleteSelection: () {},
                onConcealAllTape: () => concealCalled = true,
                onRevealAllTape: () => revealCalled = true,
              ),
            ),
          ),
        );

        expect(find.text('Conceal All'), findsOneWidget);
        expect(find.text('Reveal All'), findsOneWidget);
        expect(find.text('Patterns'), findsOneWidget);

        await tester.tap(find.text('Conceal All'));
        expect(concealCalled, isTrue);

        await tester.tap(find.text('Reveal All'));
        expect(revealCalled, isTrue);
      },
    );

    testWidgets(
      'Tier 2 dynamically shows shapes & drafting shortcuts when Drafting is active',
      (tester) async {
        final quillFocus = ValueNotifier(null);
        bool pickShapeCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GoodnotesToolbar(
                readOnly: false,
                setTool: (_) {},
                currentTool: ArrowTool(),
                setColor: (_) {},
                quillFocus: quillFocus,
                textEditing: false,
                toggleTextEditing: () {},
                pickPhoto: () {},
                pickShape: () => pickShapeCalled = true,
                paste: () {},
                copySelection: () {},
                pasteSelection: () {},
                duplicateSelection: () {},
                deleteSelection: () {},
              ),
            ),
          ),
        );

        expect(find.text('Shape Library'), findsOneWidget);
        expect(find.text('Ruler'), findsOneWidget);
        expect(find.text('Arrow'), findsOneWidget);
        expect(find.text('Dimension'), findsOneWidget);

        await tester.tap(find.text('Shape Library'));
        expect(pickShapeCalled, isTrue);
      },
    );
  });

  group('Goodnotes Notebook Cover Preview Tests', () {
    testWidgets(
      'PreviewCard renders Goodnotes-style notebook cover when no thumbnail image exists',
      (tester) async {
        stows.goodnotesUiMode.value = true;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 250,
                child: PreviewCard(
                  filePath: '/notes/Biology 101',
                  toggleSelection: (_, _) {},
                  selected: false,
                  isAnythingSelected: false,
                ),
              ),
            ),
          ),
        );

        // Verify the embossed notebook title card is displayed
        expect(find.text('Biology 101'), findsWidgets);
      },
    );
  });
}
