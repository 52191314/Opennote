# TEST_READY: Opaque-Box E2E Test Suite (Opennote)

Date: 2026-10-03
Author: E2E Test Writer (specialist, qa)
Status: **COMPLETE & VERIFIED** (183 / 183 tests passing)

---

## 1. Test Runner & Execution

### Complete E2E Suite Run:
```bash
flutter test test/e2e/
```

### Student Parity Features F1–F17 Suite Run (Current Milestone):
```bash
flutter test test/e2e/e2e_feature_coverage_test.dart test/e2e/e2e_boundary_cases_test.dart test/e2e/e2e_cross_feature_test.dart test/e2e/e2e_student_workflow_test.dart
```

### Individual Suite Files:
```bash
# Student Parity Features F1–F17 (68 tests)
flutter test test/e2e/e2e_feature_coverage_test.dart   # Tier 1: F1–F17 Feature Coverage (35 tests)
flutter test test/e2e/e2e_boundary_cases_test.dart      # Tier 2: Boundary & Corner Cases (18 tests)
flutter test test/e2e/e2e_cross_feature_test.dart       # Tier 3: Pairwise Combinations (10 tests)
flutter test test/e2e/e2e_student_workflow_test.dart    # Tier 4: Real-World Student Workflows (5 tests)

# Pre-Existing Core & Drafting Suites (115 tests)
flutter test test/e2e/e2e_core_and_pdf_test.dart
flutter test test/e2e/e2e_grid_and_snap_test.dart
flutter test test/e2e/e2e_drafting_primitives_test.dart
flutter test test/e2e/e2e_packaging_pipeline_test.dart
flutter test test/e2e/e2e_scenarios_test.dart
```

---

## 2. Test Suite Architecture & Results Summary

| Suite File | Scope | Tier 1 | Tier 2 | Tier 3 | Tier 4 | Total | Status |
|---|---|:---:|:---:|:---:|:---:|:---:|:---:|
| `test/e2e/e2e_feature_coverage_test.dart` | Features F1–F17 (Lasso, Grid, Tape, Highlighter, Cornell, Colors) | 35 | — | — | — | 35 | **PASS (35/35)** |
| `test/e2e/e2e_boundary_cases_test.dart` | Adversarial, Boundary, and Zero-State Conditions | — | 18 | — | — | 18 | **PASS (18/18)** |
| `test/e2e/e2e_cross_feature_test.dart` | Pairwise Cross-Feature Interactions | — | — | 10 | — | 10 | **PASS (10/10)** |
| `test/e2e/e2e_student_workflow_test.dart` | End-to-End Real-World Student Workloads | — | — | — | 5 | 5 | **PASS (5/5)** |
| `test/e2e/e2e_core_and_pdf_test.dart` | Legacy Core note-taking, undo/redo, PDF vector export | 10 | 10 | — | — | 20 | **PASS (20/20)** |
| `test/e2e/e2e_grid_and_snap_test.dart` | Legacy Isometric grid, snap-to-grid, angle snap, HUD controls | 20 | 20 | — | — | 40 | **PASS (40/40)** |
| `test/e2e/e2e_drafting_primitives_test.dart` | Legacy Arrow stroke, dimension stroke, vertex manipulation | 15 | 15 | — | — | 30 | **PASS (30/30)** |
| `test/e2e/e2e_packaging_pipeline_test.dart` | Legacy Codemagic packaging, unsigned IPA, iOS config | 5 | 5 | — | — | 10 | **PASS (10/10)** |
| `test/e2e/e2e_scenarios_test.dart` | Legacy Drafting cross-feature scenarios | — | — | 10 | 5 | 15 | **PASS (15/15)** |
| **TOTAL** | **Comprehensive Full E2E Test Suite** | **85** | **68** | **20** | **10** | **183** | **PASS (183/183)** |

---

## 3. Student Parity Features Coverage Matrix (F1–F17)

| # | Feature | Requirement Source | Coverage Focus | Test Assertion Verification |
|---|---------|-------------------|----------------|-----------------------------|
| F1 | Lasso Filter Preferences | ORIGINAL_REQUEST § R1 | Stows `lassoSelectHandwriting`, `lassoSelectImages`, `lassoSelectText` | Default states, independent toggling, listener notifications |
| F2 | Lasso Filtering Engine | ORIGINAL_REQUEST § R1 | `Select.onDragEnd`, `tapSelect`, `pruneDisabledFilters` | Media isolation, proximity hit-testing, active prune |
| F3 | Lasso Options UI Binding | ORIGINAL_REQUEST § R1 | Selection bounds updating upon preference change | Dynamic bounds recalculation, zero-ghosting |
| F4 | Page Thumbnail Grid View Model | ORIGINAL_REQUEST § R2 | Sequential pages in `EditorCoreInfo` | Continuous page indices, bounds, dimensions |
| F5 | Tap-to-Jump Navigation | ORIGINAL_REQUEST § R2 | `CanvasGestureDetector.getTopOfPage` | Target scroll translation calculation for any page |
| F6 | Page Drag-and-Drop Reorder | ORIGINAL_REQUEST § R2 | Reordering pages & updating child stroke indices | Sequential indexing, page order synchronization |
| F7 | Page Actions (Duplicate/Add/Delete) | ORIGINAL_REQUEST § R2 | Deep-copy duplication, guarded deletion, insertion | Layer decoupling, 1-page deletion guard rejection |
| F8 | Page Bookmark Indicators | ORIGINAL_REQUEST § R2 | `EditorPage.bookmarked` flag & BSON `'bm'` key | Toggle parity, BSON roundtrip, star filtering |
| F9 | Study Tape Tool & Model | ORIGINAL_REQUEST § R3 | `TapeStrokeContract` model & `isConcealed` state | Default conceal=true, 4-corner bounding box |
| F10 | Study Tape Rendering Modes | ORIGINAL_REQUEST § R3 | Opaque conceal vs translucent wash | Alpha transparency state toggle |
| F11 | Study Tape Tap Interaction | ORIGINAL_REQUEST § R3 | `containsPoint` hit-testing & conceal toggling | Ray-casting hit detection, toggleConceal() |
| F12 | Study Tape Serialization | ORIGINAL_REQUEST § R3 | Persistence in BSON with `'shape': 'tape'`, `'c_state'` | Binary serialization roundtrip, legacy compatibility |
| F13 | Highlighter Behind Ink Layering | ORIGINAL_REQUEST § R4 | Layer ordering in `CanvasPainter` | `_drawHighlighterStrokes` rendered before pen ink |
| F14 | Highlighter Hold-to-Straighten | ORIGINAL_REQUEST § R4 | Hold gesture linear conversion | Collinear point conversion, vector preservation |
| F15 | Cornell Template Dividing Lines | ORIGINAL_REQUEST § R5 | 28% vertical cue column line, 75% summary line | Exact coordinate ratio adherence on any canvas size |
| F16 | Cornell Ruled Layout | ORIGINAL_REQUEST § R5 | Horizontal ruled lines within note-taking section | Ruled pattern generation within Cornell bounds |
| F17 | Paper Color Options | ORIGINAL_REQUEST § R5 | Presets for Warm Cream (`0xFFFAF4E8`), Legal Pad, etc. | Preset constants matching spec, BSON color persistence |

---

## 4. Real-World Student Workload Scenarios (Tier 4)

1. **Scenario 1: Active Recall Study Session (Cornell Notes on Cream Paper)**
   - Setup: Cornell Notes page with Warm Cream background (`paperColorWarmCream`).
   - Action: Student annotates Cue, Notes, and Summary areas with fountain pen ink, places 4 Study Tapes across cue questions and formulas.
   - Drill: Enters Active Recall study drill (all tapes concealed). Taps tape 1 to reveal answer, tests self, taps tape 2, re-conceals tape 1.
   - Verification: BSON binary save and restore preserves stroke geometries, Cornell paper template, tape positions, and individual conceal/reveal states.

2. **Scenario 2: Lecture Note-Taking on PDF Slides with Lasso Reorganization**
   - Setup: Imported slide deck page with high-resolution background slide image.
   - Action: Student takes margin notes with ink pen over slide diagram; realizes notes overlap diagram.
   - Filtered Selection: Disables image filter (`lassoSelectImages = false`) while keeping handwriting enabled (`lassoSelectHandwriting = true`), then lassoes the entire overlapping area.
   - Verification: Background slide image is strictly excluded from selection while handwriting is captured. Student shifts selection by $(80, 150)$ px; handwriting translates accurately while slide image stays pinned at original coordinates. Undo restores handwriting to original position without drift.

3. **Scenario 3: Exam Prep Cramming & Multi-Page Review in Grid Bird's-Eye View**
   - Setup: Comprehensive 12-page semester exam prep notebook with heterogeneous templates (Cornell, Grid, Lined) and 4 bookmarked review sheets (pages 2, 5, 8, 11).
   - Action: Opens grid view, filters by bookmarked items only (verifies exactly 4 pages displayed).
   - Reorganization: Reorders high-yield topic from index 8 to index 1; duplicates formula summary sheet (page count increases to 13); calculates jump scroll target for Page 5.
   - Verification: Page order, bookmark persistence, deep layer duplication, and `getTopOfPage` navigation coordinates.

4. **Scenario 4: Organic Chemistry Reaction Notebook with Behind-Ink Highlighter**
   - Setup: Student draws benzene rings and reaction mechanism arrows with opaque black pen ink.
   - Action: Draws wobbly highlighter strokes across reaction arrows; hold gesture triggers auto-straightening.
   - Verification: Collinearity verification across interpolated vector points. Z-index layering verification: `_drawHighlighterStrokes` executes before pen ink, ensuring highlighter is strictly behind opaque black ink without muddying chemical bonds. Multi-color highlighter palette (yellow, cyan, magenta) with selective eraser erasing highlighter layer without disturbing pen ink structures.

5. **Scenario 5: Full Semester End-to-End Notebook Serialization Lifecycle**
   - Setup: Heterogeneous 5-page student notebook combining Warm Cream title page with cover art, Cornell Notes with 3 Study Tapes (2 concealed, 1 revealed), Dark Slate inverted page with white ink, PDF slide worksheet, and bookmarked cheat sheet.
   - Action: Serialized to BSON binary structure, then deserialized into clean data structures.
   - Verification: Deep assertions confirm page counts, background color preservation, bookmark flags, stroke counts, study tape dimensions, and conceal states across all 5 pages.

---

## 5. Verification Command & Analysis Check

Static analysis and lint compliance check:
```bash
dart analyze test/e2e/e2e_feature_coverage_test.dart test/e2e/e2e_boundary_cases_test.dart test/e2e/e2e_cross_feature_test.dart test/e2e/e2e_student_workflow_test.dart test/e2e/e2e_test_fixtures.dart
```
**Result**: `No issues found!` (0 errors, 0 warnings, 0 infos).

Full test execution:
```bash
flutter test test/e2e/e2e_feature_coverage_test.dart test/e2e/e2e_boundary_cases_test.dart test/e2e/e2e_cross_feature_test.dart test/e2e/e2e_student_workflow_test.dart
```
**Result**: `+68: All tests passed!` (100% pass rate).
