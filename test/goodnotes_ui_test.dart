/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/save_indicator.dart';
import 'package:saber/components/home/preview_card.dart';
import 'package:saber/components/toolbar/goodnotes_header_bar.dart';
import 'package:saber/components/toolbar/goodnotes_toolbar.dart';
import 'package:saber/components/toolbar/toolbar.dart';
import 'package:saber/components/toolbar/toolbar_button.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/_tool.dart';
import 'package:saber/data/tools/arrow.dart';
import 'package:saber/data/tools/dimension.dart';
import 'package:saber/data/tools/elements.dart';
import 'package:saber/data/tools/eraser.dart';
import 'package:saber/data/tools/highlighter.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:saber/data/tools/pencil.dart';
import 'package:saber/data/tools/ruler.dart';
import 'package:saber/data/tools/select.dart';
import 'package:saber/data/tools/shape_pen.dart';
import 'package:saber/data/tools/study_tape.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

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

  group('Pen Identity and Tool Switching Tests', () {
    test(
      'Pen.isWritingPen correctly categorizes standard pens vs drafting/tape/other tools',
      () {
        expect(Pen.isWritingPen(Pen.fountainPen()), isTrue);
        expect(Pen.isWritingPen(Pen.ballpointPen()), isTrue);
        expect(Pen.isWritingPen(ShapePen()), isTrue);
        expect(Pen.isWritingPen(Ruler()), isFalse);
        expect(Pen.isWritingPen(ArrowTool()), isFalse);
        expect(Pen.isWritingPen(DimensionTool()), isFalse);
        expect(Pen.isWritingPen(StudyTapeTool()), isFalse);
        expect(Pen.isWritingPen(Highlighter()), isFalse);
        expect(Pen.isWritingPen(Pencil()), isFalse);
        expect(Pen.isWritingPen(Eraser(size: 10)), isFalse);
        expect(Pen.isWritingPen(Select.currentSelect), isFalse);
        expect(Pen.isWritingPen(null), isFalse);
      },
    );

    test('Pen.currentPen setter rejects non-writing Pen subclasses', () {
      Pen.currentPen = Pen.fountainPen();
      expect(Pen.currentPen.toolId, equals(ToolId.fountainPen));

      expect(() => Pen.currentPen = Ruler(), throwsAssertionError);
      expect(() => Pen.currentPen = ArrowTool(), throwsAssertionError);
      expect(() => Pen.currentPen = DimensionTool(), throwsAssertionError);
      expect(() => Pen.currentPen = StudyTapeTool(), throwsAssertionError);
      expect(() => Pen.currentPen = Highlighter(), throwsAssertionError);
      expect(() => Pen.currentPen = Pencil(), throwsAssertionError);

      expect(Pen.currentPen.toolId, equals(ToolId.fountainPen));
    });

    testWidgets(
      'GoodnotesToolbar: Tapping Pen button while on Ruler returns to Pen.currentPen',
      (tester) async {
        Pen.currentPen = Pen.fountainPen();
        final quillFocus = ValueNotifier(null);
        Tool? selectedTool;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GoodnotesToolbar(
                readOnly: false,
                setTool: (tool) => selectedTool = tool,
                currentTool: Ruler(),
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

        final penButton = find.byWidgetPredicate(
          (w) => w is ToolbarIconButton && w.tooltip == Pen.currentPen.name,
        );
        expect(penButton, findsOneWidget);

        final iconButtonWidget = tester.widget<ToolbarIconButton>(penButton);
        expect(iconButtonWidget.selected, isFalse);

        await tester.tap(penButton);
        await tester.pump();

        expect(selectedTool, isNotNull);
        expect(selectedTool, equals(Pen.currentPen));
        expect(find.text('Pen Options'), findsNothing);
      },
    );

    testWidgets(
      'GoodnotesToolbar: Tapping Pen button while already on Pen opens pen options dialog',
      (tester) async {
        Pen.currentPen = Pen.fountainPen();
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

        final penButton = find.byWidgetPredicate(
          (w) => w is ToolbarIconButton && w.tooltip == Pen.currentPen.name,
        );
        final iconButtonWidget = tester.widget<ToolbarIconButton>(penButton);
        expect(iconButtonWidget.selected, isTrue);

        await tester.tap(penButton);
        await tester.pumpAndSettle();

        expect(find.text('Pen Options'), findsOneWidget);
      },
    );

    testWidgets(
      'Toolbar: Tapping Pen button while on DimensionTool returns to Pen.currentPen',
      (tester) async {
        Pen.currentPen = Pen.fountainPen();
        Tool? selectedTool;

        final quillFocus = ValueNotifier(null);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Toolbar(
                readOnly: false,
                setTool: (tool) => selectedTool = tool,
                currentTool: DimensionTool(),
                setColor: (_) {},
                quillFocus: quillFocus,
                textEditing: false,
                toggleTextEditing: () {},
                undo: () {},
                isUndoPossible: false,
                redo: () {},
                isRedoPossible: false,
                toggleFingerDrawing: () {},
                pickPhoto: () {},
                pickShape: () {},
                paste: () {},
                copySelection: () {},
                pasteSelection: () {},
                duplicateSelection: () {},
                deleteSelection: () {},
                exportAsSba: (_) async {},
                exportAsPdf: (_) async {},
                exportAsPng: (_) async {},
              ),
            ),
          ),
        );

        final penButton = find.byWidgetPredicate(
          (w) => w is ToolbarIconButton && w.tooltip == Pen.currentPen.name,
        );
        expect(penButton, findsOneWidget);

        final iconButtonWidget = tester.widget<ToolbarIconButton>(penButton);
        expect(iconButtonWidget.selected, isFalse);

        await tester.tap(penButton);
        await tester.pump();

        expect(selectedTool, isNotNull);
        expect(selectedTool, equals(Pen.currentPen));
      },
    );
  });

  group('Elements Placement and Programmatic Selection Tests', () {
    test('ElementItem.instantiateStrokes aligns center to targetCenter', () {
      final elem = ElementsManager.instance.items.firstWhere(
        (e) => e.name == 'Sticky Note',
      );
      const target = Offset(450, 600);
      final strokes = elem.instantiateStrokes(
        page: const HasSize(Size(1000, 1000)),
        targetCenter: target,
      );
      expect(strokes, isNotEmpty);

      Rect? totalBounds;
      for (final s in strokes) {
        final b = s.highQualityPath.getBounds();
        totalBounds = totalBounds == null ? b : totalBounds.expandToInclude(b);
      }
      expect(totalBounds, isNotNull);
      expect((totalBounds!.center.dx - target.dx).abs(), lessThan(1.0));
      expect((totalBounds.center.dy - target.dy).abs(), lessThan(1.0));
    });

    test(
      'Select.selectStrokes programmatically selects strokes with tight bounding path',
      () {
        final select = Select.currentSelect;
        select.unselect();
        final stroke = Stroke(
          color: Colors.black,
          pressureEnabled: false,
          options: StrokeOptions(size: 2),
          pageIndex: 0,
          page: const HasSize(Size(500, 500)),
          toolId: ToolId.ballpointPen,
        );
        stroke.addPoint(const Offset(100, 100), 0.5);
        stroke.addPoint(const Offset(200, 200), 0.5);

        expect(select.doneSelecting, isFalse);
        select.selectStrokes([stroke], 0);

        expect(select.doneSelecting, isTrue);
        expect(select.selectResult.strokes, contains(stroke));
        expect(select.selectResult.pageIndex, equals(0));
        expect(select.selectResult.path.getBounds().isEmpty, isFalse);

        final bounds = select.selectResult.path.getBounds();
        expect(bounds.contains(const Offset(150, 150)), isTrue);

        select.unselect();
        expect(select.doneSelecting, isFalse);
        expect(select.selectResult.strokes, isEmpty);
      },
    );
  });
}
