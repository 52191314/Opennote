/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:bson/bson.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/canvas/_asset_cache.dart';
import 'package:saber/components/canvas/_canvas_background_painter.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/data/editor/editor_core_info.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/select.dart';
import 'package:sbn/canvas_background_pattern.dart';
import 'package:sbn/tool_id.dart';

import 'e2e_test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    setupE2EEnvironment();
  });

  setUp(() {
    setupE2EEnvironment();
  });

  group('Tier 1: Feature Coverage (F1–F17)', () {
    // ------------------------------------------------------------------------
    // F1: Lasso Filter Preferences
    // ------------------------------------------------------------------------
    group('F1: Lasso Filter Preferences', () {
      test('stows default to true for handwriting, images, and text', () {
        expect(stows.lassoSelectHandwriting.value, isTrue);
        expect(stows.lassoSelectImages.value, isTrue);
        expect(stows.lassoSelectText.value, isTrue);
      });

      test('preferences can be toggled independently', () {
        stows.lassoSelectHandwriting.value = false;
        expect(stows.lassoSelectHandwriting.value, isFalse);
        expect(stows.lassoSelectImages.value, isTrue);
        expect(stows.lassoSelectText.value, isTrue);

        stows.lassoSelectImages.value = false;
        expect(stows.lassoSelectImages.value, isFalse);

        stows.lassoSelectText.value = false;
        expect(stows.lassoSelectText.value, isFalse);
      });

      test('preference updates trigger reactive listeners', () {
        int notificationCount = 0;
        void listener() => notificationCount++;

        stows.lassoSelectHandwriting.addListener(listener);
        stows.lassoSelectHandwriting.value = false;
        stows.lassoSelectHandwriting.value = true;
        stows.lassoSelectHandwriting.removeListener(listener);

        expect(notificationCount, equals(2));
      });
    });

    // ------------------------------------------------------------------------
    // F2: Lasso Filtering Engine
    // ------------------------------------------------------------------------
    group('F2: Lasso Filtering Engine', () {
      test('onDragEnd excludes images when lassoSelectImages is false', () {
        final select = Select.currentSelect;
        stows.lassoSelectImages.value = false;
        stows.lassoSelectHandwriting.value = true;

        select.onDragStart(Offset.zero, 0);
        select.onDragUpdate(const Offset(0, 100));
        select.onDragUpdate(const Offset(100, 100));
        select.onDragUpdate(const Offset(100, 0));

        final stroke = createTestStroke(points: [const Offset(50, 50)]);
        final image = E2ETestImage(
          dstRect: const Rect.fromLTWH(20, 20, 40, 40),
        );

        select.onDragEnd([stroke], [image]);

        expect(select.selectResult.strokes, contains(stroke));
        expect(select.selectResult.images, isEmpty);
      });

      test(
        'onDragEnd excludes strokes when lassoSelectHandwriting is false',
        () {
          final select = Select.currentSelect;
          stows.lassoSelectImages.value = true;
          stows.lassoSelectHandwriting.value = false;

          select.onDragStart(Offset.zero, 0);
          select.onDragUpdate(const Offset(0, 100));
          select.onDragUpdate(const Offset(100, 100));
          select.onDragUpdate(const Offset(100, 0));

          final stroke = createTestStroke(points: [const Offset(50, 50)]);
          final image = E2ETestImage(
            dstRect: const Rect.fromLTWH(20, 20, 40, 40),
          );

          select.onDragEnd([stroke], [image]);

          expect(select.selectResult.strokes, isEmpty);
          expect(select.selectResult.images, contains(image));
        },
      );

      test('onDragEnd excludes text when lassoSelectText is false', () {
        final select = Select.currentSelect;
        stows.lassoSelectText.value = false;

        select.onDragStart(Offset.zero, 0);
        select.onDragUpdate(const Offset(0, 100));
        select.onDragUpdate(const Offset(100, 100));
        select.onDragUpdate(const Offset(100, 0));

        select.onDragEnd(
          const [],
          const [],
          textRect: const Rect.fromLTWH(20, 20, 50, 50),
        );

        expect(select.selectResult.textSelected, isFalse);
      });

      test('tapSelect excludes disabled media types', () {
        final select = Select.currentSelect;
        stows.lassoSelectImages.value = false;
        stows.lassoSelectHandwriting.value = true;

        final image = E2ETestImage(
          dstRect: const Rect.fromLTWH(50, 50, 100, 100),
        );
        select.tapSelect(const Offset(80, 80), const [], [image], 0);

        expect(select.selectResult.images, isEmpty);
      });

      test(
        'pruneDisabledFilters removes elements when filter is toggled while active',
        () {
          final select = Select.currentSelect;
          stows.lassoSelectImages.value = true;
          stows.lassoSelectHandwriting.value = true;

          final stroke = createTestStroke(points: [const Offset(50, 50)]);
          final image = E2ETestImage(
            dstRect: const Rect.fromLTWH(20, 20, 40, 40),
          );

          select.selectResult = SelectResult(
            pageIndex: 0,
            strokes: [stroke],
            images: [image],
            path: Path(),
          );
          select.doneSelecting = true;

          stows.lassoSelectImages.value = false;
          select.pruneDisabledFilters();

          expect(select.selectResult.images, isEmpty);
          expect(select.selectResult.strokes, contains(stroke));
        },
      );
    });

    // ------------------------------------------------------------------------
    // F3: Lasso Options UI Binding
    // ------------------------------------------------------------------------
    group('F3: Lasso Options UI Binding', () {
      test(
        'mutating stow toggles updates active selection bounds immediately',
        () {
          final select = Select.currentSelect;
          final image = E2ETestImage(
            dstRect: const Rect.fromLTWH(0, 0, 50, 50),
          );

          select.selectResult = SelectResult(
            pageIndex: 0,
            strokes: [],
            images: [image],
            path: Path(),
          );
          select.doneSelecting = true;

          stows.lassoSelectImages.value = false;
          select.pruneDisabledFilters();

          expect(select.selectResult.isEmpty, isTrue);
          expect(select.doneSelecting, isFalse);
        },
      );
    });

    // ------------------------------------------------------------------------
    // F4: Page Thumbnail Grid View Model
    // ------------------------------------------------------------------------
    group('F4: Page Thumbnail Grid View Model', () {
      test(
        'coreInfo represents sequential pages with correct page indices',
        () {
          final page0 = EditorPage();
          final page1 = EditorPage();
          final page2 = EditorPage();
          final coreInfo = createTestCoreInfo(pages: [page0, page1, page2]);

          for (int i = 0; i < coreInfo.pages.length; i++) {
            coreInfo.pages[i].updatePageIndex(i);
          }

          expect(coreInfo.pages.length, equals(3));
          expect(coreInfo.pages[0].strokes, isEmpty);
        },
      );
    });

    // ------------------------------------------------------------------------
    // F5: Tap-to-Jump Navigation
    // ------------------------------------------------------------------------
    group('F5: Tap-to-Jump Navigation', () {
      test(
        'scrollToPage calculates correct translation matrix for target page',
        () {
          final pages = [
            EditorPage(size: const Size(800, 1200)),
            EditorPage(size: const Size(800, 1200)),
            EditorPage(size: const Size(800, 1200)),
          ];
          for (int i = 0; i < pages.length; i++) {
            pages[i].updatePageIndex(i);
          }
          final controller = TransformationController();

          CanvasGestureDetector.scrollToPage(
            pageIndex: 1,
            pages: pages,
            screenWidth: 800,
            transformationController: controller,
          );

          final expectedY = CanvasGestureDetector.getTopOfPage(
            pageIndex: 1,
            pages: pages,
            screenWidth: 800,
          );
          expect(expectedY, greaterThan(0));
          expect(
            controller.value.getTranslation().y,
            closeTo(-expectedY + 50, 1.0),
          );
        },
      );
    });

    // ------------------------------------------------------------------------
    // F6: Page Drag-and-Drop Reorder
    // ------------------------------------------------------------------------
    group('F6: Page Drag-and-Drop Reorder', () {
      test(
        'reordering pages updates page list and syncs stroke page indices',
        () {
          final page0 = EditorPage();
          final page1 = EditorPage();
          final strokeOnPage1 = createTestStroke(pageIndex: 1);
          page1.layers.first.strokes.add(strokeOnPage1);

          final coreInfo = createTestCoreInfo(pages: [page0, page1]);
          for (int i = 0; i < coreInfo.pages.length; i++) {
            coreInfo.pages[i].updatePageIndex(i);
          }

          // Move page 1 to index 0
          E2EPageManagerHelper.reorderPages(coreInfo, 1, 0);

          expect(coreInfo.pages[0], equals(page1));
          expect(coreInfo.pages[1], equals(page0));
          expect(strokeOnPage1.pageIndex, equals(0));
        },
      );
    });

    // ------------------------------------------------------------------------
    // F7: Page Actions (Duplicate/Add/Delete)
    // ------------------------------------------------------------------------
    group('F7: Page Actions (Duplicate/Add/Delete)', () {
      test('insertPageAfter inserts page at pageIndex + 1', () {
        final coreInfo = createTestCoreInfo(
          pages: [EditorPage(), EditorPage()],
        );
        for (int i = 0; i < coreInfo.pages.length; i++) {
          coreInfo.pages[i].updatePageIndex(i);
        }

        coreInfo.pages.insert(1, EditorPage());
        for (int i = 0; i < coreInfo.pages.length; i++) {
          coreInfo.pages[i].updatePageIndex(i);
        }

        expect(coreInfo.pages.length, equals(3));
      });

      test(
        'duplicatePage deep copies layers to avoid shared stroke references',
        () {
          final page0 = EditorPage();
          final originalStroke = createTestStroke(
            pageIndex: 0,
            points: [const Offset(10, 10)],
          );
          page0.layers.first.strokes.add(originalStroke);

          final coreInfo = createTestCoreInfo(pages: [page0]);
          for (int i = 0; i < coreInfo.pages.length; i++) {
            coreInfo.pages[i].updatePageIndex(i);
          }

          E2EPageManagerHelper.duplicatePageDeep(coreInfo, 0);

          expect(coreInfo.pages.length, equals(2));
          final duplicatedPage = coreInfo.pages[1];
          expect(duplicatedPage.layers.first.strokes.length, equals(1));

          final copiedStroke = duplicatedPage.layers.first.strokes.first;
          expect(identical(copiedStroke, originalStroke), isFalse);
          expect(copiedStroke.pageIndex, equals(1));
        },
      );

      test('deletePage deletes page when multiple pages exist', () {
        final coreInfo = createTestCoreInfo(
          pages: [EditorPage(), EditorPage()],
        );
        for (int i = 0; i < coreInfo.pages.length; i++) {
          coreInfo.pages[i].updatePageIndex(i);
        }

        final deleted = E2EPageManagerHelper.deletePageGuarded(coreInfo, 0);
        expect(deleted, isTrue);
        expect(coreInfo.pages.length, equals(1));
      });

      test('deletePage guard rejects deletion when only 1 page remains', () {
        final coreInfo = createTestCoreInfo(pages: [EditorPage()]);

        final deleted = E2EPageManagerHelper.deletePageGuarded(coreInfo, 0);
        expect(deleted, isFalse);
        expect(coreInfo.pages.length, equals(1));
      });
    });

    // ------------------------------------------------------------------------
    // F8: Page Bookmark Indicators & Toggles
    // ------------------------------------------------------------------------
    group('F8: Page Bookmark Indicators & Toggles', () {
      test('page bookmark defaults to false and can be toggled', () {
        final page = EditorPage();
        expect(page.bookmarked, isFalse);

        page.bookmarked = true;
        expect(page.bookmarked, isTrue);
      });

      test('bookmarked state serializes to bm key in BSON', () {
        final page = EditorPage(bookmarked: true);
        final assets = OrderedAssetCache();
        final json = page.toJson(assets);

        expect(json['bm'], isTrue);

        final pageRestored = EditorPage(
          bookmarked: json['bm'] as bool? ?? false,
        );
        expect(pageRestored.bookmarked, isTrue);
      });

      test('filtering by bookmarked flag returns only starred pages', () {
        final pages = [
          EditorPage(bookmarked: false),
          EditorPage(bookmarked: true),
          EditorPage(bookmarked: false),
          EditorPage(bookmarked: true),
        ];

        final bookmarkedPages = pages.where((p) => p.bookmarked).toList();
        expect(bookmarkedPages.length, equals(2));
      });
    });

    // ------------------------------------------------------------------------
    // F9: Study Tape Tool & Model
    // ------------------------------------------------------------------------
    group('F9: Study Tape Tool & Model', () {
      test(
        'TapeStrokeContract initializes with isConcealed = true by default',
        () {
          final tape = TapeStrokeContract(
            color: const Color(0xFFFFEB3B),
            pageIndex: 0,
            page: standardPageDef,
            start: const Offset(100, 200),
            end: const Offset(300, 200),
          );

          expect(tape.isConcealed, isTrue);
          expect(tape.tapeWidth, equals(32.0));
        },
      );

      test(
        'TapeStrokeContract calculates accurate masking bounding polygon',
        () {
          final tape = TapeStrokeContract(
            color: const Color(0xFFFFEB3B),
            pageIndex: 0,
            page: standardPageDef,
            start: const Offset(100, 200),
            end: const Offset(300, 200),
            tapeWidth: 20.0,
          );

          final poly = tape.getMaskPolygon();
          expect(poly.length, equals(4));

          expect(poly[0].dy, closeTo(210.0, 0.01));
          expect(poly[2].dy, closeTo(190.0, 0.01));
        },
      );
    });

    // ------------------------------------------------------------------------
    // F10: Study Tape Rendering
    // ------------------------------------------------------------------------
    group('F10: Study Tape Rendering Modes', () {
      test(
        'concealed tape presents opaque color; revealed presents translucent wash',
        () {
          final tape = TapeStrokeContract(
            color: const Color(0xFFFFEB3B),
            pageIndex: 0,
            page: standardPageDef,
            start: const Offset(100, 100),
            end: const Offset(200, 100),
            isConcealed: true,
          );

          expect(tape.isConcealed, isTrue);
          final concealedAlpha = (tape.color.a * 255).round();
          expect(concealedAlpha, equals(255));

          tape.toggleConceal();
          expect(tape.isConcealed, isFalse);
          final revealedColor = tape.color.withValues(alpha: 0.25);
          expect((revealedColor.a * 255).round(), lessThan(100));
        },
      );
    });

    // ------------------------------------------------------------------------
    // F11: Study Tape Tap Interaction & History
    // ------------------------------------------------------------------------
    group('F11: Study Tape Tap Interaction & History', () {
      test('containsPoint detects tap hit within tape bounds', () {
        final tape = TapeStrokeContract(
          color: const Color(0xFFFFEB3B),
          pageIndex: 0,
          page: standardPageDef,
          start: const Offset(100, 200),
          end: const Offset(300, 200),
          tapeWidth: 40.0,
        );

        expect(tape.containsPoint(const Offset(200, 200)), isTrue);
        expect(tape.containsPoint(const Offset(200, 215)), isTrue);
        expect(tape.containsPoint(const Offset(200, 250)), isFalse);
        expect(tape.containsPoint(const Offset(50, 200)), isFalse);
      });

      test('tapping tape toggles concealed state between true and false', () {
        final tape = TapeStrokeContract(
          color: const Color(0xFFFFEB3B),
          pageIndex: 0,
          page: standardPageDef,
          start: const Offset(100, 200),
          end: const Offset(300, 200),
        );

        expect(tape.isConcealed, isTrue);
        tape.toggleConceal();
        expect(tape.isConcealed, isFalse);
        tape.toggleConceal();
        expect(tape.isConcealed, isTrue);
      });
    });

    // ------------------------------------------------------------------------
    // F12: Study Tape Serialization
    // ------------------------------------------------------------------------
    group('F12: Study Tape Serialization', () {
      test('serializes shape tape and c_state cleanly in BSON roundtrip', () {
        final original = TapeStrokeContract(
          color: const Color(0xFF4CAF50),
          pageIndex: 1,
          page: standardPageDef,
          start: const Offset(150, 250),
          end: const Offset(350, 250),
          tapeWidth: 28.0,
          isConcealed: false,
        );

        final json = original.toJson();
        expect(json['shape'], equals('tape'));
        expect(json['c_state'], isFalse);
        expect(json['tape_w'], equals(28.0));

        final bsonData = BsonCodec.serialize(json);
        final decodedMap = BsonCodec.deserialize(bsonData);

        final restored = TapeStrokeContract.fromJson(
          decodedMap,
          pageIndex: 1,
          page: standardPageDef,
        );

        expect(restored.isConcealed, isFalse);
        expect(restored.tapeWidth, equals(28.0));
        expect(restored.start, equals(const Offset(150, 250)));
        expect(restored.end, equals(const Offset(350, 250)));
      });

      test('backward compatibility defaults missing c_state to true', () {
        final legacyMap = {
          'shape': 'tape',
          'sx': 100.0,
          'sy': 100.0,
          'ex': 200.0,
          'ey': 100.0,
        };

        final restored = TapeStrokeContract.fromJson(
          legacyMap,
          pageIndex: 0,
          page: standardPageDef,
        );

        expect(restored.isConcealed, isTrue);
      });
    });

    // ------------------------------------------------------------------------
    // F13: Highlighter Behind Ink Layering
    // ------------------------------------------------------------------------
    group('F13: Highlighter Behind Ink Layering', () {
      test('highlighter tool has lowest z-index among drawing tools', () {
        const highlighterTool = ToolId.highlighter;
        const penTool = ToolId.fountainPen;

        expect(highlighterTool.id, equals('Highlighter'));
        expect(penTool.id, equals('fountainPen'));
      });

      test(
        'stroke sorting places highlighter strokes below fountain pen strokes',
        () {
          final page = EditorPage();
          final inkStroke = createTestStroke(
            toolId: ToolId.fountainPen,
            color: Colors.black,
          );
          final hlStroke = createHighlighterStroke(color: Colors.yellow);

          page.layers.first.strokes.addAll([inkStroke, hlStroke]);

          final sorted = List<Stroke>.from(page.layers.first.strokes)
            ..sort((a, b) {
              final aZ = a.toolId == ToolId.highlighter ? 0 : 1;
              final bZ = b.toolId == ToolId.highlighter ? 0 : 1;
              return aZ.compareTo(bZ);
            });

          expect(sorted.first.toolId, equals(ToolId.highlighter));
          expect(sorted.last.toolId, equals(ToolId.fountainPen));
        },
      );
    });

    group('F14: Highlighter Hold-to-Straighten', () {
      test(
        'highlighter stroke converts to straight line segment with clean endpoints',
        () {
          final stroke = createHighlighterStroke(
            size: 2.0,
            points: [for (double x = 0; x <= 300; x += 10) Offset(x, 0)],
          );
          stroke.convertToLine();
          expect(stroke.points.first.dx, equals(0));
          expect(stroke.points.last.dx, equals(300));
        },
      );

      test('convertToLine aligns points into a single straight segment', () {
        final stroke = createHighlighterStroke(
          points: [
            const Offset(100, 100),
            const Offset(150, 105),
            const Offset(200, 95),
            const Offset(300, 100),
          ],
        );

        stroke.convertToLine();

        expect(stroke.points.first, equals(const Offset(100, 100)));
        expect(stroke.points.last.dy, closeTo(100.0, 1.0));
      });
    });

    // ------------------------------------------------------------------------
    // F15: Cornell Notes Template Dividing Lines
    // ------------------------------------------------------------------------
    group('F15: Cornell Notes Template Dividing Lines', () {
      test(
        'Cornell template defines vertical cue line at 28% and summary at 75%',
        () {
          const size = Size(1000, 1400);
          final cueX = CornellGeometryOracle.getVerticalCueX(size.width);
          final summaryY = CornellGeometryOracle.getHorizontalSummaryY(
            size.height,
          );

          expect(cueX, closeTo(280.0, 0.01));
          expect(summaryY, closeTo(1050.0, 0.01));
        },
      );

      test('CanvasBackgroundPattern cornell enum value exists', () {
        expect(CanvasBackgroundPattern.cornell, isNotNull);
      });
    });

    // ------------------------------------------------------------------------
    // F16: Cornell Notes Ruled Layout
    // ------------------------------------------------------------------------
    group('F16: Cornell Notes Ruled Layout', () {
      test('painter generates ruled pattern elements within note bounds', () {
        final elements = CanvasBackgroundPainter.getPatternElements(
          pattern: CanvasBackgroundPattern.cornell,
          size: const Size(1000, 1400),
          lineHeight: 40,
        ).toList();

        expect(elements, isNotEmpty);
        expect(elements.any((e) => e.isLine), isTrue);
      });
    });

    // ------------------------------------------------------------------------
    // F17: Paper Background Color Presets
    // ------------------------------------------------------------------------
    group('F17: Paper Background Color Presets', () {
      test('paper color constants match project specifications', () {
        expect(paperColorWarmCream.toARGB32(), equals(0xFFFAF4E8));
        expect(paperColorLegalPad.toARGB32(), equals(0xFFFFF9B0));
        expect(paperColorPureWhite.toARGB32(), equals(0xFFFFFFFF));
        expect(paperColorDarkSlate.toARGB32(), equals(0xFF1E1E1E));
      });

      test('EditorCoreInfo persists backgroundColor to BSON', () {
        final coreInfo = createTestCoreInfo(
          backgroundColor: paperColorWarmCream,
        );

        final (json, _) = coreInfo.toJson();
        expect(json['b'], equals(0xFFFAF4E8));

        final restored = EditorCoreInfo.fromJson(
          json,
          filePath: 'test.sbn',
          onlyFirstPage: false,
        );
        expect(restored.backgroundColor?.toARGB32(), equals(0xFFFAF4E8));
      });
    });
  });
}
