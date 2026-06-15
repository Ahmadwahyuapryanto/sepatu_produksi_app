import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Menyediakan instance SupabaseClient yang bisa dipanggil oleh semua repository
  final SupabaseClient client = Supabase.instance.client;
}