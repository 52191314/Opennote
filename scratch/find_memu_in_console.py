with open(r"E:\01_Apps\Program Files\Microvirt\MEmu\MEmuConsole.exe", "rb") as f:
    data = f.read()

import re
pos = 0
while True:
    pos = data.find(b"MEmu.exe", pos)
    if pos == -1:
        break
    start = max(0, pos - 100)
    end = min(len(data), pos + 100)
    print("Found at", pos, ":", data[start:end])
    pos += 1
