# Opennote v2 — ASO, Store Presence & Monetization Strategy Audit

> **Prepared by:** `audit-aso-growth` (ASO, Store Presence & Monetization Strategy Auditor)  
> **Scope:** Read-only audit of `metadata/**`, `pricing.md`, `pricing-cs.md`, `README*.md`, `docs/index.html`, `assets/banner/**`, `assets/icon/**`, `ROADMAP.md`, `PROJECT.md`  
> **Target Consumers:** `aso-store-copy`, `aso-visual-kit`, `monetize-paywall-ui`, `monetize-onboarding`, `verify-ui-aso`

---

## Executive Summary

Opennote has a strong technical foundation and a clear, underserved niche (**precision engineering diagramming + active-recall student handwriting notebook + local-first privacy**), but its current store presence and monetization assets suffer from **critical upstream Saber brand leakage, missing iOS App Store metadata, unoptimized storefront visuals, and zero in-app subscription infrastructure**.

### Top 5 P0 Findings
1. **Severe Upstream "Saber" Brand Leakage:** 11 of 26 `metadata/` locales leak `"Saber"` in store descriptions/titles (`title.txt = "Saber"` in 8 locales including `es`, `ja`, `pl`, `uk`, `vi`, `zh-Hant-TW`). `README.md` contains **96** mentions of `Saber` (vs. 4 of `Opennote`) and a broken `YOUR_USER` release link; all 6 localized READMEs have **0** mentions of `Opennote`. `pricing.md` and `pricing-cs.md` still direct users to pay `adil192` via GitHub Sponsors and email `adilhanney@disroot.org`.
2. **100% Missing iOS App Store Metadata:** Zero locales have Fastlane iOS fields (`name.txt`, `subtitle.txt`, `keywords.txt`, `promotional_text.txt`, `description.txt`, `release_notes.txt`).
3. **Stale & Broken Store Visuals:** `assets/icon/icon.svg` and `assets/icon/android_feature_graphic.svg` are still the yellow **Saber "S"** logo; `assets/icon/saber_logo_1x1.png` remains in the repo; 7 resized icon files in `assets/icon/resized/` are broken 11-byte symlink stubs on Windows; and all non-phone screenshot sets (`ipadScreenshots`, `iphoneScreenshots`, `macbookScreenshots`, `tenInchScreenshots`, `flathubScreenshots`) plus 19 localized screenshot folders still ship the old 4-slide Saber set (`1_home`, `2_editor`, `3_login`, `4_settings`).
4. **Under-Optimized `en-US` Store Copy:** Google Play `short_description.txt` (75/80 chars) spends 31 chars on niche `"zero-knowledge encrypted sync"` instead of high-volume search intents (`PDF`, `ruler`, `isometric`, `dark mode`, `infinite canvas`). `full_description.txt` contains a factual error (`"Dual-Password Dark Mode Inversion"`) and omits signature Opennote differentiators (`Study Tape`, `Ruler`, `Protractor`, `Layers`, `120Hz zero-lag ink`, `Hold-to-Straighten Highlighter`).
5. **Monetization & Policy Readiness Gap:** There is no subscription packaging, trial paywall, or contextual upgrade path. `docs/index.html` (line 464) currently claims *"no ... commercial monetization scripts"* and lacks an Apple-mandated Terms of Use / EULA link required for auto-renewable subscriptions (App Review Guideline 3.1.2(c)).

---

## 1. Current ASO & Brand Presence Teardown

### 1.1 `metadata/en-US/` Store Copy Audit

| Field | Current Content | Chars / Limit | Diagnosis & Specific Defects |
| :--- | :--- | :---: | :--- |
| **`title.txt`** | `Opennote: Engineering Notebook` | **30 / 30** | Clean brand + niche, hits exact 30-char cap. **Weakness:** Misses highest-volume head terms (`Notes`, `PDF`, `Handwriting`). Consider testing `Opennote: Notes & PDF Diagrams` (30 chars) or `Opennote: Handwriting & CAD` / `Opennote: Notes & Engineering` (29 chars) depending on keyword strategy. |
| **`short_description.txt`** | `Handwritten notes & engineering diagrams with zero-knowledge encrypted sync` | **75 / 80** | **Weak conversion hook.** Spends 31 chars on `"zero-knowledge encrypted sync"` (low search volume, high cognitive load for mainstream students). Misses `"PDF"`, `"infinite canvas"`, `"ruler"`, `"isometric"`, `"dark mode"`. |
| **`full_description.txt`** | 4-section feature list (3,051 chars) | **3,051 / 4,000** | **Defects:**<br>1. **Factual/copy bug (Line 15):** `"Dual-Password Dark Mode Inversion"` conflates Nextcloud dual-password sync with Dark Mode PDF inversion.<br>2. **Missing flagship features:** Zero mention of **Study Tape** (active recall), **Ruler**, **Protractor**, **Layers**, **120Hz zero-lag ink**, **Apple Pencil / S-Pen**, **Hold-to-Straighten Highlighter**, or **Page Thumbnail Grid**.<br>3. **Unverified claims risk:** Lists `hex grids` and `Zoom Window` — verify against actual shipped UI before keeping in store copy (see `ROADMAP.md` feature truth table).<br>4. **Weak opening hook:** First 250 chars (above the Google Play fold) read like a generic README instead of a crisp student/engineer value proposition. |
| **iOS Fields** | *Missing completely* | **0 / 6 files** | Missing `name.txt` (≤30), `subtitle.txt` (≤30), `keywords.txt` (≤100), `promotional_text.txt` (≤170), `description.txt` (≤4,000), `release_notes.txt`. |

### 1.2 Localized Metadata Audit (All 26 Locales under `metadata/`)

| Category | Count | Locales | Findings & Required Action (`aso-store-copy`) |
| :--- | :---: | :--- | :--- |
| **Clean `en-US` baseline** | 1 | `en-US` | Needs copy upgrade + iOS fields + refreshed screenshots. |
| **Active `"Saber"` Title Leak (`title.txt = "Saber"`)** | 8 | `es`, `he` (`\u200fSaber`), `ja`, `nl-NL`, `pl`, `uk`, `vi`, `zh-Hant-TW` | **P0 Blocker.** Users in Spain, Japan, Poland, Vietnam, Taiwan, Israel, Netherlands, and Ukraine see the app named **"Saber"** in Play Store / F-Droid! Must replace immediately. |
| **Active `"Saber"` Description Leak** | 11 | `cs`, `es`, `he`, `ja`, `nl-NL`, `pl`, `ru`, `uk`, `vi`, `zh-Hans-CN`, `zh-Hant-TW` | `full_description.txt` (and `vi/short_description.txt`) still describe Saber & Nextcloud sponsorship. Rewrite or remove stale files so stores fall back cleanly to updated `en-US` until localized. |
| **Empty Text Locales (Changelogs / Old Images Only)** | 14 | `ar`, `ca`, `de`, `eo`, `fa`, `fr`, `hu`, `it`, `nl`, `pt`, `pt-BR`, `sl`, `th`, `tr` | Zero top-level `.txt` files; 12 of these still ship **12 upstream Saber screenshots each**. |
| **Priority Tier-1 Locales to Localize First** | 8 | `en-US`, `de`, `es`, `fr`, `ja`, `zh-Hans-CN`, `zh-Hant-TW`, `pt-BR` (+ `ko-KR` new) | Highest iPad/tablet stylus ARPU & STEM student markets. Provide full Google Play + iOS Fastlane fields for these Tier-1 locales; purge stale Saber files from remaining locales. |

### 1.3 Repository Docs, Pricing & Web Privacy Policy Audit

| File | Exact Issues Identified | Required Action |
| :--- | :--- | :--- |
| **`README.md`** | • **96** mentions of `Saber`, **15** of `adil`, only **4** of `Opennote`.<br>• Line 9: broken placeholder URL `https://github.com/YOUR_USER/opennote/releases`.<br>• Lines 19–25: language links point to `saber-notes/saber`.<br>• Lines 45–63: badges & screenshots hotlink `saber-notes/saber` and `com.adilhanney.saber`.<br>• Lines 100–107: `"Supporting Saber"` links to `github.com/sponsors/adil192` and `paypal.me/adilhanney`.<br>• Lines 134–151: store badges link to Saber's Play Store (`com.adilhanney.saber`) and App Store (`id1671523739`). | Rewrite `README.md` for Opennote (retain respectful upstream fork attribution to Saber GPLv3 at bottom); fix repo URLs to `52191314/Opennote`. |
| **`README-{ar,cs,de,vi,zh-CN,zh-TW}.md`** | 105–116 `Saber` mentions each, **0** `Opennote` mentions, **15** `adil` mentions each. | Archive/remove stale upstream localized READMEs or replace with Opennote versions. |
| **`pricing.md` & `pricing-cs.md`** | 100% upstream Saber Nextcloud storage sponsorship (`adil192`, `adilhanney@disroot.org`, 5GB–100GB tiers). Zero mention of Opennote Pro, Free tier, 7-day trial, Student, or Lifetime plans. | Replace `pricing.md` with Opennote's Free / Pro Monthly / Pro Annual / Student / Lifetime pricing matrix & FAQ. |
| **`docs/index.html` & `docs/privacy-policy.html`** | Strong Opennote branding (`com.woaiyj1314.opennote`, `52191314/Opennote`, `xianspired@gmail.com`), **but 3 compliance gaps:**<br>1. Line 464 claims *"no ... commercial monetization scripts"* — update to clarify **zero ads/trackers**, while native Apple StoreKit / Google Play Billing handles optional Pro subscriptions.<br>2. Header badges say only `Target: Google Play Store` — add `Apple App Store (iOS/iPadOS/macOS)`.<br>3. Missing **Terms of Use / EULA** section or sibling `docs/terms.html` — **mandatory** for Apple App Store auto-renewable subscriptions (Guideline 3.1.2(c)). | Update `docs/index.html` (and sync `privacy-policy.html`) + add `docs/terms.html` before App Store submission. |

### 1.4 Visual Assets & Store Screenshot Inventory (`assets/` & `metadata/en-US/images/`)

All binary images were audited headlessly via Python `PIL` (zero binary reads):

| Asset Group | Files & Verified Dimensions | Audit Verdict & Gaps (`aso-visual-kit`) |
| :--- | :--- | :--- |
| **App Icon Sources (`assets/icon/`)** | • `icon.svg` & `android_feature_graphic.svg`: **STILL yellow Saber "S" logo (`#faca22` + `#32322e`)!**<br>• `saber_logo_1x1.png`: 1024×1024 RGB (1.28 MB) — legacy Saber file.<br>• `opennote_vector_concept.svg`: clean monochrome `"On"` monogram.<br>• `opennote_concept_{flat,ribbon,squircle}.jpg`: 1024×1024 concept renders.<br>• `icon.png` / `icon_opaque.png`: 1024×1024 RGB (identical MD5 `eb5e672033`).<br>• `resized/icon-{16,24,32,48,64,128,256}.png`: **7 broken 11-byte symlink stubs** (unreadable by PIL); only `icon-512x512.png` (512×512 RGB) is valid and matches `metadata/en-US/images/icon.png`. | **P0 Brand Fix:** Replace `icon.svg` and `android_feature_graphic.svg` with finalized Opennote vector brand; delete `saber_logo_1x1.png`; regenerate real raster PNGs in `assets/icon/resized/` (no broken symlinks). Ensure iOS dark & tinted icons (`icon_ios_dark.png`, `icon_ios_tintable.png`) match Opennote's mark. |
| **Feature Graphics (`assets/banner/` & `metadata/en-US/images/`)** | • `featureGraphic.png` = `digital_note_app_banner_1024x500.png` = `android_feature_graphic.png` (1024×500 PNG RGB, MD5 `fc36028957`).<br>• `featureGraphic_alt.png` = `note_app_banner_1024x500.png` (1024×500 PNG RGB, MD5 `3d8065a4ed`).<br>• 2K sources: `2752x1536` JPEG. | Dimensions match Google Play's **1024×500** requirement. `aso-visual-kit` should produce a crisp, high-contrast Opennote v2 Feature Graphic with safe-zone margins (keep text/logo inside central 820×360 safe zone) and bold 4-word headline (`"Precision Notes & Diagrams"`). |
| **Phone Screenshots (`metadata/en-US/images/phoneScreenshots/`)** | 7 files at `1280x2856` PNG RGBA (`1_home`, `2_editor`, `3_diagrams`, `4_math`, `5_pdf`, `6_dark_mode`, `7_settings`). | **Raw UI captures without marketing framing.** Store listings with framed device mockups + 4–6 word benefit headlines convert **25–40% higher** than raw screenshots. Also drop `7_settings.png` (Settings screens never drive installs) and replace with **Study Tape Active Recall** or **Infinite + Paginated Canvas**. |
| **iOS / Tablet / Desktop Screenshots** | • `iphoneScreenshots/` (4 files, `1320x2868` — 6.9" iPhone 16 Pro Max spec)<br>• `ipadScreenshots/` (4 files, `2064x2752` — 13" iPad Pro spec)<br>• `tenInchScreenshots/` (4 files, `2560x1440` — 10" Android tablet)<br>• `macbookScreenshots/` (4 files, `2880x1800`)<br>• `flathubScreenshots/` (4 files, `1050x750`) | **P0 Visual Blocker:** All 5 sets still contain the stale 4-slide Saber sequence (`1_home`, `2_editor`, `3_login`, `4_settings`). **Never put a Login screen in Slot #3** (destroys conversion and contradicts local-first/no-account-required positioning!). Missing `sevenInchScreenshots/` for Google Play. |
| **Localized Screenshots (19 locales)** | 12 PNGs each in `ar, ca, cs, de, eo, es, fa, fr, he, hu, it, pl, pt-BR, ru, sl, th, tr, uk, vi` (228 stale Saber images total). | Purge stale upstream Saber screenshots so non-localized stores inherit the new Opennote framed set cleanly. |

---

## 2. Competitive Positioning & Unfair Advantages

### 2.1 Market Landscape Matrix (2026)

| Competitor | Pricing Model | Platforms | Core Strength | Key Vulnerability / User Pain Point |
| :--- | :--- | :--- | :--- | :--- |
| **GoodNotes 6** | $9.99/yr (Apple) or $29.99 one-time (Apple-only); cross-platform requires subscription. Free cap: **3 notebooks**. | iOS/iPadOS/macOS (native); Android/Windows (web-wrapper, laggy) | Massive student brand, templates, AI math, marketplace | **No true infinite canvas**; Android/Windows versions feel like sluggish web apps; aggressive 3-notebook free wall; closed proprietary cloud. |
| **Notability** | $14.99–$19.99/yr (Notability Plus); strict free edit limits | iOS/iPadOS/macOS only | Audio recording sync, polished lecture workflow | **Apple-only**; hated subscription pivot; **no engineering drafting tools** (no isometric grid, ruler, protractor, layers). |
| **Concepts** | $4.99/mo or $29.99/yr (Everything); a-la-carte packs | iOS, Android, Windows | Best-in-class infinite vector canvas, precision grids & CAD-lite | **Not a notebook** (no paginated A4/Cornell pages, no study tape, poor multi-page PDF textbook management, steep learning curve). |
| **Noteful** | $5.99 one-time Pro unlock (Free cap: 10 notebooks) | iOS/iPadOS only | Lightweight, fast, layers, study tape, beloved one-time price | **Apple-only**; no infinite canvas; no engineering ruler/protractor/isometric snap; no cross-platform sync (iCloud only). |
| **Apple Freeform** | Free | iOS/iPadOS/macOS only | Infinite whiteboard, built-in Apple ecosystem | **Apple-only**; zero structured paper/templates; terrible for multi-page PDF annotation; no precision drafting or active-recall study tools. |
| **Opennote (Target)** | **Free Core + $19.99/yr Pro (7-day trial) / $9.99/yr Student / $49.99 Lifetime** | **iOS, iPadOS, Android, macOS, Windows, Linux** | **Hybrid Precision Notebook + Engineering Drafting + Active Recall + Local-First Privacy** | Needs flagship visual polish, frictionless onboarding, and clear store positioning (addressed in v2!). |

### 2.2 Opennote's 7 Unfair Advantages (Messaging Pillars)
1. **The Only Hybrid Precision Notebook:** Combines **GoodNotes-class structured pages** (A4, Cornell, PDF textbooks) with **Concepts-class engineering drafting** (Isometric/Engineering grids, Ruler, Protractor, Layers, Snap-to-Angle) AND an **Infinite Canvas** in one app.
2. **120Hz Zero-Lag Vector Ink:** Hardware-accelerated Skia/Impeller rendering with crisp infinite zoom — zero pixelation on complex schematics or tiny calculus subscripts.
3. **Built-In Active Recall (Study Tape):** Draw opaque masking strips over formulas, anatomy labels, or exam definitions and tap to conceal/reveal — a viral student study-tok / TikTok / Reddit feature.
4. **True Behind-Ink Highlighter + Hold-to-Straighten:** Canvas compositing renders highlighter *behind* ink without washing out text or darkening overlaps, with 400ms hold-to-straighten perfection.
5. **True OLED Dark-Mode PDF Inversion:** Invert both handwritten notes and white-background PDF textbooks/slides into crisp white-on-black for late-night studying without eye strain.
6. **Local-First & Zero-Knowledge Privacy:** Works 100% offline with zero mandatory account, zero ads, zero trackers, open `.sbn2` + PDF export, and optional client-side AES-encrypted Nextcloud/WebDAV sync.
7. **Genuinely Native Cross-Platform:** Native Flutter engine across iPad, Android tablets (Galaxy Tab / Boox e-ink), Windows, macOS, and Linux — unlike GoodNotes' web wrapper or Noteful/Notability's Apple lock-in.

### 2.3 Ready-to-Use ASO Copy Blueprint (For `aso-store-copy`)

> **Constraint Compliance Check:** iOS Title ≤30, iOS Subtitle ≤30, iOS Keywords ≤100 (comma-separated, **no spaces after commas**, **zero competitor trademarks** like GoodNotes/Notability/Concepts/Noteful/Freeform), iOS Promo ≤170; Google Play Title ≤30, Short Desc ≤80, Full Desc ≤4,000.

* **iOS & Google Play Title (30/30 chars):**  
  `Opennote: Notes & PDF Diagrams` *(30 chars — captures `Notes`, `PDF`, `Diagrams`, plus brand)*  
  *Alt (29 chars):* `Opennote: Engineering & Notes`
* **iOS Subtitle (30/30 chars):**  
  `Handwriting, Isometric & Study` *(30 chars — zero word duplication with Title!)*  
  *Alt (29 chars):* `Handwritten Notes & CAD Paper`
* **iOS Keywords Field (99/100 chars — no spaces after commas, no title/subtitle duplicates, no competitor names):**  
  `stylus,pencil,tablet,notebook,annotate,ruler,protractor,infinite,canvas,cornell,dark,math,drafting,s` → Trim cleanly to **98 chars**:  
  `stylus,pencil,tablet,notebook,annotate,ruler,protractor,infinite,canvas,cornell,dark,math,drafting` *(98 chars)*
* **iOS Promotional Text (164/170 chars — editable without app review):**  
  `Write with 120Hz zero-lag vector ink. Sketch on isometric grids, annotate dark-mode PDFs, and ace exams with Study Tape active recall. Try Opennote Pro free 7 days.` *(164 chars)*
* **Google Play Short Description (79/80 chars):**  
  `Handwritten notes, PDF annotation, isometric drafting & Study Tape—100% private` *(79 chars)*
* **6-Slide Framed Screenshot Narrative (For `aso-visual-kit`):**
  1. **Hero Value Prop:** `"Precision Notes & Diagrams"` — Split/hero iPad canvas showing crisp vector handwriting + isometric schematic + sleek toolbar.
  2. **Engineering Drafting:** `"Ruler, Protractor & Isometric Grid"` — Snapped 30° isometric drawing with ruler/protractor HUD and layers.
  3. **Study & Active Recall:** `"Ace Exams with Study Tape"` — Cornell notes page with Study Tape concealing/revealing formulas + behind-ink straight highlighter.
  4. **Dark-Mode PDF Annotation:** `"Read & Annotate PDFs in Dark Mode"` — Inverted textbook PDF with crisp white/cyan vector ink annotations.
  5. **Infinite + Paginated Canvas:** `"Infinite Canvas or Print-Ready Pages"` — Expansive mind-map/system diagram transitioning seamlessly to structured pages + thumbnail grid.
  6. **Privacy & Cross-Platform:** `"Offline-First. Zero Ads. Every Device."` — Clean multi-device badge (iPad, Android, Mac, Windows, Linux) + E2E encrypted sync shield.

---

## 3. Recommended Subscription & IAP Packaging

### 3.1 Pricing Architecture & Psychological Anchoring

| Plan | Price (USD) | Effective Monthly | Trial / Offer | Role in Pricing Psychology |
| :--- | :---: | :---: | :---: | :--- |
| **Free (`Opennote Core`)** | **$0** | $0.00 | Forever Free | **Trust & Viral Acquisition Engine.** Delivers genuine daily note-taking delight with zero ads and zero artificial 3-notebook traps, fueling 4.8★+ ratings and word-of-mouth. |
| **Pro Monthly** | **$3.99 / mo** | $3.99 | None (or 3-day) | **Decoy Price Anchor.** Establishes $47.88/yr reference value so Pro Annual looks like an irresistible **58% savings**. Captures short-term exam-week buyers. |
| **Pro Annual *(Default / Recommended)*** | **$19.99 / yr** | **$1.67 / mo** | **7-Day Free Trial** | **Primary Conversion Hero.** Visually highlighted with `"SAVE 58% • BEST VALUE"` badge and transparent 7-day trial timeline (Day 0 → Day 5 Reminder → Day 7 Charge). Undercuts Concepts ($29.99/yr) and matches Notability Plus while adding full cross-platform support. |
| **Student Annual** | **$9.99 / yr** | **$0.83 / mo** | **7-Day Free Trial** | **Campus Dominance Tier.** 50% off Annual for students (accessible via secondary toggle/link on paywall). Directly matches GoodNotes' $9.99/yr price while delivering superior STEM/engineering tools + Study Tape. |
| **Pro Lifetime Unlock** | **$49.99 once** | One-time IAP | None | **Anti-Subscription Capture & Cash-Flow Booster.** Priced at 2.5× Annual to capture subscription-fatigued engineers, Noteful fans, and privacy purists who gladly pay once for permanent ownership. |

### 3.2 Free vs. Pro Feature Matrix (Maximize Conversion Without Crippling Delight)

> **Golden Rule:** Never gate basic writing, erasing, or saving local notes. Gate **precision engineering power, exam-prep accelerators, unlimited visual organization, and cross-device/vector workflows**.

| Feature Category | Free (`Opennote Core`) | Opennote Pro | Why This Split Works |
| :--- | :---: | :---: | :--- |
| **Local Notebooks & Pages** | **Unlimited** | **Unlimited** | Eliminates #1 GoodNotes 1-star complaint; builds massive goodwill & retention. |
| **120Hz Vector Pens, Pencil, Eraser, Lasso** | Full access (3 custom pen presets) | Unlimited custom pen presets & tool tray | Core writing feels flagship on Day 1; power users quickly want 6+ color/nib presets. |
| **Highlighter Behind Ink & Hold-to-Straighten** | Included | Included | Signature quality-of-life delight that differentiates Opennote immediately. |
| **Paper Templates** | Standard (Blank, Lined, Grid, Dots) | **Engineering Suite** (Isometric, Millimeter Engineering, Cornell Notes, Music Staff, Warm Cream & Legal Pad themes, Custom Title Blocks) | High-intent contextual upgrade right inside the Template Picker! |
| **Canvas Mode** | Paginated Pages | **Infinite Canvas** + Paginated Hybrid | High perceived value for engineers, architects, and visual thinkers. |
| **Drafting & Precision Tools** | Basic Shape Recognition | **Ruler, Protractor, Snap-to-Grid/Angle, Arrow & Dimension Tools, Polygon Fill** | Core monetization wedge for STEM/engineering/architecture segments. |
| **Page Layers** | 1 Default Layer | **Unlimited Layers** (Visibility, Reorder, Merge, Lock, Opacity) | Clean, intuitive power-user boundary (same proven model as Noteful). |
| **Study Tape (Active Recall)** | Preview / up to 3 strips per page | **Unlimited Study Tape** + One-Tap Reveal-All / Quiz Mode | Lets students feel the "Aha!" moment before hitting a contextual Pro gate during exam prep. |
| **PDF Import & Annotation** | Import & annotate PDFs (up to 25 pages) | **Unlimited PDF Textbooks (1,000+ pages)** + **Dark-Mode PDF Inversion** | Students feel the value on homework sheets, then upgrade for full 400-page textbooks & late-night dark mode. |
| **Export Formats** | Standard PDF & PNG export | **High-Res Vector PDF, SVG Vector Export, Batch Folder Export** | Professionals & thesis students gladly pay for vector-clean outputs. |
| **Cloud Sync** | Local-only + Manual `.sbn2` Backup | **Automated Cross-Device E2E Encrypted Sync** (Nextcloud / WebDAV / Managed Sync) | Recurring cloud/cross-device value aligns naturally with Annual subscription. |
| **Ads & Tracking** | **Zero Ads, Zero Trackers** | **Zero Ads, Zero Trackers** | Non-negotiable brand pillar across all tiers. |

### 3.3 Ethical Paywall & Store Compliance Checklist (`monetize-paywall-ui`)
* **Transparent 7-Day Trial Timeline:** Visually render 3 clear nodes: **Today** (*Full Pro unlocked, $0 charged*) → **Day 5** (*Reminder before trial ends*) → **Day 7** (*Annual billing begins, cancel anytime in 1 tap*).
* **Zero Dark Patterns:** Visible top-right close (`×`) button or `"Continue with Free"` link on first render (no hidden/delayed close buttons or fake countdown timers).
* **Apple Guideline 3.1.2 Mandatory Footer:** Clearly display billing cadence, auto-renewal notice, **"Cancel Anytime"** reassurance, **"Restore Purchases"** button, and clickable links to **Terms of Use** and **Privacy Policy**.
* **Responsive Layout:** Must render cleanly without overflow on compact phones (`360×640` / `390×844`) AND wide tablets (`1024×768`+ two-column hero + plan selector).

---

## 4. Funnel & ASO Flywheel Blueprint

### 4.1 End-to-End Conversion & Retention Funnel

```
[App Store / Play Store Search]
  │  Title + Subtitle + 6 Framed Benefit Slides + 4.8★ Rating
  ▼  (Target Store Page CVR: 35–45%)
[First-Run Onboarding (< 45 sec)]
  │  Step 1: Welcome & 120Hz Value Hook ("Write. Draft. Ace.")
  │  Step 2: Personalize Role (Engineering/STEM • Student • Designer • General)
  │  Step 3: Pick Starting Paper (Isometric / Cornell / Lined / Infinite)
  │  Step 4: Soft 7-Day Trial Paywall (Annual anchored, clear Free escape hatch)
  ▼  (Target Onboarding → Trial Start: 12–18% | Free Activation: 75%+)
[Core Canvas Delight & Contextual Pro Gates]
  │  User writes, highlights, annotates → hits high-intent Pro tool
  │  (e.g., Isometric Snap, Layer #2, Study Tape #4, Dark PDF Inversion)
  │  → Contextual Upgrade Sheet showing THAT exact feature + 7-Day Trial CTA
  ▼  (Target Contextual Gate → Trial Start: 8–14%)
[Aha-Moment 2-Step ASO Rating Funnel]
  │  Trigger ONLY after genuine delight:
  │  ≥ 3 sessions AND (≥ 1 PDF exported OR ≥ 15 min active drawing)
  │  NEVER trigger after crash, error, or paywall dismissal!
  │
  │  Step 1 (Soft In-App Prompt): "Enjoying Opennote so far?"
  │   ├─ [Yes, Love It!] ──▶ Native SKStoreReviewController / Play In-App Review
  │   └─ [Needs Work]    ──▶ Private Feedback / GitHub Issue (deflects 1–2★ bugs)
  ▼
[Organic ASO Flywheel]
  Higher Star Rating (4.8★+) + Fresh Keyword-Rich Reviews
  ──▶ Higher Organic Rank ("engineering notebook", "isometric notes", "study tape")
  ──▶ More Organic Installs at $0 CAC ──▶ Larger Trial Funnel ──▶ Compounding MRR
```

### 4.2 Target KPI Benchmarks (First 90 Days Post-v2 Launch)

| Funnel Stage | Metric | Target Benchmark | Primary Lever |
| :--- | :--- | :---: | :--- |
| **Storefront** | Store Listing Conversion Rate (Impressions → Installs) | **35% – 45%** | Framed 6-slide visual narrative + clean Opennote icon + zero Saber leaks |
| **Activation** | Onboarding Completion Rate | **≥ 80%** | ≤ 45-second 3-step personalization + immediate canvas drop-in |
| **Monetization** | Install → 7-Day Trial Start (Onboarding + Contextual) | **10% – 15%** | Transparent trial timeline + Annual 58% savings anchor + contextual Pro sheets |
| **Monetization** | 7-Day Trial → Paid Conversion | **40% – 55%** | In-trial engagement with Pro templates, Study Tape, and Dark-Mode PDFs |
| **Monetization** | Lifetime IAP Mix (% of Paid Conversions) | **15% – 25%** | $49.99 one-time anchor for subscription-averse engineers |
| **ASO Flywheel** | Public Store Star Rating | **≥ 4.7★ (Goal: 4.8★+)** | 2-step Aha-moment rating gate + generous unlimited-notebook Free tier |

---

## 5. Actionable Handoff Summary for Downstream Agents

1. **`@aso-store-copy`:**
   - Replace `metadata/en-US/{title,short_description,full_description}.txt` using Section 2.3 copy (fixing `"Dual-Password Dark Mode Inversion"` and adding Study Tape, Ruler, Protractor, Layers, 120Hz ink).
   - Create full iOS Fastlane metadata (`name.txt`, `subtitle.txt`, `keywords.txt`, `promotional_text.txt`, `description.txt`, `release_notes.txt`) strictly within `30 / 30 / 100 / 170 / 4000` char limits (zero spaces after commas in `keywords.txt`, zero competitor trademarks).
   - Eliminate all **11 localized Saber leaks** (`cs, es, he, ja, nl-NL, pl, ru, uk, vi, zh-Hans-CN, zh-Hant-TW`) and deliver clean Tier-1 localizations (`en-US, de, es, fr, ja, zh-Hans-CN, zh-Hant-TW, pt-BR`).
   - Rewrite `pricing.md`, `README.md` (fix `YOUR_USER` + 96 Saber leaks), and update `docs/index.html` (+ add Terms of Use link) for native IAP compliance.
2. **`@aso-visual-kit`:**
   - Replace stale Saber `assets/icon/icon.svg` & `android_feature_graphic.svg`, delete `saber_logo_1x1.png`, and fix the 7 broken 11-byte symlinks in `assets/icon/resized/`.
   - Build `scripts/aso/generate_store_frames.py` to generate the 6-slide framed marketing screenshot kit (Section 2.3) across iPhone 6.9" (`1320x2868`), iPad 13" (`2064x2752`), Android Phone (`1280x2856`), 10" Tablet (`2560x1440`), and Google Play Feature Graphic (`1024x500`), replacing all stale `3_login.png` / `4_settings.png` Saber screenshots.
3. **`@monetize-paywall-ui` & `@monetize-onboarding`:**
   - Implement the 3-step personalization onboarding + soft 7-day trial paywall (`$19.99/yr` default anchor with Save 58% badge, `$3.99/mo` decoy, `$9.99/yr` Student toggle, `$49.99` Lifetime unlock), contextual Pro upgrade sheets mapped to Section 3.2's matrix, and the 2-step Aha-moment store rating funnel (Section 4.1).
