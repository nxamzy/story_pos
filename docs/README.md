# Ocam POS — ommaviy sahifalar

Google Play talab qiladigan ikkita sahifa:

| Fayl | Nima uchun |
|---|---|
| `index.html` | Maxfiylik siyosati (Privacy policy) — Play Console'da URL sifatida so'raladi |
| `delete-account.html` | Hisobni o'chirish so'rovi sahifasi — Data safety anketasida so'raladi |

Ikkalasi ham o'zbek va ingliz tilida, bitta faylda (yuqoridagi tugmalar
orqali almashadi). Tashqi fayl, shrift yoki skript ishlatilmaydi —
istalgan joyda ochiladi.

`play/` papkasida esa do'kon sahifasi uchun grafikalar turadi (ular
saytga chiqarilmaydi, `firebase.json` da `ignore` qilingan).

## 1. Aloqa manzili

Ikkala sahifada `jamshidbekormonjonov@gmail.com` yozilgan — hisobni
o'chirish so'rovlari shu manzilga keladi. Boshqasiga almashtirish:

```bash
cd docs
sed -i '' 's/jamshidbekormonjonov@gmail.com/yangi@manzil.uz/g' index.html delete-account.html
```

`lib/core/utils/app_config.dart` dagi `supportEmail` ham shu manzil —
ilova ichidagi "Yordam" sahifasidagi tugma o'shani ochadi. Birini
o'zgartirsangiz, ikkinchisini ham o'zgartiring.

## 2. Internetga chiqarish

Play sahifalari ochiq (login talab qilmaydigan) manzilda turishi shart.

### Firebase Hosting (tavsiya etiladi)

Loyihada allaqachon Firebase bor (`storepost-a64b8`), `firebase.json` da
hosting sozlangan — alohida repo ham, hisob ham kerak emas:

```bash
firebase deploy --only hosting --project storepost-a64b8
```

Bir daqiqada manzillar tayyor:

- Maxfiylik siyosati: `https://storepost-a64b8.web.app/`
- Hisobni o'chirish: `https://storepost-a64b8.web.app/delete-account.html`

Sahifani yangilaganda shu buyruqni qayta ishga tushiring. Kerak bo'lsa
`firebase hosting:disable` bilan saytni o'chirib qo'yish mumkin.

### GitHub Pages (muqobil)

```bash
# GitHub'da yangi PUBLIC repo yarating, masalan: ocam-pos-pages
cd docs
git init && git add . && git commit -m "Ocam POS: ommaviy sahifalar"
git branch -M main
git remote add origin https://github.com/<foydalanuvchi>/ocam-pos-pages.git
git push -u origin main
```

Keyin: **Settings → Pages → Source: `main` / `(root)` → Save**.

## 3. Play Console'ga kiritish

- **Store listing → Privacy policy** → maxfiylik siyosati manzili
- **App content → Data safety → Data deletion** → o'chirish sahifasi manzili

## 4. Tekshirish

Yuklashdan oldin brauzerda ochib ko'ring:

```bash
open docs/index.html docs/delete-account.html
```

Play tekshiruvchisi sahifani telefon brauzerida ham ochadi — ikkala fayl
ham kichik ekranga moslashgan.

## Sahifalarni yangilash

Ilovaga yangi ma'lumot yig'adigan funksiya qo'shsangiz, `index.html`
dagi 1-bo'limni va yuqoridagi "Oxirgi yangilanish" sanasini yangilang.
