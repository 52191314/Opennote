# Opennote ASO Visual Kit & Growth Playbook

This directory contains Opennote's App Store & Google Play conversion strategy, 8-slide screenshot storyboard, and HTML preview gallery backed by a reproducible Python (Pillow) frame compositor.

## Files in This Kit
- [`aso_master_strategy.md`](aso_master_strategy.md) — Keyword matrix, icon & screenshot CRO audit, 30s App Preview video script, 4 Custom Product Pages / Custom Store Listings, 90-day In-App Events calendar, 6-experiment A/B testing roadmap, and `ReviewPromptService` velocity loop.
- [`screenshot_storyboard.md`](screenshot_storyboard.md) — Exact 8-slide conversion storyboard (headlines `<= 5` words, subheads, studio color palettes, and platform dimensions).
- [`store_preview_gallery.html`](store_preview_gallery.html) — Visual contact sheet inspecting all generated App Store, iPad, Android, and Google Play Feature Graphic frames.
- [`../../scripts/aso/generate_store_frames.py`](../../scripts/aso/generate_store_frames.py) — Deterministic Pillow compositor that builds all store marketing frames from Opennote's existing UI screenshots/goldens and bundled fonts.

## 1-Line Run & Verify Command

Requires Python 3.10+ and `Pillow` (`pip install Pillow`). Run from the repository root:

```bash
python scripts/aso/generate_store_frames.py --output-dir build/aso_frames --preview-html docs/aso/store_preview_gallery.html --verify
```

### Generated Output Matrix
| Output Folder | Spec | Dimensions | Count |
| :--- | :--- | :--- | :--- |
| `build/aso_frames/ios_iphone_67/` | iOS App Store (iPhone 6.7") | `1290 × 2796` | 8 PNGs |
| `build/aso_frames/ios_ipad_129/` | iOS App Store (iPad Pro 12.9") | `2048 × 2732` | 8 PNGs |
| `build/aso_frames/android_phone/` | Google Play (Android Phone) | `1080 × 1920` | 8 PNGs |
| `build/aso_frames/google_play/` | Google Play Feature Graphic | `1024 × 500` | 1 PNG |

> **Note:** Generated PNGs are written to `build/aso_frames/` (or any `--output-dir` you choose) so the git repository stays lightweight and free of bloated binary duplicates.

## Updating Source UI Screenshots
When v2 Flutter golden screenshots are refreshed in `metadata/en-US/images/` or `test/goldens/`, re-run the 1-line command above to regenerate the entire 25-asset store suite in ~5 seconds.
