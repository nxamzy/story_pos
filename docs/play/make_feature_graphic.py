#!/usr/bin/env python3
"""Play Console uchun feature grafika (1024x500) va do'kon ikonkasi (512x512).

    python3 docs/play/make_feature_graphic.py

Ikonka belgisi `assets/icon/make_icon.py` dan olinadi — ikkalasi bir xil
ko'rinishda bo'lishi uchun. Play feature grafikaning chetlarini kesib
qo'yishi mumkin, shuning uchun butun kompozitsiya markazda turadi.
"""
import importlib.util
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("make_icon", ROOT / "assets/icon/make_icon.py")
mk = importlib.util.module_from_spec(spec)
sys.modules["make_icon"] = mk
spec.loader.exec_module(mk)

W, H = 1024, 500
TOP, BOT = (0x4F, 0xA3, 0x7B), (0x2C, 0x6B, 0x50)
BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
REG = "/System/Library/Fonts/Supplemental/Arial.ttf"

TITLE = "Ocam POS"
SUBS = ["Do'kon uchun kassa, ombor,", "chek va hisobot — bitta ilovada"]

img = Image.new("RGB", (W, H))
d = ImageDraw.Draw(img)
for y in range(H):
    t = y / (H - 1)
    d.line([(0, y), (W, y)], fill=tuple(int(TOP[i] + (BOT[i] - TOP[i]) * t) for i in range(3)))

mark_h = 300
m = mk.receipt_mask(mark_h * mk.S).resize(
    (int(mark_h * mk.ASPECT), mark_h), Image.LANCZOS)

f_title = ImageFont.truetype(BOLD, 96)
f_sub = ImageFont.truetype(REG, 37)

text_w = max(d.textlength(TITLE, font=f_title), *(d.textlength(s, font=f_sub) for s in SUBS))
gap = 54
x0 = (W - (m.width + gap + text_w)) / 2

img.paste(Image.new("RGB", m.size, (255, 255, 255)), (int(x0), (H - m.height) // 2), m)

tx = x0 + m.width + gap
ty = (H - (96 + 22 + 2 * 48)) / 2 - 6
d.text((tx, ty), TITLE, font=f_title, fill=(255, 255, 255))
for i, s in enumerate(SUBS):
    d.text((tx + 3, ty + 118 + i * 48), s, font=f_sub, fill=(226, 244, 235))

out = ROOT / "docs/play"
img.save(out / "feature-graphic.png")

icon = Image.open(ROOT / "assets/icon/icon.png").resize((512, 512), Image.LANCZOS)
icon.save(out / "icon-512.png")
print("yasaldi:", out / "feature-graphic.png", img.size, "|", out / "icon-512.png", icon.size)
