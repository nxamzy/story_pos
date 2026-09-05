# Ilova ikonkasi

Hozirgi ikonka shu papkadagi `make_icon.py` bilan yasalgan: yashil gradient
fon ustida oq chek — yirtilgan pastki chekka va shtrix-kod bilan.

```bash
python3 assets/icon/make_icon.py     # icon.png + icon_foreground.png
dart run flutter_launcher_icons      # barcha o'lchamlarga tarqatadi
```

Ikkinchi buyruq `android/app/src/main/res/mipmap-*/`, `drawable-*/` va
`ios/Runner/Assets.xcassets/AppIcon.appiconset/` ichini qayta yozadi.

## O'z rasmingizni qo'ymoqchi bo'lsangiz

`make_icon.py` ni ishlatmay, shu ikki faylni qo'lda qo'ying:

| Fayl | O'lcham | Talab |
|---|---|---|
| `icon.png` | 1024×1024 | To'liq ikonka. **Shaffof fon bo'lmasin** — iOS shaffoflikni qabul qilmaydi. Burchaklarni o'zingiz yumaloqlamang, tizim o'zi kesadi. |
| `icon_foreground.png` | 1024×1024 | Faqat belgi, **shaffof fonda**. Belgi rasmni deyarli to'ldirsin — pastdagi izohga qarang. |

### Old qatlamga o'zingiz bo'sh joy qo'shmang

Android 8 dan beri ikonka ikki qatlam: fon va old qatlam. Tizim ularni
qurilmaga qarab doira, kvadrat yoki tomchi shaklida kesadi, shuning uchun
belgi chetga yaqin bo'lsa kesilib qoladi — odatda "atrofida 25% bo'sh joy
qoldiring" deb aytiladi.

**Lekin bu loyihada bo'sh joyni asbobning o'zi qo'shadi.**
`flutter_launcher_icons` yasaydigan `mipmap-anydpi-v26/ic_launcher.xml`
old qatlamni `android:inset="16%"` bilan o'raydi, ya'ni rasmni 108dp
qatlamning markaziy 68% iga kichraytirib chizadi. Agar rasmga o'zingiz
ham 25% bo'sh joy qoldirsangiz, belgi ikki marta kichrayadi va ikonka
ichida yo'qolib qoladi.

Shuning uchun `make_icon.py` belgini ataylab rasm chetiga yaqin chizadi:
kerakli diagonal = xavfsiz doira (61%) ÷ inset qoldiradigan ulush (68%)
≈ **90%**.

Fon rangi `pubspec.yaml` da `#40916C` (ilovaning asosiy yashil rangi);
`android/app/src/main/res/values/colors.xml` ga ham shu yoziladi. O'rniga
rasm ishlatmoqchi bo'lsangiz `adaptive_icon_background` ni fayl yo'liga
almashtiring.

## `flutter_launcher_icons` ning iOS xatosi — har safar tekshiring

Asbob ikonkani yasagandan keyin `ios/Runner.xcodeproj/project.pbxproj`
ni ham o'zgartiradi va **noto'g'ri kalitni bosib yozadi**:

```
-  ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
+  ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon;
```

U `ASSETCATALOG_COMPILER_APPICON_NAME` ni izlaydi; loyiha darajasidagi
Debug va Release konfiguratsiyalarida bu kalit yo'q, shuning uchun duch
kelgan birinchi `ASSETCATALOG_*` kalitini almashtiradi. `YES`/`NO`
kutadigan sozlamaga `AppIcon` yozib qo'yiladi.

Ikonka nomi **target** darajasida allaqachon to'g'ri turibdi, ya'ni bu
o'zgarish keraksiz. Har safar buyruqni ishlatgandan keyin qaytaring:

```bash
git checkout ios/Runner.xcodeproj/project.pbxproj
```

Qolgan o'zgarishlar (`mipmap-*`, `drawable-*`, `colors.xml`,
`AppIcon.appiconset/`) to'g'ri — faqat shu bitta faylni qaytaring.

## Play Console uchun

Do'kon sahifasiga kerak bo'ladigan grafikalar `docs/play/` da tayyor:

| Fayl | O'lcham | Qayerga |
|---|---|---|
| `docs/play/icon-512.png` | 512×512 | Store listing → App icon |
| `docs/play/feature-graphic.png` | 1024×500 | Store listing → Feature graphic |

Ikonkani o'zgartirsangiz ikkalasini qayta yasang:

```bash
python3 docs/play/make_feature_graphic.py
```
