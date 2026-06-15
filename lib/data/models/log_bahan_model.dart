class LogBahanModel {
  final int? id;
  final int idBahan;
  final String? idUser;
  final String tipeTransaksi;
  final double jumlah;
  final String? keterangan;
  final DateTime? createdAt;

  LogBahanModel({
    this.id,
    required this.idBahan,
    this.idUser,
    required this.tipeTransaksi,
    required this.jumlah,
    this.keterangan,
    this.createdAt,
  });

  factory LogBahanModel.fromJson(Map<String, dynamic> json) {
    return LogBahanModel(
      id: json['id'] as int?,
      idBahan: json['id_bahan'] as int,
      idUser: json['id_user'] as String?,
      tipeTransaksi: json['tipe_transaksi'] as String,
      jumlah: (json['jumlah'] as num).toDouble(),
      keterangan: json['keterangan'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_bahan': idBahan,
      'id_user': idUser,
      'tipe_transaksi': tipeTransaksi,
      'jumlah': jumlah,
      if (keterangan != null) 'keterangan': keterangan,
    };
  }
}