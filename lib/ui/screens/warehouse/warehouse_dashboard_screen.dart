import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/warehouse_repository.dart';
import '../../../data/models/bahan_baku_model.dart';
import '../../../data/models/sepatu_model.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/theme_provider.dart';
import '../../widgets/warehouse_bottom_nav.dart';
import '../login_screen.dart';
import 'bahan_baku_screen.dart';
import 'qc_screen.dart';
import 'riwayat_barang_screen.dart';

class WarehouseDashboardScreen extends StatefulWidget {
  const WarehouseDashboardScreen({super.key});

  @override
  State<WarehouseDashboardScreen> createState() =>
      _WarehouseDashboardScreenState();
}

class _WarehouseDashboardScreenState extends State<WarehouseDashboardScreen> {
  int _selectedIndex = 0;
  final WarehouseRepository _repository = WarehouseRepository();

  List<BahanBakuModel> _bahanBaku = [];
  List<SepatuModel> _sepatu = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _muatRingkasan();
    });
  }

  Future<void> _muatRingkasan() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _repository.getDaftarBahanBaku(),
        _repository.getDaftarSepatu(),
      ]);
      if (!mounted) return;
      setState(() {
        _bahanBaku = results[0] as List<BahanBakuModel>;
        _sepatu = results[1] as List<SepatuModel>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat dasbor: $e'), backgroundColor: AppTheme.redAccent),
        );
      }
    }
  }

  Future<void> _prosesLogout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkBg : const Color(0xFFF4F7FC);
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final cardBorder = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);
    final textPri = isDark ? AppTheme.darkTextPrimary : AppTheme.textHighEmphasis;
    final textSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textMediumEmphasis;

    final List<Widget> halaman = [
      _buildDasborContent(isDark, cardBg, cardBorder, textPri, textSec),
      BahanBakuScreen(isDark: isDark),
      QcScreen(isDark: isDark),
      RiwayatBarangScreen(isDark: isDark),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            if (_selectedIndex == 0) _buildAppBar(isDark, cardBg, cardBorder, textPri),
            Expanded(child: halaman[_selectedIndex]),
          ],
        ),
      ),
      bottomNavigationBar: WarehouseBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) {
          setState(() => _selectedIndex = i);
          if (i == 0) _muatRingkasan();
        },
        items: const [
          WarehouseNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
          WarehouseNavItem(icon: Icons.inventory_2_outlined, label: 'Materials'),
          WarehouseNavItem(icon: Icons.fact_check_outlined, label: 'QC'),
          WarehouseNavItem(icon: Icons.history_rounded, label: 'History'),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, Color cardBg, Color cardBorder, Color textPri) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;
    final namaUser = context.read<AuthProvider>().currentUser?.namaLengkap ?? 'Gudang';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardBg,
              border: Border.all(color: cardBorder),
            ),
            child: Icon(Icons.person, color: textPri.withValues(alpha: 0.5), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(color: textPri.withValues(alpha: 0.6), fontSize: 12),
                ),
                Text(
                  'Halo, $namaUser',
                  style: TextStyle(
                    color: textPri,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => themeProvider.toggleTheme(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cardBg,
                border: Border.all(color: cardBorder),
              ),
              child: Icon(
                isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDarkMode ? AppTheme.amberAccent : AppTheme.blueAccent,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _prosesLogout,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cardBg,
                border: Border.all(color: cardBorder),
              ),
              child: const Icon(Icons.logout_rounded, color: AppTheme.redAccent, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDasborContent(bool isDark, Color cardBg, Color cardBorder, Color textPri, Color textSec) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.blueAccent));
    }

    int totalItemBahan = _bahanBaku.length;
    int totalStokKritis = _bahanBaku.where((b) => b.totalStok <= 5).length;
    int totalSepatuBagus = _sepatu.fold(0, (sum, s) => sum + s.stokBagus);
    int totalSepatuReject = _sepatu.fold(0, (sum, s) => sum + s.stokReject);

    return RefreshIndicator(
      onRefresh: _muatRingkasan,
      color: AppTheme.blueAccent,
      backgroundColor: cardBg,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 4),
          // 4 stat cards
          Row(
            children: [
              Expanded(child: _buildStatCard(cardBg, cardBorder, textPri, textSec, 'Bahan', '$totalItemBahan', 'SKU', AppTheme.blueAccent, Icons.inventory_2_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(cardBg, cardBorder, textPri, textSec, 'Stok Kritis', '$totalStokKritis', 'Item', AppTheme.redAccent, Icons.warning_amber_rounded)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildStatCard(cardBg, cardBorder, textPri, textSec, 'Barang Jadi', '$totalSepatuBagus', 'Unit', AppTheme.greenAccent, Icons.check_circle_outline_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard(cardBg, cardBorder, textPri, textSec, 'Barang Reject', '$totalSepatuReject', 'Batch', AppTheme.amberAccent, Icons.cancel_outlined)),
            ],
          ),
          const SizedBox(height: 24),

          // Menu Cepat
          Row(
            children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: AppTheme.greenAccent, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text('Menu Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPri)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMenuCard(isDark, 'Catat Bahan', Icons.shopping_cart_rounded, AppTheme.blueAccent, () => setState(() => _selectedIndex = 1))),
              const SizedBox(width: 12),
              Expanded(child: _buildMenuCard(isDark, 'Terima & QC', Icons.fact_check_rounded, AppTheme.greenAccent, () => setState(() => _selectedIndex = 2))),
            ],
          ),
          const SizedBox(height: 24),

          // Riwayat Terakhir
          Row(
            children: [
              Container(width: 4, height: 18, decoration: BoxDecoration(color: AppTheme.greenAccent, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Expanded(child: Text('Riwayat Terakhir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPri))),
              GestureDetector(
                onTap: () => setState(() => _selectedIndex = 3),
                child: Text('Lihat Semua', style: TextStyle(fontSize: 12, color: AppTheme.blueAccent, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Placeholder riwayat items
          _buildRiwayatItem(cardBg, cardBorder, textPri, textSec, 'Penerimaan Bahan', 'Kain Polyester + 50 Roll', '10:45', 'SELESAI', AppTheme.greenAccent, Icons.inventory_2_outlined),
          _buildRiwayatItem(cardBg, cardBorder, textPri, textSec, 'Pengambilan Bahan', 'Benang Jahit + 12 Pack', '09:12', 'SELESAI', AppTheme.greenAccent, Icons.remove_shopping_cart_outlined),
          _buildRiwayatItem(cardBg, cardBorder, textPri, textSec, 'Reject Bahan', 'Karet Sol 1 Batch', 'Kemarin', 'REJECT', AppTheme.redAccent, Icons.cancel_outlined),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(Color cardBg, Color cardBorder, Color textPri, Color textSec,
      String judul, String nilai, String sub, Color warna, IconData ikon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(ikon, color: warna, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(judul, style: TextStyle(color: textSec, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(nilai, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textPri)),
          Text(sub, style: TextStyle(color: warna, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMenuCard(bool isDark, String judul, IconData ikon, Color warna, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: warna.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(ikon, color: warna, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.textHighEmphasis, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatItem(Color cardBg, Color cardBorder, Color textPri, Color textSec,
      String title, String subtitle, String time, String status, Color statusColor, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textPri)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: textSec), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}