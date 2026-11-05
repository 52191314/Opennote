import ctypes
from ctypes import wintypes

user32 = ctypes.windll.user32

def enum_all(hwnd, lparam):
    if user32.IsWindowVisible(hwnd):
        title = ctypes.create_unicode_buffer(512)
        user32.GetWindowTextW(hwnd, title, 512)
        cls = ctypes.create_unicode_buffer(512)
        user32.GetClassNameW(hwnd, cls, 512)
        lpdw_pid = wintypes.DWORD()
        user32.GetWindowThreadProcessId(hwnd, ctypes.byref(lpdw_pid))
        t = title.value.lower()
        c = cls.value.lower()
        if any(k in t or k in c for k in ['memu', 'microvirt', 'android', 'phone', 'emulator', 'qt5']):
            rect = wintypes.RECT()
            user32.GetWindowRect(hwnd, ctypes.byref(rect))
            print(f"PID {lpdw_pid.value}, HWND {hwnd}: Title='{title.value}', Class='{cls.value}', Rect=({rect.left},{rect.top},{rect.right},{rect.bottom})")
    return True

WNDENUMPROC = ctypes.WINFUNCTYPE(ctypes.c_bool, wintypes.HWND, wintypes.LPARAM)
user32.EnumWindows(WNDENUMPROC(enum_all), 0)
