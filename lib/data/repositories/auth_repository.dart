import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseService _supabaseService = SupabaseService();

  // Login menggunakan Supabase Auth
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabaseService.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Logout akun
  Future<void> signOut() async {
    await _supabaseService.client.auth.signOut();
  }

  // Mengambil data profil dari tb_users berdasarkan ID Auth Supabase
  Future<UserModel?> getCurrentUserData() async {
    final user = _supabaseService.client.auth.currentUser;
    if (user == null) return null;

    // Menggunakan .maybeSingle() agar lebih AMAN. 
    // Jika data tidak ada, ia akan mengembalikan null, bukan membuat aplikasi crash.
    final response = await _supabaseService.client
        .from('tb_users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      throw const AuthException('Data profil Anda belum didaftarkan oleh Admin ke dalam sistem (tb_users kosong).');
    }

    return UserModel.fromJson(response);
  }
}