import '../services/supabase_service.dart';
import '../models/sepatu_model.dart';
import '../models/tahapan_model.dart';
import '../models/progres_produksi_model.dart';

class WorkerRepository {
  final SupabaseService _supabaseService = SupabaseService();

  // Mengambil daftar sepatu untuk pilihan dropdown di form input progres
  Future<List<SepatuModel>> getDaftarSepatu() async {
    final response = await _supabaseService.client
        .from('tb_master_sepatu')
        .select();
    return (response as List).map((e) => SepatuModel.fromJson(e)).toList();
  }

  // Mengambil daftar tahapan untuk form input progres
  Future<List<TahapanModel>> getDaftarTahapan() async {
    final response = await _supabaseService.client
        .from('tb_master_tahapan')
        .select();
    return (response as List).map((e) => TahapanModel.fromJson(e)).toList();
  }

  // Mengirim hasil kerja pekerja ke database
  Future<void> insertProgres(ProgresProduksiModel progres) async {
    await _supabaseService.client
        .from('tb_progres_produksi')
        .insert(progres.toJson());
  }
  
  // Mengambil riwayat progres pekerja (dioptimasi dengan limit 50 data terbaru)
  Future<List<ProgresProduksiModel>> getRiwayatProgres(String userId) async {
    final response = await _supabaseService.client
        .from('tb_progres_produksi')
        .select()
        .eq('id_pekerja', userId)
        .order('created_at', ascending: false)
        .limit(50); 
    return (response as List).map((e) => ProgresProduksiModel.fromJson(e)).toList();
  }
}