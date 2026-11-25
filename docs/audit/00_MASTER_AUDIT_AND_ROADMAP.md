# Opennote v2 — Master Technical, UX, ASO & Monetization Audit & Roadmap

> **Synthesized from:**
> - [`01_canvas_tools_audit.md`](./01_canvas_tools_audit.md) (`audit-canvas`, #31)
> - [`02_editor_home_ui_audit.md`](./02_editor_home_ui_audit.md) (`audit-editor-home`, #22)
> - [`03_sync_platform_audit.md`](./03_sync_platform_audit.md) (`audit-sync-data`, #24)
> - [`04_aso_monetization_audit.md`](./04_aso_monetization_audit.md) (`audit-aso-growth`, #23)
>
> **Purpose:** Single executive source of truth for Opennote v2's ship-readiness, remodularization, brand hygiene, subscription monetization, and 90-day ASO growth execution.

---

## Executive Scorecard

| Pillar | Composite Maturity (1–5) | Core Strength | Top Ship-Blocker |
| :--- | :---: | :--- | :--- |
| **Canvas & Drawing Engine** | **3.5** | 120Hz `Picture` caching, octave-quantized infinite culling, 6-posture palm rejection | Shape/connector `fc`/`ls`/`ty` serialization data loss; invisible light-mode Protractor; unscaled Circle-to-Select & selection handles |
| **Editor Chrome, Home & Navigation** | **2.6** | `OpennoteTokens`, dual-tier Studio toolbar, `PageGridOverviewDialog`, 2-pane Settings | P0 `OpennoteContextualSubBar` text-mode RenderFlex crash; P0 `PresentationMode` touch-trap overlay; 3 concurrent un-awaited startup dialogs |
| **Sync, Crypto, Export & Native** | **2.5** | Fast BSON `.sbn2`/`.sba` core, zero-dep `MobileKeybinder`, native clipboard | AES-CTR static IV reuse + unused `stows.key`; `doBackgroundSync()` infinite hang; Android 13+ gallery save broken; PDF export OOM; iOS target `14.0` blocks StoreKit 2 |
| **Brand Hygiene, ASO & Monetization** | **1.5** | Clear underserved niche (Engineering Drafting + Study Tape + Local-First Cross-Platform) | 445 i18n + 11/26 store locale + 96 README `"Saber"` leaks; 0/26 iOS Fastlane fields; stale Saber icons/screenshots; 0% IAP/paywall integration |

---

## 1. Complete App Feature Inventory Matrix

| Domain | Feature | Maturity (1–5) | Tier (Free / Pro) | Top Action |
| :--- | :--- | :---: | :--- | :--- |
| **Canvas** | Fountain & Ballpoint Pens + Pen Tray | **4.0** | **Free** (3 presets) / **Pro** (6+ presets, dashed/dotted, custom pressure) | Guard locked layer before pushing undo (`pen_gesture.dart:92`); clamp pressure curve (`pen.dart:157`). |
| **Canvas** | Highlighter (Behind-Ink + Straight-Line) | **4.0** | **Free** (core) / **Pro** (custom palettes, PDF text-snap) | Persist last color in `stows` (`highlighter.dart:21`); match in-flight `BlendMode` (`stroke_painter_part.dart:345`). |
| **Canvas** | Pencil & GLSL Texture Shader | **3.0** | **Free** (graphite) / **Pro** (tilt shading, texture packs) | Anchor `pencil.frag:139` grain to canvas coords; add uninitialized fallback (`pencil_shader.dart:10`). |
| **Canvas** | Shape Pen & Recognition (Circle/Rect/Poly) | **3.0** | **Free** (basic shapes) / **Pro** (fills, dashed borders, editable vertices) | Fix `fc`/`ls`/`ty` serialization loss & SVG Y-axis inversion (`_circle_stroke.dart`, `_rectangle_stroke.dart`, `_polygon_stroke.dart`). |
| **Canvas** | Eraser (Object & Precision) | **3.0** | **Free** (object + filters) / **Pro** (true stroke-splitting precision) | Add AABB early-exit (`eraser.dart:36`); fix 2× cursor mismatch (`eraser_gesture.dart:54`); build stroke-splitting. |
| **Canvas** | Scribble-to-Erase Gesture | **4.0** | **Free Core** | Bypass Eraser filter flags (`scribble_detector.dart:354`); scale cursor by `1/scale` (`pen_gesture.dart:135`). |
| **Canvas** | Lasso / Rect Select & Callout Menu | **3.5** | **Free** (move/resize/color) / **Pro** (save element, beautify, OCR) | Scale handles by `1/scale` (`selection_painter_part.dart:180`); wire `onDuplicate` (`lasso_callout_menu.dart:317`). |
| **Canvas** | Circle-to-Select Gesture | **2.0** | **Free Core** | Scale thresholds by `currentScale` + add 6px jitter deadzone for 120Hz styluses (`circle_to_select_detector.dart:29-76`). |
| **Canvas** | Engineering Drafting (Ruler/Arrows/Dimensions/Symbols) | **3.5** | **Free** (basic ruler/arrow) / **Pro** (calibrated dimensions, connectors, iso snap, symbol packs) | Fix `ArrowStroke`/`DimensionStroke` `fromJson`; show HUD for Arrow/Dimension (`canvas_hud.dart:94`); add real-world units. |
| **Canvas** | Protractor Overlay | **1.5** | **Pro** (Engineering Drafting Suite) | Fix invisible white-on-white light-mode colors (`protractor_overlay.dart:51-132`); add rotate/scale/angle readout. |
| **Canvas** | Study Tape (Active Recall) | **4.0** | **Free** (solid tape, up to 3–5/page) / **Pro** (unlimited, patterned, Quiz Mode) | Fix live drag preview (`stroke_painter_part.dart:344`); keep reveal/conceal pill visible when `hasTape` (`canvas_hud.dart:350`). |
| **Canvas** | Laser Pointer & Spotlight | **3.5** | **Free** (red laser) / **Pro** (multi-color + clean presentation feed) | Guard `fadeOutStroke` against disposed pages & stuck `isDrawing` (`laser_pointer.dart:110-138`). |
| **Canvas** | Text / Quill Overlay | **3.0** | **Free** (page text) / **Pro** (floating multi-text & LaTeX boxes) | Measure actual `RenderBox` bounds (`page.dart:219`); plan multi-instance floating `TextBox` nodes. |
| **Canvas** | PDF, Image, Stickers & Reusable Elements | **3.5** | **Free** (PDF ≤25p, 4–5 elements) / **Pro** (unlimited PDFs + 300 DPI + Dark Invert, unlimited elements) | Remove `pageSize` drag clamp on infinite canvas (`canvas_image.dart:152`); add crop undo (`:491`). |
| **Canvas** | Backgrounds, Paper Templates & Layers | **3.5** | **Free** (standard paper, 2 layers/page) / **Pro** (Engineering/Isometric/Cornell/Planners, unlimited layers) | Add undo/confirm for layer deletion (`floating_layers_overlay.dart:44`); add rename/reorder/opacity; expose templates from Home. |
| **Canvas** | Infinite Canvas & Mode Conversion | **4.0** | **Free** (1 whiteboard) / **Pro** (unlimited infinite canvases + conversion) | Fix `EditorCoreInfo.copyWith` dropping `isInfiniteCanvas` (`editor_core_info.dart:549`). |
| **Canvas** | Zoom/Pan Physics, Palm Rejection & Zoom Window | **4.5 / 2.5** | **Free** (120Hz zoom/palm) / **Pro** (auto-advance Zoom Window, 2-finger rotate) | Upgrade `ZoomWindowPanel` to use `CanvasPainter` + stylus pressure (`zoom_window_view.dart:389`). |
| **Canvas** | Undo / Redo History Engine | **4.0** | **Free Core** | Add history types for layer edits, image crop, scribble text deletion, and tape toggle (`editor_history.dart:267`). |
| **Canvas** | Handwriting OCR & Ink Search | **1.5** | **Pro** (Marquee differentiator) | Replace 5-letter toy `InkReader` (`ink_search.dart:182`) with on-device ML Kit / Apple Vision OCR. Do NOT market until shipped. |
| **Editor** | Opennote Studio Chrome, Toolbars & Sheets | **2.5** | **Free Core** (Pro badges on gated tools) | Fix `OpennoteContextualSubBar` text-mode RenderFlex crash (`contextual_sub_bar.dart:129`); restore shortcuts & fullscreen toggle; fix double drag handle & confirm Clear All. |
| **Editor** | Presentation / Flashcard Mode | **1.5** | **Free** (basic) / **Pro** (spaced-repetition stats & quiz) | Move touch-blocking `GestureDetector` below controls (`presentation_mode.dart:270`); wire `known` tracking & card-flip animation. |
| **Editor** | Page Grid Overview & Document Outline | **3.5** | **Free Core** | Deduplicate `OutlineExtractor`; add multi-page batch select/export; replace M3 `SegmentedButton` with `OpennoteSegmentedBar`. |
| **Home** | Onboarding & Empty States | **2.0** | **Free Core + 7-Day Trial Soft Offer** | Serialize `_showDialogs()` with `await` (`home.dart:45`); build 3-step Tactile Studio onboarding + interactive sample `.sbn2` + CTA empty states. |
| **Home** | Library, Recent, Browse, Shelf & Search | **2.5** | **Free Core** (unlimited local notebooks) | Fix `BrowsePage` Quick Note overwrite (`browse.dart:341`), `NotebookShelf` menu labels (`:216, 497`), `SearchDialog` `Spacer()` & SafeArea (`search_dialog.dart:414, 503`); deduplicate hero/dock. |
| **Home** | Navigation (Phone Bar & Tablet/Desktop Rail) | **3.5** | **Free Core** (+ subtle sidebar Pro pill) | Rebuild `HorizontalNavbar` on `OpennoteGlassPill`; localize `VerticalNavbar`; fix platform shortcut badge (`⌘K` vs `Ctrl+K`) and wire shortcut. |
| **Settings** | Settings Studio, Design System & Logs | **3.0** | **Free Core** (+ Top Pro Hero Card) | Adopt `OpennoteGlassPill`/`OpennoteSegmentedBar` across editor/nav; localize `SettingsCategory`; filter individual rows; remove `adil192` & `nc.saber` leaks. |
| **Sync** | Cloud Sync, E2E Crypto & CRDT | **2.0** | **Free** (local + BYO Nextcloud/WebDAV) / **Pro** (Managed E2EE Cloud, Auto-Backup, Version History) | Fix `doBackgroundSync()` hang (`main.dart:192`); design `config_v2.sbc` (Argon2id + AES-256-GCM + random nonces); fix missing `await` (`saber_syncer.dart:178`). |
| **Export** | PDF, PNG, SBA & Vector Export | **3.0** | **Free** (150 DPI PDF, PNG, `.sba`) / **Pro** (Vector SVG, 300+ DPI/Transparent PNG, Batch/Range PDF, Dark-Mode PDF) | Fix Android 13+ gallery save & iOS `NSPhotoLibraryAddUsageDescription`; stream PDF pages to prevent OOM (`editor_exporter.dart:64`); uncap PNG 1× (`editor_media_import.dart:504`). |
| **Platform** | Shortcuts, Clipboard, Sentry & i18n | **3.2** | **Free Core** | Purge 445 Saber i18n leaks + 776 missing keys; scrub `event.exceptions`/`breadcrumbs` in `SentryFilter` (`sentry_filter.dart:50`). |
| **Native/ASO** | iOS/Android Store Readiness, IAP & Metadata | **1.5** | **Platform & Growth Foundation** | Bump iOS target to `15.0` (StoreKit 2); fix 1×1 `LaunchImage`; add `CFBundleDocumentTypes` + `Runner.entitlements`; finalize Android `applicationId` & remove `fallback-key.jks`; ship iOS+Play ASO copy & 6-slide framed visual kit. |

---

## 2. Unified P0 / P1 / P2 Bug & Security Register

### P0 — Ship-Blocking Crashes, Data Loss, Security & Store Rejections (25 Items)

| ID | Domain | Exact File & Line | Defect Description |
| :---: | :--- | :--- | :--- |
| **P0-01** | Security / Crypto | `lib/data/nextcloud/nextcloud_client_extension.dart:37, 157-164` & `saber_syncer.dart:223, 268, 403, 444` | `client.encrypter` ignores `stows.key`, uses single-pass `sha256` key derivation, and reuses one static `stows.iv` across all files/names in AES-CTR (breaks confidentiality). |
| **P0-02** | Security / Release | `android/fallback-key.jks`, `android/fallback-key.properties`, `android/app/build.gradle.kts:17-19, 98` | Release signing falls back to a public keystore with plaintext password committed to Git; `debug` uses `release` signing config. |
| **P0-03** | Data Loss | `lib/components/canvas/_circle_stroke.dart:64-74`, `_rectangle_stroke.dart:73-84`, `_polygon_stroke.dart:32-73`, `_arrow_stroke.dart:61-111`, `_dimension_stroke.dart:83-132` | `toJson`/`fromJson` drop `fc` (`fillColor`), `ls` (`lineStyle`), and `ty` (`toolId`) on save/reload. |
| **P0-04** | Data Loss | `lib/data/editor/editor_core_info.dart:549-571` | `EditorCoreInfo.copyWith` drops `isInfiniteCanvas`, silently reverting copied notes to paged mode. |
| **P0-05** | Data Loss | `lib/components/canvas/canvas_image.dart:491-493` | Image crop end mutates `srcRect` with zero `EditorHistoryItem` and zero autosave trigger. |
| **P0-06** | Data Loss | `lib/pages/home/browse.dart:341-347` | Subfolder "Quick Note" pushes `$createPath/Untitled` without uniqueness suffix, overwriting/reopening the same file. |
| **P0-07** | Crash | `lib/components/toolbar/opennote/contextual_sub_bar.dart:129` | `Expanded(child: QuillSimpleToolbar(...))` inside `Row(min)` inside horizontal `SingleChildScrollView` throws unbounded-width RenderFlex crash in text mode. |
| **P0-08** | Crash / OOM | `lib/data/editor/editor_exporter.dart:64-91` | `generatePdf()` buffers every page's 2× RGBA `im.Image` simultaneously in RAM (~1.1 GB on 50 pages) → OOM crash. |
| **P0-09** | Crash / Store | `ios/Runner/Info.plist:64` & `lib/data/file_manager/file_manager_transfer.dart:51` | Code requests `Permission.photosAddOnly`, but `Info.plist` is missing `NSPhotoLibraryAddUsageDescription` (iOS crash/rejection). |
| **P0-10** | Broken Feature | `android/app/src/main/AndroidManifest.xml:13` & `lib/data/file_manager/file_manager_transfer.dart:59-63` | Manifest strips `READ_MEDIA_IMAGES` while Dart requests it (with `sdkInt > 33` off-by-one); Android 13+ gallery saves silently fail. |
| **P0-11** | Broken Feature | `lib/main.dart:192-226` | `doBackgroundSync()` never loads credentials, never sets `NcHttpOverrides`, and never calls `refresh()` → hangs until OS kills background task. |
| **P0-12** | Broken UI | `lib/components/editor/presentation_mode.dart:133-139, 270-276` | Full-screen opaque `GestureDetector` sits above Exit/Reset/Know/Don't Know controls, trapping touch users; `_markStudied(known)` ignores `known`. |
| **P0-13** | Broken UI | `lib/components/canvas/hud/protractor_overlay.dart:51-132` | Hardcodes white colors (`0x33FFFFFF`–`0xCCFFFFFF`) — completely invisible on light/cream paper. |
| **P0-14** | Broken UI | `lib/pages/home/home.dart:45-51` | `_showDialogs()` fires `UpdateManager`, `SentryConsentDialog`, and `WelcomeOnboardingDialog` concurrently without `await`. |
| **P0-15** | Broken UX | `lib/data/tools/circle_to_select_detector.dart:29-76` | Violates physical-scale invariant (unscaled canvas thresholds) and cancels 450ms `_holdTimer` on every 120Hz stylus micro-jitter event. |
| **P0-16** | Broken UX | `lib/components/canvas/painters/selection_painter_part.dart:180-294`, `select_gesture.dart:30-35`, `lasso_callout_menu.dart:305-404` | Selection handles draw/hit-test unscaled (1.5px at 0.25× zoom); `onDuplicate` is required but never rendered in callout menu; image rotation is a no-op (`select_gesture.dart:301-308`). |
| **P0-17** | Broken UX | `lib/components/canvas/canvas_image.dart:152-171` | Clamps image dragging to `pageSize` even in infinite canvas mode. |
| **P0-18** | Broken UX | `lib/components/toolbar/opennote_toolbar.dart` & `toolbar.dart:95-125` | Default `OpennoteToolbar` drops all keyboard shortcuts (`Ctrl+E/F/C/V/Shift+S/F11`) and fullscreen toggle. |
| **P0-19** | Broken Export | `_circle_stroke.dart:115`, `_rectangle_stroke.dart:132`, `_polygon_stroke.dart:107`, `_tape_stroke.dart:228` | `toSvgPath()` omits `page.size.height - y` flip, exporting upside-down SVG shapes/tapes. |
| **P0-20** | Broken History | `lib/data/editor/gestures/pen_gesture.dart:48, 92-100` | Drawing on a locked layer drops the stroke but still pushes a ghost `EditorHistoryItem` onto undo stack. |
| **P0-21** | Broken UI / Crash | `lib/components/home/notebook_shelf.dart:216, 497` & `new_note_button.dart:120-126` | Shelf "Open" actions display `"Home"`/`"Browse"`; `NewNoteButton` throws uncaught string `'Invalid file type'` after snackbar. |
| **P0-22** | Perf / Hit-Test | `lib/data/tools/eraser.dart:18, 36-56` & `eraser_gesture.dart:54` | Missing AABB early-exit (`O(N×V)` per move) and 2× mismatch between visual cursor radius (`size/2`) and erase radius (`size`). |
| **P0-23** | Store Blocker | `ios/Podfile:3`, `ios/Runner.xcodeproj/project.pbxproj:485, 632, 688`, `ios/Runner/Info.plist`, `LaunchImage*.png` | iOS `14.0` target blocks StoreKit 2 (`15.0+`); missing `Runner.entitlements` & `CFBundleDocumentTypes`; 1×1 px `LaunchImage.png`; Android `applicationId` (`com.woaiyj1314.opennote`) mismatch with iOS `com.opennote.app`. |
| **P0-24** | Store Blocker | `metadata/**`, `README.md`, `pricing.md`, `assets/icon/icon.svg` | 11/26 locales leak `"Saber"` (8 titled `"Saber"`); 0/26 iOS Fastlane fields; stale Saber icons/screenshots; `pricing.md` bills `adil192`; `docs/index.html:464` lacks IAP/Terms disclosures. |
| **P0-25** | Dead Code | `lib/data/sync/crdt/*` | Entire CRDT engine is unwired (test-only), with no-op page ops (`crdt_document.dart:159-161`) and unbounded log growth. |

### P1 — High-Impact UX, Stability, Security & Conversion Fixes (Top 16 Items)
1. **Sync Reliability (`saber_syncer.dart:178, 205, 467-510`)**: Add missing `await` on `loadEncryptionKey`; fix `config.sbc` `.endsWith` path bug; replace silent LWW overwrite with conflict copies; eliminate 2s busy-wait in `findLocalChanges`.
2. **Sentry PII Scrubbing (`lib/data/sentry/sentry_filter.dart:50-83`)**: Extend `beforeSend` to scrub `event.exceptions`, `event.breadcrumbs`, `event.contexts`, and `event.extra` before enabling Opennote Sentry.
3. **PNG Export Resolution (`lib/pages/editor/editor_media_import.dart:502-504`)**: Uncap `targetPixelRatio` from `1.0` to `2.0–3.0` (max 4096 px) and handle null/errors gracefully.
4. **Cold-Start PDF Share Intent (`lib/main.dart:114-116, 289`)**: Await `Printing.info()` before handling `getInitialSharing()` and lowercase-normalize `.pdf` extension check.
5. **Android Manifest Bugs (`AndroidManifest.xml:28, 103`, `build.gradle.kts:94`)**: Move `launchMode="singleTask"` off `<application>`; fix `.*\\.pdf` double backslash; set `debugSymbolLevel = "SYMBOL_TABLE"`.
6. **Stroke Z-Order (`lib/data/editor/page.dart:527-566`)**: Stop sorting non-highlighter strokes alphabetically by `toolId.id`; preserve chronological layering.
7. **Scribble-to-Erase Polish (`scribble_detector.dart:354`, `pen_gesture.dart:135`)**: Bypass Eraser filter flags during scribble; scale cursor by `1 / currentScale`.
8. **Study Tape Live Preview & HUD (`stroke_painter_part.dart:344`, `canvas_hud.dart:350`)**: Render `TapeStroke` properly during drag; keep reveal/conceal pill visible when `hasTape`.
9. **Layer Deletion Safety & Drafting HUD (`floating_layers_overlay.dart:44-54`, `canvas_hud.dart:94-96`)**: Add undo/confirmation before deleting layers; keep Drafting HUD visible for `ArrowTool` and `DimensionTool`.
10. **Zoom Window Fidelity (`zoom_window_view.dart:389-435`, `zoom_window.dart:324`)**: Render full `CanvasPainter` + `CanvasBackgroundPainter` + stylus pressure instead of cream centerline-only preview.
11. **Pencil Shader Anchoring (`shaders/pencil.frag:139`, `pencil_shader.dart:10`)**: Pass canvas transform uniform to stop "shower-door" swimming; add safe fallback if shader uninitialized.
12. **Laser Pointer Lifecycle (`laser_pointer.dart:110-138`)**: Guard `fadeOutStroke` against disposed pages and reset stuck `isDrawing` on gesture cancel.
13. **Select Polish (`select.dart:250, 318-372`, `selection_painter_part.dart:55-58`)**: Reverse Z-order in `tapSelect`, guard `polygon.isEmpty`, add AABB early-exit in `_isLassoed`, stop mutating page state inside `paint()`.
14. **Editor Bottom Sheet & Singleton Hygiene (`editor_bottom_sheet.dart:146, 212, 557`, `editor.dart:213`, `primary_tool_dock.dart:170`)**: Remove duplicate drag handle, confirm Clear Page/All, hoist `TextEditingController`s, enforce canonical singletons for `Eraser`/`Ruler`/`ArrowTool`/`DimensionTool`.
15. **Home/Search/Navbar Polish (`search_dialog.dart:414, 503`, `horizontal_navbar.dart:81`, `vertical_navbar.dart:182`)**: Remove `Spacer()` in `Column(min)`, add iOS `SafeArea`, adopt `OpennoteGlassPill` across nav/editor, fix `⌘K`/`Ctrl+K` badge & bind shortcut.
16. **i18n Debt (`lib/i18n/_missing_translations.yaml`, `canvas_background_pattern_localized.dart:15-16`)**: Localize `'Isometric'`, `'Engineering Grid'`, `SettingsCategory`, and clear 776 missing keys.

### P2 — Flagship Craft & Differentiators (Summary)
- True stroke-splitting precision eraser + swept-segment hit-testing (`eraser.dart`).
- On-device ML Kit / Apple Vision Handwriting OCR replacing 5-letter `InkReader` (`ink_search.dart:182`).
- `EditorImage.rotation` support + `ShapePen` triangle/star `PolygonStroke` conversion + `PolygonStroke` in `renderSignature`.
- Dispose `DimensionStroke._cachedTextPainter`; enable 2-finger canvas rotation (`interactive_canvas.dart:248`); floating multi-text boxes on infinite canvas; direct AirPrint/Android Print action; `quota_codec.dart:23` div-by-zero guard; `MobileKeybinder` returning `true` when consuming shortcuts so text fields don't receive them.

---

## 3. Legacy "Saber" Leak Remediation Checklist

### 3.1 SAFE to Rename Immediately (Zero Data-Loss / Migration Risk)

| Surface | Exact Location(s) | Current Leak | Target Replacement |
| :--- | :--- | :--- | :--- |
| **App Title & Gallery** | `lib/main.dart:336`, `file_manager_transfer.dart:24` | `title: 'Saber'`, `albumPath: 'Saber'` | `'Opennote'` |
| **Sync Defaults & Auth** | `nextcloud_client_extension.dart:18, 22`, `lib/pages/user/login.dart:28` | `nc.saber.adil.hanney.org`, `'Saber/$buildName'` | Opennote Cloud / generic self-hosted URL, `'Opennote/$buildName'` |
| **About & Sponsor URLs** | `lib/components/settings/app_info.dart:20-28` | `github.com/sponsors/adil192`, `saber-notes/saber` | Opennote repo/support URLs (keep GPLv3 upstream credit in About) |
| **Export UI Label** | `lib/components/toolbar/export_bar.dart:68` | `'SBA'` | `'Backup (.sba)'` / `'Opennote Archive'` |
| **Sentry & Pubspec** | `sentry_init.dart:62`, `sentry_filter.dart:11-12`, `pubspec.yaml:257, 269-270` | Saber DSN, `project: saber`, `org: saber-yf`, `adaptive_background_color: "#ffc800"` | Opennote Sentry config & Opennote brand background hex |
| **iOS Project & Icons** | `ios/Runner.xcodeproj/project.pbxproj:542, 560, 576`, `ios/Runner/AppIcon.icon/icon.json`, `assets/icon/{icon,android_feature_graphic}.svg`, `assets/icon/saber_logo_1x1.png` | `com.adilhanney.saber.RunnerTests`, yellow Saber "S" SVGs & 1×1 PNG | `com.opennote.app.RunnerTests`, finalized Opennote vector/Liquid Glass icon; delete `saber_logo_1x1.png`; fix 7 broken 11-byte symlinks in `assets/icon/resized/` |
| **i18n Strings (445)** | `lib/i18n/en.i18n.yaml` (19 lines: `:23, 82, 107, 129, 151, 199, 228, 231, 234, 239, 253, 269, 273-276, 280, 284, 403`) + 24 other `*.i18n.yaml` | `"Welcome to Saber"`, `"adilhanney@disroot.org"`, etc. | `"Opennote"` + Opennote support email (retain `based on Saber © 2022-$buildYear Adil Hanney` at `:284`), then run `dart run slang` |
| **Store Metadata & Docs** | `metadata/{cs,es,he,ja,nl-NL,pl,ru,uk,vi,zh-Hans-CN,zh-Hant-TW}/*.txt`, 19 localized `images/` (228 PNGs), non-phone `en-US/images/` (`3_login`/`4_settings`), `README*.md`, `pricing*.md` | 8 locales titled `"Saber"`, 96 Saber leaks in `README.md`, `adil192` in `pricing.md`, stale Saber screenshots | Full Opennote v2 ASO copy (iOS + Play), 6-slide framed screenshot kit, Opennote Pro `pricing.md`, clean `README.md` |

### 3.2 UNSAFE / HIGH-RISK to Rename Without Migration (DO NOT Blindly Rename)

| Exact Location(s) | Legacy Symbol / Path | Why Unsafe & Required Migration Strategy |
| :--- | :--- | :--- |
| `pubspec.yaml:1` | `name: saber` | Breaks every `package:saber/...` import across all Dart files & tests. Keep as internal package name (per `ROADMAP.md`). |
| `lib/data/file_manager/file_manager.dart:39` | `appRootDirectoryPrefix = 'Saber'` | Existing local `<Docs>/Saber/` and remote `/Saber/` directories depend on this. Must ship a bidirectional read-fallback / migration script before changing. |
| `lib/data/file_manager/note_paths.dart:9, 14`, `AndroidManifest.xml:59-86` | `.sbn2`, `.sbn`, `.sba` extensions | Breaks opening existing notes & backups. Retain permanent read/import support even if adding `.onote` alias later. |
| `lib/data/nextcloud/saber_syncer.dart:557` | `encExtension = '.sbe'` | Breaks discovery/decryption of existing encrypted remote files. |
| `lib/data/nextcloud/nextcloud_client_extension.dart:30, 37` | `configFileName = 'config.sbc'`, `reproducibleSalt` | Immediately breaks decryption of existing synced accounts. Migrate via versioned `config_v2.sbc` when upgrading to Argon2id + AES-256-GCM. |
| `lib/data/sentry/sentry_filter.dart:16`, `saber_version.dart`, `saber_syncer.dart`, `packages/sbn/lib/{quill_styles,font_fallbacks}.dart` | Internal Dart class/const names (`SaberSyncFile`, `SaberVersion`, `SaberQuillStyles`, etc.) | Never user-facing; renaming causes merge churn without user benefit. |
| `android/app/build.gradle.kts:22, 32` | `applicationId = "com.woaiyj1314.opennote"` | **Safe ONLY BEFORE first Google Play publish; immutable after.** Decide on `com.opennote.app` vs. current ID prior to launch. |

---

## 4. Remodularization Target Scoreboard

| File | Current Lines | Coupled Responsibilities | Target Modular Split | Swarm Owner |
| :--- | :---: | :--- | :--- | :--- |
| `lib/components/canvas/_stroke.dart` | **1,043** | Points, RDP, polygon/path gen, BSON/JSON, SVG, snapping, $1 recognition | `canvas/stroke/{geometry, serialization, snapping, simplification}.dart` (<350 lines barrel) | `@remod-canvas` |
| `lib/components/canvas/_canvas_background_painter.dart` | **952** | Viewport quantization, LOD, `Float32List` batching, 9 patterns | `canvas/painters/{grid, lined, dots, music, cornell, isometric}.dart` (<250 lines core) | `@remod-canvas` |
| `lib/pages/editor/editor_ui_builders.dart` | **945** | Opennote + Classic AppBar, Export dialog, BottomSheet, Canvas builders | `editor_app_bar_builder.dart`, `editor_export_dialog.dart`, `editor_sheet_builder.dart` | `@remod-editor-core` |
| `lib/components/toolbar/editor_bottom_sheet.dart` | **888** | 5 unrelated settings cards + inline `TextEditingController`s | `sheet_quick_actions.dart`, `sheet_paper_pattern.dart`, `sheet_canvas_size.dart`, `sheet_import_card.dart` | `@ui-editor-toolbar` |
| `lib/components/editor/page_grid_overview.dart` | **872** | Thumbnail grid, drag-reorder, bookmark filter, duplicated outline parser | Shared `OutlineExtractor` + `PageThumbnailCard` (**already reduced to 213 lines** by `@remod-editor-core`!) | `@remod-editor-core` |
| `lib/data/editor/page.dart` | **796** | `EditorPage`, `Layer`, `QuillStruct`, `Picture` cache, JSON, ephemeral state | `data/editor/page/{serialization, mutation_bounds, background_config}.dart` (<300 lines) | `@remod-gesture-page` |
| `lib/data/prefs.dart` | **751** | Giant monolithic `Stows` mixing sync, theme, tool, gesture, canvas prefs | Domain pref mixins (`SyncPrefs`, `ThemePrefs`, `ToolPrefs`, `GesturePrefs`, `MonetizationPrefs`) | Phase 2 Refactor |
| `lib/components/canvas/canvas_gesture_detector.dart` | **728** | Transform bounds, viewport gating, HUD composition, keybindings | `canvas/gesture_detector/{scale_physics, pointer_routing, inertia, viewport_projection}.dart` (<280 lines) | `@remod-gesture-page` |
| `lib/components/toolbar/toolbar.dart` | **721** | Legacy toolbar maintained in parallel with `OpennoteToolbar` | Extract shared `EditorShortcutController` into `EditorState`; retire legacy toolbar | `@ui-editor-toolbar` |
| `lib/components/home/preview_card.dart` & `notebook_shelf.dart` | **678 / 672** | Cover art, thumbnails, menus, drag targets, creation dialog | Shared `NotebookCoverArt`, `PreviewThumbnailController`, `ShelfFolderChips`, `NewNotebookDialog` | `@ui-home-library` |
| `lib/components/canvas/canvas_image.dart` | **593** | Image drag/pan, 8-handle resize, crop overlay, dialog launcher | `canvas_image_resize_handle.dart`, `canvas_image_crop_overlay.dart` | Phase 2 Refactor |
| `lib/pages/home/browse.dart` & `recent_notes.dart` | **588 / 528** | ~260 lines copy-pasted hero strip & selection dock | Shared `workspace_hero_strip.dart`, `floating_selection_dock.dart` | `@ui-home-library` |
| `lib/components/home/search_dialog.dart` | **581** | UI + main-isolate BSON/Quill/stroke scanning | Isolate-backed `lib/data/search/note_search_service.dart` | `@ui-home-library` |
| `lib/data/editor/editor_core_info.dart` & `select.dart` | **572 / 538** | BSON/SBA migrations; lasso/rect/tap hit-testing | `sbn_migrations.dart`, `sba_archive_codec.dart`, `select_hit_test.dart` | Phase 2 Refactor |

---

## 5. Subscription / IAP Monetization & Conversion Funnel Architecture

### 5.1 Unified Pricing Ladder & Anchoring (Canonical Launch SKUs)

| Plan | StoreKit / Play SKU | Price (USD) | Effective Monthly | Trial | Strategic Role |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Opennote Core (Free)** | — | **$0** | $0.00 | Forever | Generous local-first note-taking, 120Hz core ink, scribble-to-erase, zero ads — fuels 4.8★+ ratings & organic referrals. |
| **Pro Monthly** | `com.opennote.pro.monthly` | **$4.99 / mo** | $4.99 | None | Decoy price anchor ($59.88/yr reference) making Annual look like an immediate **50% savings**; captures exam-week buyers. |
| **Pro Annual *(Default Hero)*** | `com.opennote.pro.annual` | **$29.99 / yr** | **$2.50 / mo** | **7-Day Free Trial** | Primary revenue driver (`SAVE 50% • BEST VALUE`), matches Concepts ($29.99/yr) while delivering cross-platform notebook + engineering drafting + Study Tape. |
| **Student Annual** | `com.opennote.pro.student.annual` | **$14.99 / yr** | **$1.25 / mo** | **7-Day Free Trial** | Campus wedge (50% student discount) directly matching Notability Plus ($14.99/yr) to win STEM/engineering cohorts. |
| **Pro Lifetime Unlock** | `com.opennote.pro.lifetime` | **$69.99 once** | One-time IAP | None | 2.3× Annual anchor capturing subscription-fatigued engineers & Noteful migrants; high immediate cash flow. |

> **Price-Elasticity Testing Note:** Launch globally on the canonical ladder above (`$4.99/mo`, `$29.99/yr`, `$14.99/yr` Student, `$69.99` Lifetime) to maintain 100% parity across `OpennoteProducts.storekit`, `iap_product_catalog.json`, `pricing.md`, `docs/index.html`, and the Paywall UI. Run a prioritized Phase 2 **A/B price-elasticity test** comparing **`$19.99/yr` vs. `$29.99/yr` (control) vs. `$39.99/yr`** (measuring Revenue Per Install = Trial Start % × Trial-to-Paid % × Price) once statistically powered.

### 5.2 Reconciled Free vs. Pro Feature Boundaries (Aligned Across All 4 Audits)

- **Free Core (Never Crippled):** Unlimited local paged notebooks & pages; 120Hz Fountain/Ballpoint/Pencil/Highlighter (behind-ink + straight-line); Object Eraser; Scribble-to-Erase; Circle-to-Select; 6-posture palm rejection; 3 Pen Tray presets; 1 Infinite Canvas whiteboard; 2 Layers per page; basic shapes (line/circle/rect) & straight Ruler/Arrow; Standard paper (Blank, Lined, Grid, Dots); Solid Study Tape (up to 3–5 strips/page); PDF import & annotation (up to 25 pages, 180 DPI); 4–5 saved Elements; Standard PDF/PNG/`.sba` export; Local-only + BYO Nextcloud/WebDAV; Zero ads/trackers.
- **Opennote Pro (High Willingness-to-Pay):**
  1. **Engineering Drafting Suite Pro:** Isometric & Millimeter Engineering Grids, Cornell/Planners/Music templates, Calibrated Dimension Lines (`mm`/`cm`/`in`/`1:50`), Elbow/Curved Connectors, Interactive Magnetic Protractor, Expanded Symbol Packs (EE/Mech/UML/Arch).
  2. **Unlimited Infinite Canvas & Layers:** Unlimited Infinite Canvases, Paged↔Infinite conversion, Unlimited Layers with opacity/reorder/lock, 6+ Pen Tray presets, Dashed/Dotted ink, Precision Stroke-Splitting Eraser.
  3. **Active Recall & PDF Power Tools:** Unlimited Patterned Study Tape + Quiz/Flashcard Mode, Unlimited-page 300+ DPI PDF Textbooks + Dark-Mode PDF Inversion, Unlimited Reusable Element Packs, On-Device Handwriting OCR & Full-Text Ink Search (Phase 2).
  4. **Pro Export & Managed Cloud:** Vector SVG Export, 300–600 DPI / Transparent PNG, Batch Multi-Note & Custom Page-Range PDF Export, Managed Zero-Config E2EE Cloud Sync + Auto-Backup to Google Drive/iCloud/OneDrive + Version History.

### 5.3 Ethical Conversion Surfaces & 2-Step Aha-Moment Review Loop
1. **Passive Discovery:** Top `"Opennote Pro"` Ink-Indigo Hero Card in Settings (`settings_layouts.dart`) + subtle dismissible `"Unlock Opennote Pro"` glass pill in `VerticalNavbar` footer.
2. **First-Run Onboarding (< 45s):** 3-step Tactile Studio personalization (Role → Paper/Posture → Interactive Sample Notebook) → Soft 7-day trial paywall with transparent **3-node trial timeline** (`Today $0` → `Day 5 Reminder` → `Day 7 Billing, Cancel Anytime`), visible `×` / `"Continue with Free"` escape hatch, and Apple 3.1.2 footer (`Restore Purchases`, `Terms of Use`, `Privacy Policy`).
3. **Contextual Pro Gates (Peak Intent):** Trigger a compact feature-specific upgrade sheet when tapping: Pro Paper Templates (Isometric/Cornell), Layer #3+, 2nd Infinite Canvas, Dimension/Protractor/Symbol Packs, Study Tape #4+ / Quiz Mode, Dark-Mode PDF Inversion, or Pro Export options (Vector SVG / Batch / 300 DPI).
4. **2-Step Aha-Moment ASO Rating Funnel:** Triggered strictly after delight milestones (`≥ 3 sessions` AND `[3rd completed PDF/PNG export OR completed Flashcard session OR 5th note across ≥3 active days]`; never after crashes or paywall dismissals; max 1×/90 days):
   - **Step 1:** Soft in-app sentiment check (*"Enjoying Opennote?"*).
   - **Step 2:** Positive → Native `SKStoreReviewController` / Google Play In-App Review; Negative/Neutral → Private feedback / GitHub issue link (deflects 1–2★ bugs from public ratings).

---

## 6. ASO & Revenue Growth 90-Day Playbook

### Phase 1 — Days 1–30: Store Readiness, Brand Purge & Launch Foundation
- **Engineering P0s:** Ship all 25 P0 fixes (shape serialization, light-mode protractor, Circle-to-Select scaling, `OpennoteContextualSubBar` crash, `PresentationMode` touch trap, Android 13+ gallery save, PDF streaming OOM fix, `doBackgroundSync()` fix, iOS `15.0` target + `NSPhotoLibraryAddUsageDescription` + `CFBundleDocumentTypes` + `Runner.entitlements`, finalize Android `applicationId`, remove `fallback-key.jks`).
- **Zero Saber Leaks:** Purge all 445 i18n strings, 11/26 store locales, 96 README leaks, `pricing.md`, `app_info.dart`, and Saber yellow SVGs/icons. Publish updated `docs/index.html` + new `docs/terms.html`.
- **Storefront Launch:** Ship compliant `en-US` iOS (`30/30/98/164`) + Google Play (`30/79/≤4000`) metadata + 6-slide framed visual kit (`iPhone 6.9"`, `iPad 13"`, `Android Phone`, `10" Tablet`, `1024×500` Feature Graphic) via `scripts/aso/generate_store_frames.py`.
- **Monetization v1:** Wire StoreKit 2 + Google Play Billing (RevenueCat or `in_app_purchase`), ship 3-step onboarding + 7-day trial paywall + contextual gates + 2-step Aha-moment rating funnel.
- **Day-30 Targets:** Zero store rejections; Crash-free sessions ≥ 99.5%; Store Page CVR ≥ 35%; Install → Trial ≥ 10%.

### Phase 2 — Days 31–60: Tier-1 Localization, Conversion Tuning & Export/Sync Pro
- **Tier-1 Localization Expansion:** Roll out localized store copy + framed screenshots for `de`, `es`, `fr`, `ja`, `zh-Hans-CN`, `zh-Hant-TW`, `pt-BR`, and `ko-KR`; clear remaining 776 `_missing_translations.yaml` keys.
- **Paywall & Funnel Experimentation:** A/B test Annual price presentation (`$2.50/mo billed annually` vs `$29.99/yr`), **A/B price-elasticity test (`$19.99/yr` vs `$29.99/yr` vs `$39.99/yr`)**, trial timeline copy (7-day vs 14-day), and contextual gate copy on Isometric Grid & Study Tape.
- **Pro Feature Wave 1:** Ship Vector SVG export, 300/600 DPI PNG, Page-Range & Batch PDF export, `config_v2.sbc` (Argon2id + AES-256-GCM), and Auto-Backup to Google Drive / iCloud.
- **Day-60 Targets:** Public rating ≥ 4.7★ (100+ reviews); Trial → Paid ≥ 42%; Lifetime mix 15–25%; Top-15 organic rank for `"isometric notebook"` & `"engineering notes"`.

### Phase 3 — Days 61–90: Marquee Pro Differentiators & Organic Flywheel
- **Pro Feature Wave 2:** Ship On-Device Handwriting OCR & Full-Text Ink Search (ML Kit / Apple Vision), Calibrated Real-World Dimensions (`mm`/`cm`/`in`/`1:50`), Interactive Magnetic Protractor, True Stroke-Splitting Precision Eraser, and Expanded Engineering Symbol Packs.
- **Campus & Creator Distribution:** Launch Student Annual (`$14.99/yr`) campaign targeting STEM/engineering Reddit, StudyTok/YouTube iPad/Galaxy Tab reviewers, and `.sbn2` engineering template packs (organic backlinks + word-of-mouth).
- **Day-90 Targets:** Store Page CVR ≥ 42%; Public rating ≥ 4.8★; Install → Trial 12–15%; Trial → Paid 45–55%; Blended CAC → $0 via compounding organic ASO rank.
