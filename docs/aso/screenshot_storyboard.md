# Opennote — 8-Slide Store Screenshot Conversion Storyboard

> **Aesthetic Direction:** Minimalist Precision Studio — pure white (`#FFFFFF`) & ultra-subtle slate (`#F8FAFC`) canvases, deep obsidian (`#0B1120`) for Dark Mode & Pro slides, architectural micro-grid hairlines, crisp device bezels, bold `<= 5-word` headlines in **Atkinson Hyperlegible Next SemiBold**, and a disciplined 3-accent palette (`#2563EB` Royal Blue, `#16A34A` Forest Green, `#D97706` Precision Amber). **Zero rainbow gradients or visual clutter.**

---

## 1. Target Output Dimensions & Platform Matrix

| Platform Target | Output Size (px) | Aspect Ratio | Safe Text Zone (Top) | Device Frame Zone | Format |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **iOS App Store — iPhone 6.7"** | `1290 × 2796` | 9:19.5 | `y: 120–620` | `y: 660–2660` (centered bezel) | RGB PNG |
| **iOS App Store — iPad Pro 12.9"** | `2048 × 2732` | 3:4 | `y: 120–560` | `y: 600–2600` (tablet bezel) | RGB PNG |
| **Google Play — Android Phone** | `1080 × 1920` | 9:16 | `y: 80–430` | `y: 460–1830` (phone bezel) | RGB PNG |
| **Google Play — Android Tablet** | `1920 × 1200` (or `2048 × 2732` portrait) | 16:10 / 3:4 | Left 42% copy / Right 58% frame (landscape) | Centered tablet bezel | RGB PNG |
| **Google Play — Feature Graphic** | `1024 × 500` | ~2.05:1 | Left 54% lockup + tagline | Right 46% angled/crisp device preview | RGB PNG |

---

## 2. Slide-by-Slide Conversion Storyboard (8 Slides)

### Slide 1 — Hero Hook (Above-the-Fold #1)
- **Kicker:** `OPENNOTE · ENGINEERING NOTEBOOK`
- **Headline (4 words):** **Precision Notes & Diagrams**
- **Subhead:** Natural vector handwriting and technical sketching built for tablets and stylus.
- **Visual Focal Point:** Clean Home/Editor hero showcase (`iphoneScreenshots/1_home.png`, `ipadScreenshots/1_home.png`, `phoneScreenshots/1_home.png`) paired with the Opennote app icon lockup in the header.
- **Studio Palette:** Canvas `#FFFFFF`, Grid `#E2E8F0`, Headline `#0F172A`, Subhead `#475569`, Accent `#2563EB` (Royal Blue).
- **Conversion Goal:** Instant 1.5-second category + quality recognition in App Store & Play Search.

### Slide 2 — Stylus & Drafting Tools (Above-the-Fold #2)
- **Kicker:** `DRAFTING & VECTOR INK`
- **Headline (4 words):** **120Hz Stylus & Drafting**
- **Subhead:** Isometric grids, automatic shape snapping, zoom window, and zero-lag vector strokes.
- **Visual Focal Point:** Active engineering diagram canvas (`phoneScreenshots/3_diagrams.png` / `iphoneScreenshots/2_editor.png` / `ipadScreenshots/2_editor.png`) highlighting crisp geometric vectors and pen toolbar.
- **Studio Palette:** Canvas `#F8FAFC`, Grid `#E2E8F0`, Headline `#0F172A`, Subhead `#475569`, Accent `#2563EB` (Royal Blue).
- **Conversion Goal:** Immediately differentiate Opennote from generic text/note apps via STEM & drafting precision.

### Slide 3 — Dual Canvas Architecture (Above-the-Fold #3)
- **Kicker:** `DUAL CANVAS ENGINE`
- **Headline (4 words):** **Infinite Canvas & Pages**
- **Subhead:** Brainstorm without borders on an infinite whiteboard or structure clean paginated notebooks.
- **Visual Focal Point:** Expansive math/diagram workspace (`phoneScreenshots/4_math.png` / `iphoneScreenshots/2_editor.png` / `ipadScreenshots/2_editor.png`) demonstrating crisp vector math & layout flexibility.
- **Studio Palette:** Canvas `#FFFFFF`, Grid `#E2E8F0`, Headline `#0F172A`, Subhead `#475569`, Accent `#0F766E` (Teal Slate).
- **Conversion Goal:** Resolve the #1 buyer fork ("whiteboard vs notebook") in the third above-the-fold slot.

### Slide 4 — PDF Annotation & Dark Mode
- **Kicker:** `PDF & NIGHT STUDY`
- **Headline (4 words):** **Annotate PDFs in Dark**
- **Subhead:** Import textbooks and slides, highlight cleanly, and invert pages for eye-friendly study.
- **Visual Focal Point:** Dark-mode annotated PDF / note view (`phoneScreenshots/6_dark_mode.png` / `phoneScreenshots/5_pdf.png` / `test/goldens/home_theme_iOS_dark.png`) framed in a dark titanium bezel.
- **Studio Palette:** Canvas `#0B1120` (Deep Obsidian), Grid `#1E293B`, Headline `#F8FAFC`, Subhead `#94A3B8`, Accent `#38BDF8` (Sky Blue).
- **Conversion Goal:** High-contrast dark slide breaks visual monotony in the carousel and converts late-night university/med students.

### Slide 5 — Study Tape Active Recall
- **Kicker:** `ACTIVE RECALL`
- **Headline (4 words):** **Study Tape Active Recall**
- **Subhead:** Mask formulas, terms, and diagrams with interactive tape—tap to reveal as you quiz yourself.
- **Visual Focal Point:** Annotated study sheet / PDF (`phoneScreenshots/5_pdf.png` / `iphoneScreenshots/2_editor.png` / `ipadScreenshots/2_editor.png`) showcasing clean study annotation workflow.
- **Studio Palette:** Canvas `#F8FAFC`, Grid `#E2E8F0`, Headline `#0F172A`, Subhead `#475569`, Accent `#D97706` (Precision Amber).
- **Conversion Goal:** Highlight a sticky, exam-winning feature that drives paid Opennote Pro trials.

### Slide 6 — Templates & Organization
- **Kicker:** `TEMPLATES & LIBRARY`
- **Headline (4 words):** **Smart Templates & Folders**
- **Subhead:** Engineering millimeter grids, isometric dots, Cornell notes, and instant folder search.
- **Visual Focal Point:** Clean library / home browse view (`test/goldens/home_theme_iOS_light.png` / `iphoneScreenshots/1_home.png` / `ipadScreenshots/1_home.png`).
- **Studio Palette:** Canvas `#FFFFFF`, Grid `#E2E8F0`, Headline `#0F172A`, Subhead `#475569`, Accent `#2563EB` (Royal Blue).
- **Conversion Goal:** Prove long-term organizational clarity across semesters and engineering projects.

### Slide 7 — Local-First Privacy & Sync
- **Kicker:** `ZERO-KNOWLEDGE PRIVACY`
- **Headline (3 words):** **Local-First Encrypted Sync**
- **Subhead:** Works 100% offline with zero ads, zero trackers, and optional end-to-end encrypted sync.
- **Visual Focal Point:** Clean privacy/settings/sync surface (`phoneScreenshots/7_settings.png` / `iphoneScreenshots/4_settings.png` / `ipadScreenshots/4_settings.png`) — framed with clear privacy benefit copy (replacing the raw legacy login screen).
- **Studio Palette:** Canvas `#F8FAFC`, Grid `#E2E8F0`, Headline `#0F172A`, Subhead `#475569`, Accent `#16A34A` (Forest Green).
- **Conversion Goal:** Convert privacy-sensitive engineers, researchers, and users fatigued by cloud lock-in.

### Slide 8 — Opennote Pro Value Summary
- **Kicker:** `OPENNOTE PRO`
- **Headline (3 words):** **Unlock Opennote Pro**
- **Subhead:** Unlimited notebooks, Study Tape, engineering templates & vector PDF export. Try 7 days free.
- **Visual Focal Point:** Premium studio dark-slate presentation of the flagship editor (`phoneScreenshots/2_editor.png` / `iphoneScreenshots/2_editor.png` / `ipadScreenshots/2_editor.png`) with clean 3-pillar summary strip at the bottom.
- **Studio Palette:** Canvas `#0F172A` (Studio Navy), Grid `#1E293B`, Headline `#FFFFFF`, Subhead `#CBD5E1`, Accent `#38BDF8` (Sky Blue).
- **Conversion Goal:** Pre-frame Opennote Pro transparently before install so Day-1 paywall views convert with higher trust and lower sticker shock.

---

## 3. Google Play Feature Graphic (`1024 × 500`)
- **Left Column (54% width):** Opennote app icon (`72×72` rounded squircle), bold title **"Opennote"**, subtitle **"Precision Notes & Diagrams"**, and concise trust line *"120Hz Vector Ink · Study Tape · Local-First Privacy"*.
- **Right Column (46% width):** Clean cropped studio phone bezel displaying the live diagramming editor (`phoneScreenshots/3_diagrams.png`) anchored against a crisp architectural dot grid on `#FFFFFF` / `#F8FAFC`.
- **No text near outer 40px edges** to survive Google Play's circular play-button overlay and responsive cropping.

---

## 4. Reproducible Generation
All 25 marketing assets (8 iPhone 6.7" + 8 iPad Pro 12.9" + 8 Android Phone + 1 Google Play Feature Graphic) and the interactive preview gallery (`docs/aso/store_preview_gallery.html`) are generated deterministically by [`scripts/aso/generate_store_frames.py`](../../scripts/aso/generate_store_frames.py). See [`docs/aso/README.md`](README.md) for the exact 1-line command.
