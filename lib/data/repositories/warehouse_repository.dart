import '../services/supabase_service.dart';
import '../models/bahan_baku_model.dart';
import '../models/log_bahan_model.dart';
import '../models/qc_produksi_model.dart';
import '../models/sepatu_model.dart';

/// Model tambahan untuk riwayat barang yang sudah join dengan nama bahan/sepatu
class LogBahanDetail {
  final LogBahanModel log;
  final String namaBahan;
  final String satuan;

  LogBahanDetail({required this.log, required this.namaBahan, required this.satuan});
}

class QcProduksiDetail {
  final QcProduksiModel qc;
  final String namaModel;

  QcProduksiDetail({required this.qc, required this.namaModel});
}

class WarehouseRepository {
  final SupabaseService _supabaseService = SupabaseService();

  // Mengambil stok bahan baku saat ini
  Future<List<BahanBakuModel>> getDaftarBahanBaku() async {
    final response = await _supabaseService.client
        .from('tb_bahan_baku')
        .select()
        .order('nama_bahan', ascending: true);
    return (response as List).map((e) => BahanBakuModel.fromJson(e)).toList();
  }

  // Menambahkan jenis bahan baku baru
  Future<BahanBakuModel> tambahBahanBaku(String namaBahan, String satuan) async {
    final response = await _supabaseService.client
        .from('tb_bahan_baku')
        .insert({
          'nama_bahan': namaBahan,
          'satuan': satuan,
          'total_stok': 0,
        })
        .select()
        .single();
    return BahanBakuModel.fromJson(response);
  }

  // Mengupdate jenis bahan baku
  Future<void> updateBahanBaku(BahanBakuModel bahan) async {
    await _supabaseService.client
        .from('tb_bahan_baku')
        .update({
          'nama_bahan': bahan.namaBahan,
          'satuan': bahan.satuan,
        })
        .eq('id', bahan.id);
  }

  // Menghapus jenis bahan baku
  Future<void> hapusBahanBaku(int id) async {
    await _supabaseService.client
        .from('tb_bahan_baku')
        .delete()
        .eq('id', id);
  }

  // Mencatat transaksi bahan masuk/keluar (otomatis trigger stok di Supabase)
  Future<void> insertLogBahan(LogBahanModel logBahan) async {
    await _supabaseService.client
        .from('tb_log_bahan')
        .insert(logBahan.toJson());
  }

  // Mengambil daftar sepatu untuk keperluan QC
  Future<List<SepatuModel>> getDaftarSepatu() async {
    final response = await _supabaseService.client
        .from('tb_master_sepatu')
        .select();
    return (response as List).map((e) => SepatuModel.fromJson(e)).toList();
  }

  // Mencatat sepatu bagus dan reject hasil QC (otomatis trigger stok di Supabase)
  Future<void> insertQcProduksi(QcProduksiModel qcProduksi) async {
    await _supabaseService.client
        .from('tb_qc_produksi')
        .insert(qcProduksi.toJson());
  }

  // ==================== RIWAYAT BARANG ====================

  /// Mengambil riwayat log bahan masuk/keluar (dengan join nama bahan)
  Future<List<LogBahanDetail>> getRiwayatLogBahan({int limit = 100, int offset = 0}) async {
    final response = await _supabaseService.client
        .from('tb_log_bahan')
        .select('*, tb_bahan_baku(nama_bahan, satuan)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return (response as List).map((e) {
      final bahan = e['tb_bahan_baku'] ?? {};
      return LogBahanDetail(
        log: LogBahanModel.fromJson(e),
        namaBahan: bahan['nama_bahan'] ?? '-',
        satuan: bahan['satuan'] ?? '',
      );
    }).toList();
  }

  /// Mengambil riwayat log bahan berdasarkan tipe transaksi (MASUK/KELUAR)
  Future<List<LogBahanDetail>> getRiwayatLogBahanByTipe(String tipe, {int limit = 100, int offset = 0}) async {
    final response = await _supabaseService.client
        .from('tb_log_bahan')
        .select('*, tb_bahan_baku(nama_bahan, satuan)')
        .eq('tipe_transaksi', tipe)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return (response as List).map((e) {
      final bahan = e['tb_bahan_baku'] ?? {};
      return LogBahanDetail(
        log: LogBahanModel.fromJson(e),
        namaBahan: bahan['nama_bahan'] ?? '-',
        satuan: bahan['satuan'] ?? '',
      );
    }).toList();
  }

  /// Mengambil riwayat QC produksi (dengan join nama sepatu)
  Future<List<QcProduksiDetail>> getRiwayatQcProduksi({int limit = 100, int offset = 0}) async {
    final response = await _supabaseService.client
        .from('tb_qc_produksi')
        .select('*, tb_master_sepatu(nama_model)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return (response as List).map((e) {
      final sepatu = e['tb_master_sepatu'] ?? {};
      return QcProduksiDetail(
        qc: QcProduksiModel.fromJson(e),
        namaModel: sepatu['nama_model'] ?? '-',
      );
    }).toList();
  }
}
