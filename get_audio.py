import sys
import os

# ตรวจสอบว่าอยู่ใน onefile mode หรือไม่
if getattr(sys, '_MEIPASS', None):
    base_path = sys._MEIPASS
else:
    base_path = os.path.abspath(".")

# สร้าง path ไปยังไฟล์เสียง
debirun_sound = os.path.join(base_path, "Assets", "audio", "[fadr.com] instrumental-debirun_sound_test.mp3")
# debirun_sound = os.path.join(base_path, "Assets", "audio", "debirun_sound_test.mp3")
gacha_sound = os.path.join(base_path, "Assets", "audio", "gacha_sound_test.mp3")
