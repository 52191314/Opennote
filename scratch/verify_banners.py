import os
from PIL import Image

paths = [
    r'E:\02_Projects\Opennote\metadata\en-US\images\featureGraphic.png',
    r'E:\02_Projects\Opennote\metadata\en-US\images\featureGraphic_alt.png',
    r'E:\02_Projects\Opennote\assets\icon\android_feature_graphic.png',
    r'E:\02_Projects\Opennote\assets\banner\digital_note_app_banner_1024x500.png',
    r'E:\02_Projects\Opennote\assets\banner\digital_note_app_banner_cropped_1024x500.png',
    r'E:\02_Projects\Opennote\assets\banner\note_app_banner_1024x500.png',
    r'E:\02_Projects\Opennote\assets\banner\note_app_banner_cropped_1024x500.png',
]

for p in paths:
    img = Image.open(p)
    size_kb = os.path.getsize(p) / 1024
    print(f"{os.path.basename(p):38}: Size={img.size}, Mode={img.mode}, Size={size_kb:.1f} KB")
