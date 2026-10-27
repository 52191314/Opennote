/// 🤖 Generated wholely or partially with Grok 4.7
library;

import 'package:flutter/material.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/tools/pen.dart';
import 'package:sbn/tool_id.dart';

/// One saved pen: a color and a thickness.
class PenPreset {
  const PenPreset(this.color, this.size);

  /// ARGB color stored as an int.
  final int color;

  /// Stroke thickness in page pixels.
  final double size;
}

/// The row of saved pens.
///
/// Choosing a pen writes its color and thickness onto the pen already in
/// use. It does not replace [Pen.currentPen].
class PenTray {
  /// Black, blue, red, green, purple, and brown.
  static const defaultPresets = <PenPreset>[
    PenPreset(0xFF000000, 2),
    PenPreset(0xFF1565C0, 3),
    PenPreset(0xFFC62828, 4),
    PenPreset(0xFF2E7D32, 3),
    PenPreset(0xFF6A1B9A, 5),
    PenPreset(0xFF5D4037, 8),
  ];

  static const encodedDefaults =
      'ff000000:2,ff1565c0:3,ffc62828:4,ff2e7d32:3,ff6a1b9a:5,ff5d4037:8';

  static List<PenPreset> get presets => decode(stows.penTray.value);

  static int get selectedIndex {
    final pens = presets;
    if (pens.isEmpty) return 0;
    final index = stows.penTrayIndex.value;
    if (index < 0 || index >= pens.length) return 0;
    return index;
  }

  /// Applies saved pen [index] onto [pen].
  static void select(int index, Pen pen) {
    final pens = presets;
    if (index < 0 || index >= pens.length) return;
    _apply(pens[index], pen);
    stows.penTrayIndex.value = index;
    _persistPen(pen);
  }

  /// Stores [pen]'s current color and thickness in the selected slot.
  static void remember(Pen pen) {
    if (!Pen.isWritingPen(pen)) return;
    final pens = List<PenPreset>.of(presets);
    final index = selectedIndex;
    if (index < 0 || index >= pens.length) return;
    pens[index] = PenPreset(pen.color.toARGB32(), pen.options.size);
    stows.penTray.value = encode(pens);
    _persistPen(pen);
  }

  static String encode(List<PenPreset> pens) {
    return pens
        .map((pen) => '${pen.color.toRadixString(16)}:${_sizeText(pen.size)}')
        .join(',');
  }

  static List<PenPreset> decode(String encoded) {
    final pens = <PenPreset>[];
    for (final part in encoded.split(',')) {
      final bits = part.split(':');
      if (bits.length != 2) continue;
      final color = int.tryParse(bits[0], radix: 16);
      final size = double.tryParse(bits[1]);
      if (color == null || size == null || size <= 0) continue;
      pens.add(PenPreset(color, size));
    }
    if (pens.isNotEmpty) return pens;
    return defaultPresets;
  }

  static String _sizeText(double size) {
    if (size == size.roundToDouble()) return size.toInt().toString();
    return size.toString();
  }

  static void _apply(PenPreset preset, Pen pen) {
    pen.color = Color(preset.color);
    pen.options.size = preset.size;
  }

  static void _persistPen(Pen pen) {
    final color = pen.color.toARGB32();
    switch (pen.toolId) {
      case ToolId.fountainPen:
        stows.lastFountainPenColor.value = color;
        stows.lastFountainPenOptions.value = pen.options;
      case ToolId.ballpointPen:
        stows.lastBallpointPenColor.value = color;
        stows.lastBallpointPenOptions.value = pen.options;
      case ToolId.shapePen:
        stows.lastShapePenColor.value = color;
        stows.lastShapePenOptions.value = pen.options;
      default:
        break;
    }
  }
}
