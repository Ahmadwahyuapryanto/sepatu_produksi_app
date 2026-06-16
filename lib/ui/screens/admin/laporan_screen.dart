import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/admin_provider.dart';
import '../../../data/models/tahapan_model.dart';

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
  List<Map<String, dynamic>> _dataPekerjaan = [];
  List<TahapanModel> _daftarTahapan = [];
  int? _filterTahapanId;
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

    final dataProduksi = await admin.fetchLaporanProduksiByPeriode(start, end);
    final dataBahan = await admin.fetchLaporanLogBahan(start, end);
    
    // Load daftar tahapan
    if (_daftarTahapan.isEmpty) {
      await admin.fetchDaftarTahapan();
      if (!mounted) return;
      setState(() => _daftarTahapan = admin.daftarTahapan);
    }
    
    // Load data pekerjaan
    final List<Map<String, dynamic>> dataPekerjaan;
    if (_filterTahapanId != null) {
      dataPekerjaan = await admin.fetchLaporanPekerjaanByTahapan(start, end, _filterTahapanId!);
    } else {
      dataPekerjaan = await admin.fetchLaporanPekerjaanByPeriode(start, end);
    }
    if (!mounted) return;
    
    setState(() {
      _dataProduksi = dataProduksi;
      _dataBahan = dataBahan;
      _dataPekerjaan = dataPekerjaan;
      _loading = false;
    });
  }

  String _getNamaModel(Map<String, dynamic> d) {
    final sepatu = d['tb_master_sepatu'];
    if (sepatu is Map) return sepatu['nama_model'] ?? '-';
    return d['nama_model'] ?? '-';
  }

  String _getNamaBahan(Map<String, dynamic> d) {
    final bahan = d['tb_bahan_baku'];
    if (bahan is Map) return bahan['nama_bahan'] ?? '-';
    return d['nama_bahan'] ?? '-';
  }

  String _getNamaUser(Map<String, dynamic> d) {
    final user = d['tb_users'];
    if (user is Map) return user['nama_lengkap'] ?? '-';
    return d['nama_lengkap'] ?? '-';
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
              children: ['Produksi', 'Bahan Baku', 'Pekerjaan'].map((t) {
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
                  ? _buildProduksiContent(cardBg, cardBorder, textPri, textSec, isDark)
                  : _tab == 'Pekerjaan'
                      ? _buildPekerjaanContent(cardBg, cardBorder, textPri, textSec, isDark)
                      : _buildBahanContent(cardBg, cardBorder, textPri, textSec, isDark),
        ),
      ],
    );
  }

  // ===================== PRODUKSI CONTENT =====================
  Widget _buildProduksiContent(Color cardBg, Color cardBorder, Color textPri, Color textSec, bool isDark) {
    return Column(
      children: [
        // Statistik cards
        _buildProduksiStatCards(cardBg, cardBorder, textPri, textSec),
        // Grafik pertumbuhan
        _buildProduksiChart(cardBg, cardBorder, textPri, textSec, isDark),
        // List riwayat
        Expanded(child: _buildProduksiList(cardBg, cardBorder, textPri, textSec)),
      ],
    );
  }

  Widget _buildProduksiStatCards(Color cardBg, Color cardBorder, Color textPri, Color textSec) {
    int totalBagus = 0;
    int totalReject = 0;
    int totalModel = 0;
    final modelSet = <String>{};

    for (final d in _dataProduksi) {
      totalBagus += (d['jumlah_bagus'] as int?) ?? 0;
      totalReject += (d['jumlah_reject'] as int?) ?? 0;
      final nm = _getNamaModel(d);
      if (nm != '-') modelSet.add(nm);
    }
    totalModel = modelSet.length;
    final totalAll = totalBagus + totalReject;
    final persenBagus = totalAll > 0 ? ((totalBagus / totalAll) * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Produksi', '$totalAll', AppTheme.blueAccent, Icons.inventory_2_outlined, cardBg, cardBorder, textPri, textSec)),
          const SizedBox(width: 6),
          Expanded(child: _buildStatCard('Bagus', '$totalBagus', AppTheme.greenAccent, Icons.check_circle_outline, cardBg, cardBorder, textPri, textSec)),
          const SizedBox(width: 6),
          Expanded(child: _buildStatCard('Reject', '$totalReject', AppTheme.redAccent, Icons.cancel_outlined, cardBg, cardBorder, textPri, textSec)),
          const SizedBox(width: 6),
          Expanded(child: _buildStatCard('Akurasi', '$persenBagus%', AppTheme.blueAccent, Icons.verified_outlined, cardBg, cardBorder, textPri, textSec)),
        ],
      ),
    );
  }

  Widget _buildProduksiChart(Color cardBg, Color cardBorder, Color textPri, Color textSec, bool isDark) {
    // Group by model name
    final Map<String, int> modelBagus = {};
    final Map<String, int> modelReject = {};

    for (final d in _dataProduksi) {
      final nm = _getNamaModel(d);
      modelBagus[nm] = (modelBagus[nm] ?? 0) + ((d['jumlah_bagus'] as int?) ?? 0);
      modelReject[nm] = (modelReject[nm] ?? 0) + ((d['jumlah_reject'] as int?) ?? 0);
    }

    final models = modelBagus.keys.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: AppTheme.blueAccent, size: 18),
                const SizedBox(width: 8),
                Text('Grafik Produksi per Model', style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 14),
            if (models.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(child: Text('Belum ada data produksi', style: TextStyle(color: textSec, fontSize: 12))),
              )
            else
              ...models.map((model) {
                final bagus = modelBagus[model] ?? 0;
                final reject = modelReject[model] ?? 0;
                final total = bagus + reject;
                final persenBagus = total > 0 ? (bagus / total) : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(model, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri)),
                          Text('$bagus bagus / $reject reject', style: TextStyle(fontSize: 11, color: textSec)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Stacked bar chart
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 20,
                          child: Row(
                            children: [
                              if (bagus > 0)
                                Expanded(
                                  flex: bagus,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]),
                                    ),
                                    alignment: Alignment.center,
                                    child: bagus > total * 0.15
                                        ? Text('$bagus', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                                        : null,
                                  ),
                                ),
                              if (reject > 0)
                                Expanded(
                                  flex: reject,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                                    ),
                                    alignment: Alignment.center,
                                    child: reject > total * 0.15
                                        ? Text('$reject', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                                        : null,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 4),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem('Bagus', const Color(0xFF22C55E)),
                const SizedBox(width: 16),
                _legendItem('Reject', const Color(0xFFEF4444)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon, Color cardBg, Color cardBorder, Color textPri, Color textSec) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: cardBorder)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: TextStyle(color: textSec, fontSize: 9)),
        ],
      ),
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
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
        itemCount: _dataProduksi.length,
        itemBuilder: (context, i) {
          final d = _dataProduksi[i];
          final namaModel = _getNamaModel(d);
          final namaUser = _getNamaUser(d);
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
                      Text(namaModel, style: TextStyle(fontWeight: FontWeight.w600, color: textPri, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('${d['jumlah_bagus'] ?? 0} bagus • ${d['jumlah_reject'] ?? 0} reject', style: TextStyle(fontSize: 12, color: textSec)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 11, color: textSec),
                          const SizedBox(width: 3),
                          Text('oleh $namaUser', style: TextStyle(fontSize: 11, color: textSec)),
                          const SizedBox(width: 8),
                          Text(Formatters.tanggalWaktu(DateTime.tryParse(d['created_at'] ?? '')), style: TextStyle(fontSize: 11, color: textSec)),
                        ],
                      ),
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

  // ===================== BAHAN BAKU CONTENT =====================
  Widget _buildBahanContent(Color cardBg, Color cardBorder, Color textPri, Color textSec, bool isDark) {
    return Column(
      children: [
        // Statistik cards
        _buildBahanStatCards(cardBg, cardBorder, textPri, textSec),
        // Grafik pergerakan
        _buildBahanChart(cardBg, cardBorder, textPri, textSec, isDark),
        // List riwayat
        Expanded(child: _buildBahanList(cardBg, cardBorder, textPri, textSec)),
      ],
    );
  }

  Widget _buildBahanStatCards(Color cardBg, Color cardBorder, Color textPri, Color textSec) {
    int totalMasuk = 0;
    int totalKeluar = 0;
    for (final d in _dataBahan) {
      final jml = ((d['jumlah'] as num?)?.toDouble() ?? 0).toInt();
      if (d['tipe_transaksi'] == 'MASUK') {
        totalMasuk += jml;
      } else {
        totalKeluar += jml;
      }
    }
    final totalAll = totalMasuk + totalKeluar;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Pemasukan', '$totalMasuk', AppTheme.greenAccent, Icons.download_rounded, cardBg, cardBorder, textPri, textSec)),
          const SizedBox(width: 6),
          Expanded(child: _buildStatCard('Pengeluaran', '$totalKeluar', AppTheme.redAccent, Icons.upload_rounded, cardBg, cardBorder, textPri, textSec)),
          const SizedBox(width: 6),
          Expanded(child: _buildStatCard('Total', '$totalAll', AppTheme.blueAccent, Icons.all_inbox_outlined, cardBg, cardBorder, textPri, textSec)),
          const SizedBox(width: 6),
          Expanded(child: _buildStatCard('Transaksi', '${_dataBahan.length}', AppTheme.blueAccent, Icons.swap_horiz_rounded, cardBg, cardBorder, textPri, textSec)),
        ],
      ),
    );
  }

  Widget _buildBahanChart(Color cardBg, Color cardBorder, Color textPri, Color textSec, bool isDark) {
    // Group by bahan name
    final Map<String, int> bahanMasuk = {};
    final Map<String, int> bahanKeluar = {};

    for (final d in _dataBahan) {
      final nb = _getNamaBahan(d);
      final jml = ((d['jumlah'] as num?)?.toDouble() ?? 0).toInt();
      if (d['tipe_transaksi'] == 'MASUK') {
        bahanMasuk[nb] = (bahanMasuk[nb] ?? 0) + jml;
      } else {
        bahanKeluar[nb] = (bahanKeluar[nb] ?? 0) + jml;
      }
    }

    final allBahan = <String>{...bahanMasuk.keys, ...bahanKeluar.keys}.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up_rounded, color: AppTheme.blueAccent, size: 18),
                const SizedBox(width: 8),
                Text('Grafik Pergerakan Bahan', style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 14),
            if (allBahan.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(child: Text('Belum ada data bahan', style: TextStyle(color: textSec, fontSize: 12))),
              )
            else
              ...allBahan.map((bahan) {
                final masuk = bahanMasuk[bahan] ?? 0;
                final keluar = bahanKeluar[bahan] ?? 0;
                final maxVal = (masuk > keluar ? masuk : keluar).toDouble();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bahan, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri)),
                      const SizedBox(height: 4),
                      // Bar masuk (green) - horizontal
                      if (masuk > 0) ...[
                        Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Text('Masuk', style: TextStyle(fontSize: 10, color: AppTheme.greenAccent)),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: maxVal > 0 ? masuk / maxVal : 0,
                                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.greenAccent),
                                  minHeight: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('$masuk', style: TextStyle(fontSize: 10, color: AppTheme.greenAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                      if (keluar > 0) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Text('Keluar', style: TextStyle(fontSize: 10, color: AppTheme.redAccent)),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: maxVal > 0 ? keluar / maxVal : 0,
                                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.redAccent),
                                  minHeight: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('$keluar', style: TextStyle(fontSize: 10, color: AppTheme.redAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
            const SizedBox(height: 4),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem('Masuk', AppTheme.greenAccent),
                const SizedBox(width: 16),
                _legendItem('Keluar', AppTheme.redAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================== PEKERJAAN CONTENT =====================
  Widget _buildPekerjaanContent(Color cardBg, Color cardBorder, Color textPri, Color textSec, bool isDark) {
    return Column(
      children: [
        // Filter tahapan chips
        _buildTahapanFilter(cardBg, cardBorder, textPri, textSec),
        // Statistik cards
        _buildPekerjaanStatCards(cardBg, cardBorder, textPri, textSec),
        // Grafik pekerjaan
        _buildPekerjaanChart(cardBg, cardBorder, textPri, textSec, isDark),
        // List pekerjaan
        Expanded(child: _buildPekerjaanList(cardBg, cardBorder, textPri, textSec)),
      ],
    );
  }

  Widget _buildTahapanFilter(Color cardBg, Color cardBorder, Color textPri, Color textSec) {
    return Container(
      height: 40,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "Semua" chip
          GestureDetector(
            onTap: () {
              setState(() => _filterTahapanId = null);
              _muatData();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _filterTahapanId == null ? AppTheme.blueAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: _filterTahapanId == null ? null : Border.all(color: cardBorder),
              ),
              child: Text('Semua',
                style: TextStyle(
                  color: _filterTahapanId == null ? Colors.white : textSec,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Tahapan chips
          ..._daftarTahapan.map((t) {
            final selected = _filterTahapanId == t.id;
            return GestureDetector(
              onTap: () {
                setState(() => _filterTahapanId = t.id);
                _muatData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.blueAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: selected ? null : Border.all(color: cardBorder),
                ),
                child: Text(t.namaTahapan,
                  style: TextStyle(
                    color: selected ? Colors.white : textSec,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPekerjaanStatCards(Color cardBg, Color cardBorder, Color textPri, Color textSec) {
    int totalProduksi = 0;
    int totalPekerja = 0;
    final pekerjaSet = <String>{};

    for (final d in _dataPekerjaan) {
      totalProduksi += (d['jumlah_selesai'] as int?) ?? 0;
      final idPekerja = d['id_pekerja'] as String?;
      if (idPekerja != null) pekerjaSet.add(idPekerja);
    }
    totalPekerja = pekerjaSet.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Produksi', '$totalProduksi', AppTheme.blueAccent, Icons.build_outlined, cardBg, cardBorder, textPri, textSec)),
          const SizedBox(width: 6),
          Expanded(child: _buildStatCard('Pekerja', '$totalPekerja', AppTheme.greenAccent, Icons.people_outline, cardBg, cardBorder, textPri, textSec)),
          const SizedBox(width: 6),
          Expanded(child: _buildStatCard('Entry', '${_dataPekerjaan.length}', AppTheme.blueAccent, Icons.list_alt_rounded, cardBg, cardBorder, textPri, textSec)),
          const SizedBox(width: 6),
          Expanded(child: _buildStatCard('Rata', totalPekerja > 0 ? '${(totalProduksi / totalPekerja).round()}' : '0', AppTheme.blueAccent, Icons.auto_graph_rounded, cardBg, cardBorder, textPri, textSec)),
        ],
      ),
    );
  }

  Widget _buildPekerjaanChart(Color cardBg, Color cardBorder, Color textPri, Color textSec, bool isDark) {
    // Group by pekerja
    final Map<String, int> pekerjaProduksi = {};
    final Map<String, String> pekerjaTahapan = {};

    for (final d in _dataPekerjaan) {
      final namaPekerja = _getNamaUser(d);
      final jumlah = (d['jumlah_selesai'] as int?) ?? 0;
      final tahapan = d['tb_master_tahapan']?['nama_tahapan'] ?? '-';
      pekerjaProduksi[namaPekerja] = (pekerjaProduksi[namaPekerja] ?? 0) + jumlah;
      pekerjaTahapan[namaPekerja] = tahapan;
    }

    final pekerjaList = pekerjaProduksi.keys.toList();
    final maxVal = pekerjaProduksi.values.isEmpty ? 1.0 : pekerjaProduksi.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, color: AppTheme.blueAccent, size: 18),
                const SizedBox(width: 8),
                Text('Grafik Produksi per Pekerja', style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 14),
            if (pekerjaList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(child: Text('Belum ada data pekerjaan', style: TextStyle(color: textSec, fontSize: 12))),
              )
            else
              ...pekerjaList.map((pekerja) {
                final jumlah = pekerjaProduksi[pekerja] ?? 0;
                final tahapan = pekerjaTahapan[pekerja] ?? '-';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(pekerja, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPri), overflow: TextOverflow.ellipsis),
                          ),
                          Text('$jumlah pcs ($tahapan)', style: TextStyle(fontSize: 10, color: textSec)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: maxVal > 0 ? jumlah / maxVal : 0,
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.blueAccent),
                          minHeight: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPekerjaanList(Color cardBg, Color cardBorder, Color textPri, Color textSec) {
    if (_dataPekerjaan.isEmpty) {
      return Center(child: Text('Tidak ada data pekerjaan', style: TextStyle(color: textSec)));
    }
    return RefreshIndicator(
      onRefresh: _muatData,
      color: AppTheme.blueAccent,
      backgroundColor: cardBg,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
        itemCount: _dataPekerjaan.length,
        itemBuilder: (context, i) {
          final d = _dataPekerjaan[i];
          final namaPekerja = _getNamaUser(d);
          final tahapan = d['tb_master_tahapan']?['nama_tahapan'] ?? '-';
          final jumlah = (d['jumlah_selesai'] as int?) ?? 0;
          final tarif = (d['tb_master_tahapan']?['tarif_upah'] as int?) ?? 0;
          final subtotal = jumlah * tarif;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.blueAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.work_outline, color: AppTheme.blueAccent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(namaPekerja, style: TextStyle(fontWeight: FontWeight.w600, color: textPri, fontSize: 14)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.blueAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                            child: Text(tahapan, style: TextStyle(color: AppTheme.blueAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.check_circle_outline, size: 11, color: AppTheme.greenAccent),
                          const SizedBox(width: 3),
                          Text('$jumlah pcs', style: TextStyle(fontSize: 11, color: AppTheme.greenAccent, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Rp ${Formatters.angkaDesimal(subtotal.toDouble())}', style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 14)),
                    Text('@Rp ${Formatters.angkaDesimal(tarif.toDouble())}/pcs', style: TextStyle(fontSize: 10, color: textSec)),
                  ],
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
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
        itemCount: _dataBahan.length,
        itemBuilder: (context, i) {
          final d = _dataBahan[i];
          final isMasuk = d['tipe_transaksi'] == 'MASUK';
          final warna = isMasuk ? AppTheme.greenAccent : AppTheme.redAccent;
          final namaBahan = _getNamaBahan(d);
          final namaUser = _getNamaUser(d);
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
                      Text(namaBahan, style: TextStyle(fontWeight: FontWeight.w600, color: textPri, fontSize: 14)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: warna.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                            child: Text(isMasuk ? 'MASUK' : 'KELUAR', style: TextStyle(color: warna, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.person_outline, size: 11, color: textSec),
                          const SizedBox(width: 3),
                          Text('oleh $namaUser', style: TextStyle(fontSize: 11, color: textSec)),
                        ],
                      ),
                      if (d['keterangan'] != null && (d['keterangan'] as String).isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(d['keterangan'] ?? '', style: TextStyle(color: textSec, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
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