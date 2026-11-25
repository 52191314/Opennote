/// 🤖 Generated wholely or partially with Google Antigravity
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'package:flutter/material.dart';

/// Top-level categories shown in the Settings rail and filter chips.
enum SettingsCategory {
  all('All Settings', Icons.tune_rounded, ''),
  membershipSync(
    'Membership & Sync',
    Icons.cloud_sync_outlined,
    'pro membership subscription trial restore purchases cloud sync nextcloud webdav account login insecure connections',
  ),
  stylusCanvas(
    'Stylus & Canvas',
    Icons.draw_rounded,
    'stylus canvas editor pen studio ui toolbar fullscreen invert infinite canvas recent colors writing gestures greyscale whiteboard eraser scribble finger drawing pressure curve posture palm straighten shapes',
  ),
  appearance(
    'Appearance & Theme',
    Icons.palette_outlined,
    'general appearance language locale theme dark light mode platform layout size accent color hyperlegible font simplified home',
  ),
  exportBackup(
    'Export & Backup',
    Icons.save_alt_rounded,
    'export backup autosave storage custom data dir print page indicators max image size rename',
  ),
  supportCommunity(
    'Support & Community',
    Icons.favorite_outline_rounded,
    'support community rate review app store play store share opennote restore purchases welcome tour guide about version updates logs debug diagnostics sentry license',
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
