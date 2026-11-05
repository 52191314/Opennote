import re

with open(r"E:\01_Apps\Program Files\Microvirt\MEmu\screenrecord.exe", "rb") as f:
    data = f.read()

strings = re.findall(rb'[\x20-\x7e]{4,}', data)
for s in strings:
    text = s.decode('latin1')
    if any(k in text.lower() for k in ['shot', 'cap', 'png', 'bmp', 'jpg', 'vm', 'memu', 'port', 'pipe', 'help', 'usage', 'record', 'out']):
        print(text)
