from PIL import Image
import numpy as np

f1 = r'E:\Downloads\Note_app_feature_graphic_banner_2K_20261026093852.jpg'
f2 = r'E:\Downloads\Digital_note_app_feature_banner_2K_20261026093836.jpg'

for f in [f1, f2]:
    img = Image.open(f)
    arr = np.array(img)
    mean_color = arr.mean(axis=(0,1))
    print(f"{f}:")
    print(f"  Size: {img.size}, Mode: {img.mode}, Mean RGB: {mean_color.astype(int)}")
