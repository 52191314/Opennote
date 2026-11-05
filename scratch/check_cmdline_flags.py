with open(r"E:\01_Apps\Program Files\Microvirt\MEmu\screenrecord.exe", "rb") as f:
    data = f.read()

import re
matches = re.findall(rb'-[a-zA-Z0-9_\-]+', data)
for m in sorted(set(matches)):
    print(m.decode('latin1'))
