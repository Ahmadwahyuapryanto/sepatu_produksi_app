import 'package:flutter/material.dart';
import '../data/repositories/admin_repository.dart';
import '../data/models/user_model.dart';
import '../data/models/sepatu_model.dart';
import '../data/models/tahapan_model.dart';
import '../data/models/progres_produksi_model.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _adminRepository = AdminRepository();

  bool _isLoading = false;
  String? _errorMessage;

  // Master data
  List<UserModel> _daftarPegawai = []; 
  List<SepatuModel> _laporanProduksi = [];
  List<TahapanModel> _daftarTahapan = [];
  
  // Data payroll (mentahan dari database join)
  List<Map<String, dynamic>> _rawRekapGaji = [];

  // Getter
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UserModel> get daftarPegawai => _daftarPegawai;
  List<SepatuModel> get laporanProduksi => _laporanProduksi;
  List<TahapanModel> get daftarTahapan => _daftarTahapan;
  List<Map<String, dynamic>> get rawRekapGaji => _rawRekapGaji;

  // =================== DASHBOARD & MASTER DATA ===================
  Future<void> fetchLaporanProduksi() async {
    _setLoading(true);
    try {
      _laporanProduksi = await _adminRepository.getLaporanProduksi();
    } catch (e) {
      _errorMessage = "Gagal memuat laporan produksi: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchDaftarPegawai() async {
    _setLoading(true);
    try {
      _daftarPegawai = await _adminRepository.getDaftarPegawai();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Gagal memuat daftar pegawai: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> tambahPegawai(String email, String password, String nama, String role, String noHp) async {
    _setLoading(true);
    try {
      final newUserId = await _adminRepository.daftarkanAuthBaru(email, password);
      
      if (newUserId != null) {
        final profilBaru = UserModel(id: newUserId, namaLengkap: nama, role: role, noHp: noHp);
        await _adminRepository.insertProfilPegawai(profilBaru);
        await fetchDaftarPegawai(); 
        return true;
      }
      _errorMessage = "Gagal membuat autentikasi pekerja.";
      return false;
    } catch (e) {
      _errorMessage = "Gagal menambahkan pekerja: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePegawai(UserModel pegawai) async {
    _setLoading(true);
    try {
      await _adminRepository.updateProfilPegawai(pegawai);
      await fetchDaftarPegawai(); 
      return true;
    } catch (e) {
      _errorMessage = "Gagal mengubah data: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> hapusPegawai(String id) async {
    _setLoading(true);
    try {
      await _adminRepository.hapusProfilPegawai(id);
      await fetchDaftarPegawai(); 
      return true;
    } catch (e) {
      _errorMessage = "Gagal menghapus data: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =================== KATALOG SEPATU ===================
  Future<bool> tambahModelSepatu(String namaModel) async {
    _setLoading(true);
    try {
      final sepatuBaru = SepatuModel(id: 0, namaModel: namaModel);
      await _adminRepository.insertSepatu(sepatuBaru);
      await fetchLaporanProduksi(); 
      return true;
    } catch (e) {
      _errorMessage = "Gagal menambahkan sepatu: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateModelSepatu(SepatuModel sepatu) async {
    _setLoading(true);
    try {
      await _adminRepository.updateSepatu(sepatu);
      await fetchLaporanProduksi();
      return true;
    } catch (e) {
      _errorMessage = "Gagal mengubah model sepatu: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> hapusModelSepatu(int id) async {
    _setLoading(true);
    try {
      await _adminRepository.hapusSepatu(id);
      await fetchLaporanProduksi();
      return true;
    } catch (e) {
      _errorMessage = "Gagal menghapus model sepatu: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =================== TAHAPAN & TARIF UPAH ===================
  Future<void> fetchDaftarTahapan() async {
    _setLoading(true);
    try {
      _daftarTahapan = await _adminRepository.getDaftarTahapan();
    } catch (e) {
      _errorMessage = "Gagal memuat daftar tahapan: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> tambahTahapan(String nama, int tarif) async {
    _setLoading(true);
    try {
      final tahapan = TahapanModel(id: 0, namaTahapan: nama, tarifUpah: tarif);
      await _adminRepository.insertTahapan(tahapan);
      await fetchDaftarTahapan();
      return true;
    } catch (e) {
      _errorMessage = "Gagal menambahkan tahapan: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTahapan(TahapanModel tahapan) async {
    _setLoading(true);
    try {
      await _adminRepository.updateTahapan(tahapan);
      await fetchDaftarTahapan();
      return true;
    } catch (e) {
      _errorMessage = "Gagal mengubah tahapan: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> hapusTahapan(int id) async {
    _setLoading(true);
    try {
      await _adminRepository.hapusTahapan(id);
      await fetchDaftarTahapan();
      return true;
    } catch (e) {
      _errorMessage = "Gagal menghapus tahapan: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =================== PAYROLL / GAJI PEKERJA ===================
  // Mengambil data progres (mentah, join dengan user & tahapan)
  Future<void> fetchRekapGaji() async {
    _setLoading(true);
    try {
      _rawRekapGaji = await _adminRepository.getRekapGajiPekerja();
    } catch (e) {
      _errorMessage = "Gagal memuat rekap gaji: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  // Mengelompokkan progres menjadi per pekerja
  // Return: List of { idPekerja, namaPekerja, totalGaji, listProgres (id progres) }
  List<Map<String, dynamic>> getRekapGajiPerPekerja({bool hanyaBelumBayar = true}) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (final row in _rawRekapGaji) {
      // Filter: hanya progres yang belum dibayar
      final bool isPaid = row['status_bayar'] == true;
      if (hanyaBelumBayar && isPaid) continue;

      final String idPekerja = row['id_pekerja'] as String;
      // nama_lengkap ada di dalam object 'tb_users'
      final String nama = (row['tb_users']?['nama_lengkap']) ?? 'Tanpa Nama';
      final int jumlah = (row['jumlah_selesai'] as int?) ?? 0;
      // tarif_upah ada di dalam object 'tb_master_tahapan'
      final int tarif = (row['tb_master_tahapan']?['tarif_upah'] as int?) ?? 0;
      final int idProgres = row['id'] as int;

      final int subTotal = jumlah * tarif;

      if (!grouped.containsKey(idPekerja)) {
        grouped[idPekerja] = {
          'idPekerja': idPekerja,
          'namaPekerja': nama,
          'totalGaji': 0,
          'totalPasang': 0,
          'listIdProgres': <int>[],
          'listDetail': <Map<String, dynamic>>[],
        };
      }

      final group = grouped[idPekerja]!;
      group['totalGaji'] = (group['totalGaji'] as int) + subTotal;
      group['totalPasang'] = (group['totalPasang'] as int) + jumlah;
      (group['listIdProgres'] as List<int>).add(idProgres);
      (group['listDetail'] as List).add({
        'id': idProgres,
        'tanggal': row['created_at'],
        'tahapan': row['tb_master_tahapan']?['nama_tahapan'] ?? '-',
        'jumlah': jumlah,
        'tarif': tarif,
        'subtotal': subTotal,
      });
    }

    // Urutkan dari nominal gaji terbesar
    final list = grouped.values.toList();
    list.sort((a, b) => (b['totalGaji'] as int).compareTo(a['totalGaji'] as int));
    return list;
  }

  // Total gaji seluruh pekerja yang belum dibayar
  int get totalGajiBelumDibayar {
    int total = 0;
    for (final p in getRekapGajiPerPekerja()) {
      total += (p['totalGaji'] as int);
    }
    return total;
  }

  // Konfirmasi pembayaran untuk satu pekerja
  Future<bool> konfirmasiPembayaran(String idPekerja) async {
    _setLoading(true);
    try {
      // Ambil ulang data untuk pastikan ID progres yang akan dibayar
      final List<ProgresProduksiModel> progres = 
          await _adminRepository.getProgresByPekerja(idPekerja);
      
      final List<int> ids = progres.map((p) => p.id!).toList();
      await _adminRepository.tandaiSudahBayar(ids);
      
      // Refresh data
      await fetchRekapGaji();
      return true;
    } catch (e) {
      _errorMessage = "Gagal konfirmasi pembayaran: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Konfirmasi pembayaran untuk SEMUA pekerja
  Future<bool> konfirmasiSemuaPembayaran() async {
    _setLoading(true);
    try {
      final List<int> semuaId = _rawRekapGaji
          .where((r) => r['status_bayar'] != true)
          .map<int>((r) => r['id'] as int)
          .toList();
      await _adminRepository.tandaiSudahBayar(semuaId);
      await fetchRekapGaji();
      return true;
    } catch (e) {
      _errorMessage = "Gagal membayar semua: ${e.toString()}";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =================== LAPORAN ===================
  Future<List<Map<String, dynamic>>> fetchLaporanProduksiByPeriode(
    DateTime start, 
    DateTime end,
  ) async {
    _setLoading(true);
    try {
      return await _adminRepository.getLaporanProduksiByPeriode(start, end);
    } catch (e) {
      _errorMessage = "Gagal memuat laporan produksi: ${e.toString()}";
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Laporan pekerjaan per tahapan
  Future<List<Map<String, dynamic>>> fetchLaporanPekerjaanByPeriode(
    DateTime start,
    DateTime end,
  ) async {
    _setLoading(true);
    try {
      return await _adminRepository.getLaporanPekerjaanByPeriode(start, end);
    } catch (e) {
      _errorMessage = "Gagal memuat laporan pekerjaan: ${e.toString()}";
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Map<String, dynamic>>> fetchLaporanPekerjaanByTahapan(
    DateTime start,
    DateTime end,
    int idTahapan,
  ) async {
    _setLoading(true);
    try {
      return await _adminRepository.getLaporanPekerjaanByPeriodeDanTahapan(start, end, idTahapan);
    } catch (e) {
      _errorMessage = "Gagal memuat laporan pekerjaan: ${e.toString()}";
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<List<Map<String, dynamic>>> fetchLaporanLogBahan(
    DateTime start, 
    DateTime end,
  ) async {
    _setLoading(true);
    try {
      return await _adminRepository.getLaporanLogBahan(start, end);
    } catch (e) {
      _errorMessage = "Gagal memuat laporan bahan: ${e.toString()}";
      return [];
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
