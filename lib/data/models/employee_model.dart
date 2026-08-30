import 'package:equatable/equatable.dart';
import 'package:ocam_pos/data/models/model_utils.dart';

class EmployeeModel extends Equatable {
  final String id;
  final String name;
  final String role;
  final String phone;
  final String imageUrl;
  final String lastCheckIn;
  final double salary;
  final double balance;
  final int earlyLeaves;
  final int absents;
  final int presentDays;
  final int lateIns;
  final DateTime createdAt;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    this.imageUrl = '',
    this.lastCheckIn = "Kelmagan",
    this.salary = 0,
    this.balance = 0,
    this.earlyLeaves = 0,
    this.absents = 0,
    this.presentDays = 0,
    this.lateIns = 0,
    required this.createdAt,
  });

  factory EmployeeModel.fromMap(Map<String, dynamic> map, String docId) {
    return EmployeeModel(
      id: docId,
      name: ModelUtils.toStr(map['name']),
      role: ModelUtils.toStr(map['role']),
      phone: ModelUtils.toStr(map['phone']),
      imageUrl: ModelUtils.toStr(map['imageUrl']),
      lastCheckIn: ModelUtils.toStr(map['lastCheckIn'], 'Kelmagan'),
      salary: ModelUtils.toDouble(map['salary']),
      balance: ModelUtils.toDouble(map['balance']),
      earlyLeaves: ModelUtils.toInt(map['earlyLeaves']),
      absents: ModelUtils.toInt(map['absents']),
      presentDays: ModelUtils.toInt(map['presentDays']),
      lateIns: ModelUtils.toInt(map['lateIns']),
      createdAt: ModelUtils.date(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'phone': phone,
      'imageUrl': imageUrl,
      'lastCheckIn': lastCheckIn,
      'salary': salary,
      'balance': balance,
      'earlyLeaves': earlyLeaves,
      'absents': absents,
      'presentDays': presentDays,
      'lateIns': lateIns,
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? role,
    String? phone,
    String? imageUrl,
    String? lastCheckIn,
    double? salary,
    double? balance,
    int? earlyLeaves,
    int? absents,
    int? presentDays,
    int? lateIns,
    DateTime? createdAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      salary: salary ?? this.salary,
      balance: balance ?? this.balance,
      earlyLeaves: earlyLeaves ?? this.earlyLeaves,
      absents: absents ?? this.absents,
      presentDays: presentDays ?? this.presentDays,
      lateIns: lateIns ?? this.lateIns,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    role,
    phone,
    imageUrl,
    salary,
    balance,
    presentDays,
    absents,
    lateIns,
    earlyLeaves,
  ];
}
