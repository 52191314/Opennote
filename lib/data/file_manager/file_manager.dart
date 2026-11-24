/// 🤖 Modified with Claude Code (Claude Opus 5.5); Google Antigravity
library;

import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saber/data/file_manager/file_manager_models.dart';
import 'package:saber/data/file_manager/note_paths.dart';
import 'package:saber/data/nextcloud/saber_syncer.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';

export 'package:saber/data/file_manager/file_manager_models.dart';

part 'file_manager_io.dart';
part 'file_manager_migration.dart';
part 'file_manager_mutations.dart';
part 'file_manager_queries.dart';
part 'file_manager_transfer.dart';

/// A collection of cross-platform utility functions for working with a virtual file system.
class FileManager {
  // disable constructor
  FileManager._();

  static final log = Logger('FileManager');

  static const appRootDirectoryPrefix = 'Saber';

  /// This isn't final because isolates sometimes init multiple times.
  /// Realistically, this value never changes.
  static late String documentsDirectory;

  // ignore: close_sinks
  static final fileWriteStream = StreamController<FileOperation>.broadcast();

  /// A regex that matches the file names/paths of asset files,
  /// including previews, e.g. `mynote.sbn2.1`.
  static final assetFileRegex = RegExp(r'\.sbn2?\.[\dp]+$');

  /// Whether [getFile] should just return `File(filePath)`
  /// instead of prefixing with the documents directory.
  /// This is useful for testing when test files
  /// aren't in the documents directory.
  @visibleForTesting
  static var shouldUseRawFilePath = false;

  static const maxRecentlyAccessedFiles = 30;

  static String? validateFilename(String filename) =>
      _fmValidateFilename(filename);

  static Future<void> init({
    String? documentsDirectory,
    bool shouldWatchRootDirectory = true,
  }) => _fmInit(
    documentsDirectory: documentsDirectory,
    shouldWatchRootDirectory: shouldWatchRootDirectory,
  );

  static Future<String> getDocumentsDirectory() => _fmGetDocumentsDirectory();

  static Future<String> getDefaultDocumentsDirectory() =>
      _fmGetDefaultDocumentsDirectory();

  static Future<void> migrateDataDir() => _fmMigrateDataDir();

  static Future<void> moveDirContents({
    required Directory oldDir,
    required Directory newDir,
  }) => _fmMoveDirContents(oldDir: oldDir, newDir: newDir);

  @visibleForTesting
  static Future<void> watchRootDirectory() => _fmWatchRootDirectory();

  @visibleForTesting
  static void broadcastFileWrite(FileOperationType type, String path) =>
      _fmBroadcastFileWrite(type, path);

  /// Returns the contents of the file at [filePath].
  static Future<Uint8List?> readFile(String filePath, {int retries = 3}) =>
      _fmReadFile(filePath, retries: retries);

  static File getFile(String filePath) => _fmGetFile(filePath);

  static Directory getRootDirectory() => _fmGetRootDirectory();

  /// Writes [toWrite] to [filePath].
  ///
  /// The file at [filePath] will have its last modified timestamp set to
  /// [lastModified], if specified.
  /// This is useful when downloading remote files, to make sure that the
  /// timestamp is the same locally and remotely.
  static Future<void> writeFile(
    String filePath,
    List<int> toWrite, {
    bool awaitWrite = false,
    bool alsoUpload = true,
    DateTime? lastModified,
  }) => _fmWriteFile(
    filePath,
    toWrite,
    awaitWrite: awaitWrite,
    alsoUpload: alsoUpload,
    lastModified: lastModified,
  );

  static Future<void> createFolder(String folderPath) =>
      _fmCreateFolder(folderPath);

  static Future exportFile(
    String fileName,
    List<int> bytes, {
    bool isImage = false,
    required BuildContext context,
  }) => _fmExportFile(fileName, bytes, isImage: isImage, context: context);

  /// Moves a file from [fromPath] to [toPath], returning its final path.
  ///
  /// If a file already exists at [toPath], [fromPath] will be suffixed with
  /// a number e.g. "file (1)". If [replaceExistingFile] is true, the existing
  /// file will be overwritten instead.
  ///
  /// If [replaceExistingFile] is true but the file is a reserved file name,
  /// the filename will be suffixed with a number instead
  /// (like if [replaceExistingFile] was false).
  static Future<String> moveFile(
    String fromPath,
    String toPath, {
    bool replaceExistingFile = false,
    bool alsoMoveAssets = true,
  }) => _fmMoveFile(
    fromPath,
    toPath,
    replaceExistingFile: replaceExistingFile,
    alsoMoveAssets: alsoMoveAssets,
  );

  static Future deleteFile(
    String filePath, {
    bool alsoUpload = true,
    bool alsoDeleteAssets = true,
  }) => _fmDeleteFile(
    filePath,
    alsoUpload: alsoUpload,
    alsoDeleteAssets: alsoDeleteAssets,
  );

  static Future removeUnusedAssets(String filePath, {required int numAssets}) =>
      _fmRemoveUnusedAssets(filePath, numAssets: numAssets);

  static Future renameDirectory(String directoryPath, String newName) =>
      _fmRenameDirectory(directoryPath, newName);

  /// Moves a directory from [fromPath] into [toParentPath].
  ///
  /// Returns the new directory path, or `null` if the move was invalid or failed.
  static Future<String?> moveDirectory(String fromPath, String toParentPath) =>
      _fmMoveDirectory(fromPath, toParentPath);

  /// Moves either a note or directory [itemPath] into [targetParentFolder].
  ///
  /// Returns the final path of the moved item, or `null` if the operation failed.
  static Future<String?> moveItem(String itemPath, String targetParentFolder) =>
      _fmMoveItem(itemPath, targetParentFolder);

  static Future deleteDirectory(
    String directoryPath, [
    bool recursive = true,
  ]) => _fmDeleteDirectory(directoryPath, recursive);

  /// Gets the children of a directory, separated into
  /// [DirectoryChildren.directories] and [DirectoryChildren.files].
  ///
  /// If [includeExtensions] is false (default), the extension will be removed
  /// from the file names. We use this to get all notes in a directory.
  ///
  /// If [includeAssets] is true, assets and previews will be included.
  /// We use this for syncing.
  ///
  /// Note: [includeAssets] can't be true without [includeExtensions],
  /// since otherwise we wouldn't be able to tell the difference between notes
  /// and assets.
  static Future<DirectoryChildren?> getChildrenOfDirectory(
    String directory, {
    bool includeExtensions = false,
    bool includeAssets = false,
  }) => _fmGetChildrenOfDirectory(
    directory,
    includeExtensions: includeExtensions,
    includeAssets: includeAssets,
  );

  /// Returns a list of all files recursively in the root directory.
  ///
  /// See [getChildrenOfDirectory] for more information on the parameters.
  static Future<List<String>> getAllFiles({
    bool includeExtensions = false,
    bool includeAssets = false,
  }) => _fmGetAllFiles(
    includeExtensions: includeExtensions,
    includeAssets: includeAssets,
  );

  static Future<List<String>> getRecentlyAccessed() => _fmGetRecentlyAccessed();

  /// Returns whether the [filePath] is a directory or file.
  /// Behaviour is undefined if [filePath] is not a valid path.
  static bool isDirectory(String filePath) => _fmIsDirectory(filePath);

  static bool doesFileExist(String filePath) => _fmDoesFileExist(filePath);

  static DateTime lastModified(String filePath) => _fmLastModified(filePath);

  static Future<String> newFilePath([String parentPath = '/']) =>
      _fmNewFilePath(parentPath);

  /// Returns a unique file path by appending a number to the end of the [filePath].
  /// e.g. "/Untitled" -> "/Untitled (2)"
  ///
  /// Providing a [currentPath] means that e.g. "/Untitled (2)" being renamed
  /// to "/Untitled" will be returned as "/Untitled (2)" not "/Untitled (3)".
  ///
  /// If [currentPath] is provided, it must
  /// end with [NotePaths.extension] or [NotePaths.extensionOldJson].
  static Future<String> suffixFilePathToMakeItUnique(
    String filePath, {
    String? intendedExtension,
    String? currentPath,
  }) => _fmSuffixFilePathToMakeItUnique(
    filePath,
    intendedExtension: intendedExtension,
    currentPath: currentPath,
  );

  /// Imports a file from a sharing intent.
  ///
  /// [parentDir], if provided, must start and end with a slash.
  ///
  /// [extension], if provided, must start with a dot.
  /// If not provided, it will be inferred from the [path].
  ///
  /// Returns the file path of the imported file.
  static Future<String?> importFile(
    String path,
    String? parentDir, {
    String? extension,
    bool awaitWrite = true,
  }) => _fmImportFile(
    path,
    parentDir,
    extension: extension,
    awaitWrite: awaitWrite,
  );
}
