import subprocess
from PIL import Image

ADB = r"E:\03_Devops\AndroidSdk\platform-tools\adb.exe"
DEVICE = "127.0.0.1:21513"
TEST_IMG = r"E:\02_Projects\Opennote\scratch\test_screen.png"

# Capture screen
subprocess.run([ADB, "-s", DEVICE, "shell", "screencap", "-p", "/sdcard/test.png"], check=True)
subprocess.run([ADB, "-s", DEVICE, "pull", "/sdcard/test.png", TEST_IMG], check=True)

img = Image.open(TEST_IMG)
colors = len(set(img.getdata()))
print(f"Size: {img.size}, Mode: {img.mode}, Unique colors: {colors}")
