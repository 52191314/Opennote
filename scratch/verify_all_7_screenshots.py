import os
from PIL import Image

DIR = r"E:\02_Projects\Opennote\metadata\en-US\images\phoneScreenshots"
files = sorted([f for f in os.listdir(DIR) if f.endswith(".png")])

print(f"Total screenshots: {len(files)}")
for f in files:
    path = os.path.join(DIR, f)
    size_bytes = os.path.getsize(path)
    img = Image.open(path)
    # count unique colors on flattened data
    colors = len(set(img.get_flattened_data())) // 4 if hasattr(img, 'get_flattened_data') else len(set(img.getdata()))
    print(f"  {f:18}: Size={img.size}, Mode={img.mode}, Bytes={size_bytes:,}, UniqueColors={colors:,}")
