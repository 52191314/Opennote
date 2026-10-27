from PIL import Image

for path in [
    r"E:\02_Projects\Opennote\android\app\src\main\ic_launcher-playstore.png",
    r"E:\02_Projects\Opennote\assets\icon\icon.png",
    r"E:\02_Projects\Opennote\assets\icon\icon_opaque.png",
]:
    try:
        img = Image.open(path)
        print(f"{path}: Size={img.size}, Mode={img.mode}")
    except Exception as e:
        print(f"{path}: {e}")
