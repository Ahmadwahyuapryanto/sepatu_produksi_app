import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/worker_provider.dart';

class RiwayatProgresScreen extends StatefulWidget {
  const RiwayatProgresScreen({super.key});

  @override
  State<RiwayatProgresScreen> createState() => _RiwayatProgresScreenState();
}

class _RiwayatProgresScreenState extends State<RiwayatProgresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _muat();
    });
  }

  Future<void> _muat() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId != null) {
      await context.read<WorkerProvider>().fetchRiwayatProgres(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = WorkerColors(context);

    return Consumer<WorkerProvider>(
      builder: (context, worker, _) {
        if (worker.isLoading) {
          return Center(child: CircularProgressIndicator(color: colors.blue));
        }

        if (worker.riwayatProgres.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off_rounded, size: 64, color: colors.textSecondary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  'Belum ada riwayat progres',
                  style: TextStyle(color: colors.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mulai catat progres pertama Anda!',
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          );
        }

        int totalPasang = 0;
        int totalGaji = 0;
        for (final p in worker.riwayatProgres) {
          totalPasang += p.jumlahSelesai;
          final tahapan = worker.daftarTahapan.firstWhere(
            (t) => t.id == p.idTahapan,
            orElse: () => throw Exception('Tahapan tidak ditemukan'),
          );
          totalGaji += p.jumlahSelesai * tahapan.tarifUpah;
        }

        return RefreshIndicator(
          onRefresh: _muat,
          color: colors.blue,
          backgroundColor: colors.cardBg,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 8),
              // Ringkasan - Gradient card
              Container(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Pasang',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$totalPasang',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'pasang',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Estimasi Gaji',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rp',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            Formatters.rupiah(totalGaji).replaceFirst('Rp ', ''),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Row(
                children: [
                  Text(
                    '${worker.riwayatProgres.length} entri terakhir',
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // List Riwayat
              ...worker.riwayatProgres.map((p) {
                final tahapan = worker.daftarTahapan.firstWhere(
                  (t) => t.id == p.idTahapan,
                  orElse: () => throw Exception('Tahapan tidak ditemukan'),
                );
                final sepatu = worker.daftarSepatu.firstWhere(
                  (s) => s.id == p.idSepatu,
                  orElse: () => throw Exception('Sepatu tidak ditemukan'),
                );
                final estimasi = p.jumlahSelesai * tahapan.tarifUpah;
                return _buildRiwayatItem(
                  colors,
                  sepatu.namaModel,
                  tahapan.namaTahapan,
                  p.jumlahSelesai,
                  estimasi,
                  Formatters.tanggalWaktu(p.createdAt),
                  p.statusBayar,
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiwayatItem(
    WorkerColors colors,
    String namaModel,
    String namaTahapan,
    int jumlah,
    int estimasi,
    String tanggal,
    bool statusBayar,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      namaTahapan,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBayar
                      ? colors.green.withValues(alpha: 0.15)
                      : colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusBayar
                        ? colors.green.withValues(alpha: 0.3)
                        : colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  statusBayar ? 'DIBAYAR' : 'BELUM',
                  style: TextStyle(
                    color: statusBayar ? colors.green : colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: colors.cardBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                tanggal,
                style: TextStyle(color: colors.textSecondary, fontSize: 11),
              ),
              const Spacer(),
              Text(
                '$jumlah pasang',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                Formatters.rupiah(estimasi),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.green,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}