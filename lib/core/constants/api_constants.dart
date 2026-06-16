import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Fallback values untuk memastikan aplikasi selalu bisa terhubung ke Supabase
  // meskipun file .env gagal di-load di release build
  static const String _fallbackSupabaseUrl = 'https://atrbkrfgyztzaxcckgtw.supabase.co';
  static const String _fallbackSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF0cmJrcmZneXp0emF4Y2NrZ3R3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzMDMwNjQsImV4cCI6MjA5NTg3OTA2NH0.d53L0RRm6IvhE4hppOH_lV8OdnJnjHzy2_NnY456qYo';

  // Mengambil URL Supabase - gunakan .env jika tersedia, fallback ke hardcoded
  static String get supabaseUrl {
    try {
      final envUrl = dotenv.env['SUPABASE_URL'];
      if (envUrl != null && envUrl.isNotEmpty) return envUrl;
    } catch (_) {}
    return _fallbackSupabaseUrl;
  }
  
  // Mengambil Anon Key Supabase - gunakan .env jika tersedia, fallback ke hardcoded
  static String get supabaseAnonKey {
    try {
      final envKey = dotenv.env['SUPABASE_ANON_KEY'];
      if (envKey != null && envKey.isNotEmpty) return envKey;
    } catch (_) {}
    return _fallbackSupabaseAnonKey;
  }
}
