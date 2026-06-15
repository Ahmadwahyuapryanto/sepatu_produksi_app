import 'package:flutter/material.dart';
import '../data/repositories/worker_repository.dart';
import '../data/models/sepatu_model.dart';
import '../data/models/tahapan_model.dart';
import '../data/models/progres_produksi_model.dart';

class WorkerProvider extends ChangeNotifier {
  final WorkerRepository _workerRepository = WorkerRepository();

  bool _isLoading = false;
  String? _errorMessage;

  List<SepatuModel> _daftarSepatu = [];
  List<TahapanModel> _daftarTahapan = [];
  List<ProgresProduksiModel> _riwayatProgres = [];

  // Getter
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SepatuModel> get daftarSepatu => _daftarSepatu;
  List<TahapanModel> get daftarTahapan => _daftarTahapan;
  List<ProgresProduksiModel> get riwayatProgres => _riwayatProgres;

  // Memuat data dropdown (Sepatu dan Tahapan) untuk formulir input
  Future<void> fetchDropdownData() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _daftarSepatu = await _workerRepository.getDaftarSepatu();
      _daftarTahapan = await _workerRepository.getDaftarTahapan();
    } catch (e) {
      _errorMessage = "Gagal memuat data pilihan: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  // Memuat riwayat progres pekerja berdasarkan ID mereka
  Future<void> fetchRiwayatProgres(String userId) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _riwayatProgres = await _workerRepository.getRiwayatProgres(userId);
    } catch (e) {
      _errorMessage = "Gagal memuat riwayat: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  // Menyimpan input progres baru ke database
  Future<bool> submitProgres(ProgresProduksiModel progres) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _workerRepository.insertProgres(progres);
      // Refresh riwayat setelah berhasil menyimpan data baru
      await fetchRiwayatProgres(progres.idPekerja);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = "Gagal menyimpan progres: ${e.toString()}";
      _setLoading(false);
      return false;
    }
  }

  // Fungsi internal untuk mengelola state loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}