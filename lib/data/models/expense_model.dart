import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/model_utils.dart';

/// Do'kon xarajati: ijara, kommunal to'lov, transport va hokazo.
///
/// [fromDrawer] `true` bo'lsa pul kassadan olingan — shu sababli xarajat
/// yozilganda kassa balansi ham kamayadi (bitta tranzaksiyada).
class ExpenseModel extends Equatable {
  final String id;
  final String title;
  final String category;
  final double amount;
  final String note;
  final bool fromDrawer;
  final DateTime createdAt;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    this.note = '',
    this.fromDrawer = true,
    required this.createdAt,
  });

  /// Ilovada tanlanadigan xarajat turlari.
  static const List<String> categories = [
    'Ijara',
    'Kommunal',
    'Maosh',
    'Transport',
    "Ta'mirlash",
    'Soliq',
    'Boshqa',
  ];

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String docId) {
    return ExpenseModel(
      id: docId,
      title: ModelUtils.toStr(map['title']),
      category: ModelUtils.toStr(map['category'], 'Boshqa'),
      amount: ModelUtils.toDouble(map['amount']),
      note: ModelUtils.toStr(map['note']),
      fromDrawer: map['fromDrawer'] != false,
      createdAt: ModelUtils.date(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'category': category,
    'amount': amount,
    'note': note,
    'fromDrawer': fromDrawer,
  };

  ExpenseModel copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    String? note,
    bool? fromDrawer,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      fromDrawer: fromDrawer ?? this.fromDrawer,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    amount,
    note,
    fromDrawer,
    createdAt,
  ];
}
