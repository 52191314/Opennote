from PIL import Image

img = Image.open(r"E:\02_Projects\Opennote\scratch\test_screen.png")
w, h = img.size

# check alpha along rows
transparent_rows = []
for y in range(h):
    # sample x at 500
    p = img.getpixel((500, y))
    if p[3] == 0:
        transparent_rows.append(y)

print(f"Total rows: {h}, transparent rows: {len(transparent_rows)}, range: {min(transparent_rows) if transparent_rows else None} to {max(transparent_rows) if transparent_rows else None}")
