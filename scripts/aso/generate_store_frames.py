#!/usr/bin/env python3
"""Opennote App Store & Google Play Marketing Frame Generator.

Composites high-resolution, minimalist studio marketing frames for:
  - iOS App Store iPhone 6.7"  (1290 x 2796)
  - iOS App Store iPad Pro 12.9" (2048 x 2732)
  - Google Play Android Phone   (1080 x 1920)
  - Google Play Feature Graphic (1024 x 500)

Also emits an interactive HTML contact sheet (`docs/aso/store_preview_gallery.html`)
for rapid visual review.

🤖 Generated wholely or partially with Google Antigravity
"""

from __future__ import annotations

import argparse
import html
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFilter, ImageFont


REPO_ROOT = Path(__file__).resolve().parents[2]


@dataclass(frozen=True)
class SlideSpec:
    index: int
    slug: str
    kicker: str
    headline: str
    subhead: str
    theme: str  # "light", "slate", "dark", "navy"
    accent: str
    sources: dict[str, tuple[str, ...]]
    footer_pillars: tuple[str, ...] = ()


@dataclass(frozen=True)
class PlatformSpec:
    key: str
    label: str
    width: int
    height: int
    device_kind: str  # "iphone", "ipad", "android"
    folder: str


THEMES: dict[str, dict[str, str]] = {
    "light": {
        "bg": "#FFFFFF",
        "grid": "#E2E8F0",
        "headline": "#0F172A",
        "subhead": "#475569",
        "bezel": "#0F172A",
        "bezel_edge": "#CBD5E1",
        "pillar_bg": "#F8FAFC",
        "pillar_border": "#E2E8F0",
        "pillar_text": "#0F172A",
    },
    "slate": {
        "bg": "#F8FAFC",
        "grid": "#E2E8F0",
        "headline": "#0F172A",
        "subhead": "#475569",
        "bezel": "#0F172A",
        "bezel_edge": "#CBD5E1",
        "pillar_bg": "#FFFFFF",
        "pillar_border": "#E2E8F0",
        "pillar_text": "#0F172A",
    },
    "dark": {
        "bg": "#0B1120",
        "grid": "#1E293B",
        "headline": "#F8FAFC",
        "subhead": "#94A3B8",
        "bezel": "#1E293B",
        "bezel_edge": "#334155",
        "pillar_bg": "#111827",
        "pillar_border": "#1E293B",
        "pillar_text": "#F8FAFC",
    },
    "navy": {
        "bg": "#0F172A",
        "grid": "#1E293B",
        "headline": "#FFFFFF",
        "subhead": "#CBD5E1",
        "bezel": "#1E293B",
        "bezel_edge": "#334155",
        "pillar_bg": "#1E293B",
        "pillar_border": "#334155",
        "pillar_text": "#F8FAFC",
    },
}


SLIDES: tuple[SlideSpec, ...] = (
    SlideSpec(
        index=1,
        slug="01_hero_precision_notes",
        kicker="OPENNOTE · ENGINEERING NOTEBOOK",
        headline="Precision Notes & Diagrams",
        subhead="Natural vector handwriting and technical sketching built for tablets and stylus.",
        theme="light",
        accent="#2563EB",
        sources={
            "ios_iphone_67": (
                "metadata/en-US/images/iphoneScreenshots/1_home.png",
                "metadata/en-US/images/phoneScreenshots/1_home.png",
            ),
            "ios_ipad_129": (
                "metadata/en-US/images/ipadScreenshots/1_home.png",
                "metadata/en-US/images/tenInchScreenshots/1_home.png",
            ),
            "android_phone": (
                "metadata/en-US/images/phoneScreenshots/1_home.png",
                "test/goldens/home_theme_android_light.png",
            ),
        },
    ),
    SlideSpec(
        index=2,
        slug="02_stylus_drafting",
        kicker="DRAFTING & VECTOR INK",
        headline="120Hz Stylus & Drafting",
        subhead="Isometric grids, automatic shape snapping, zoom window, and zero-lag vector strokes.",
        theme="slate",
        accent="#2563EB",
        sources={
            "ios_iphone_67": (
                "metadata/en-US/images/phoneScreenshots/3_diagrams.png",
                "metadata/en-US/images/iphoneScreenshots/2_editor.png",
            ),
            "ios_ipad_129": (
                "metadata/en-US/images/ipadScreenshots/2_editor.png",
                "metadata/en-US/images/phoneScreenshots/3_diagrams.png",
            ),
            "android_phone": (
                "metadata/en-US/images/phoneScreenshots/3_diagrams.png",
                "metadata/en-US/images/phoneScreenshots/2_editor.png",
            ),
        },
    ),
    SlideSpec(
        index=3,
        slug="03_infinite_canvas_pages",
        kicker="DUAL CANVAS ENGINE",
        headline="Infinite Canvas & Pages",
        subhead="Brainstorm without borders on an infinite whiteboard or structure clean paginated notebooks.",
        theme="light",
        accent="#0F766E",
        sources={
            "ios_iphone_67": (
                "metadata/en-US/images/phoneScreenshots/4_math.png",
                "metadata/en-US/images/iphoneScreenshots/2_editor.png",
            ),
            "ios_ipad_129": (
                "metadata/en-US/images/ipadScreenshots/2_editor.png",
                "metadata/en-US/images/phoneScreenshots/4_math.png",
            ),
            "android_phone": (
                "metadata/en-US/images/phoneScreenshots/4_math.png",
                "metadata/en-US/images/phoneScreenshots/2_editor.png",
            ),
        },
    ),
    SlideSpec(
        index=4,
        slug="04_pdf_dark_mode",
        kicker="PDF & NIGHT STUDY",
        headline="Annotate PDFs in Dark",
        subhead="Import textbooks and slides, highlight cleanly, and invert pages for eye-friendly study.",
        theme="dark",
        accent="#38BDF8",
        sources={
            "ios_iphone_67": (
                "metadata/en-US/images/phoneScreenshots/6_dark_mode.png",
                "test/goldens/home_theme_iOS_dark.png",
            ),
            "ios_ipad_129": (
                "metadata/en-US/images/phoneScreenshots/6_dark_mode.png",
                "metadata/en-US/images/ipadScreenshots/2_editor.png",
            ),
            "android_phone": (
                "metadata/en-US/images/phoneScreenshots/6_dark_mode.png",
                "test/goldens/home_theme_android_dark.png",
            ),
        },
    ),
    SlideSpec(
        index=5,
        slug="05_study_tape_recall",
        kicker="ACTIVE RECALL",
        headline="Study Tape Active Recall",
        subhead="Mask formulas, terms, and diagrams with interactive tape—tap to reveal as you quiz yourself.",
        theme="slate",
        accent="#D97706",
        sources={
            "ios_iphone_67": (
                "metadata/en-US/images/phoneScreenshots/5_pdf.png",
                "metadata/en-US/images/iphoneScreenshots/2_editor.png",
            ),
            "ios_ipad_129": (
                "metadata/en-US/images/ipadScreenshots/2_editor.png",
                "metadata/en-US/images/phoneScreenshots/5_pdf.png",
            ),
            "android_phone": (
                "metadata/en-US/images/phoneScreenshots/5_pdf.png",
                "metadata/en-US/images/phoneScreenshots/2_editor.png",
            ),
        },
    ),
    SlideSpec(
        index=6,
        slug="06_templates_organization",
        kicker="TEMPLATES & LIBRARY",
        headline="Smart Templates & Folders",
        subhead="Engineering millimeter grids, isometric dots, Cornell notes, and instant folder search.",
        theme="light",
        accent="#2563EB",
        sources={
            "ios_iphone_67": (
                "test/goldens/home_theme_iOS_light.png",
                "metadata/en-US/images/iphoneScreenshots/1_home.png",
            ),
            "ios_ipad_129": (
                "metadata/en-US/images/ipadScreenshots/1_home.png",
                "test/goldens/home_theme_iOS_light.png",
            ),
            "android_phone": (
                "test/goldens/home_theme_android_light.png",
                "metadata/en-US/images/phoneScreenshots/1_home.png",
            ),
        },
    ),
    SlideSpec(
        index=7,
        slug="07_local_first_privacy",
        kicker="ZERO-KNOWLEDGE PRIVACY",
        headline="Local-First Encrypted Sync",
        subhead="Works 100% offline with zero ads, zero trackers, and optional end-to-end encrypted sync.",
        theme="slate",
        accent="#16A34A",
        sources={
            "ios_iphone_67": (
                "metadata/en-US/images/iphoneScreenshots/4_settings.png",
                "metadata/en-US/images/phoneScreenshots/7_settings.png",
            ),
            "ios_ipad_129": (
                "metadata/en-US/images/ipadScreenshots/4_settings.png",
                "metadata/en-US/images/phoneScreenshots/7_settings.png",
            ),
            "android_phone": (
                "metadata/en-US/images/phoneScreenshots/7_settings.png",
                "metadata/en-US/images/iphoneScreenshots/4_settings.png",
            ),
        },
    ),
    SlideSpec(
        index=8,
        slug="08_opennote_pro",
        kicker="OPENNOTE PRO",
        headline="Unlock Opennote Pro",
        subhead="Unlimited notebooks, Study Tape, engineering templates & vector PDF export. Try 7 days free.",
        theme="navy",
        accent="#38BDF8",
        sources={
            "ios_iphone_67": (
                "metadata/en-US/images/iphoneScreenshots/2_editor.png",
                "metadata/en-US/images/phoneScreenshots/2_editor.png",
            ),
            "ios_ipad_129": (
                "metadata/en-US/images/ipadScreenshots/2_editor.png",
                "metadata/en-US/images/phoneScreenshots/2_editor.png",
            ),
            "android_phone": (
                "metadata/en-US/images/phoneScreenshots/2_editor.png",
                "metadata/en-US/images/iphoneScreenshots/2_editor.png",
            ),
        },
        footer_pillars=("7-Day Free Trial", "Cancel Anytime", "Local-First Privacy"),
    ),
)


PLATFORMS: dict[str, PlatformSpec] = {
    "ios_iphone_67": PlatformSpec(
        key="ios_iphone_67",
        label='iOS App Store — iPhone 6.7" (1290×2796)',
        width=1290,
        height=2796,
        device_kind="iphone",
        folder="ios_iphone_67",
    ),
    "ios_ipad_129": PlatformSpec(
        key="ios_ipad_129",
        label='iOS App Store — iPad Pro 12.9" (2048×2732)',
        width=2048,
        height=2732,
        device_kind="ipad",
        folder="ios_ipad_129",
    ),
    "android_phone": PlatformSpec(
        key="android_phone",
        label="Google Play — Android Phone (1080×1920)",
        width=1080,
        height=1920,
        device_kind="android",
        folder="android_phone",
    ),
}


def hex_to_rgb(value: str) -> tuple[int, int, int]:
    cleaned = value.lstrip("#")
    return (int(cleaned[0:2], 16), int(cleaned[2:4], 16), int(cleaned[4:6], 16))


def load_font(role: str, size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates: dict[str, list[Path]] = {
        "bold": [
            REPO_ROOT / "assets/google_fonts/Atkinson_Hyperlegible_Next/AtkinsonHyperlegibleNext-SemiBold.ttf",
            Path(r"C:\Windows\Fonts\segoeuib.ttf"),
            Path("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"),
            Path("/System/Library/Fonts/Helvetica.ttc"),
        ],
        "regular": [
            REPO_ROOT / "assets/google_fonts/Atkinson_Hyperlegible_Next/AtkinsonHyperlegibleNext-Regular.ttf",
            Path(r"C:\Windows\Fonts\segoeui.ttf"),
            Path("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"),
            Path("/System/Library/Fonts/Helvetica.ttc"),
        ],
        "mono": [
            REPO_ROOT / "assets/google_fonts/Fira_Mono/FiraMono-Bold.ttf",
            REPO_ROOT / "assets/google_fonts/Atkinson_Hyperlegible_Next/AtkinsonHyperlegibleNext-Medium.ttf",
            Path(r"C:\Windows\Fonts\consolab.ttf"),
            Path("/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"),
        ],
    }
    for candidate in candidates[role]:
        if candidate.exists():
            try:
                return ImageFont.truetype(str(candidate), size=size)
            except OSError:
                continue
    return ImageFont.load_default()


def resolve_source_image(candidates: Iterable[str]) -> Path | None:
    for rel in candidates:
        path = REPO_ROOT / rel
        if path.exists():
            return path
    return None


def draw_engineering_dot_grid(
    canvas: Image.Image,
    dot_color: str,
    spacing: int,
) -> None:
    draw = ImageDraw.Draw(canvas)
    rgb = hex_to_rgb(dot_color)
    width, height = canvas.size
    radius = max(1, spacing // 36)
    for y in range(spacing, height, spacing):
        for x in range(spacing, width, spacing):
            draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=rgb)


def wrap_text(
    draw: ImageDraw.ImageDraw,
    text: str,
    font: ImageFont.ImageFont,
    max_width: int,
) -> list[str]:
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        trial = f"{current} {word}".strip()
        bbox = draw.textbbox((0, 0), trial, font=font)
        if bbox[2] - bbox[0] <= max_width or not current:
            current = trial
        else:
            lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255)
    return mask


def fit_cover(image: Image.Image, target_w: int, target_h: int) -> Image.Image:
    src_w, src_h = image.size
    scale = max(target_w / src_w, target_h / src_h)
    new_w = max(1, int(round(src_w * scale)))
    new_h = max(1, int(round(src_h * scale)))
    resized = image.resize((new_w, new_h), Image.Resampling.LANCZOS)
    left = (new_w - target_w) // 2
    top = 0  # Anchor top so app bars and toolbars stay crisp and visible
    return resized.crop((left, top, left + target_w, top + target_h))


def paste_app_icon(canvas: Image.Image, x: int, y: int, size: int) -> None:
    icon_path = REPO_ROOT / "assets/icon/icon.png"
    if not icon_path.exists():
        return
    with Image.open(icon_path) as icon_raw:
        icon = icon_raw.convert("RGBA").resize((size, size), Image.Resampling.LANCZOS)
    radius = int(size * 0.22)
    mask = rounded_mask((size, size), radius)
    canvas.paste(icon, (x, y), mask)


def composite_device_frame(
    canvas: Image.Image,
    screenshot_path: Path | None,
    box: tuple[int, int, int, int],
    device_kind: str,
    palette: dict[str, str],
) -> None:
    x0, y0, x1, y1 = box
    frame_w = x1 - x0
    frame_h = y1 - y0
    bezel_thickness = max(14, int(min(frame_w, frame_h) * (0.028 if device_kind != "ipad" else 0.022)))
    outer_radius = int(min(frame_w, frame_h) * (0.11 if device_kind != "ipad" else 0.045))
    inner_radius = max(12, outer_radius - bezel_thickness)

    # Soft grounded shadow
    shadow_pad = max(36, int(frame_w * 0.06))
    shadow = Image.new("RGBA", (frame_w + shadow_pad * 2, frame_h + shadow_pad * 2), (0, 0, 0, 0))
    s_draw = ImageDraw.Draw(shadow)
    s_draw.rounded_rectangle(
        (shadow_pad, shadow_pad + 18, shadow_pad + frame_w, shadow_pad + frame_h + 18),
        radius=outer_radius,
        fill=(15, 23, 42, 62),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=max(16, shadow_pad // 2)))
    canvas.paste(shadow, (x0 - shadow_pad, y0 - shadow_pad), shadow)

    # Device outer bezel + subtle 1px edge highlight
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle(
        (x0, y0, x1, y1),
        radius=outer_radius,
        fill=hex_to_rgb(palette["bezel"]),
        outline=hex_to_rgb(palette["bezel_edge"]),
        width=max(2, bezel_thickness // 8),
    )

    screen_x0 = x0 + bezel_thickness
    screen_y0 = y0 + bezel_thickness
    screen_w = frame_w - bezel_thickness * 2
    screen_h = frame_h - bezel_thickness * 2

    if screenshot_path and screenshot_path.exists():
        with Image.open(screenshot_path) as raw:
            fitted = fit_cover(raw.convert("RGB"), screen_w, screen_h)
    else:
        fitted = Image.new("RGB", (screen_w, screen_h), hex_to_rgb(palette["pillar_bg"]))

    screen_mask = rounded_mask((screen_w, screen_h), inner_radius)
    canvas.paste(fitted, (screen_x0, screen_y0), screen_mask)

    # Minimal Dynamic Island / camera pill for iPhone/Android (clean, non-intrusive)
    if device_kind == "iphone":
        pill_w = int(screen_w * 0.24)
        pill_h = max(18, int(bezel_thickness * 1.05))
        pill_x0 = screen_x0 + (screen_w - pill_w) // 2
        pill_y0 = screen_y0 + max(12, bezel_thickness // 2)
        draw.rounded_rectangle(
            (pill_x0, pill_y0, pill_x0 + pill_w, pill_y0 + pill_h),
            radius=pill_h // 2,
            fill=(15, 23, 42),
        )
    elif device_kind == "android":
        cam_r = max(8, bezel_thickness // 2)
        cx = screen_x0 + screen_w // 2
        cy = screen_y0 + max(16, bezel_thickness)
        draw.ellipse((cx - cam_r, cy - cam_r, cx + cam_r, cy + cam_r), fill=(15, 23, 42))


def render_portrait_slide(
    slide: SlideSpec,
    platform: PlatformSpec,
    output_path: Path,
) -> Path:
    palette = THEMES[slide.theme]
    w, h = platform.width, platform.height
    canvas = Image.new("RGB", (w, h), hex_to_rgb(palette["bg"]))

    grid_spacing = max(36, w // 26)
    draw_engineering_dot_grid(canvas, palette["grid"], spacing=grid_spacing)
    draw = ImageDraw.Draw(canvas)

    margin_x = int(w * 0.085)
    max_text_w = w - margin_x * 2

    kicker_size = int(w * (0.025 if platform.device_kind != "ipad" else 0.019))
    headline_size = int(w * (0.068 if platform.device_kind != "ipad" else 0.052))
    subhead_size = int(w * (0.032 if platform.device_kind != "ipad" else 0.025))

    kicker_font = load_font("mono", kicker_size)
    headline_font = load_font("bold", headline_size)
    subhead_font = load_font("regular", subhead_size)

    cursor_y = int(h * 0.048)

    # Slide 1 includes compact Opennote icon mark above the kicker
    if slide.index == 1:
        icon_size = int(w * (0.088 if platform.device_kind != "ipad" else 0.066))
        paste_app_icon(canvas, (w - icon_size) // 2, cursor_y, icon_size)
        cursor_y += icon_size + int(h * 0.022)

    # Centered Kicker (clean uppercase typography, no noisy pill boxes)
    kicker_bbox = draw.textbbox((0, 0), slide.kicker, font=kicker_font)
    kicker_w = kicker_bbox[2] - kicker_bbox[0]
    kicker_h = kicker_bbox[3] - kicker_bbox[1]
    draw.text(
        ((w - kicker_w) // 2, cursor_y),
        slide.kicker,
        font=kicker_font,
        fill=hex_to_rgb(slide.accent),
    )
    cursor_y += kicker_h + int(h * 0.018)

    # Centered Headline
    headline_lines = wrap_text(draw, slide.headline, headline_font, max_text_w)
    for line in headline_lines:
        bbox = draw.textbbox((0, 0), line, font=headline_font)
        line_w = bbox[2] - bbox[0]
        line_h = bbox[3] - bbox[1]
        draw.text(
            ((w - line_w) // 2, cursor_y),
            line,
            font=headline_font,
            fill=hex_to_rgb(palette["headline"]),
        )
        cursor_y += int(line_h * 1.22)

    cursor_y += int(h * 0.012)

    # Centered Subhead
    subhead_lines = wrap_text(draw, slide.subhead, subhead_font, int(max_text_w * 0.94))
    for line in subhead_lines:
        bbox = draw.textbbox((0, 0), line, font=subhead_font)
        line_w = bbox[2] - bbox[0]
        line_h = bbox[3] - bbox[1]
        draw.text(
            ((w - line_w) // 2, cursor_y),
            line,
            font=subhead_font,
            fill=hex_to_rgb(palette["subhead"]),
        )
        cursor_y += int(line_h * 1.35)

    # Reserve bottom strip for Slide 8 Pro value pillars
    bottom_reserve = int(h * 0.085) if slide.footer_pillars else int(h * 0.042)
    device_top = max(cursor_y + int(h * 0.028), int(h * 0.25))
    device_bottom = h - bottom_reserve

    if platform.device_kind == "ipad":
        frame_w = int(w * 0.78)
    else:
        frame_w = int(w * 0.76)

    # Maintain realistic device aspect ratio inside available vertical slot
    avail_h = max(300, device_bottom - device_top)
    target_ratio = 0.74 if platform.device_kind == "ipad" else 0.475
    computed_w = int(avail_h * target_ratio)
    if computed_w < frame_w:
        frame_w = computed_w
    frame_h = avail_h
    frame_x0 = (w - frame_w) // 2

    src_path = resolve_source_image(slide.sources.get(platform.key, ()))
    composite_device_frame(
        canvas=canvas,
        screenshot_path=src_path,
        box=(frame_x0, device_top, frame_x0 + frame_w, device_top + frame_h),
        device_kind=platform.device_kind,
        palette=palette,
    )

    if slide.footer_pillars:
        pillar_font = load_font("bold", int(w * (0.025 if platform.device_kind != "ipad" else 0.019)))
        gap = int(w * 0.02)
        count = len(slide.footer_pillars)
        total_w = w - margin_x * 2
        card_w = (total_w - gap * (count - 1)) // count
        card_h = int(h * 0.046)
        card_y0 = h - bottom_reserve + (bottom_reserve - card_h) // 2
        for idx, label in enumerate(slide.footer_pillars):
            cx0 = margin_x + idx * (card_w + gap)
            draw.rounded_rectangle(
                (cx0, card_y0, cx0 + card_w, card_y0 + card_h),
                radius=12,
                fill=hex_to_rgb(palette["pillar_bg"]),
                outline=hex_to_rgb(palette["pillar_border"]),
                width=2,
            )
            bbox = draw.textbbox((0, 0), label, font=pillar_font)
            tw = bbox[2] - bbox[0]
            th = bbox[3] - bbox[1]
            draw.text(
                (cx0 + (card_w - tw) // 2, card_y0 + (card_h - th) // 2 - 2),
                label,
                font=pillar_font,
                fill=hex_to_rgb(palette["pillar_text"]),
            )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output_path, format="PNG", optimize=True)
    return output_path


def render_feature_graphic(output_path: Path) -> Path:
    w, h = 1024, 500
    palette = THEMES["light"]
    canvas = Image.new("RGB", (w, h), hex_to_rgb(palette["bg"]))
    draw_engineering_dot_grid(canvas, palette["grid"], spacing=28)
    draw = ImageDraw.Draw(canvas)

    # Subtle right-side slate surface panel
    draw.rectangle((560, 0, w, h), fill=hex_to_rgb("#F8FAFC"))
    draw.line((560, 0, 560, h), fill=hex_to_rgb("#E2E8F0"), width=2)

    # Left column brand lockup (keeps >=48px safe margin on all sides)
    left_x = 56
    paste_app_icon(canvas, left_x, 62, 74)

    brand_font = load_font("bold", 48)
    kicker_font = load_font("mono", 16)
    headline_font = load_font("bold", 34)
    sub_font = load_font("regular", 20)

    draw.text((left_x + 92, 68), "Opennote", font=brand_font, fill=hex_to_rgb("#0F172A"))
    draw.text((left_x + 94, 122), "ENGINEERING NOTEBOOK", font=kicker_font, fill=hex_to_rgb("#2563EB"))

    draw.text((left_x, 196), "Precision Notes", font=headline_font, fill=hex_to_rgb("#0F172A"))
    draw.text((left_x, 238), "& Vector Diagrams", font=headline_font, fill=hex_to_rgb("#0F172A"))

    sub_lines = wrap_text(
        draw,
        "120Hz stylus ink, isometric drafting, PDF dark mode & Study Tape.",
        sub_font,
        460,
    )
    sy = 304
    for line in sub_lines:
        draw.text((left_x, sy), line, font=sub_font, fill=hex_to_rgb("#475569"))
        sy += 28

    # Clean trust footer line
    draw.text(
        (left_x, 424),
        "LOCAL-FIRST  ·  ZERO ADS  ·  ENCRYPTED SYNC",
        font=load_font("mono", 14),
        fill=hex_to_rgb("#16A34A"),
    )

    # Right column crisp device preview cropped cleanly at bottom edge
    src_path = resolve_source_image(
        (
            "metadata/en-US/images/phoneScreenshots/3_diagrams.png",
            "metadata/en-US/images/phoneScreenshots/1_home.png",
        )
    )
    composite_device_frame(
        canvas=canvas,
        screenshot_path=src_path,
        box=(618, 40, 966, 620),
        device_kind="android",
        palette=palette,
    )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output_path, format="PNG", optimize=True)
    return output_path


def write_preview_gallery(
    preview_html: Path,
    output_dir: Path,
    generated: dict[str, list[tuple[SlideSpec | None, Path]]],
) -> None:
    preview_html.parent.mkdir(parents=True, exist_ok=True)

    def rel_src(img_path: Path) -> str:
        return Path(os.path.relpath(img_path, preview_html.parent)).as_posix()

    sections: list[str] = []

    if "feature_graphic" in generated:
        _, fg_path = generated["feature_graphic"][0]
        sections.append(
            f"""
            <section class="group">
              <h2>Google Play — Feature Graphic (1024×500)</h2>
              <div class="feature-card">
                <img src="{html.escape(rel_src(fg_path))}" alt="Google Play Feature Graphic" />
                <div class="meta"><code>{html.escape(fg_path.name)}</code> · 1024×500 PNG</div>
              </div>
            </section>
            """
        )

    for key, platform in PLATFORMS.items():
        items = generated.get(key, [])
        if not items:
            continue
        cards: list[str] = []
        for slide, img_path in items:
            assert slide is not None
            cards.append(
                f"""
                <article class="card">
                  <div class="frame-wrap">
                    <img src="{html.escape(rel_src(img_path))}" alt="{html.escape(slide.headline)}" loading="lazy" />
                  </div>
                  <div class="card-body">
                    <div class="kicker">Slide {slide.index} · {html.escape(slide.kicker)}</div>
                    <h3>{html.escape(slide.headline)}</h3>
                    <p>{html.escape(slide.subhead)}</p>
                    <div class="meta"><code>{html.escape(img_path.name)}</code> · {platform.width}×{platform.height}</div>
                  </div>
                </article>
                """
            )
        sections.append(
            f"""
            <section class="group">
              <h2>{html.escape(platform.label)}</h2>
              <div class="grid">{''.join(cards)}</div>
            </section>
            """
        )

    doc = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Opennote — Store Screenshot Preview Gallery</title>
  <style>
    :root {{
      --bg: #F8FAFC;
      --surface: #FFFFFF;
      --border: #E2E8F0;
      --text: #0F172A;
      --muted: #475569;
      --accent: #2563EB;
    }}
    * {{ box-sizing: border-box; }}
    body {{
      margin: 0;
      padding: 40px 32px 72px;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.5;
    }}
    header {{
      max-width: 1440px;
      margin: 0 auto 40px;
      padding-bottom: 24px;
      border-bottom: 1px solid var(--border);
    }}
    header h1 {{ margin: 0 0 8px; font-size: 28px; }}
    header p {{ margin: 0; color: var(--muted); }}
    .group {{ max-width: 1440px; margin: 0 auto 48px; }}
    .group h2 {{ font-size: 20px; margin: 0 0 18px; }}
    .grid {{
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
      gap: 20px;
    }}
    .card, .feature-card {{
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 10px;
      overflow: hidden;
    }}
    .feature-card {{ max-width: 760px; padding: 16px; }}
    .feature-card img {{ width: 100%; height: auto; border-radius: 6px; border: 1px solid var(--border); }}
    .frame-wrap {{
      background: #F1F5F9;
      padding: 12px;
      display: flex;
      justify-content: center;
    }}
    .frame-wrap img {{
      width: 100%;
      height: auto;
      border-radius: 6px;
      border: 1px solid var(--border);
    }}
    .card-body {{ padding: 14px 16px 16px; }}
    .kicker {{
      font-size: 11px;
      font-weight: 700;
      letter-spacing: 0.06em;
      color: var(--accent);
      text-transform: uppercase;
      margin-bottom: 4px;
    }}
    .card-body h3 {{ margin: 0 0 6px; font-size: 16px; }}
    .card-body p {{ margin: 0 0 10px; font-size: 13px; color: var(--muted); }}
    .meta {{ font-size: 12px; color: var(--muted); }}
    code {{ background: #F1F5F9; padding: 2px 6px; border-radius: 4px; }}
  </style>
</head>
<body>
  <header>
    <h1>Opennote — App Store &amp; Google Play Visual Preview Gallery</h1>
    <p>Generated by <code>scripts/aso/generate_store_frames.py</code>. Re-run with <code>--output-dir build/aso_frames --verify</code> to refresh PNG frames.</p>
  </header>
  {''.join(sections)}
</body>
</html>
"""
    preview_html.write_text(doc, encoding="utf-8")


def verify_outputs(expected: list[tuple[Path, int, int]]) -> None:
    failures: list[str] = []
    for path, exp_w, exp_h in expected:
        if not path.exists():
            failures.append(f"MISSING: {path}")
            continue
        with Image.open(path) as img:
            w, h = img.size
            if (w, h) != (exp_w, exp_h):
                failures.append(f"DIMENSION MISMATCH: {path} got {w}x{h}, expected {exp_w}x{exp_h}")
            if img.getbbox() is None:
                failures.append(f"BLANK IMAGE: {path}")
    if failures:
        raise SystemExit("Verification failed:\n" + "\n".join(failures))
    print(f"Verified {len(expected)} generated PNGs: all dimensions and pixel bounds passed.")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate Opennote App Store & Google Play marketing frames.")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=REPO_ROOT / "build/aso_frames",
        help="Directory where generated PNG frames are written.",
    )
    parser.add_argument(
        "--preview-html",
        type=Path,
        default=REPO_ROOT / "docs/aso/store_preview_gallery.html",
        help="Path to write the HTML preview gallery.",
    )
    parser.add_argument(
        "--platforms",
        default="all",
        help="Comma-separated subset of: ios_iphone_67,ios_ipad_129,android_phone,feature_graphic,all",
    )
    parser.add_argument(
        "--verify",
        action="store_true",
        help="Verify every generated PNG matches exact target dimensions via PIL.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    output_dir = args.output_dir if args.output_dir.is_absolute() else (REPO_ROOT / args.output_dir)
    preview_html = args.preview_html if args.preview_html.is_absolute() else (REPO_ROOT / args.preview_html)

    requested = {p.strip() for p in args.platforms.split(",") if p.strip()}
    run_all = "all" in requested

    generated: dict[str, list[tuple[SlideSpec | None, Path]]] = {}
    expected_checks: list[tuple[Path, int, int]] = []

    for key, platform in PLATFORMS.items():
        if not run_all and key not in requested:
            continue
        items: list[tuple[SlideSpec | None, Path]] = []
        for slide in SLIDES:
            out_file = output_dir / platform.folder / f"{slide.slug}.png"
            render_portrait_slide(slide, platform, out_file)
            items.append((slide, out_file))
            expected_checks.append((out_file, platform.width, platform.height))
        generated[key] = items

    if run_all or "feature_graphic" in requested:
        fg_file = output_dir / "google_play" / "feature_graphic_1024x500.png"
        render_feature_graphic(fg_file)
        generated["feature_graphic"] = [(None, fg_file)]
        expected_checks.append((fg_file, 1024, 500))

    write_preview_gallery(preview_html, output_dir, generated)
    print(f"Generated {len(expected_checks)} frames into {output_dir}")
    print(f"Wrote preview gallery to {preview_html}")

    if args.verify:
        verify_outputs(expected_checks)


if __name__ == "__main__":
    main()
