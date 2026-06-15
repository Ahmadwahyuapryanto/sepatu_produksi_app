import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/admin_provider.dart';
import 'tahapan_screen.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchRekapGaji();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final cardBorder = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);
    final textPri = isDark ? AppTheme.darkTextPrimary : AppTheme.textHighEmphasis;
    final textSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textMediumEmphasis;

    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        final rekap = admin.getRekapGajiPerPekerja(hanyaBelumBayar: true);
        final totalBelumBayar = admin.totalGajiBelumDibayar;

        return Stack(
          children: [
            Column(
              children: [
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
                // Total unpaid card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.gradientStart, AppTheme.gradientEnd]), borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      children: [
                        const Text('TOTAL UPAH BELUM DIBAYAR', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        Text(Formatters.rupiah(totalBelumBayar), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text('${rekap.length} pekerja menunggu pembayaran', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Bayar Semua?'),
                                content: Text('Konfirmasi pembayaran untuk ${rekap.length} pekerja?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Bayar', style: TextStyle(color: AppTheme.greenAccent))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await admin.konfirmasiSemuaPembayaran();
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pembayaran berhasil dikonfirmasi'), backgroundColor: AppTheme.greenAccent));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.payment, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Bayar Semua Pekerja', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Tombol Kelola Tarif Upah
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TahapanScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: AppTheme.blueAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.blueAccent.withValues(alpha: 0.3))),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.add_circle_outline, color: AppTheme.blueAccent, size: 18),
                        SizedBox(width: 8),
                        Text('Tambah / Kelola Tarif Upah', style: TextStyle(color: AppTheme.blueAccent, fontWeight: FontWeight.w600, fontSize: 13)),
                      ]),
                    ),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text('Rincian per Pekerja', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPri)),
                      const Spacer(),
                      Text('${rekap.length} pekerja', style: TextStyle(fontSize: 12, color: textSec)),
                    ],
                  ),
                ),
                // List
                Expanded(
                  child: admin.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.blueAccent))
                      : rekap.isEmpty
                          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.check_circle_outline, size: 48, color: AppTheme.greenAccent.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              Text('Semua gaji sudah dibayar!', style: TextStyle(color: textSec)),
                            ]))
                          : RefreshIndicator(
                              onRefresh: () => admin.fetchRekapGaji(),
                              color: AppTheme.blueAccent, backgroundColor: cardBg,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                                itemCount: rekap.length,
                                itemBuilder: (context, i) => _buildPegawaiGajiCard(rekap[i], cardBg, cardBorder, textPri, textSec, admin),
                              ),
                            ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPegawaiGajiCard(Map<String, dynamic> r, Color cardBg, Color cardBorder, Color textPri, Color textSec, AdminProvider admin) {
    final nama = r['namaPekerja'] ?? '-';
    final totalGaji = r['totalGaji'] as int;
    final totalPasang = r['totalPasang'] as int;
    final listDetail = r['listDetail'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.blueAccent.withValues(alpha: 0.15), shape: BoxShape.circle), child: const Icon(Icons.person, color: AppTheme.blueAccent, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(nama, style: TextStyle(fontWeight: FontWeight.w600, color: textPri, fontSize: 14)),
                Text('${listDetail.length} transaksi • $totalPasang pasang', style: TextStyle(fontSize: 12, color: textSec)),
              ])),
              Text(Formatters.rupiah(totalGaji), style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.greenAccent, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Bayar $nama?'),
                  content: Text('Konfirmasi pembayaran ${Formatters.rupiah(totalGaji)}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Bayar', style: TextStyle(color: AppTheme.greenAccent))),
                  ],
                ),
              );
              if (confirm == true) {
                await admin.konfirmasiPembayaran(r['idPekerja']);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran $nama berhasil'), backgroundColor: AppTheme.greenAccent));
                }
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: AppTheme.greenAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle_outline, color: AppTheme.greenAccent, size: 16),
                SizedBox(width: 6),
                Text('Bayar', style: TextStyle(color: AppTheme.greenAccent, fontWeight: FontWeight.w600, fontSize: 13)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}