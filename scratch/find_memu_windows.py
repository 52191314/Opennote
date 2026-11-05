import ctypes
from ctypes import wintypes

user32 = ctypes.windll.user32

pids = [2056, 30464, 29308, 6488]
hwnds = []

def enum_windows_callback(hwnd, extra):
    lpdw_process_id = wintypes.DWORD()
    user32.GetWindowThreadProcessId(hwnd, ctypes.byref(lpdw_process_id))
    if lpdw_process_id.value in pids:
        title = ctypes.create_unicode_buffer(512)
        user32.GetWindowTextW(hwnd, title, 512)
        cls = ctypes.create_unicode_buffer(512)
        user32.GetClassNameW(hwnd, cls, 512)
        rect = wintypes.RECT()
        user32.GetWindowRect(hwnd, ctypes.byref(rect))
        vis = user32.IsWindowVisible(hwnd)
        print(f"PID {lpdw_process_id.value}, HWND {hwnd}: Title='{title.value}', Class='{cls.value}', Rect=({rect.left},{rect.top},{rect.right},{rect.bottom}), Vis={vis}")
    return True

WNDENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)
user32.EnumWindows(WNDENUMPROC(enum_windows_callback), 0)
