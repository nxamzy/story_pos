#!/usr/bin/env python3
"""Ocam POS ikonkasini yasaydi — chek (yirtilgan pastki chekka + shtrix-kod).

    python3 assets/icon/make_icon.py
    dart run flutter_launcher_icons

Belgi maskasi bir marta chiziladi, keyin ikki faylda ishlatiladi:

  icon.png             gradient yashil fon + oq chek, shaffofliksiz (iOS talabi)
  icon_foreground.png  faqat oq chek, shaffof fonda (Android adaptive old qatlami)

Chek ichidagi chiziqlar qog'ozdan "kesib olingan" — ular fon rangini
ko'rsatadi, shuning uchun ikkala faylda ham bir xil ko'rinadi.

DIQQAT — old qatlam o'lchami. flutter_launcher_icons yasaydigan
`mipmap-anydpi-v26/ic_launcher.xml` old qatlamga `android:inset="16%"`
qo'shadi, ya'ni rasmni 108dp qatlamning markaziy 68% iga kichraytirib
chizadi. Shuning uchun bu fayldagi belgi deyarli chetdan chetga bo'lishi
kerak — bo'sh joyni asbobning o'zi qo'shadi. Belgiga o'zingiz 25% bo'sh
joy qoldirsangiz, u ikki marta kichrayadi va ikonka ichida yo'qolib
qoladi.
"""
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "icon"

S = 4                       # supersampling — chetlarni silliqlash uchun
N = 1024                    # yakuniy o'lcham
ASPECT = 0.76               # chek eni / bo'yi
TOP = (0x4F, 0xA3, 0x7B)    # gradient tepasi
BOT = (0x33, 0x78, 0x5A)    # gradient pasti (brend rangi #40916C o'rtada)

SAFE = 0.61                 # adaptive ikonkaning kafolatlangan xavfsiz doirasi
INSET_SCALE = 1 - 2 * 0.16  # ic_launcher.xml dagi `inset` qoldiradigan ulush


def receipt_mask(bh):
    """Chek maskasi: 255 = oq qog'oz, 0 = fon yoki kesik."""
    bw = int(bh * ASPECT)
    m = Image.new("L", (bw, bh), 0)
    d = ImageDraw.Draw(m)

    d.rounded_rectangle([0, 0, bw - 1, bh - 1], radius=int(bw * 0.09), fill=255)

    # yirtilgan pastki chekka — 5 ta tish (ko'proq bo'lsa 48 px da xiralashadi)
    th, n = int(bh * 0.085), 5
    tw = bw / n
    for i in range(n):
        x0 = i * tw
        d.polygon([(x0, bh), (x0 + tw, bh), (x0 + tw / 2, bh - th)], fill=0)

    px = bw * 0.17

    def line(x0, y0, x1, y1):
        d.rounded_rectangle([x0, y0, x1, y1], radius=max(1, int((y1 - y0) / 2)), fill=0)

    line(px, bh * 0.130, bw - px, bh * 0.196)      # do'kon nomi
    line(px, bh * 0.246, bw * 0.61, bh * 0.312)    # sana / kassir

    widths, gap = [3, 1, 2, 1, 3], 1.3             # shtrix-kod
    u = (bw - 2 * px) / (sum(widths) + gap * (len(widths) - 1))
    x = px
    for w in widths:
        d.rectangle([x, bh * 0.420, x + w * u, bh * 0.712], fill=0)
        x += (w + gap) * u
    return m


def _gradient(size):
    g = Image.new("RGB", (1, size))
    for y in range(size):
        t = y / (size - 1)
        g.putpixel((0, y), tuple(int(TOP[i] + (BOT[i] - TOP[i]) * t) for i in range(3)))
    return g.resize((size, size), Image.BICUBIC)


def _place(canvas, mark_h):
    """Belgini markazga, oq rangda joylashtiradi."""
    bh = int(mark_h) * S
    m = receipt_mask(bh).resize((int(bh * ASPECT) // S, bh // S), Image.LANCZOS)
    canvas.paste(
        Image.new(canvas.mode, m.size, (255, 255, 255, 255)[: len(canvas.mode)]),
        ((canvas.width - m.width) // 2, (canvas.height - m.height) // 2),
        m,
    )
    return canvas


def build():
    diag = (1 + ASPECT ** 2) ** 0.5

    icon = _place(_gradient(N), N * 0.63)   # to'liq ikonkada belgi bo'yi = 63%
    icon.save(OUT / "icon.png")

    # xavfsiz doiraga sig'sin: diagonal = SAFE / INSET_SCALE
    fg = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    _place(fg, (SAFE / INSET_SCALE) * N / diag)
    fg.save(OUT / "icon_foreground.png")
    return icon, fg


if __name__ == "__main__":
    a, b = build()
    print("yasaldi:", OUT / "icon.png", a.size, "|", OUT / "icon_foreground.png", b.size)
