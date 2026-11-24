/// 🤖 Generated wholely or partially with Google Antigravity
part of 'file_manager.dart';

// TODO(adil192): Implement or remove this
String _sanitisePath(String path) => File(path).path;

/// Forbidden names for files and directories (on any/all platforms).
/// These patterns match the base name only (not the full path).
/// Source: https://stackoverflow.com/a/31976060/
List<(String, RegExp)> _getForbiddenFilenamePatterns() => [
  (
    t.home.renameNote.noteNameForbiddenCharacters,
    RegExp(r'[<>:"/\\|?*\x00-\x1F]'),
  ),
  (
    t.home.renameNote.noteNameReserved,
    RegExp(
      r'^((con|prn|aux|nul|com[1-9]|lpt[1-9])(\..*)?)|\.+$',
      caseSensitive: false,
    ),
  ),
];

String? _fmValidateFilename(String filename) {
  if (filename.isEmpty) return t.home.renameNote.noteNameEmpty;
  for (final (error, regexp) in _getForbiddenFilenamePatterns()) {
    if (regexp.hasMatch(filename)) return error;
  }
  return null;
}

void _fmBroadcastFileWrite(FileOperationType type, String path) async {
  if (!FileManager.fileWriteStream.hasListener) return;

  if (path.endsWith(NotePaths.extension)) {
    path = path.substring(0, path.length - NotePaths.extension.length);
  } else if (path.endsWith(NotePaths.extensionOldJson)) {
    path = path.substring(0, path.length - NotePaths.extensionOldJson.length);
  }

  FileManager.fileWriteStream.add(FileOperation(type, path));
}

Future<Uint8List?> _fmReadFile(String filePath, {int retries = 3}) async {
  filePath = _sanitisePath(filePath);

  Uint8List? result;
  final file = _fmGetFile(filePath);
  if (file.existsSync()) {
    result = await file.readAsBytes();
    if (result.isEmpty) result = null;
  } else {
    retries = 0;
  }

  if (result == null && retries > 0) {
    await Future.delayed(const Duration(milliseconds: 100));
    return _fmReadFile(filePath, retries: retries - 1);
  }
  return result;
}

File _fmGetFile(String filePath) {
  if (FileManager.shouldUseRawFilePath) {
    return File(filePath);
  } else {
    assert(
      filePath.startsWith('/'),
      'Expected filePath to start with a slash, got $filePath',
    );
    return File(FileManager.documentsDirectory + filePath);
  }
}

Directory _fmGetRootDirectory() => Directory(FileManager.documentsDirectory);

Future<void> _fmWriteFile(
  String filePath,
  List<int> toWrite, {
  bool awaitWrite = false,
  bool alsoUpload = true,
  DateTime? lastModified,
}) async {
  filePath = _sanitisePath(filePath);
  FileManager.log.fine('Writing to $filePath');

  await _saveFileAsRecentlyAccessed(filePath);

  final file = _fmGetFile(filePath);
  await _createFileDirectory(filePath);
  Future writeFuture = Future.wait([
    file.writeAsBytes(toWrite).then((file) async {
      if (lastModified != null) await file.setLastModified(lastModified);
    }),
    if (filePath.endsWith(NotePaths.extension))
      _fmGetFile(
        '${filePath.substring(0, filePath.length - NotePaths.extension.length)}'
        '${NotePaths.extensionOldJson}',
      ).delete().catchError(
        (_) => File(''),
        test: (e) => e is PathNotFoundException,
      ),
  ]);

  void afterWrite() {
    _fmBroadcastFileWrite(FileOperationType.write, filePath);
    if (alsoUpload) syncer.uploader.enqueueRel(filePath);
    if (filePath.endsWith(NotePaths.extension)) {
      _removeReferences(
        '${filePath.substring(0, filePath.length - NotePaths.extension.length)}'
        '${NotePaths.extensionOldJson}',
      );
    }
  }

  writeFuture = writeFuture.then((_) => afterWrite());
  if (awaitWrite) await writeFuture;
}

Future<void> _fmCreateFolder(String folderPath) async {
  folderPath = _sanitisePath(folderPath);

  final dir = Directory(FileManager.documentsDirectory + folderPath);
  await dir.create(recursive: true);
}

bool _fmIsDirectory(String filePath) {
  filePath = _sanitisePath(filePath);
  final directory = Directory(FileManager.documentsDirectory + filePath);
  return directory.existsSync();
}

bool _fmDoesFileExist(String filePath) {
  filePath = _sanitisePath(filePath);
  final file = _fmGetFile(filePath);
  return file.existsSync();
}

DateTime _fmLastModified(String filePath) {
  filePath = _sanitisePath(filePath);
  final file = _fmGetFile(filePath);
  return file.lastModifiedSync();
}

Future<String> _fmNewFilePath([String parentPath = '/']) async {
  assert(parentPath.endsWith('/'));

  final DateTime now = DateTime.now();
  final String filePath =
      '$parentPath${DateFormat("yy-MM-dd").format(now)} '
      '${t.editor.untitled}';

  return await _fmSuffixFilePathToMakeItUnique(filePath);
}

Future<String> _fmSuffixFilePathToMakeItUnique(
  String filePath, {
  String? intendedExtension,
  String? currentPath,
}) async {
  String newFilePath = filePath;
  bool hasExtension = false;

  if (filePath.endsWith(NotePaths.extension)) {
    filePath = filePath.substring(
      0,
      filePath.length - NotePaths.extension.length,
    );
    newFilePath = filePath;
    hasExtension = true;
    intendedExtension ??= NotePaths.extension;
  } else if (filePath.endsWith(NotePaths.extensionOldJson)) {
    filePath = filePath.substring(
      0,
      filePath.length - NotePaths.extensionOldJson.length,
    );
    newFilePath = filePath;
    hasExtension = true;
    intendedExtension ??= NotePaths.extensionOldJson;
  } else {
    intendedExtension ??= NotePaths.extension;
  }

  int i = 1;
  while (true) {
    if (!_fmDoesFileExist(newFilePath + NotePaths.extension) &&
        !_fmDoesFileExist(newFilePath + NotePaths.extensionOldJson))
      break;
    if (newFilePath + NotePaths.extension == currentPath) break;
    if (newFilePath + NotePaths.extensionOldJson == currentPath) break;
    i++;
    newFilePath = '$filePath ($i)';
  }

  return newFilePath + (hasExtension ? intendedExtension : '');
}

/// Creates the parent directories of filePath if they don't exist.
Future _createFileDirectory(String filePath) async {
  assert(filePath.contains('/'), 'filePath must be a path, not a file name');
  final parentDirectory = filePath.substring(0, filePath.lastIndexOf('/'));
  await Directory(
    FileManager.documentsDirectory + parentDirectory,
  ).create(recursive: true);
}
