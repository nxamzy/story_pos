import 'package:flutter/material.dart';
import 'package:ocam_pos/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

/// Ko'p so'raladigan savollar.
///
/// Javoblar ilovaning haqiqiy ishlashiga asoslangan — savdo, qaytarish,
/// kassa va hisobot mantig'i qanday yozilgan bo'lsa, shunday tushuntirilgan.
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const _questions = <({String question, String answer})>[
    (
      question: "Mahsulotni qanday qo'shaman?",
      answer:
          "Ombor bo'limidagi \"+\" tugmasini bosing. Nom, shtrix-kod, "
          "sotib olingan narx, sotish narxi va qoldiqni kiriting. "
          "Shtrix-kod maydonidagi skaner belgisini bossangiz kodni "
          "kamerada o'qib olish mumkin.",
    ),
    (
      question: "Skaner kodni o'qimayapti, nima qilay?",
      answer:
          "Avval qurilma kameraga ruxsat berganini tekshiring. Keyin "
          "Sozlamalar -> \"Shtrix-kod skaneri\" -> \"Skanerni sinash\" "
          "orqali kodni o'qib ko'ring: ilova o'qilgan kodni va shu kod "
          "bilan omborda mahsulot bor-yo'qligini aytadi.",
    ),
    (
      question: "Savdoni qanday yakunlayman?",
      answer:
          "Savdo bo'limida mahsulotni tanlang yoki shtrix-kodini "
          "skanerlang, so'ng Savatga o'ting va \"To'lov\"ni bosing. "
          "To'lov turini (naqd yoki karta) tanlab, olingan summani "
          "kiriting — qaytim o'zi hisoblanadi. Kerak bo'lsa mijozni "
          "biriktirasiz va o'tgan sanani tanlashingiz mumkin.",
    ),
    (
      question: "Nega mahsulotni savatga qo'sha olmayapman?",
      answer:
          "Savatga ombordagi qoldiqdan ko'p mahsulot qo'shib bo'lmaydi. "
          "Qoldiqni Ombor bo'limida tekshiring — tovar kelgan bo'lsa uni "
          "\"Xaridlar\" orqali kirim qiling, shunda qoldiq oshadi.",
    ),
    (
      question: "Eski chekni qanday topaman?",
      answer:
          "Bosh sahifadagi \"Savdolar tarixi\"ga kiring. U yerda sana "
          "oralig'ini tanlab, mijoz nomi, kassir yoki chek raqami "
          "bo'yicha qidirish mumkin. Kerakli qatorni bossangiz chek "
          "ochiladi va uni qayta chop etish mumkin.",
    ),
    (
      question: "Savdoni qanday qaytaraman?",
      answer:
          "Chekni oching va qaytarishni tasdiqlang. Mahsulot qoldig'i "
          "tiklanadi, naqd savdo bo'lsa pul kassadan qaytariladi, "
          "mijozning sarflagan summasi kamayadi. Bitta savdoni faqat bir "
          "marta qaytarish mumkin va qaytarilgan savdo hisobot "
          "summalariga kirmaydi.",
    ),
    (
      question: "Kassadagi pul qanday o'zgaradi?",
      answer:
          "Naqd savdo kassaga pul qo'shadi. Kassadan to'langan xarid va "
          "\"kassadan\" belgilangan xarajat esa pulni kamaytiradi. "
          "Bundan tashqari kassa bilan xodim o'rtasida o'tkazma qilish "
          "mumkin — har bir o'tkazma tarixga yoziladi.",
    ),
    (
      question: "Xarid bilan xarajat farqi nimada?",
      answer:
          "Xarid — ta'minotchidan tovar olish: mahsulot qoldig'i oshadi "
          "va uning tannarxi yangilanadi. Xarajat — ijara, kommunal, "
          "transport kabi do'kondan chiqadigan pul. Hisobotda xarid "
          "alohida xarajat sifatida ko'rinmaydi: uning puli mahsulot "
          "sotilganda tannarx orqali foydadan chiqariladi.",
    ),
    (
      question: "Kassirni qanday almashtiraman?",
      answer:
          "Profil -> \"Profilni almashtirish\" bo'limidan xodimni "
          "tanlaysiz. Xodimga PIN o'rnatilgan bo'lsa u so'raladi. "
          "Shundan keyin qilingan savdolar shu kassir nomiga yoziladi.",
    ),
    (
      question: "Xodim PIN kodini unutdi",
      answer:
          "Do'kon egasi Xodimlar ro'yxatidan o'sha xodimni ochib, "
          "tahrirlash varag'ida yangi PIN belgilaydi. Eski PIN'ni "
          "ko'rishning iloji yo'q — u ilovada ochiq matnda saqlanmaydi.",
    ),
    (
      question: "Valyutani qanday o'zgartiraman?",
      answer:
          "Sozlamalar -> \"Valyuta\". Tanlangan belgi butun ilovadagi "
          "narxlarga va chekka darhol qo'llanadi.",
    ),
    (
      question: "Chek printerimda qiyshiq chiqyapti",
      answer:
          "Sozlamalar -> \"Printer\" da qog'oz o'lchamini tanlang: "
          "58 mm lenta, 80 mm lenta yoki A4. Shu yerdagi \"Sinov cheki\" "
          "tugmasi bilan natijani darhol tekshirib ko'rasiz.",
    ),
    (
      question: "Hisobot nimani ko'rsatadi?",
      answer:
          "Kun, hafta yoki oy bo'yicha savdo summasi, foyda, "
          "xarajatlardan keyingi sof foyda va eng ko'p sotilgan "
          "mahsulotlar. Qaytarilgan savdolar hech qaysi summaga "
          "qo'shilmaydi.",
    ),
    (
      question: "Internet uzilib qolsa nima bo'ladi?",
      answer:
          "Qisqa uzilishlarda ilova mahalliy nusxa bilan ishlashda davom "
          "etadi va aloqa tiklanganda ma'lumot serverga yuboriladi. "
          "Lekin ilova uzoq muddat internetsiz ishlash uchun "
          "mo'ljallanmagan — kun oxirida aloqa borligiga ishonch hosil "
          "qiling.",
    ),
    (
      question: "Hisobimni qanday o'chiraman?",
      answer:
          "Sozlamalar -> \"Xavfli hudud\" -> \"Hisobni butunlay "
          "o'chirish\". Parolingiz qayta so'raladi va tasdiqlagach "
          "hisobingiz hamda do'konning barcha ma'lumoti butunlay "
          "o'chiriladi. Bu amalni ortga qaytarib bo'lmaydi.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
        title: const Text(
          "Ko'p so'raladigan savollar",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: _questions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _questions[index];

          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mintLight),
            ),
            child: Theme(
              // ExpansionTile ochilganda standart ajratkich chizig'ini
              // olib tashlaydi — chegara allaqachon Container'da bor.
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                iconColor: AppColors.primary,
                collapsedIconColor: AppColors.sage,
                title: Text(
                  item.question,
                  style: const TextStyle(
                    color: AppColors.forestDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.answer,
                    style: const TextStyle(
                      color: AppColors.sage,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
