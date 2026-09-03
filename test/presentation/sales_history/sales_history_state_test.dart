import 'package:flutter_test/flutter_test.dart';
import 'package:ocam_pos/data/models/sale_model.dart';
import 'package:ocam_pos/presentation/sales_history/bloc/sales_history_state.dart';

SaleModel sale({
  required String id,
  String? customerName,
  String? cashierName,
  double total = 10000,
  bool refunded = false,
}) => SaleModel(
  id: id,
  items: const [],
  subTotal: total,
  total: total,
  paid: total,
  change: 0,
  customerName: customerName,
  cashierName: cashierName,
  refunded: refunded,
  createdAt: DateTime(2026, 9, 1),
);

void main() {
  final sales = [
    sale(id: 'abc123', customerName: 'Anvar', total: 50000),
    sale(id: 'def456', cashierName: 'Aziz', total: 30000),
    sale(id: 'ghi789', customerName: 'Anvar', total: 20000, refunded: true),
  ];

  group('SalesHistoryState.visibleSales', () {
    test('mijoz ismi bo\'yicha filtrlaydi', () {
      final state = SalesHistoryState(sales: sales, query: 'anvar');

      expect(state.visibleSales, hasLength(2));
    });

    test('kassir ismi bo\'yicha filtrlaydi', () {
      final state = SalesHistoryState(sales: sales, query: 'aziz');

      expect(state.visibleSales.single.id, 'def456');
    });

    test('chek raqami boshi bo\'yicha topadi', () {
      final state = SalesHistoryState(sales: sales, query: 'def');

      expect(state.visibleSales.single.id, 'def456');
    });

    test('so\'rov bo\'sh bo\'lsa hammasi ko\'rinadi', () {
      const state = SalesHistoryState();

      expect(SalesHistoryState(sales: sales).visibleSales, hasLength(3));
      expect(state.visibleSales, isEmpty);
    });
  });

  group('SalesHistoryState.total', () {
    test('qaytarilgan savdolar summaga qo\'shilmaydi', () {
      final state = SalesHistoryState(sales: sales);

      expect(state.total, 80000);
    });

    test('filtrlangan ro\'yxat summasi hisoblanadi', () {
      final state = SalesHistoryState(sales: sales, query: 'anvar');

      // Anvar'ning ikki xaridi bor, biri qaytarilgan.
      expect(state.total, 50000);
    });
  });
}
