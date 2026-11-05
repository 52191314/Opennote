import xml.etree.ElementTree as ET
import subprocess

ADB = r"E:\03_Devops\AndroidSdk\platform-tools\adb.exe"
DEVICE = "127.0.0.1:21513"

subprocess.run([ADB, "-s", DEVICE, "pull", "/sdcard/window_dump.xml", "scratch/dump.xml"], check=True)
tree = ET.parse("scratch/dump.xml")
root = tree.getroot()

for node in root.iter("node"):
    text = node.attrib.get("text")
    desc = node.attrib.get("content-desc")
    bounds = node.attrib.get("bounds")
    if text or desc:
        print(f"Text='{text}', Desc='{desc}', Bounds={bounds}")
