class ProgresProduksiModel {
  final int? id;
  final String idPekerja;
  final int idSepatu;
  final int idTahapan;
  final int jumlahSelesai;
  final bool statusBayar;
  final DateTime? createdAt;

  ProgresProduksiModel({
    this.id,
    required this.idPekerja,
    required this.idSepatu,
    required this.idTahapan,
    required this.jumlahSelesai,
    this.statusBayar = false,
    this.createdAt,
  });

  factory ProgresProduksiModel.fromJson(Map<String, dynamic> json) {
    return ProgresProduksiModel(
      id: json['id'] as int?,
      idPekerja: json['id_pekerja'] as String,
      idSepatu: json['id_sepatu'] as int,
      idTahapan: json['id_tahapan'] as int,
      jumlahSelesai: json['jumlah_selesai'] as int,
      statusBayar: json['status_bayar'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pekerja': idPekerja,
      'id_sepatu': idSepatu,
      'id_tahapan': idTahapan,
      'jumlah_selesai': jumlahSelesai,
      'status_bayar': statusBayar,
    };
  }
}