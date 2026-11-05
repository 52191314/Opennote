import os
from PIL import Image, ImageOps

source_path = r"C:\Users\X\.gemini\antigravity-cli\brain\d285d29b-6cd8-494c-a2e3-0f0854936eac\opennote_app_icon_v3_1792928566609.jpg"
workspace = r"E:\02_Projects\Opennote"

# Open master image (1024x1024)
master = Image.open(source_path).convert("RGB")

# 1. Save master icon to assets/icon/
os.makedirs(os.path.join(workspace, "assets", "icon"), exist_ok=True)
master.save(os.path.join(workspace, "assets", "icon", "icon.png"), "PNG")
master.save(os.path.join(workspace, "assets", "icon", "icon_opaque.png"), "PNG")

# 2. Playstore icon 512x512
playstore_icon = master.resize((512, 512), Image.Resampling.LANCZOS)
playstore_icon.save(os.path.join(workspace, "android", "app", "src", "main", "ic_launcher-playstore.png"), "PNG")
print("Saved ic_launcher-playstore.png")

# 3. Create transparent foreground / monochrome layer for adaptive icons
# Extract luminance as alpha channel: pure black -> alpha 0, pure white -> alpha 255
gray = ImageOps.grayscale(master)
# Scale glyph down slightly (~68%) to comfortably fit inside Android adaptive icon 72dp circle safe zone
target_scale = 0.68
glyph_size = int(1024 * target_scale)
gray_scaled = gray.resize((glyph_size, glyph_size), Image.Resampling.LANCZOS)

# Create 1024x1024 transparent RGBA canvas
foreground_1024 = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
# White image with luminance as alpha
white_glyph = Image.new("RGBA", (glyph_size, glyph_size), (255, 255, 255, 255))
white_glyph.putalpha(gray_scaled)

offset = ((1024 - glyph_size) // 2, (1024 - glyph_size) // 2)
foreground_1024.paste(white_glyph, offset, white_glyph)

foreground_1024.save(os.path.join(workspace, "assets", "icon", "icon_maskable.png"), "PNG")
foreground_1024.save(os.path.join(workspace, "assets", "icon", "icon_monochrome.png"), "PNG")

# Android mipmap densities:
# density: (normal_size, adaptive_size)
densities = {
    "mdpi": (48, 108),
    "hdpi": (72, 162),
    "xhdpi": (96, 216),
    "xxhdpi": (144, 324),
    "xxxhdpi": (192, 432),
}

for density, (normal_size, adaptive_size) in densities.items():
    density_dir = os.path.join(workspace, "android", "app", "src", "main", "res", f"mipmap-{density}")
    os.makedirs(density_dir, exist_ok=True)
    
    # 1. Normal legacy icon
    icon_resized = master.resize((normal_size, normal_size), Image.Resampling.LANCZOS)
    icon_resized.save(os.path.join(density_dir, "ic_launcher.png"), "PNG")
    
    # 2. Adaptive foreground
    fg_resized = foreground_1024.resize((adaptive_size, adaptive_size), Image.Resampling.LANCZOS)
    fg_resized.save(os.path.join(density_dir, "ic_launcher_foreground.png"), "PNG")
    
    # 3. Adaptive monochrome
    fg_resized.save(os.path.join(density_dir, "ic_launcher_monochrome.png"), "PNG")
    print(f"Generated icons for {density}: normal={normal_size}px, adaptive={adaptive_size}px")

print("All Android icons successfully installed!")
