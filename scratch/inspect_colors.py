from PIL import Image
from collections import Counter

img = Image.open(r"E:\02_Projects\Opennote\scratch\test_screen.png")
counts = Counter(img.getdata())
print(f"Colors: {counts.most_common(10)}")
