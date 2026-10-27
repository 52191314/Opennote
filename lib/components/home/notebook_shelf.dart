/// 🤖 Generated wholely or partially with Grok 4.7
library;

import 'package:flutter/material.dart';
import 'package:saber/i18n/strings.g.dart';

/// Notebooks as covers on a shelf.
///
/// Tapping a cover calls [onOpenNote]. Tapping a folder calls [onOpenFolder].
/// Creating a notebook calls [onCreateNote] with its path so the shelf can
/// show it.
class NotebookShelf extends StatelessWidget {
  const NotebookShelf({
    super.key,
    required this.notes,
    required this.folders,
    required this.onOpenNote,
    required this.onOpenFolder,
    required this.onCreateNote,
    this.directory,
  });

  /// Note paths to show as covers.
  final List<String> notes;

  /// Folder names in the current directory.
  final List<String> folders;

  /// Directory the new notebook is created in. Null means the library root.
  final String? directory;

  final ValueChanged<String> onOpenNote;
  final ValueChanged<String> onOpenFolder;

  /// Called with the path of a notebook the user just created.
  final ValueChanged<String> onCreateNote;

  static const _coverColors = <Color>[
    Color(0xFF2B4C7E),
    Color(0xFF2E6F56),
    Color(0xFF8C3A3A),
    Color(0xFF7A4F82),
    Color(0xFF8D5B2C),
    Color(0xFF37474F),
    Color(0xFF1B6B76),
  ];

  String pathFor(String name) {
    final dir = directory;
    if (dir == null || dir.isEmpty || dir == '/') return '/$name';
    return '$dir/$name';
  }

  Future<void> _create(BuildContext context) async {
    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => const _NewNotebookDialog(),
    );
    if (chosen == null || chosen.isEmpty) return;
    onCreateNote(pathFor(chosen));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (folders.isNotEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final folder in folders)
                  ActionChip(
                    key: ValueKey('shelf-folder-$folder'),
                    avatar: const Icon(Icons.folder, size: 18),
                    label: Text(folder),
                    onPressed: () => onOpenFolder(folder),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 20,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              for (final note in notes)
                _NotebookCover(
                  key: ValueKey('shelf-cover-$note'),
                  title: _title(note),
                  color:
                      _coverColors[note.hashCode.abs() % _coverColors.length],
                  onTap: () => onOpenNote(note),
                ),
              _NewNotebook(onTap: () => _create(context)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
              border: Border(top: BorderSide(color: scheme.outlineVariant)),
            ),
          ),
        ],
      ),
    );
  }

  static String _title(String path) {
    final slash = path.lastIndexOf('/');
    if (slash == -1 || slash == path.length - 1) return path;
    return path.substring(slash + 1);
  }
}

class _NotebookCover extends StatelessWidget {
  const _NotebookCover({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 96,
        height: 128,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 10,
                child: ColoredBox(color: Color(0x33000000)),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 10, 16),
                  padding: const EdgeInsets.all(6),
                  color: const Color(0xFFFDFBF7),
                  child: Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2C2416),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewNotebookDialog extends StatefulWidget {
  const _NewNotebookDialog();

  @override
  State<_NewNotebookDialog> createState() => _NewNotebookDialogState();
}

class _NewNotebookDialogState extends State<_NewNotebookDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _name.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(t.home.shelf.newNotebook),
      content: TextField(
        key: const ValueKey('shelf-notebook-name'),
        controller: _name,
        autofocus: true,
        decoration: InputDecoration(hintText: t.home.shelf.notebookName),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.common.cancel),
        ),
        TextButton(
          key: const ValueKey('shelf-create-confirm'),
          onPressed: _submit,
          child: Text(t.home.newFolder.create),
        ),
      ],
    );
  }
}

class _NewNotebook extends StatelessWidget {
  const _NewNotebook({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const ValueKey('shelf-new-notebook'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 96,
        height: 128,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ColorScheme.of(context).outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add),
              const SizedBox(height: 6),
              Text(
                t.home.shelf.newNotebook,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
