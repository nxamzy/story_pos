import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/employee_model.dart';

/// Pul o'tkazmasining tarafi: kassaning o'zi yoki bitta xodim.
///
/// Ilgari o'tkazma faqat ikki xodim orasida bo'lardi — kassadagi pul esa
/// naqd savdolardan doim ko'payib borib, hech qachon kamaymasdi (ya'ni
/// kassadan pul berishni yozib qo'yishning iloji yo'q edi). Shu model ikkala
/// tarafni bir xil ko'rinishga keltiradi.
class TransferParty extends Equatable {
  /// Kassa hujjati (`pos_settings/drawer_info`) uchun maxsus id.
  /// Xodim hujjati id'si bilan to'qnashmaydi.
  static const String drawerId = 'drawer';

  final String id;
  final String name;
  final double balance;

  const TransferParty({
    required this.id,
    required this.name,
    required this.balance,
  });

  bool get isDrawer => id == drawerId;

  factory TransferParty.drawer(double balance) =>
      TransferParty(id: drawerId, name: 'Kassa', balance: balance);

  factory TransferParty.fromEmployee(EmployeeModel employee) => TransferParty(
    id: employee.id,
    name: employee.name,
    balance: employee.balance,
  );

  @override
  List<Object?> get props => [id, name, balance];
}
