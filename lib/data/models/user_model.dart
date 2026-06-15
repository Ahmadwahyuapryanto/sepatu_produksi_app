class UserModel {
  final String id;
  final String namaLengkap;
  final String role;
  final String? noHp;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.namaLengkap,
    required this.role,
    this.noHp,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      namaLengkap: json['nama_lengkap'] as String,
      role: json['role'] as String,
      noHp: json['no_hp'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'role': role,
      'no_hp': noHp,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}