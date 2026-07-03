/// 🤖 Generated with DeepSeek v4 Flash
///
/// A dialog that displays available stickers (emoji stamps) in a
/// categorised grid for the user to pick from.
library;

import 'package:flutter/material.dart';
import 'package:saber/data/tools/stickers.dart';

/// Dialog that shows a grid of sticker categories and their emoji items.
///
/// When the user taps a sticker, [onStickerSelected] is called with the
/// emoji string.
class StickerPickerDialog extends StatefulWidget {
  const StickerPickerDialog({super.key, required this.onStickerSelected});

  /// Called when the user taps a sticker, providing the emoji string.
  final void Function(String emoji) onStickerSelected;

  @override
  State<StickerPickerDialog> createState() => _StickerPickerDialogState();
}

class _StickerPickerDialogState extends State<StickerPickerDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: Sticker.categories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    const categories = Sticker.categories;

    return AlertDialog(
      title: const Text('Stickers'),
      content: SizedBox(
        width: 360,
        height: 420,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                for (final category in categories)
                  Tab(
                    child: Text(category.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (final category in categories)
                    _StickerGrid(
                      stickers: category.stickers,
                      colorScheme: colorScheme,
                      onSelected: widget.onStickerSelected,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _StickerGrid extends StatelessWidget {
  const _StickerGrid({
    required this.stickers,
    required this.colorScheme,
    required this.onSelected,
  });

  final List<Sticker> stickers;
  final ColorScheme colorScheme;
  final void Function(String emoji) onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        return Tooltip(
          message: sticker.name,
          child: Material(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                onSelected(sticker.emoji);
                Navigator.pop(context);
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    sticker.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
