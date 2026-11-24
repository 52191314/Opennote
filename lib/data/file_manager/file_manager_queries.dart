/// 🤖 Generated wholely or partially with Google Antigravity
part of 'file_manager.dart';

Future<DirectoryChildren?> _fmGetChildrenOfDirectory(
  String directory, {
  bool includeExtensions = false,
  bool includeAssets = false,
}) async {
  assert(
    !includeAssets || includeExtensions,
    'includeAssets can\'t be true without includeExtensions',
  );

  directory = _sanitisePath(directory);
  if (!directory.endsWith('/')) directory += '/';

  final List<String> directories = [], files = [];
  final Set<String> seenDirectories = {};

  final dir = Directory(FileManager.documentsDirectory + directory);
  // ignore: avoid_slow_async_io
  if (!await dir.exists()) return null;

  final int directoryPrefixLength = directory.endsWith('/')
      ? directory.length
      : directory.length + 1;

  await for (final entity in dir.list()) {
    final filePath = entity.path.substring(
      FileManager.documentsDirectory.length,
    );

    if (entity is Directory) {
      final childName = filePath.substring(directoryPrefixLength);
      if (seenDirectories.add(childName)) {
        directories.add(childName);
      }
      continue;
    }

    if (NotePaths.isReserved(filePath)) continue;

    final isSbn2 = filePath.endsWith(NotePaths.extension);
    final isSbn1 = filePath.endsWith(NotePaths.extensionOldJson);

    final String resolvedPath;
    if (!includeExtensions) {
      if (isSbn2) {
        resolvedPath = filePath.substring(
          0,
          filePath.length - NotePaths.extension.length,
        );
      } else if (isSbn1) {
        resolvedPath = filePath.substring(
          0,
          filePath.length - NotePaths.extensionOldJson.length,
        );
      } else {
        continue;
      }
    } else {
      if (!includeAssets && !isSbn2 && !isSbn1) continue;
      resolvedPath = filePath;
    }

    final childName = resolvedPath.substring(directoryPrefixLength);
    if (!includeAssets && FileManager.assetFileRegex.hasMatch(childName)) {
      continue;
    }
    files.add(childName);
  }

  return DirectoryChildren(directories, files);
}

Future<List<String>> _fmGetAllFiles({
  bool includeExtensions = false,
  bool includeAssets = false,
}) async {
  final allFiles = <String>[];
  final directories = <String>['/'];

  while (directories.isNotEmpty) {
    final directory = directories.removeLast();
    final children = await _fmGetChildrenOfDirectory(
      directory,
      includeExtensions: includeExtensions,
      includeAssets: includeAssets,
    );
    if (children == null) continue;

    for (final file in children.files) {
      allFiles.add('$directory$file');
    }
    for (final childDirectory in children.directories) {
      directories.add('$directory$childDirectory/');
    }
  }

  return allFiles;
}

Future<List<String>> _fmGetRecentlyAccessed() async {
  if (!stows.recentFiles.loaded) await stows.recentFiles.waitUntilRead();

  final recentFiles = stows.recentFiles.value.toList();
  final existenceResults = await Future.wait(
    recentFiles.map((filePath) async {
      final sanitised = _sanitisePath(filePath);
      // ignore: avoid_slow_async_io
      return await _fmGetFile(sanitised).exists();
    }),
  );
  for (int i = 0; i < recentFiles.length; i++) {
    if (!existenceResults[i]) {
      _removeReferences(recentFiles[i]);
    }
  }

  return stows.recentFiles.value
      .map((String filePath) {
        if (filePath.endsWith(NotePaths.extension)) {
          return filePath.substring(
            0,
            filePath.length - NotePaths.extension.length,
          );
        } else if (filePath.endsWith(NotePaths.extensionOldJson)) {
          return filePath.substring(
            0,
            filePath.length - NotePaths.extensionOldJson.length,
          );
        } else {
          return filePath;
        }
      })
      .where((String file) => !NotePaths.isReserved(file))
      .toList();
}

Future _renameReferences(String fromPath, String toPath) async {
  bool replaced = false;
  for (int i = 0; i < stows.recentFiles.value.length; i++) {
    if (stows.recentFiles.value[i] != fromPath) continue;
    if (!replaced) {
      stows.recentFiles.value[i] = toPath;
      replaced = true;
    } else {
      stows.recentFiles.value.removeAt(i);
    }
  }
  stows.recentFiles.notifyListeners();
}

Future _removeReferences(String filePath) async {
  for (int i = 0; i < stows.recentFiles.value.length; i++) {
    if (stows.recentFiles.value[i] != filePath) continue;
    stows.recentFiles.value.removeAt(i);
  }
  stows.recentFiles.notifyListeners();
}

Future _saveFileAsRecentlyAccessed(String filePath) async {
  if (FileManager.assetFileRegex.hasMatch(filePath)) return;

  stows.recentFiles.value.remove(filePath);
  stows.recentFiles.value.insert(0, filePath);
  if (stows.recentFiles.value.length > FileManager.maxRecentlyAccessedFiles)
    stows.recentFiles.value.removeLast();

  stows.recentFiles.notifyListeners();
}
