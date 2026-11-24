/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/material.dart';

/// Top-level categories shown in the Settings rail and filter chips.
enum SettingsCategory {
  all('All Settings', Icons.tune_rounded, ''),
  appearance(
    'Studio Appearance',
    Icons.palette_outlined,
    'general appearance language locale theme dark light mode platform layout size accent color hyperlegible font simplified home',
  ),
  editor(
    'Editor & Pen',
    Icons.edit_note_rounded,
    'editor pen studio ui toolbar fullscreen invert infinite canvas rename recent colors print page indicators performance image size autosave shape recognition straighten lines',
  ),
  gestures(
    'Smart Gestures',
    Icons.gesture_rounded,
    'writing gestures greyscale whiteboard eraser scribble finger drawing stylus pressure curve posture palm straighten shapes',
  ),
  syncStorage(
    'Cloud & Storage',
    Icons.cloud_sync_outlined,
    'nextcloud profile sync storage account login version app info custom data dir insecure',
  ),
  about(
    'About',
    Icons.info_outline_rounded,
    'about app info version updates welcome guide logs debug diagnostics sentry license',
  );

  const SettingsCategory(this.label, this.icon, this.searchKeywords);

  final String label;
  final IconData icon;
  final String searchKeywords;

  /// Returns whether this category matches the currently selected filter and
  /// search query.
  bool matches({
    required SettingsCategory selectedCategory,
    required String searchQuery,
  }) {
    if (selectedCategory != SettingsCategory.all && selectedCategory != this) {
      return false;
    }
    if (searchQuery.isEmpty) return true;
    return searchKeywords.toLowerCase().contains(searchQuery.toLowerCase());
  }
}
