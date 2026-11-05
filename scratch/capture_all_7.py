import subprocess
import time
import os

ADB = r"E:\03_Devops\AndroidSdk\platform-tools\adb.exe"
DEVICE = "127.0.0.1:21513"
OUTPUT_DIR = r"E:\02_Projects\Opennote\metadata\en-US\images\phoneScreenshots"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def adb_cmd(args):
    cmd = [ADB, "-s", DEVICE] + args
    return subprocess.run(cmd, capture_output=True, text=True).stdout.strip()

def tap(x, y, delay=1.2):
    adb_cmd(["shell", "input", "tap", str(x), str(y)])
    time.sleep(delay)

def swipe(x1, y1, x2, y2, duration=350, delay=1.0):
    adb_cmd(["shell", "input", "swipe", str(x1), str(y1), str(x2), str(y2), str(duration)])
    time.sleep(delay)

def keyevent(code, delay=1.0):
    adb_cmd(["shell", "input", "keyevent", str(code)])
    time.sleep(delay)

def draw_stroke(points, duration=300):
    # points is list of (x, y)
    if len(points) >= 2:
        for i in range(len(points) - 1):
            p1 = points[i]
            p2 = points[i+1]
            adb_cmd(["shell", "input", "swipe", str(p1[0]), str(p1[1]), str(p2[0]), str(p2[1]), str(duration)])

def capture(name):
    path = os.path.join(OUTPUT_DIR, name)
    # capture directly to device file and pull
    tmp_path = f"/sdcard/{name}"
    adb_cmd(["shell", "screencap", "-p", tmp_path])
    adb_cmd(["pull", tmp_path, path])
    if os.path.exists(path):
        size = os.path.getsize(path)
        print(f"Captured {name}: {size} bytes")
    else:
        print(f"Failed to capture {name}")

print("Screenshot automation script loaded.")
