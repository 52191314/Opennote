/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:saber/data/is_this_a_test.dart';

/// Holds the decoded thumbnail [ImageProvider] and existence flag for a
/// notebook preview card, notifying listeners whenever the thumbnail changes.
class PreviewThumbnailState extends ChangeNotifier {
  var updateCount = 0;
  ImageProvider? _image;
  var _imageExists = false;
  File? _imageFile;

  /// The current thumbnail image provider, if loaded.
  ImageProvider? get image => _image;

  /// Whether a valid thumbnail image exists on disk and is ready to display.
  bool get doesImageExist => _image != null && _imageExists;

  /// Derives a displayable parent folder label from [filePath], or `null` at root.
  static String? folderLabelFor(String filePath) {
    final lastSlash = filePath.lastIndexOf('/');
    if (lastSlash <= 0) return null;
    final folder = filePath.substring(1, lastSlash);
    return folder.isEmpty ? null : folder;
  }

  /// Increments [updateCount] and notifies listeners to refresh the view.
  void markAsChanged() {
    ++updateCount;
    notifyListeners();
  }

  /// Replaces the thumbnail [image] and updates its [exists] status.
  void setImage(ImageProvider? image, {required bool exists}) {
    _image = image;
    _imageExists = exists;
    markAsChanged();
  }

  /// Updates the existence flag without replacing the [ImageProvider].
  void setExists(bool exists, {bool forceNotify = false}) {
    if (_imageExists == exists && !forceNotify) return;
    _imageExists = exists;
    markAsChanged();
  }

  /// Binds [imageFile] and loads or refreshes its decoded [ImageProvider].
  void bindFile(File imageFile, {required bool Function() isMounted}) {
    final isSameFile = _imageFile?.path == imageFile.path;
    _imageFile = imageFile;

    if (isThisATest) {
      final exists = imageFile.existsSync();
      setImage(
        exists ? MemoryImage(imageFile.readAsBytesSync()) : null,
        exists: exists,
      );
      return;
    }

    if (!isSameFile || _image == null) {
      setImage(
        ResizeImage(FileImage(imageFile), width: 400),
        exists: doesImageExist,
      );
      unawaited(_checkExists(imageFile, isMounted: isMounted));
    }
  }

  /// Evicts cached bytes and re-checks the bound thumbnail file on disk.
  void refresh({required bool Function() isMounted}) {
    _image?.evict();
    final imageFile = _imageFile;
    if (isThisATest && imageFile != null) {
      final exists = imageFile.existsSync();
      setImage(
        exists ? MemoryImage(imageFile.readAsBytesSync()) : null,
        exists: exists,
      );
      return;
    }
    if (imageFile != null) {
      if (_image == null) {
        setImage(
          ResizeImage(FileImage(imageFile), width: 400),
          exists: doesImageExist,
        );
      }
      unawaited(
        _checkExists(imageFile, isMounted: isMounted, forceNotify: true),
      );
    } else {
      markAsChanged();
    }
  }

  Future<void> _checkExists(
    File imageFile, {
    required bool Function() isMounted,
    bool forceNotify = false,
  }) async {
    // ignore: avoid_slow_async_io
    final exists = await imageFile.exists();
    if (!isMounted() || _imageFile?.path != imageFile.path) return;
    setExists(exists, forceNotify: forceNotify);
  }
}
