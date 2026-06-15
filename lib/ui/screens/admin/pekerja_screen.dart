import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../logic/admin_provider.dart';
import '../../../data/models/user_model.dart';

class PekerjaScreen extends StatefulWidget {
  const PekerjaScreen({super.key});

  @override
  State<PekerjaScreen> createState() => _PekerjaScreenState();
}

class _PekerjaScreenState extends State<PekerjaScreen> {
  String _filterAktif = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchDaftarPegawai();
    });
  }

  List<UserModel> _terapkanFilter(List<UserModel> semua) {
    if (_filterAktif == 'Semua') return semua;
    if (_filterAktif == 'Gudang') return semua.where((p) => p.role == 'GUDANG').toList();
    if (_filterAktif == 'Pekerja') return semua.where((p) => p.role == 'PEKERJA').toList();
    return semua;
  }

  Color _warnaRole(String role) {
    switch (role) {
      case 'ADMIN': return AppTheme.amberAccent;
      case 'GUDANG': return AppTheme.blueAccent;
      case 'PEKERJA': return AppTheme.greenAccent;
      default: return AppTheme.textMediumEmphasis;
    }
  }

  void _tampilkanFormTambahPegawai() {
    final formKey = GlobalKey<FormState>();
    final namaC = TextEditingController();
    final emailC = TextEditingController();
    final passC = TextEditingController();
    final nohpC = TextEditingController();
    String selectedRole = 'PEKERJA';

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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tambah Pegawai Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPri)),
                      IconButton(icon: Icon(Icons.close, color: textSec), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildField(namaC, 'Nama Lengkap', 'Contoh: Budi Santoso', Icons.person, textPri, textSec, cardBg, cardBorder),
                  const SizedBox(height: 12),
                  _buildField(emailC, 'Email', 'contoh@email.com', Icons.email, textPri, textSec, cardBg, cardBorder),
                  const SizedBox(height: 12),
                  _buildField(passC, 'Password', 'Minimal 6 karakter', Icons.lock, textPri, textSec, cardBg, cardBorder, obscure: true),
                  const SizedBox(height: 12),
                  _buildField(nohpC, 'No. HP', '08xxxxxxxxxx', Icons.phone, textPri, textSec, cardBg, cardBorder),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    style: TextStyle(color: textPri),
                    dropdownColor: cardBg,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      labelStyle: TextStyle(color: textSec),
                      prefixIcon: const Icon(Icons.badge, color: AppTheme.blueAccent),
                      filled: true, fillColor: cardBg,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.blueAccent, width: 1.5)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'PEKERJA', child: Text('Pekerja')),
                      DropdownMenuItem(value: 'GUDANG', child: Text('Gudang')),
                    ],
                    onChanged: (v) => selectedRole = v ?? 'PEKERJA',
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        final adm = context.read<AdminProvider>();
                        final ok = await adm.tambahPegawai(emailC.text.trim(), passC.text.trim(), namaC.text.trim(), selectedRole, nohpC.text.trim());
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok ? 'Pegawai berhasil ditambahkan' : adm.errorMessage ?? 'Gagal'),
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
          ),
        );
      },
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, String hint, IconData icon, Color textPri, Color textSec, Color cardBg, Color cardBorder, {bool obscure = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      style: TextStyle(color: textPri),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: textSec),
        hintStyle: TextStyle(color: textSec.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, color: AppTheme.blueAccent),
        filled: true, fillColor: cardBg,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.blueAccent, width: 1.5)),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return '$label wajib diisi';
        if (label == 'Email' && !v.contains('@')) return 'Format email tidak valid';
        if (label == 'Password' && v.length < 6) return 'Minimal 6 karakter';
        return null;
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
      builder: (context, adminProvider, _) {
        final filtered = _terapkanFilter(adminProvider.daftarPegawai);
        final total = adminProvider.daftarPegawai.length;
        final aktif = adminProvider.daftarPegawai.where((p) => p.role != 'ADMIN').length;

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
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.gradientStart, AppTheme.gradientEnd]), borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kekompakan Tim', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Total Personil', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              Text('$total Orang', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                            ])),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Aktif Hari Ini', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              Row(children: [
                                Text('$aktif', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                                const SizedBox(width: 6),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppTheme.greenAccent.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6)), child: const Text('100%', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))),
                              ]),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: ['Semua', 'Gudang', 'Pekerja'].map((f) {
                      final selected = _filterAktif == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _filterAktif = f),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(color: selected ? AppTheme.blueAccent : Colors.transparent, borderRadius: BorderRadius.circular(20), border: selected ? null : Border.all(color: cardBorder)),
                            child: Text(f, style: TextStyle(color: selected ? Colors.white : textSec, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      Text('Daftar Pegawai', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textPri)),
                      const Spacer(),
                      Text('${filtered.length} orang', style: TextStyle(fontSize: 12, color: textSec)),
                    ],
                  ),
                ),
                Expanded(
                  child: adminProvider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.blueAccent))
                      : filtered.isEmpty
                          ? Center(child: Text('Tidak ada data pegawai', style: TextStyle(color: textSec)))
                          : RefreshIndicator(
                              onRefresh: () => adminProvider.fetchDaftarPegawai(),
                              color: AppTheme.blueAccent, backgroundColor: cardBg,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                                itemCount: filtered.length,
                                itemBuilder: (context, i) => _buildPegawaiCard(filtered[i], cardBg, cardBorder, textPri, textSec),
                              ),
                            ),
                ),
              ],
            ),
            // FAB Tambah Pegawai
            Positioned(
              right: 16, bottom: 16,
              child: GestureDetector(
                onTap: _tampilkanFormTambahPegawai,
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.blueAccent, boxShadow: [BoxShadow(color: AppTheme.blueAccent.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]),
                  child: const Icon(Icons.person_add, color: Colors.white, size: 26),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPegawaiCard(UserModel p, Color cardBg, Color cardBorder, Color textPri, Color textSec) {
    final color = _warnaRole(p.role);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: cardBorder)),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(child: Text(p.namaLengkap.isNotEmpty ? p.namaLengkap[0].toUpperCase() : '?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(p.namaLengkap, style: TextStyle(fontWeight: FontWeight.w600, color: textPri, fontSize: 14))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(p.role, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold))),
              ]),
              if (p.noHp != null && p.noHp!.isNotEmpty) ...[const SizedBox(height: 4), Text('📞 ${p.noHp}', style: TextStyle(color: textSec, fontSize: 12))],
            ]),
          ),
        ],
      ),
    );
  }
}