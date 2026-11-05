import ctypes
import os

dll_path = r"E:\01_Apps\Program Files\Microvirt\MEmu\MEmuRecordApi.dll"
# Read PE export table
with open(dll_path, "rb") as f:
    data = f.read()

import re
funcs = re.findall(rb'MEmuRecord[A-Za-z0-9_]+', data)
for fn in sorted(set(funcs)):
    print(fn.decode('latin1'))
