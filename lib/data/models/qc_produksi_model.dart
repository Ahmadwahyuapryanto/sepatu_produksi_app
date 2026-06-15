class QcProduksiModel {
  final int? id;
  final int idSepatu;
  final String? idUser;
  final int jumlahBagus;
  final int jumlahReject;
  final DateTime? createdAt;

  QcProduksiModel({
    this.id,
    required this.idSepatu,
    this.idUser,
    required this.jumlahBagus,
    required this.jumlahReject,
    this.createdAt,
  });

  factory QcProduksiModel.fromJson(Map<String, dynamic> json) {
    return QcProduksiModel(
      id: json['id'] as int?,
      idSepatu: json['id_sepatu'] as int,
      idUser: json['id_user'] as String?,
      jumlahBagus: json['jumlah_bagus'] as int,
      jumlahReject: json['jumlah_reject'] as int,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sepatu': idSepatu,
      'id_user': idUser,
      'jumlah_bagus': jumlahBagus,
      'jumlah_reject': jumlahReject,
    };
  }
}