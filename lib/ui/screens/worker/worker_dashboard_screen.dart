import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/theme_provider.dart';
import '../../../logic/worker_provider.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../login_screen.dart';
import 'input_progres_screen.dart';
import 'riwayat_progres_screen.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _muatDataAwal();
    });
  }

  Future<void> _muatDataAwal() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      final provider = context.read<WorkerProvider>();
      await provider.fetchDropdownData();
      await provider.fetchRiwayatProgres(userId);
    }
  }

  Future<void> _prosesLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = WorkerColors(context);

    final List<Widget> halaman = [
      _buildDasborContent(colors),
      const InputProgresScreen(),
      const RiwayatProgresScreen(),
    ];

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(colors),
            Expanded(child: halaman[_selectedIndex]),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) {
          setState(() => _selectedIndex = i);
          if (i == 1 || i == 2) _muatDataAwal();
        },
        items: const [
          NavItem(icon: Icons.home_rounded, label: 'Dasbor'),
          NavItem(icon: Icons.add_circle_outline, label: 'Input'),
          NavItem(icon: Icons.history_rounded, label: 'Riwayat'),
        ],
      ),
    );
  }

  Widget _buildAppBar(WorkerColors colors) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.cardBg,
              border: Border.all(color: colors.cardBorder),
            ),
            child: Icon(Icons.person, color: colors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              _judulHalaman(_selectedIndex),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Dark/Light mode toggle
          GestureDetector(
            onTap: () => themeProvider.toggleTheme(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.cardBg,
                border: Border.all(color: colors.cardBorder),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? AppTheme.amberAccent : AppTheme.blueAccent,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Logout button
          GestureDetector(
            onTap: _prosesLogout,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.cardBg,
                border: Border.all(color: colors.cardBorder),
              ),
              child: Icon(Icons.logout_rounded, color: colors.red, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  String _judulHalaman(int idx) {
    switch (idx) {
      case 0: return 'Dasbor Pekerja';
      case 1: return 'Input Progres';
      case 2: return 'Riwayat Progres';
      default: return '';
    }
  }

  Widget _buildDasborContent(WorkerColors colors) {
    return Consumer2<AuthProvider, WorkerProvider>(
      builder: (context, auth, worker, _) {
        final user = auth.currentUser;
        if (user == null) {
          return Center(child: CircularProgressIndicator(color: colors.blue));
        }

        final DateTime startMinggu = Formatters.awalMingguIni();
        int totalPasangMinggu = 0;
        int totalEstimasiGaji = 0;

        for (final p in worker.riwayatProgres) {
          final tgl = p.createdAt;
          if (tgl != null && tgl.isAfter(startMinggu)) {
            totalPasangMinggu += p.jumlahSelesai;
            final tahapan = worker.daftarTahapan.firstWhere(
              (t) => t.id == p.idTahapan,
              orElse: () => worker.daftarTahapan.isNotEmpty
                  ? worker.daftarTahapan.first
                  : throw Exception('Tidak ada tahapan'),
            );
            totalEstimasiGaji += p.jumlahSelesai * tahapan.tarifUpah;
          }
        }

        return RefreshIndicator(
          onRefresh: _muatDataAwal,
          color: colors.blue,
          backgroundColor: colors.cardBg,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 4),
              _buildWelcomeCard(colors, user.namaLengkap),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      colors,
                      'Pasang Minggu Ini',
                      '$totalPasangMinggu',
                      Icons.check_circle_outline_rounded,
                      colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      colors,
                      'Estimasi Gaji',
                      Formatters.rupiah(totalEstimasiGaji),
                      Icons.payments_rounded,
                      colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Menu Cepat header
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: colors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Menu Cepat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      colors,
                      'Input\nProgres Baru',
                      Icons.add_circle_outline_rounded,
                      () => setState(() => _selectedIndex = 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMenuCard(
                      colors,
                      'Lihat\nRiwayat',
                      Icons.history_rounded,
                      () => setState(() => _selectedIndex = 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 5 Progres Terakhir header
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: colors.green,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '5 Progres Terakhir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 2),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (worker.riwayatProgres.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Center(
                    child: Text(
                      'Belum ada progres. Mulai input progres pertama Anda!',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                )
              else
                ...worker.riwayatProgres.take(5).map((p) {
                  final tahapan = worker.daftarTahapan.firstWhere(
                    (t) => t.id == p.idTahapan,
                    orElse: () => worker.daftarTahapan.isNotEmpty
                        ? worker.daftarTahapan.first
                        : throw Exception('Tidak ada tahapan'),
                  );
                  final sepatu = worker.daftarSepatu.firstWhere(
                    (s) => s.id == p.idSepatu,
                    orElse: () => worker.daftarSepatu.isNotEmpty
                        ? worker.daftarSepatu.first
                        : throw Exception('Tidak ada sepatu'),
                  );
                  final estimasi = p.jumlahSelesai * tahapan.tarifUpah;
                  return _buildProgresItem(
                    colors,
                    sepatu.namaModel,
                    Formatters.tanggalWaktu(p.createdAt),
                    p.jumlahSelesai,
                    estimasi,
                  );
                }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(WorkerColors colors, String nama) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: colors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.gradientEndColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.groups_rounded, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang,',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'Status Keanggotaan',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.green.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 6, color: colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Aktif',
                            style: TextStyle(
                              color: colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(WorkerColors colors, String judul, String nilai, IconData ikon, Color warna) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.iconBg(warna),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(ikon, color: warna, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            judul,
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            nilai,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(WorkerColors colors, String judul, IconData ikon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          gradient: colors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colors.gradientEndColor.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(ikon, color: Colors.white, size: 32),
            const SizedBox(height: 10),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgresItem(WorkerColors colors, String namaModel, String tanggal, int jumlah, int estimasi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.iconBg(colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.inventory_2_outlined, color: colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaModel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tanggal,
                  style: TextStyle(fontSize: 11, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$jumlah pasang',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Formatters.rupiah(estimasi),
                style: TextStyle(
                  fontSize: 11,
                  color: colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}