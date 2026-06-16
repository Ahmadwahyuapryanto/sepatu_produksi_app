import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'core/constants/api_constants.dart';
import 'core/theme/app_theme.dart';
import 'logic/auth_provider.dart';
import 'logic/admin_provider.dart';
import 'logic/worker_provider.dart';
import 'logic/theme_provider.dart';
import 'ui/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env dengan fallback - tidak crash jika .env gagal di-load
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env gagal dimuat, ApiConstants akan menggunakan fallback values
    debugPrint('Warning: .env file failed to load: $e');
  }

  // Inisialisasi locale Indonesia untuk intl (date formatting)
  await initializeDateFormatting('id_ID', null);
  // Set locale default ke id_ID
  Intl.defaultLocale = 'id_ID';

  await Supabase.initialize(
    url: ApiConstants.supabaseUrl,
    anonKey: ApiConstants.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Sistem Informasi Produksi Sepatu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}