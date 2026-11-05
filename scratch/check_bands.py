from PIL import Image
import numpy as np

for path in [
    r'E:\Downloads\Note_app_feature_graphic_banner_2K_20261026093852.jpg',
    r'E:\Downloads\Digital_note_app_feature_banner_2K_20261026093836.jpg'
]:
    img = Image.open(path)
    w, h = img.size
    # top 96 rows and bottom 96 rows
    top_band = np.array(img.crop((0, 0, w, 96)))
    bot_band = np.array(img.crop((0, h - 96, w, h)))
    print(f"{path}:")
    print(f"  Top band variance: {top_band.std():.2f}")
    print(f"  Bottom band variance: {bot_band.std():.2f}")
