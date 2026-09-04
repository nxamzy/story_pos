# Ocam POS — ommaviy sahifalar

Google Play talab qiladigan ikkita sahifa:

| Fayl | Nima uchun |
|---|---|
| `index.html` | Maxfiylik siyosati (Privacy policy) — Play Console'da URL sifatida so'raladi |
| `delete-account.html` | Hisobni o'chirish so'rovi sahifasi — Data safety anketasida so'raladi |

Ikkalasi ham o'zbek va ingliz tilida, bitta faylda (yuqoridagi tugmalar
orqali almashadi). Tashqi fayl, shrift yoki skript ishlatilmaydi —
istalgan joyda ochiladi.

## 1. Email manzilini qo'yish

Ikkala faylda `ALMASHTIRING@example.com` o'rniga haqiqiy manzilingizni
yozing:

```bash
cd docs
sed -i '' 's/ALMASHTIRING@example.com/sizning@email.uz/g' index.html delete-account.html
```

Manzil maxfiylik siyosatida ham, o'chirish so'rovi sahifasida ham
ishlatiladi, shuning uchun **javob beriladigan** manzil bo'lishi kerak.

## 2. GitHub Pages'ga qo'yish

Play sahifalari ochiq (login talab qilmaydigan) manzilda turishi shart.
Eng oson bepul yo'l:

```bash
# 1. GitHub'da yangi PUBLIC repo yarating, masalan: ocam-pos-pages
# 2. Shu papkani o'sha repoga yuklang:
cd docs
git init
git add .
git commit -m "Ocam POS: maxfiylik siyosati va hisobni o'chirish sahifasi"
git branch -M main
git remote add origin https://github.com/<foydalanuvchi>/ocam-pos-pages.git
git push -u origin main
```

Keyin GitHub'da: **Settings → Pages → Source: `main` / `(root)` → Save**.

1-2 daqiqadan keyin manzillar tayyor bo'ladi:

- Maxfiylik siyosati: `https://<foydalanuvchi>.github.io/ocam-pos-pages/`
- Hisobni o'chirish: `https://<foydalanuvchi>.github.io/ocam-pos-pages/delete-account.html`

Shu ikki manzilni Play Console'ga kiritasiz:

- **Store listing → Privacy policy** → birinchi manzil
- **App content → Data safety → Data deletion** → ikkinchi manzil

## 3. Tekshirish

Yuklashdan oldin brauzerda ochib ko'ring:

```bash
open docs/index.html docs/delete-account.html
```

Play tekshiruvchisi sahifani telefon brauzerida ham ochadi — ikkala fayl
ham kichik ekranga moslashgan.

## Sahifalarni yangilash

Ilovaga yangi ma'lumot yig'adigan funksiya qo'shsangiz, `index.html`
dagi 1-bo'limni va yuqoridagi "Oxirgi yangilanish" sanasini yangilang.
