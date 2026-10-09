/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

/// How note files are named, and which paths the app keeps for itself.
abstract final class NotePaths {
  /// The file extension used by the app.
  /// Files with this extension are
  /// encoded in BSON format.
  static const extension = '.sbn2';

  /// The old file extension used by the app.
  /// Files with this extension are
  /// encoded in JSON format.
  static const extensionOldJson = '.sbn';

  /// The path of the note behind the whiteboard page.
  static const whiteboard = '/_whiteboard';

  /// Returns true if [path] belongs to a hidden file
  /// used by other functions of the app
  static bool isReserved(String path) =>
      _reserved.any((regex) => regex.hasMatch(path));

  static final _reserved = <RegExp>[RegExp(RegExp.escape(whiteboard))];
}
