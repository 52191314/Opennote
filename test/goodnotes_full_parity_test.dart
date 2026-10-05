/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/components/canvas/hud/floating_layers_overlay.dart';
import 'package:saber/components/toolbar/elements_sheet.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/elements.dart';
import 'package:saber/data/tools/laser_pointer.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

void main() {
  setUpAll(() {
    FlavorConfig.setup();
  });

  const testPageSize = HasSize(Size(800, 1000));

  Stroke createDummyStroke({
    Offset start = const Offset(50, 50),
    Offset end = const Offset(150, 150),
    LineStyle lineStyle = LineStyle.solid,
  }) {
    final stroke = Stroke(
      color: Colors.blue,
      pressureEnabled: false,
      options: StrokeOptions(size: 4),
      pageIndex: 0,
      page: testPageSize,
      toolId: ToolId.ballpointPen,
      lineStyle: lineStyle,
    );
    stroke.addPoint(start, 0.5);
    stroke.addPoint(end, 0.5);
    return stroke;
  }

  group('Feature A: Layer Locking & Page Stroke Mutation Guards', () {
    test('Layer default state has locked=false and visible=true', () {
      final layer = Layer(name: 'Background');
      expect(layer.locked, isFalse);
      expect(layer.visible, isTrue);
      expect(layer.strokes, isEmpty);
    });

    test('Layer toJson serializes locked state and fromJson restores it', () {
      final unlockedLayer = Layer(name: 'Notes', locked: false, visible: true);
      final lockedLayer = Layer(name: 'Template', locked: true, visible: true);

      final jsonUnlocked = unlockedLayer.toJson();
      final jsonLocked = lockedLayer.toJson();

      expect(jsonUnlocked['l'], isFalse);
      expect(jsonLocked['l'], isTrue);

      final restoredUnlocked = Layer.fromJson(
        jsonUnlocked,
        fileVersion: 2,
        pageIndex: 0,
        page: testPageSize,
      );
      final restoredLocked = Layer.fromJson(
        jsonLocked,
        fileVersion: 2,
        pageIndex: 0,
        page: testPageSize,
      );

      expect(restoredUnlocked.locked, isFalse);
      expect(restoredLocked.locked, isTrue);
      expect(restoredLocked.name, equals('Template'));
    });

    test('EditorPage insertStroke rejects strokes when active layer is locked', () {
      final page = EditorPage(size: const Size(800, 1000));
      expect(page.layers.length, equals(1));
      expect(page.activeLayer.locked, isFalse);

      final stroke1 = createDummyStroke(start: const Offset(10, 10), end: const Offset(20, 20));
      page.insertStroke(stroke1);
      expect(page.activeLayer.strokes.length, equals(1));

      // Lock active layer
      page.activeLayer.locked = true;

      // Attempt inserting stroke into locked layer
      final stroke2 = createDummyStroke(start: const Offset(30, 30), end: const Offset(40, 40));
      page.insertStroke(stroke2);

      // Stroke count must remain 1
      expect(page.activeLayer.strokes.length, equals(1));
      expect(page.activeLayer.strokes.first, equals(stroke1));
    });

    test('EditorPage removeStroke skips locked layers and preserves their strokes', () {
      final page = EditorPage(size: const Size(800, 1000));
      final stroke1 = createDummyStroke(start: const Offset(10, 10), end: const Offset(20, 20));
      page.insertStroke(stroke1);
      expect(page.activeLayer.strokes.length, equals(1));

      // Add second unlocked layer with stroke2
      page.layers.add(Layer(name: 'Layer 2'));
      page.activeLayerIndex = 1;
      final stroke2 = createDummyStroke(start: const Offset(50, 50), end: const Offset(60, 60));
      page.insertStroke(stroke2);

      // Lock layer 0 containing stroke1
      page.layers[0].locked = true;

      // Attempting to remove stroke1 must fail because Layer 0 is locked
      final removedStroke1 = page.removeStroke(stroke1);
      expect(removedStroke1, isFalse);
      expect(page.layers[0].strokes.contains(stroke1), isTrue);

      // Removing stroke2 from unlocked Layer 1 must succeed
      final removedStroke2 = page.removeStroke(stroke2);
      expect(removedStroke2, isTrue);
      expect(page.layers[1].strokes.contains(stroke2), isFalse);
    });
  });

  group('Feature B: FloatingLayersOverlay Widget Interactions', () {
    testWidgets('Renders collapsed badge with active layer name and lock indicator', (tester) async {
      final page = EditorPage(size: const Size(800, 1000));
      page.layers[0].name = 'Sketch';
      page.layers[0].locked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FloatingLayersOverlay(
                  page: page,
                  onChanged: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Sketch'), findsOneWidget);
      expect(find.byIcon(Icons.layers_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);

      // Lock the layer and pump
      page.layers[0].locked = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FloatingLayersOverlay(
                  page: page,
                  onChanged: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('Tapping collapsed badge expands HUD; Add Layer creates and selects Layer 2', (tester) async {
      final page = EditorPage(size: const Size(800, 1000));
      page.layers[0].name = 'Layer 1';
      var changedCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FloatingLayersOverlay(
                  page: page,
                  onChanged: () => changedCount++,
                ),
              ],
            ),
          ),
        ),
      );

      // Tap collapsed badge to expand
      await tester.tap(find.text('Layer 1'));
      await tester.pumpAndSettle();

      expect(find.text('Layers (1)'), findsOneWidget);
      expect(find.byTooltip('Add Layer'), findsOneWidget);

      // Tap Add Layer
      await tester.tap(find.byTooltip('Add Layer'));
      await tester.pumpAndSettle();

      expect(changedCount, equals(1));
      expect(page.layers.length, equals(2));
      expect(page.activeLayerIndex, equals(1));
      expect(find.text('Layers (2)'), findsOneWidget);

      // Lock Layer 2 (active layer)
      final lockButtons = find.byTooltip('Lock Layer');
      expect(lockButtons, findsWidgets);
      await tester.tap(lockButtons.last);
      await tester.pumpAndSettle();

      expect(changedCount, equals(2));
      expect(page.activeLayer.locked, isTrue);

      // Close the HUD
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      // Should be back to collapsed badge
      expect(find.text('Layers (2)'), findsNothing);
    });
  });

  group('Feature C: Elements / Reusable Stickers Tray', () {
    setUp(() {
      stows.elementsJson.value = '';
      ElementsManager.instance.reload();
    });

    test('ElementsManager loads starter defaults when storage is empty', () {
      final manager = ElementsManager.instance;
      expect(manager.items, isNotEmpty);
      expect(manager.categories, contains('Stickers'));
      expect(manager.categories, contains('General'));

      final names = manager.items.map((e) => e.name).toList();
      expect(names, contains('Star'));
      expect(names, contains('Heart'));
      expect(names, contains('Checkmark'));
      expect(names, contains('Sticky Note'));
    });

    test('ElementsManager addElement saves normalized strokes and can be removed', () {
      final manager = ElementsManager.instance;
      final initialCount = manager.items.length;

      final stroke = createDummyStroke(start: const Offset(100, 200), end: const Offset(150, 250));
      manager.addElement(
        name: 'Custom Arrow',
        category: 'Diagrams',
        strokes: [stroke],
      );

      expect(manager.items.length, equals(initialCount + 1));
      final added = manager.items.firstWhere((e) => e.name == 'Custom Arrow');
      expect(added.category, equals('Diagrams'));

      // Test instantiation centered at target
      final instantiated = added.instantiateStrokes(
        page: testPageSize,
        targetCenter: const Offset(300, 300),
      );
      expect(instantiated.length, equals(1));
      final center = instantiated.first.highQualityPath.getBounds().center;
      expect(center.dx, closeTo(300, 2.0));
      expect(center.dy, closeTo(300, 2.0));

      // Remove element
      manager.removeElement(added.id);
      expect(manager.items.length, equals(initialCount));
    });

    testWidgets('ElementsSheet renders categories and selecting item triggers callback', (tester) async {
      ElementItem? selectedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElementsSheet(
              onSelectElement: (item) => selectedItem = item,
            ),
          ),
        ),
      );

      expect(find.text('Elements'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Stickers'), findsOneWidget);

      // Tap on Stickers chip
      await tester.tap(find.text('Stickers'));
      await tester.pumpAndSettle();

      // Find Star sticker element and tap it
      expect(find.text('Star'), findsOneWidget);
      await tester.tap(find.text('Star'));
      await tester.pumpAndSettle();

      expect(selectedItem, isNotNull);
      expect(selectedItem!.name, equals('Star'));
    });
  });

  group('Feature D: Laser Pointer Spotlight Mode', () {
    setUp(() {
      stows.laserPointerMode.value = 'trail';
      Pen.currentStroke = null;
    });

    tearDown(() {
      stows.laserPointerMode.value = 'trail';
      Pen.currentStroke = null;
    });

    test('LaserPointer in spotlight mode updates laserSpotlightPosition without trail strokes', () {
      final laser = LaserPointer.currentLaserPointer;
      final page = EditorPage(size: const Size(800, 1000));
      stows.laserPointerMode.value = 'spotlight';

      // Drag start
      laser.onDragStart(const Offset(100, 150), page, 0);
      expect(page.laserSpotlightPosition, equals(const Offset(100, 150)));
      expect(Pen.currentStroke, isNull);

      // Drag update
      laser.onDragUpdate(const Offset(220, 280));
      expect(page.laserSpotlightPosition, equals(const Offset(220, 280)));
      expect(Pen.currentStroke, isNull);

      // Drag end clears spotlight
      var redrawn = false;
      final finished = laser.onDragEnd(
        () => redrawn = true,
        (s) {},
      );

      expect(finished, isNull);
      expect(page.laserSpotlightPosition, isNull);
      expect(redrawn, isTrue);
    });

    test('LaserPointer in trail mode creates LaserStroke and records point delays', () {
      final laser = LaserPointer.currentLaserPointer;
      final page = EditorPage(size: const Size(800, 1000));
      stows.laserPointerMode.value = 'trail';

      laser.onDragStart(const Offset(50, 50), page, 0);
      expect(Pen.currentStroke, isNotNull);
      expect(page.laserSpotlightPosition, isNull);

      laser.onDragUpdate(const Offset(80, 80), elapsed: const Duration(milliseconds: 16));
      expect(Pen.currentStroke?.length, greaterThanOrEqualTo(1));

      laser.onDragEnd(() {}, (s) {});
      expect(Pen.currentStroke, isNull);
    });
  });

  group('Feature E: Dashed & Dotted Pen Stroke Styles', () {
    setUp(() {
      stows.penLineStyle.value = 'solid';
      Pen.currentStroke = null;
    });

    tearDown(() {
      stows.penLineStyle.value = 'solid';
      Pen.currentStroke = null;
    });

    test('Stroke centerlinePath constructs path through stroke points', () {
      final stroke = createDummyStroke(start: const Offset(10, 20), end: const Offset(100, 200));
      final path = stroke.centerlinePath;
      final bounds = path.getBounds();

      expect(bounds.left, equals(10.0));
      expect(bounds.top, equals(20.0));
      expect(bounds.right, equals(100.0));
      expect(bounds.bottom, equals(200.0));
    });

    test('Pen creates dashed or dotted strokes based on penLineStyle stow', () {
      final pen = Pen.ballpointPen();
      final page = EditorPage(size: const Size(800, 1000));

      // Solid
      stows.penLineStyle.value = 'solid';
      pen.onDragStart(Offset.zero, page, 0, 0.5);
      expect(Pen.currentStroke?.lineStyle, equals(LineStyle.solid));

      // Dashed
      stows.penLineStyle.value = 'dashed';
      pen.onDragStart(Offset.zero, page, 0, 0.5);
      expect(Pen.currentStroke?.lineStyle, equals(LineStyle.dashed));

      // Dotted
      stows.penLineStyle.value = 'dotted';
      pen.onDragStart(Offset.zero, page, 0, 0.5);
      expect(Pen.currentStroke?.lineStyle, equals(LineStyle.dotted));
    });

    test('Stroke serializes and deserializes LineStyle correctly', () {
      final dashedStroke = createDummyStroke(lineStyle: LineStyle.dashed);
      final dottedStroke = createDummyStroke(lineStyle: LineStyle.dotted);
      final solidStroke = createDummyStroke(lineStyle: LineStyle.solid);

      final dashedJson = dashedStroke.toJson();
      final dottedJson = dottedStroke.toJson();
      final solidJson = solidStroke.toJson();

      expect(dashedJson['ls'], equals('dashed'));
      expect(dottedJson['ls'], equals('dotted'));
      expect(solidJson.containsKey('ls'), isFalse); // Omitted for compact storage

      final restoredDashed = Stroke.fromJson(
        dashedJson,
        fileVersion: 19,
        pageIndex: 0,
        page: testPageSize,
      );
      final restoredDotted = Stroke.fromJson(
        dottedJson,
        fileVersion: 19,
        pageIndex: 0,
        page: testPageSize,
      );
      final restoredSolid = Stroke.fromJson(
        solidJson,
        fileVersion: 19,
        pageIndex: 0,
        page: testPageSize,
      );

      expect(restoredDashed.lineStyle, equals(LineStyle.dashed));
      expect(restoredDotted.lineStyle, equals(LineStyle.dotted));
      expect(restoredSolid.lineStyle, equals(LineStyle.solid));
    });
  });
}
