import struct

with open("lib/x86_64/libirondash_engine_context_native.so", "rb") as f:
    data = f.read()

# find strings ending in .so
import re
sos = set(re.findall(rb'[a-zA-Z0-9_\-\.]+\.so[a-zA-Z0-9_\-\.]*', data))
for s in sorted(sos):
    print(s.decode('latin1'))
