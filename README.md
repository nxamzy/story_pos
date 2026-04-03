# 🚀 Ocam POS — Modern Retail Management System

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)

**Ocam POS** — bu do'konlar, omborxonalar va savdo nuqtalari uchun mo'ljallangan zamonaviy mobil boshqaruv tizimi. Loyihaning asosiy maqsadi — hisob-kitob jarayonlarini raqamlashtirish va biznesni boshqarishni maksimal darajada osonlashtirish. Dastur barqaror ishlashi va kelajakda oson kengaytirilishi (scale) uchun to'liq **Clean Architecture** va **BLoC** pattern asosida qurilgan.

## ✨ Loyihaning Asosiy Imkoniyatlari (Features)

* 📦 **Smart Inventarizatsiya:** Mahsulotlarni QR-kod orqali soniyalar ichida skanerlash, qidirish va omborga tezkor qo'shish.
* 👥 **Taminotchilar Boshqaruvi (Suppliers):** Yetkazib beruvchilar bilan ishlash, ularning ro'yxati, filtrlash va muddatlar (sana) bo'yicha aniq nazorat qilish.
* ☁️ **Real-Time Database & Sync:** Barcha ma'lumotlar Firebase Firestore yordamida bulutda xavfsiz saqlanadi. Ilova ma'lumotlarni real vaqtda sinxronizatsiya qiladi.
* 📊 **Analitika va Hisobotlar:** Savdo jarayonlarini kuzatish va moliyaviy oqimlarni tahlil qilish uchun qulay interfeys.
* 🛡 **Solid Error Handling:** Har qanday tarmoq uzilishi yoki ma'lumot yuklashdagi xatoliklar try-catch orqali global ushlanadi va foydalanuvchiga toza holatda (Loading/Error UI) ko'rsatiladi.

## 🛠 Texnologik Stek

* **UI Framework:** Flutter (Android & iOS).
* **Til:** Dart (100% Null-safety).
* **State Management:** BLoC (Business Logic Component). Biznes mantiq UI'dan to'liq ajratilgan, UI faqat view vazifasini bajaradi.
* **Arxitektura:** Clean Architecture.
* **Backend & DB:** Firebase (Firestore, Authentication).
* **Routing:** GoRouter (sahifalar orasida chuqur va xavfsiz o'tishlar uchun).
* **Dizayn Tizimi:** Barcha ranglar, shriftlar markazlashgan holda `AppColors` va yagona tema orqali boshqariladi. Hardcode qiymatlardan foydalanilmagan.

## 🏗 Loyiha Arxitekturasi (Clean Architecture Breakdown)

Loyiha qat'iy ravishda 4 ta asosiy qatlamga (layer) bo'lingan va har biri o'zining aniq vazifasiga ega:

```text
lib/
 ├── core/                 # Loyiha bo'ylab ishlatiladigan umumiy resurslar
 │    ├── constants/       # AppColors, TextStyles
 │    ├── error/           # Failure, Exceptions
 │    └── utils/           # Yordamchi funksiyalar
 │
 ├── data/                 # Ma'lumotlar bilan ishlash qatlami
 │    ├── datasources/     # Firebase call'lar va tashqi API bilan ishlash
 │    ├── models/          # DTO'lar, fromJson/toJson metodlari
 │    └── repositories/    # Domain layer interfeyslarning aniq realizatsiyasi
 │
 ├── domain/               # Biznes mantiq qatlami (Tashqi kutubxonalarga qaram emas)
 │    ├── entities/        # Asosiy ma'lumot obyektlari (sof Dart)
 │    ├── repositories/    # Interfeyslar (shartnomalar)
 │    └── usecases/        # Har bir funksional uchun alohida UseCase
 │
 └── presentation/         # UI va State qatlami
      ├── bloc/            # BLoC, Events, States (Barcha mantiq shu yerda)
      ├── pages/           # Ekranlar (Toza ko'rinish)
      └── widgets/         # Qayta ishlatiladigan komponentlar (Row, Column, Custom Cards)
