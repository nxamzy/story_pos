import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/model_utils.dart';
import 'package:ocam_pos/data/models/product_model.dart';

/// Ta'minotchidan olingan bitta mahsulot qatori.
class PurchaseItem extends Equatable {
  final String productId;
  final String name;
  final int quantity;

  /// Shu xaridda kelishilgan tannarx (bir dona uchun).
  final double buyPrice;

  const PurchaseItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.buyPrice,
  });

  double get subTotal => buyPrice * quantity;

  factory PurchaseItem.fromProduct(ProductModel product, {int quantity = 1}) =>
      PurchaseItem(
        productId: product.id,
        name: product.name,
        quantity: quantity,
        buyPrice: product.buyPrice,
      );

  factory PurchaseItem.fromMap(Map<String, dynamic> map) => PurchaseItem(
    productId: ModelUtils.toStr(map['productId']),
    name: ModelUtils.toStr(map['name']),
    quantity: ModelUtils.toInt(map['quantity'], 1),
    buyPrice: ModelUtils.toDouble(map['buyPrice']),
  );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'name': name,
    'quantity': quantity,
    'buyPrice': buyPrice,
    'subTotal': subTotal,
  };

  PurchaseItem copyWith({int? quantity, double? buyPrice}) => PurchaseItem(
    productId: productId,
    name: name,
    quantity: quantity ?? this.quantity,
    buyPrice: buyPrice ?? this.buyPrice,
  );

  @override
  List<Object?> get props => [productId, name, quantity, buyPrice];
}

/// Ta'minotchidan mahsulot kirimi (xarid).
///
/// Xarid yozilganda omborga tovar kiradi va mahsulotning tannarxi shu
/// xariddagi narxga yangilanadi — foyda hisobi shu tannarxga tayanadi.
class PurchaseModel extends Equatable {
  final String id;
  final String supplierId;
  final String supplierName;
  final List<PurchaseItem> items;
  final String note;

  /// `true` bo'lsa pul kassadan to'langan va kassa balansi kamayadi.
  final bool paidFromDrawer;
  final DateTime createdAt;

  const PurchaseModel({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    this.note = '',
    this.paidFromDrawer = true,
    required this.createdAt,
  });

  double get total => items.fold(0, (sum, item) => sum + item.subTotal);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory PurchaseModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawItems = (map['items'] as List<dynamic>? ?? const []);
    return PurchaseModel(
      id: docId,
      supplierId: ModelUtils.toStr(map['supplierId']),
      supplierName: ModelUtils.toStr(map['supplierName']),
      items: rawItems
          .map((e) => PurchaseItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      note: ModelUtils.toStr(map['note']),
      paidFromDrawer: map['paidFromDrawer'] != false,
      createdAt: ModelUtils.date(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'supplierId': supplierId,
    'supplierName': supplierName,
    'items': items.map((e) => e.toMap()).toList(),
    'note': note,
    'paidFromDrawer': paidFromDrawer,
    'total': total,
    'itemCount': itemCount,
  };

  PurchaseModel copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    List<PurchaseItem>? items,
    String? note,
    bool? paidFromDrawer,
    DateTime? createdAt,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      items: items ?? this.items,
      note: note ?? this.note,
      paidFromDrawer: paidFromDrawer ?? this.paidFromDrawer,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    supplierId,
    supplierName,
    items,
    note,
    paidFromDrawer,
    createdAt,
  ];
}
