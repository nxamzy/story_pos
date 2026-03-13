class EmployeeModel {
  final String id;
  final String name;
  final String role;
  final String phone;
  final String imageUrl;
  final String lastCheckIn;
  final double salary; // Ishchi maoshi
  final int earlyLeaves;
  final int absents;
  final int presentDays;
  final int lateIns;
  final DateTime createdAt;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.imageUrl,
    this.lastCheckIn = "Not checked in",
    required this.salary,
    this.earlyLeaves = 0,
    this.absents = 0,
    this.presentDays = 0,
    this.lateIns = 0,
    required this.createdAt,
  });

  // --- Yangilash uchun (Edit) ---
  EmployeeModel copyWith({
    String? name,
    String? role,
    String? phone,
    String? imageUrl,
    double? salary,
    int? earlyLeaves,
    int? absents,
    int? presentDays,
    int? lateIns,
  }) {
    return EmployeeModel(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      lastCheckIn: lastCheckIn,
      salary: salary ?? this.salary,
      earlyLeaves: earlyLeaves ?? this.earlyLeaves,
      absents: absents ?? this.absents,
      presentDays: presentDays ?? this.presentDays,
      lateIns: lateIns ?? this.lateIns,
      createdAt: createdAt,
    );
  }

  // --- Firebase-ga yuborish uchun ---
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'phone': phone,
      'imageUrl': imageUrl,
      'lastCheckIn': lastCheckIn,
      'salary': salary,
      'earlyLeaves': earlyLeaves,
      'absents': absents,
      'presentDays': presentDays,
      'lateIns': lateIns,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // --- Firebase-dan o'qish uchun ---
  factory EmployeeModel.fromMap(Map<String, dynamic> map, String docId) {
    return EmployeeModel(
      id: docId,
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      phone: map['phone'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      lastCheckIn: map['lastCheckIn'] ?? 'Not checked in',
      salary: (map['salary'] ?? 0.0).toDouble(),
      earlyLeaves: map['earlyLeaves'] ?? 0,
      absents: map['absents'] ?? 0,
      presentDays: map['presentDays'] ?? 0,
      lateIns: map['lateIns'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
