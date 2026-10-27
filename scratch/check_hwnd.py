import ctypes
from ctypes import wintypes

user32 = ctypes.windll.user32

hwnd = 527134
title = ctypes.create_unicode_buffer(512)
user32.GetWindowTextW(hwnd, title, 512)

rect = wintypes.RECT()
user32.GetWindowRect(hwnd, ctypes.byref(rect))

is_visible = user32.IsWindowVisible(hwnd)
print(f"HWND {hwnd}: Title='{title.value}', Rect=({rect.left}, {rect.top}, {rect.right}, {rect.bottom}), Visible={is_visible}")
