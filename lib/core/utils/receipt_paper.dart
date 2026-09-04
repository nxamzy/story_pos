/// Chek chiqariladigan qog'oz formati.
///
/// Do'konlarda ko'pincha 58 mm yoki 80 mm lentali termal printer ishlatiladi;
/// A4 esa oddiy printerdan chek chiqarish yoki PDF qilib saqlash uchun.
/// Tanlov Sozlamalar -> "Printer" da qilinadi va `ReceiptPrinter` shu
/// qiymatga qarab sahifa o'lchamini beradi.
enum ReceiptPaper {
  roll57('roll57', "58 mm lenta", "Kichik termal printer"),
  roll80('roll80', "80 mm lenta", "Standart kassa printeri"),
  a4('a4', "A4 varaq", "Oddiy printer yoki PDF");

  /// Firestore'da saqlanadigan qiymat.
  final String wire;
  final String label;
  final String description;

  const ReceiptPaper(this.wire, this.label, this.description);

  static ReceiptPaper fromWire(Object? value) => values.firstWhere(
    (paper) => paper.wire == value,
    orElse: () => ReceiptPaper.roll80,
  );
}
