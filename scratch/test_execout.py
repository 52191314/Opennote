import subprocess
from PIL import Image
import io

ADB = r"E:\03_Devops\AndroidSdk\platform-tools\adb.exe"
DEVICE = "127.0.0.1:21513"

res = subprocess.run([ADB, "-s", DEVICE, "exec-out", "screencap", "-p"], capture_output=True)
print(f"Captured {len(res.stdout)} bytes")
try:
    img = Image.open(io.BytesIO(res.stdout))
    print(f"Parsed image: {img.size}, mode: {img.mode}, unique colors: {len(set(img.getdata()))}")
except Exception as e:
    print(f"Error: {e}")
