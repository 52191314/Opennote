/// 🤖 Generated wholely or partially with Claude Code (Claude Opus 5.5)
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:saber/data/sentry/sentry_init.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

const _upstreamSentryOrganization = 'o4509780708229120';

void main() {
  test(
    "Crash reporting is not offered while the Sentry project is upstream's",
    () {
      final options = SentryFlutterOptions();
      populateSentryOptions(options);
      final reportsToSaber = options.dsn!.contains(_upstreamSentryOrganization);

      expect(
        isSentryConfigured && reportsToSaber,
        isFalse,
        reason:
            'Opennote crashes must not be sent to the Saber maintainers. '
            'Set an Opennote DSN before turning isSentryConfigured on.',
      );
    },
  );
}
