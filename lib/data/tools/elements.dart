/// 🤖 Generated wholely or partially with Claude Code; Google Antigravity
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:saber/components/canvas/_stroke.dart';
import 'package:saber/data/editor/page.dart';
import 'package:saber/data/prefs.dart';
import 'package:sbn/has_size.dart';
import 'package:sbn/tool_id.dart';

/// Represents a single reusable element/sticker that can be saved
/// and stamped onto canvas pages.
class ElementItem {
  final String id;
  final String name;
  final String category;
  final List<Map<String, dynamic>> strokesJson;
  final DateTime createdAt;

  ElementItem({
    required this.id,
    required this.name,
    this.category = 'General',
    required this.strokesJson,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'strokes': strokesJson,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ElementItem.fromJson(Map<String, dynamic> json) => ElementItem(
    id: json['id'] as String? ?? UniqueKey().toString(),
    name: json['name'] as String? ?? 'Sticker',
    category: json['category'] as String? ?? 'General',
    strokesJson: (json['strokes'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [],
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
  );

  /// Deserializes strokes and shifts them so their center aligns with [targetCenter].
  List<Stroke> instantiateStrokes({
    required HasSize page,
    Offset targetCenter = const Offset(200, 200),
  }) {
    final strokes = EditorPage.parseStrokesJson(
      strokesJson,
      page: page,
      onlyFirstPage: false,
      fileVersion: 2,
    );
    if (strokes.isEmpty) return [];

    Rect? totalBounds;
    for (final s in strokes) {
      final b = s.highQualityPath.getBounds();
      totalBounds = totalBounds == null ? b : totalBounds.expandToInclude(b);
    }
    if (totalBounds != null && !totalBounds.isEmpty) {
      final shiftOffset = targetCenter - totalBounds.center;
      for (final s in strokes) {
        s.shift(shiftOffset);
      }
    }
    return strokes;
  }
}

/// Manages collections of user and default reusable canvas elements.
class ElementsManager extends ChangeNotifier {
  static final instance = ElementsManager._internal();
  ElementsManager._internal() {
    _load();
  }

  final List<ElementItem> _items = [];
  List<ElementItem> get items => List.unmodifiable(_items);

  /// Reloads items from storage or falls back to defaults.
  void reload() {
    _load();
    notifyListeners();
  }

  List<String> get categories {
    final cats = _items.map((e) => e.category).toSet().toList();
    if (!cats.contains('General')) cats.insert(0, 'General');
    if (!cats.contains('Stickers')) cats.add('Stickers');
    if (!cats.contains('Shapes')) cats.add('Shapes');
    return cats;
  }

  void _load() {
    _items.clear();
    final rawJson = stows.elementsJson.value;
    if (rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _items.add(ElementItem.fromJson(item));
            }
          }
        }
      } catch (_) {
        // Fallback to defaults
      }
    }
    if (_items.isEmpty) {
      _loadDefaults();
    }
  }

  void _loadDefaults() {
    _items.addAll([
      _createStarElement(),
      _createHeartElement(),
      _createCheckmarkElement(),
      _createStickyNoteElement(),
    ]);
  }

  static Map<String, dynamic> _strokeToJson(Stroke stroke) {
    final json = stroke.toJson();
    json['p'] = stroke.rawPoints.map((p) => <String, dynamic>{
      'x': p.x,
      'y': p.y,
      if (p.pressure != null) 'p': p.pressure,
    }).toList();
    return json;
  }

  static ElementItem _createStarElement() {
    final stroke = Stroke(
      color: const Color(0xFFFFB300),
      pressureEnabled: false,
      options: StrokeOptions(size: 4),
      pageIndex: 0,
      page: const HasSize(Size(100, 100)),
      toolId: ToolId.ballpointPen,
    );
    stroke.addPoint(const Offset(50, 10), 0.6);
    stroke.addPoint(const Offset(62, 38), 0.6);
    stroke.addPoint(const Offset(92, 38), 0.6);
    stroke.addPoint(const Offset(68, 56), 0.6);
    stroke.addPoint(const Offset(77, 85), 0.6);
    stroke.addPoint(const Offset(50, 68), 0.6);
    stroke.addPoint(const Offset(23, 85), 0.6);
    stroke.addPoint(const Offset(32, 56), 0.6);
    stroke.addPoint(const Offset(8, 38), 0.6);
    stroke.addPoint(const Offset(38, 38), 0.6);
    stroke.addPoint(const Offset(50, 10), 0.6);

    return ElementItem(
      id: 'default_star',
      name: 'Star',
      category: 'Stickers',
      strokesJson: [_strokeToJson(stroke)],
    );
  }

  static ElementItem _createHeartElement() {
    final stroke = Stroke(
      color: const Color(0xFFE91E63),
      pressureEnabled: false,
      options: StrokeOptions(size: 4),
      pageIndex: 0,
      page: const HasSize(Size(100, 100)),
      toolId: ToolId.ballpointPen,
    );
    stroke.addPoint(const Offset(50, 30), 0.6);
    stroke.addPoint(const Offset(35, 15), 0.6);
    stroke.addPoint(const Offset(15, 25), 0.6);
    stroke.addPoint(const Offset(15, 50), 0.6);
    stroke.addPoint(const Offset(50, 85), 0.6);
    stroke.addPoint(const Offset(85, 50), 0.6);
    stroke.addPoint(const Offset(85, 25), 0.6);
    stroke.addPoint(const Offset(65, 15), 0.6);
    stroke.addPoint(const Offset(50, 30), 0.6);

    return ElementItem(
      id: 'default_heart',
      name: 'Heart',
      category: 'Stickers',
      strokesJson: [_strokeToJson(stroke)],
    );
  }

  static ElementItem _createCheckmarkElement() {
    final stroke = Stroke(
      color: const Color(0xFF4CAF50),
      pressureEnabled: false,
      options: StrokeOptions(size: 4.5),
      pageIndex: 0,
      page: const HasSize(Size(100, 100)),
      toolId: ToolId.ballpointPen,
    );
    stroke.addPoint(const Offset(20, 50), 0.5);
    stroke.addPoint(const Offset(38, 75), 0.7);
    stroke.addPoint(const Offset(82, 22), 0.8);

    return ElementItem(
      id: 'default_checkmark',
      name: 'Checkmark',
      category: 'Stickers',
      strokesJson: [_strokeToJson(stroke)],
    );
  }

  static ElementItem _createStickyNoteElement() {
    final borderStroke = Stroke(
      color: const Color(0xFFFFCA28),
      pressureEnabled: false,
      options: StrokeOptions(size: 3),
      pageIndex: 0,
      page: const HasSize(Size(100, 100)),
      toolId: ToolId.ballpointPen,
    );
    borderStroke.addPoint(const Offset(10, 10), 0.6);
    borderStroke.addPoint(const Offset(90, 10), 0.6);
    borderStroke.addPoint(const Offset(90, 90), 0.6);
    borderStroke.addPoint(const Offset(10, 90), 0.6);
    borderStroke.addPoint(const Offset(10, 10), 0.6);

    return ElementItem(
      id: 'default_stickynote',
      name: 'Sticky Note',
      category: 'General',
      strokesJson: [_strokeToJson(borderStroke)],
    );
  }

  void addElement({
    required String name,
    required List<Stroke> strokes,
    String category = 'General',
  }) {
    if (strokes.isEmpty) return;

    Rect? totalBounds;
    for (final s in strokes) {
      final b = s.highQualityPath.getBounds();
      totalBounds = totalBounds == null ? b : totalBounds.expandToInclude(b);
    }

    final origin = totalBounds?.topLeft ?? Offset.zero;
    final normalized = strokes.map((s) {
      final copy = s.copy();
      copy.shift(-origin);
      return _strokeToJson(copy);
    }).toList();

    final newItem = ElementItem(
      id: 'elem_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: category,
      strokesJson: normalized,
    );
    _items.insert(0, newItem);
    _save();
    notifyListeners();
  }

  void removeElement(String id) {
    _items.removeWhere((item) => item.id == id);
    _save();
    notifyListeners();
  }

  void _save() {
    stows.elementsJson.value = jsonEncode(_items.map((e) => e.toJson()).toList());
  }
}
