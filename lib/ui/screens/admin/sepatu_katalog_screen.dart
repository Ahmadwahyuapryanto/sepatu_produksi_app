import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sepatu_model.dart';
import '../../../logic/admin_provider.dart';

class SepatuKatalogScreen extends StatefulWidget {
  const SepatuKatalogScreen({super.key});

  @override
  State<SepatuKatalogScreen> createState() => _SepatuKatalogScreenState();
}

class _SepatuKatalogScreenState extends State<SepatuKatalogScreen> {
  String _filter = 'Semua Model';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchLaporanProduksi();
    });
  }

  void _tampilkanFormTambah() {
    final formKey = GlobalKey<FormState>();
    final namaC = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final cardBorder = isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);
    final textPri = isDark ? AppTheme.darkTextPrimary : AppTheme.textHighEmphasis;
    final textSec = isDark ? AppTheme.darkTextSecondary : AppTheme.textMediumEmphasis;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tambah Model Sepatu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPri)),
                    IconButton(icon: Icon(Icons.close, color: textSec), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: namaC,
                  style: TextStyle(color: textPri),
                  decoration: InputDecoration(
                    labelText: 'Nama Model Sepatu',
                    labelStyle: TextStyle(color: textSec),
                    prefixIcon: const Icon(Icons.style, color: AppTheme.blueAccent),
                    hintText: 'Contoh: Sneakers Air Max',
                    hintStyle: TextStyle(color: textSec.withValues(alpha: 0.5)),
                    filled: true, fillColor: cardBg,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cardBorder)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.blueAccent, width: 1.5)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama model wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      final admin = context.read<AdminProvider>();
                      final ok = await admin.tambahModelSepatu(namaC.text.trim());
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok ? 'Model sepatu berhasil ditambahkan' : admin.errorMessage ?? 'Gagal'),
                          backgroundColor: ok ? AppTheme.greenAccent : AppTheme.redAccent,
                        ));
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.gradientStart, AppTheme.gradientEnd]), borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text('Simpan Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
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
        List<SepatuModel> filtered = admin.laporanProduksi;
        if (_searchQuery.isNotEmpty) {
          filtered = filtered.where((s) => s.namaModel.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        }
        if (_filter == 'Running') {
          filtered = filtered.where((s) => s.kategori == 'Running').toList();
        } else if (_filter == 'Casual') {
          filtered = filtered.where((s) => s.kategori == 'Casual').toList();
        }

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    style: TextStyle(color: textPri),
                    decoration: InputDecoration(
                      hintText: 'Cari model sepatu...',
                      hintStyle: TextStyle(color: textSec.withValues(alpha: 0.5)),
                      prefixIcon: Icon(Icons.search, color: textSec),
                      filled: true, fillColor: cardBg,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.blueAccent, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: ['Semua Model', 'Running', 'Casual'].map((f) {
                      final selected = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _filter = f),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(color: selected ? AppTheme.blueAccent : Colors.transparent, borderRadius: BorderRadius.circular(20), border: selected ? null : Border.all(color: cardBorder)),
                            child: Text(f, style: TextStyle(color: selected ? Colors.white : textSec, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: admin.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.blueAccent))
                      : filtered.isEmpty
                          ? Center(child: Text('Tidak ada data katalog', style: TextStyle(color: textSec)))
                          : RefreshIndicator(
                              onRefresh: () => admin.fetchLaporanProduksi(),
                              color: AppTheme.blueAccent, backgroundColor: cardBg,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                                itemCount: filtered.length,
                                itemBuilder: (context, i) => _buildKatalogCard(filtered[i], cardBg, cardBorder, textPri, textSec),
                              ),
                            ),
                ),
              ],
            ),
            // FAB Tambah Katalog
            Positioned(
              right: 16, bottom: 16,
              child: GestureDetector(
                onTap: _tampilkanFormTambah,
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.blueAccent, boxShadow: [BoxShadow(color: AppTheme.blueAccent.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKatalogCard(SepatuModel s, Color cardBg, Color cardBorder, Color textPri, Color textSec) {
    final kategoriColor = s.kategori == 'Running' ? AppTheme.blueAccent : AppTheme.amberAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: kategoriColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(s.kategori.toUpperCase(), style: TextStyle(color: kategoriColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.namaModel, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 16)),
                const SizedBox(height: 8),
                Row(children: [
                  _buildStockBadge('Stok Bagus', '${s.stokBagus}', AppTheme.greenAccent),
                  const SizedBox(width: 10),
                  _buildStockBadge('Reject', '${s.stokReject}', AppTheme.redAccent),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.gradientStart, AppTheme.gradientEnd]), borderRadius: BorderRadius.circular(10)),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Lihat Rincian', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        SizedBox(width: 6), Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(String label, String value, Color color) {
    return Row(children: [
      Icon(Icons.circle, size: 8, color: color),
      const SizedBox(width: 6),
      Text('$label  ', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
    ]);
  }
}