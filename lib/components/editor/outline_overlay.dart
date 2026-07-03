/// 🤖 Generated with DeepSeek v4 Flash
library;
import 'package:flutter/material.dart';
import 'package:saber/components/canvas/canvas_gesture_detector.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/data/editor/editor_core_info.dart';

/// A heading entry extracted from the document.
class _HeadingEntry {
  final int pageIndex;
  final int level; // 1-6
  final String text;

  const _HeadingEntry({
    required this.pageIndex,
    required this.level,
    required this.text,
  });
}

/// Displays a document outline (table of contents) inside a dialog.
///
/// Parses all pages' Quill documents for headings (h1-h6)
/// and shows them in a scrollable list. Tapping a heading
/// scrolls to the page containing that heading.
class DocumentOutlineView extends StatefulWidget {
  final EditorCoreInfo coreInfo;
  final TransformationController transformationController;

  const DocumentOutlineView({
    super.key,
    required this.coreInfo,
    required this.transformationController,
  });

  @override
  State<DocumentOutlineView> createState() => _DocumentOutlineViewState();
}

class _DocumentOutlineViewState extends State<DocumentOutlineView> {
  late List<_HeadingEntry> _headings;

  @override
  void initState() {
    super.initState();
    _extractHeadings();
  }

  void _extractHeadings() {
    _headings = [];
    for (int i = 0; i < widget.coreInfo.pages.length; i++) {
      final page = widget.coreInfo.pages[i];
      final delta = page.quill.controller.document.toDelta();
      for (final op in delta.toList()) {
        if (op.isInsert && op.data is String) {
          final attributes = op.attributes;
          if (attributes != null && attributes.containsKey('heading')) {
            final text = (op.data as String).trim();
            if (text.isEmpty) continue;
            final level = attributes['heading'] as int;
            _headings.add(_HeadingEntry(
              pageIndex: i,
              level: level,
              text: text,
            ));
          }
        }
      }
    }
  }

  void _scrollToPage(int pageIndex) {
    CanvasGestureDetector.scrollToPage(
      pageIndex: pageIndex,
      pages: widget.coreInfo.pages,
      screenWidth: MediaQuery.sizeOf(context).width,
      transformationController: widget.transformationController,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_headings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No headings found')),
      );
    }

    final platform = Theme.of(context).platform;
    return SizedBox(
      width: platform.isCupertino ? null : 350,
      height: platform.isCupertino ? 400 : null,
      child: ListView.builder(
        itemCount: _headings.length,
        itemBuilder: (context, index) {
          final entry = _headings[index];
          return InkWell(
            onTap: () => _scrollToPage(entry.pageIndex),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${entry.pageIndex + 1}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(width: (entry.level - 1) * 16.0),
                  Expanded(
                    child: Text(
                      entry.text,
                      style: TextStyle(
                        fontSize: 14.0 - (entry.level - 1) * 1.0,
                        fontWeight: entry.level <= 2
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
