/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'dart:io';

import 'package:collapsible/collapsible.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:saber/components/design_system/opennote_tokens.dart';
import 'package:saber/components/navbar/responsive_navbar.dart';
import 'package:saber/components/onboarding/welcome_onboarding_dialog.dart';
import 'package:saber/components/settings/app_info.dart';
import 'package:saber/components/settings/nextcloud_profile.dart';
import 'package:saber/components/settings/settings_button.dart';
import 'package:saber/components/settings/settings_color.dart';
import 'package:saber/components/settings/settings_directory_selector.dart';
import 'package:saber/components/settings/settings_dropdown.dart';
import 'package:saber/components/settings/settings_selection.dart';
import 'package:saber/components/settings/settings_sentry.dart';
import 'package:saber/components/settings/settings_switch.dart';
import 'package:saber/components/settings/update_manager.dart';
import 'package:saber/components/settings/writing_posture_selector.dart';
import 'package:saber/components/theming/adaptive_alert_dialog.dart';
import 'package:saber/components/theming/adaptive_toggle_buttons.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/components/theming/uni_icon.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/is_this_a_test.dart';
import 'package:saber/data/locales.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/data/sentry/sentry_init.dart';
import 'package:saber/data/tools/shape_pen.dart';
import 'package:saber/i18n/strings.g.dart';
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

abstract class _SettingsStows {
  static final appTheme = TransformedStow(
    stows.appTheme,
    (ThemeMode value) => value.index,
    (int value) => ThemeMode.values[value],
  );

  static final platform = TransformedStow(
    stows.platform,
    (TargetPlatform value) => value.index,
    (int value) => TargetPlatform.values[value],
  );

  static final layoutSize = TransformedStow(
    stows.layoutSize,
    (LayoutSize value) => value.index,
    (int value) => LayoutSize.values[value],
  );

  static final editorToolbarAlignment = TransformedStow(
    stows.editorToolbarAlignment,
    (AxisDirection value) => value.index,
    (int value) => AxisDirection.values[value],
  );
}

class _PressureCurveSetting extends StatefulWidget {
  @override
  State<_PressureCurveSetting> createState() => _PressureCurveSettingState();
}

class _PressureCurveSettingState extends State<_PressureCurveSetting> {
  @override
  void initState() {
    super.initState();
    stows.penPressureCurve.addListener(onChanged);
  }

  void onChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.settings.prefLabels.penPressureCurve,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle:
                        stows.penPressureCurve.value !=
                            stows.penPressureCurve.defaultValue
                        ? FontStyle.italic
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.settings.prefDescriptions.penPressureCurve,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            stows.penPressureCurve.value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(
            width: 150,
            child: Slider(
              value: stows.penPressureCurve.value,
              min: 0.3,
              max: 3.0,
              divisions: 27,
              onChanged: (value) {
                stows.penPressureCurve.value = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    stows.penPressureCurve.removeListener(onChanged);
    super.dispose();
  }
}

enum _SettingsCategory {
  all('All Settings', Icons.tune_rounded),
  appearance('Studio Appearance', Icons.palette_outlined),
  editor('Editor & Pen', Icons.edit_note_rounded),
  gestures('Smart Gestures', Icons.gesture_rounded),
  syncStorage('Cloud & Storage', Icons.cloud_sync_outlined),
  about('About', Icons.info_outline_rounded);

  const _SettingsCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _SettingsPageState extends State<SettingsPage> {
  late TargetPlatform platform;

  var _selectedCategory = _SettingsCategory.all;
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

  bool _matchesSection(_SettingsCategory category, String keywords) {
    if (_selectedCategory != _SettingsCategory.all &&
        _selectedCategory != category) {
      return false;
    }
    if (_searchQuery.isEmpty) return true;
    return keywords.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  // In tests, pretend the current platform is the defaultTargetPlatform
  bool get usesCupertinoByDefault =>
      switch (isThisATest ? platform : defaultTargetPlatform) {
        .iOS => true,
        .macOS => true,
        _ => false,
      };
  bool get usesYaruByDefault =>
      switch (isThisATest ? platform : defaultTargetPlatform) {
        .linux => true,
        _ => false,
      };
  bool get usesMaterialByDefault =>
      !usesCupertinoByDefault && !usesYaruByDefault;

  static const cupertinoDirectionIcons = [
    CupertinoIcons.arrow_up_to_line,
    CupertinoIcons.arrow_right_to_line,
    CupertinoIcons.arrow_down_to_line,
    CupertinoIcons.arrow_left_to_line,
  ];
  static const materialDirectionIcons = [
    Icons.north,
    Icons.east,
    Icons.south,
    Icons.west,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    platform = Theme.of(context).platform;
    final cupertino = platform.isCupertino;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 760;

    final requiresManualUpdates = FlavorConfig.appStore.isEmpty;

    final materialIcon = switch (defaultTargetPlatform) {
      .windows => FontAwesomeIcons.windows,
      _ => Icons.android,
    };

    final showSync = _matchesSection(
      _SettingsCategory.syncStorage,
      'nextcloud profile sync storage account login version app info custom data dir insecure',
    );
    final showAppearance = _matchesSection(
      _SettingsCategory.appearance,
      'general appearance language locale theme dark light mode platform layout size accent color hyperlegible font simplified home',
    );
    final showGestures = _matchesSection(
      _SettingsCategory.gestures,
      'writing gestures greyscale whiteboard eraser scribble finger drawing stylus pressure curve posture palm straighten shapes',
    );
    final showEditor = _matchesSection(
      _SettingsCategory.editor,
      'editor pen studio ui toolbar fullscreen invert infinite canvas rename recent colors print page indicators performance image size autosave shape recognition straighten lines',
    );
    final showAbout = _matchesSection(
      _SettingsCategory.about,
      'about app info version updates welcome guide logs debug diagnostics sentry license',
    );

    // 1. Bento Card: Cloud & Storage
    final bentoSyncCard = _BentoSectionCard(
      icon: Icons.cloud_sync_outlined,
      title: 'Cloud & Storage',
      badge: stows.username.value.isNotEmpty ? 'Connected' : 'Local Only',
      children: [
        const NextcloudProfile(),
        if (Platform.isAndroid)
          SettingsDirectorySelector(
            title: t.settings.prefLabels.customDataDir,
            icon: Icons.folder,
          ),
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
          SettingsButton(
            title: t.settings.openDataDir,
            icon: Icons.folder_open,
            onPressed: () {
              if (Platform.isWindows) {
                Process.run('explorer', [FileManager.documentsDirectory]);
              } else if (Platform.isLinux) {
                Process.run('xdg-open', [FileManager.documentsDirectory]);
              } else if (Platform.isMacOS) {
                Process.run('open', [FileManager.documentsDirectory]);
              }
            },
          ),
        SettingsSwitch(
          title: t.settings.prefLabels.allowInsecureConnections,
          subtitle: t.settings.prefDescriptions.allowInsecureConnections,
          icon: Icons.private_connectivity,
          pref: stows.allowInsecureConnections,
        ),
      ],
    );

    // 2. Bento Card: Studio Appearance
    final bentoAppearanceCard = _BentoSectionCard(
      icon: Icons.palette_outlined,
      title: t.settings.prefCategories.general,
      children: [
        SettingsDropdown(
          title: t.settings.prefLabels.locale,
          icon: cupertino ? CupertinoIcons.globe : Icons.language,
          pref: stows.locale,
          options: [
            ToggleButtonsOption('', Text(t.settings.systemLanguage)),
            ...AppLocaleUtils.supportedLocales.map((locale) {
              final localeCode = locale.toLanguageTag();
              final localeName = localeNames[localeCode];
              assert(localeName != null, 'Missing locale name for $localeCode');
              return ToggleButtonsOption(
                localeCode,
                Text(localeName ?? localeCode),
              );
            }),
          ],
        ),
        SettingsSelection(
          title: t.settings.prefLabels.appTheme,
          iconBuilder: (i) {
            if (i == ThemeMode.system.index) return Icons.brightness_auto;
            if (i == ThemeMode.light.index) return Icons.light_mode;
            if (i == ThemeMode.dark.index) return Icons.dark_mode;
            return null;
          },
          pref: _SettingsStows.appTheme,
          optionsWidth: 60,
          options: [
            ToggleButtonsOption(
              ThemeMode.system.index,
              Icon(
                Icons.brightness_auto,
                semanticLabel: t.settings.themeModes.system,
              ),
            ),
            ToggleButtonsOption(
              ThemeMode.light.index,
              Icon(
                Icons.light_mode,
                semanticLabel: t.settings.themeModes.light,
              ),
            ),
            ToggleButtonsOption(
              ThemeMode.dark.index,
              Icon(Icons.dark_mode, semanticLabel: t.settings.themeModes.dark),
            ),
          ],
        ),
        SettingsSelection(
          title: t.settings.prefLabels.platform,
          iconBuilder: (i) => switch (stows.platform.value) {
            .iOS || .macOS => Icons.apple,
            .linux => FontAwesomeIcons.ubuntu,
            _ => materialIcon,
          },
          pref: _SettingsStows.platform,
          optionsWidth: 60,
          options: [
            ToggleButtonsOption(() {
              if (usesMaterialByDefault) return defaultTargetPlatform.index;
              return TargetPlatform.android.index;
            }(), UniIcon(materialIcon, semanticLabel: 'Material')),
            ToggleButtonsOption(() {
              if (kDebugMode && stows.platform.value.isCupertino)
                return stows.platform.value.index;
              if (usesCupertinoByDefault) return defaultTargetPlatform.index;
              return TargetPlatform.iOS.index;
            }(), const Icon(Icons.apple, semanticLabel: 'Cupertino')),
            ToggleButtonsOption(() {
              if (usesYaruByDefault) return defaultTargetPlatform.index;
              return TargetPlatform.linux.index;
            }(), const UniIcon(FontAwesomeIcons.ubuntu, semanticLabel: 'Yaru')),
          ],
        ),
        SettingsSelection(
          title: t.settings.prefLabels.layoutSize,
          subtitle: switch (stows.layoutSize.value) {
            .auto => t.settings.layoutSizes.auto,
            .phone => t.settings.layoutSizes.phone,
            .tablet => t.settings.layoutSizes.tablet,
          },
          afterChange: (_) => setState(() {}),
          iconBuilder: (i) => switch (LayoutSize.values[i]) {
            .auto => Icons.aspect_ratio,
            .phone => Icons.smartphone,
            .tablet => Icons.tablet,
          },
          pref: _SettingsStows.layoutSize,
          optionsWidth: 60,
          options: [
            ToggleButtonsOption(
              LayoutSize.auto.index,
              Icon(
                Icons.aspect_ratio,
                semanticLabel: t.settings.layoutSizes.auto,
              ),
            ),
            ToggleButtonsOption(
              LayoutSize.phone.index,
              Icon(
                Icons.smartphone,
                semanticLabel: t.settings.layoutSizes.phone,
              ),
            ),
            ToggleButtonsOption(
              LayoutSize.tablet.index,
              Icon(Icons.tablet, semanticLabel: t.settings.layoutSizes.tablet),
            ),
          ],
        ),
        SettingsColor(
          title: t.settings.prefLabels.customAccentColor,
          icon: Icons.colorize,
          pref: stows.accentColor,
        ),
        SettingsSwitch(
          title: t.settings.prefLabels.hyperlegibleFont,
          subtitle: t.settings.prefDescriptions.hyperlegibleFont,
          iconBuilder: (b) {
            if (b)
              return cupertino
                  ? CupertinoIcons.textformat
                  : Icons.font_download;
            return cupertino
                ? CupertinoIcons.textformat_alt
                : Icons.font_download_off;
          },
          pref: stows.hyperlegibleFont,
        ),
      ],
    );

    // 3. Bento Card: Editor & Pen Studio
    final bentoEditorCard = _BentoSectionCard(
      icon: Icons.edit_note_rounded,
      title: t.settings.prefCategories.editor,
      children: [
        SettingsSwitch(
          title: 'Opennote Studio UI',
          subtitle:
              'Dual-tier contextual toolbar, document header bar, and 3D notebook covers',
          icon: Icons.auto_stories_rounded,
          pref: stows.opennoteUiMode,
        ),
        SettingsSelection(
          title: t.settings.prefLabels.editorToolbarAlignment,
          subtitle: t
              .settings
              .axisDirections[_SettingsStows.editorToolbarAlignment.value],
          iconBuilder: (num i) {
            if (i is! int || i >= materialDirectionIcons.length) return null;
            return cupertino
                ? cupertinoDirectionIcons[i]
                : materialDirectionIcons[i];
          },
          pref: _SettingsStows.editorToolbarAlignment,
          optionsWidth: 60,
          options: [
            for (final AxisDirection direction in AxisDirection.values)
              ToggleButtonsOption(
                direction.index,
                Icon(
                  cupertino
                      ? cupertinoDirectionIcons[direction.index]
                      : materialDirectionIcons[direction.index],
                  semanticLabel: t.settings.axisDirections[direction.index],
                ),
              ),
          ],
          afterChange: (_) => setState(() {}),
        ),
        SettingsSwitch(
          title: t.settings.prefLabels.editorToolbarShowInFullscreen,
          icon: cupertino ? CupertinoIcons.fullscreen : Icons.fullscreen,
          pref: stows.editorToolbarShowInFullscreen,
        ),
        SettingsSwitch(
          title: t.settings.prefLabels.editorAutoInvert,
          iconBuilder: (b) {
            return b ? Icons.invert_colors_on : Icons.invert_colors_off;
          },
          pref: stows.editorAutoInvert,
        ),
        SettingsSwitch(
          title: t.settings.prefLabels.defaultInfiniteCanvas,
          subtitle: t.settings.prefDescriptions.defaultInfiniteCanvas,
          icon: Icons.all_inclusive_rounded,
          pref: stows.defaultInfiniteCanvas,
        ),
        SettingsSwitch(
          title: t.settings.prefLabels.editorPromptRename,
          subtitle: t.settings.prefDescriptions.editorPromptRename,
          iconBuilder: (b) {
            if (b) return cupertino ? CupertinoIcons.keyboard : Icons.keyboard;
            return cupertino
                ? CupertinoIcons.keyboard_chevron_compact_down
                : Icons.keyboard_hide;
          },
          pref: stows.editorPromptRename,
        ),
        SettingsSwitch(
          title: t.settings.prefLabels.recentColorsDontSavePresets,
          icon: Icons.palette,
          pref: stows.recentColorsDontSavePresets,
        ),
        SettingsSelection(
          title: t.settings.prefLabels.recentColorsLength,
          icon: Icons.history,
          pref: stows.recentColorsLength,
          options: const [
            ToggleButtonsOption(5, Text('5')),
            ToggleButtonsOption(10, Text('10')),
          ],
        ),
        SettingsSwitch(
          title: t.settings.prefLabels.printPageIndicators,
          subtitle: t.settings.prefDescriptions.printPageIndicators,
          icon: Icons.numbers,
          pref: stows.printPageIndicators,
        ),
        SettingsSelection(
          title: t.settings.prefLabels.maxImageSize,
          subtitle: t.settings.prefDescriptions.maxImageSize,
          icon: Icons.photo_size_select_large,
          pref: stows.maxImageSize,
          options: const <ToggleButtonsOption<double>>[
            ToggleButtonsOption(500, Text('500')),
            ToggleButtonsOption(1000, Text('1000')),
            ToggleButtonsOption(2000, Text('2000')),
          ],
        ),
        SettingsSelection(
          title: t.settings.prefLabels.autosave,
          subtitle: t.settings.prefDescriptions.autosave,
          icon: Icons.save,
          pref: stows.autosaveDelay,
          options: [
            const ToggleButtonsOption(5000, Text('5s')),
            const ToggleButtonsOption(10000, Text('10s')),
            ToggleButtonsOption(-1, Text(t.settings.autosaveDisabled)),
          ],
        ),
        SettingsSwitch(
          title: t.settings.prefLabels.simplifiedHomeLayout,
          subtitle: t.settings.prefDescriptions.simplifiedHomeLayout,
          iconBuilder: (simplified) =>
              simplified ? Icons.grid_view : Symbols.browse,
          pref: stows.simplifiedHomeLayout,
        ),
      ],
    );

    // 4. Bento Card: Smart Gestures & Stylus
    final bentoGesturesCard = _BentoSectionCard(
      icon: Icons.gesture_rounded,
      title: t.settings.prefCategories.writing,
      children: [
        SettingsSwitch(
          title: t.settings.prefLabels.preferGreyscale,
          subtitle: t.settings.prefDescriptions.preferGreyscale,
          iconBuilder: (b) {
            return b ? Icons.monochrome_photos : Icons.enhance_photo_translate;
          },
          pref: stows.preferGreyscale,
        ),
        SettingsSwitch(
          title: t.settings.prefLabels.autoClearWhiteboardOnExit,
          subtitle: t.settings.prefDescriptions.autoClearWhiteboardOnExit,
          icon: Icons.cleaning_services,
          pref: stows.autoClearWhiteboardOnExit,
        ),
        SettingsSwitch(
          title: t.settings.prefLabels.disableEraserAfterUse,
          subtitle: t.settings.prefDescriptions.disableEraserAfterUse,
          icon: FontAwesomeIcons.eraser,
          pref: stows.disableEraserAfterUse,
        ),
        SettingsSwitch(
          title: t.settings.prefLabels.scribbleToErase,
          subtitle: t.settings.prefDescriptions.scribbleToErase,
          icon: FontAwesomeIcons.eraser,
          pref: stows.scribbleToErase,
        ),
        ValueListenableBuilder(
          valueListenable: stows.hideFingerDrawingToggle,
          builder: (context, _, _) {
            return SettingsSwitch(
              title: t.settings.prefLabels.hideFingerDrawingToggle,
              subtitle: () {
                if (!stows.hideFingerDrawingToggle.value) {
                  return t.settings.prefDescriptions.hideFingerDrawing.shown;
                } else if (stows.editorFingerDrawing.value) {
                  return t.settings.prefDescriptions.hideFingerDrawing.fixedOn;
                } else {
                  return t.settings.prefDescriptions.hideFingerDrawing.fixedOff;
                }
              }(),
              icon: CupertinoIcons.hand_draw_fill,
              pref: stows.hideFingerDrawingToggle,
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: stows.hideFingerDrawingToggle,
          builder: (context, hideFingerDrawing, _) {
            return Collapsible(
              collapsed: hideFingerDrawing,
              axis: CollapsibleAxis.vertical,
              child: SettingsSwitch(
                title: t
                    .settings
                    .prefLabels
                    .autoDisableFingerDrawingWhenStylusDetected,
                subtitle: t
                    .settings
                    .prefDescriptions
                    .autoDisableFingerDrawingWhenStylusDetected,
                icon: CupertinoIcons.pencil,
                pref: stows.autoDisableFingerDrawingWhenStylusDetected,
              ),
            );
          },
        ),
        SettingsSelection(
          title: t.settings.prefLabels.shapeRecognitionDelay,
          subtitle: t.settings.prefDescriptions.shapeRecognitionDelay,
          icon: FontAwesomeIcons.shapes,
          pref: stows.shapeRecognitionDelay,
          options: [
            const ToggleButtonsOption(500, Text('0.5s')),
            const ToggleButtonsOption(1000, Text('1s')),
            ToggleButtonsOption(-1, Text(t.settings.shapeRecognitionDisabled)),
          ],
          afterChange: (ms) {
            ShapePen.debounceDuration = ShapePen.getDebounceFromPref();
          },
        ),
        SettingsSwitch(
          title: t.settings.prefLabels.autoStraightenLines,
          subtitle: t.settings.prefDescriptions.autoStraightenLines,
          icon: Icons.straighten,
          pref: stows.autoStraightenLines,
        ),
        _PressureCurveSetting(),
        const Divider(),
        const WritingPostureSelector(),
      ],
    );

    // 5. Bento Card: About & Diagnostics
    final bentoAboutCard = _BentoSectionCard(
      icon: Icons.info_outline_rounded,
      title: 'About & Diagnostics',
      children: [
        const Padding(padding: EdgeInsets.all(8), child: AppInfo()),
        if (isSentryAvailable) const SettingsSentryConsent(),
        if (requiresManualUpdates ||
            stows.shouldCheckForUpdates.value !=
                stows.shouldCheckForUpdates.defaultValue) ...[
          SettingsSwitch(
            title: t.settings.prefLabels.shouldCheckForUpdates,
            icon: Icons.system_update,
            pref: stows.shouldCheckForUpdates,
            afterChange: (_) => setState(() {}),
          ),
          Collapsible(
            collapsed: !stows.shouldCheckForUpdates.value,
            axis: CollapsibleAxis.vertical,
            child: SettingsSwitch(
              title: t.settings.prefLabels.shouldAlwaysAlertForUpdates,
              subtitle: t.settings.prefDescriptions.shouldAlwaysAlertForUpdates,
              icon: Icons.system_security_update_warning,
              pref: stows.shouldAlwaysAlertForUpdates,
            ),
          ),
        ],
        SettingsButton(
          title: t.settings.prefLabels.welcomeGuide,
          subtitle: t.settings.prefDescriptions.welcomeGuide,
          icon: Icons.school_outlined,
          onPressed: () => WelcomeOnboardingDialog.show(context),
        ),
        SettingsButton(
          title: t.logs.viewLogs,
          subtitle: t.logs.debuggingInfo,
          icon: Icons.receipt_long,
          onPressed: () => context.push(RoutePaths.logs),
        ),
      ],
    );

    final cards = [
      if (showSync) bentoSyncCard,
      if (showAppearance) bentoAppearanceCard,
      if (showEditor) bentoEditorCard,
      if (showGestures) bentoGesturesCard,
      if (showAbout) bentoAboutCard,
    ];

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            // Left Category Rail (220px wide)
            SizedBox(
              width: 220,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
                  border: BorderDirectional(
                    end: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  right: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          t.home.titles.settings,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        child: TextField(
                          key: const ValueKey('settings-search-field'),
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: t.home.search.hint,
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 18,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            isDense: true,
                            filled: true,
                            fillColor: colorScheme.surfaceContainer,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          children: [
                            for (final category in _SettingsCategory.values)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Material(
                                  color: _selectedCategory == category
                                      ? colorScheme.primary.withValues(
                                          alpha: 0.14,
                                        )
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    OpennoteTokens.radiusSm,
                                  ),
                                  child: InkWell(
                                    key: ValueKey(
                                      'settings-category-${category.name}',
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      OpennoteTokens.radiusSm,
                                    ),
                                    onTap: () => setState(
                                      () => _selectedCategory = category,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            category.icon,
                                            size: 18,
                                            color: _selectedCategory == category
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              category.label,
                                              style: TextStyle(
                                                fontWeight:
                                                    _selectedCategory ==
                                                        category
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                fontSize: 13,
                                                color:
                                                    _selectedCategory ==
                                                        category
                                                    ? colorScheme.primary
                                                    : colorScheme.onSurface,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Right Detail Pane: Bento Cards Scroll View
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Text(
                      _selectedCategory.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    pinned: true,
                    scrolledUnderElevation: 0.5,
                    surfaceTintColor: Colors.transparent,
                    shape: Border(
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.25,
                        ),
                        width: 1,
                      ),
                    ),
                    actions: [
                      if (UpdateManager.status.value != .upToDate)
                        IconButton(
                          tooltip: t.home.tooltips.showUpdateDialog,
                          icon: const Icon(Icons.system_update),
                          onPressed: () {
                            UpdateManager.showUpdateDialog(
                              context,
                              userTriggered: true,
                            );
                          },
                        ),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    sliver: SliverList.list(children: cards),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            collapsedHeight: 56,
            expandedHeight: 88,
            pinned: true,
            scrolledUnderElevation: 0.5,
            surfaceTintColor: Colors.transparent,
            shape: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                t.home.titles.settings,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsetsDirectional.only(
                start: 20,
                bottom: 12,
              ),
            ),
            actions: [
              if (UpdateManager.status.value != .upToDate)
                IconButton(
                  tooltip: t.home.tooltips.showUpdateDialog,
                  icon: const Icon(Icons.system_update),
                  onPressed: () {
                    UpdateManager.showUpdateDialog(
                      context,
                      userTriggered: true,
                    );
                  },
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    key: const ValueKey('settings-search-field'),
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: t.home.search.hint,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.45,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final category in _SettingsCategory.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              key: ValueKey(
                                'settings-category-${category.name}',
                              ),
                              avatar: Icon(category.icon, size: 16),
                              label: Text(category.label),
                              selected: _selectedCategory == category,
                              onSelected: (_) {
                                setState(() => _selectedCategory = category);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverSafeArea(top: false, sliver: SliverList.list(children: cards)),
        ],
      ),
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

class _BentoSectionCard extends StatelessWidget {
  const _BentoSectionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.badge,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.of(context);
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: isDark
            ? OpennoteTokens.cardDarkSurface
            : OpennoteTokens.cardLightSurface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(
                          alpha: isDark ? 0.25 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(
                          OpennoteTokens.radiusSm,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(icon, size: 18, color: colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (badge != null)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer.withValues(
                            alpha: 0.6,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Section Body
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
