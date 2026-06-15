class SepatuModel {
  final int id;
  final String namaModel;
  final int stokBagus;
  final int stokReject;
  final DateTime? createdAt;

  SepatuModel({
    required this.id,
    required this.namaModel,
    this.stokBagus = 0,
    this.stokReject = 0,
    this.createdAt,
  });

  // Kategori diturunkan (computed) dari nama model menggunakan heuristik
  // sehingga tidak perlu menambah kolom baru di database
  String get kategori {
    final nama = namaModel.toLowerCase();
    if (nama.contains('running') ||
        nama.contains('sneaker') ||
        nama.contains('sport') ||
        nama.contains('olahrag')) {
      return 'Running';
    }
    if (nama.contains('formal') ||
        nama.contains('pantofel') ||
        nama.contains('kantor') ||
        nama.contains('business') ||
        nama.contains('dress')) {
      return 'Formal';
    }
    return 'Casual';
  }

  factory SepatuModel.fromJson(Map<String, dynamic> json) {
    return SepatuModel(
      id: json['id'] as int,
      namaModel: json['nama_model'] as String,
      stokBagus: json['stok_bagus'] as int? ?? 0,
      stokReject: json['stok_reject'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      'nama_model': namaModel,
      'stok_bagus': stokBagus,
      'stok_reject': stokReject,
    };
  }
}
