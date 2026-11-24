/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saber/components/settings/update_manager.dart';
import 'package:saber/components/theming/adaptive_alert_dialog.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/is_this_a_test.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/home/settings/settings_category.dart';
import 'package:saber/pages/home/settings/settings_layouts.dart';
import 'package:saber/pages/home/settings/settings_sections.dart';
import 'package:stow/stow.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();

  static Future<bool?> showResetDialog({
    required BuildContext context,
    required Stow pref,
    required String prefTitle,
  }) async {
    if (pref.value == pref.defaultValue) return null;
    return await showDialog(
      context: context,
      builder: (context) => AdaptiveAlertDialog(
        title: Text(t.settings.reset.title),
        content: Text(prefTitle),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              pref.value = pref.defaultValue;
              Navigator.of(context).pop(true);
            },
            child: Text(t.settings.reset.button),
          ),
        ],
      ),
    );
  }
}

class _SettingsPageState extends State<SettingsPage> {
  late TargetPlatform platform;

  var _selectedCategory = SettingsCategory.all;
  final _searchController = TextEditingController();
  var _searchQuery = '';

  @override
  void initState() {
    stows.locale.addListener(onChanged);
    UpdateManager.status.addListener(onChanged);
    super.initState();
  }

  void onChanged() {
    setState(() {});
  }

  bool _matches(SettingsCategory category) {
    return category.matches(
      selectedCategory: _selectedCategory,
      searchQuery: _searchQuery,
    );
  }

  // In tests, pretend the current platform is the defaultTargetPlatform.
  bool get usesCupertinoByDefault =>
      switch (isThisATest ? platform : defaultTargetPlatform) {
        .iOS => true,
        .macOS => true,
        _ => false,
      };
  bool get usesMaterialByDefault => !usesCupertinoByDefault;

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _onSearchCleared() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  void _onCategorySelected(SettingsCategory category) {
    setState(() => _selectedCategory = category);
  }

  @override
  Widget build(BuildContext context) {
    platform = Theme.of(context).platform;
    final cupertino = platform.isCupertino;
    final isWide = MediaQuery.sizeOf(context).width >= 760;
    final requiresManualUpdates = FlavorConfig.appStore.isEmpty;

    final cards = [
      if (_matches(SettingsCategory.syncStorage)) buildSyncSettingsCard(),
      if (_matches(SettingsCategory.appearance))
        buildAppearanceSettingsCard(
          cupertino: cupertino,
          usesMaterialByDefault: usesMaterialByDefault,
          usesCupertinoByDefault: usesCupertinoByDefault,
          onStateChanged: onChanged,
        ),
      if (_matches(SettingsCategory.editor))
        buildEditorSettingsCard(
          cupertino: cupertino,
          onStateChanged: onChanged,
        ),
      if (_matches(SettingsCategory.gestures)) buildGesturesSettingsCard(),
      if (_matches(SettingsCategory.about))
        buildAboutSettingsCard(
          context: context,
          requiresManualUpdates: requiresManualUpdates,
          onStateChanged: onChanged,
        ),
    ];

    if (isWide) {
      return SettingsWideLayout(
        selectedCategory: _selectedCategory,
        searchController: _searchController,
        searchQuery: _searchQuery,
        onSearchChanged: _onSearchChanged,
        onSearchCleared: _onSearchCleared,
        onCategorySelected: _onCategorySelected,
        cards: cards,
      );
    }

    return SettingsCompactLayout(
      selectedCategory: _selectedCategory,
      searchController: _searchController,
      searchQuery: _searchQuery,
      onSearchChanged: _onSearchChanged,
      onSearchCleared: _onSearchCleared,
      onCategorySelected: _onCategorySelected,
      cards: cards,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    stows.locale.removeListener(onChanged);
    UpdateManager.status.removeListener(onChanged);
    super.dispose();
  }
}
