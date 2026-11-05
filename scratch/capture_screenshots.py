import subprocess
import time
import os
import sys

ADB = r"E:\03_Devops\AndroidSdk\platform-tools\adb.exe"
DEVICE = "127.0.0.1:21513"
OUTPUT_DIR = r"E:\02_Projects\Opennote\metadata\en-US\images\phoneScreenshots"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def run_adb(args):
    cmd = [ADB, "-s", DEVICE] + args
    res = subprocess.run(cmd, capture_output=True, text=True)
    return res.stdout.strip()

def tap(x, y):
    run_adb(["shell", "input", "tap", str(x), str(y)])
    time.sleep(1.5)

def swipe(x1, y1, x2, y2, duration=300):
    run_adb(["shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(duration)])
    time.sleep(1.5)

def take_screenshot(filename):
    filepath = os.path.join(OUTPUT_DIR, filename)
    with open(filepath, "wb") as f:
        subprocess.run([ADB, "-s", DEVICE, "exec-out", "screencap", "-p"], stdout=f)
    print(f"Captured: {filename} ({os.path.getsize(filepath)} bytes)")

print("=== Starting Play Store UI Screenshot Capture ===")
time.sleep(1)
