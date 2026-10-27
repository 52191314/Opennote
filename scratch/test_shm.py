import ctypes
from ctypes import wintypes

kernel32 = ctypes.windll.kernel32
FILE_MAP_READ = 4

names_to_try = [
    "MEmu_1_ImgSharedMemory",
    "MEmu_MEmu_1_ImgSharedMemory",
    "MEmu1_ImgSharedMemory",
    "MEmu_ImgSharedMemory",
    "Local\\MEmu_1_ImgSharedMemory",
    "Global\\MEmu_1_ImgSharedMemory",
    "Local\\MEmu_ImgSharedMemory",
    "Global\\MEmu_ImgSharedMemory",
    "_ImgSharedMemory",
    "MEmu_1",
]

for name in names_to_try:
    h = kernel32.OpenFileMappingA(FILE_MAP_READ, False, name.encode('ascii'))
    if h:
        print(f"FOUND mapping: {name}! Handle={h}")
        kernel32.CloseHandle(h)
    else:
        err = kernel32.GetLastError()
        # print(f"Not found: {name} (err {err})")
