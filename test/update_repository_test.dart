/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:saber/components/settings/app_info.dart';
import 'package:saber/components/settings/update_manager.dart';

const _upstreamRepository = 'saber-notes/saber';

void main() {
  group('Update checks', () {
    final urls = {
      'version file': UpdateManager.versionUrl,
      'latest release': UpdateManager.apiUrl,
      'changelog': UpdateManager.changelogUrl(
        localeCode: 'en-US',
        version: 134030,
      ),
      'releases page': AppInfo.releasesUrl,
    };

    for (final MapEntry(key: name, value: url) in urls.entries) {
      test('the $name comes from Opennote, not upstream Saber', () {
        expect(url.toString(), contains(UpdateManager.repository));
        expect(url.toString(), isNot(contains(_upstreamRepository)));
      });
    }

    test('the repository is Opennote', () {
      expect(UpdateManager.repository, '52191314/Opennote');
    });
  });
}
