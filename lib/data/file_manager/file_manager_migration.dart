/// 🤖 Generated wholely or partially with Google Antigravity
part of 'file_manager.dart';

Future<void> _fmInit({
  String? documentsDirectory,
  bool shouldWatchRootDirectory = true,
}) async {
  FileManager.documentsDirectory =
      documentsDirectory ?? await _fmGetDocumentsDirectory();

  if (shouldWatchRootDirectory) unawaited(_fmWatchRootDirectory());
}

Future<String> _fmGetDocumentsDirectory() async =>
    stows.customDataDir.value ?? await _fmGetDefaultDocumentsDirectory();

Future<String> _fmGetDefaultDocumentsDirectory() async =>
    '${(await getApplicationDocumentsDirectory()).path}/${FileManager.appRootDirectoryPrefix}';

Future<void> _fmMigrateDataDir() async {
  final oldDir = Directory(FileManager.documentsDirectory);
  final newDir = Directory(await _fmGetDocumentsDirectory());
  if (oldDir.path == newDir.path) return;
  FileManager.log.info('Migrating data directory from $oldDir to $newDir');

  late final oldDirEmpty = oldDir.existsSync()
      ? oldDir.listSync().isEmpty
      : true;
  late final newDirEmpty = newDir.existsSync()
      ? newDir.listSync().isEmpty
      : true;

  if (!oldDirEmpty && !newDirEmpty) {
    FileManager.log.severe(
      'New and old data directory aren\'t empty, can\'t migrate',
    );
    return;
  }

  FileManager.documentsDirectory = newDir.path;
  if (oldDirEmpty) {
    FileManager.log.fine(
      'Old data directory is empty or missing, nothing to migrate',
    );
  } else {
    await _fmMoveDirContents(oldDir: oldDir, newDir: newDir);
    await oldDir.delete(recursive: true);
  }
}

Future<void> _fmMoveDirContents({
  required Directory oldDir,
  required Directory newDir,
}) async {
  await newDir.create(recursive: true);

  await for (final entity in oldDir.list(recursive: true)) {
    final relative = p.relative(entity.path, from: oldDir.path);
    final targetPath = p.join(newDir.path, relative);

    if (entity is Directory) {
      await Directory(targetPath).create(recursive: true);
      continue;
    }

    if (entity is File) {
      await entity.parent.create(recursive: true);

      try {
        await entity.rename(targetPath);
      } on FileSystemException catch (e) {
        const exdev = 18;
        if (e.osError?.errorCode == exdev) {
          await entity.copy(targetPath);
          await entity.delete();
        } else {
          rethrow;
        }
      }
    }
  }
}

Future<void> _fmWatchRootDirectory() async {
  final rootDir = Directory(FileManager.documentsDirectory);
  await rootDir.create(recursive: true);
  if (Platform.isIOS) return;
  rootDir.watch(recursive: true).listen((event) {
    final FileOperationType type = switch (event.type) {
      FileSystemEvent.delete => .delete,
      FileSystemEvent.create => .write,
      FileSystemEvent.modify => .write,
      FileSystemEvent.move => .write,
      _ =>
        kDebugMode
            ? throw UnimplementedError(
                'Unhandled FileSystemEvent type: ${event.type}',
              )
            : .write,
    };
    final String path = event.path
        .replaceAll('\\', '/')
        .replaceFirst(FileManager.documentsDirectory, '');
    _fmBroadcastFileWrite(type, path);
  });
}
