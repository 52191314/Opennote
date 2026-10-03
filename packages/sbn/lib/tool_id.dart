/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:stow_codecs/stow_codecs.dart';

/// An enum of all available tools.
/// Note that the pens must be ordered in z-axis order,
/// e.g. so that the highlighter is always below the rest.
enum ToolId {
  highlighter('Highlighter'),
  fountainPen('fountainPen'),
  ballpointPen('ballpointPen'),
  pencil('Pencil'),
  shapePen('ShapePen'),
  eraser('Eraser'),
  select('Select'),
  textEditing('TextEditingTool'),
  laserPointer('LaserPointer'),
  ruler('Ruler'),
  arrow('ArrowTool'),
  dimension('DimensionTool'),
  studyTape('StudyTape');

  final String id;
  const ToolId(this.id);

  static const codec = EnumCodec(values);

  static final _log = Logger('ToolId');

  /// Before using this enum, we used the (runtimeType).toString()
  /// as the identifier for pens.
  /// This function converts those old identifiers to the new [ToolId]s.
  static ToolId parsePenType(String? penType, {required ToolId fallback}) {
    if (penType == null) {
      return fallback;
    }
    if (penType == 'Pen') {
      return .fountainPen;
    }
    for (final toolId in ToolId.values) {
      if (penType == toolId.id) {
        return toolId;
      }
    }
    if (kDebugMode) {
      throw ArgumentError.value(
        penType,
        'penType',
        'Unknown pen type: `$penType`.',
      );
    }
    _log.warning(
      'Unknown pen type: `$penType`, using fallback `${fallback.id}`.',
    );
    return fallback;
  }
}

/// Z-index ordering for strokes rendered on the canvas.
/// Highlighters render lowest (behind ink), normal pens in middle,
/// and study tape renders on top to conceal notes.
extension ToolIdZIndex on ToolId {
  int get zIndex => switch (this) {
    ToolId.highlighter => 0,
    ToolId.studyTape => 2,
    _ => 1,
  };
}
