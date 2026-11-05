import ctypes
from ctypes import wintypes

user32 = ctypes.windll.user32

parent = 527134
children = []

def enum_child_proc(hwnd, lparam):
    title = ctypes.create_unicode_buffer(512)
    user32.GetWindowTextW(hwnd, title, 512)
    cls = ctypes.create_unicode_buffer(512)
    user32.GetClassNameW(hwnd, cls, 512)
    rect = wintypes.RECT()
    user32.GetWindowRect(hwnd, ctypes.byref(rect))
    vis = user32.IsWindowVisible(hwnd)
    print(f"Child HWND {hwnd}: Title='{title.value}', Class='{cls.value}', Rect=({rect.left},{rect.top},{rect.right},{rect.bottom}), Vis={vis}")
    return True

WNDENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)
user32.EnumChildWindows(parent, WNDENUMPROC(enum_child_proc), 0)
print("Finished enum child windows.")
