/// 🤖 Generated wholely or partially with Google Antigravity
library;

import 'dart:io';

import 'package:collapsible/collapsible.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import 'package:saber/components/settings/writing_posture_selector.dart';
import 'package:saber/components/theming/adaptive_toggle_buttons.dart';
import 'package:saber/components/theming/saber_theme.dart';
import 'package:saber/data/locales.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/data/sentry/sentry_init.dart';
import 'package:saber/data/tools/shape_pen.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/home/settings/bento_section_card.dart';
import 'package:saber/pages/home/settings/pressure_curve_setting.dart';
import 'package:saber/pages/home/settings/settings_stows.dart';

const _cupertinoDirectionIcons = [
  CupertinoIcons.arrow_up_to_line,
  CupertinoIcons.arrow_right_to_line,
  CupertinoIcons.arrow_down_to_line,
  CupertinoIcons.arrow_left_to_line,
];

const _materialDirectionIcons = [
  Icons.north,
  Icons.east,
  Icons.south,
  Icons.west,
];

/// Builds the Cloud & Storage Bento card.
Widget buildSyncSettingsCard() {
  return BentoSectionCard(
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
      SettingsSwitch(
        title: t.settings.prefLabels.allowInsecureConnections,
        subtitle: t.settings.prefDescriptions.allowInsecureConnections,
        icon: Icons.private_connectivity,
        pref: stows.allowInsecureConnections,
      ),
    ],
  );
}

/// Builds the Studio Appearance Bento card.
Widget buildAppearanceSettingsCard({
  required bool cupertino,
  required bool usesMaterialByDefault,
  required bool usesCupertinoByDefault,
  required VoidCallback onStateChanged,
}) {
  const materialIcon = Icons.android;

  return BentoSectionCard(
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
        pref: SettingsStows.appTheme,
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
            Icon(Icons.light_mode, semanticLabel: t.settings.themeModes.light),
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
          _ => materialIcon,
        },
        pref: SettingsStows.platform,
        optionsWidth: 60,
        options: [
          ToggleButtonsOption(() {
            if (usesMaterialByDefault) return defaultTargetPlatform.index;
            return TargetPlatform.android.index;
          }(), const Icon(materialIcon, semanticLabel: 'Material')),
          ToggleButtonsOption(() {
            if (kDebugMode && stows.platform.value.isCupertino)
              return stows.platform.value.index;
            if (usesCupertinoByDefault) return defaultTargetPlatform.index;
            return TargetPlatform.iOS.index;
          }(), const Icon(Icons.apple, semanticLabel: 'Cupertino')),
        ],
      ),
      SettingsSelection(
        title: t.settings.prefLabels.layoutSize,
        subtitle: switch (stows.layoutSize.value) {
          .auto => t.settings.layoutSizes.auto,
          .phone => t.settings.layoutSizes.phone,
          .tablet => t.settings.layoutSizes.tablet,
        },
        afterChange: (_) => onStateChanged(),
        iconBuilder: (i) => switch (LayoutSize.values[i]) {
          .auto => Icons.aspect_ratio,
          .phone => Icons.smartphone,
          .tablet => Icons.tablet,
        },
        pref: SettingsStows.layoutSize,
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
            Icon(Icons.smartphone, semanticLabel: t.settings.layoutSizes.phone),
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
            return cupertino ? CupertinoIcons.textformat : Icons.font_download;
          return cupertino
              ? CupertinoIcons.textformat_alt
              : Icons.font_download_off;
        },
        pref: stows.hyperlegibleFont,
      ),
    ],
  );
}

/// Builds the Editor & Pen Studio Bento card.
Widget buildEditorSettingsCard({
  required bool cupertino,
  required VoidCallback onStateChanged,
}) {
  return BentoSectionCard(
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
            .axisDirections[SettingsStows.editorToolbarAlignment.value],
        iconBuilder: (num i) {
          if (i is! int || i >= _materialDirectionIcons.length) return null;
          return cupertino
              ? _cupertinoDirectionIcons[i]
              : _materialDirectionIcons[i];
        },
        pref: SettingsStows.editorToolbarAlignment,
        optionsWidth: 60,
        options: [
          for (final AxisDirection direction in AxisDirection.values)
            ToggleButtonsOption(
              direction.index,
              Icon(
                cupertino
                    ? _cupertinoDirectionIcons[direction.index]
                    : _materialDirectionIcons[direction.index],
                semanticLabel: t.settings.axisDirections[direction.index],
              ),
            ),
        ],
        afterChange: (_) => onStateChanged(),
      ),
      SettingsSwitch(
        title: t.settings.prefLabels.editorToolbarShowInFullscreen,
        icon: cupertino ? CupertinoIcons.fullscreen : Icons.fullscreen,
        pref: stows.editorToolbarShowInFullscreen,
      ),
      SettingsSwitch(
        title: t.settings.prefLabels.editorAutoInvert,
        iconBuilder: (b) =>
            b ? Icons.invert_colors_on : Icons.invert_colors_off,
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
            simplified ? Icons.grid_view : Icons.dashboard_rounded,
        pref: stows.simplifiedHomeLayout,
      ),
    ],
  );
}

/// Builds the Smart Gestures & Stylus Bento card.
Widget buildGesturesSettingsCard() {
  return BentoSectionCard(
    icon: Icons.gesture_rounded,
    title: t.settings.prefCategories.writing,
    children: [
      SettingsSwitch(
        title: t.settings.prefLabels.preferGreyscale,
        subtitle: t.settings.prefDescriptions.preferGreyscale,
        iconBuilder: (b) =>
            b ? Icons.monochrome_photos : Icons.enhance_photo_translate,
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
        icon: Icons.auto_fix_normal_rounded,
        pref: stows.disableEraserAfterUse,
      ),
      SettingsSwitch(
        title: t.settings.prefLabels.scribbleToErase,
        subtitle: t.settings.prefDescriptions.scribbleToErase,
        icon: Icons.auto_fix_normal_rounded,
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
        icon: Icons.category_rounded,
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
      const PressureCurveSetting(),
      const Divider(),
      const WritingPostureSelector(),
    ],
  );
}

/// Builds the About & Diagnostics Bento card.
Widget buildAboutSettingsCard({
  required BuildContext context,
  required bool requiresManualUpdates,
  required VoidCallback onStateChanged,
}) {
  return BentoSectionCard(
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
          afterChange: (_) => onStateChanged(),
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
}
