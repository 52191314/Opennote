# E2E Test Infrastructure: Opennote (Goodnotes Parity Student Features)

## 1. Test Philosophy & Principles
- **Opaque-Box Requirement-Driven**: Tests are derived strictly from authoritative specifications in `ORIGINAL_REQUEST.md` (R1–R5), `PROJECT.md` (F1–F18), and `AGENTS.md`.
- **Zero-Facade Integrity**: No dummy tests, tautological assertions, or mocks designed to match buggy implementations. All tests verify actual math, state transitions, domain collections, and serialization roundtrips.
- **Progressive Testability**: Modular multi-tier test suite architecture ensuring independent verifiable execution across feature implementations and milestone gates.
- **Deterministic Expected Outputs**: Derived from geometric properties, state machines, and BSON serialization schemas.

---

## 2. Feature Inventory Mapping

| # | Feature | Requirement Source | Scope | Tier 1 (Coverage) | Tier 2 (Boundary) | Tier 3 (Pairwise) | Tier 4 (Workload) |
|---|---------|-------------------|-------|:-----------------:|:-----------------:|:-----------------:|:-----------------:|
| F1 | Lasso Filter Preferences | ORIGINAL_REQUEST § R1 | Stows `lassoSelectHandwriting`, `lassoSelectImages`, `lassoSelectText` | 3 | 2 | 2 | 2 |
| F2 | Lasso Filtering Engine | ORIGINAL_REQUEST § R1 | Gating collection in `Select.onDragEnd`, `tapSelect`, `pruneDisabledFilters` | 4 | 3 | 3 | 2 |
| F3 | Lasso Options UI | ORIGINAL_REQUEST § R1 | `LassoFilterPopup` toggle controls & reactive preference bindings | 2 | 2 | 1 | 1 |
| F4 | Page Thumbnail Grid View | ORIGINAL_REQUEST § R2 | Grid overview rendering `CanvasPreview` cards with page numbers & highlight | 3 | 2 | 2 | 2 |
| F5 | Tap-to-Jump Navigation | ORIGINAL_REQUEST § R2 | Single-tap jump to page via `scrollToPage` & matrix translation | 2 | 2 | 1 | 2 |
| F6 | Page Drag-and-Drop Reorder | ORIGINAL_REQUEST § R2 | Interactive reordering updating `coreInfo.pages` and stroke `pageIndex` | 3 | 2 | 2 | 2 |
| F7 | Page Actions (Duplicate/Add/Delete) | ORIGINAL_REQUEST § R2 | Deep-copied layer duplication, guarded single-page deletion, insertion | 4 | 3 | 2 | 2 |
| F8 | Page Bookmark Indicators & Toggles | ORIGINAL_REQUEST § R2 | `EditorPage.bookmarked` flag, `'bm'` BSON serialization, bookmark filtering | 3 | 2 | 2 | 2 |
| F9 | Study Tape Tool & Model | ORIGINAL_REQUEST § R3 | `ToolId.studyTape`, `TapeStroke` model with `isConcealed: bool` state | 3 | 2 | 2 | 2 |
| F10 | Study Tape Rendering | ORIGINAL_REQUEST § R3 | Masking rect, concealed opaque strip vs revealed translucent wash | 3 | 2 | 2 | 2 |
| F11 | Study Tape Tap Interaction | ORIGINAL_REQUEST § R3 | Tap-to-toggle conceal/reveal in canvas with `EditorHistory` undo/redo | 3 | 2 | 2 | 2 |
| F12 | Study Tape Serialization | ORIGINAL_REQUEST § R3 | Persistence in `.sbn2` with `'shape': 'tape'`, `'c_state'`, backward compat | 3 | 2 | 2 | 2 |
| F13 | Highlighter Behind Ink Layering | ORIGINAL_REQUEST § R4 | Active `_drawHighlighterStrokes` layer under ink, `ToolId.zIndex` sorting | 3 | 2 | 2 | 2 |
| F14 | Highlighter Hold-to-Straighten | ORIGINAL_REQUEST § R4 | 400ms hold timer during drag, `isStraightLine`, `convertToLine`, angle snap | 3 | 2 | 2 | 2 |
| F15 | Cornell Notes Template Dividing Lines | ORIGINAL_REQUEST § R5 | 28% vertical cue column line, 75% horizontal summary dividing line | 3 | 2 | 2 | 2 |
| F16 | Cornell Notes Ruled Layout | ORIGINAL_REQUEST § R5 | Accurate ruled lines in main notes and bottom summary section | 3 | 2 | 2 | 2 |
| F17 | Paper Background Color Options | ORIGINAL_REQUEST § R5 | Presets for Warm Cream (`0xFFFAF4E8`), Legal Pad (`0xFFFFF9B0`), White, Dark | 3 | 2 | 2 | 2 |

---

## 3. Test Suite Architecture & Tier Breakdown

The test suite is organized into four distinct tiers under `test/e2e/`:

```
test/e2e/
├── e2e_test_fixtures.dart            # Shared test fixtures, mock helpers, and stroke factories
├── e2e_feature_coverage_test.dart    # Tier 1: Happy-path coverage for F1–F17 (45+ tests)
├── e2e_boundary_cases_test.dart       # Tier 2: Boundary, corner, and stress conditions (25+ tests)
├── e2e_cross_feature_test.dart       # Tier 3: Pairwise cross-feature interactions (10+ tests)
└── e2e_student_workflow_test.dart    # Tier 4: Real-world student workload scenarios (5 scenarios)
```

### Tier 1: Feature Coverage (`e2e_feature_coverage_test.dart`)
- **Objective**: Systematic unit and functional verification of each individual feature in isolation.
- **Coverage**: Features F1 through F17 with representative happy-path inputs, validating expected states, return values, and DOM/canvas structures.

### Tier 2: Boundary & Corner Cases (`e2e_boundary_cases_test.dart`)
- **Objective**: Adversarial edge testing and failure resilience.
- **Conditions Tested**:
  - Empty notes (0 pages, 0 strokes, 0 images)
  - Single-page deletion prevention (guards against removing only remaining page)
  - Zero-selection and miss clicks (lasso around empty space)
  - Overlapping heterogeneous media (handwriting directly over images and text)
  - Long drag paths (hundreds of points with winding contours)
  - Multi-page boundary crossings (strokes on page 0 never selected from page 1)
  - Extreme coordinates (negative, sub-pixel, huge dimensions $>50,000$ px)
  - Rapid preference toggle flapping during active gestures

### Tier 3: Cross-Feature Combinations (`e2e_cross_feature_test.dart`)
- **Objective**: Pairwise integration testing of concurrently active features.
- **Key Pairs**:
  - Pair 1: Lasso Filter + Study Tape over imported images
  - Pair 2: Page Grid Overview thumbnail rendering on Cornell notes with Cream paper
  - Pair 3: Highlighter Auto-Straightening aligned with Cornell dividing lines
  - Pair 4: Study Tape concealment state preservation across Page Drag-and-Drop Reorder
  - Pair 5: Lasso selection movement preserving Highlighter behind-ink z-order
  - Pair 6: Bookmark filtering combined with page deletion and insertion
  - Pair 7: Study tape tap reveal integrated with Undo/Redo history stack
  - Pair 8: Cornell template + Warm Cream background under Dark Mode color inversion
  - Pair 9: Page duplication with deep-copied Study Tape and Highlighter layers
  - Pair 10: Lasso tap-select disambiguation vs Study Tape tap-to-reveal

### Tier 4: Real-World Student Workload Scenarios (`e2e_student_workflow_test.dart`)
- **Objective**: End-to-end integration workflows simulating authentic university and high school student study patterns.
- **Scenarios**:
  1. **Scenario 1: Active Recall Study Session (Medical / Biology Coursework)**
     - Setup Cornell template on Warm Cream paper.
     - Handwritten vocabulary with Study Tape masking.
     - Interactive reveal/conceal study drill.
     - `.sbn2` persistence roundtrip.
  2. **Scenario 2: Lecture Note-Taking on PDF Slides with Lasso Reorganization**
     - Multi-page PDF slides imported.
     - Pen annotations and highlights over slide diagrams.
     - Lasso with image filter disabled to move annotations to margins without shifting slides.
  3. **Scenario 3: Exam Prep Cramming & Multi-Page Review in Grid Bird's-Eye View**
     - 8-page notebook with priority bookmark stars.
     - Filtering bookmarked cards in grid overview, single-tap page jumping.
     - Reordering and duplicating summary pages.
  4. **Scenario 4: Organic Chemistry Reaction Notebook with Behind-Ink Highlighter**
     - Black ink chemical structures and reaction arrows.
     - Highlighting functional groups with behind-ink z-index guarantee.
     - Hold-to-straighten horizontal reaction boundary lines.
  5. **Scenario 5: Full Semester End-to-End Notebook Serialization Lifecycle**
     - Heterogeneous 5-page notebook combining Legal Pad, Warm Cream, Cornell, PDF worksheets, Study Tape, and Bookmarks.
     - Full BSON encoding/decoding, history integrity, and asset preservation.

---

## 4. Execution Commands

### Run Full E2E Test Suite
```bash
flutter test test/e2e/e2e_feature_coverage_test.dart test/e2e/e2e_boundary_cases_test.dart test/e2e/e2e_cross_feature_test.dart test/e2e/e2e_student_workflow_test.dart
```

### Run Specific Test Tier
```bash
# Tier 1: Feature Coverage
flutter test test/e2e/e2e_feature_coverage_test.dart

# Tier 2: Boundary & Corner Cases
flutter test test/e2e/e2e_boundary_cases_test.dart

# Tier 3: Cross-Feature Combinations
flutter test test/e2e/e2e_cross_feature_test.dart

# Tier 4: Real-World Student Workflows
flutter test test/e2e/e2e_student_workflow_test.dart
```

---

## 5. Pass/Fail Criteria & Quality Gates
- **Zero Failures**: 100% of tests must pass.
- **Zero Lints**: `flutter analyze` must report 0 errors and 0 warnings.
- **Deterministic**: Tests must run identically across repeated runs with zero test flakiness or cross-test state leakage.
- **AGENTS.md Compliance**: All test files must contain proper AI attribution headers.
