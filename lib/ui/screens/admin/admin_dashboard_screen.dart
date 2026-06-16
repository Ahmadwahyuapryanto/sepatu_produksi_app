import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/admin_provider.dart';
import '../../../logic/auth_provider.dart';
import 'sepatu_katalog_screen.dart';
import 'pekerja_screen.dart';
import 'payroll_screen.dart';
import 'laporan_screen.dart';
import '../login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _muatDataDasbor();
    });
  }

  Future<void> _muatDataDasbor() async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    await Future.wait([
      adminProvider.fetchLaporanProduksi(),
      adminProvider.fetchDaftarPegawai(),
    ]);
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBg : const Color(0xFFF4F7FC);

    final List<Widget> halaman = [
      _buildDashboardContent(),
      const PekerjaScreen(),
      const SepatuKatalogScreen(),
      const PayrollScreen(),
      const LaporanScreen(),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(child: halaman[_selectedIndex]),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final bgColor = isDark ? const Color(0xFF111827) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final activeColor = AppTheme.blueAccent;
    final inactiveColor = isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

    final items = [
      (Icons.dashboard_rounded, 'Dasbor'),
      (Icons.people_outline_rounded, 'Pegawai'),
      (Icons.inventory_2_outlined, 'Katalog'),
      (Icons.payments_outlined, 'Gaji'),
      (Icons.assessment_outlined, 'Laporan'),
    ];

    return Container(
      decoration: BoxDecoration(color: bgColor, border: Border(top: BorderSide(color: borderColor, width: 0.5))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == _selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    if (index == 0) _muatDataDasbor();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(item.$1, size: 24, color: isActive ? activeColor : inactiveColor),
                      ),
                      const SizedBox(height: 4),
                      Text(item.$2, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w600 : FontWeight.w500, color: isActive ? activeColor : inactiveColor)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? AppTheme.darkCard : Colors.white;
        final cardBorder = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);
        final textPri = isDark ? AppTheme.darkTextPrimary : AppTheme.textHighEmphasis;
        final textSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textMediumEmphasis;
        final namaUser = context.read<AuthProvider>().currentUser?.namaLengkap ?? 'Admin';


        return RefreshIndicator(
          onRefresh: _muatDataDasbor,
          color: AppTheme.blueAccent,
          backgroundColor: cardBg,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 8),
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi, $namaUser', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textPri)),
                        const SizedBox(height: 2),
                        Text('Selamat datang kembali!', style: TextStyle(fontSize: 13, color: textSec)),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.blueAccent.withValues(alpha: 0.15)),
                        child: const Icon(Icons.person, color: AppTheme.blueAccent, size: 22),
                      ),
                      const SizedBox(width: 8),
                      // Tombol logout
                      GestureDetector(
                        onTap: () async {
                          final auth = context.read<AuthProvider>();
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.logout_rounded, color: AppTheme.redAccent, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tips banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.gradientStart, AppTheme.gradientEnd]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tips meningkatkan\nproduksi harian', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, height: 1.4)),
                          const SizedBox(height: 6),
                          Text('Pantau performa tim secara berkala', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Target banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.greenAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.greenAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.greenAccent.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle, color: AppTheme.greenAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Target minggu ini telah tercapai!', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.greenAccent, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('Performa tim di atas rata-rata', style: TextStyle(color: textSec, fontSize: 11)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: textSec),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Model card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppTheme.blueAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.blueAccent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${adminProvider.laporanProduksi.length} Model', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPri)),
                          Text('Katalog yang sedang aktif', style: TextStyle(fontSize: 12, color: textSec)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 2),
                      child: Text('Lihat Semua', style: TextStyle(color: AppTheme.blueAccent, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Stats
              Row(
                children: [
                  Expanded(child: _buildStatCard(cardBg, cardBorder, textPri, textSec, 'Pegawai Aktif', '${adminProvider.daftarPegawai.length}', 'orang', AppTheme.blueAccent)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildStatCard(cardBg, cardBorder, textPri, textSec, 'Estimasi Gaji', Formatters.rupiah(0), 'total', AppTheme.greenAccent)),
                ],
              ),
              const SizedBox(height: 20),

              // Aktivitas Produksi
              Row(
                children: [
                  Container(width: 4, height: 18, decoration: BoxDecoration(color: AppTheme.greenAccent, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  Text('Aktivitas Produksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPri)),
                ],
              ),
              const SizedBox(height: 12),

              if (adminProvider.laporanProduksi.isNotEmpty)
                ...adminProvider.laporanProduksi.take(3).map((s) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Model: ${s.namaModel}', style: TextStyle(fontWeight: FontWeight.w600, color: textPri, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('Total: ${s.stokBagus + s.stokReject} | Bagus: ${s.stokBagus} | Reject: ${s.stokReject}', style: TextStyle(fontSize: 12, color: textSec)),
                    ],
                  ),
                ))
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
                  child: Center(child: Text('Belum ada aktivitas produksi', style: TextStyle(color: textSec))),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(Color cardBg, Color cardBorder, Color textPri, Color textSec, String title, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.circle, color: color, size: 12),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(color: textSec, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textPri)),
          Text(sub, style: TextStyle(fontSize: 11, color: textSec)),
        ],
      ),
    );
  }
}