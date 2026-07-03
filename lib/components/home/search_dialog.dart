/// 🤖 Generated with DeepSeek v4 Flash
library;

import 'dart:async';
import 'dart:convert';

import 'package:bson/bson.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';

/// A single match found by the search.
class SearchMatch {
  final String filePath;
  final String fileName;
  final int pageIndex;

  /// One of 'filename', 'text', 'color', 'tool'.
  final String matchKind;
  final String preview;

  SearchMatch({
    required this.filePath,
    required this.fileName,
    required this.pageIndex,
    required this.matchKind,
    required this.preview,
  });
}

/// A search dialog that searches across all notes in the current folder
/// for typed text (Quill content), file names, and stroke metadata.
class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  /// Shows the search dialog from the given [context].
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => const SearchDialog(),
    );
  }

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _scrollController = ScrollController();

  Timer? _debounce;

  /// All note files found in the root directory (cached once at search start).
  List<String> _allFiles = const [];

  /// Results accumulated so far.
  final _results = <SearchMatch>[];

  /// Whether a content-scan pass is in progress.
  var _isScanning = false;

  /// How many files have been scanned in the current content pass.
  var _filesScanned = 0;

  /// Total number of files to scan.
  var _totalFiles = 0;

  /// The most recent query we finished (or are) scanning for.
  /// Used to discard stale results when the query changes mid-scan.
  var _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _results.clear();
        _isScanning = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    final queryLower = query.toLowerCase();
    _activeQuery = queryLower;
    setState(() {
      _results.clear();
      _isScanning = true;
      _filesScanned = 0;
    });

    // 1. Discover all note files once per search session.
    if (_allFiles.isEmpty) {
      _allFiles = await FileManager.getAllFiles();
    }

    _totalFiles = _allFiles.length;

    // 2. Quick pass: file name matches (no file I/O).
    final fileNameMatches = <SearchMatch>[];
    for (final filePath in _allFiles) {
      final fileName = p.basename(filePath);
      if (fileName.toLowerCase().contains(queryLower)) {
        fileNameMatches.add(SearchMatch(
          filePath: filePath,
          fileName: fileName,
          pageIndex: 0,
          matchKind: 'filename',
          preview: fileName,
        ));
      }
    }
    if (!mounted || _activeQuery != queryLower) return;

    setState(() {
      _results.addAll(fileNameMatches);
    });

    // 3. Slow pass: open each file and search its contents.
    for (final filePath in _allFiles) {
      if (!mounted || _activeQuery != queryLower) return;

      setState(() {
        _filesScanned++;
      });

      try {
        final pageMatches = await _searchFileContents(
          filePath,
          queryLower,
        );
        if (!mounted || _activeQuery != queryLower) return;

        if (pageMatches.isNotEmpty) {
          setState(() {
            _results.addAll(pageMatches);
          });
        }
      } catch (_) {
        // Skip unreadable / corrupt files.
      }

      // Yield to the UI event loop every few files so the dialog stays
      // responsive.
      if (_filesScanned % 3 == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        if (!mounted || _activeQuery != queryLower) return;
      }
    }

    if (!mounted) return;
    setState(() {
      _isScanning = false;
    });
  }

  /// Lightweight search inside a single note file.
  ///
  /// Reads the raw BSON, deserialises it, and walks the page list looking for
  /// the query in Quill text, stroke colours, and tool types – *without*
  /// constructing a full [EditorCoreInfo].
  Future<List<SearchMatch>> _searchFileContents(
    String filePath,
    String queryLower,
  ) async {
    // Try .sbn2 (BSON) first, then .sbn (JSON).
    final bsonBytes = await FileManager.readFile(
      filePath + Editor.extension,
      retries: 0,
    );

    dynamic root;
    if (bsonBytes != null) {
      final bsonBinary = BsonBinary.from(bsonBytes);
      root = BsonCodec.deserialize(bsonBinary);
    } else {
      final jsonBytes = await FileManager.readFile(
        filePath + Editor.extensionOldJson,
        retries: 0,
      );
      if (jsonBytes == null) return const [];
      root = _parseJsonSafe(utf8.decode(jsonBytes));
    }

    if (root is! Map<String, dynamic>) return const [];

    final results = <SearchMatch>[];
    final fileName = p.basename(filePath);

    // Extract pages list (key 'z').
    final pagesList = (root['z'] as List?) ?? const [];

    for (int pageIdx = 0; pageIdx < pagesList.length; pageIdx++) {
      final pageJson = pagesList[pageIdx];
      if (pageJson is! Map<String, dynamic>) continue;

      // --- Quill text search (key 'q') ---
      final quillDelta = pageJson['q'];
      if (quillDelta is List && quillDelta.isNotEmpty) {
        final plainText = _extractPlainTextFromQuillDelta(quillDelta);
        if (plainText.toLowerCase().contains(queryLower)) {
          final snippet = _buildSnippet(plainText, queryLower);
          results.add(SearchMatch(
            filePath: filePath,
            fileName: fileName,
            pageIndex: pageIdx,
            matchKind: 'text',
            preview: 'Page ${pageIdx + 1}: "$snippet"',
          ));
        }
      }

      // --- Legacy stroke list (key 's') ---
      final legacyStrokes = pageJson['s'];
      if (legacyStrokes is List) {
        _searchStrokeList(
          legacyStrokes,
          filePath: filePath,
          fileName: fileName,
          pageIndex: pageIdx,
          queryLower: queryLower,
          results: results,
        );
      }

      // --- New layer format (key 'l') ---
      final layersList = pageJson['l'];
      if (layersList is List) {
        for (final layerJson in layersList) {
          if (layerJson is! Map<String, dynamic>) continue;
          final strokeList = layerJson['s'];
          if (strokeList is List) {
            _searchStrokeList(
              strokeList,
              filePath: filePath,
              fileName: fileName,
              pageIndex: pageIdx,
              queryLower: queryLower,
              results: results,
            );
          }
        }
      }
    }

    return results;
  }

  /// Searches a list of stroke JSON objects for colour and tool-type matches.
  void _searchStrokeList(
    List strokes, {
    required String filePath,
    required String fileName,
    required int pageIndex,
    required String queryLower,
    required List<SearchMatch> results,
  }) {
    bool foundColor = false;
    bool foundTool = false;

    for (final stroke in strokes) {
      if (stroke is! Map<String, dynamic>) continue;

      // --- Colour search ---
      if (!foundColor) {
        final colorInt = _extractInt(stroke['c']);
        if (colorInt != null) {
          final hex = _intToHex(colorInt);
          if (hex.toLowerCase().contains(queryLower)) {
            results.add(SearchMatch(
              filePath: filePath,
              fileName: fileName,
              pageIndex: pageIndex,
              matchKind: 'color',
              preview: 'Page ${pageIndex + 1} – colour $hex',
            ));
            foundColor = true;
          }
        }
      }

      // --- Tool type search ---
      if (!foundTool) {
        final toolType = stroke['ty'] as String?;
        if (toolType != null &&
            toolType.toLowerCase().contains(queryLower)) {
          results.add(SearchMatch(
            filePath: filePath,
            fileName: fileName,
            pageIndex: pageIndex,
            matchKind: 'tool',
            preview: 'Page ${pageIndex + 1} – tool: $toolType',
          ));
          foundTool = true;
        }
      }

      if (foundColor && foundTool) break;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Converts an ARGB int to a hex string like `#FF0000FF`.
  static String _intToHex(int value) {
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Tries to read [v] as an int (including BsonBinary → Int64).
  static int? _extractInt(dynamic v) {
    if (v is int) return v;
    if (v is Int64) return v.toInt();
    return null;
  }

  /// Safely decodes a JSON string, returning null on failure.
  static dynamic _parseJsonSafe(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  /// Extracts plain text from a Quill delta list.
  /// E.g. `[{"insert": "Hello\n"}, {"insert": "World"}]` → `"Hello\nWorld"`.
  static String _extractPlainTextFromQuillDelta(List delta) {
    final buffer = StringBuffer();
    for (final op in delta) {
      if (op is! Map) continue;
      final insert = op['insert'];
      if (insert is String) {
        buffer.write(insert);
      }
    }
    return buffer.toString();
  }

  /// Builds a compact snippet around the first occurrence of [query] in [text].
  static String _buildSnippet(String text, String query) {
    final idx = text.toLowerCase().indexOf(query);
    if (idx < 0) {
      return text.length > 60
          ? '${text.substring(0, 60)}…'
          : text;
    }

    const contextLen = 30;
    final start = (idx - contextLen).clamp(0, text.length);
    final end = (idx + query.length + contextLen).clamp(0, text.length);

    final prefix = start > 0 ? '…' : '';
    final suffix = end < text.length ? '…' : '';
    return '$prefix${text.substring(start, end)}$suffix';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final platform = Theme.of(context).platform;

    return Dialog(
      backgroundColor: colorScheme.surface,
      insetPadding: platform.isCupertino
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: platform.isCupertino
          ? _buildCupertino(context)
          : _buildMaterial(context),
    );
  }

  Widget _buildMaterial(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            autofocus: true,
            decoration: InputDecoration(
              hintText: t.home.search.hint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
          ),
        ),
        // Progress / status bar
        if (_isScanning || _results.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                if (_isScanning)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                if (_isScanning) const SizedBox(width: 8),
                Text(
                  _isScanning
                      ? '${t.home.search.scanning} $_filesScanned / $_totalFiles'
                      : t.home.search.resultsFound(n: _results.length),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        // Results list
        if (_results.isNotEmpty)
          Flexible(
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                return _SearchResultTile(match: _results[index]);
              },
            ),
          )
        else if (!_isScanning && _searchController.text.trim().length >= 2)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                t.home.search.noResults,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else if (!_isScanning)
          const Spacer(),
        // Close button
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.common.cancel),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCupertino(BuildContext context) {
    // On Cupertino we use a simple full-screen look.
    return _buildMaterial(context);
  }
}

// ---------------------------------------------------------------------------
// Result tile widget
// ---------------------------------------------------------------------------

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.match});

  final SearchMatch match;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final theme = Theme.of(context);

    final IconData icon = switch (match.matchKind) {
      'filename' => Icons.description,
      'text' => Icons.text_fields,
      'color' => Icons.palette,
      'tool' => Icons.edit,
      _ => Icons.article,
    };

    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        match.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        match.preview,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        'P${match.pageIndex + 1}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () {
        // Pop the dialog, then navigate to the note.
        Navigator.pop(context);
        context.push(RoutePaths.editFilePath(match.filePath));
      },
    );
  }
}
