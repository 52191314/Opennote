import subprocess
import sys
import os

MEMUC = r"E:\01_Apps\Program Files\Microvirt\MEmu\memuc.exe"

flags = subprocess.CREATE_NEW_PROCESS_GROUP
if os.name == "nt":
    flags |= getattr(subprocess, "DETACHED_PROCESS", 0x00000008)

proc = subprocess.Popen(
    [MEMUC, "start", "-i", "1"],
    stdin=subprocess.DEVNULL,
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL,
    creationflags=flags,
    close_fds=True
)

print(f"Launched MEmu 1 with PID {proc.pid}")
