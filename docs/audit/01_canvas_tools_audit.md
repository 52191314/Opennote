# 01 — Canvas, Tools & Drawing Engine Audit

**Scope:** Read-only exhaustive audit of `lib/components/canvas/**`, `lib/data/tools/**`, `lib/data/editor/**`, `shaders/**`, and related canvas/tool tests in `E:\02_Projects\Opennote`.  
**Auditor:** `audit-canvas`  
**Inventory Audited:** 85 source files (`.dart` + `shaders/pencil.frag`) + test suite coverage map.

---

## 1. Executive Summary

Opennote's drawing engine has a **remarkably strong performance foundation** (120Hz `Picture` caching, `drawRawPoints` batching, octave-quantized viewport culling on infinite canvas, multi-posture palm rejection, and rich drafting primitives). However, the audit uncovered **critical data-loss serialization bugs**, **unusable light-mode UI**, **zoom-unscaled gesture/handle hit-testing**, and **unfinished Pro-grade differentiators** (like a 5-letter toy `InkReader` and a white-on-white `ProtractorOverlay`).

### Top 5 P0 Issues (Fix Immediately)
1. **Silent Data Loss on Save/Reload for All Shapes & Connectors (`fillColor` / `lineStyle` / `toolId` dropped):**
   - `CircleStroke.toJson` ([`_circle_stroke.dart:64-74`](file:///E:/02_Projects/Opennote/lib/components/canvas/_circle_stroke.dart#L64-L74)) and `RectangleStroke.toJson` ([`_rectangle_stroke.dart:73-84`](file:///E:/02_Projects/Opennote/lib/components/canvas/_rectangle_stroke.dart#L73-L84)) never write `fc` (`fillColor`), `ls` (`lineStyle`), or `ty` (`toolId`); `ArrowStroke.fromJson` ([`_arrow_stroke.dart:61-111`](file:///E:/02_Projects/Opennote/lib/components/canvas/_arrow_stroke.dart#L61-L111)), `DimensionStroke.fromJson` ([`_dimension_stroke.dart:83-132`](file:///E:/02_Projects/Opennote/lib/components/canvas/_dimension_stroke.dart#L83-L132)), and `PolygonStroke.fromJson` ([`_polygon_stroke.dart:32-73`](file:///E:/02_Projects/Opennote/lib/components/canvas/_polygon_stroke.dart#L32-L73)) ignore `fc`/`ls` on load. Filled shapes and dashed arrows silently lose styling after saving.
2. **Protractor Overlay Completely Invisible on Light Paper:**
   - [`protractor_overlay.dart:51-132`](file:///E:/02_Projects/Opennote/lib/components/canvas/hud/protractor_overlay.dart#L51-L132) hardcodes semi-transparent white (`0x33FFFFFF`, `0x88FFFFFF`, `0xCCFFFFFF`) for fill, ticks, and labels. On default white/cream paper, the protractor vanishes completely.
3. **Circle-to-Select Violates Physical-Scale Invariant & Fails on 120Hz Styluses:**
   - [`circle_to_select_detector.dart:29-76`](file:///E:/02_Projects/Opennote/lib/data/tools/circle_to_select_detector.dart#L29-L76) checks raw canvas-space thresholds (`width > 20`, `distanceToStart < 50.0`) with zero zoom scaling, and cancels `_holdTimer` on *every* `update()` without a jitter deadzone—so natural 120Hz Apple Pencil / S-Pen micro-jitter continuously resets the 450ms hold timer.
4. **Canvas Images Cannot Be Dragged Freely on Infinite Canvas + Crop Mode Has No Undo/Autosave:**
   - [`canvas_image.dart:152-171`](file:///E:/02_Projects/Opennote/lib/components/canvas/canvas_image.dart#L152-L171) clamps image dragging to `widget.pageSize` even in infinite canvas mode, trapping images inside `1000×1400`. Crop completion ([`canvas_image.dart:491-493`](file:///E:/02_Projects/Opennote/lib/components/canvas/canvas_image.dart#L491-L493)) records no `EditorHistoryItem` and triggers no autosave.
5. **Zoom-Unscaled Selection Handles, Broken Image Rotation & Stroke Z-Order Corruption:**
   - Selection handles paint and hit-test in unscaled canvas units ([`selection_painter_part.dart:180-259`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/selection_painter_part.dart#L180-L259), [`select_gesture.dart:30-35`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/select_gesture.dart#L30-L35)), shrinking to 1.5px dots at 0.25x zoom. Rotating a selected image does nothing ([`select_gesture.dart:301-308`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/select_gesture.dart#L301-L308)). `EditorPage.insertStroke` sorts by `toolId.id` alphabetically ([`page.dart:527-552`](file:///E:/02_Projects/Opennote/lib/data/editor/page.dart#L527-L552)), breaking visual layering (e.g., pen strokes drawn over filled shapes drop behind them).

### Top 5 Opennote Pro Value-Gate Hooks
1. **Engineering Drafting & CAD Suite Pro:** Calibrated real-world dimension units (`mm`/`cm`/`in`/`1:50` scale), interactive magnetic ruler/protractor edge-snapping, isometric grid snapping, and expanded Engineering Symbol Packs (EE, Mechanical, Flowchart, UML, Architecture, Chemistry).
2. **Unlimited Infinite Canvas + Unlimited Layers:** Free users get 1 infinite canvas + 2 layers/page; Pro unlocks unlimited infinite whiteboards, unlimited layers with opacity/blend/reorder, and high-DPI 300+ DPI PDF annotation.
3. **Smart Study Tape & Active Recall Pro:** Free gets basic solid tape; Pro unlocks patterned tapes, spaced-repetition quiz mode, bulk reveal/conceal per layer, and flashcard export from concealed regions.
4. **On-Device Handwriting OCR & Full-Text Ink Search:** Replace the 5-letter prototype `InkReader` ([`ink_search.dart:182-207`](file:///E:/02_Projects/Opennote/lib/data/editor/ink_search.dart#L182-L207)) with real on-device ML Kit / Apple Vision OCR + math-to-LaTeX conversion as a marquee Pro tier feature.
5. **Custom Brush Studio, Pen Tray Presets & Reusable Element Libraries:** Free gets 3 pen tray slots + 4 default elements; Pro unlocks unlimited pen presets, custom pressure curves, stroke beautification (`smoothen`), and cloud-synced reusable sticker/element packs.

### `AGENTS.md` Invariant Compliance Matrix

| Invariant | Status | Concrete Evidence / Violations |
| :--- | :---: | :--- |
| **Tool Singleton Identity** | **PASS (with gap)** | `Pen.currentPen`, `Highlighter.currentHighlighter`, `Pencil.currentPencil`, `Select.currentSelect`, `StudyTapeTool.currentStudyTape`, `LaserPointer.currentLaserPointer` exist; `PenTray.select` mutates in-place ([`pen_tray.dart:93-96`](file:///E:/02_Projects/Opennote/lib/data/tools/pen_tray.dart#L93-L96)). **Gap:** `Eraser`, `Ruler`, `ArrowTool`, `DimensionTool` do NOT expose canonical singletons on their classes. |
| **Physical-Scale Gestures** | **PARTIAL FAIL** | `ScribbleDetector` properly multiplies by `_scale` ([`scribble_detector.dart:225`](file:///E:/02_Projects/Opennote/lib/data/tools/scribble_detector.dart#L225)) and uses a 60-point sliding window. **Violations:** `CircleToSelectDetector` ([`circle_to_select_detector.dart:57-60`](file:///E:/02_Projects/Opennote/lib/data/tools/circle_to_select_detector.dart#L57-L60)) and `SelectGesture` handle hit radii ([`select_gesture.dart:30-35`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/select_gesture.dart#L30-L35)) and `PenGesture` scribble eraser cursor ([`pen_gesture.dart:135`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/pen_gesture.dart#L135)) are unscaled canvas units. |
| **Infinite-Canvas Viewport Culling** | **PASS (with gap)** | `CanvasBackgroundPainter` strictly clamps infinite loops to `quantizedInfiniteRect` + adaptive LOD `_lodBucket` + `drawRawPoints` batching ([`_canvas_background_painter.dart:140-240, 465-658`](file:///E:/02_Projects/Opennote/lib/components/canvas/_canvas_background_painter.dart#L140-L240)). **Gap:** `staffs`, `tablature`, `cornell` degrade to plain lines in infinite mode (`L641-658`). |
| **Viewport / Tap-Based Stamping** | **PARTIAL** | `ElementItem.instantiateStrokes` defaults to static `Offset(200, 200)` ([`elements.dart:55`](file:///E:/02_Projects/Opennote/lib/data/tools/elements.dart#L55))—callers must override; `EditorImage` defaults `_dstRect` to `(0, 0)` ([`editor_image.dart:73-78`](file:///E:/02_Projects/Opennote/lib/components/canvas/image/editor_image.dart#L73-L78)). |

---

## 2. Exhaustive Feature-by-Feature Audit

### 2.1 Drawing Pens (Fountain, Ballpoint, Pen Tray, Line Styles)
- **Entry Files:** [`lib/data/tools/pen.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/pen.dart), [`lib/data/tools/pen_tray.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/pen_tray.dart), [`lib/data/tools/stroke_properties.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/stroke_properties.dart), [`lib/components/canvas/_stroke.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/_stroke.dart), [`lib/data/editor/gestures/pen_gesture.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/pen_gesture.dart)
- **Maturity Score:** **4 / 5**
- **UX / Bug / Performance Gaps:**
  - **Pressure curve NaN/Infinity risk:** [`pen.dart:157-159`](file:///E:/02_Projects/Opennote/lib/data/tools/pen.dart#L157-L159) executes `pow(pressure, stows.penPressureCurve.value)` without clamping `pressure` to `[0.0, 1.0]` or guarding `penPressureCurve <= 0`.
  - **Locked-layer ghost history item:** If `activeLayer.locked == true`, `EditorPage.insertStroke` ([`page.dart:532`](file:///E:/02_Projects/Opennote/lib/data/editor/page.dart#L532)) silently drops the stroke, yet `PenGesture.end()` ([`pen_gesture.dart:92-100`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/pen_gesture.dart#L92-L100)) still pushes an `EditorHistoryItem(type: .draw)` onto the undo stack.
  - **Dashed/dotted line style leaks to drafting subclasses:** [`pen.dart:123`](file:///E:/02_Projects/Opennote/lib/data/tools/pen.dart#L123) only excludes `Highlighter` and `Pencil`, not `StudyTapeTool` or `Ruler` if `super.onDragStart` is called.
  - **Alphabetical Z-order corruption:** [`page.dart:535-547`](file:///E:/02_Projects/Opennote/lib/data/editor/page.dart#L535-L547) inserts strokes sorted by `toolId.id`, causing newer fountain pen strokes to render *under* older shape/ballpoint strokes depending on enum string order.
  - **Hover pen preview not cleared on drag end:** [`pen_gesture.dart:104-109`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/pen_gesture.dart#L104-L109) sets `penPreviewPosition` on start/update; verify it is cleared on pointer up so no ghost dot lingers.
- **Mega-Files & Coupling:** `_stroke.dart` (1,043 lines) couples point storage, RDP simplification, `perfect_freehand` polygon caching, dashed path generation, BSON/JSON serialization, SVG export, grid/isometric snapping, and $1 shape recognition in one class.
- **Monetization Tier:** **Free Core** (Fountain + Ballpoint + 3 Pen Tray presets + Solid lines). **Opennote Pro** hook: *Unlimited Pen Tray presets (6+ slots), Dashed/Dotted ink styles, Handwriting Beautification (`smoothen`), and custom pressure curves.*
- **Prioritized Fixes:**
  - **P0:** Check `if (page.activeLayer.locked)` before drawing/recording history in [`pen_gesture.dart:48, 92`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/pen_gesture.dart#L92-L100).
  - **P1:** Preserve chronological Z-order for non-highlighter strokes in [`page.dart:527-566`](file:///E:/02_Projects/Opennote/lib/data/editor/page.dart#L527-L566) (only group/sort highlighters for `saveLayer` batching).
  - **P2:** Clamp `pressure` to `[0.0, 1.0]` and guard `penPressureCurve > 0` in [`pen.dart:157-159`](file:///E:/02_Projects/Opennote/lib/data/tools/pen.dart#L157-L159).

---

### 2.2 Highlighter
- **Entry Files:** [`lib/data/tools/highlighter.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/highlighter.dart), [`lib/components/canvas/painters/stroke_painter_part.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/stroke_painter_part.dart)
- **Maturity Score:** **4 / 5**
- **UX / Bug / Performance Gaps:**
  - **Color not persisted across launches:** [`highlighter.dart:21`](file:///E:/02_Projects/Opennote/lib/data/tools/highlighter.dart#L21) hardcodes `Colors.yellow.withAlpha(Highlighter.alpha)` on construction instead of reading a persisted `stows.lastHighlighterColor`.
  - **Double-alpha darkening during active drag:** Committed highlighters render via `saveLayer(BlendMode.darken/lighten)` with uniform `alpha = 100` ([`stroke_painter_part.dart:159-220`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/stroke_painter_part.dart#L159-L220)), while the in-flight `currentStroke` ([`stroke_painter_part.dart:338-370`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/stroke_painter_part.dart#L338-L370)) paints directly with standard `srcOver`—causing a visible color/opacity pop when lifting the pen.
  - **Straight-line snap is awesome** (`dx.abs() > dy.abs() * 1.4` horizontal/vertical lock in [`highlighter.dart:57-67`](file:///E:/02_Projects/Opennote/lib/data/tools/highlighter.dart#L57-L67)), and run-length `saveLayer` batching is well-optimized.
- **Monetization Tier:** **Free Core** (basic highlighter + straight-line mode). **Opennote Pro** hook: *Custom highlighter color palettes & PDF text-snap highlighting.*
- **Prioritized Fixes:**
  - **P1:** Persist last highlighter color in `stows` and load in [`highlighter.dart:21`](file:///E:/02_Projects/Opennote/lib/data/tools/highlighter.dart#L21).
  - **P2:** Apply matching `BlendMode.darken/lighten` to in-flight highlighter `currentStroke` in [`stroke_painter_part.dart:345-365`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/stroke_painter_part.dart#L345-L365).

---

### 2.3 Pencil & GLSL Texture Shader
- **Entry Files:** [`lib/data/tools/pencil.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/pencil.dart), [`lib/components/canvas/pencil_shader.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/pencil_shader.dart), [`shaders/pencil.frag`](file:///E:/02_Projects/Opennote/shaders/pencil.frag), [`lib/components/canvas/painters/stroke_painter_part.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/stroke_painter_part.dart)
- **Maturity Score:** **3 / 5**
- **UX / Bug / Performance Gaps:**
  - **Screen-space "shower-door" swimming artifact:** [`shaders/pencil.frag:139-143`](file:///E:/02_Projects/Opennote/shaders/pencil.frag#L139-L143) samples `FlutterFragCoord().xy` directly in screen pixels without passing canvas transform/offset uniforms. When panning or zooming, the graphite grain swims across the stroke instead of staying anchored to the paper.
  - **Crash risk if shader not initialized:** [`pencil_shader.dart:4-12`](file:///E:/02_Projects/Opennote/lib/components/canvas/pencil_shader.dart#L4-L12) uses `static late final FragmentProgram _program;` with no `isInitialized` check or graceful fallback to solid/alpha paint on software renderers or unit tests.
  - **Dead shader code & unguarded currentStroke:** [`shaders/pencil.frag:37-123`](file:///E:/02_Projects/Opennote/shaders/pencil.frag#L37-L123) includes unused 1D/3D `noise`/`fbm` functions; [`stroke_painter_part.dart:348-354`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/stroke_painter_part.dart#L348-L354) unconditionally applies `page.pencilShader` even when `shouldUsePencilShader` is false.
  - **No tilt/shading support:** Stylus tilt (`PointerEvent.tilt`) is not captured or passed to widen graphite shading like Apple Notes/Procreate.
- **Monetization Tier:** **Free Core** (standard graphite pencil). **Opennote Pro** hook: *Stylus tilt shading + Paper-grain texture pack (Charcoal, Mechanical 2H/2B, Technical Pen).*
- **Prioritized Fixes:**
  - **P1:** Pass canvas translation/scale uniform to [`shaders/pencil.frag:139`](file:///E:/02_Projects/Opennote/shaders/pencil.frag#L139) so grain locks to canvas coordinates; add safe fallback in [`pencil_shader.dart:10`](file:///E:/02_Projects/Opennote/lib/components/canvas/pencil_shader.dart#L10).
  - **P2:** Guard `_drawCurrentStroke` with `shouldUsePencilShader` at [`stroke_painter_part.dart:348`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/stroke_painter_part.dart#L348) and remove unused 1D/3D noise functions from `pencil.frag`.

---

### 2.4 Shape Pen, Recognition & Specialized Shape Strokes
- **Entry Files:** [`lib/data/tools/shape_pen.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/shape_pen.dart), [`lib/components/canvas/_circle_stroke.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/_circle_stroke.dart), [`lib/components/canvas/_rectangle_stroke.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/_rectangle_stroke.dart), [`lib/components/canvas/_polygon_stroke.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/_polygon_stroke.dart)
- **Maturity Score:** **3 / 5**
- **UX / Bug / Performance Gaps:**
  - **P0 Serialization Data Loss:** `CircleStroke.toJson` ([`_circle_stroke.dart:64-74`](file:///E:/02_Projects/Opennote/lib/components/canvas/_circle_stroke.dart#L64-L74)) and `RectangleStroke.toJson` ([`_rectangle_stroke.dart:73-84`](file:///E:/02_Projects/Opennote/lib/components/canvas/_rectangle_stroke.dart#L73-L84)) omit `fc` (`fillColor`), `ls` (`lineStyle`), and `ty` (`toolId`). `PolygonStroke.fromJson` ([`_polygon_stroke.dart:32-73`](file:///E:/02_Projects/Opennote/lib/components/canvas/_polygon_stroke.dart#L32-L73)) omits `fc` and `ls`.
  - **P0 SVG Export Y-Axis Inversion Bug:** `CircleStroke.toSvgPath` ([`_circle_stroke.dart:115-117`](file:///E:/02_Projects/Opennote/lib/components/canvas/_circle_stroke.dart#L115-L117)), `RectangleStroke.toSvgPath` ([`_rectangle_stroke.dart:132-138`](file:///E:/02_Projects/Opennote/lib/components/canvas/_rectangle_stroke.dart#L132-L138)), `PolygonStroke.toSvgPath` ([`_polygon_stroke.dart:107-116`](file:///E:/02_Projects/Opennote/lib/components/canvas/_polygon_stroke.dart#L107-L116)), and `TapeStroke.toSvgPath` ([`_tape_stroke.dart:228-234`](file:///E:/02_Projects/Opennote/lib/components/canvas/_tape_stroke.dart#L228-L234)) do NOT flip `page.size.height - y`, unlike `Stroke.toSvgPath` ([`_stroke.dart:741`](file:///E:/02_Projects/Opennote/lib/components/canvas/_stroke.dart#L741)).
  - **Stale Picture Cache for `PolygonStroke`:** `Stroke.renderSignature` ([`_stroke.dart:172-200`](file:///E:/02_Projects/Opennote/lib/components/canvas/_stroke.dart#L172-L200)) omits `PolygonStroke` completely.
  - **No Dashed/Dotted rendering on Shapes:** [`stroke_painter_part.dart:284-328`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/stroke_painter_part.dart#L284-L328) draws `CircleStroke`, `RectangleStroke`, and `PolygonStroke` with solid `shapePaint`, ignoring `stroke.lineStyle`.
  - **Triangles/Stars lose canonical shape type:** [`shape_pen.dart:113-124`](file:///E:/02_Projects/Opennote/lib/data/tools/shape_pen.dart#L113-L124) converts recognized triangles/stars into raw freehand `Stroke` instead of `PolygonStroke`, losing fill support and vertex editing.
- **Monetization Tier:** **Free Core** (basic draw-and-hold shape recognition: line, circle, rectangle). **Opennote Pro** hook: *Shape fill colors, dashed/dotted shape borders, editable polygon vertices, and auto-snapping connectors.*
- **Prioritized Fixes:**
  - **P0:** Serialize/deserialize `fc`, `ls`, `ty` in `_circle_stroke.dart`, `_rectangle_stroke.dart`, `_polygon_stroke.dart`.
  - **P0:** Fix Y-axis inversion in `toSvgPath()` across `CircleStroke`, `RectangleStroke`, `PolygonStroke`, `TapeStroke`.
  - **P1:** Convert recognized triangles/stars to `PolygonStroke` in [`shape_pen.dart:113-124`](file:///E:/02_Projects/Opennote/lib/data/tools/shape_pen.dart#L113-L124) and add `PolygonStroke` to `renderSignature` ([`_stroke.dart:198`](file:///E:/02_Projects/Opennote/lib/components/canvas/_stroke.dart#L198)).

---

### 2.5 Eraser (Object & Precision Modes)
- **Entry Files:** [`lib/data/tools/eraser.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/eraser.dart), [`lib/data/editor/gestures/eraser_gesture.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/eraser_gesture.dart), [`lib/components/canvas/painters/cursor_painter_part.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/cursor_painter_part.dart)
- **Maturity Score:** **3 / 5**
- **UX / Bug / Performance Gaps:**
  - **"Precision" mode does NOT split strokes:** [`eraser.dart:33-34, 67-99`](file:///E:/02_Projects/Opennote/lib/data/tools/eraser.dart#L33-L34) merely halves the hit radius (`sqrSize * 0.25`) and still deletes the *entire* stroke! Users expect pixel/partial stroke-splitting eraser like GoodNotes/Notability.
  - **Cursor radius vs hit radius mismatch (2x off):** [`eraser_gesture.dart:54`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/eraser_gesture.dart#L54) sets `page.eraserCursorRadius = eraser.size / 2`, whereas `Eraser` treats `size` as a **radius** (`sqrSize = square(size)` at [`eraser.dart:18`](file:///E:/02_Projects/Opennote/lib/data/tools/eraser.dart#L18)). Strokes outside the visual circle get erased.
  - **Missing AABB early-exit:** [`eraser.dart:36-56`](file:///E:/02_Projects/Opennote/lib/data/tools/eraser.dart#L36-L56) iterates vertices of *every* stroke on the page without checking `stroke.boundingBox.inflate(size).contains(eraserPos)` first—O(N×V) per pointer move on dense pages.
  - **No singleton:** `Eraser` lacks `Eraser.currentEraser` (violating AGENTS.md singleton naming convention).
  - **Discrete gap skipping on fast swipes:** Checks single point `eraserPos` instead of line segment from `prevPos -> eraserPos`, so fast swipes jump over thin strokes.
- **Monetization Tier:** **Free Core** (Object Eraser + Highlighter-only / Tape-only filters). **Opennote Pro** hook: *True Partial/Precision Stroke-Splitting Eraser.*
- **Prioritized Fixes:**
  - **P0:** Add `stroke.boundingBox.inflate(effectiveRadius).contains(eraserPos)` early-exit in [`eraser.dart:36-56`](file:///E:/02_Projects/Opennote/lib/data/tools/eraser.dart#L36-L56) and fix cursor radius mismatch in [`eraser_gesture.dart:54`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/eraser_gesture.dart#L54).
  - **P1:** Implement swept-segment hit-testing (`prevPos -> currentPos`) and true stroke-splitting for `precision` mode in [`eraser.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/eraser.dart).

---

### 2.6 Scribble-to-Erase Gesture
- **Entry Files:** [`lib/data/tools/scribble_detector.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/scribble_detector.dart), [`lib/data/editor/gestures/pen_gesture.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/pen_gesture.dart)
- **Maturity Score:** **4 / 5**
- **Strengths:** Properly implements `AGENTS.md` invariants: physical screen-pixel scaling (`point * _scale` at `L225`), 60-point sliding window (`L31, L84-86`), retroactive lead-in erasure (`L99-105`), pass-spacing ratio discrimination against cursive handwriting (`L44, L333-348`), and immediate `Pen.currentStroke = null` visual cleanup ([`pen_gesture.dart:130`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/pen_gesture.dart#L130)).
- **UX / Bug / Performance Gaps:**
  - **Inherits Eraser filter flags silently:** [`scribble_detector.dart:354`](file:///E:/02_Projects/Opennote/lib/data/tools/scribble_detector.dart#L354) instantiates `Eraser(size: _reach)` which reads `stows.eraserEraseHighlighterOnly` and `stows.eraserEraseTapeOnly`! If a user left "Erase Highlighter Only" enabled on the Eraser tool, scribble-to-erase silently fails to erase pen ink.
  - **Unscaled eraser cursor visual:** [`pen_gesture.dart:135`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/pen_gesture.dart#L135) sets `page.eraserCursorRadius = ScribbleDetector.eraserRadius` (24.0 canvas px) instead of `ScribbleDetector.eraserRadius / _host.currentScale`.
  - **Text line erasure index shift & missing history:** [`scribble_detector.dart:188-215`](file:///E:/02_Projects/Opennote/lib/data/tools/scribble_detector.dart#L188-L215) mutates `page.quill.controller.replaceText` directly without recording an `EditorHistoryItem`, and tracks `_erasedLineIndices` against a shifting line list.
- **Monetization Tier:** **Free Core** (signature zero-friction delight & retention driver—never paywall!).
- **Prioritized Fixes:**
  - **P1:** Bypass `eraserEraseHighlighterOnly`/`eraserEraseTapeOnly` inside `ScribbleDetector._eraseAt` ([`scribble_detector.dart:353-361`](file:///E:/02_Projects/Opennote/lib/data/tools/scribble_detector.dart#L353-L361)).
  - **P1:** Scale `eraserCursorRadius` by `1 / _host.currentScale` in [`pen_gesture.dart:135`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/pen_gesture.dart#L135).
  - **P2:** Record Quill deletion in `EditorHistory` when `eraseTextAt` mutates text.

---

### 2.7 Lasso / Rectangle Select, Transform & Callout Menu
- **Entry Files:** [`lib/data/tools/select.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/select.dart), [`lib/data/tools/stroke_touch.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/stroke_touch.dart), [`lib/data/editor/gestures/select_gesture.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/select_gesture.dart), [`lib/components/canvas/lasso_callout_menu.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/lasso_callout_menu.dart), [`lib/components/canvas/painters/selection_painter_part.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/selection_painter_part.dart), [`lib/data/editor/selection_handles.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/selection_handles.dart), [`lib/data/editor/selection_resize.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/selection_resize.dart)
- **Maturity Score:** **3.5 / 5**
- **UX / Bug / Performance Gaps:**
  - **P0 Handles unscaled by zoom:** Rotation/resize/vertex handles draw and hit-test in raw canvas pixels ([`selection_painter_part.dart:180-294`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/selection_painter_part.dart#L180-L294), [`select_gesture.dart:30-35`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/select_gesture.dart#L30-L35)). At 0.25x zoom, handles are 1.5px dots and impossible to grab.
  - **P0 Missing `Duplicate` button in Callout Menu:** [`lasso_callout_menu.dart:37`](file:///E:/02_Projects/Opennote/lib/components/canvas/lasso_callout_menu.dart#L37) requires `onDuplicate`, yet `_buildBody` (`L305-404`) never renders a Duplicate button!
  - **P0 Image rotation broken:** [`select_gesture.dart:301-308`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/select_gesture.dart#L301-L308) orbits `image.dstRect.center` without rotating the image itself (`EditorImage` has no `rotation` field).
  - **P1 `tapSelect` ignores `lassoSelectTape` & hits bottommost item first:** [`select.dart:343-372`](file:///E:/02_Projects/Opennote/lib/data/tools/select.dart#L343-L372) iterates forward (bottom-to-top) instead of `.reversed` (topmost visible) and skips `TapeStroke` filtering.
  - **P1 `NaN` division on empty polygon + missing AABB early-exit:** [`select.dart:318-325`](file:///E:/02_Projects/Opennote/lib/data/tools/select.dart#L318-L325) divides by `polygon.length` without empty check; `_isLassoed` (`L250-261`) lacks `selectionBounds.overlaps(stroke.boundingBox)` before testing every vertex.
  - **P1 State mutation inside `CustomPainter.paint()`:** [`selection_painter_part.dart:55-58, 184, 250-278`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/selection_painter_part.dart#L184) mutates `page.selection*Handles` during `paint()`.
  - **P2 `scaleAround` smoothing inconsistency:** [`_stroke.dart:349-350`](file:///E:/02_Projects/Opennote/lib/components/canvas/_stroke.dart#L349-L350) rebuilds `_lowQualityPath` with `smooth: false` instead of `smooth: true`.
- **Monetization Tier:** **Free Core** (Lasso/Rect select, move, resize, rotate, cut/copy/paste/delete, color change). **Opennote Pro** hook: *Connected-stroke smart selection, Lasso Screenshot export, Save to Reusable Elements, Handwriting Smoothen/Beautify, and OCR Convert-to-Text.*
- **Prioritized Fixes:**
  - **P0:** Multiply handle visual radii & hit radii by `invScale` (`1 / currentScale`); wire `onDuplicate` button in [`lasso_callout_menu.dart:317`](file:///E:/02_Projects/Opennote/lib/components/canvas/lasso_callout_menu.dart#L317).
  - **P1:** Iterate `strokes.reversed` and `images.reversed` in `tapSelect`, guard `polygon.isEmpty`, add AABB early-exit in `_isLassoed`.
  - **P2:** Add `double rotation` to `EditorImage` and apply `Transform.rotate` in `CanvasImage`.

---

### 2.8 Circle-to-Select Gesture
- **Entry Files:** [`lib/data/tools/circle_to_select_detector.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/circle_to_select_detector.dart), [`lib/data/editor/gestures/pen_gesture.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/pen_gesture.dart)
- **Maturity Score:** **2 / 5**
- **UX / Bug / Performance Gaps:**
  - **P0 Violates Physical-Scale Invariant:** [`circle_to_select_detector.dart:57-60`](file:///E:/02_Projects/Opennote/lib/data/tools/circle_to_select_detector.dart#L57-L60) uses hardcoded canvas coordinates (`width > 20`, `height > 20`, `distanceToStart < 50.0`) without `scale`. Zoomed in 4x, a normal circle fails `width > 20`; zoomed out 0.25x, closing within 12.5 screen px is nearly impossible.
  - **P0 120Hz Stylus Jitter Cancels Hold Timer:** [`circle_to_select_detector.dart:31`](file:///E:/02_Projects/Opennote/lib/data/tools/circle_to_select_detector.dart#L31) unconditionally cancels `_holdTimer` on every `update(point)`. Real styluses emit sub-pixel jitter while held still, preventing the 450ms timer from ever firing.
  - **P1 No haptic/visual ring feedback** during the 450ms hold to signal detection.
- **Monetization Tier:** **Free Core** (core ergonomic differentiator).
- **Prioritized Fixes:**
  - **P0:** Pass `scale` into `CircleToSelectDetector.update(point, scale: _host.currentScale)`, convert thresholds to screen pixels, and keep `_holdTimer` alive while stylus stays within a `6.0` screen-pixel jitter deadzone.

---

### 2.9 Drafting Tools (Ruler, Arrows/Connectors, Dimensions, Shape Library)
- **Entry Files:** [`lib/data/tools/ruler.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/ruler.dart), [`lib/data/tools/arrow.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/arrow.dart), [`lib/data/tools/dimension.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/dimension.dart), [`lib/components/canvas/_arrow_stroke.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/_arrow_stroke.dart), [`lib/components/canvas/_dimension_stroke.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/_dimension_stroke.dart), [`lib/components/canvas/shape_library_dialog.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/shape_library_dialog.dart), [`lib/components/canvas/hud/canvas_hud.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/hud/canvas_hud.dart)
- **Maturity Score:** **3.5 / 5**
- **UX / Bug / Performance Gaps:**
  - **P0 Serialization loss:** `ArrowStroke.fromJson` and `DimensionStroke.fromJson` drop `fillColor`/`lineStyle`.
  - **P1 Drafting HUD fades out for Arrow & Dimension tools:** [`canvas_hud.dart:94-96`](file:///E:/02_Projects/Opennote/lib/components/canvas/hud/canvas_hud.dart#L94-L96) only checks `activeTool == ToolId.ruler`, omitting `ToolId.arrow` and `ToolId.dimension`.
  - **P1 Hardcoded English tool names & `px`-only dimensions:** `'Ruler'`, `'Arrow'`, `'Elbow Connector'`, `'Curved Connector'`, `'Dimension'` are not localized (`i18n`); `DimensionTool` ([`dimension.dart:98, 112`](file:///E:/02_Projects/Opennote/lib/data/tools/dimension.dart#L98)) hardcodes `px` with no real-world unit/scale calibration (`mm`/`cm`/`in`/`1:50`).
  - **P1 `TextPainter` native memory leak:** `DimensionStroke._cachedTextPainter` ([`_dimension_stroke.dart:36-62`](file:///E:/02_Projects/Opennote/lib/components/canvas/_dimension_stroke.dart#L36-L62)) is never disposed when a stroke is deleted or page is disposed.
  - **P2 Triplicated snapping code:** `_snapPoint` + `isIso` + `Stroke.snapLineToAngle` is copy-pasted across `ruler.dart`, `arrow.dart`, `dimension.dart`.
  - **P2 Tiny Shape Library (8 EE symbols only):** [`shape_library_dialog.dart:107-192`](file:///E:/02_Projects/Opennote/lib/components/canvas/shape_library_dialog.dart#L107-L192) only has 8 electrical symbols with hardcoded `stroke="black"`.
- **Monetization Tier:** **Free Core** (basic straight-line Ruler + simple Arrow). **Opennote Pro** hook: *Full Engineering Drafting Suite — Dimension Lines with calibrated real-world units (`mm`/`cm`/`in`/`1:50`), Elbow & Curved smart connectors, Isometric 30° angle snap, and Engineering Symbol Packs (EE, Mechanical, UML, Flowchart, Architecture).* — **Aha Moment:** User draws a circuit/floorplan on Engineering Grid, taps Dimension tool or Shape Library -> Pro badge with 7-day free trial.
- **Prioritized Fixes:**
  - **P0:** Fix `ArrowStroke.fromJson` & `DimensionStroke.fromJson` to restore `fc` and `ls`.
  - **P1:** Add `ToolId.arrow` & `ToolId.dimension` to `isDraftingVisible` in [`canvas_hud.dart:94-96`](file:///E:/02_Projects/Opennote/lib/components/canvas/hud/canvas_hud.dart#L94-L96); localize tool names; extract shared `DraftingSnapMixin`.

---

### 2.10 Protractor Overlay
- **Entry Files:** [`lib/components/canvas/hud/protractor_overlay.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/hud/protractor_overlay.dart)
- **Maturity Score:** **1.5 / 5**
- **UX / Bug / Performance Gaps:**
  - **P0 Completely invisible on Light Paper:** Hardcoded white colors (`0x33FFFFFF`, `0x88FFFFFF`, `0xCCFFFFFF`) at [`protractor_overlay.dart:51-132`](file:///E:/02_Projects/Opennote/lib/components/canvas/hud/protractor_overlay.dart#L51-L132) render white-on-white over default light paper.
  - **P1 Zero drafting utility:** Cannot rotate, cannot resize, cannot snap strokes along its edge, has no close button, and allocates 5 `TextPainter`s inside `paint()` on every repaint (`L108-123`).
- **Monetization Tier:** **Opennote Pro** (part of Engineering Drafting Suite once upgraded to interactive magnetic Protractor + Physical Ruler overlay).
- **Prioritized Fixes:**
  - **P0:** Theme-adapt protractor colors using `Theme.of(context).colorScheme` (high-contrast dark slate ink on light canvas, light ink on dark canvas) in [`protractor_overlay.dart:49-133`](file:///E:/02_Projects/Opennote/lib/components/canvas/hud/protractor_overlay.dart#L49-L133).
  - **P1:** Add 2-finger rotate/scale, angle readout pill, and dismiss button.

---

### 2.11 Study Tape (Active Recall)
- **Entry Files:** [`lib/data/tools/study_tape.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/study_tape.dart), [`lib/components/canvas/_tape_stroke.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/_tape_stroke.dart), [`lib/components/canvas/painters/specialized_stroke_painter_part.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/specialized_stroke_painter_part.dart)
- **Maturity Score:** **4 / 5**
- **UX / Bug / Performance Gaps:**
  - **P1 Broken live preview while dragging:** [`stroke_painter_part.dart:338-370`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/stroke_painter_part.dart#L338-L370) (`_drawCurrentStroke`) does NOT check `if (currentStroke is TapeStroke) return _drawTapeStroke(...)`, so while dragging new tape it renders as an unstyled solid path until pen-up.
  - **P1 Zero-width accidental taps not discarded:** [`study_tape.dart:103-114`](file:///E:/02_Projects/Opennote/lib/data/tools/study_tape.dart#L103-L114) commits tiny 10px tape strips on accidental taps (unlike `ArrowTool` / `DimensionTool`).
  - **P1 Hardcoded `'Study Tape'` name** ([`study_tape.dart:20`](file:///E:/02_Projects/Opennote/lib/data/tools/study_tape.dart#L20)) + SVG Y-axis inversion bug ([`_tape_stroke.dart:228-234`](file:///E:/02_Projects/Opennote/lib/components/canvas/_tape_stroke.dart#L228-L234)).
  - **P2 Reveal/Conceal HUD hides after 5s:** [`canvas_hud.dart:343-394`](file:///E:/02_Projects/Opennote/lib/components/canvas/hud/canvas_hud.dart#L343-L394) ties the Study Tape reveal/conceal pill to `effectiveOpacity`, so students studying a page without panning can't see the "Reveal All / Conceal All" buttons until they wiggle the canvas!
- **Monetization Tier:** **Freemium Hook** — Free gets Solid yellow tape (up to 5 strips/page or basic conceal/reveal); **Opennote Pro** unlocks *Unlimited patterned Study Tape (Stripes/Dots/Grid), custom pastel colors, and Active Recall Quiz Mode (auto-hide all on open + tap-to-score).*
- **Prioritized Fixes:**
  - **P1:** Handle `TapeStroke` in `_drawCurrentStroke` ([`stroke_painter_part.dart:344`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/stroke_painter_part.dart#L344)); keep tape HUD pill visible when `hasTape` is true ([`canvas_hud.dart:350`](file:///E:/02_Projects/Opennote/lib/components/canvas/hud/canvas_hud.dart#L350)).

---

### 2.12 Laser Pointer & Spotlight
- **Entry Files:** [`lib/data/tools/laser_pointer.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/laser_pointer.dart), [`lib/data/editor/gestures/laser_gesture.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/gestures/laser_gesture.dart), [`lib/components/canvas/painters/stroke_painter_part.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/stroke_painter_part.dart), [`lib/components/canvas/painters/cursor_painter_part.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/cursor_painter_part.dart)
- **Maturity Score:** **3.5 / 5**
- **UX / Bug / Performance Gaps:**
  - **P1 Disposed-page crash / zombie loop risk:** [`laser_pointer.dart:93-138`](file:///E:/02_Projects/Opennote/lib/data/tools/laser_pointer.dart#L93-L138) runs `unawaited(fadeOutStroke(...))` calling `page.redrawStrokes()` without checking if the page was disposed. If a gesture cancels without calling `onDragEnd`, static `LaserPointer.isDrawing` stays `true` forever, spinning `while (isDrawing) await wait(100ms)` indefinitely!
  - **P2 Hardcoded red color only:** [`laser_pointer.dart:25`](file:///E:/02_Projects/Opennote/lib/data/tools/laser_pointer.dart#L25) and [`cursor_painter_part.dart:70-77`](file:///E:/02_Projects/Opennote/lib/components/canvas/painters/cursor_painter_part.dart#L70-L77) hardcode `Colors.red`—no color/fade-duration options for presentation mode.
- **Monetization Tier:** **Free Core** (great for teachers/presenters; Pro can add Presentation Mode with multi-color laser + external display clean-feed).
- **Prioritized Fixes:**
  - **P1:** Guard `fadeOutStroke` against disposed `EditorPage` and reset `isDrawing` on gesture cancel / timeout ([`laser_pointer.dart:110-138`](file:///E:/02_Projects/Opennote/lib/data/tools/laser_pointer.dart#L110-L138)).

---

### 2.13 Text / Quill Editor Overlay
- **Entry Files:** [`lib/components/canvas/inner_canvas.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/inner_canvas.dart), [`lib/data/editor/page.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/page.dart)
- **Maturity Score:** **3 / 5**
- **UX / Bug / Performance Gaps:**
  - **Single page-wide Quill document only:** No floating/positioned text boxes (`TextBox` objects)—only one `QuillStruct` per page shifted/scaled/rotated as a single block ([`inner_canvas.dart:292-319`](file:///E:/02_Projects/Opennote/lib/components/canvas/inner_canvas.dart#L292-L319)). On an infinite canvas, this feels severely limiting compared to GoodNotes/Concepts/Freeform.
  - **Approximate hit-test rect:** [`page.dart:219-234`](file:///E:/02_Projects/Opennote/lib/data/editor/page.dart#L219-L234) (`computeTextContentRect`) estimates height via `lines * lineHeight * textContentScale` ignoring word-wrap and heading font sizes, so lasso/tap selection of wrapped text is inaccurate.
- **Monetization Tier:** **Free Core** (basic typed notes). **Opennote Pro** hook: *Multiple floating rich-text boxes & LaTeX equation boxes on infinite canvas.*
- **Prioritized Fixes:**
  - **P2:** Introduce multi-instance `TextBoxImage` / floating text nodes for infinite canvas; measure actual rendered Quill `RenderBox` bounds for `computeTextContentRect`.

---

### 2.14 PDF, Image, Sticky Note, Sticker & Reusable Element Overlays
- **Entry Files:** [`lib/components/canvas/canvas_image.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/canvas_image.dart), [`lib/components/canvas/image/editor_image.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/image/editor_image.dart), [`lib/components/canvas/image/pdf_editor_image.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/image/pdf_editor_image.dart), [`lib/data/tools/elements.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/elements.dart), [`lib/data/tools/stickers.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/stickers.dart)
- **Maturity Score:** **3.5 / 5**
- **UX / Bug / Performance Gaps:**
  - **P0 Infinite Canvas image drag clamp:** [`canvas_image.dart:152-171`](file:///E:/02_Projects/Opennote/lib/components/canvas/canvas_image.dart#L152-L171) clamps `dstRect` inside `widget.pageSize` (`1000×1400`), preventing users from placing images anywhere else on an infinite canvas!
  - **P0 Image crop has no undo/autosave:** [`canvas_image.dart:491-493`](file:///E:/02_Projects/Opennote/lib/components/canvas/canvas_image.dart#L491-L493) modifies `srcRect` without notifying history or autosave.
  - **P1 Giant 40×40 unscaled resize handles:** [`canvas_image.dart:513-514`](file:///E:/02_Projects/Opennote/lib/components/canvas/canvas_image.dart#L513-L514) renders 40×40px solid circles that look huge/clunky and don't counter-scale with zoom.
  - **P1 Static default stamping coordinates:** `ElementItem.instantiateStrokes` defaults to `Offset(200, 200)` ([`elements.dart:55`](file:///E:/02_Projects/Opennote/lib/data/tools/elements.dart#L55)) and `EditorImage` defaults `_dstRect` to `(0, 0)` ([`editor_image.dart:73-78`](file:///E:/02_Projects/Opennote/lib/components/canvas/image/editor_image.dart#L73-L78))—ensure all editor insertion callers project to tap/viewport center per `AGENTS.md`.
  - **P2 PDF DPI cap:** [`pdf_editor_image.dart:181`](file:///E:/02_Projects/Opennote/lib/components/canvas/image/pdf_editor_image.dart#L181) caps `maximumDpi: 180`, slightly soft at 5x–10x zoom on dense schematics.
- **Monetization Tier:** **Free Core** (Photo/PDF import, basic sticky notes, 4 default elements). **Opennote Pro** hook: *Unlimited custom Reusable Element collections, 300+ DPI crisp PDF rendering, PDF Dark Mode Auto-Invert, and vector sticker packs.*
- **Prioritized Fixes:**
  - **P0:** Skip `pageSize` clamp in [`canvas_image.dart:152-171`](file:///E:/02_Projects/Opennote/lib/components/canvas/canvas_image.dart#L152-L171) when `isInfiniteCanvas == true`; record `EditorHistoryItem` + `onMiscChange` on crop end (`L491-493`).

---

### 2.15 Backgrounds, Paper Templates & Layers
- **Entry Files:** [`lib/components/canvas/_canvas_background_painter.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/_canvas_background_painter.dart), [`lib/data/tools/page_templates.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/page_templates.dart), [`lib/components/canvas/hud/floating_layers_overlay.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/hud/floating_layers_overlay.dart), [`lib/data/editor/page.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/page.dart)
- **Maturity Score:** **4 / 5** (Backgrounds) / **3 / 5** (Layers)
- **UX / Bug / Performance Gaps:**
  - **P1 Layer deletion is destructive with zero confirmation and zero Undo:** [`floating_layers_overlay.dart:44-54`](file:///E:/02_Projects/Opennote/lib/components/canvas/hud/floating_layers_overlay.dart#L44-L54) immediately removes the layer and all its strokes without an `EditorHistoryItem` or confirmation dialog!
  - **P1 Missing layer UX basics:** No drag-to-reorder layers, no layer rename, no layer opacity slider, and images/text aren't layer-scoped (only strokes live inside `Layer`).
  - **P2 Infinite canvas pattern fallback:** [`_canvas_background_painter.dart:641-658`](file:///E:/02_Projects/Opennote/lib/components/canvas/_canvas_background_painter.dart#L641-L658) degrades `staffs`, `tablature`, and `cornell` to plain horizontal lines on infinite canvas.
  - **P2 Hardcoded English template names:** [`page_templates.dart:69-168`](file:///E:/02_Projects/Opennote/lib/data/tools/page_templates.dart#L69-L168) hardcodes all 14 template names and planner text in English.
- **Mega-Files:** `_canvas_background_painter.dart` (952 lines—currently being modularized by `@remod-canvas` under `painters/`).
- **Monetization Tier:** **Free Core** (Blank, Lined, Grid, Dot Grid, College Ruled, up to 2 layers/page). **Opennote Pro** hook: *Engineering Grid, Isometric Grid, Cornell Notes, Music Staff/Tablature, Custom Paper Templates, and Unlimited Layers with opacity/reorder.*
- **Prioritized Fixes:**
  - **P1:** Add undoable `EditorHistoryItem` or confirmation dialog for layer deletion in [`floating_layers_overlay.dart:44-54`](file:///E:/02_Projects/Opennote/lib/components/canvas/hud/floating_layers_overlay.dart#L44-L54); add rename & reorder support.

---

### 2.16 Infinite Canvas & Mode Conversion
- **Entry Files:** [`lib/data/editor/canvas_mode_conversion.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/canvas_mode_conversion.dart), [`lib/data/editor/editor_core_info.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/editor_core_info.dart), [`lib/components/canvas/canvas_gesture_detector.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/canvas_gesture_detector.dart)
- **Maturity Score:** **4 / 5**
- **Strengths:** Clean `mergePagesIntoFirst` + `fitFirstPageToContent` conversion, `0.02x–10.0x` zoom range, octave-quantized background culling, and `Fit Content` HUD button.
- **UX / Bug / Performance Gaps:**
  - **P0 `EditorCoreInfo.copyWith` drops `isInfiniteCanvas`:** [`editor_core_info.dart:549-571`](file:///E:/02_Projects/Opennote/lib/data/editor/editor_core_info.dart#L549-L571) omits `isInfiniteCanvas`, silently reverting copied notes to paged mode (`false`).
  - **P1 `contentBounds` ignores `Text` and `backgroundImage`:** [`canvas_mode_conversion.dart:154-164`](file:///E:/02_Projects/Opennote/lib/data/editor/canvas_mode_conversion.dart#L154-L164) only checks `strokes` and `images`, so switching a text-heavy infinite note to paged mode can clip text.
  - **P1 `CanvasImage` drag clamped to `pageSize`** (see §2.14).
- **Monetization Tier:** **Opennote Pro** (Free gets 1 Infinite Canvas whiteboard to experience the *Aha moment*; Pro unlocks unlimited Infinite Canvas notebooks + Paged↔Infinite conversion).
- **Prioritized Fixes:**
  - **P0:** Preserve `isInfiniteCanvas` in `EditorCoreInfo.copyWith` ([`editor_core_info.dart:549-571`](file:///E:/02_Projects/Opennote/lib/data/editor/editor_core_info.dart#L549-L571)).
  - **P1:** Include `page.computeTextContentRect` in `contentBounds` ([`canvas_mode_conversion.dart:154-164`](file:///E:/02_Projects/Opennote/lib/data/editor/canvas_mode_conversion.dart#L154-L164)).

---

### 2.17 Zoom, Pan Physics, Palm Rejection & Zoom Writing Window
- **Entry Files:** [`lib/components/canvas/interactive_canvas.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/interactive_canvas.dart), [`lib/components/canvas/interactive/interactive_canvas_gestures.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/interactive/interactive_canvas_gestures.dart), [`lib/components/canvas/interactive/canvas_scale_gesture_recognizer.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/interactive/canvas_scale_gesture_recognizer.dart), [`lib/data/tools/palm_rejection.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/palm_rejection.dart), [`lib/components/canvas/zoom_window_view.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/zoom_window_view.dart), [`lib/data/editor/zoom_window.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/zoom_window.dart)
- **Maturity Score:** **4.5 / 5** (Zoom/Pan/Palm) / **2.5 / 5** (Zoom Window)
- **Strengths:** Custom `InteractiveCanvasViewer` + `CanvasScaleGestureRecognizer` with 6 writing postures, 120ms multi-touch forgiveness, stylus preemption, friction inertia (`0.3`), and 2-finger/3-finger tap Undo/Redo is flagship-tier engineering!
- **UX / Bug / Performance Gaps:**
  - **P1 Zoom Window renders broken strokes & ignores dark mode:** [`zoom_window_view.dart:389-435`](file:///E:/02_Projects/Opennote/lib/components/canvas/zoom_window_view.dart#L389-L435) hardcodes cream background `0xFFFFFDF8`, renders ONLY `stroke.centerlinePath` (so `CircleStroke`, `RectangleStroke`, `ArrowStroke`, `DimensionStroke`, `TapeStroke`, `EditorImage`, and `Quill` text are **completely invisible** inside the Zoom Window!), ignores pressure variation, and `ZoomInk` ([`zoom_window.dart:324, 331`](file:///E:/02_Projects/Opennote/lib/data/editor/zoom_window.dart#L324)) passes `pressure: null`.
  - **P2 Canvas rotation hardcoded disabled:** [`interactive_canvas.dart:248`](file:///E:/02_Projects/Opennote/lib/components/canvas/interactive_canvas.dart#L248) has `final bool _rotateEnabled = false;`—2-finger canvas rotation (loved by Concepts/Procreate users) is stubbed out.
- **Monetization Tier:** **Free Core** (120Hz Zoom/Pan + 6-posture Palm Rejection). **Opennote Pro** hook: *Auto-Advancing Zoom Writing Window (once upgraded to full fidelity) + 2-Finger Canvas Rotation.*
- **Prioritized Fixes:**
  - **P1:** Render `CanvasPainter` + `CanvasBackgroundPainter` inside `ZoomWindowPanel` ([`zoom_window_view.dart:210-217`](file:///E:/02_Projects/Opennote/lib/components/canvas/zoom_window_view.dart#L210-L217)) and pass stylus pressure through `Listener` in `ZoomWindowPanel`.

---

### 2.18 Undo / Redo History Engine
- **Entry Files:** [`lib/data/editor/editor_history.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/editor_history.dart), [`lib/data/editor/selection_transform.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/selection_transform.dart)
- **Maturity Score:** **4 / 5**
- **UX / Bug / Performance Gaps:**
  - **P1 Missing history coverage for:** Layer add/delete/reorder/visibility, Image crop (`srcRect`), Scribble-to-erase text deletion, Study Tape conceal/reveal toggle, and per-page paper template changes.
  - **P2 Fixed 100-item cap:** [`editor_history.dart:15`](file:///E:/02_Projects/Opennote/lib/data/editor/editor_history.dart#L15) (`maxHistoryLength = 100`) is fine for memory, though stroke-heavy sessions can exhaust it quickly; consider 250 or memory-budgeted stack.
- **Monetization Tier:** **Free Core** (never paywall Undo/Redo).
- **Prioritized Fixes:**
  - **P1:** Add `EditorHistoryItemType.layerChange` and `imageCrop` to [`editor_history.dart:267-280`](file:///E:/02_Projects/Opennote/lib/data/editor/editor_history.dart#L267-L280).

---

### 2.19 Pressure Curves, Stylus Integration & Ink Search
- **Entry Files:** [`lib/components/canvas/gesture_detector/canvas_pointer_handlers.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/gesture_detector/canvas_pointer_handlers.dart), [`lib/data/editor/ink_search.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/ink_search.dart)
- **Maturity Score:** **4 / 5** (Stylus) / **1.5 / 5** (Ink Search)
- **UX / Bug / Performance Gaps:**
  - **P1 `InkReader` is a 5-letter toy heuristic:** [`ink_search.dart:182-207`](file:///E:/02_Projects/Opennote/lib/data/editor/ink_search.dart#L182-L207) ONLY classifies block capitals `'O'`, `'H'`, `'T'`, `'L'`, `'I'`! Advertising "Handwriting Search" in store copy while shipping a 5-letter heuristic will trigger 1-star App Store reviews.
  - **P2 Stylus barrel button / Apple Pencil Double-Tap:** [`canvas_pointer_handlers.dart:141-148`](file:///E:/02_Projects/Opennote/lib/components/canvas/gesture_detector/canvas_pointer_handlers.dart#L141-L148) detects `kSecondaryButton` and `invertedStylus`, but lacks Apple Pencil Squeeze / Hover-preview customization.
- **Monetization Tier:** **Opennote Pro** (Real on-device ML Kit / Apple Vision Handwriting OCR & Full-Text Ink Search is the #1 willingness-to-pay driver for students & engineers).
- **Prioritized Fixes:**
  - **P1:** Do NOT market handwriting search until `InkReader` is backed by on-device ML Kit Digital Ink Recognition (Android/iOS) or Apple Vision / Scribble.

---

## 3. Mega-Files & Coupling Hotspots (Remodularization Roadmap)

| File | Lines | Primary Responsibilities Coupled | Recommended Split |
| :--- | :---: | :--- | :--- |
| [`lib/components/canvas/_stroke.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/_stroke.dart) | 1,043 | Point storage, RDP simplification, polygon/path gen, BSON/JSON, SVG, snapping, $1 shape detection | **In progress by `@remod-canvas`** -> `canvas/stroke/{geometry, serialization, snapping, simplification}.dart` |
| [`lib/components/canvas/_canvas_background_painter.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/_canvas_background_painter.dart) | 952 | Viewport quantization, LOD bucketing, `Float32List` batching, 9 pattern generators (paged + infinite) | **In progress by `@remod-canvas`** -> `canvas/painters/background/{grid, lined, dots, music, cornell, isometric}.dart` |
| [`lib/data/editor/page.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/page.dart) | 796 | `EditorPage`, `Layer`, `QuillStruct`, `Picture` cache lifecycle, JSON serialization, text bounds, ephemeral cursor/selection state | Extract `layer.dart`, `quill_struct.dart`, `page_ephemeral_state.dart` (cursors/handles), `page_picture_cache.dart` |
| [`lib/components/canvas/canvas_gesture_detector.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/canvas_gesture_detector.dart) | 728 | Transform bounds math, viewport rebuild gating, HUD/Overlay composition, keybindings, transform cache | Extract `canvas_bounds_math.dart` and `canvas_hud_stack.dart` |
| [`lib/components/canvas/canvas_image.dart`](file:///E:/02_Projects/Opennote/lib/components/canvas/canvas_image.dart) | 593 | Image drag/pan, 8-handle resize, crop mode overlay, modal dialog launcher | Extract `canvas_image_resize_handle.dart` and `canvas_image_crop_overlay.dart` |
| [`lib/data/editor/editor_core_info.dart`](file:///E:/02_Projects/Opennote/lib/data/editor/editor_core_info.dart) | 572 | Note metadata, BSON/JSON/SBA serialization, isolate loading, v0–v19 schema migrations | Extract `sbn_migrations.dart` and `sba_archive_codec.dart` |
| [`lib/data/tools/select.dart`](file:///E:/02_Projects/Opennote/lib/data/tools/select.dart) | 538 | Selection state, lasso/rect hit-testing, tap hit-testing, filter pruning, `SelectResult` | Extract `select_hit_test.dart` and `select_result.dart` |

---

## 4. Prioritized Master Fix Backlog

### P0 — Ship-Blocking Bugs & Data Loss
1. **Restore `fc`/`ls`/`ty` serialization** in `_circle_stroke.dart:64-74`, `_rectangle_stroke.dart:73-84`, `_polygon_stroke.dart:32-73`, `_arrow_stroke.dart:61-111`, `_dimension_stroke.dart:83-132`.
2. **Fix SVG Y-axis inversion** in `toSvgPath()` for `_circle_stroke.dart:115`, `_rectangle_stroke.dart:132`, `_polygon_stroke.dart:107`, `_tape_stroke.dart:228`.
3. **Fix invisible Protractor on light paper** in `protractor_overlay.dart:51-132` (use theme-aware `colorScheme` ink/surface).
4. **Fix `CircleToSelectDetector` zoom-scaling & 120Hz jitter deadzone** in `circle_to_select_detector.dart:29-76`.
5. **Remove `pageSize` clamp for `CanvasImage` drag on infinite canvas** + add undo/autosave for crop mode in `canvas_image.dart:152-171, 491-493`.
6. **Scale selection handle visuals & hit radii by `1 / currentScale`** in `selection_painter_part.dart:180-294` & `select_gesture.dart:30-35`, and wire missing `Duplicate` button in `lasso_callout_menu.dart:305-404`.
7. **Fix `EditorCoreInfo.copyWith` dropping `isInfiniteCanvas`** in `editor_core_info.dart:549-571`.
8. **Block ghost undo entries when drawing on locked layers** in `pen_gesture.dart:48, 92-100`.
9. **Add AABB early-exit to `Eraser` & fix 2x cursor radius mismatch** in `eraser.dart:36-56` and `eraser_gesture.dart:54`.

### P1 — High-Impact UX & Performance Polish
1. **Fix `TapeStroke` live drag preview** in `stroke_painter_part.dart:338-370` & keep Study Tape reveal/conceal pill visible when `hasTape` (`canvas_hud.dart:350`).
2. **Fix `ScribbleDetector` inheriting Eraser filter flags** (`scribble_detector.dart:354`) & scale scribble eraser cursor (`pen_gesture.dart:135`).
3. **Preserve chronological stroke Z-order** for non-highlighters (`page.dart:527-566`).
4. **Upgrade Zoom Window painter** to render full `CanvasPainter` + `CanvasBackgroundPainter` + stylus pressure (`zoom_window_view.dart:389-435`, `zoom_window.dart:324`).
5. **Fix `PencilShader` screen-space swimming** (`shaders/pencil.frag:139`) & add uninitialized fallback (`pencil_shader.dart:10`).
6. **Add undo/confirmation for Layer deletion** (`floating_layers_overlay.dart:44-54`) + include `Arrow`/`Dimension` in `isDraftingVisible` (`canvas_hud.dart:94-96`).
7. **Fix `Select.tapSelect` reverse Z-order & `TapeStroke` filter** (`select.dart:343-372`) + guard `polygon.isEmpty` (`select.dart:325`).
8. **Guard `LaserPointer.fadeOutStroke` against disposed pages & stuck `isDrawing`** (`laser_pointer.dart:110-138`).
9. **Replace 5-letter `InkReader` prototype** (`ink_search.dart:182-207`) with on-device ML Kit / Apple Vision OCR before marketing handwriting search.

### P2 — Flagship Craft & Differentiators
1. Add `rotation` field to `EditorImage` so lasso rotation rotates images properly (`select_gesture.dart:301-308`).
2. Implement true stroke-splitting precision eraser & swept-segment hit-testing (`eraser.dart`).
3. Convert ShapePen triangles/stars to `PolygonStroke` (`shape_pen.dart:113-124`) & add `PolygonStroke` to `renderSignature` (`_stroke.dart:198`).
4. Dispose `DimensionStroke._cachedTextPainter` on stroke/page teardown (`_dimension_stroke.dart:36-62`).
5. Enable 2-finger canvas rotation (`interactive_canvas.dart:248`) & floating multi-text-box support on infinite canvas.

---

## 5. Free Core vs Opennote Pro Monetization Matrix (Canvas & Tools)

| Feature Domain | Free Core (Generous, High-Delight) | Opennote Pro (High-Willingness-to-Pay) | Exact "Aha Moment" / Gate Trigger |
| :--- | :--- | :--- | :--- |
| **Core Ink & Gestures** | Fountain, Ballpoint, Highlighter, Pencil, Object Eraser, Scribble-to-Erase, Circle-to-Select, 6-Posture Palm Rejection, 120Hz Engine | Precision Stroke-Splitting Eraser, Unlimited Pen Tray Presets (6+), Dashed/Dotted Ink, Custom Pressure Curves, Stylus Tilt Shading | User taps `+` for 4th Pen Tray slot or selects "Precision Split Eraser" / "Beautify Handwriting". |
| **Infinite Canvas & Layers** | 1 Infinite Canvas whiteboard, Unlimited Paged notes, 2 Layers per page | Unlimited Infinite Canvases, Paged↔Infinite conversion, Unlimited Layers w/ opacity & reorder | User creates 2nd Infinite Whiteboard or taps `+ Add Layer` on a 2-layer diagram. |
| **Engineering Drafting** | Straight-line Ruler, Basic Arrow, Basic Shapes (Circle/Rect/Line) | Dimension Lines w/ calibrated units (`mm`/`cm`/`in`/`1:50`), Elbow/Curved Connectors, Interactive Magnetic Protractor/Ruler, Engineering/Isometric Grids, Pro Symbol Packs (EE/Mech/UML/Arch) | User selects Dimension tool, Isometric Grid, or opens Engineering Symbol Library beyond 3 free symbols. |
| **Study & Active Recall** | Solid Yellow Study Tape (basic conceal/reveal) | Patterned & Custom-Color Study Tape, Active Recall Quiz Mode, Flashcard Export | User taps patterned tape style or "Start Quiz Mode" in Study Tape HUD. |
| **Media, Search & Zoom** | Photo/PDF Import (180 DPI), Sticky Notes, 4 Default Elements | 300+ DPI Crisp PDF + Dark-Mode PDF Invert, Unlimited Reusable Element Packs, On-Device Handwriting OCR & Full-Text Ink Search, Auto-Advance Zoom Writing Window | User searches handwritten text or taps "Save to Elements" / "Convert Ink to Text" in Lasso Callout Menu. |
