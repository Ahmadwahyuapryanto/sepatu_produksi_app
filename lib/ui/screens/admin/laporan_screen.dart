import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/admin_provider.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  String _tab = 'Produksi';
  String _periode = 'Harian';
  List<Map<String, dynamic>> _dataProduksi = [];
  List<Map<String, dynamic>> _dataBahan = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _muatData());
  }

  Future<void> _muatData() async {
    setState(() => _loading = true);
    final admin = context.read<AdminProvider>();
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (_periode == 'Harian') {
      start = DateTime(now.year, now.month, now.day);
    } else if (_periode == 'Mingguan') {
      start = now.subtract(Duration(days: now.weekday - 1));
      start = DateTime(start.year, start.month, start.day);
    } else {
      start = DateTime(now.year, now.month, 1);
    }

    final results = await Future.wait([
      admin.fetchLaporanProduksiByPeriode(start, end),
      admin.fetchLaporanLogBahan(start, end),
    ]);
    if (!mounted) return;
    setState(() {
      _dataProduksi = results[0];
      _dataBahan = results[1];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final cardBorder = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);
    final textPri = isDark ? AppTheme.darkTextPrimary : AppTheme.textHighEmphasis;
    final textSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textMediumEmphasis;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: cardBg, border: Border.all(color: cardBorder)), child: Icon(Icons.person, color: textPri, size: 20)),
              const SizedBox(width: 12),
              Text('Warehouse Admin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPri)),
              const Spacer(),
              Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: cardBg, border: Border.all(color: cardBorder)), child: Icon(Icons.notifications_outlined, color: textSec, size: 18)),
            ],
          ),
        ),
        // Tab Produksi / Bahan Baku
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
            child: Row(
              children: ['Produksi', 'Bahan Baku'].map((t) {
                final selected = _tab == t;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _tab = t);
                      _muatData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.blueAccent : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(t, style: TextStyle(color: selected ? Colors.white : textSec, fontWeight: FontWeight.w600, fontSize: 13))),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Periode tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            children: ['Harian', 'Mingguan', 'Bulanan'].map((p) {
              final selected = _periode == p;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _periode = p);
                    _muatData();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.blueAccent : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: selected ? null : Border.all(color: cardBorder),
                    ),
                    child: Text(p, style: TextStyle(color: selected ? Colors.white : textSec, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Cetak / Filter summary bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: cardBorder)),
                  child: Text(
                    'Periode: $_periode • ${_dataProduksi.length + _dataBahan.length} data',
                    style: TextStyle(fontSize: 11, color: textSec),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Cetak Laporan button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mencetak laporan $_tab periode $_periode...'),
                      backgroundColor: AppTheme.blueAccent,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.gradientStart, AppTheme.gradientEnd]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.print_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Cetak', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.blueAccent))
              : _tab == 'Produksi'
                  ? _buildProduksiList(cardBg, cardBorder, textPri, textSec)
                  : _buildBahanList(cardBg, cardBorder, textPri, textSec),
        ),
      ],
    );
  }

  Widget _buildProduksiList(Color cardBg, Color cardBorder, Color textPri, Color textSec) {
    if (_dataProduksi.isEmpty) {
      return Center(child: Text('Tidak ada data produksi', style: TextStyle(color: textSec)));
    }
    return RefreshIndicator(
      onRefresh: _muatData,
      color: AppTheme.blueAccent,
      backgroundColor: cardBg,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: _dataProduksi.length,
        itemBuilder: (context, i) {
          final d = _dataProduksi[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.blueAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.inventory_2_outlined, color: AppTheme.blueAccent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['nama_model'] ?? '-', style: TextStyle(fontWeight: FontWeight.w600, color: textPri, fontSize: 14)),
                      Text('${d['jumlah_bagus'] ?? 0} bagus • ${d['jumlah_reject'] ?? 0} reject', style: TextStyle(fontSize: 12, color: textSec)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBahanList(Color cardBg, Color cardBorder, Color textPri, Color textSec) {
    if (_dataBahan.isEmpty) {
      return Center(child: Text('Tidak ada data bahan', style: TextStyle(color: textSec)));
    }
    return RefreshIndicator(
      onRefresh: _muatData,
      color: AppTheme.blueAccent,
      backgroundColor: cardBg,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: _dataBahan.length,
        itemBuilder: (context, i) {
          final d = _dataBahan[i];
          final isMasuk = d['tipe_transaksi'] == 'MASUK';
          final warna = isMasuk ? AppTheme.greenAccent : AppTheme.redAccent;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: warna.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(isMasuk ? Icons.download_rounded : Icons.upload_rounded, color: warna, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['nama_bahan'] ?? '-', style: TextStyle(fontWeight: FontWeight.w600, color: textPri, fontSize: 14)),
                      Text('${isMasuk ? "Masuk" : "Keluar"} • ${Formatters.tanggalWaktu(DateTime.tryParse(d['created_at'] ?? ''))}', style: TextStyle(fontSize: 12, color: textSec)),
                    ],
                  ),
                ),
                Text(
                  '${isMasuk ? "+" : "-"}${Formatters.angkaDesimal((d['jumlah'] as num?)?.toDouble() ?? 0)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: warna, fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}