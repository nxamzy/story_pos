import 'package:flutter_test/flutter_test.dart';
import 'package:ocam_pos/data/models/cart_item_model.dart';
import 'package:ocam_pos/data/models/expense_model.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/presentation/report/bloc/report_state.dart';

ProductModel product(String id, String name, {double buy = 5000, double sell = 8000}) =>
    ProductModel(
      id: id,
      name: name,
      barcode: id,
      buyPrice: buy,
      sellPrice: sell,
      stock: 100,
    );

SaleModel sale(List<CartItem> items, {bool refunded = false}) {
  final total = items.fold<double>(0, (sum, item) => sum + item.subTotal);
  return SaleModel(
    id: 'sale-${items.length}-${refunded ? 'r' : 'n'}-${items.hashCode}',
    items: items,
    subTotal: total,
    total: total,
    paid: total,
    change: 0,
    refunded: refunded,
    createdAt: DateTime(2026, 9, 1),
  );
}

void main() {
  final cola = product('p1', 'Coca-Cola');
  final suv = product('p2', 'Suv', buy: 1000, sell: 2000);

  group('ReportState hisob-kitobi', () {
    final state = ReportState(
      sales: [
        sale([CartItem(product: cola, quantity: 3)]),
        sale([
          CartItem(product: suv, quantity: 5),
          CartItem(product: cola, quantity: 1),
        ]),
        // Qaytarilgan savdo hech qayerda hisobga olinmaydi.
        sale([CartItem(product: cola, quantity: 10)], refunded: true),
      ],
      expenses: [
        ExpenseModel(
          id: 'e1',
          title: 'Ijara',
          category: 'Ijara',
          amount: 20000,
          createdAt: DateTime(2026, 9, 1),
        ),
      ],
    );

    test('qaytarilgan savdo summaga kirmaydi', () {
      expect(state.refundedCount, 1);
      // 3x8000 + (5x2000 + 1x8000) = 24000 + 18000
      expect(state.salesTotal, 42000);
      expect(state.productsSold, 9);
    });

    test('sof foyda tannarx ayirilgan holda hisoblanadi', () {
      // Cola: 4 dona x 3000 foyda, Suv: 5 dona x 1000 foyda
      expect(state.netIncome, 17000);
    });

    test('xarajatdan keyingi foyda', () {
      expect(state.expenseTotal, 20000);
      expect(state.profitAfterExpenses, -3000);
    });

    test('eng ko\'p sotilganlar miqdor bo\'yicha saralanadi', () {
      final top = state.topProducts;

      expect(top.first.name, 'Suv');
      expect(top.first.quantity, 5);
      expect(top[1].name, 'Coca-Cola');
      // Qaytarilgan savdodagi 10 dona hisobga olinmaydi.
      expect(top[1].quantity, 4);
      expect(top[1].revenue, 32000);
    });

    test('davr belgisi standart holda kun', () {
      expect(ReportState().period, ReportPeriod.day);
      expect(ReportPeriod.week.label, 'Hafta');
    });
  });
}
