# Opennote Audit 03 — Sync, Data, Export, Localization & Native Platform Readiness

> **Scope**: Read-only audit of `lib/data/sync/**`, `lib/data/nextcloud/**`, `lib/data/codecs/**`, `lib/data/clipboard/**`, `lib/data/shortcuts/**`, `lib/data/sentry/**`, `lib/i18n/**`, `packages/**`, `ios/**`, `android/**`, `pubspec.yaml`, plus directly coupled export/import/startup entrypoints (`lib/data/editor/editor_exporter.dart`, `lib/data/editor/editor_core_info.dart`, `lib/data/file_manager/file_manager.dart`, `lib/data/file_manager/file_manager_transfer.dart`, `lib/main.dart`, `lib/pages/editor/editor_media_import.dart`, `lib/components/home/export_note_button.dart`).

---

## Executive Summary

| Domain | Maturity (1–5) | Verdict | Top Blocker |
| --- | :---: | --- | --- |
| **1. Sync & Cloud Architecture** | **2.0** | Functional WebDAV prototype, broken background sync, severe crypto flaw, dead CRDT | Unwired CRDT (`lib/data/sync/crdt/*`); AES static IV + unused `stows.key`; `doBackgroundSync()` hangs indefinitely (`lib/main.dart:192-226`) |
| **2. File Format & Export Pipeline** | **3.0** | Solid BSON `.sbn2`/`.sba` core; PDF/PNG export has OOM, resolution cap, and Android 13+ gallery breakage | Android 13+ gallery save broken (`AndroidManifest.xml:13` removes `READ_MEDIA_IMAGES` while `file_manager_transfer.dart:59-63` requests it); PNG capped at 1x (`editor_media_import.dart:504`); PDF screenshots all pages into RAM simultaneously |
| **3. Shortcuts, Clipboard, Sentry & i18n** | **3.2** | Clean zero-dep `MobileKeybinder` & native image clipboard; Sentry safely gated off; severe i18n debt & Saber leaks | **445 "Saber" string leaks** across 25 `*.i18n.yaml` files; **776 missing/outdated translations** across 14 locales; `SentryFilter.beforeSend` only scrubs `event.message` |
| **4. Native iOS & Android Platform** | **2.5** | Impeller + 120Hz + clipboard wired; not ready for App Store / Play Store IAP or deep links | Missing `NSPhotoLibraryAddUsageDescription`, `CFBundleDocumentTypes`, `Runner.entitlements`; iOS deployment target `14.0` blocks StoreKit 2 (`15.0+`); `LaunchImage.png` is 1×1 px; `android/fallback-key.jks` + plaintext password committed to Git; `com.woaiyj1314.opennote` package ID |

---

## 1. Sync & Cloud Architecture

### 1.1 What Exists & What Works
- **WebDAV Sync Engine (`lib/data/nextcloud/saber_syncer.dart`)**: Uses `abstract_sync` (`Syncer<SaberSyncInterface, SaberSyncFile, File, WebDavFile>`) over Nextcloud WebDAV (`propfind`, `get`, `put`, `mkcol`).
- **Path & Preview Prioritization**: Preview thumbnails (`.sbn2.p`) are reordered ahead of full notes (`.sbn2`) in `findRemoteChanges()` (`saber_syncer.dart:110-135`), improving perceived home-screen load speed.
- **Worker-Isolate Crypto Offloading**: Encryption/decryption runs on `workerManager` isolates (`saber_syncer.dart:225, 270, 405, 446`), preventing UI jank during sync.
- **Login Flow V2 (`lib/data/nextcloud/login_flow.dart`)**: Uses `FlutterWebAuth2` with callback scheme `nc` and 1-second polling (`login_flow.dart:36-68`).
- **Self-Signed Cert Support (`lib/data/nextcloud/nc_http_overrides.dart`)**: Scoped to `stows.url` host or `temporarilyExemptHost` when `stows.allowInsecureConnections` is enabled.

### 1.2 Critical Bugs, Security Flaws & Architectural Gaps

1. **[P0 — Cryptography] Static IV Reuse + Unused Random Key (`lib/data/nextcloud/nextcloud_client_extension.dart:37, 94-99, 135-164`)**
   - `loadEncryptionKey()` generates a random 32-byte `Key` and 16-byte `IV`, encrypts `key.base64` into `config.sbc`, and stores it in `stows.key.value`.
   - **Bug**: `client.encrypter` (`nextcloud_client_extension.dart:157-164`) **never reads `stows.key.value`**. It derives the AES key via single-pass `sha256(encPassword + '8MnPs64@R&mF8XjWeLrD')` (no PBKDF2/Argon2/scrypt) and passes it to `Encrypter(AES(passwordKey))` — which defaults to **AES-SIC (CTR mode)** in `package:encrypt`.
   - Every single note file and every encrypted filename (`saber_syncer.dart:223, 268, 403, 444`) reuses the **exact same `stows.iv.value`**. In AES-CTR, key+IV reuse breaks confidentiality (XOR of two ciphertexts exposes XOR of plaintexts).
2. **[P0 — Broken Background Sync] `doBackgroundSync()` Never Triggers Sync & Hangs Forever (`lib/main.dart:192-226`)**
   - `doBackgroundSync()` initializes `FileManager` and `workerManager`, subscribes to `syncer.downloader.transferStream`, and awaits `completer.future`, **without ever calling `syncer.downloader.refresh()` or `syncer.uploader.refresh()`**, without loading `stows.username`/`stows.encPassword`, and without setting `HttpOverrides.global = NcHttpOverrides()`.
   - Result: Background sync tasks hang until killed by Android WorkManager / iOS BGTask timeout.
3. **[P0 — Dead Code] CRDT Engine Is Completely Unwired (`lib/data/sync/crdt/`)**
   - `CrdtDocument` (`crdt_document.dart`), `CrdtOperation` (`crdt_operation.dart`), and `CrdtStateVector` (`crdt_state_vector.dart`) are **only referenced in `test/opennote_canvas_features_test.dart`** and nowhere in `lib/`.
   - Additional CRDT design gaps before wiring: `addPage`/`deletePage` are no-ops (`crdt_document.dart:159-161`); `_log` grows unbounded with no compaction/snapshots; no persistence format; `reconstructPageStrokes` silently swallows exceptions (`crdt_document.dart:194-196`); no support for Quill text, images, layers, or page metadata.
4. **[P1 — Silent Data Loss] Conflict Resolution Is Pure Timestamp LWW (`lib/data/nextcloud/saber_syncer.dart:467-510`)**
   - `getBestFile()` compares `lastModifiedRemote` vs `lastModifiedLocal` with a 500ms tolerance. Editing the same note offline on two devices silently overwrites the older save with zero conflict copy or merge warning.
   - `findLocalChanges()` (`saber_syncer.dart:40-43`) polls `remoteFiles.isEmpty` with a brittle 2-second busy-wait (`10 * 200ms`) hoping `findRemoteChanges()` finishes first.
5. **[P1 — Uncaught Auth Failure & Config File Bug] (`lib/data/nextcloud/saber_syncer.dart:175-185, 205-216`)**
   - Line 178: `_client!.loadEncryptionKey(generateKeyIfMissing: false);` is **missing `await`**, so `on EncLoginFailure` (line 179) will never catch an async throw.
   - Line 205: `if (file.localFile.path == NextcloudClientExtension.configFileName)` compares full absolute path against `'config.sbc'` (unlike `.endsWith` at line 175), so it falls through to `if (encryptedBytes.isEmpty)` (line 210) and attempts `FileManager.deleteFile('/config.sbc')`.
6. **[P2 — Crash / Branding]**
   - `lib/data/codecs/quota_codec.dart:23`: `used / total * 100` produces `NaN`/`Infinity` when `total == 0` (e.g., unlimited Nextcloud quota).
   - `nextcloud_client_extension.dart:18`: Hardcoded default server `https://nc.saber.adil.hanney.org` (upstream maintainer's server — Opennote users must not hit this!).
   - `nextcloud_client_extension.dart:22`: User-Agent `'Saber/$buildName'`.
   - `saber_syncer.dart:23`: Fixed 4-second `failureTimeout` with no exponential backoff or offline queue persistence across restarts.

### 1.3 Consumer UX Friction vs. Technical Users & Opennote Pro Positioning
- **Why normal consumers bounce**:
  - Nextcloud + "Two passwords (Nextcloud password + separate Encryption Password)" + "Self-hosted server URL" is intimidating and opaque to students/engineers who expect 1-tap Apple/Google Sign-In or iCloud/Google Drive sync.
  - Zero visibility into sync status per note, no conflict recovery UI, and warning that forgetting the encryption password permanently destroys cloud notes (`en.i18n.yaml:249`).
- **Opennote Pro Cloud Sync & Backup Positioning**:
  - **Free Tier**: Local-first unlimited notes + manual `.sba` backup/restore + BYO Nextcloud/WebDAV (preserving open-source trust for technical users).
  - **Opennote Pro ("Opennote Cloud")**:
    1. **Zero-Config Managed Sync** (1-tap Sign in with Apple/Google, iCloud Drive / S3-backed E2EE with Recovery Key QR/passphrase using Argon2id + AES-256-GCM with per-file random nonces).
    2. **Auto-Backup to Google Drive / OneDrive / Dropbox** as searchable PDFs + `.sba` snapshots (huge student/engineer conversion hook, proven by GoodNotes/Notability).
    3. **Version History & Conflict Snapshots** (30-day restore + side-by-side conflict resolution, powered by wiring `CrdtDocument` or delta snapshots).

---

## 2. File Format & Export Pipeline

### 2.1 Format Architecture (`.sbn` / `.sbn2` / `.sba`)
- **`.sbn2`** (`lib/data/file_manager/note_paths.dart:9`, `lib/data/editor/editor_core_info.dart:56`): BSON binary v19 with sidecar asset files (`note.sbn2.0`, `note.sbn2.1`, preview `note.sbn2.p`). Fast, compact, forward-version-checked.
- **`.sbn`** (`note_paths.dart:14`): Legacy JSON format, read-compatible via `EditorCoreInfo.fromOldJson`.
- **`.sba`** (`editor_core_info.dart:511-530`, `file_manager_transfer.dart:89-142`): ZIP bundle containing `main.sbn2` + `main.sbn2.<N>` assets. Solid portable archive format.
- **Packages**:
  - `packages/sbn` (`packages/sbn/pubspec.yaml`): Lightweight shared data primitives (`CanvasBackgroundPattern`, `ToolId`, `ReadOnlyReason`, `HasSize`, `SaberQuillStyles`, `saber*FontFallbacks`).
  - `packages/onyxsdk_pen` (`packages/onyxsdk_pen/pubspec.yaml`): Android e-ink stylus plugin (`package: com.example.onyxsdk_pen`, uses insecure HTTP `http://repo.boox.com/repository/maven-public/` in `android/build.gradle.kts:6`).

### 2.2 Export, Import, Share & Gallery Bugs / Bottlenecks

| Severity | Location | Issue |
| :---: | --- | --- |
| **P0** | `android/app/src/main/AndroidManifest.xml:13` + `lib/data/file_manager/file_manager_transfer.dart:59-63` | **Android 13+ Gallery Save Completely Broken**: `AndroidManifest.xml:13` explicitly strips `READ_MEDIA_IMAGES` via `tools:node="remove"`, while `_requestPhotosPermission()` requests `Permission.storage` on API 33 (`sdkInt > 33` off-by-one!) and `Permission.photos` (`READ_MEDIA_IMAGES`) on API 34+, which always returns denied. Furthermore, `SaverGallery.saveImage` on API 29+ uses MediaStore `insert` and requires **no runtime storage permission at all**. On denial, `_fmExportFile` silently does nothing (no snackbar). |
| **P0** | `ios/Runner/Info.plist:64` + `file_manager_transfer.dart:51` | **iOS Gallery Save Crash/Rejection Risk**: Code requests `Permission.photosAddOnly`, but `Info.plist` only declares `NSPhotoLibraryUsageDescription` and is **missing `NSPhotoLibraryAddUsageDescription`**. |
| **P0** | `lib/data/editor/editor_exporter.dart:64-91` | **PDF Export OOM & UI-Thread Contention**: `generatePdf()` rasterizes **every page** via `ScreenshotController.widgetToUiImage(..., pixelRatio: 2, delay: 200ms)` using a `Pool(1..4)` (all contending on the single Flutter UI rasterizer thread) and retains every full RGBA `im.Image` in RAM simultaneously before calling `pdf.addPage()`. A 50-page note allocates ~1.1 GB of raw RGBA buffers → OOM crash on iOS/Android. |
| **P1** | `lib/pages/editor/editor_media_import.dart:502-504` | **PNG Export Capped at 1× Resolution**: `targetPixelRatio = 3000 / page.size.longestSide; if (targetPixelRatio > 1) targetPixelRatio = 1;` clamps standard 1000×1400 pages down to `1.0` instead of `2.0–3.0`, producing blurry exports. Also force-unwraps `pngBytes!` and swallows errors without user feedback. |
| **P1** | `lib/data/file_manager/file_manager_transfer.dart:24` | **Branding Leak in Photos**: `SaverGallery.saveImage(..., albumPath: 'Saber')` creates a `"Saber"` photo album on users' devices. |
| **P1** | `lib/main.dart:114-116, 289` | **Cold-Start PDF Share Intent Race + Case Sensitivity**: `Editor.canRasterPdf` is populated asynchronously by `unawaited(Printing.info())`, racing with `getInitialSharing()`. Also `extension == '.pdf'` rejects `.PDF` uppercase filenames. |
| **P1** | `lib/data/editor/editor_exporter.dart:41-48, 58-61` | **Duplicate Trailing-Empty-Page Removal**: Removes the last empty page twice if two trailing empty pages exist. |
| **P2** | `lib/data/editor/editor_exporter.dart:32-34, 110-116` | **Layer Z-Order & Theme Distortion in PDF**: Rasterizing highlighter/pencil into the background image breaks inter-layer Z-order when mixed with vector pen strokes. `EditorExporterTheme` hardcodes light mode + `en_US` locale (`editor_exporter.dart:305, 318`). |
| **P2** | `lib/data/file_manager/file_manager_transfer.dart:32` | **Unsafe RenderBox Cast on iOS Share**: `context.findRenderObject() as RenderBox` can throw if null/detached. |
| **P2** | `lib/components/home/export_note_button.dart:69` | **Batch Export UX & RAM**: Names multi-note ZIP `${files.first.name}.zip` (e.g. `Lecture1.pdf.zip`) and buffers all exported PDFs in memory before zipping. |
| **P2** | `lib/main.dart:114` | **No Direct Print Action**: `printing` package is imported *only* for `Printing.info().canRaster` — there is no "Print Note" action exposed to users despite shipping the `printing` native plugin. |

### 2.3 Missing Export Formats & Opennote Pro Opportunities
- **Currently supported**: PDF (hybrid raster+vector, fixed 2× bg), SBA (archive), PNG (single current page, capped at 1×, gallery-only).
- **Missing**: Pure **SVG Vector Export**, **High-Res 300/600 DPI PNG / Transparent PNG**, **Multi-page PNG / Selective Page Range UI** (`pageIndices` parameter exists in `EditorExporter.generatePdf` at line 39 but is unused by UI!), **Searchable OCR PDF**, **Markdown + Embedded Diagram Export**, **Direct AirPrint / Android Print**.
- **Pro Export Matrix**:
  - **Free**: Standard PDF export (150 DPI), single-page PNG, `.sba` backup.
  - **Opennote Pro**: Pure **Vector SVG / CAD-ready PDF** (for engineering diagrams), **Ultra-HD 300–600 DPI & Transparent PNG**, **Batch Folder Export**, **Custom Page Range & Dark-Mode PDF Toggle**, **OCR-Searchable PDF** (on-device Apple Vision / ML Kit invisible text layer).

---

## 3. Shortcuts, Clipboard, Sentry/Telemetry & i18n

### 3.1 Shortcuts (`lib/data/shortcuts/mobile_keybinder.dart`)
- **Status**: **Clean & well-engineered (4.5/5)**. Zero external dependencies, backed by `HardwareKeyboard`, supports `VoidCallback` and hold-state `ValueChanged<bool>`, handles shifted `+` (`mobile_keybinder.dart:123-125`), and preserves drop-in `typedef Keybinder = MobileKeybinder`.
- **Gaps**:
  - Always returns `false` from `_handleKeyEvent` (`mobile_keybinder.dart:254, 270`), so matched shortcuts can still propagate to focused text fields (e.g., Quill editor or search bar).
  - No iPadOS `ShortcutManager` / `Shortcuts` widget integration for the iOS "Hold ⌘ to see keyboard shortcuts" HUD overlay.

### 3.2 Clipboard (`lib/data/clipboard/mobile_clipboard.dart`)
- **Status**: **Clean & well-tested (4.5/5)**. Uses `com.opennote.app/clipboard` MethodChannel wired in both `AppDelegate.swift:8` and `MainActivity.kt:22`. Supports PNG/JPEG/GIF/WebP paste + PNG copy via `UIPasteboard` (iOS) and `FileProvider` (Android).
- **Gaps**:
  - `MainActivity.kt:111` overwrites a single static `cacheDir/clipboard/copied_image.png` file (can race if user copies twice rapidly while another app reads the URI).
  - No SVG or rich-text/stroke-vector clipboard support between Opennote windows.

### 3.3 Sentry & Telemetry (`lib/data/sentry/`)
- **Good**: `isSentryConfigured = false` (`lib/data/sentry/sentry_init.dart:20`) intentionally prevents Opennote from sending crashes to upstream Saber's Sentry DSN (`sentry_init.dart:62`).
- **Critical Gaps before enabling Opennote Sentry**:
  1. `pubspec.yaml:269-270` still configures `sentry_dart_plugin` with `project: saber` and `org: saber-yf`.
  2. `lib/data/sentry/sentry_init.dart:62` still contains upstream Saber's DSN.
  3. **`lib/data/sentry/sentry_filter.dart:50-83` (P1 PII Leak)**: `beforeSend` **only scrubs `event.message`**. It does **not** scrub `event.exceptions` (exception values/stack frames containing file paths or URLs), `event.breadcrumbs`, `event.contexts`, or `event.extra`. Once Sentry is enabled, exception messages containing note filenames or user paths will leak unredacted.
  4. `sentry_filter.dart:11-12` comments reference `https://saber-yf.sentry.io/settings/security-and-privacy/`.

### 3.4 Localization / i18n (`lib/i18n/`, `slang.yaml`)
- **Setup**: `slang` v4.12.1 (`base_locale: en`, `fallback_strategy: base_locale`, 25 locales). `RedirectingLocalizationDelegate` cleanly handles Esperanto (`eo`) fallback.
- **Untranslated / Hardcoded Strings**:
  - `lib/i18n/extensions/canvas_background_pattern_localized.dart:15-16`: Hardcoded `'Isometric'` and `'Engineering Grid'` instead of `t.editor.menu.bgPatterns.*`.
  - **`lib/i18n/_missing_translations.yaml`**: **776 missing/outdated keys** across 14 of 24 non-English locales:
    - `uk` (272), `ca` (147), `fa` (75), `fr` (75), `pt-BR` (67), `es` (55), `ar` (37), `tr` (37), `ja` (11), `eo` (10), `th` (6), `ru` (4), `sl` (4), `vi` (4).
    - Complete (0 missing): `cs`, `de`, `he`, `hu`, `it`, `nl`, `pl`, `zh-Hans-CN`, `zh-Hant-TW`.
  - `lib/i18n/_unused_translations.yaml`: Clean (0 unused keys).
- **Legacy "Saber" String Leaks in `lib/i18n/`**:
  - **445 total matches** across all 25 `*.i18n.yaml` files (12–19 per locale).
  - Exact `en.i18n.yaml` leaks (19 lines — **all safe to rename** to Opennote except line 274 if Nextcloud folder stays `'Saber'` for backward compat, and line 284 copyright attribution must retain upstream notice alongside Opennote):
    - `lib/i18n/en.i18n.yaml:23` (`welcome: Welcome to Saber`)
    - `lib/i18n/en.i18n.yaml:82` (`title: Help improve Saber?`)
    - `lib/i18n/en.i18n.yaml:107` (`shouldCheckForUpdates: Check for Saber updates`)
    - `lib/i18n/en.i18n.yaml:129` (`customDataDir: Custom Saber folder`)
    - `lib/i18n/en.i18n.yaml:151` (`allowInsecureConnections: ... Allow Saber to connect ...`)
    - `lib/i18n/en.i18n.yaml:199` (`openDataDir: Open Saber folder`)
    - `lib/i18n/en.i18n.yaml:228` (`saberNcServer: Saber's Nextcloud server`)
    - `lib/i18n/en.i18n.yaml:231` (`loginWithSaber: Login with Saber`)
    - `lib/i18n/en.i18n.yaml:234` (`pleaseAuthorize: Please authorize Saber ...`)
    - `lib/i18n/en.i18n.yaml:239` (`newToSaber: New to Saber? ...`)
    - `lib/i18n/en.i18n.yaml:253` (`Saber will generate your encryption keys ...`)
    - `lib/i18n/en.i18n.yaml:269` (`... log back in to Saber ...`)
    - `lib/i18n/en.i18n.yaml:273-276` (`Log out of Saber`, `delete your 'Saber' folder`, `Log back in to Saber`)
    - `lib/i18n/en.i18n.yaml:280` (`official Saber server ... adilhanney@disroot.org`)
    - `lib/i18n/en.i18n.yaml:284` (`Saber Copyright © 2022-$buildYear Adil Hanney`)
    - `lib/i18n/en.i18n.yaml:403` (`This note was edited using a newer version of Saber`)

---

## 4. Native iOS & Android Platform Readiness

### 4.1 StoreKit 2 (iOS) & Google Play Billing (Android) Readiness
- **Current State**: **Not integrated (0%)**. No `in_app_purchase`, `purchases_flutter` (RevenueCat), or `adapty_flutter` in `pubspec.yaml`.
- **iOS StoreKit 2 Blockers**:
  1. `ios/Podfile:3` and `ios/Runner.xcodeproj/project.pbxproj:485, 632, 688` set `IPHONEOS_DEPLOYMENT_TARGET = 14.0`. **StoreKit 2 requires iOS 15.0+**. Bump deployment target to `15.0` (or guard StoreKit 2 behind `@available(iOS 15.0, *)`).
  2. No `ios/Runner/Runner.entitlements` file exists (`CODE_SIGN_ENTITLEMENTS` absent from `project.pbxproj`). Required for Associated Domains (Universal Links), Push Notifications (subscription lifecycle/renewal), and iCloud/App Groups if added.
  3. Enable **In-App Purchase** capability in Xcode / App Store Connect for `com.opennote.app` (Team `3DB8QX4Z23`).
- **Android Google Play Billing Blockers**:
  1. **`android/app/build.gradle.kts:22, 32`**: `namespace` and `applicationId` are `"com.woaiyj1314.opennote"` (mismatch with iOS `com.opennote.app` and `MobileClipboard` channel `com.opennote.app/clipboard`). **Must finalize before first Play Store upload** because `applicationId` is immutable once published.
  2. **`android/fallback-key.jks` + `android/fallback-key.properties` are committed to Git** with plaintext password (`Uwa4V2FvQLVqgUhAN6c`). `build.gradle.kts:17-19` silently falls back to this public keystore if `key.properties` is absent, and `build.gradle.kts:98` signs `debug` builds with the `release` config. Remove fallback keystore from release signing and use Play App Signing.
  3. **`android/app/build.gradle.kts:94`**: `debugSymbolLevel = "NONE"` triggers Play Console warning; change to `"SYMBOL_TABLE"` for crash/ANR symbolication.
  4. **`android/app/build.gradle.kts:42`**: `abiFilters += listOf("arm64-v8a")` works for Play Store 64-bit mandate, but excludes `armeabi-v7a` budget tablets/e-ink devices and `x86_64` Chromebooks.

### 4.2 Universal Links, Deep Links, Document Types & Manifest Bugs
- **iOS (`ios/Runner/Info.plist`)**:
  - **Missing `CFBundleDocumentTypes` & `UTExportedTypeDeclarations`**: Even though `UISupportsDocumentBrowser=true`, `UIFileSharingEnabled=true`, and `LSSupportsOpeningDocumentsInPlace=true` (`Info.plist:110-115`), iOS cannot associate `.sbn`, `.sbn2`, `.sba`, or `.pdf` with Opennote in the Files app or Share Sheet.
  - **Missing `CFBundleURLTypes` & Associated Domains**: No `opennote://` custom scheme or `https://` Universal Links for referral/promo/paywall deep links.
  - **Missing `NSPhotoLibraryAddUsageDescription`** (App Store rejection / crash on PNG gallery save).
  - **Export Compliance Risk (`Info.plist:58`)**: `ITSAppUsesNonExemptEncryption = false` conflicts with custom AES encryption in `nextcloud_client_extension.dart` unless documented under Apple's standard encryption exemption.
  - **Deprecated Background Fetch (`AppDelegate.swift:26`)**: `setMinimumBackgroundFetchInterval` is deprecated since iOS 13; migrate to `BGTaskScheduler` + `BGTaskSchedulerPermittedIdentifiers` in `Info.plist`.
- **Android (`android/app/src/main/AndroidManifest.xml`)**:
  - **Line 13**: `<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" tools:node="remove" />` breaks gallery save (see §2.2).
  - **Line 28**: `android:launchMode="singleTask"` is placed on `<application>` (invalid; only valid on `<activity>`).
  - **Line 103**: `android:pathPattern=".*\\.pdf"` has an extra backslash (matches literal `\.pdf` instead of `.pdf`).
  - **Missing**: `android:autoVerify="true"` App Links intent-filter and `opennote://` custom scheme for marketing/paywall deep links.

### 4.3 App Icons & Launch Screens
- **iOS Launch Screen (`ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage*.png`)**: All 3 images are **1×1 px transparent PNGs (`(1, 1) LA`)** — resulting in a blank white flash on launch. Replace with centered Opennote mark + dark-mode adaptive `LaunchScreen.storyboard` background (`systemBackgroundColor` instead of hardcoded white `LaunchScreen.storyboard:22`).
- **iOS 26 / Liquid Glass App Icon (`ios/Runner/AppIcon.icon/icon.json`)**: Still uses Saber's yellow paper layers (`yellowPaper.svg`, `shadowedPaper.svg`, `srgb:1.00000,0.78431,0.00000`).
- **Android Adaptive Icon Color Mismatch**: `pubspec.yaml:257` specifies `adaptive_background_color: "#ffc800"` (Saber yellow), while `android/app/src/main/res/values/colors.xml:3` has `#FF000000` (black). Re-running `icons_launcher` will revert Android's adaptive background to Saber yellow unless `pubspec.yaml:257` is updated.

---

## 5. Exact Legacy "Saber" Reference Registry (Safe vs. Unsafe to Rename)

### 5.1 SAFE to Rename Immediately (Zero Data-Loss / Migration Risk)

| File & Line(s) | Current Reference | Recommended Action |
| --- | --- | --- |
| `lib/main.dart:336` | `DynamicMaterialApp(title: 'Saber', ...)` | Change to `'Opennote'` |
| `lib/data/file_manager/file_manager_transfer.dart:24` | `albumPath: 'Saber'` | Change to `'Opennote'` |
| `lib/data/nextcloud/nextcloud_client_extension.dart:18` | `'https://nc.saber.adil.hanney.org'` | Remove or replace with Opennote server / empty custom URL |
| `lib/data/nextcloud/nextcloud_client_extension.dart:22` | `'Saber/$buildName ...'` | Change to `'Opennote/$buildName ...'` |
| `lib/data/sentry/sentry_init.dart:62` | Upstream Saber Sentry DSN | Replace with Opennote Sentry DSN before setting `isSentryConfigured = true` |
| `lib/data/sentry/sentry_filter.dart:11-12` | `https://saber-yf.sentry.io/...` comment | Update to Opennote Sentry org URL |
| `pubspec.yaml:257` | `adaptive_background_color: "#ffc800"` | Update to Opennote brand background hex |
| `pubspec.yaml:269-270` | `project: saber`, `org: saber-yf` | Update to Opennote Sentry project/org |
| `ios/Runner.xcodeproj/project.pbxproj:542, 560, 576` | `PRODUCT_BUNDLE_IDENTIFIER = com.adilhanney.saber.RunnerTests` | Change to `com.opennote.app.RunnerTests` |
| `ios/Runner/AppIcon.icon/icon.json` + `Assets/*.svg` | Saber yellow paper Liquid Glass icon | Replace with Opennote layered icon |
| `lib/i18n/en.i18n.yaml:23, 82, 107, 129, 151, 199, 228, 231, 234, 239, 253, 269, 273, 275, 276, 280, 403` (+ all 24 other `*.i18n.yaml`, 445 matches total) | User-facing `"Saber"` strings & `adilhanney@disroot.org` | Replace with `"Opennote"` + Opennote support email, then re-run `dart run slang` |
| `lib/i18n/en.i18n.yaml:284` | `Saber Copyright © 2022-$buildYear Adil Hanney` | Update to `Opennote (based on Saber © 2022-$buildYear Adil Hanney)` to preserve GPL/upstream attribution |
| `packages/sbn/pubspec.yaml:2` | `"Data handling of the sbn format for the Saber: Handwritten Notes app."` | Update description (safe metadata) |
| `packages/onyxsdk_pen/pubspec.yaml:4` | `homepage: https://github.com/saber-notes/saber/...` | Keep or update to Opennote fork URL (safe metadata) |

### 5.2 UNSAFE / HIGH-RISK to Rename Without Migration (Do NOT Blindly Rename)

| File & Line(s) | Current Reference | Why Unsafe / Required Migration |
| --- | --- | --- |
| `pubspec.yaml:1` | `name: saber` | **Breaks every `import 'package:saber/...'` across hundreds of Dart files & tests.** Keep as internal Dart package name unless doing a dedicated repo-wide automated refactor. |
| `lib/data/file_manager/file_manager.dart:39` | `static const appRootDirectoryPrefix = 'Saber';` | **Existing users' local notes directory (`<Docs>/Saber/`) AND Nextcloud remote root (`/Saber/`) depend on this exact string!** Renaming without a bidirectional migration script will orphan all existing local & synced notes. |
| `lib/data/file_manager/note_paths.dart:9, 14` & `AndroidManifest.xml:59-86` | `.sbn2`, `.sbn`, `.sba` extensions & MIME types | **Breaks opening existing notes & `.sba` backups.** Always retain read/import compatibility for `.sbn`/`.sbn2`/`.sba` even if introducing an `.onote` alias later. |
| `lib/data/nextcloud/saber_syncer.dart:557` | `static const encExtension = '.sbe';` | **Breaks decryption/discovery of all existing encrypted remote files on Nextcloud.** |
| `lib/data/nextcloud/nextcloud_client_extension.dart:30, 37` | `configFileName = 'config.sbc'`, `reproducibleSalt = r'8MnPs64@R&mF8XjWeLrD'` | **Changing salt or config filename immediately breaks decryption of all existing synced user accounts.** Requires versioned `config_v2.sbc` migration when fixing the AES-CTR static IV flaw. |
| `lib/data/sentry/sentry_filter.dart:16` | `RegExp(r'SaberSyncFile\(.+\)')` | Must stay synchronized with `SaberSyncFile.toString()` (`saber_syncer.dart:589`); rename together only if renaming the class. |
| `lib/data/saber_version.dart:1`, `saber_syncer.dart:26, 564`, `login_flow.dart:14`, `packages/sbn/lib/quill_styles.dart:7`, `packages/sbn/lib/font_fallbacks.dart:6, 28, 38` | Internal Dart class/const names (`SaberVersion`, `SaberSyncInterface`, `SaberSyncFile`, `SaberLoginFlow`, `SaberQuillStyles`, `saber*FontFallbacks`) | Internal symbols only (never user-facing); renaming risks merge conflicts and unnecessary churn across call sites. |
| `android/app/build.gradle.kts:22, 32` | `applicationId = "com.woaiyj1314.opennote"` | **Safe ONLY BEFORE first Google Play publish; UNSAFE after.** Decide on `com.opennote.app` vs current ID before launch. |

---

## 6. Top Prioritized Action Plan

### P0 — Ship-Blockers (Fix Before Store Submission / Pro Launch)
1. **Fix Android 13+ Gallery Save**: Remove redundant `Permission.photos`/`storage` check on API ≥ 29 in `file_manager_transfer.dart:49-64`, change `albumPath: 'Saber'` → `'Opennote'`, and add `NSPhotoLibraryAddUsageDescription` to `ios/Runner/Info.plist`.
2. **Eliminate User-Facing Saber Leaks**: Fix `lib/main.dart:336`, `nextcloud_client_extension.dart:18, 22`, `ios/Runner.xcodeproj/project.pbxproj:542, 560, 576`, `ios/Runner/AppIcon.icon/icon.json`, `pubspec.yaml:257, 269-270`, and all 19 `en.i18n.yaml` strings (+ regenerate slang).
3. **Fix PDF Export OOM & PNG 1× Cap**: Stream PDF pages sequentially (dispose each `im.Image` / `ui.Image` before next page, or encode JPEG/PNG bytes per page) in `editor_exporter.dart:64-91`; uncap PNG `targetPixelRatio` to `2.0–3.0` (clamped by max 4096 px) in `editor_media_import.dart:502-504`.
4. **Fix `doBackgroundSync()` Hang (`lib/main.dart:192-226`)**: Load credentials, set `HttpOverrides.global`, and call `syncer.downloader.refresh()` + `syncer.uploader.refresh()` with a hard timeout.
5. **Fix iOS & Android Store Readiness**: Bump iOS deployment target to `15.0` (StoreKit 2), replace 1×1 `LaunchImage.png`, add `CFBundleDocumentTypes` + `UTExportedTypeDeclarations` + `Runner.entitlements`, finalize Android `applicationId`, remove committed `fallback-key.jks` from release signing, fix `AndroidManifest.xml:28` (`launchMode`) & `:103` (`.*\\.pdf`).

### P1 — High-Impact Quality, Security & Pro Foundations
6. **Upgrade Sync Crypto (v2)**: Introduce `config_v2.sbc` using Argon2id/PBKDF2 key derivation + AES-256-GCM with per-file random 96-bit nonces, and actually use `stows.key` for note encryption; fix missing `await` at `saber_syncer.dart:178` and `.endsWith` at line 205.
7. **Harden `SentryFilter.beforeSend`**: Scrub `event.exceptions`, `event.breadcrumbs`, and `event.contexts` before enabling Opennote's Sentry project.
8. **Fix Cold-Start PDF Share Intent**: Await `Printing.info()` (or use `pdfrx` directly) and lowercase-normalize extensions in `lib/main.dart:289`.
9. **Localize Missing Keys**: Add `isometric` & `engineeringGrid` to `en.i18n.yaml` and clear the 776 missing keys in `_missing_translations.yaml`.
10. **Build Pro Export & Cloud Tier**: Wire RevenueCat / StoreKit 2 + Play Billing; ship Vector SVG export, 300/600 DPI PNG, Page Range picker, Batch Folder export, and Managed E2EE Cloud Sync / Auto-Backup.
