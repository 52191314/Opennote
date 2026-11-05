/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
/// 🤖 Modified with Claude Code (Claude Opus 5.5)
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/tools/elements.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:sbn/has_size.dart';

/// Modal bottom sheet or popup for browsing, selecting, and managing Elements (stickers/assets).
class ElementsSheet extends StatefulWidget {
  final ValueChanged<ElementItem> onSelectElement;

  const ElementsSheet({super.key, required this.onSelectElement});

  @override
  State<ElementsSheet> createState() => _ElementsSheetState();
}

class _ElementsSheetState extends State<ElementsSheet> {
  final _manager = ElementsManager.instance;
  var _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onManagerChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onManagerChanged);
    super.dispose();
  }

  void _onManagerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categories = ['All', ..._manager.categories];

    final filteredItems = _selectedCategory == 'All'
        ? _manager.items
        : _manager.items.where((e) => e.category == _selectedCategory).toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 460),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  t.editor.elements.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Category tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Grid of elements
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      t.editor.elements.empty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 110,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          widget.onSelectElement(item);
                          Navigator.of(context).pop();
                        },
                        onLongPress: () => _confirmDelete(item),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomPaint(
                                    size: const Size(60, 60),
                                    painter: _ElementThumbnailPainter(
                                      strokesJson: item.strokesJson,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 6,
                                  left: 4,
                                  right: 4,
                                ),
                                child: Text(
                                  item.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ElementItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.editor.elements.deleteTitle),
        content: Text(t.editor.elements.deleteConfirm(name: item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              _manager.removeElement(item.id);
              Navigator.pop(ctx);
            },
            child: Text(
              t.editor.actions.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders a thumbnail preview of element strokes scaled to fit into canvas bounds.
class _ElementThumbnailPainter extends CustomPainter {
  final List<Map<String, dynamic>> strokesJson;
  List<Stroke>? _cachedStrokes;

  _ElementThumbnailPainter({required this.strokesJson});

  @override
  void paint(Canvas canvas, Size size) {
    _cachedStrokes ??= EditorPage.parseStrokesJson(
      strokesJson,
      page: HasSize(size),
      onlyFirstPage: false,
      fileVersion: 2,
    );
    if (_cachedStrokes!.isEmpty) return;

    Rect? totalBounds;
    for (final s in _cachedStrokes!) {
      final b = s.highQualityPath.getBounds();
      totalBounds = totalBounds == null ? b : totalBounds.expandToInclude(b);
    }
    if (totalBounds == null || totalBounds.isEmpty) return;

    final width = max(1.0, totalBounds.width);
    final height = max(1.0, totalBounds.height);
    final scale = min((size.width - 8) / width, (size.height - 8) / height);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.translate(-totalBounds.center.dx, -totalBounds.center.dy);

    for (final s in _cachedStrokes!) {
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawPath(s.highQualityPath, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ElementThumbnailPainter oldDelegate) {
    return oldDelegate.strokesJson != strokesJson;
  }
}
