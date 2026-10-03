<!-- 🤖 Generated with Grok 4.7 -->

# Opennote roadmap

Opennote is a fork of [Saber](https://github.com/saber-notes/saber) 1.34.3.
The goal is a handwriting notebook you can draft in: paper that matches the
geometry, tools that place real lines and dimensions, and symbols you can
reuse.

It stays a Saber notebook. Sync, encryption, PDF annotation, and the `.sbn2`
file format stay. Full CAD — constraints, parametrics, assemblies — is a
different product.

The README lists isometric grid, arrows, dimensions, ruler, snap, layers,
protractor, and a shape library. Several of those exist only as data types or
overlays. Nothing in the UI creates an arrow or a dimension, and snap is
stored in preferences with no control that turns it on.

## Where the code stands

| Promise | In the code today | Gap |
| --- | --- | --- |
| Isometric and engineering paper | Both patterns paint (`_canvas_background_painter.dart`) and both are page templates (`page_templates.dart`) | Isometric families do not meet at the same vertices, so a cube cannot sit on the printed lines. Engineering heavy lines use floating-point modulo (`y % (lineHeight * 10)`), so the bold rhythm drifts. |
| Ruler | `Ruler` drags a straight stroke and can snap | `snapToGrid`, `gridSize`, `snapToAngle`, and `snapAngleStep` live in `prefs.dart` and default off. No screen writes them. Default grid size is 20 px and is not the page line height. |
| Arrows, dimensions, polygons | `ArrowStroke`, `DimensionStroke`, and `PolygonStroke` serialize and paint | No tool constructs them. A saved file can show one; a user cannot draw one. |
| Layers | Per-page list, visibility, reorder, merge, active layer for new strokes (`page.dart`, `layer_manager.dart`) | No rename, lock, or opacity. Strings are hardcoded English. Layer edits sit outside the undo stack. The class comment still says pages have a single implicit layer. |
| Protractor | HUD toggle, draggable 180° overlay (`protractor_overlay.dart`) | No rotate, resize, or angle readout. It does not constrain the ruler. |
| Shape library | Eight electronics SVGs inserted as `SvgEditorImage` (`shape_library_dialog.dart`) | Not strokes, so they cannot snap, recolor, or take a dimension. Icons do not match the symbols. |
| Line style | `LineStyle` (solid, dashed, dotted) serializes on `Stroke` | No picker. |
| Tests | Large Saber suite. `canvas_backgrounds_test.dart` walks every pattern, including the new ones, and checks bounds and spacing | That test also asserts every line is horizontal or vertical, which isometric diagonals are not. Nothing asserts that isometric vertices concur. Nothing covers arrow, dimension, polygon, layers, the ruler, or the snap preferences. `snap_line_test.dart` covers upstream axis snap inside shape recognition, which is a different feature. |

What already works is inherited Saber: pens, highlighter, eraser, select,
shape recognition, PDF annotation, Nextcloud sync, and export. New tools
belong in their own classes, the way `Ruler` already does. `editor.dart` is
already a god file. More methods on it will make upstream merges impractical.

Keep the Dart package name `saber` so rebases stay possible. Change the name
the user sees. Changing the application id is a one-way store decision and
can wait until the drawing loop is good.

## How to build it

- One tool, one class. Register it from `editor.dart`. Do not grow that file.
- Tests before the UI. Follow the TDD note in `AGENTS.md`.
- English strings in the feature commit. Other languages in a following
  `i18n:` commit.
- Credit the model at the top of each changed source file, and do not remove
  existing credits.
- Rebase onto Saber when you can. Keep fork code in named files
  (`_arrow_stroke.dart`, `ruler.dart`, `layer_manager.dart`).
- Extend the existing stroke model. `ArrowStroke` and `DimensionStroke`
  already have a `shape` discriminator in `Stroke.fromJson`. Do not invent a
  second geometry model.
- Sticky notes, stickers, bookmarks, presentation mode, and planner templates
  can stay. They are not this roadmap.
- Leave KiCad, FreeCAD, and draw.io alone. Opennote wins when a sketch is
  measurable and tidy.

## Phase 1 — Paper and snap you can trust

Make the page geometrically true, then make strokes land on it.

- Rebuild the isometric painter so vertical, +30°, and −30° lines concur.
  Snap targets are those intersections, not a separate 20 px grid.
- Tie snap spacing to the page line height. A line that claims to be on the
  grid must sit on a printed line.
- Add editor HUD toggles: snap to grid, snap to angle, and a step of
  15° / 30° / 45° / isometric 30°. Show a ghost point while dragging.
- Fix the engineering grid so every 10th line is heavy by index, not by
  `y % (lineHeight * 10)`.
- Give `canvas_backgrounds_test.dart` a path for diagonal patterns, and add
  tests that assert concurring vertices. Add tests for snap math and for
  JSON round-trips of arrow, dimension, polygon, and layer.

Done when a ruler line drawn with snap on lies on a printed grid
intersection and stays there after save and reload.

## Phase 2 — The tools the README already names

Wire tools to the stroke classes that already exist.

- **Arrow.** Drag or two clicks. Single or double head. Writes `ArrowStroke`.
- **Dimension.** Pick two points, drag the offset, live label. Start in page
  pixels, using the text field `DimensionStroke` already has.
- **Polygon.** Click vertices, close on the first point, optional fill.
  Writes `PolygonStroke`.
- **Line style.** Solid, dashed, dotted, using the `LineStyle` already
  serialized on strokes.
- **Endpoint edit.** Select on these primitives moves vertices. Arrow heads
  and the dimension offset stay attached.
- **Protractor.** Rotate, resize, flip between 180° and 360°, readout of the
  angle between its baseline and a selected line. Optional: hold the ruler to
  that angle.
- **Layers.** Rename, lock, opacity. Active-layer chip visible while drawing,
  not only inside the page menu. Every layer operation records undo. Hidden
  layers stay out of PDF export. Update the stale comment on `Layer`.

Done when you can draw an arrow, dimension it, hide the construction layer,
undo the whole sequence, and export a PDF that matches the screen.

## Phase 3 — Units and object snap

This is the step that makes it a diagram tool.

- Page scale: one cell equals N millimetres. Dimension text uses that scale.
  Angle dimensions use the same label path.
- Object snap, in this order: endpoint, midpoint, intersection, center. Show
  which snap is active.
- Isometric mode snaps to the three axis directions and to the corrected grid.
- Duplicate, and duplicate along a line, for repeated symbols.
- A simple title-block template: title, date, scale, author. One page size.

Leader-line callouts wait until dimensions already read the right number. A
callout is a dimension whose text is not a length.

## Phase 4 — Symbols you can edit

- Stop inserting library items as `SvgEditorImage`. Store a symbol instance:
  a transform plus a list of primitives, so color, scale, and snap work.
- Ship two small packs, drawn to the same grid: basic geometry (arrow, center
  mark, section arrow) and the current eight electrical symbols, redrawn so
  terminals sit on grid points.
- Let the user save a selection as a symbol.
- Add further packs only after those two feel right: mechanical sketch marks,
  a few P&ID symbols. Match people who sketch, not people who file drawings.

## Phase 5 — Interchange

- SVG export that keeps lines, arrows, and polygons as vectors.
- PDF export stays the Saber path.
- SVG import of lines, circles, and polylines back into the same primitives.
- DXF import of those same primitives only after the in-app tools have been
  stable for a release. Writing DXF can follow import.

A constraint solver does not belong in this app.

## The next four builds

1. **Snap you can see.** HUD toggles, grid spacing taken from the page,
   isometric intersections fixed, tests for snap and paper.
2. **Arrows and dimensions you can draw.** Tools that construct the existing
   stroke classes, endpoint editing, undo.
3. **Measure.** Protractor rotate and readout, isometric angle snap, endpoint
   and midpoint object snap, page scale in millimetres.
4. **Symbols.** Library items as editable instances on the grid, plus
   save-selection-as-symbol.

## Release that earns the README

A student opens an isometric page, snaps a line to 30°, draws an arrow,
places a dimension that reads a real length, drops a resistor onto the grid,
hides the construction layer, and exports a PDF that still looks like the
page.

To safely modify this roadmap later, another agent should re-read the files
named in the table before editing a phase. Promote a row from "gap" to
"done" only when a test or a UI path actually constructs the feature. Do not
mark arrows or dimensions done while `ArrowStroke(` and `DimensionStroke(`
still appear only inside their own class files.
