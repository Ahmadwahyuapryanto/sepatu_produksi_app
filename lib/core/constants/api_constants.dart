import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Mengambil URL Supabase dari environment variable secara aman
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  
  // Mengambil Anon Key Supabase dari environment variable secara aman
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}