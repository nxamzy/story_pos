import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ocam_pos/core/utils/app_config.dart';
import 'package:ocam_pos/core/utils/formatters.dart';
import 'package:ocam_pos/core/utils/receipt_paper.dart';
import 'package:ocam_pos/data/models/cart_item_model.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/data/models/user_model.dart';

/// Chekni PDF qilib chop etish.
///
/// Qog'oz o'lchami Sozlamalar -> "Printer" da tanlanadi
/// (`AppConfig.receiptPaper`); standart holat — 80 mm lenta.
class ReceiptPrinter {
  const ReceiptPrinter._();

  /// [sale] berilsa chekda savdo raqami, to'lov turi, to'langan summa va
  /// qaytim ham ko'rsatiladi. [store] — Sozlamalardagi do'kon ma'lumoti
  /// (nomi, manzili, STIR); berilmasa umumiy sarlavha chiqadi.
  static PdfPageFormat _pageFormat(ReceiptPaper paper) => switch (paper) {
    ReceiptPaper.roll57 => PdfPageFormat.roll57,
    ReceiptPaper.roll80 => PdfPageFormat.roll80,
    ReceiptPaper.a4 => PdfPageFormat.a4,
  };

  static Future<void> printReceipt(
    List<CartItem> items,
    double total, {
    SaleModel? sale,
    UserModel? store,
  }) async {
    final pdf = pw.Document(theme: await _theme());
    final createdAt = sale?.createdAt ?? DateTime.now();

    pdf.addPage(
      pw.Page(
        pageFormat: _pageFormat(AppConfig.receiptPaper),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _header(store),
            pw.Divider(),
            _line("Sana", AppFormat.dateTime(createdAt)),
            if (sale != null && sale.id.isNotEmpty)
              _line("Chek", '#${_shortId(sale.id)}'),
            if (sale?.customerName != null && sale!.customerName!.isNotEmpty)
              _line("Mijoz", sale.customerName!),
            if (sale?.cashierName != null && sale!.cashierName!.isNotEmpty)
              _line("Kassir", sale.cashierName!),
            pw.Divider(),

            ...items.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        "${item.product.name} x${item.quantity}",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Text(
                      AppFormat.money(item.subTotal),
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),

            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "JAMI:",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  AppFormat.money(total),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (sale != null) ...[
              _line("To'lov turi", _paymentLabel(sale.paymentMethod)),
              _line("To'landi", AppFormat.money(sale.paid)),
              if (sale.change > 0) _line("Qaytim", AppFormat.money(sale.change)),
              if (sale.note.isNotEmpty) _line("Eslatma", sale.note),
            ],

            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text(
                "Xaridingiz uchun rahmat!",
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static pw.Widget _header(UserModel? store) {
    final name = (store?.storeName.isNotEmpty ?? false)
        ? store!.storeName
        : "OCAM POS";

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          name,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        if (store != null && store.address.isNotEmpty)
          pw.Text(store.address, style: const pw.TextStyle(fontSize: 9)),
        if (store != null && store.storePhone.isNotEmpty)
          pw.Text(
            "Tel: ${store.storePhone}",
            style: const pw.TextStyle(fontSize: 9),
          ),
        if (store != null && store.taxId.isNotEmpty)
          pw.Text(
            "STIR: ${store.taxId}",
            style: const pw.TextStyle(fontSize: 9),
          ),
      ],
    );
  }

  static pw.Widget _line(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.Flexible(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    ),
  );

  static String _paymentLabel(String method) =>
      method == 'card' ? "Plastik karta" : "Naqd pul";

  static String _shortId(String id) =>
      id.length > 6 ? id.substring(0, 6) : id;

  /// PDF'ning standart shrifti (Helvetica) o'zbekcha `oʻ`, `gʻ` kabi
  /// belgilarni chiza olmaydi. Roboto yuklab olinadi; internet bo'lmasa
  /// standart shriftga qaytiladi — chek baribir chiqadi.
  static Future<pw.ThemeData?> _theme() async {
    try {
      return pw.ThemeData.withFont(
        base: await PdfGoogleFonts.robotoRegular(),
        bold: await PdfGoogleFonts.robotoBold(),
      );
    } catch (_) {
      return null;
    }
  }
}
