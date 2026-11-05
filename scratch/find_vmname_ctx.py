with open(r"E:\01_Apps\Program Files\Microvirt\MEmu\screenrecord.exe", "rb") as f:
    data = f.read()

# search for "-n" or "-o" or "out"
idx = 0
while True:
    pos = data.find(b"vmName", idx)
    if pos == -1:
        break
    start = max(0, pos - 100)
    end = min(len(data), pos + 100)
    print("Found at", pos, ":", data[start:end])
    idx = pos + 1
