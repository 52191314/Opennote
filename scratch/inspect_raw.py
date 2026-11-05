import struct
from PIL import Image

with open(r"E:\02_Projects\Opennote\scratch\raw.bin", "rb") as f:
    header = f.read(16)
    w, h, fmt, cs = struct.unpack("<IIII", header)
    pixels = f.read()

print(f"Header: {w}x{h}, fmt={fmt}, cs={cs}, pixel bytes={len(pixels)}")
img = Image.frombytes("RGBA", (w, h), pixels)
colors = set(img.getdata())
print(f"Unique colors in raw: {len(colors)}")
for c in list(colors)[:10]:
    print(" ", c)
