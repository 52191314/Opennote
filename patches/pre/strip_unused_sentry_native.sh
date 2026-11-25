#!/usr/bin/env bash
# Strips native Sentry SDK packages in CI release builds when Sentry is unconfigured.
set -euo pipefail

if [ -f "lib/data/sentry/sentry_init.dart" ] && grep -q "const isSentryConfigured = false;" "lib/data/sentry/sentry_init.dart"; then
  echo "Sentry is unconfigured; stripping unused native Sentry SDK from build..."
  cp "lib/data/sentry/_sentry_init_foss.dart" "lib/data/sentry/sentry_init.dart"
  rm -f "lib/data/sentry/sentry_filter.dart"
  grep -v -E "^[[:space:]]*(sentry_flutter|sentry_logging|sentry_dart_plugin):" pubspec.yaml > pubspec.yaml.tmp
  mv pubspec.yaml.tmp pubspec.yaml
else
  echo "Sentry is configured or already stripped; skipping."
fi
