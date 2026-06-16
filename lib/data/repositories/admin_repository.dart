import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/api_constants.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../models/sepatu_model.dart';
import '../models/tahapan_model.dart';
import '../models/progres_produksi_model.dart';

class AdminRepository {
  final SupabaseService _supabaseService = SupabaseService();

  // ======================= MANAJEMEN PEGAWAI =======================
  Future<List<UserModel>> getDaftarPegawai() async {
    final response = await _supabaseService.client
        .from('tb_users')
        .select()
        .inFilter('role', ['PEKERJA', 'GUDANG']) 
        .order('role', ascending: true);
    return (response as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<String?> daftarkanAuthBaru(String email, String password) async {
    final tempClient = SupabaseClient(
      ApiConstants.supabaseUrl, 
      ApiConstants.supabaseAnonKey,
      authOptions: const AuthClientOptions(
        authFlowType: AuthFlowType.implicit, 
      ),
    );
    final response = await tempClient.auth.signUp(email: email, password: password);
    return response.user?.id; 
  }

  Future<void> insertProfilPegawai(UserModel pegawai) async {
    await _supabaseService.client.from('tb_users').insert(pegawai.toJson());
  }

  Future<void> updateProfilPegawai(UserModel pegawai) async {
    await _supabaseService.client
        .from('tb_users')
        .update({
          'nama_lengkap': pegawai.namaLengkap,
          'role': pegawai.role,
          'no_hp': pegawai.noHp,
        })
        .eq('id', pegawai.id);
  }

  Future<void> hapusProfilPegawai(String id) async {
    await _supabaseService.client.from('tb_users').delete().eq('id', id);
  }

  // ======================= KATALOG SEPATU =======================
  Future<List<SepatuModel>> getLaporanProduksi() async {
    final response = await _supabaseService.client
        .from('tb_master_sepatu')
        .select()
        .order('id', ascending: true);
    return (response as List).map((e) => SepatuModel.fromJson(e)).toList();
  }

  Future<void> insertSepatu(SepatuModel sepatu) async {
    await _supabaseService.client.from('tb_master_sepatu').insert(sepatu.toJson());
  }

  Future<void> updateSepatu(SepatuModel sepatu) async {
    await _supabaseService.client
        .from('tb_master_sepatu')
        .update({
          'nama_model': sepatu.namaModel,
          'kategori': sepatu.kategori,
        })
        .eq('id', sepatu.id);
  }

  Future<void> hapusSepatu(int id) async {
    await _supabaseService.client.from('tb_master_sepatu').delete().eq('id', id);
  }

  // ======================= TAHAPAN & TARIF UPAH =======================
  Future<List<TahapanModel>> getDaftarTahapan() async {
    final response = await _supabaseService.client
        .from('tb_master_tahapan')
        .select()
        .order('id', ascending: true);
    return (response as List).map((e) => TahapanModel.fromJson(e)).toList();
  }

  Future<void> insertTahapan(TahapanModel tahapan) async {
    await _supabaseService.client.from('tb_master_tahapan').insert(tahapan.toJson());
  }

  Future<void> updateTahapan(TahapanModel tahapan) async {
    await _supabaseService.client
        .from('tb_master_tahapan')
        .update({
          'nama_tahapan': tahapan.namaTahapan,
          'tarif_upah': tahapan.tarifUpah,
        })
        .eq('id', tahapan.id);
  }

  Future<void> hapusTahapan(int id) async {
    await _supabaseService.client.from('tb_master_tahapan').delete().eq('id', id);
  }

  // ======================= PAYROLL / GAJI PEKERJA =======================
  Future<List<Map<String, dynamic>>> getRekapGajiPekerja() async {
    final response = await _supabaseService.client
        .from('tb_progres_produksi')
        .select('''
          id,
          id_pekerja,
          jumlah_selesai,
          status_bayar,
          created_at,
          tb_users!inner ( nama_lengkap, role ),
          tb_master_tahapan!inner ( nama_tahapan, tarif_upah )
        ''')
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<void> tandaiSudahBayar(List<int> idsProgres) async {
    if (idsProgres.isEmpty) return;
    await _supabaseService.client
        .from('tb_progres_produksi')
        .update({'status_bayar': true})
        .inFilter('id', idsProgres);
  }

  Future<List<ProgresProduksiModel>> getProgresByPekerja(String userId) async {
    final response = await _supabaseService.client
        .from('tb_progres_produksi')
        .select()
        .eq('id_pekerja', userId)
        .eq('status_bayar', false)
        .order('created_at', ascending: false);
    return (response as List).map((e) => ProgresProduksiModel.fromJson(e)).toList();
  }

  // ======================= LAPORAN =======================
  // Laporan produksi per model (harian/mingguan/bulanan) + user info
  Future<List<Map<String, dynamic>>> getLaporanProduksiByPeriode(
    DateTime start, 
    DateTime end,
  ) async {
    final response = await _supabaseService.client
        .from('tb_qc_produksi')
        .select('''
          id,
          jumlah_bagus,
          jumlah_reject,
          created_at,
          tb_master_sepatu!inner ( nama_model ),
          tb_users!inner ( nama_lengkap )
        ''')
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String())
        .order('created_at', ascending: false);
    return (response as List).cast<Map<String, dynamic>>();
  }

  // Laporan pergerakan bahan baku + user info
  // Laporan progres pekerjaan per tahapan (filter by id_tahapan)
  Future<List<Map<String, dynamic>>> getLaporanPekerjaanByPeriode(
    DateTime start,
    DateTime end,
  ) async {
    final response = await _supabaseService.client
        .from('tb_progres_produksi')
        .select('''
          id,
          id_pekerja,
          jumlah_selesai,
          created_at,
          tb_users!inner ( nama_lengkap ),
          tb_master_tahapan!inner ( nama_tahapan, tarif_upah )
        ''')
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String())
        .order('created_at', ascending: false)
        .limit(500);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getLaporanPekerjaanByPeriodeDanTahapan(
    DateTime start,
    DateTime end,
    int idTahapan,
  ) async {
    final response = await _supabaseService.client
        .from('tb_progres_produksi')
        .select('''
          id,
          id_pekerja,
          jumlah_selesai,
          created_at,
          tb_users!inner ( nama_lengkap ),
          tb_master_tahapan!inner ( nama_tahapan, tarif_upah )
        ''')
        .eq('id_tahapan', idTahapan)
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String())
        .order('created_at', ascending: false)
        .limit(500);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getLaporanLogBahan(
    DateTime start, 
    DateTime end,
  ) async {
    final response = await _supabaseService.client
        .from('tb_log_bahan')
        .select('''
          id,
          tipe_transaksi,
          jumlah,
          keterangan,
          created_at,
          tb_bahan_baku!inner ( nama_bahan, satuan ),
          tb_users!inner ( nama_lengkap )
        ''')
        .gte('created_at', start.toIso8601String())
        .lte('created_at', end.toIso8601String())
        .order('created_at', ascending: false)
        .limit(500);
    return (response as List).cast<Map<String, dynamic>>();
  }
}