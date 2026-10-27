import ctypes
import os
from ctypes import wintypes
from PIL import Image

dll_dir = r"E:\01_Apps\Program Files\Microvirt\MEmu"
os.add_dll_directory(dll_dir)
api = ctypes.CDLL(os.path.join(dll_dir, "MEmuRecordApi.dll"))

# Signature guess:
# MEmuRecordInit(const char* vmName)
vm_name = b"MEmu_1"
ret = api.MEmuRecordInit(vm_name)
print(f"MEmuRecordInit returned: {ret}")

if ret == 0 or ret == 1:
    w = wintypes.DWORD()
    h = wintypes.DWORD()
    api.MEmuRecordGetVideoSize(ctypes.byref(w), ctypes.byref(h))
    print(f"Video size: {w.value} x {h.value}")

    ptr = api.MEmuRecordGetVideoPointer(0)
    print(f"Video pointer: {hex(ptr) if ptr else None}")
    if ptr and w.value > 0 and h.value > 0:
        raw_bytes = ctypes.string_at(ptr, w.value * h.value * 4)
        img = Image.frombytes("RGBA", (w.value, h.value), raw_bytes)
        colors = len(set(img.getdata()))
        print(f"Unique colors from MEmuRecordApi: {colors}")
        img.save(r"E:\02_Projects\Opennote\scratch\memu_record_shot.png")
    api.MEmuRecordRelease(0)
