import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../logic/admin_provider.dart';
import '../../../data/models/tahapan_model.dart';

class TahapanScreen extends StatefulWidget {
  const TahapanScreen({super.key});

  @override
  State<TahapanScreen> createState() => _TahapanScreenState();
}

class _TahapanScreenState extends State<TahapanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchDaftarTahapan();
    });
  }

  // Warna helper mengikuti theme
  Color _cardBg(bool isDark) => isDark ? AppTheme.darkCard : Colors.white;
  Color _cardBorder(bool isDark) => isDark ? AppTheme.darkBorder : const Color(0xFFE5E7EB);
  Color _textPri(bool isDark) => isDark ? AppTheme.darkTextPrimary : AppTheme.textHighEmphasis;
  Color _textSec(bool isDark) => isDark ? AppTheme.darkTextSecondary : AppTheme.textMediumEmphasis;
  Color _bg(bool isDark) => isDark ? AppTheme.darkBg : const Color(0xFFF4F7FC);

  void _tampilkanForm(BuildContext context, {TahapanModel? tahapanLama}) {
    final bool isEdit = tahapanLama != null;
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: isEdit ? tahapanLama.namaTahapan : '');
    final tarifController = TextEditingController(text: isEdit ? tahapanLama.tarifUpah.toString() : '');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = _cardBg(isDark);
    final cardBorder = _cardBorder(isDark);
    final textPri = _textPri(isDark);
    final textSec = _textSec(isDark);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
      builder: (BuildContext modalContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(modalContext).viewInsets.bottom, left: 24.0, right: 24.0, top: 24.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isEdit ? 'Ubah Tahapan' : 'Tambah Tahapan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPri)),
                      IconButton(icon: Icon(Icons.close, color: textSec), onPressed: () => Navigator.pop(modalContext)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: namaController,
                    style: TextStyle(color: textPri),
                    decoration: InputDecoration(
                      labelText: 'Nama Tahapan',
                      hintText: 'Contoh: Cutting, Penjahitan, Bordir',
                      hintStyle: TextStyle(color: textSec.withValues(alpha: 0.5)),
                      labelStyle: TextStyle(color: textSec),
                      prefixIcon: const Icon(Icons.work_outline, color: AppTheme.blueAccent),
                      filled: true,
                      fillColor: cardBg,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.blueAccent, width: 1.5)),
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Nama tahapan wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: tarifController,
                    style: TextStyle(color: textPri),
                    decoration: InputDecoration(
                      labelText: 'Tarif Upah (per pasang/piece)',
                      hintText: 'Contoh: 1500',
                      hintStyle: TextStyle(color: textSec.withValues(alpha: 0.5)),
                      labelStyle: TextStyle(color: textSec),
                      prefixIcon: const Icon(Icons.payments_outlined, color: AppTheme.blueAccent),
                      filled: true,
                      fillColor: cardBg,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.blueAccent, width: 1.5)),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Tarif wajib diisi';
                      final n = int.tryParse(value);
                      if (n == null || n <= 0) return 'Tarif harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        final provider = Provider.of<AdminProvider>(context, listen: false);
                        final navigator = Navigator.of(modalContext);
                        final messenger = ScaffoldMessenger.of(context);
                        final nama = namaController.text.trim();
                        final tarif = int.parse(tarifController.text.trim());

                        bool isSuccess = false;
                        if (isEdit) {
                          isSuccess = await provider.updateTahapan(TahapanModel(id: tahapanLama.id, namaTahapan: nama, tarifUpah: tarif));
                        } else {
                          isSuccess = await provider.tambahTahapan(nama, tarif);
                        }

                        navigator.pop();
                        if (context.mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(isSuccess ? 'Data tahapan berhasil disimpan' : provider.errorMessage ?? 'Gagal menyimpan', style: const TextStyle(color: Colors.white)),
                              backgroundColor: isSuccess ? AppTheme.greenAccent : AppTheme.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.gradientStart, AppTheme.gradientEnd]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('Simpan Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _konfirmasiHapus(BuildContext context, TahapanModel tahapan) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Hapus Tahapan?', style: TextStyle(color: _textPri(Theme.of(context).brightness == Brightness.dark))),
          content: Text(
            'Yakin ingin menghapus tahapan "${tahapan.namaTahapan}"?',
            style: TextStyle(color: _textSec(Theme.of(context).brightness == Brightness.dark)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: TextStyle(color: _textSec(Theme.of(context).brightness == Brightness.dark))),
            ),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);
                final provider = Provider.of<AdminProvider>(context, listen: false);
                navigator.pop();
                final isSuccess = await provider.hapusTahapan(tahapan.id);
                if (context.mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(isSuccess ? 'Tahapan dihapus' : provider.errorMessage ?? 'Gagal menghapus', style: const TextStyle(color: Colors.white)),
                      backgroundColor: isSuccess ? AppTheme.greenAccent : AppTheme.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = _cardBg(isDark);
    final cardBorder = _cardBorder(isDark);
    final textPri = _textPri(isDark);
    final textSec = _textSec(isDark);
    final bg = _bg(isDark);

    return Scaffold(
      backgroundColor: bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: cardBg, border: Border.all(color: cardBorder)),
                      child: Icon(Icons.arrow_back_rounded, color: textPri, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Tahapan & Tarif Upah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPri)),
                  const Spacer(),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: cardBg, border: Border.all(color: cardBorder)),
                    child: Icon(Icons.info_outline, color: textSec, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.blueAccent));
          }

          final daftar = adminProvider.daftarTahapan;

          if (daftar.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_off_outlined, size: 64, color: textSec.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('Belum ada tahapan produksi', style: TextStyle(color: textSec)),
                  const SizedBox(height: 4),
                  Text('Tekan tombol + untuk menambahkan', style: TextStyle(color: textSec, fontSize: 12)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => adminProvider.fetchDaftarTahapan(),
            color: AppTheme.blueAccent,
            backgroundColor: cardBg,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: daftar.length,
              itemBuilder: (context, index) {
                final t = daftar[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
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
                          color: AppTheme.blueAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.work, color: AppTheme.blueAccent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.namaTahapan, style: TextStyle(fontWeight: FontWeight.bold, color: textPri, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                              'Tarif: ${Formatters.rupiah(t.tarifUpah)} / pasang',
                              style: TextStyle(color: AppTheme.greenAccent, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _tampilkanForm(context, tahapanLama: t),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.blueAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.edit_outlined, color: AppTheme.blueAccent, size: 18),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _konfirmasiHapus(context, t),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.delete_outline, color: AppTheme.redAccent, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: () => _tampilkanForm(context),
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.blueAccent,
            boxShadow: [BoxShadow(color: AppTheme.blueAccent.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}