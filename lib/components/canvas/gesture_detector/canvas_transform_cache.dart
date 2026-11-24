/// 🤖 Generated wholely or partially with Claude Code; Gemini; Google Antigravity
library;

import 'dart:collection';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:vector_math/vector_math_64.dart';

/// How to place the canvas when a note opens.
enum CanvasOpenScroll { unchanged, restoreCache, scrollToPage, identity }

/// The scroll decision for opening a note.
class CanvasOpenTarget {
  const CanvasOpenTarget(this.scroll, [this.pageIndex]);

  final CanvasOpenScroll scroll;
  final int? pageIndex;
}

/// Chooses the opening scroll.
///
/// An explicit route page, such as an ink-search hit, is shown even when
/// [cachedTransform] is the position from the last time this note was open.
CanvasOpenTarget chooseCanvasOpenTarget({
  required bool noteLoaded,
  required bool userHasScrolled,
  required Matrix4? cachedTransform,
  required bool isInfiniteCanvas,
  required int? explicitPageIndex,
  required int? savedPageIndex,
}) {
  if (!noteLoaded || userHasScrolled) {
    return const CanvasOpenTarget(CanvasOpenScroll.unchanged);
  }
  if (explicitPageIndex != null) {
    return CanvasOpenTarget(CanvasOpenScroll.scrollToPage, explicitPageIndex);
  }
  if (cachedTransform != null) {
    return const CanvasOpenTarget(CanvasOpenScroll.restoreCache);
  }
  if (isInfiniteCanvas) {
    return const CanvasOpenTarget(CanvasOpenScroll.identity);
  }
  if (savedPageIndex != null) {
    return CanvasOpenTarget(CanvasOpenScroll.scrollToPage, savedPageIndex);
  }
  return const CanvasOpenTarget(CanvasOpenScroll.unchanged);
}

class CanvasTransformCache {
  static const _maxCacheSize = 5;
  static final _cache = LinkedList<CanvasTransformCacheItem>();

  CanvasTransformCache._();

  static void add(String filePath, Matrix4 transform) {
    for (final entry in _cache) {
      if (entry.filePath != filePath) continue;
      entry.unlink();
      break;
    }
    _cache.add(CanvasTransformCacheItem(filePath, transform));

    if (_cache.length > _maxCacheSize) {
      _cache.first.unlink();
    }
  }

  static CanvasTransformCacheItem? get(String filePath) {
    try {
      return _cache.firstWhere((item) => item.filePath == filePath);
    } on StateError {
      return null;
    }
  }

  @visibleForTesting
  static void clear() {
    _cache.clear();
  }
}

base class CanvasTransformCacheItem
    extends LinkedListEntry<CanvasTransformCacheItem> {
  final String filePath;
  final Matrix4 transform;

  CanvasTransformCacheItem(this.filePath, this.transform);
}
