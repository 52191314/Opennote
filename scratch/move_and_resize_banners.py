import os
import shutil
from PIL import Image

SRC1 = r'E:\Downloads\Note_app_feature_graphic_banner_2K_20261026093852.jpg'
SRC2 = r'E:\Downloads\Digital_note_app_feature_banner_2K_20261026093836.jpg'

DEST_DIR = r'E:\02_Projects\Opennote\assets\banner'
METADATA_DIR = r'E:\02_Projects\Opennote\metadata\en-US\images'
ICON_DIR = r'E:\02_Projects\Opennote\assets\icon'

os.makedirs(DEST_DIR, exist_ok=True)
os.makedirs(METADATA_DIR, exist_ok=True)
os.makedirs(ICON_DIR, exist_ok=True)

# 1. Copy 2K originals to assets/banner/
orig1 = os.path.join(DEST_DIR, 'Note_app_feature_graphic_banner_2K.jpg')
orig2 = os.path.join(DEST_DIR, 'Digital_note_app_feature_banner_2K.jpg')
shutil.copy2(SRC1, orig1)
shutil.copy2(SRC2, orig2)
print(f"Copied 2K originals to {DEST_DIR}")

# 2. Function to resize
def process_banner(src_path, base_name):
    img = Image.open(src_path)
    w, h = img.size
    
    # Direct resize (1024x500)
    direct_1024 = img.resize((1024, 500), Image.Resampling.LANCZOS)
    direct_png = os.path.join(DEST_DIR, f"{base_name}_1024x500.png")
    direct_jpg = os.path.join(DEST_DIR, f"{base_name}_1024x500.jpg")
    direct_1024.save(direct_png, format="PNG", optimize=True)
    direct_1024.save(direct_jpg, format="JPEG", quality=95)
    
    # Aspect-preserved center crop (crop to 1024:500 ratio then resize)
    target_ratio = 1024 / 500
    crop_h = int(w / target_ratio)
    top = (h - crop_h) // 2
    bottom = top + crop_h
    cropped_img = img.crop((0, top, w, bottom))
    crop_1024 = cropped_img.resize((1024, 500), Image.Resampling.LANCZOS)
    crop_png = os.path.join(DEST_DIR, f"{base_name}_cropped_1024x500.png")
    crop_1024.save(crop_png, format="PNG", optimize=True)
    
    return direct_1024, crop_1024

b1_direct, b1_crop = process_banner(orig1, "note_app_banner")
b2_direct, b2_crop = process_banner(orig2, "digital_note_app_banner")

# Save primary feature graphic for Play Store Fastlane metadata
# Digital note app banner (b2) is deep navy/indigo which matches Opennote branding
playstore_fg = os.path.join(METADATA_DIR, "featureGraphic.png")
b2_direct.save(playstore_fg, format="PNG", optimize=True)

# Also save note_app banner as alternate in metadata
playstore_fg_alt = os.path.join(METADATA_DIR, "featureGraphic_alt.png")
b1_direct.save(playstore_fg_alt, format="PNG", optimize=True)

# Also update assets/icon/android_feature_graphic.png
icon_fg = os.path.join(ICON_DIR, "android_feature_graphic.png")
b2_direct.save(icon_fg, format="PNG", optimize=True)

print("All banners processed and saved successfully.")
