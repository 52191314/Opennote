# Opennote — App Store & Google Play ASO Master Strategy

> **Version:** 2.0  
> **Scope:** Apple App Store (iOS / iPadOS) & Google Play Store (Android Phone / Tablet)  
> **Positioning:** Precision vector handwriting, engineering & STEM diagramming, PDF annotation, Study Tape active recall, and zero-knowledge encrypted sync.

---

## 1. Keyword Architecture & Search Matrix

### 1.1 Policy Guardrails
- **Zero competitor trademarks** in iOS `Keywords` (100-char field), iOS `Title`/`Subtitle`, or Google Play `Title`/`Short Description`/`Full Description`. Competitor-adjacent terms in Section 1.2.4 are strictly for **Apple Search Ads (ASA)**, **Google App Campaigns (ACi)**, and organic semantic topic modeling—never metadata stuffing.
- **Zero duplicate tokens** across iOS Title, Subtitle, and Keywords (Apple indexes the union automatically).
- **Zero spaces after commas** in the iOS 100-character keyword field.

### 1.2 Keyword Matrix (iOS App Store & Google Play)

#### A. Core Head Terms (High Volume, Broad Category Intent)
| Keyword | Est. Intent | Primary Platform | Metadata Placement | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `handwriting notes` | High | iOS + Play | Title / Subtitle / Short Desc | Core category anchor |
| `pdf annotator` | High | iOS + Play | Subtitle / Short Desc | High-LTV academic & pro intent |
| `digital notebook` | High | iOS + Play | Full Desc / iOS Keywords | Strong tablet search volume |
| `stylus notes` | Med-High | Play + iPadOS | Short Desc / Keywords | Captures Apple Pencil & S-Pen users |
| `infinite canvas` | Med-High | iOS + Play | Keywords / Full Desc | Differentiator vs paginated-only apps |
| `math notes` | Med-High | iOS + Play | Keywords / Full Desc | High student conversion |
| `note taking app` | Very High | Play | Full Desc (natural density) | Broad discovery |

#### B. Long-Tail High-Conversion Terms (Lower Competition, High Install CVR)
| Keyword Phrase | Target Persona | Primary Platform | Placement |
| :--- | :--- | :--- | :--- |
| `handwritten pdf annotation dark mode` | Night-study students | Play + ASA | Full Desc / Slide 4 |
| `infinite canvas vector notebook` | Visual thinkers | iOS + Play | Full Desc / CPP #4 |
| `offline private handwriting app` | Privacy-conscious pros | iOS + Play | Full Desc / Slide 7 |
| `study tape flashcard notes` | Med & university students | iOS + Play | Full Desc / CPP #2 |
| `zoom window handwriting tablet` | Small-handwriting / STEM | iOS + Play | Full Desc |
| `encrypted nextcloud notes sync` | Self-hosters / engineers | Play + iOS | Full Desc |
| `no account local first notes` | Privacy switchers | Play + iOS | Full Desc |

#### C. Engineering & STEM Niche Terms (Opennote's Unfair Moat)
| Keyword | Search Competition | Conversion Potential | Placement |
| :--- | :--- | :--- | :--- |
| `engineering notebook` | Low-Med | Very High | Title / Subtitle / CPP #1 |
| `isometric grid drawing` | Low | Very High | Keywords / Full Desc / Slide 2 |
| `technical diagram app` | Low | High | Short Desc / Keywords |
| `drafting tablet notes` | Low | High | Keywords / Full Desc |
| `millimeter graph paper` | Low | High | Full Desc / Slide 6 |
| `circuit schematic sketch` | Very Low | High | Full Desc / CPP #1 |
| `cornell notes template` | Med | High | Full Desc / Slide 6 |
| `hex grid notebook` | Very Low | Med-High | Full Desc |

#### D. Competitor-Adjacent Intent Terms (Paid ASA / ACi Campaigns ONLY — Never in Store Metadata)
| Paid Ad Group | Target Competitor Intent | Opennote Counter-Angle (Landing CPP / CSL) |
| :--- | :--- | :--- |
| `ASA_Comp_GoodNotes` | Paginated notebook & PDF switchers frustrated by subscription lock-in / bloat | **CPP #3 (PDF & Study):** "Local-first vector ink + Study Tape + transparent pricing" |
| `ASA_Comp_Notability` | Lecture & exam note-takers seeking dark mode PDF + active recall | **CPP #2 (University & Med):** "Study Tape active recall & dark-mode PDF annotation" |
| `ASA_Comp_Concepts` | Architects, engineers, & infinite-canvas sketchers | **CPP #1 (Engineering & Drafting):** "Isometric grids, precision drafting + paginated PDF export" |
| `ASA_Comp_Noteful_Freeform` | Minimalist iPad Pencil users wanting folders + infinite canvas | **CPP #4 (Visual Thinkers):** "Infinite canvas AND structured notebooks in one local-first app" |

### 1.3 Localized Market Prioritization
Opennote already ships 26 locale folders under `metadata/` (`ar`, `ca`, `cs`, `de`, `en-US`, `eo`, `es`, `fa`, `fr`, `he`, `hu`, `it`, `ja`, `nl`, `nl-NL`, `pl`, `pt`, `pt-BR`, `ru`, `sl`, `th`, `tr`, `uk`, `vi`, `zh-Hans-CN`, `zh-Hant-TW`). Prioritize full screenshot + keyword localization in three tiers based on tablet/stylus penetration and subscription ARPU:

| Tier | Locales | Rationale | Deliverables |
| :--- | :--- | :--- | :--- |
| **Tier 1 (Launch Wave)** | `en-US`, `de`, `ja`, `zh-Hans-CN`, `zh-Hant-TW`, `fr`, `es` | Highest iPad + Apple Pencil + S-Pen density and STEM university subscription WTP | Localized metadata + localized 8-slide screenshot text + localized CPP/CSL |
| **Tier 2 (Month 2)** | `pt-BR`, `it`, `nl`, `pl`, `ko` (add new), `vi` | Fast-growing Android tablet (Galaxy Tab / Xiaomi Pad) + university cohorts | Localized metadata + localized first 3 hero screenshots |
| **Tier 3 (Maintenance)** | `ar`, `cs`, `he`, `hu`, `ru`, `th`, `tr`, `uk`, `ca`, `sl`, `fa`, `eo` | Community-supported locales; keep free of legacy "Saber" leaks | Localized title/subtitle/short desc + English studio frames |

---

## 2. Store Conversion Rate Optimization (CRO) Audit

### 2.1 App Icon Audit (`assets/icon/`)
Inspection via Python PIL of current repository icon assets reveals critical hygiene and conversion gaps:

| Asset Path | Dimensions & Mode | Audit Finding | Action |
| :--- | :--- | :--- | :--- |
| `assets/icon/icon.png` | `1024x1024 RGB` | Primary icon; clean opaque square for App Store. | Baseline control (`Variant A`) for PPO/Play Icon A/B test. |
| `assets/icon/icon_ios_dark.png` | `1024x1024 RGBA` | iOS 18 Dark Mode icon ready. | Verify crisp contrast against `#000000` dock. |
| `assets/icon/icon_ios_tintable.png` | `1024x1024 RGB` | iOS 18 Tinted icon ready. | Keep in Xcode Asset Catalog. |
| `assets/icon/icon_maskable.png` | `1024x1024 RGBA` | Android adaptive icon maskable layer. | Confirm safe-zone padding (>= 20% inset) so circular/squircle masks never clip glyph. |
| `assets/icon/opennote_concept_flat.jpg` / `_ribbon.jpg` / `_squircle.jpg` | `1024x1024 RGB` | Three strong visual concept variants already exist! | Convert top performer to PNG and run as `Variant B` in App Icon PPO experiment. |
| `assets/icon/saber_logo_1x1.png` | `1024x1024 RGB` | **Legacy Saber branding leak** sitting in repo. | Remove or archive outside production asset bundle. |
| `assets/icon/icon.svg` & `android_feature_graphic.svg` | Vector SVG | **Legacy yellow Saber "S" vectors** still present in source icon folder. | Replace with Opennote vector mark before any SVG rasterization. |
| `assets/icon/resized/icon-{16..256}.png` | 11-byte broken symlink stubs on Windows | Fails PIL open; only `icon-512x512.png` (`512x512 RGB`) is valid. | Regenerate real PNGs if needed by desktop builds. |

### 2.2 Above-the-Fold First-3-Screenshots Audit (`metadata/en-US/images/`)
Current store screenshots suffer from **four severe conversion leaks**:
1. **Wasted Slots 3 & 4 on iOS & iPadOS:** `iphoneScreenshots/` (`1320x2868`) and `ipadScreenshots/` (`2064x2752`) only contain 4 images: `1_home.png`, `2_editor.png`, `3_login.png`, and `4_settings.png`. Showing a **Nextcloud Login screen** in Slot 3—which is visible *above the fold* in iOS Search Results!—kills install conversion by signaling mandatory account friction.
2. **Raw Unframed UI on Android:** `phoneScreenshots/` (`1280x2856`, 7 images: `1_home` through `7_settings`) lack benefit-driven headlines, device bezels, and visual hierarchy. Users scanning search results on a 6" phone cannot parse tiny toolbar icons without bold <=5-word value hooks.
3. **Missing Study Tape & Pro Value Proof:** Neither iOS nor Android screenshots showcase Study Tape active recall, Infinite Canvas vs Paginated dual mode, or Opennote Pro's transparent value proposition.
4. **Dimension Alignment:** App Store 6.7" requires `1290x2796` (or 6.9" `1320x2868`) and iPad Pro 12.9"/13" requires `2048x2732` (or `2064x2752`). Google Play requires `1080x1920` (9:16 portrait) + `1024x500` Feature Graphic.

#### The Above-the-Fold First-3 Formula (iOS Search & Play Browse)
Users see **Slides 1–3 simultaneously** in iOS portrait search results (~1.8 seconds of visual attention):
- **Slide 1 (Hero Hook):** *"Precision Notes & Diagrams"* — Immediate category clarity + Opennote's engineering-grade ink quality.
- **Slide 2 (Hero Differentiator):** *"120Hz Stylus & Drafting"* — Isometric grid + vector shape snapping + precision drafting tools (instant differentiation from generic note apps).
- **Slide 3 (Canvas Versatility):** *"Infinite Canvas & Pages"* — Solves the #1 buyer hesitation ("Is this an infinite whiteboard or a PDF notebook?" → Both!).

### 2.3 App Preview Video — 30-Second Shot-by-Shot Script
- **Specs:** 30 seconds max, 30fps or 60fps, silent-first (auto-plays muted in App Store search), bold clean caption overlays (Atkinson Hyperlegible SemiBold, white/slate high contrast), zero background clutter.
- **Resolutions:** iPhone 6.7" (`886x1920` portrait), iPad Pro (`1200x1600` portrait or `1600x1200` landscape), Google Play YouTube promo (`1920x1080` 16:9).

| Time | Visual Capture (Real App Screen) | On-Screen Caption (<=5 words) | Sound Design (Unmuted) |
| :--- | :--- | :--- | :--- |
| **0:00–0:03** | Open directly onto a crisp isometric engineering diagram being sketched live with Apple Pencil / stylus at 120Hz; stroke snaps into a clean 3D cube. | **Precision Notes & Diagrams** | Subtle crisp stylus-on-paper tick + soft chime |
| **0:03–0:08** | Tap Drafting Tool → draw straight vector line with angle readout → highlight an equation with true transparent compositing. | **120Hz Stylus & Drafting** | Soft mechanical click on shape snap |
| **0:08–0:13** | Pinch-zoom smoothly out on an Infinite Canvas mind map, then tap to switch to a crisp Paginated A4 engineering grid notebook. | **Infinite Canvas & Pages** | Gentle whoosh transition |
| **0:13–0:18** | Open a dense PDF textbook page → toggle **Dark Mode Inversion** (page flips to obsidian black with crisp white diagrams) → annotate margin with neon-blue ink. | **Annotate PDFs in Dark** | Clean toggle click |
| **0:18–0:23** | Swipe **Study Tape** over 3 anatomy/formula answers → tap each tape strip to reveal the hidden answer in real time. | **Study Tape Active Recall** | Tactile peel / pop sound |
| **0:23–0:27** | Quick montage of organized folder library + zero-knowledge encrypted sync badge ("Offline-first. Zero ads."). | **Private. Local-First. Synced.** | Calm ambient swell |
| **0:27–0:30** | Opennote icon lockup on clean `#FFFFFF` studio canvas + "Start Free · Try Opennote Pro 7 Days Free". | **Opennote** / *Precision Digital Notebook* | Resolution chord |

---

## 3. Custom Product Pages (iOS CPP) & Custom Store Listings (Play CSL)

Tailor landing pages to the 4 highest-LTV user cohorts via Apple Search Ads (ASA), Google App Campaigns, and organic/social deep links:

| Cohort | CPP / CSL Slug | Hero Screenshot Re-Ordering | Tailored Promo Text (<=170 chars) | Primary Acquisition Channels | Target CVR Lift |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **A. Engineering & Architecture Students/Pros** | `/engineering` | **Slide 2** (Drafting) → **Slide 1** (Hero) → **Slide 3** (Infinite Canvas) → Slide 6 (Templates) → Slide 7 (Privacy) → Slide 8 (Pro) | *Sketch isometric 3D projections, circuits, and millimeter-grid schematics with 120Hz vector ink, automatic shape snapping, and crisp PDF export.* | ASA (`engineering notebook`, `isometric grid`, `drafting app`), Reddit r/EngineeringStudents, YouTube STEM creators | +18% to +25% |
| **B. University & Medical Study / Flashcards** | `/study-tape` | **Slide 5** (Study Tape) → **Slide 4** (PDF Dark Mode) → **Slide 1** (Hero) → Slide 6 (Cornell Templates) → Slide 8 (Pro) | *Master exams faster with built-in Study Tape active recall, dark-mode lecture slide annotation, and Cornell templates—zero ads, works offline.* | ASA (`study notes`, `med school ipad`, `flashcard pdf`), TikTok/IG StudyTok | +15% to +22% |
| **C. PDF Textbook & Research Annotators** | `/pdf-annotator` | **Slide 4** (PDF & Dark Mode) → **Slide 1** (Hero) → **Slide 6** (Folders) → Slide 7 (Local-First) → Slide 2 (Highlighter/Pen) → Slide 8 (Pro) | *Import massive PDF textbooks and papers, highlight with true color compositing, invert pages for eye-friendly night reading, and export clean vector PDFs.* | ASA (`pdf annotator`, `markup pdf tablet`, `textbook notes`), Academic Twitter/X | +14% to +20% |
| **D. Visual Thinkers & Infinite Canvas Creators** | `/infinite-canvas` | **Slide 3** (Infinite Canvas) → **Slide 2** (Stylus & Shapes) → **Slide 1** (Hero) → Slide 7 (Sync) → Slide 8 (Pro) | *Map big ideas without borders on a boundless vector canvas—then switch to structured paginated notebooks whenever you need to print or share.* | ASA (`infinite canvas`, `mind map stylus`, `whiteboard app`), Product Hunt | +12% to +18% |

---

## 4. In-App Events (iOS) & Promotional Content (Play) — 90-Day Calendar

Apple In-App Events appear directly in Search Results for lapsed/non-users (replacing screenshots with a fresh event card) and boost re-engagement + editorial featuring. Google Play Promotional Content surfaces in the Games/Apps tabs and Store Listing.

| Window | Event Theme | Event Type | iOS Name (<=30 chars) | iOS Short Desc (<=50 chars) | iOS Long Desc (<=120 chars) | Deep Link Target |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Days 1–30** | **Engineering Drafting & Isometric Update** | Major Update | `Precision Drafting v2.0` (23) | `Isometric grids, snap shapes & 120Hz vector ink.` (48) | `Sketch 3D projections, schematics, and technical diagrams with our upgraded drafting engine and millimeter templates.` (117) | `opennote://templates/engineering` |
| **Days 31–60** | **Exam Prep Study Tape Challenge** | Challenge | `14-Day Study Tape Sprint` (24) | `Cover answers, test recall & ace your finals.` (45) | `Turn any lecture PDF or handwritten sheet into an active-recall quiz with Study Tape. Try 7 days of Opennote Pro free.` (118) | `opennote://editor/study-tape-demo` |
| **Days 61–90** | **Back-to-School / New Semester Starter Pack** | Special Event / Offer | `New Semester Template Pack` (26) | `Cornell, lab log & dark-mode PDF study kits.` (44) | `Start the term organized with engineering grids, Cornell note layouts, and encrypted offline notebooks—built for tablets.` (120) | `opennote://paywall?campaign=semester` |

---

## 5. Rigorous A/B Testing Roadmap (App Store PPO & Play Store Experiments)

Execute sequentially (never overlap Store Listing icon + screenshot tests simultaneously) to isolate lift cleanly. Sample sizes calculated for **80% statistical power, α = 0.05 (two-tailed)** assuming a baseline store CVR of 25% (for PPO/Play) and trial-start rate of 8% (for in-app paywall tests).

| Priority | Experiment Name | Platform / Tool | Variants | Primary Metric | Guardrail Metric | MDE | Min Sample / Variant | Est. Duration |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **P0 — Exp 1** | **App Icon Contrast & Silhouette** | iOS PPO & Play Store Experiments | **Control:** Current `icon.png`<br>**B:** `opennote_concept_squircle` (high-contrast navy/white drafting glyph)<br>**C:** `opennote_concept_flat` (minimal geometric nib) | Store Product Page CVR (Install / Impression) | Day-1 Retention & Uninstall Rate | +5% rel (+1.25 pp) | ~18,000 impressions | 14–21 days |
| **P0 — Exp 2** | **Screenshot #1 Headline Hook** | iOS PPO & Play Store Experiments | **Control:** *"Precision Notes & Diagrams"*<br>**B:** *"Handwrite, Draft & Ace Exams"*<br>**C:** *"Engineering Notes, Perfected"* | Store Product Page CVR | Tap-to-Download from Search | +5% rel | ~18,000 impressions | 14–21 days |
| **P1 — Exp 3** | **Paywall Trial Duration (7d vs 14d)** | In-App Remote Config (RevenueCat / Flag) | **Control:** 7-Day Free Trial (Annual)<br>**B:** 14-Day Free Trial (Annual) | Net Paid Conversion (Trial Start × Trial-to-Paid) at Day 21 | Refund Rate & Support Tickets | +10% rel | ~3,200 paywall views | 28 days (incl. 14d conversion lag) |
| **P1 — Exp 4** | **Annual Price Elasticity ($29.99 vs $39.99)** | In-App Remote Config / StoreKit / Play Billing | **Control:** $29.99/yr ($2.50/mo)<br>**B:** $39.99/yr ($3.33/mo) | Revenue per 1,000 Installs (ARPI at Day 30) | Trial Start Rate & Churn | +12% ARPI | ~4,000 paywall views | 30 days |
| **P2 — Exp 5** | **Onboarding Soft-Paywall Placement** | In-App Experiment | **Control:** Post-Personalization (End of 3-step onboarding)<br>**B:** Post-First-Note AHA Moment (after 1st saved note or PDF import) | Day-7 Trial Start Rate & Paid ARPI | Onboarding Completion Rate & Day-7 Retention | +10% rel | ~3,500 new installs | 21 days |
| **P2 — Exp 6** | **Lifetime Price Anchor Presence** | In-App Paywall Layout | **Control:** 2 Plans (Annual + Monthly)<br>**B:** 3 Plans (Annual *"Best Value"* + Monthly + $79.99 Lifetime Anchor) | Annual Plan Mix % & Blended Day-30 LTV | Paywall Dismiss Rate | +8% rel | ~3,500 paywall views | 21 days |

---

## 6. Ratings & Review Velocity Loop (`ReviewPromptService`)

App Store and Google Play ranking algorithms heavily weight **rating average (target >= 4.7★)**, **recent 30-day review velocity**, and **positive keyword sentiment** inside reviews.

### 6.1 Positive-Moment Trigger Architecture
Connect `ReviewPromptService` strictly to **earned moments of delight**—never on cold launch, mid-stroke, or after an error:
1. **Milestone Gate (ALL must pass):**
   - `>= 3` notes created or edited across `>= 2` distinct sessions
   - User just completed a high-satisfaction action: exported a crisp PDF/PNG, finished a Study Tape recall session, or saved an engineering diagram
   - Zero crashes or sync errors in the last 72 hours
   - Cooldown: `>= 90 days` since last prompt; max `3` native OS prompts per 365 days (Apple `SKStoreReviewController` hard limit)
2. **2-Step Ethical Sentiment Funnel:**
   - **Step 1 (In-App Pre-Prompt):** Clean non-modal bottom sheet: *"Enjoying Opennote so far?"* with two clear actions: **"Yes, love it"** and **"Could be better"**.
   - **Step 2A (Happy Path → Native OS Review):** Triggers `InAppReview.requestReview()` (iOS `SKStoreReviewController` / Android Play In-App Review API) immediately while delight is peak.
   - **Step 2B (Constructive Path → Private Feedback):** Routes to in-app feedback / GitHub issue / support email—capturing actionable bug reports without polluting public store ratings (compliant with Apple/Google guidelines because we never incentivize or gate features on leaving a 5-star review).

### 6.2 Review-to-ASO Feedback Loop
- **Weekly Review Mining:** Tag recurring 5-star praise phrases (e.g., *"isometric grid saved my statics class"*, *"best dark mode PDF reader"*) and feed exact customer phrasing into Slide 1–4 subheads and Play Store full description.
- **Developer Replies (< 24h SLA on 1–3★):** Responding rapidly with fix timelines converts ~25–35% of 1–2★ ratings into 4–5★ updates on Google Play and builds trust for prospective installers reading "Most Critical" reviews.
- **Target KPIs:** Sustain `>= 4.75★` average rating, `>= 2.5%` review-submission rate among Day-7 active users, and `> 40` net new reviews/month per platform to unlock sustained Top-25 Productivity category ranking.
