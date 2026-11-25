# Opennote — Editor UX, Home, Library, Navigation & Settings Audit

**Auditor:** `audit-editor-home` (Read-Only UI/UX Audit)  
**Scope:** `lib/pages/**`, `lib/components/{editor,toolbar,home,navbar,onboarding,settings,design_system,theming}/**`, `lib/data/file_manager/**`, `lib/data/prefs.dart`  
**Benchmark Apps:** GoodNotes 6, Notability, Concepts, Craft  
**Maturity Scale:** `1` (Broken / Prototype) · `2` (Functional Legacy / High Friction) · `3` (Usable / Inconsistent Polish) · `4` (Strong / Minor Gaps) · `5` (Flagship Studio Grade)

---

## Executive Summary & Overall Scorecard

Opennote has made substantial architectural strides away from its upstream Saber fork—introducing `OpennoteTokens`, `OpennoteHeaderBar`, a dual-tier `OpennoteToolbar`, `NotebookShelf`, `PageGridOverviewDialog`, and a two-pane Settings studio. However, the UI currently suffers from **two competing design eras** (legacy Material/Saber vs. Opennote Tactile Studio), **multiple P0 runtime/interaction bugs**, **pervasive hardcoded English strings**, **visible Saber/Nextcloud branding leaks**, and **zero monetization or rating conversion surfaces**.

| Surface Area | Maturity (1–5) | Top Critical Issue |
| --- | :---: | --- |
| 1. First-Run Onboarding & Time-to-First-Note | **2.0** | 3 startup dialogs fire concurrently without `await` (`home.dart:48-50`) |
| 2. Home, Library, Shelf, Search & Templates | **2.5** | ~260 lines duplicated hero/dock, broken Shelf menu labels, `Quick Note` overwrites `Untitled`, `Spacer()` layout bug in Search |
| 3. Navigation (Phone Bar vs. Tablet/Desktop Rail) | **3.5** | `HorizontalNavbar` still uses legacy M3 `primaryContainer` pill; `VerticalNavbar` hardcodes English & `⌘K` on non-macOS |
| 4. Editor Chrome, Toolbars, Sheets & Export | **2.5** | **P0 RenderFlex crash** in `OpennoteContextualSubBar` text mode; **P0 touch-blocking overlay** in `PresentationMode`; double drag handle & unconfirmed `Clear All` |
| 5. Settings, Login, Logs & Design System | **3.0** | `OpennoteGlassPill` & `OpennoteSegmentedBar` unused by editor; legacy `nc.saber.adil.hanney.org` login & `adil192` sponsor URL |
| 6. Brand Hygiene & Monetization Readiness | **1.5** | Saber leaks in URLs/paths/SBA export; zero Pro paywall surfaces, contextual gates, or in-app review triggers |

---

## 1. First-Run Onboarding & Time-to-First-Note Friction

**Maturity Score: 2.0 / 5**

### Findings
- **P0 — Concurrent Startup Dialog Collision** (`lib/pages/home/home.dart:45-51`):  
  `_showDialogs()` invokes `UpdateManager.showUpdateDialog(context)`, `SentryConsentDialog.showIfNeeded(context)`, and `WelcomeOnboardingDialog.showIfNeeded(context)` without `await`. On first launch, all eligible dialogs stack simultaneously on the navigator, forcing users to dismiss overlapping modals before seeing the app.
- **P1 — Static, High-Friction 4-Page Modal Onboarding** (`lib/components/onboarding/welcome_onboarding_dialog.dart:14-350`):
  - `stows.hasSeenOnboarding.value = true` is persisted **before** `await show(context)` completes (line 21); if the app backgrounds or closes mid-flow, onboarding is lost.
  - Uses 4 hardcoded off-brand accent colors (`0xFF6750A4`, `0xFF00677D`, `0xFFB52700`, `0xFF006C4C`, lines 46–79) and generic Material icons instead of `OpennoteTokens` or interactive stroke/paper previews.
  - "Try Playground" (`_finishOnboarding(true)`, lines 90–96) simply calls `context.push(RoutePaths.edit)` — opening an empty blank note rather than a pre-populated interactive sandbox (with sample tape, shapes, and scribble-to-erase targets).
  - Misses high-value personalization: writing posture (left/right hand), default paper template, and stylus vs. finger mode.
- **P1 — Dead-End Empty States** (`lib/components/home/welcome.dart:8-60`, `lib/components/home/no_files.dart:5-32`):
  - Both screens render generic unDraw SVGs (`undraw_learning_sketching_nd4f.svg`, `undraw_researching_re_fuod.svg`) and static text (`t.home.createNewNote`) with **zero inline CTA buttons** (no "New Notebook", "Import PDF", or "Choose Template").
  - Visual mismatch: `Welcome` wraps content in a bordered `surfaceContainerLow` card (`welcome.dart:18-27`), whereas `NoFiles` renders raw unstyled text with a `64px` gap (`no_files.dart:14-28`).

### Redesign Recommendations
- **P0:** Serialize `_showDialogs()` with `await` and a `mounted` check between each step; defer `SentryConsentDialog` until after the user's first note or session 2 so first-run time-to-first-note is < 5 seconds.
- **P1:** Replace `WelcomeOnboardingDialog` with a 3-step full-bleed Tactile Studio flow: (1) Hand Posture & Input Mode, (2) Paper Style & Theme preview, (3) "Open Interactive Sample Notebook" (bundled `.sbn2` playground) vs. "Start Blank Note".
- **P1:** Unify `Welcome` and `NoFiles` into a single `EmptyLibraryState` component featuring custom studio illustrations and 3 tactile CTAs (`New Note`, `From Template`, `Import PDF`).

---

## 2. Home, Recent Notes, Browse, Folders, Whiteboard, Preview Cards, Search & Templates

**Maturity Score: 2.5 / 5**

### Findings
- **P0 — `BrowsePage` "Quick Note" Overwrites/Reopens `Untitled`** (`lib/pages/home/browse.dart:341-347`):  
  When inside a subfolder (`createPath != null`), tapping "Quick Note" calls `context.push(RoutePaths.editFilePath('$createPath/Untitled'))` without `FileManager.newFilePath` or `suffixFilePathToMakeItUnique`. Repeated taps reopen the same `Untitled` file instead of creating a new note.
- **P0 — Broken Localized Menu Labels in `NotebookShelf`** (`lib/components/home/notebook_shelf.dart:216, 497`):  
  - Notebook 3-dot menu "Open" action displays `Text(t.home.tabs.home)` (**"Home"**) instead of "Open" (line 497).
  - Folder chip 3-dot menu "Open" action displays `Text(t.home.tabs.browse)` (**"Browse"**) instead of "Open" (line 216).
  - `onRename` callback passes `(note, note)` (line 285), and cover colors derive from `note.hashCode.abs()` (line 282; also `preview_card.dart:533`), which is not guaranteed stable across Dart VM restarts.
- **P0 — Uncaught String Exception in `NewNoteButton`** (`lib/components/home/new_note_button.dart:120-126`):  
  Picking an unsupported file shows a `SnackBar` and then executes `throw 'Invalid file type';` inside an async `onTap`, generating unhandled error crashes/Sentry noise.
- **P1 — `SearchDialog` Layout & iOS SafeArea Bugs** (`lib/components/home/search_dialog.dart:411-522`):
  - Line 503 places `const Spacer()` inside a `Column(mainAxisSize: MainAxisSize.min)` when query length < 2, stretching the dialog awkwardly with blank space instead of showing recent searches or filter chips.
  - `_buildCupertino` delegates directly to `_buildMaterial` (lines 519–522) while line 414 sets `insetPadding: EdgeInsets.zero` with no `SafeArea`, clipping into the iOS status bar / Dynamic Island.
  - Content search scans every `.sbn2` file sequentially on the main isolate (`search_dialog.dart:152-178`) with only a `1ms` yield every 3 files, causing jank on large libraries; no sort or filter controls exist on `RecentPage` or `BrowsePage`.
- **P1 — Misleading Labels & Hardcoded Copy Across Home/Browse**:
  - `recent_notes.dart:207` displays hardcoded `'Jump Back In — Pinned & Recent Shelf'` despite **no pinning/favorites feature existing**.
  - `recent_notes.dart:284-312` and `browse.dart:338-371` hardcode English hero card copy (`Quick Note`, `Infinite Board`, `Shelf View`, `Search Notes`) and duplicate ~260 lines verbatim (`_WorkspaceHeroStrip`, `_HeroActionCard`, `_FloatingSelectionDock`).
  - `recent_notes.dart:290-294` labels the single global `/_whiteboard` (`lib/pages/home/whiteboard.dart:14`) as **"Infinite Board / Freeform Canvas"**, creating user confusion when it reopens the shared scratchpad (or auto-clears if `autoClearWhiteboardOnExit` is on).
- **P1 — `GridFolders` Gesture Conflict & Wrong Tooltip** (`lib/components/home/grid_folders.dart:198, 333-375`):  
  The 3-dot button tooltip is `t.home.tabs.settings` ("Settings", line 198). Long-pressing a real folder fires both `LongPressDraggable` (200ms) and `GestureDetector.onLongPress` (line 370).
- **P1 — `NotebookShelf` Feature Parity Gap vs. `PreviewCard`**:  
  `NotebookShelf` (`notebook_shelf.dart`) lacks multi-selection, export, move-to-folder menu items, live page-1 thumbnail rendering, and custom cover color/style selection. Meanwhile, `PreviewCard` (`preview_card.dart:352`) hardcodes `'Deselect'`/`'Select'` and lacks a "Duplicate" or "Pin/Favorite" action.
- **P2 — `TemplatePickerDialog` Buried & Basic** (`lib/components/editor/template_picker_dialog.dart:45-80`):  
  Only reachable from inside an open note's bottom sheet (not from Home/Browse FAB or "+ New Notebook"), has no category tabs (Study, Planners, Grids, Music, Engineering), and no paper color/size selector.

### Redesign Recommendations
- **P0:** Fix `BrowsePage` Quick Note to use `FileManager.newFilePath('$createPath/')`; fix `NotebookShelf` menu strings; remove `throw 'Invalid file type';` in `NewNoteButton`.
- **P0:** Fix `SearchDialog` `Spacer()` (replace with a compact empty-query state showing recent searches & quick filter pills: *Handwriting*, *Typed Text*, *PDFs*, *Bookmarked*) and wrap Cupertino search in `SafeArea`.
- **P1:** Extract shared `WorkspaceHeroStrip` and `FloatingSelectionDock` into `lib/components/home/`; localize all strings; add real **Note Pinning / Favorites** and **Sort/Filter bar** (Modified, Name, Kind) to `RecentPage` and `BrowsePage`.
- **P1:** Upgrade `NewNoteButton` SpeedDial with `New from Template` and `New Infinite Canvas`, and align FAB bottom offset with `HorizontalNavbar.clearanceHeightOf(context)` so FAB, `TrashDropZone`, and `_FloatingSelectionDock` never overlap on phones.

---

## 3. Navigation (Phone Bottom Bar vs. Tablet/Desktop Rail)

**Maturity Score: 3.5 / 5**

### Findings
- **P1 — Visual Disconnect in `HorizontalNavbar`** (`lib/components/navbar/horizontal_navbar.dart:81-150`):
  - On Android/Windows/Linux, `GlassyContainer` uses solid `colorScheme.primaryContainer` (legacy Saber pill, line 102) instead of `OpennoteGlassPill`.
  - On iOS/macOS, `BackdropFilter` uses `sigmaX: 2, sigmaY: 2` (line 135 — barely visible blur) with a harsh `shadow.withValues(alpha: 0.5)` (line 113).
  - `clearanceHeightOf` (`horizontal_navbar.dart:25-30`) relies on magic arithmetic (`+ 16 + 16 - 8`) rather than shared layout constants.
- **P1 — Hardcoded Strings & macOS-Only Shortcut Badge in `VerticalNavbar`** (`lib/components/navbar/vertical_navbar.dart:93-190, 298`):
  - Hardcodes `'Opennote Studio'`, `'Workspace'`, `'Collapse sidebar'`, `'Expand sidebar'`, `'Cloud Sync'`.
  - Displays `'⌘K'` (line 182) on **all** platforms (including Windows, Linux, Android tablets, and iPads without keyboards), and `Cmd+K` / `Ctrl+K` is not bound globally in `ResponsiveNavbar`.
- **Strengths:** `ResponsiveNavbar` (`lib/components/navbar/responsive_navbar.dart:57-64`) cleanly handles `LayoutSize.{auto,phone,tablet}` at the `600px` breakpoint and properly guards unsaved `Whiteboard` transitions (lines 31–47).

### Redesign Recommendations
- **P1:** Rebuild `HorizontalNavbar` on top of `OpennoteGlassPill` (`blurSigma: 16`, `OpennoteTokens.floatingShadow`) so phone navigation matches the Tactile Studio language across iOS and Android.
- **P1:** Localize `VerticalNavbar`, show `Ctrl+K` on Windows/Linux and `⌘K` on macOS (hide on touch-only tablets), and wire a real `CallbackShortcuts` listener for `Cmd/Ctrl+K` -> `SearchDialog.show(context)`.

---

## 4. Editor Chrome, Floating Toolbars, Contextual Sub-Bars, Bottom Sheet, Page Grid & Export UX

**Maturity Score: 2.5 / 5**

### Findings
- **P0 — RenderFlex Crash in `OpennoteContextualSubBar` Text Mode** (`lib/components/toolbar/opennote/contextual_sub_bar.dart:82-143`):  
  When `actions.textEditing` is active and `quill != null`, line 129 returns `Expanded(child: QuillSimpleToolbar(...))` inside a `Row(mainAxisSize: MainAxisSize.min)` inside a horizontal `SingleChildScrollView`. Flutter throws an unbounded-width `RenderFlex` layout exception whenever a user focuses text in Opennote Studio mode.
- **P0 — `PresentationMode` Touch-Blocking Overlay & Broken Flashcard Logic** (`lib/components/editor/presentation_mode.dart:133-139, 182-277, 283-298`):
  - Lines 270–276 place a full-screen `Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.opaque, ...))` **on top of** the controls overlay (Exit, Reset, Know, Don't Know). Every tap on those buttons is swallowed by the `GestureDetector`, trapping touch users in fullscreen mode.
  - `_markStudied(bool known)` (lines 133–139) ignores `known` completely — both "Know" and "Don't Know" mark the page studied.
  - `_buildCardBack` (line 294) has `angle < math.pi / 2 ? child : child` and never animates the transition to the revealed page.
- **P0 — Missing Keyboard Shortcuts & Fullscreen Toggle in `OpennoteToolbar`** (`lib/components/toolbar/opennote_toolbar.dart`, `lib/components/toolbar/toolbar.dart:95-125`):  
  Switching to `OpennoteToolbar` (the default via `stows.opennoteUiMode = true`) silently drops all keyboard shortcuts (`Ctrl+F`, `Ctrl+E`, `Ctrl+C`, `Ctrl+Shift+S`, `F11`, `Ctrl+V`) and removes the fullscreen toggle button from the editor UI.
- **P1 — Tool Singleton Identity Violations** (`lib/pages/editor/editor.dart:213, 221-225`, `lib/components/toolbar/opennote/primary_tool_dock.dart:170`, `lib/components/toolbar/pen_modal.dart:57, 85, 113`):  
  Direct re-instantiation of `Eraser(size: ...)`, `Ruler()`, `ArrowTool()`, `DimensionTool()`, `Pen.fountainPen()`, `Pen.ballpointPen()`, and `ShapePen()` violates the project's **Tool State Singleton Identity** invariant (`AGENTS.md`), risking stale toolbar highlight states.
- **P1 — `EditorBottomSheet` Polish & Safety Bugs** (`lib/components/toolbar/editor_bottom_sheet.dart` + `lib/pages/editor/editor_ui_builders.dart:389`):
  - **Double drag handle**: `showModalBottomSheet(..., showDragHandle: true)` stacks on top of the manual drag pill at `editor_bottom_sheet.dart:146-155`.
  - **Inline `TextEditingController` leak** (`editor_bottom_sheet.dart:557-559, 587-589`): new controllers are instantiated inside `build()` on every rebuild without disposal.
  - **Unconfirmed destructive actions** (`editor_bottom_sheet.dart:212-238`): `Clear Page` and `Clear All` sit inside the top 2×4 quick-action grid with no confirmation dialog, unlike `OpennoteEraserSubBar._confirmClearPage` (`eraser_sub_bar.dart:21-43`).
- **P1 — Editor Chrome Inconsistencies**:
  - `OpennoteHeaderBar` (`opennote_header_bar.dart:92-106`), `OpennotePrimaryToolDock` (`primary_tool_dock.dart:82-96`), and `OpennoteContextualSubBar` (`contextual_sub_bar.dart:65-79`) all hand-roll opaque `Container` pills instead of using `OpennoteGlassPill`.
  - On `screenWidth >= 600`, `OpennoteHeaderBar` renders **both** a left Back chevron (line 138) and a center-pill Close `×` button (lines 301–317) that invoke the exact same `onBack` callback.
  - `OpennotePrimaryToolDock` hardcodes `'Dock toolbar Bottom'` / `'Dock toolbar Top'` tooltips (lines 332–333) and lacks a quick vertical (left/right) dock option.
- **P1 — Barebones Export UX** (`lib/components/toolbar/export_bar.dart:60-88`, `lib/pages/editor/editor_ui_builders.dart:656-715`):  
  Presents 3 unlabeled `TextButton`s (`SBA`, `PDF`, `PNG`) with no format subtitles, no page-range picker (Current / All / Bookmarked), no paper-background toggle, no dark-mode inversion option, and exposes legacy `'SBA'` (Saber Archive) branding.
- **P2 — `PageGridOverviewDialog` & `LayerManager` Gaps**:
  - `PageGridOverviewDialog` (`page_grid_overview.dart:198-218`) duplicates `DocumentOutlineView` (`lib/components/editor/outline_overlay.dart:52-71`), uses M3 `SegmentedButton` instead of `OpennoteSegmentedBar`, and lacks multi-page batch selection (delete/duplicate/export selected pages).
  - `LayerManager` (`lib/components/editor/layer_manager.dart:107`) uses index-based `ValueKey('layer_$index')` inside `ReorderableListView` (breaking reorder animations) and lacks layer renaming and opacity sliders.

### Redesign Recommendations
- **P0:** Fix `OpennoteContextualSubBar` text mode by wrapping `QuillSimpleToolbar` in a `SizedBox(width: ...)` or replacing the outer `SingleChildScrollView` when in text mode.
- **P0:** Fix `PresentationMode` by moving the `GestureDetector` **below** the controls overlay in the `Stack`, implementing real `known` vs. `reviewAgain` tracking, and animating front/back card flip properly.
- **P0:** Move editor keyboard shortcuts out of legacy `Toolbar` into `EditorState` (shared by both toolbars), add a fullscreen toggle to `OpennoteHeaderBar`, and remove the redundant `×` button.
- **P1:** Wrap `EditorBottomSheet` `Clear Page` / `Clear All` in confirmation dialogs (or move them out of the top bento grid into a bottom "Danger Zone" row), remove the duplicate drag handle, and hoist page-size `TextEditingController`s into State fields.
- **P1:** Redesign `_showExportDialog` into a flagship Export Sheet (GoodNotes-style): visual cards for **PDF Document**, **High-Res Images (PNG)**, and **Opennote Backup (`.ona`/`.sba`)**, with page-range selector and "Include Paper Background" toggle.

---

## 5. Settings, Login, Logs, Design System & Visual Polish vs. Flagship Apps

**Maturity Score: 3.0 / 5**

### Findings
- **P1 — Settings Search & Localization Gaps** (`lib/pages/home/settings/settings_category.dart:7-53`, `settings_sections.dart:53-54, 215-217, 435`):
  - `SettingsCategory` labels and `searchKeywords` are 100% hardcoded English, breaking non-English localization.
  - Searching in Settings filters only at the **whole-card** level (`settings.dart:111-132`), not individual settings rows—searching `"scribble"` still dumps the entire 12-item Gestures card without highlighting or filtering to the matching toggle.
  - Hardcoded English strings in `settings_sections.dart`: `'Cloud & Storage'`, `'Connected'`, `'Local Only'`, `'Opennote Studio UI'`, `'About & Diagnostics'`.
- **P1 — Legacy Nextcloud-Only Login & Sync UX** (`lib/pages/user/login.dart:27-29`, `lib/components/settings/nextcloud_profile.dart:19-151`):
  - `NcLoginPage.signupUrl` points directly to upstream Saber's server (`https://nc.saber.adil.hanney.org/index.php/apps/registration/`).
  - Requires a 2-step Nextcloud server + separate E2E encryption password flow with zero consumer cloud options (iCloud, Google Drive, OneDrive, WebDAV) — a major barrier vs. GoodNotes/Notability/Craft.
- **P2 — `LogsPage` Diagnostics Polish** (`lib/pages/logs.dart:43-239`):
  - Uses legacy unDraw SVG, lacks severity filter chips (Info / Warning / Error), lacks a Share/Export `.log` button, and copying to clipboard (`lines 109-111`) gives zero `SnackBar` confirmation.
- **P1 — Design System Fragmentation** (`lib/components/design_system/*`, `lib/components/theming/saber_theme.dart`):
  - `OpennoteTokens` (`opennote_tokens.dart`) defines strong Tactile Studio palette & spacing (`#F6F5F1` Alabaster, `#121316` Obsidian, `#3B5BDB` Ink Indigo), and `OpennoteGlassPill` / `OpennoteSegmentedBar` are cleanly built—yet **neither widget is used** in `OpennoteHeaderBar`, `OpennoteToolbar`, `HorizontalNavbar`, `PageGridOverviewDialog`, or `EditorBottomSheet`.
  - Missing tokens: **Typography scale** (editorial display/heading/caption styles), **Semantic colors** (success, warning, destructive, Pro gold/accent), and **Motion/Duration tokens**.
  - `SaberTheme.createTheme` (`saber_theme.dart:17-23`) blends `colorScheme.surface` with `studioLightSurface`/`studioDarkSurface` at `0.45`, muddying the warm alabaster / obsidian tone when dynamic color is active.
- **Visual Polish Gaps vs. Flagship Apps (GoodNotes 6 / Notability / Concepts / Craft):**
  - *Typography & Hierarchy*: Heavy reliance on default `Typography.material2021` without editorial letter-spacing/weight tokens.
  - *Micro-interactions*: Tool switching lacks animated ink-tip elevation (GoodNotes/Apple PencilKit style); notebook covers lack subtle tilt/press feedback and real page-1 preview overlays.
  - *Dual-UI Drag*: Maintaining both legacy `Toolbar` / Classic `AppBar` and `OpennoteToolbar` / `OpennoteHeaderBar` splits polish effort and introduces parity bugs.

---

## 6. Leftover "Saber" UX/Branding Leaks

| Severity | File & Line | Leak / Artifact | Recommended Fix |
| :---: | --- | --- | --- |
| **P0** | `lib/pages/user/login.dart:28` | `https://nc.saber.adil.hanney.org/index.php/apps/registration/` | Replace with Opennote Cloud / generic self-hosted WebDAV/Nextcloud URL |
| **P0** | `lib/components/settings/app_info.dart:20-28` | `sponsorUrl` (`github.com/sponsors/adil192`) & `licenseUrl` (`saber-notes/saber`) | Point to Opennote repo/sponsor/license while retaining upstream attribution in About |
| **P1** | `lib/data/file_manager/file_manager.dart:39` | `appRootDirectoryPrefix = 'Saber'` | Plan non-breaking migration to `'Opennote'` with legacy `'Saber'` read fallback |
| **P1** | `lib/data/file_manager/file_manager_transfer.dart:24` | `albumPath: 'Saber'` (saved gallery album name!) | Change exported image album name to `'Opennote'` |
| **P1** | `lib/components/toolbar/export_bar.dart:68` & `lib/pages/editor/editor_media_import.dart:482` | Export button labeled `'SBA'` ("Saber Archive") | Label as `Backup (.sba)` or `Opennote Archive` in UI |
| **P2** | `lib/components/theming/saber_theme.dart:10` | `SaberTheme` class & file name | Rename to `OpennoteTheme` in dedicated refactor |
| **P2** | `lib/pages/home/settings/settings_category.dart:27` & `settings_sections.dart:56` | `NextcloudProfile` & `'nextcloud'` search keyword | Abstract behind `CloudSyncProfileCard` |

---

## 7. Mega-File Remodularization Hotspots

| File | Lines | Core Problem | Recommended Split |
| --- | :---: | --- | --- |
| `lib/pages/editor/editor_ui_builders.dart` | **945** | Mixes Opennote + Classic AppBar, Export dialog, BottomSheet wiring, Canvas builders | Split into `editor_app_bar_builder.dart`, `editor_export_dialog.dart`, `editor_sheet_builder.dart` |
| `lib/components/toolbar/editor_bottom_sheet.dart` | **888** | Monolithic sheet with 5 unrelated cards + inline controllers | Split into `sheet_quick_actions.dart`, `sheet_paper_pattern.dart`, `sheet_canvas_size.dart`, `sheet_import_card.dart` |
| `lib/components/editor/page_grid_overview.dart` | **872** | Combines thumbnail grid, drag-reorder, bookmark filter, and duplicated outline parser | Share `OutlineExtractor` with `outline_overlay.dart`; extract `PageThumbnailCard` |
| `lib/data/prefs.dart` | **751** | Single giant `Stows` class mixing sync, theme, tool, gesture, and canvas prefs | Group into domain pref mixins (`SyncPrefs`, `ThemePrefs`, `ToolPrefs`, `GesturePrefs`) |
| `lib/components/toolbar/toolbar.dart` | **721** | Legacy toolbar maintained in parallel with `OpennoteToolbar` | Deprecate or extract shared `EditorShortcutController` and retire legacy UI |
| `lib/components/home/preview_card.dart` | **678** | Thumbnail caching, selection overlay, 3-dot menu, drag feedback, and Moleskine fallback | Extract `NotebookCoverArt` (shared with `NotebookShelf`) and `PreviewThumbnailController` |
| `lib/components/home/notebook_shelf.dart` | **672** | Folder chips, shelf covers, drag targets, and creation dialog in one file | Extract `ShelfFolderChips`, `NotebookCoverTile`, `NewNotebookDialog` |
| `lib/pages/home/browse.dart` & `recent_notes.dart` | **588 / 528** | ~260 lines copy-pasted (`_WorkspaceHeroStrip`, `_FloatingSelectionDock`) | Extract `lib/components/home/workspace_hero_strip.dart` & `floating_selection_dock.dart` |
| `lib/components/home/search_dialog.dart` | **581** | UI + BSON file scanning + Quill delta parsing + stroke scanning on main isolate | Move search engine to `lib/data/search/note_search_service.dart` (isolate-backed) |

---

## 8. High-Converting UI Placement Opportunities (Pro Upgrade, Contextual Gates & Review Prompts)

Opennote currently has **zero** monetization UI, Pro upgrade placements, or App Store / Play Store review prompts. Below are the highest-converting, low-friction placements aligned with GoodNotes 6 / Notability / Craft patterns:

### A. Pro Upgrade Banners & Plan Cards (Passive Discovery)
1. **Settings Top Pro Card** (`lib/pages/home/settings/settings_layouts.dart` & `settings_sections.dart`):  
   Place a sleek Ink-Indigo Tactile Studio **"Opennote Pro"** hero card at the top of the Settings rail/list (above `Cloud & Storage`) showing active plan status (`Free Studio` vs. `Pro`), unlocked features, and a single `Upgrade` CTA.
2. **Vertical Sidebar Footer Upgrade Pill** (`lib/components/navbar/vertical_navbar.dart:268-315`):  
   Above the `Cloud Sync` footer in the expanded tablet/desktop rail, place a subtle dismissible `Unlock Opennote Pro` glass pill highlighting Cross-Device Sync + Unlimited Templates.
3. **Onboarding Soft Offer** (`lib/components/onboarding/welcome_onboarding_dialog.dart`):  
   On the final onboarding step, offer a non-blocking `"Start 7-Day Free Pro Trial"` primary CTA alongside `"Continue with Free"`.

### B. Contextual Pro Gates (Peak Intent Moments)
1. **Premium Paper Templates & Planners** (`lib/components/editor/template_picker_dialog.dart`):  
   Keep core templates (Blank, Lined, Grid, Dotted) free; badge premium templates (Cornell Study, Daily/Weekly Planners, Music Staff, Isometric Engineering, Custom PDF Templates) with a subtle Pro lock pill that opens a contextual mini-paywall showing a live preview.
2. **Pro Export Controls** (`lib/components/toolbar/export_bar.dart` / `editor_ui_builders.dart:656-715`):  
   Keep standard PDF/PNG export free; gate **Batch Multi-Note PDF Export**, **Custom DPI / Vector PDF**, and **Flattened/No-Background Export** behind a contextual Pro toggle.
3. **Advanced Study & Layer Tools** (`lib/components/editor/layer_manager.dart`, `lib/components/toolbar/elements_sheet.dart`, `lib/components/editor/presentation_mode.dart`):  
   Allow 2 layers per page and 5 saved Elements free; trigger a contextual Pro sheet when tapping `+ Add Layer` (3+) or saving a 6th reusable Element, or unlocking Spaced-Repetition Flashcard stats.
4. **Infinite Canvas & Multi-Cloud Sync** (`lib/components/toolbar/editor_bottom_sheet.dart:484-505`, `lib/components/settings/nextcloud_profile.dart`):  
   Allow local/Nextcloud sync free; position **One-Tap iCloud / Google Drive Sync** and **Unlimited Infinite Canvases** as flagship Pro upgrades.

### C. In-App Review Prompts (Peak Delight Moments)
Never prompt on cold launch or mid-stroke. Add a `reviewPromptCount` + `lastReviewPromptDate` + `notesExportedCount` stow in `lib/data/prefs.dart` and trigger native `SKStoreReviewController` / Google Play In-App Review (max once per 90 days) after:
1. **Successful PDF/PNG Export** (`lib/pages/editor/editor_media_import.dart` / `export_bar.dart`) — on the user's **3rd completed export**.
2. **Completed Flashcard Study Session** (`lib/components/editor/presentation_mode.dart`) — when the user finishes reviewing all cards in a deck.
3. **Library Milestone** (`lib/pages/home/recent_notes.dart`) — on returning to Home after creating/editing their **5th distinct note** across ≥3 active days.
