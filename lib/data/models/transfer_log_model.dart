import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/model_utils.dart';

/// Kassa (drawer) va xodimlar o'rtasidagi pul o'tkazmasi tarixi.
class TransferLogModel extends Equatable {
  final String id;
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final double amount;
  final String note;
  final DateTime createdAt;

  const TransferLogModel({
    required this.id,
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.amount,
    this.note = '',
    required this.createdAt,
  });

  factory TransferLogModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransferLogModel(
      id: docId,
      fromId: ModelUtils.toStr(map['from_id']),
      fromName: ModelUtils.toStr(map['from_name']),
      toId: ModelUtils.toStr(map['to_id']),
      toName: ModelUtils.toStr(map['to_name']),
      amount: ModelUtils.toDouble(map['amount']),
      note: ModelUtils.toStr(map['note']),
      createdAt: ModelUtils.date(map['timestamp'] ?? map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'from_id': fromId,
    'from_name': fromName,
    'to_id': toId,
    'to_name': toName,
    'amount': amount,
    'note': note,
  };

  @override
  List<Object?> get props => [id, fromId, toId, amount, createdAt];
}
