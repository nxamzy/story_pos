import 'package:flutter_test/flutter_test.dart';
import 'package:ocam_pos/core/logic/bloc_status.dart';
import 'package:ocam_pos/data/models/product_model.dart';
import 'package:ocam_pos/presentation/inventory/bloc/product_state.dart';

ProductModel _product({
  required String id,
  required String name,
  String? category,
  int stock = 10,
  String barcode = '',
}) => ProductModel(
  id: id,
  name: name,
  barcode: barcode,
  buyPrice: 1000,
  sellPrice: 2000,
  stock: stock,
  category: category,
);

void main() {
  final products = [
    _product(id: '1', name: 'Coca-Cola', category: 'Ichimliklar', stock: 20),
    _product(id: '2', name: 'Fanta', category: 'Ichimliklar', stock: 2),
    _product(id: '3', name: 'Snickers', category: 'Shirinliklar', stock: 0),
  ];

  group('ProductState.visibleProducts', () {
    test('so\'rov bo\'yicha nomga qarab filtrlaydi', () {
      final state = ProductState(
        status: BlocStatus.success,
        products: products,
        query: 'fanta',
      );
      expect(state.visibleProducts.map((p) => p.id), ['2']);
    });

    test('kategoriya bo\'yicha filtrlaydi', () {
      final state = ProductState(
        status: BlocStatus.success,
        products: products,
        category: 'Shirinliklar',
      );
      expect(state.visibleProducts.map((p) => p.id), ['3']);
    });

    test('"Barchasi" kategoriyasi hammasini ko\'rsatadi', () {
      final state = ProductState(status: BlocStatus.success, products: products);
      expect(state.visibleProducts.length, 3);
    });
  });

  group('ProductState.lowStockProducts', () {
    test('chegaradan kam yoki teng qoldiqlarni qaytaradi', () {
      final state = ProductState(status: BlocStatus.success, products: products);
      // AppConfig.lowStockThreshold == 5
      expect(state.lowStockProducts.map((p) => p.id), containsAll(['2', '3']));
      expect(state.lowStockProducts.map((p) => p.id), isNot(contains('1')));
    });
  });

  group('ProductState.inventoryValue', () {
    test('tannarx x qoldiq yig\'indisini hisoblaydi', () {
      final state = ProductState(status: BlocStatus.success, products: products);
      // (20 + 2 + 0) * 1000
      expect(state.inventoryValue, 22000);
    });
  });
}
