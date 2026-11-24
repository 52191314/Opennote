/// 🤖 Generated wholely or partially with Google Antigravity
part of 'file_manager.dart';

Future _fmExportFile(
  String fileName,
  List<int> bytes, {
  bool isImage = false,
  required BuildContext context,
}) async {
  File? tempFile;
  Future<File> getTempFile() async {
    final tempFolder = (await getTemporaryDirectory()).path;
    final file = File('$tempFolder/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  if (isImage) {
    final permissionGranted = await _requestPhotosPermission();
    if (permissionGranted) {
      await SaverGallery.saveImage(
        Uint8List.fromList(bytes),
        fileName: fileName,
        albumPath: 'Saber',
        skipIfExists: true,
      );
    }
  } else {
    tempFile = await getTempFile();
    if (Platform.isIOS) {
      if (!context.mounted) return;
      final box = context.findRenderObject() as RenderBox;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempFile.path)],
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } else {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(tempFile.path)]),
      );
    }
  }

  await tempFile?.delete();
}

Future<bool> _requestPhotosPermission() async {
  if (Platform.isIOS) {
    return await Permission.photosAddOnly.request().isGranted;
  } else if (!Platform.isAndroid) {
    return true;
  }

  final sdkInt = await DeviceInfoPlugin().androidInfo.then(
    (info) => info.version.sdkInt,
  );
  if (sdkInt > 33) {
    return await Permission.photos.request().isGranted;
  } else {
    return await Permission.storage.request().isGranted;
  }
}

Future<String?> _fmImportFile(
  String path,
  String? parentDir, {
  String? extension,
  bool awaitWrite = true,
}) async {
  assert(
    parentDir == null || parentDir.startsWith('/') && parentDir.endsWith('/'),
  );

  if (extension == null) {
    extension = '.${path.split('.').last}';
    assert(extension.length > 1);
  } else {
    assert(extension.startsWith('.'));
  }

  String fileName = path.split(RegExp(r'[\\/]')).last;
  fileName = fileName.substring(0, fileName.lastIndexOf('.'));
  final String importedPath;

  final writeFutures = <Future>[];

  if (extension.toLowerCase() == '.sba') {
    final inputStream = InputFileStream(path);
    final archive = ZipDecoder().decodeStream(inputStream);

    final mainFile = archive.files.cast<ArchiveFile?>().firstWhere(
      (file) =>
          file!.name.toLowerCase().endsWith('sbn') ||
          file.name.toLowerCase().endsWith('sbn2'),
      orElse: () => null,
    );
    if (mainFile == null) {
      FileManager.log.severe('Failed to find main note in sba: $path');
      return null;
    }
    final mainFileExtension = '.${mainFile.name.split('.').last}'.toLowerCase();
    importedPath = await _fmSuffixFilePathToMakeItUnique(
      '${parentDir ?? '/'}$fileName',
      intendedExtension: mainFileExtension,
    );
    final mainFileContents = () {
      final output = OutputMemoryStream();
      mainFile.writeContent(output);
      return output.getBytes();
    }();
    writeFutures.add(
      _fmWriteFile(
        importedPath + mainFileExtension,
        mainFileContents,
        awaitWrite: awaitWrite,
      ),
    );

    for (final file in archive.files) {
      if (!file.isFile) continue;
      if (file == mainFile) continue;

      final extension = file.name.split('.').last;
      final assetNumber = int.tryParse(extension);
      if (assetNumber == null) continue;
      if (assetNumber < 0) continue;

      final assetBytes = () {
        final output = OutputMemoryStream();
        file.writeContent(output);
        return output.getBytes();
      }();
      writeFutures.add(
        _fmWriteFile(
          '$importedPath$mainFileExtension.$assetNumber',
          assetBytes,
          awaitWrite: awaitWrite,
        ),
      );
    }
  } else {
    final file = File(path);
    final fileContents = await file.readAsBytes();
    importedPath = await _fmSuffixFilePathToMakeItUnique(
      '${parentDir ?? '/'}$fileName',
      intendedExtension: extension.toLowerCase(),
    );
    writeFutures.add(
      _fmWriteFile(
        importedPath + extension.toLowerCase(),
        fileContents,
        awaitWrite: awaitWrite,
      ),
    );
  }

  await Future.wait(writeFutures);

  return importedPath;
}
