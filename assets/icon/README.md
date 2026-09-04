# Ilova ikonkasi

Bu papkaga ikkita PNG qo'yiladi, keyin loyiha ildizida:

```bash
dart run flutter_launcher_icons
```

Bu buyruq `android/app/src/main/res/mipmap-*/` va
`ios/Runner/Assets.xcassets/AppIcon.appiconset/` ichidagi barcha
o'lchamlarni qayta yozadi.

## Kerakli fayllar

| Fayl | O'lcham | Talab |
|---|---|---|
| `icon.png` | 1024×1024 | To'liq ikonka. **Shaffof fon bo'lmasin** — iOS shaffoflikni qabul qilmaydi. Burchaklarni o'zingiz yumaloqlamang, tizim o'zi qiladi. |
| `icon_foreground.png` | 1024×1024 | Faqat belgi, **shaffof fonda**. Belgi markazdagi ~60% doirasiga sig'ishi kerak — atrofida kamida 25% bo'sh joy qoldiring. |

## Nega ikkita fayl

Android 8 dan boshlab ikonka ikki qatlamdan iborat: fon va old qatlam.
Tizim ularni qurilmaga qarab doira, kvadrat yoki tomchi shaklida kesadi
va animatsiya paytida bir-biriga nisbatan siljitadi. Shuning uchun old
qatlamdagi belgi chekkaga yaqin bo'lsa **kesilib qoladi**.

Fon rangi `pubspec.yaml` da `#40916C` (ilovaning asosiy yashil rangi) deb
belgilangan — o'rniga rasm ishlatmoqchi bo'lsangiz, o'sha yerdagi
`adaptive_icon_background` ni fayl yo'liga almashtiring.

## Faqat bitta rasmingiz bo'lsa

`icon.png` ni qo'ying va ayting — `icon_foreground.png` ni undan
kerakli bo'sh joy bilan o'zim yasab beraman.

## Play Console uchun alohida

Do'kon sahifasiga **512×512 PNG** alohida yuklanadi (ilova ichidagi
ikonkadan mustaqil). `icon.png` ni shu o'lchamga kichraytirish yetarli:

```bash
sips -Z 512 assets/icon/icon.png --out /tmp/play-icon-512.png
```
