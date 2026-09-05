# Play Market uchun reliz tayyorlash

Ocam POS'ni Google Play Console'ga yuklash bo'yicha to'liq yo'riqnoma.
Paket nomi: **`uz.ocam.pos`** — Play'ga birinchi marta yuklangandan keyin
bu nomni o'zgartirib bo'lmaydi.

---

## 1. Upload keystore yaratish (bir marta)

Keystore — ilovani imzolaydigan maxfiy kalit. **Uni yo'qotsangiz ilovani
boshqa hech qachon yangilay olmaysiz**, shuning uchun nusxasini xavfsiz
joyda (masalan parol menejeri yoki shifrlangan disk) saqlang.

Terminalda quyidagini ishga tushiring — parolni o'zingiz o'ylab topasiz:

```bash
keytool -genkey -v \
  -keystore ~/ocam-upload-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

`keytool` javanikidir; agar topilmasa:
`/opt/homebrew/opt/openjdk@17/bin/keytool` to'liq yo'lini yozing.

Savollarga javob beriladi (ism, tashkilot, shahar, davlat kodi — `UZ`).
Parol kamida 6 belgi bo'lishi kerak.

> **Keystore'ni repo ichiga qo'ymang.** `~/ocam-upload-key.jks` — uy
> papkangiz, bu to'g'ri joy. `.gitignore` `*.jks` ni bloklaydi, lekin
> baribir tashqarida saqlagan xavfsizroq.

## 2. `android/key.properties` faylini yaratish

```bash
cp android/key.properties.example android/key.properties
```

Keyin faylni ochib o'z qiymatlaringizni yozing:

```properties
storePassword=<keytool'da kiritgan keystore paroli>
keyPassword=<kalit paroli — odatda yuqoridagi bilan bir xil>
keyAlias=upload
storeFile=/Users/<foydalanuvchi>/ocam-upload-key.jks
```

Bu fayl `.gitignore`da — git'ga hech qachon tushmaydi.

`android/app/build.gradle.kts` shu faylni o'zi topadi: mavjud bo'lsa reliz
haqiqiy kalit bilan imzolanadi, bo'lmasa debug kalit bilan imzolanadi va
Gradle ogohlantirish chiqaradi.

## 3. Imzo ishlayotganini tekshirish

```bash
flutter build appbundle --release
```

Chiqishda `OGOHLANTIRISH: android/key.properties topilmadi` yozuvi
**bo'lmasligi** kerak. Natija:
`build/app/outputs/bundle/release/app-release.aab`

Imzoni tasdiqlash:

```bash
keytool -list -v -keystore ~/ocam-upload-key.jks -alias upload
```

Chiqadigan **SHA-1** va **SHA-256** barmoq izlarini saqlab qo'ying —
keyinchalik Google orqali kirish (Google Sign-In) yoki boshqa Google
xizmatlarini ulasangiz, ularni Firebase konsoliga qo'shish kerak bo'ladi.

## 4. Play Console'ga yuklash

Play **`.apk` emas, `.aab`** (Android App Bundle) qabul qiladi:

```bash
flutter build appbundle --release
```

`.aab` har bir qurilma uchun alohida APK yasaydi, shuning uchun
foydalanuvchi yuklab oladigan hajm to'liq APK'dan (~79 MB) ancha kichik
bo'ladi.

Play Console'da yangi ilova yaratganingizda **Play App Signing** yoqiladi
(standart holat). Bu degani: siz yuqoridagi kalit bilan imzolab yuklaysiz
(u "upload key" deb ataladi), Google esa foydalanuvchilarga tarqatishdan
oldin o'z kaliti bilan qayta imzolaydi. Upload kalitini yo'qotsangiz uni
Google orqali tiklash mumkin — lekin buni sinab ko'rmaslik ma'qul.

## 5. Versiyani oshirish

Har bir yangi yuklamada `pubspec.yaml`dagi versiya oshirilishi shart:

```yaml
version: 1.0.0+1
#        ^^^^^ versionName (foydalanuvchi ko'radi)
#              ^ versionCode (Play uchun; har safar oshishi SHART)
```

`1.0.0+1` → `1.0.1+2` → `1.1.0+3` ...
Bir xil `versionCode` bilan ikkinchi marta yuklab bo'lmaydi.

## 6. Play Console'da to'ldiriladigan narsalar

Kodga aloqasi yo'q, lekin ularsiz ilova chiqmaydi.

**Tayyor — faqat yuklash/nusxa olish qoladi:**

| Nima | Qayerda |
|---|---|
| Ilova ikonkasi 512×512 | `docs/play/icon-512.png` |
| Feature grafika 1024×500 | `docs/play/feature-graphic.png` |
| Nom, qisqa va to'liq tavsif, teglar | `docs/play-listing.md` |
| Maxfiylik siyosati sahifasi | `docs/index.html` |
| Hisobni o'chirish sahifasi | `docs/delete-account.html` |

Ikki sahifani avval internetga chiqarish kerak (`docs/README.md`):

```bash
firebase deploy --only hosting --project storepost-a64b8
```

**Hali qilinmagan:**

- **Skrinshotlar** — kamida 2 ta, telefon uchun. Ilovani real ma'lumot
  bilan to'ldirib oling: kassa, savat, chek, ombor, hisobot ekranlari.
- **Data safety** anketasi — qanday ma'lumot yig'ilishi va nima uchun.
  Ocam POS uchun: Email manzil (hisob boshqaruvi), Ism (hisob
  boshqaruvi), Ilova faoliyati (do'kon ma'lumoti). Hammasi shifrlangan
  holda uzatiladi (Firebase HTTPS), foydalanuvchi hisobini o'chira
  oladi — o'chirish havolasi sifatida yuqoridagi sahifani ko'rsating.
- **Kamera ruxsati izohi** — shtrix-kod skanerlash uchun. Ilovadagi
  matn: `ios/Runner/Info.plist` dagi `NSCameraUsageDescription`.
- **Content rating** anketasi va **Target audience** — biznes ilovasi,
  18+ auditoriya.

## 7. Tez ma'lumotnoma

| Nima | Qiymat |
|---|---|
| Paket nomi (`applicationId`) | `uz.ocam.pos` |
| iOS bundle id | `uz.ocam.pos` |
| Firebase loyihasi | `storepost-a64b8` |
| Keystore (tavsiya) | `~/ocam-upload-key.jks` |
| Kalit nomi (alias) | `upload` |
| Reliz buyrug'i | `flutter build appbundle --release` |
| Natija | `build/app/outputs/bundle/release/app-release.aab` |
