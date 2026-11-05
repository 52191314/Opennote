with open(r"E:\01_Apps\Program Files\Microvirt\MEmu\MEmu.exe", "rb") as f:
    data = f.read()

pos = 0
while True:
    pos = data.find(b"screenrecord", pos)
    if pos == -1:
        break
    start = max(0, pos - 150)
    end = min(len(data), pos + 150)
    print("Found at", pos, ":", data[start:end])
    pos += 1
