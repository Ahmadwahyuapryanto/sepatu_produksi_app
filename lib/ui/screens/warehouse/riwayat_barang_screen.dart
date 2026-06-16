import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/warehouse_repository.dart';

class RiwayatBarangScreen extends StatefulWidget {
  final bool isDark;
  const RiwayatBarangScreen({super.key, this.isDark = true});

  @override
  State<RiwayatBarangScreen> createState() => _RiwayatBarangScreenState();
}

class _RiwayatBarangScreenState extends State<RiwayatBarangScreen> {
  final WarehouseRepository _repository = WarehouseRepository();

  int _filterIndex = 0;

  List<LogBahanDetail> _riwayatLogBahan = [];
  List<QcProduksiDetail> _riwayatQc = [];
  bool _loading = true;

  bool get _isDark => widget.isDark;
  Color get _cardBg => _isDark ? AppTheme.darkCard : Colors.white;
  Color get _cardBorder => _isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);
  Color get _textPri => _isDark ? AppTheme.darkTextPrimary : AppTheme.textHighEmphasis;
  Color get _textSec => _isDark ? AppTheme.darkTextSecondary : AppTheme.textMediumEmphasis;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _muat();
    });
  }

  Future<void> _muat() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _repository.getRiwayatLogBahan(),
        _repository.getRiwayatQcProduksi(),
      ]);
      if (!mounted) return;
      setState(() {
        _riwayatLogBahan = results[0] as List<LogBahanDetail>;
        _riwayatQc = results[1] as List<QcProduksiDetail>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat riwayat: $e'), backgroundColor: AppTheme.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.blueAccent));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Icon(Icons.arrow_back_rounded, color: _textPri, size: 22),
              const SizedBox(width: 8),
              Text('Riwayat Transaksi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textPri)),
              const Spacer(),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _cardBg, border: Border.all(color: _cardBorder)),
                child: Icon(Icons.notifications_outlined, color: _textSec, size: 20),
              ),
            ],
          ),
        ),
        _buildSummaryCards(),
        _buildFilterTabs(),
        Expanded(child: _buildGroupedList()),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final totalMasuk = _riwayatLogBahan.where((d) => d.log.tipeTransaksi == 'MASUK').length;
    final totalKeluar = _riwayatLogBahan.where((d) => d.log.tipeTransaksi == 'KELUAR').length;
    final totalAll = totalMasuk + totalKeluar;
    final akurasi = totalAll > 0 ? ((totalMasuk / totalAll) * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(child: _buildMiniStat('Masuk', '$totalMasuk', AppTheme.greenAccent, Icons.download_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _buildMiniStat('Keluar', '$totalKeluar', AppTheme.redAccent, Icons.upload_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _buildMiniStat('Akurasi', '$akurasi%', AppTheme.blueAccent, Icons.verified_outlined)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: TextStyle(color: _textSec, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final labels = ['Semua', 'Bahan Masuk', 'Bahan Keluar'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = _filterIndex == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filterIndex = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.blueAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: selected ? null : Border.all(color: _cardBorder),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: selected ? Colors.white : _textSec,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGroupedList() {
    final List<_RiwayatItem> items = [];

    if (_filterIndex == 0 || _filterIndex == 1 || _filterIndex == 2) {
      for (final d in _riwayatLogBahan) {
        if (_filterIndex == 0 ||
            (_filterIndex == 1 && d.log.tipeTransaksi == 'MASUK') ||
            (_filterIndex == 2 && d.log.tipeTransaksi == 'KELUAR')) {
          items.add(_RiwayatItem(
            tanggal: d.log.createdAt ?? DateTime.now(),
            child: _buildLogBahanCard(d),
            dateKey: _dateKey(d.log.createdAt),
          ));
        }
      }
    }

    if (_filterIndex == 0 || _filterIndex == 3) {
      for (final d in _riwayatQc) {
        items.add(_RiwayatItem(
          tanggal: d.qc.createdAt ?? DateTime.now(),
          child: _buildQcCard(d),
          dateKey: _dateKey(d.qc.createdAt),
        ));
      }
    }

    items.sort((a, b) => b.tanggal.compareTo(a.tanggal));

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 64, color: _textSec.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('Belum ada riwayat transaksi', style: TextStyle(color: _textSec)),
            const SizedBox(height: 4),
            Text('Riwayat akan muncul setelah ada transaksi', style: TextStyle(color: _textSec, fontSize: 12)),
          ],
        ),
      );
    }

    final Map<String, List<_RiwayatItem>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.dateKey, () => []).add(item);
    }

    final dateLabels = grouped.keys.toList();

    return RefreshIndicator(
      onRefresh: _muat,
      color: AppTheme.blueAccent,
      backgroundColor: _cardBg,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: dateLabels.length,
        itemBuilder: (context, sectionIndex) {
          final dateKey = dateLabels[sectionIndex];
          final sectionItems = grouped[dateKey]!;
          final firstDate = sectionItems.first.tanggal;
          final isToday = _isToday(firstDate);
          final isYesterday = _isYesterday(firstDate);

          String dateLabel;
          if (isToday) {
            dateLabel = 'Hari Ini';
          } else if (isYesterday) {
            dateLabel = 'Kemarin';
          } else {
            dateLabel = Formatters.tanggal(firstDate);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(dateLabel, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textPri)),
                  const Spacer(),
                  Text(Formatters.tanggal(firstDate), style: TextStyle(fontSize: 11, color: _textSec)),
                ],
              ),
              const SizedBox(height: 8),
              ...sectionItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: item.child,
              )),
            ],
          );
        },
      ),
    );
  }

  String _dateKey(DateTime? dt) {
    if (dt == null) return 'unknown';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  bool _isYesterday(DateTime dt) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day;
  }

  Widget _buildLogBahanCard(LogBahanDetail detail) {
    final isMasuk = detail.log.tipeTransaksi == 'MASUK';
    final warna = isMasuk ? AppTheme.greenAccent : AppTheme.redAccent;
    final ikon = isMasuk ? Icons.download_rounded : Icons.upload_rounded;
    final label = isMasuk ? 'MASUK' : 'KELUAR';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(ikon, color: warna, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.namaBahan, style: TextStyle(fontWeight: FontWeight.bold, color: _textPri, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: warna.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(label, style: TextStyle(color: warna, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(Formatters.tanggalWaktu(detail.log.createdAt), style: TextStyle(color: _textSec, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 11, color: _textSec),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text('oleh ${detail.namaUser}', style: TextStyle(color: _textSec, fontSize: 11), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                if (detail.log.keterangan != null && detail.log.keterangan!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(detail.log.keterangan!, style: TextStyle(color: _textSec, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          Text(
            '${isMasuk ? "+" : "-"}${Formatters.angkaDesimal(detail.log.jumlah)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: warna, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildQcCard(QcProduksiDetail detail) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.blueAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fact_check, color: AppTheme.blueAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.namaModel, style: TextStyle(fontWeight: FontWeight.bold, color: _textPri, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.blueAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('QC', style: TextStyle(color: AppTheme.blueAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(Formatters.tanggalWaktu(detail.qc.createdAt), style: TextStyle(color: _textSec, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 11, color: _textSec),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text('oleh ${detail.namaUser}', style: TextStyle(color: _textSec, fontSize: 11), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.greenAccent, size: 14),
                    const SizedBox(width: 4),
                    Text('${detail.qc.jumlahBagus}', style: const TextStyle(color: AppTheme.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              if (detail.qc.jumlahReject > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cancel, color: AppTheme.redAccent, size: 14),
                      const SizedBox(width: 4),
                      Text('${detail.qc.jumlahReject}', style: const TextStyle(color: AppTheme.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RiwayatItem {
  final DateTime tanggal;
  final Widget child;
  final String dateKey;

  _RiwayatItem({required this.tanggal, required this.child, required this.dateKey});
}