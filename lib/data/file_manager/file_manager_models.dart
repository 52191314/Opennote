/// 🤖 Generated wholely or partially with Google Antigravity
library;

/// Children of a directory, separated into subdirectories and files.
class DirectoryChildren {
  final List<String> directories;
  final List<String> files;

  DirectoryChildren(this.directories, this.files);

  bool onlyOneChild() => directories.length + files.length <= 1;

  bool get isEmpty => directories.isEmpty && files.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

/// The type of file system operation broadcast on `FileManager.fileWriteStream`.
enum FileOperationType { write, delete }

/// A file system operation event emitted by `FileManager`.
class FileOperation {
  final FileOperationType type;
  final String filePath;

  const FileOperation(this.type, this.filePath);
}
