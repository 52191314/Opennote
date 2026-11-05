from PIL import Image
import os

src_path = r"E:\02_Projects\Opennote\assets\icon\icon.png"
img = Image.open(src_path)

print(f"Loaded master icon: size={img.size}, mode={img.mode}")

# Resize with high-quality LANCZOS resampling to exactly 512x512
img_512 = img.resize((512, 512), Image.Resampling.LANCZOS)

targets = [
    r"E:\02_Projects\Opennote\metadata\en-US\images\icon.png",
    r"E:\02_Projects\Opennote\android\app\src\main\ic_launcher-playstore.png",
    r"E:\02_Projects\Opennote\assets\icon\resized\icon-512x512.png",
]

for target in targets:
    os.makedirs(os.path.dirname(target), exist_ok=True)
    if os.path.exists(target):
        os.remove(target) # remove any symlink text file first
    img_512.save(target, format="PNG", optimize=True)
    file_size = os.path.getsize(target)
    verify_img = Image.open(target)
    print(f"Saved: {target}")
    print(f"  Dimensions: {verify_img.size}, Mode: {verify_img.mode}, Bytes: {file_size:,} ({file_size/1024:.1f} KB)")
