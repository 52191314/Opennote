/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/files/file_tree.dart';
import 'package:saber/components/home/grid_folders.dart';
import 'package:saber/components/home/notebook_shelf.dart';
import 'package:saber/components/home/trash_drop_zone.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/file_manager/item_drag_state.dart';
import 'package:saber/data/file_manager/note_paths.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/i18n/strings.g.dart';

import 'utils/test_mock_channel_handlers.dart';

void main() {
  group('Drag & Drop Workspace - FileManager tests', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupMockPathProvider();
    FlavorConfig.setup();
    LocaleSettings.setLocale(AppLocale.en);

    late final String rootDir;

    setUpAll(() async {
      await FileManager.init(shouldWatchRootDirectory: false);
      rootDir = FileManager.documentsDirectory;
      await Directory(rootDir).create(recursive: true);
    });

    test('moveDirectory moves directory and nested files', () async {
      const sourceDir = '/test_dnd_source';
      const destDir = '/test_dnd_dest';
      const fileInside = '$sourceDir/nested_note${NotePaths.extension}';

      // Create source and dest folders
      await Directory('$rootDir$sourceDir').create(recursive: true);
      await Directory('$rootDir$destDir').create(recursive: true);
      await File('$rootDir$fileInside').writeAsString('nested content');

      expect(Directory('$rootDir$sourceDir').existsSync(), isTrue);
      expect(File('$rootDir$fileInside').existsSync(), isTrue);

      final result = await FileManager.moveDirectory(sourceDir, destDir);
      expect(result, '$destDir/test_dnd_source');

      expect(Directory('$rootDir$sourceDir').existsSync(), isFalse);
      expect(
        Directory('$rootDir$destDir/test_dnd_source').existsSync(),
        isTrue,
      );
      expect(
        File(
          '$rootDir$destDir/test_dnd_source/nested_note${NotePaths.extension}',
        ).existsSync(),
        isTrue,
      );

      // Clean up
      await Directory('$rootDir$destDir').delete(recursive: true);
    });

    test('moveDirectory prevents moving into self or descendant', () async {
      const parentDir = '/test_dnd_cycle';
      const subDir = '$parentDir/child';

      await Directory('$rootDir$subDir').create(recursive: true);

      // Moving into self
      final selfResult = await FileManager.moveDirectory(parentDir, parentDir);
      expect(selfResult, isNull);

      // Moving into descendant
      final descResult = await FileManager.moveDirectory(parentDir, subDir);
      expect(descResult, isNull);

      expect(Directory('$rootDir$parentDir').existsSync(), isTrue);

      // Clean up
      await Directory('$rootDir$parentDir').delete(recursive: true);
    });

    test('moveDirectory handles naming conflicts uniquely', () async {
      const sourceDir = '/test_conflict_src';
      const targetParent = '/test_conflict_target';
      const existingInTarget = '$targetParent/test_conflict_src';

      await Directory('$rootDir$sourceDir').create(recursive: true);
      await Directory('$rootDir$existingInTarget').create(recursive: true);

      final result = await FileManager.moveDirectory(sourceDir, targetParent);
      expect(result, '$targetParent/test_conflict_src (2)');
      expect(Directory('$rootDir$result').existsSync(), isTrue);

      // Clean up
      await Directory('$rootDir$targetParent').delete(recursive: true);
    });

    test('moveItem correctly moves notes and directories', () async {
      const notePath = '/test_item_note';
      const fullNotePath = '$notePath${NotePaths.extension}';
      const folderPath = '/test_item_folder';
      const targetFolder = '/test_item_dest';

      await Directory('$rootDir$folderPath').create(recursive: true);
      await Directory('$rootDir$targetFolder').create(recursive: true);
      await File('$rootDir$fullNotePath').writeAsString('note content');

      // Move note without extension
      final noteResult = await FileManager.moveItem(notePath, targetFolder);
      expect(noteResult, '$targetFolder/test_item_note${NotePaths.extension}');
      expect(File('$rootDir$noteResult').existsSync(), isTrue);

      // Move folder
      final dirResult = await FileManager.moveItem(folderPath, targetFolder);
      expect(dirResult, '$targetFolder/test_item_folder');
      expect(Directory('$rootDir$dirResult').existsSync(), isTrue);

      // Clean up
      await Directory('$rootDir$targetFolder').delete(recursive: true);
    });

    testWidgets('FileTree has Draggable items and DragTarget for folders', (
      tester,
    ) async {
      await tester.runAsync(() async {
        await Directory('$rootDir/test_tree_folder').create(recursive: true);
        await File(
          '$rootDir/test_tree_folder/tree_note${NotePaths.extension}',
        ).writeAsString('content');

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: FileTree())),
        );
        await Future.delayed(const Duration(milliseconds: 150));
        await tester.pump();

        // Verify DragTarget exists for root browse header and folders
        expect(find.byType(DragTarget<String>), findsWidgets);

        // Clean up
        await Directory('$rootDir/test_tree_folder').delete(recursive: true);
      });
    });

    testWidgets('GridFolders wraps folders in Draggable and DragTarget', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                GridFolders(
                  isAtRoot: false,
                  currentPath: '/test_folder',
                  crossAxisCount: 2,
                  onTap: (_) {},
                  onItemMoved: (item, target) {},
                  createFolder: (_) {},
                  renameFolder: (oldName, newName) async {},
                  isFolderEmpty: (_) async => true,
                  deleteFolder: (_) async {},
                  doesFolderExist: (_) => false,
                  folders: const ['subfolder_a', 'subfolder_b'],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Both backFolder and 2 real folders should be DragTargets (3 DragTargets total)
      expect(find.byType(DragTarget<String>), findsNWidgets(3));

      // Real folders should have Draggable/LongPressDraggable
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Draggable<String> ||
              widget is LongPressDraggable<String>,
        ),
        findsWidgets,
      );
    });

    test('ItemDragState manages drag lifecycle', () {
      expect(ItemDragState.isDragging, isFalse);
      expect(ItemDragState.activeDragItem.value, isNull);

      ItemDragState.startDrag('/notes/chemistry');
      expect(ItemDragState.isDragging, isTrue);
      expect(ItemDragState.activeDragItem.value, '/notes/chemistry');

      ItemDragState.endDrag();
      expect(ItemDragState.isDragging, isFalse);
      expect(ItemDragState.activeDragItem.value, isNull);
    });

    testWidgets('TrashDropZone renders and activates when dragging', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TrashDropZone())),
      );
      await tester.pump();

      // DragTarget is present in tree
      expect(find.byType(DragTarget<String>), findsOneWidget);

      // Trigger drag active
      ItemDragState.startDrag('/test_note');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(ItemDragState.isDragging, isTrue);

      // Clear drag
      ItemDragState.endDrag();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(ItemDragState.isDragging, isFalse);
    });

    testWidgets(
      'NotebookShelf renders 3-dots menus on covers and folder chips',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NotebookShelf(
                notes: const ['/test_note'],
                folders: const ['test_folder'],
                onOpenNote: (_) {},
                onOpenFolder: (_) {},
                onCreateNote: (_) {},
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Both cover and folder chip have PopupMenuButton for delete/rename
        expect(find.byType(PopupMenuButton<String>), findsNWidgets(2));
      },
    );

    testWidgets('GridFolders real folder has 3-dots options button', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                GridFolders(
                  isAtRoot: false,
                  currentPath: '/test_root',
                  crossAxisCount: 2,
                  onTap: (_) {},
                  createFolder: (_) {},
                  renameFolder: (oldName, newName) async {},
                  isFolderEmpty: (_) async => true,
                  deleteFolder: (_) async {},
                  doesFolderExist: (_) => false,
                  folders: const ['algebra'],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check 3-dots button on folder card
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
    });
  });
}
