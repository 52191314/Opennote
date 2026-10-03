# Project: Opennote (Goodnotes Parity Student Features)

## Architecture
Opennote (forked from Saber Notes) is a Flutter cross-platform handwritten note-taking application.
- **Document Model**: `EditorCoreInfo` holds `List<EditorPage> pages`, notebook-level metadata (`backgroundColor`, `backgroundPattern`, `lineHeight`, `lineThickness`). Each `EditorPage` maintains `layers` (holding `Stroke` collections), `images` (`EditorImage`), `quill` (`QuillStruct`), and `bookmarked` (`bool`).
- **Rendering Pipeline**: `InnerCanvas` renders `CanvasBackgroundPainter` (paper color & templates), then a Stack of text & embedded images, followed by `CanvasPainter` (foreground vector strokes using Skia/Impeller hardware-accelerated paths).
- **Tools System**: Tools extend `Tool` or `Pen` with a singleton pattern (`Select.currentSelect`, `Highlighter.currentHighlighter`). Tools handle pointer events (`onDragStart`, `onDragUpdate`, `onDragEnd`) and manipulate the active page or current selection.
- **Serialization**: Notebooks serialize to `.sbn2` format using BSON (version 19). Strokes serialize polymorphic shapes (`circle`, `rect`, `arrow`, `dimension`, `polygon`, and now `tape`).

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| F1 | Lasso Filter Preferences | Persistent stows for handwriting, images, and text toggles (`lassoSelectHandwriting`, `lassoSelectImages`, `lassoSelectText`) | M1 | ORIGINAL_REQUEST §R1 |
| F2 | Lasso Filtering Engine | Gating candidate collection in `Select.onDragEnd` and `Select.tapSelect` so disabled types are excluded from selection | M1 | ORIGINAL_REQUEST §R1 |
| F3 | Lasso Options UI | `LassoFilterPopup` dialog with `AdaptiveSwitchListTile` toggles, launched from toolbar and selection bar | M1 | ORIGINAL_REQUEST §R1 |
| F4 | Page Thumbnail Grid View | Responsive `PageGridOverviewDialog` rendering `CanvasPreview` cards with page numbers and active highlight | M2 | ORIGINAL_REQUEST §R2 |
| F5 | Tap-to-Jump Navigation | Single tap on a thumbnail card navigates immediately via `scrollToPage` and dismisses dialog | M2 | ORIGINAL_REQUEST §R2 |
| F6 | Page Drag-and-Drop Reorder | Drag-and-drop reordering of pages in grid view updating page indices and strokes | M2 | ORIGINAL_REQUEST §R2 |
| F7 | Page Actions (Duplicate/Add/Delete) | Duplicate page with deep-copied layers and bug-free undo; add page; guarded delete for single page | M2 | ORIGINAL_REQUEST §R2 |
| F8 | Page Bookmark Indicators & Toggles | Interactive bookmark star badge on each card in grid overview and filter tab (All vs Bookmarked) | M2 | ORIGINAL_REQUEST §R2 |
| F9 | Study Tape Tool & Model | `StudyTape` pen tool and `TapeStroke` model with `isConcealed: bool` state | M3 | ORIGINAL_REQUEST §R3 |
| F10 | Study Tape Rendering | Concealed opaque masking strip vs revealed translucent wash with dashed outline | M3 | ORIGINAL_REQUEST §R3 |
| F11 | Study Tape Tap Interaction | Tap-to-toggle conceal/reveal in canvas with undo/redo and autosave | M3 | ORIGINAL_REQUEST §R3 |
| F12 | Study Tape Serialization | Persistence in `.sbn2` with `'shape': 'tape'` and `'c_state'` with backward compatibility | M3 | ORIGINAL_REQUEST §R3 |
| F13 | Highlighter Behind Ink Layering | Active highlighter painted inside `_drawHighlighterStrokes` layer under ink, and `ToolId.zIndex` sorting in `page.dart` | M4 | ORIGINAL_REQUEST §R4 |
| F14 | Highlighter Hold-to-Straighten | 400ms hold timer during drag triggers line conversion and live snap-to-angle straightening | M4 | ORIGINAL_REQUEST §R4 |
| F15 | Cornell Notes Template Dividing Lines | Canvas background painter with 28% vertical cue column dividing line and 75% horizontal summary dividing line | M5 | ORIGINAL_REQUEST §R5 |
| F16 | Cornell Notes Ruled Layout | Accurate ruled lines in main notes and bottom summary section | M5 | ORIGINAL_REQUEST §R5 |
| F17 | Paper Background Color Options | Presets for Warm Cream (`0xFFFAF4E8`), Legal Pad (`0xFFFFF9B0`), White, and Dark with palette selector in UI | M5 | ORIGINAL_REQUEST §R5 |
| F18 | Comprehensive E2E Verification | 100% pass on E2E test suite (Tiers 1-4) across all features, 0 flutter analyze errors | M6 | ORIGINAL_REQUEST Acceptance Criteria |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| E2E | E2E Testing Suite | Test infrastructure, harness, and comprehensive test cases (Tiers 1-4) | none | DONE |
| M1 | Lasso Selection Filter Toggles | F1, F2, F3: Preferences, filter logic in `Select`, `LassoFilterPopup` UI, unit/widget tests | none | DONE |
| M2 | Page Thumbnail Grid Overview | F4, F5, F6, F7, F8: `PageGridOverviewDialog`, `CanvasPreview` cards, reordering, duplicate bugfix, bookmarks, tests | none | DONE |
| M3 | Study Tape Active-Recall Tool | F9, F10, F11, F12: `ToolId.studyTape`, `TapeStroke`, rendering (conceal/reveal), tap toggle, `.sbn2` serialization, tests | none | PLANNED |
| M4 | Highlighter Behind Ink & Auto-Straighten | F13, F14: Active stroke layering, `ToolId.zIndex` sorting, 400ms hold timer, live line straightening, tests | none | PLANNED |
| M5 | Paper Templates & Styling | F15, F16, F17: Cornell cue (28%) & summary (75%) dividing lines, ruled lines, Cream and Legal Pad paper colors, tests | none | PLANNED |
| M6 | Final Verification & Audit | F18: Pass 100% of E2E tests, zero `flutter analyze` errors, Forensic Audit clean verdict | E2E, M1, M2, M3, M4, M5 | PLANNED |

## Interface Contracts

### `packages/sbn/lib/tool_id.dart`
- `ToolId.studyTape('StudyTape')` added to enum `ToolId`.
- Extension `ToolIdZIndex on ToolId`:
  ```dart
  int get zIndex => switch (this) {
    ToolId.highlighter => 0,
    ToolId.studyTape => 2,
    _ => 1,
  };
  ```

### `lib/data/prefs.dart` (Stows)
- `final PlainStow<bool> lassoSelectHandwriting = PlainStow('lassoSelectHandwriting', true, volatile: !_isOnMainIsolate);`
- `final PlainStow<bool> lassoSelectImages = PlainStow('lassoSelectImages', true, volatile: !_isOnMainIsolate);`
- `final PlainStow<bool> lassoSelectText = PlainStow('lassoSelectText', true, volatile: !_isOnMainIsolate);`

### `lib/components/canvas/_tape_stroke.dart`
- `class TapeStroke extends Stroke`:
  - `bool isConcealed;` (default `true`)
  - `Map<String, dynamic> toJson()` -> contains `'shape': 'tape'`, `'c_state': isConcealed`
  - `static TapeStroke fromJson(...)`

### `lib/components/editor/page_grid_overview.dart`
- `class PageGridOverviewDialog extends StatefulWidget`:
  - `final EditorCoreInfo coreInfo;`
  - `final int currentPageIndex;`
  - `final void Function(int pageIndex) scrollToPage;`
  - `final void Function() redrawAndSave;`
  - `final void Function(int pageIndex) duplicatePage;`
  - `final void Function(int pageIndex) deletePage;`
  - `final void Function(int pageIndex) insertPageAfter;`

### Paper Color Constants
- `const Color paperColorPureWhite = Color(0xFFFFFFFF);`
- `const Color paperColorCleanWhite = Color(0xFFFCFCFC);`
- `const Color paperColorWarmCream = Color(0xFFFAF4E8);`
- `const Color paperColorLegalPad = Color(0xFFFFF9B0);`
- `const Color paperColorDarkSlate = Color(0xFF1E1E1E);`

## Code Layout
- `lib/data/prefs.dart`: Stow preference definitions
- `lib/data/tools/`: Tool definitions (`select.dart`, `highlighter.dart`, `study_tape.dart`, `page_templates.dart`)
- `lib/components/toolbar/`: Toolbar UI components (`toolbar.dart`, `selection_bar.dart`, `lasso_filter_popup.dart`, `editor_bottom_sheet.dart`)
- `lib/components/editor/`: Editor modals (`page_grid_overview.dart`, `template_picker_dialog.dart`)
- `lib/components/canvas/`: Canvas rendering and stroke models (`_canvas_painter.dart`, `_canvas_background_painter.dart`, `_stroke.dart`, `_tape_stroke.dart`, `canvas_preview.dart`, `inner_canvas.dart`)
- `lib/data/editor/`: Document data models (`page.dart`, `editor_core_info.dart`, `editor_history.dart`)
- `lib/pages/editor/`: Main editor screen (`editor.dart`)
- `packages/sbn/lib/`: Core cross-platform types (`tool_id.dart`, `canvas_background_pattern.dart`)
- `test/`: Unit, component, and E2E tests
