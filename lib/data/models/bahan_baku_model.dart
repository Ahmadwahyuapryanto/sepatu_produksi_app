class BahanBakuModel {
  final int id;
  final String namaBahan;
  final String satuan;
  final double totalStok;

  BahanBakuModel({
    required this.id,
    required this.namaBahan,
    required this.satuan,
    this.totalStok = 0.0,
  });

  factory BahanBakuModel.fromJson(Map<String, dynamic> json) {
    return BahanBakuModel(
      id: json['id'] as int,
      namaBahan: json['nama_bahan'] as String,
      satuan: json['satuan'] as String,
      // Konversi num ke double untuk mengakomodasi nilai desimal dari NUMERIC PostgreSQL
      totalStok: (json['total_stok'] as num?)?.toDouble() ?? 0.0, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      'nama_bahan': namaBahan,
      'satuan': satuan,
      'total_stok': totalStok,
    };
  }
}