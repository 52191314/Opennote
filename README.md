# Opennote — 120Hz Handwriting, PDF Annotation & Precision Drafting

**Opennote** is a fast, local-first digital notebook built for natural 120Hz handwriting, PDF annotation, infinite canvas brainstorming, and precision engineering diagrams—available across iOS, iPadOS, Android, macOS, Windows, and Linux.

> Open-source under **GNU GPLv3** • Built on top of the upstream [Saber](https://github.com/saber-notes/saber) project with expanded engineering drafting tools, infinite canvas workflows, Study Tape active recall, and a refreshed cross-platform UI.

[Product Landing Page](https://52191314.github.io/Opennote/) · [Pricing & Opennote Pro](./pricing.md) · [Privacy Policy](./docs/privacy-policy.html) · [Releases](https://github.com/52191314/Opennote/releases)

---

## Why Opennote?

- **120Hz Vector Ink & Natural Gestures**: Smooth fountain pen, ballpoint, shader pencil, and true-compositing highlighter that never washes out text or darkens on overlap—paired with Scribble-to-Erase and Circle-to-Select gestures.
- **Precision Drafting Suite**: Ruler, protractor, automatic shape recognition, snap-to-grid, and technical templates (isometric, millimeter graph, hex, Cornell, blueprint, and music staves).
- **Infinite Canvas + Paginated Notebooks**: Switch between structured pages for printing/homework and an unbounded infinite canvas for mind maps, schematics, and whiteboarding.
- **Smart PDF Annotation & Study Tape**: Import textbooks, slides, and worksheets; invert notes and PDFs in Dark Mode for comfortable night study; cover formulas and terms with **Study Tape** for tap-to-reveal active recall.
- **Local-First Privacy & Zero-Knowledge Sync**: Works 100% offline with zero ads or tracking. Optionally sync across all devices using any **Nextcloud** or **WebDAV** server with client-side AES encryption.

---

## Opennote Free & Opennote Pro

Core handwriting, paginated notebooks, PDF annotation, dark mode inversion, local storage, and self-hosted encrypted sync are **free forever**.

| Plan | Price | Highlights |
|---|---|---|
| **Opennote Free** | **$0** | Everyday handwriting, paginated notebooks, PDF annotation, dark mode, local-first storage |
| **Opennote Pro Annual** | **$29.99 / year** | Save 50% + **7-day free trial** — Infinite Canvas, Drafting Suite, Study Tape, High-Res Vector Export |
| **Opennote Pro Monthly** | **$4.99 / month** | Full Pro toolkit, cancel anytime |
| **Opennote Pro Student** | **$14.99 / year** | 50% off Annual for verified students |
| **Opennote Pro Lifetime** | **$69.99** one-time | Own Opennote Pro forever, no recurring subscription |

See [pricing.md](./pricing.md) ([čeština](./pricing-cs.md)) for the full feature comparison and FAQ.

---

## Installation

### Android
Download the latest APK from [GitHub Releases](https://github.com/52191314/Opennote/releases) or build from source.

### iOS / iPadOS (SideStore / AltStore / LiveContainer)
Build via GitHub Actions (see `.github/workflows/`):
1. Push → Actions → **"Build iOS"** → Run workflow
2. Download the unsigned `.ipa` artifact
3. Open in SideStore → My Apps → `+` → select `.ipa`
4. SideStore re-signs with your Apple ID

### Build from Source
Opennote pins its Flutter SDK in `submodules/flutter`. After cloning with submodules:

```bash
flutter pub get
flutter test
flutter run
```

See [AGENTS.md](./AGENTS.md) for architecture invariants and development guidelines.

---

## Project Structure

```text
Opennote/
├── lib/                 # Flutter app: components/, data/ (incl. tools/), i18n/, pages/, main.dart
├── test/                # Unit and widget tests
├── packages/            # Local packages (onyxsdk_pen, sbn)
├── submodules/flutter   # Pinned Flutter SDK submodule (stable)
├── patches/             # pre/ and post/ patches applied before/after `flutter pub get`
├── assets/ assets_raw/ shaders/   # Runtime assets; raw badge/icon sources; pencil.frag
├── android/ ios/ linux/ macos/ windows/   # Platform runners
├── flatpak/ snap/ installers/     # Linux and Windows packaging
├── metadata/            # App Store & Google Play listings, screenshots, localized ASO metadata
├── docs/                # Product landing page (index.html) and Privacy Policy
├── scripts/             # Version bump, icons, screenshots, PDFium and font helpers
├── .github/ codemagic.yaml        # CI / release pipelines
└── AGENTS.md / CLAUDE.md / GEMINI.md   # AI agent guidance (.agents/ holds skills)
```

---

## Upstream Attribution & License

Opennote is forked from and respectfully builds upon [Saber](https://github.com/saber-notes/saber) by Adil Hanney and the Saber open-source contributors.

Licensed under the **GNU General Public License v3.0 (GPLv3)** — see [LICENSE.md](./LICENSE.md).
