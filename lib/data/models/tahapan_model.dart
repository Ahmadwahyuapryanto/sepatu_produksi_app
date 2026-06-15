class TahapanModel {
  final int id;
  final String namaTahapan;
  final int tarifUpah;

  TahapanModel({
    required this.id,
    required this.namaTahapan,
    required this.tarifUpah,
  });

  factory TahapanModel.fromJson(Map<String, dynamic> json) {
    return TahapanModel(
      id: json['id'] as int,
      namaTahapan: json['nama_tahapan'] as String,
      tarifUpah: json['tarif_upah'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      'nama_tahapan': namaTahapan,
      'tarif_upah': tarifUpah,
    };
  }
}