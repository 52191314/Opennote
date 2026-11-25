/// 🤖 Modified with Claude Code (Claude Opus 5.5); Google Antigravity
/// 🤖 Generated wholely or partially with Gemini 4 Neon (Medium); Google Antigravity
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saber/components/settings/update_manager.dart';
import 'package:saber/data/flavor_config.dart';
import 'package:saber/data/is_this_a_test.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/version.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays Opennote's version metadata and opens the branded About dialog.
class AppInfo extends StatelessWidget {
  const AppInfo({super.key});

  static final Uri sponsorUrl = Uri.parse(
    'https://github.com/${UpdateManager.repository}',
  );
  static final Uri privacyPolicyUrl = Uri.parse(
    'https://52191314.github.io/Opennote/',
  );
  static final Uri licenseUrl = Uri.parse(
    'https://github.com/${UpdateManager.repository}/blob/main/LICENSE.md',
  );
  static final Uri releasesUrl = Uri.parse(
    'https://github.com/${UpdateManager.repository}/releases',
  );
  static final Uri appStoreUrl = Uri.parse(
    'https://apps.apple.com/app/opennote',
  );
  static final Uri playStoreUrl = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.opennote.app',
  );
  static const shareText =
      'Check out Opennote — precision digital notebook & engineering diagram studio! https://52191314.github.io/Opennote/';

  static String get info => [
    // Tests use static values to improve reducibility
    if (isThisATest) 'v1.33.3' else 'v$buildName',
    if (FlavorConfig.flavor.isNotEmpty) FlavorConfig.flavor,
    if (kDebugMode && !isThisATest) t.appInfo.debug,
    if (isThisATest) '(133030)' else '($buildNumber)',
  ].join(' ');

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      leading: SvgPicture.asset('assets/icon/icon.svg', width: 28, height: 28),
      title: const Text('Opennote', style: TextStyle(fontSize: 18)),
      subtitle: ValueListenableBuilder(
        valueListenable: stows.locale,
        builder: (context, _, _) =>
            Text(info, style: const TextStyle(fontSize: 13)),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showAboutDialog(context),
    );
  }

  void _showAboutDialog(BuildContext context) => showAboutDialog(
    context: context,
    applicationName: 'Opennote',
    applicationVersion: info,
    applicationIcon: SvgPicture.asset(
      'assets/icon/icon.svg',
      width: 50,
      height: 50,
    ),
    applicationLegalese:
        '© $buildYear Opennote Contributors · Open-source under GPLv3',
    children: [
      const SizedBox(height: 10),
      if (!Platform.isIOS)
        // Apple rejected apps linking to external donations outside the App Store.
        TextButton(
          onPressed: () => launchUrl(sponsorUrl),
          child: const SizedBox(
            width: double.infinity,
            child: Text('Opennote on GitHub'),
          ),
        ),
      TextButton(
        onPressed: () => launchUrl(licenseUrl),
        child: SizedBox(
          width: double.infinity,
          child: Text(t.appInfo.licenseButton),
        ),
      ),
      TextButton(
        onPressed: () => launchUrl(privacyPolicyUrl),
        child: SizedBox(
          width: double.infinity,
          child: Text(t.appInfo.privacyPolicyButton),
        ),
      ),
    ],
  );
}
