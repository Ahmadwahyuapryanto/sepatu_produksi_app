import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getter agar UI dapat membaca variabel dengan aman tanpa bisa mengubahnya secara langsung
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Cek apakah pengguna sudah berhasil login
  bool get isAuthenticated => _currentUser != null;

  // Inisialisasi awal saat aplikasi dibuka untuk mengecek apakah ada sesi yang tersimpan
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      // Jika sesi Supabase masih ada di perangkat, langsung ambil data profilnya
      if (Supabase.instance.client.auth.currentUser != null) {
        _currentUser = await _authRepository.getCurrentUserData();
      }
    } catch (e) {
      _errorMessage = "Gagal memuat sesi pengguna: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  // Fungsi Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null; // Reset pesan error setiap kali mencoba login baru

    try {
      // 1. Melakukan autentikasi email & password ke Supabase
      await _authRepository.signIn(email, password);
      
      // 2. Mengambil data profil (termasuk Role) dari tb_users
      _currentUser = await _authRepository.getCurrentUserData();
      
      _setLoading(false);
      return true; // Mengembalikan nilai true jika login sukses
      
    } on AuthException catch (e) {
      // Menangkap error khusus dari Supabase Auth (misal: password salah)
      _errorMessage = e.message;
      _setLoading(false);
      return false; 
    } catch (e) {
      // Menangkap error sistem lainnya (misal: tidak ada koneksi internet)
      _errorMessage = "Terjadi kesalahan sistem: ${e.toString()}";
      _setLoading(false);
      return false; 
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.signOut();
      _currentUser = null; // Menghapus data pengguna dari memori aplikasi
    } catch (e) {
      _errorMessage = "Gagal logout: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  // Fungsi internal bantuan untuk memperbarui status loading dan merender ulang UI terkait
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}