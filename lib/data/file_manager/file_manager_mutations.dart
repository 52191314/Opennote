/// 🤖 Generated wholely or partially with Google Antigravity
part of 'file_manager.dart';

Future<String> _fmMoveFile(
  String fromPath,
  String toPath, {
  bool replaceExistingFile = false,
  bool alsoMoveAssets = true,
}) async {
  fromPath = _sanitisePath(fromPath);
  toPath = _sanitisePath(toPath);

  if (!_fmGetFile(fromPath).existsSync()) {
    if (_fmGetFile('$fromPath${NotePaths.extension}').existsSync()) {
      fromPath = '$fromPath${NotePaths.extension}';
      if (!toPath.endsWith(NotePaths.extension)) {
        toPath = '$toPath${NotePaths.extension}';
      }
    } else if (_fmGetFile(
      '$fromPath${NotePaths.extensionOldJson}',
    ).existsSync()) {
      fromPath = '$fromPath${NotePaths.extensionOldJson}';
      if (!toPath.endsWith(NotePaths.extensionOldJson)) {
        toPath = '$toPath${NotePaths.extensionOldJson}';
      }
    }
  }

  if (!toPath.contains('/')) {
    toPath = fromPath.substring(0, fromPath.lastIndexOf('/') + 1) + toPath;
  }

  if (!replaceExistingFile || NotePaths.isReserved(toPath)) {
    toPath = await _fmSuffixFilePathToMakeItUnique(
      toPath,
      currentPath: fromPath,
    );
  }

  if (fromPath == toPath) return toPath;

  final fromFile = _fmGetFile(fromPath);
  final toFile = _fmGetFile(toPath);
  await _createFileDirectory(toPath);
  if (fromFile.existsSync()) {
    await fromFile.rename(toFile.path);
  } else {
    FileManager.log.warning(
      'Tried to move non-existent file from $fromPath to $toPath',
    );
  }

  syncer.uploader.enqueueRel(fromPath);
  syncer.uploader.enqueueRel(toPath);

  _renameReferences(fromPath, toPath);
  _fmBroadcastFileWrite(FileOperationType.delete, fromPath);
  _fmBroadcastFileWrite(FileOperationType.write, toPath);

  if (alsoMoveAssets && !FileManager.assetFileRegex.hasMatch(fromPath)) {
    final assets = <String>[];
    for (int assetNumber = 0; true; assetNumber++) {
      final assetFile = _fmGetFile('$fromPath.$assetNumber');
      if (assetFile.existsSync()) {
        assets.add('$assetNumber');
      } else {
        break;
      }
    }
    {
      const assetNumber = 'p';
      final assetFile = _fmGetFile('$fromPath.$assetNumber');
      if (assetFile.existsSync()) {
        assets.add(assetNumber);
      }
    }

    await Future.wait([
      for (final assetNumber in assets)
        _fmMoveFile(
          '$fromPath.$assetNumber',
          '$toPath.$assetNumber',
          replaceExistingFile: replaceExistingFile,
        ),
    ]);
  }

  return toPath;
}

Future _fmDeleteFile(
  String filePath, {
  bool alsoUpload = true,
  bool alsoDeleteAssets = true,
}) async {
  filePath = _sanitisePath(filePath);

  final file = _fmGetFile(filePath);
  if (!file.existsSync()) return;
  await file.delete();

  if (alsoUpload) syncer.uploader.enqueueRel(filePath);

  _removeReferences(filePath);
  _fmBroadcastFileWrite(FileOperationType.delete, filePath);

  if (alsoDeleteAssets && !FileManager.assetFileRegex.hasMatch(filePath)) {
    final assets = <int>[];
    for (int assetNumber = 0; true; assetNumber++) {
      final assetFile = _fmGetFile('$filePath.$assetNumber');
      if (assetFile.existsSync()) {
        assets.add(assetNumber);
      } else {
        break;
      }
    }

    final previewFile = _fmGetFile('$filePath.p');
    await Future.wait([
      for (final assetNumber in assets)
        _fmDeleteFile('$filePath.$assetNumber', alsoDeleteAssets: false),
      if (previewFile.existsSync())
        _fmDeleteFile('$filePath.p', alsoDeleteAssets: false),
    ]);
  }
}

Future _fmRemoveUnusedAssets(String filePath, {required int numAssets}) async {
  final futures = <Future>[];

  for (int assetNumber = numAssets; true; assetNumber++) {
    final assetPath = '$filePath.$assetNumber';
    if (_fmGetFile(assetPath).existsSync()) {
      futures.add(_fmDeleteFile(assetPath));
    } else {
      break;
    }
  }

  await Future.wait(futures);
}

Future _fmRenameDirectory(String directoryPath, String newName) async {
  directoryPath = _sanitisePath(directoryPath);

  final directory = Directory(FileManager.documentsDirectory + directoryPath);
  if (!directory.existsSync()) return;

  final List<String> children = [];
  await for (final entity in directory.list(recursive: true)) {
    if (entity is File) {
      children.add(entity.path.substring(directory.path.length));
    }
  }

  final String newPath =
      directoryPath.substring(0, directoryPath.lastIndexOf('/') + 1) + newName;
  await directory.rename(FileManager.documentsDirectory + newPath);

  for (final child in children) {
    _renameReferences(directoryPath + child, newPath + child);
    _fmBroadcastFileWrite(FileOperationType.delete, directoryPath + child);
    _fmBroadcastFileWrite(FileOperationType.write, newPath + child);
  }
}

Future<String?> _fmMoveDirectory(String fromPath, String toParentPath) async {
  fromPath = _sanitisePath(fromPath);
  if (!fromPath.startsWith('/')) fromPath = '/$fromPath';
  if (fromPath.length > 1 && fromPath.endsWith('/')) {
    fromPath = fromPath.substring(0, fromPath.length - 1);
  }

  final folderName = fromPath.substring(fromPath.lastIndexOf('/') + 1);
  if (folderName.isEmpty) return null;

  toParentPath = _sanitisePath(toParentPath);
  if (!toParentPath.startsWith('/')) toParentPath = '/$toParentPath';
  if (toParentPath.length > 1 && toParentPath.endsWith('/')) {
    toParentPath = toParentPath.substring(0, toParentPath.length - 1);
  }

  if (toParentPath == fromPath || toParentPath.startsWith('$fromPath/')) {
    FileManager.log.warning(
      'Cannot move directory $fromPath into itself or descendant $toParentPath',
    );
    return null;
  }

  final currentParent = fromPath.substring(0, fromPath.lastIndexOf('/'));
  final normalizedParent = currentParent.isEmpty ? '/' : currentParent;
  if (toParentPath == normalizedParent) {
    return fromPath;
  }

  final directory = Directory(FileManager.documentsDirectory + fromPath);
  if (!directory.existsSync()) {
    FileManager.log.warning('Source directory $fromPath does not exist');
    return null;
  }

  final targetPath = toParentPath == '/'
      ? '/$folderName'
      : '$toParentPath/$folderName';

  var uniqueTargetPath = targetPath;
  int counter = 1;
  while (Directory(
    FileManager.documentsDirectory + uniqueTargetPath,
  ).existsSync()) {
    counter++;
    uniqueTargetPath = toParentPath == '/'
        ? '/$folderName ($counter)'
        : '$toParentPath/$folderName ($counter)';
  }

  final parentDir = Directory(FileManager.documentsDirectory + toParentPath);
  if (!parentDir.existsSync()) {
    await parentDir.create(recursive: true);
  }

  final List<String> children = [];
  await for (final entity in directory.list(recursive: true)) {
    if (entity is File) {
      children.add(entity.path.substring(directory.path.length));
    }
  }

  await directory.rename(FileManager.documentsDirectory + uniqueTargetPath);

  for (final child in children) {
    syncer.uploader.enqueueRel(fromPath + child);
    syncer.uploader.enqueueRel(uniqueTargetPath + child);
    _renameReferences(fromPath + child, uniqueTargetPath + child);
    _fmBroadcastFileWrite(FileOperationType.delete, fromPath + child);
    _fmBroadcastFileWrite(FileOperationType.write, uniqueTargetPath + child);
  }

  return uniqueTargetPath;
}

Future<String?> _fmMoveItem(String itemPath, String targetParentFolder) async {
  if (_fmIsDirectory(itemPath)) {
    return await _fmMoveDirectory(itemPath, targetParentFolder);
  } else {
    itemPath = _sanitisePath(itemPath);
    final fileName = itemPath.substring(itemPath.lastIndexOf('/') + 1);
    if (targetParentFolder.length > 1 && targetParentFolder.endsWith('/')) {
      targetParentFolder = targetParentFolder.substring(
        0,
        targetParentFolder.length - 1,
      );
    }
    final toPath = targetParentFolder == '/'
        ? '/$fileName'
        : '$targetParentFolder/$fileName';
    return await _fmMoveFile(itemPath, toPath);
  }
}

Future _fmDeleteDirectory(String directoryPath, [bool recursive = true]) async {
  directoryPath = _sanitisePath(directoryPath);

  final directory = Directory(FileManager.documentsDirectory + directoryPath);
  if (!directory.existsSync()) return;

  if (recursive) {
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        await _fmDeleteFile(
          entity.path.substring(FileManager.documentsDirectory.length),
        );
      }
    }
  }

  await directory.delete(recursive: recursive);
}
