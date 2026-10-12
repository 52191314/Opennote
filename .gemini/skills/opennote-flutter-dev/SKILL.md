---
name: opennote-flutter-dev
description: >-
  Workflows for Opennote Flutter development: pinned submodule setup, shallow clone tag
  restoration, running tests without pub, Windows vs Linux test baselines, and PR review invariants.
---

# Opennote Flutter Development & Review Runbook

## 1. Pinned Flutter Submodule Initialization
The workstation does not have a global Flutter SDK configured on PATH for Opennote. The repo pins Flutter as `submodules/flutter` (3.44.4).

1. Initialize submodule:
   `git submodule update --init --depth 1 submodules/flutter`
   *(Reports "Filename too long" for 5 golden images; safely ignore)*
2. Restore version tag (shallow clones lack tags, causing version `0.0.0-unknown` pub failures):
   `git -C submodules/flutter fetch --depth 1 origin refs/tags/3.44.4:refs/tags/3.44.4`
   `Remove-Item submodules/flutter/bin/cache/flutter.version.json -Force -ErrorAction SilentlyContinue`
3. Fetch dependencies:
   `submodules\flutter\bin\flutter.bat pub get`
   *(Symlink support warning on non-developer-mode Windows is harmless)*

## 2. Running Local Verification Suites
- Unit and widget tests: `submodules\flutter\bin\flutter.bat test --no-pub`
- Static analysis: `submodules\flutter\bin\flutter.bat analyze --no-pub`
- Code formatting: `dart format lib packages scripts test --output none --set-exit-if-changed`

### Windows-Specific Test Baseline Discrepancies
Six tests fail on Windows due to platform path/line-ending differences but pass on Linux CI. Do not treat these as regressions:
- `fm_write_stream_test`
- `glassy_container_test`
- `packaging_pipeline_test` (Info.plist)
- `login_golden_test`
- `version_test`
- `sbn_test`

## 3. Pull Request & Branch Policies
- `main` branch is protected by GitHub Ruleset 19132035: requires 1 approving review from another account.
- **Invariant**: Never run `gh pr merge --admin` unless explicitly commanded by the user. Land work on a feature branch (`feat/*`), open a PR into `main`, ensure checks pass, and leave approval to the repository owner.
