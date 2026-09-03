import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/cart_item_model.dart';
import 'package:ocam_pos/data/models/model_utils.dart';

/// Yakunlangan savdo yozuvi.
class SaleModel extends Equatable {
  final String id;
  final List<CartItem> items;
  final double subTotal;
  final double tax;
  final double total;
  final double paid;
  final double change;
  final String paymentMethod;
  final String? customerId;
  final String? customerName;

  /// Savdoni rasmiylashtirgan kassir (Profil -> "Profilni almashtirish"
  /// orqali tanlanadi). Bo'sh bo'lsa — do'kon egasi o'zi sotgan.
  final String? cashierId;
  final String? cashierName;
  final String note;
  final DateTime createdAt;

  /// Savdo qaytarilgan (bekor qilingan) bo'lsa `true` — ombor, kassa va
  /// mijoz sarfi orqaga qaytarilgan demakdir. Hisobotda bunday savdolar
  /// summaga qo'shilmaydi.
  final bool refunded;
  final DateTime? refundedAt;

  const SaleModel({
    required this.id,
    required this.items,
    required this.subTotal,
    this.tax = 0,
    required this.total,
    required this.paid,
    required this.change,
    this.paymentMethod = 'cash',
    this.customerId,
    this.customerName,
    this.cashierId,
    this.cashierName,
    this.note = '',
    required this.createdAt,
    this.refunded = false,
    this.refundedAt,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Sotuvdan olingan sof foyda.
  double get profit => items.fold(
    0,
    (sum, item) => sum + (item.product.profitPerUnit * item.quantity),
  );

  factory SaleModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawItems = (map['items'] as List<dynamic>? ?? const []);
    return SaleModel(
      id: docId,
      items: rawItems
          .map((e) => CartItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      subTotal: ModelUtils.toDouble(map['subTotal'], ModelUtils.toDouble(map['total'])),
      tax: ModelUtils.toDouble(map['tax']),
      total: ModelUtils.toDouble(map['total']),
      paid: ModelUtils.toDouble(map['paid']),
      change: ModelUtils.toDouble(map['change']),
      paymentMethod: ModelUtils.toStr(map['paymentMethod'], 'cash'),
      customerId: map['customerId'] as String?,
      customerName: map['customerName'] as String?,
      cashierId: map['cashierId'] as String?,
      cashierName: map['cashierName'] as String?,
      note: ModelUtils.toStr(map['note']),
      refunded: map['refunded'] == true,
      refundedAt: ModelUtils.dateOrNull(map['refundedAt']),
      // Eski yozuvlarda sana `date` deb saqlangan.
      createdAt: ModelUtils.date(map['createdAt'] ?? map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((e) => e.toMap()).toList(),
      'subTotal': subTotal,
      'tax': tax,
      'total': total,
      'paid': paid,
      'change': change,
      'paymentMethod': paymentMethod,
      'customerId': customerId,
      'customerName': customerName,
      'cashierId': cashierId,
      'cashierName': cashierName,
      'note': note,
      'itemCount': itemCount,
      'profit': profit,
      'refunded': refunded,
    };
  }

  @override
  List<Object?> get props => [
    id,
    items,
    total,
    paid,
    change,
    createdAt,
    refunded,
  ];
}
