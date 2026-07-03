/// 🤖 Generated with DeepSeek v4 Flash
///
/// Data model for stickers (pre-made emoji stamps) that can be
/// inserted onto the canvas.
library;

import 'package:flutter/material.dart';

/// A single sticker that can be placed on the canvas.
class Sticker {
  /// Display name shown in the picker.
  final String name;

  /// Material icon for preview in lists.
  final IconData icon;

  /// The emoji character(s) rendered on the canvas.
  final String emoji;

  const Sticker({
    required this.name,
    required this.icon,
    required this.emoji,
  });

  /// All built-in stickers grouped by category.
  static const categories = <StickerCategory>[
    StickerCategory(
      name: 'Stars',
      icon: Icons.star,
      stickers: [
        Sticker(name: 'Star', icon: Icons.star, emoji: '⭐'),
        Sticker(name: 'Glowing Star', icon: Icons.star_border, emoji: '🌟'),
        Sticker(name: 'Sparkles', icon: Icons.auto_awesome, emoji: '✨'),
      ],
    ),
    StickerCategory(
      name: 'Hearts',
      icon: Icons.favorite,
      stickers: [
        Sticker(name: 'Red Heart', icon: Icons.favorite, emoji: '❤️'),
        Sticker(name: 'Blue Heart', icon: Icons.favorite_border, emoji: '💙'),
        Sticker(name: 'Green Heart', icon: Icons.favorite_border, emoji: '💚'),
        Sticker(name: 'Yellow Heart', icon: Icons.favorite_border, emoji: '💛'),
        Sticker(name: 'Purple Heart', icon: Icons.favorite_border, emoji: '💜'),
      ],
    ),
    StickerCategory(
      name: 'Checkmarks',
      icon: Icons.check_circle,
      stickers: [
        Sticker(name: 'Check Mark', icon: Icons.check_circle, emoji: '✅'),
        Sticker(name: 'Cross Mark', icon: Icons.cancel, emoji: '❌'),
        Sticker(name: 'Ballot Box', icon: Icons.check_box, emoji: '☑️'),
        Sticker(name: 'Heavy Check', icon: Icons.check, emoji: '✔️'),
      ],
    ),
    StickerCategory(
      name: 'Arrows',
      icon: Icons.arrow_forward,
      stickers: [
        Sticker(name: 'Right Arrow', icon: Icons.arrow_forward, emoji: '➡️'),
        Sticker(name: 'Left Arrow', icon: Icons.arrow_back, emoji: '⬅️'),
        Sticker(name: 'Up Arrow', icon: Icons.arrow_upward, emoji: '⬆️'),
        Sticker(name: 'Down Arrow', icon: Icons.arrow_downward, emoji: '⬇️'),
        Sticker(name: 'Return Arrow', icon: Icons.subdirectory_arrow_left, emoji: '↩️'),
      ],
    ),
    StickerCategory(
      name: 'Smileys',
      icon: Icons.emoji_emotions,
      stickers: [
        Sticker(name: 'Smile', icon: Icons.emoji_emotions, emoji: '😊'),
        Sticker(name: 'Heart Eyes', icon: Icons.emoji_emotions, emoji: '😍'),
        Sticker(name: 'Thumbs Up', icon: Icons.thumb_up, emoji: '👍'),
        Sticker(name: 'Thumbs Down', icon: Icons.thumb_down, emoji: '👎'),
        Sticker(name: 'Party Popper', icon: Icons.celebration, emoji: '🎉'),
      ],
    ),
    StickerCategory(
      name: 'Nature',
      icon: Icons.nature,
      stickers: [
        Sticker(name: 'Sunflower', icon: Icons.nature, emoji: '🌻'),
        Sticker(name: 'Cherry Blossom', icon: Icons.nature, emoji: '🌸'),
        Sticker(name: 'Hibiscus', icon: Icons.nature, emoji: '🌺'),
        Sticker(name: 'Rainbow', icon: Icons.wb_sunny, emoji: '🌈'),
        Sticker(name: 'Sun', icon: Icons.wb_sunny, emoji: '☀️'),
      ],
    ),
    StickerCategory(
      name: 'Objects',
      icon: Icons.inventory_2,
      stickers: [
        Sticker(name: 'Memo', icon: Icons.note, emoji: '📝'),
        Sticker(name: 'Pushpin', icon: Icons.push_pin, emoji: '📌'),
        Sticker(name: 'Pencil', icon: Icons.edit, emoji: '✏️'),
        Sticker(name: 'Pen', icon: Icons.edit, emoji: '🖊️'),
        Sticker(name: 'Paperclip', icon: Icons.attach_file, emoji: '📎'),
      ],
    ),
    StickerCategory(
      name: 'Flags',
      icon: Icons.flag,
      stickers: [
        Sticker(name: 'Chequered Flag', icon: Icons.flag, emoji: '🏁'),
        Sticker(name: 'Triangular Flag', icon: Icons.flag, emoji: '🚩'),
        Sticker(name: 'Black Flag', icon: Icons.flag, emoji: '⚑'),
        Sticker(name: 'White Flag', icon: Icons.flag, emoji: '⚐'),
      ],
    ),
  ];

  /// Flat list of all stickers across all categories.
  static List<Sticker> get all =>
      categories.expand((category) => category.stickers).toList();
}

/// A named group of stickers for the picker UI.
class StickerCategory {
  final String name;
  final IconData icon;
  final List<Sticker> stickers;

  const StickerCategory({
    required this.name,
    required this.icon,
    required this.stickers,
  });
}
