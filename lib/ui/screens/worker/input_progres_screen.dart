import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/progres_produksi_model.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/worker_provider.dart';

class InputProgresScreen extends StatefulWidget {
  const InputProgresScreen({super.key});

  @override
  State<InputProgresScreen> createState() => _InputProgresScreenState();
}

class _InputProgresScreenState extends State<InputProgresScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedSepatu;
  int? _selectedTahapan;
  final _jumlahController = TextEditingController();

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  int? _estimasiGaji() {
    if (_selectedTahapan == null) return null;
    final jumlah = int.tryParse(_jumlahController.text);
    if (jumlah == null || jumlah <= 0) return null;
    final tahapan = context.read<WorkerProvider>().daftarTahapan
        .firstWhere((t) => t.id == _selectedTahapan, orElse: () => throw Exception('Tahapan tidak ditemukan'));
    return jumlah * tahapan.tarifUpah;
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSepatu == null || _selectedTahapan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih sepatu dan tahapan terlebih dahulu'),
          backgroundColor: AppTheme.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final progres = ProgresProduksiModel(
      idPekerja: userId,
      idSepatu: _selectedSepatu!,
      idTahapan: _selectedTahapan!,
      jumlahSelesai: int.parse(_jumlahController.text.trim()),
    );

    final provider = context.read<WorkerProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final isSuccess = await provider.submitProgres(progres);

    if (!mounted) return;

    if (isSuccess) {
      _jumlahController.clear();
      setState(() {
        _selectedSepatu = null;
        _selectedTahapan = null;
      });
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Progres berhasil disimpan!', style: TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.greenAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal menyimpan', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppTheme.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = WorkerColors(context);

    return Consumer<WorkerProvider>(
      builder: (context, worker, _) {
        if (worker.daftarSepatu.isEmpty || worker.daftarTahapan.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 48, color: colors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data sepatu atau tahapan.\nHubungi Admin untuk menambahkan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            onChanged: () => setState(() {}),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.iconBg(colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.info_outline, color: colors.blue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Catat progres pekerjaan harian Anda di sini. Estimasi gaji dihitung otomatis.',
                          style: TextStyle(color: colors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Dropdown Sepatu
                _buildDropdown<int>(
                  colors: colors,
                  value: _selectedSepatu,
                  hint: 'Pilih Model Sepatu',
                  icon: Icons.style_rounded,
                  items: worker.daftarSepatu
                      .map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.namaModel)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSepatu = v),
                  validator: (v) => v == null ? 'Pilih model sepatu' : null,
                ),
                const SizedBox(height: 16),

                // Dropdown Tahapan
                _buildDropdown<int>(
                  colors: colors,
                  value: _selectedTahapan,
                  hint: 'Pilih Tahapan / Divisi',
                  icon: Icons.work_outline_rounded,
                  items: worker.daftarTahapan.map((t) {
                    return DropdownMenuItem<int>(
                      value: t.id,
                      child: Text('${t.namaTahapan} (${Formatters.rupiah(t.tarifUpah)}/pasang)'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedTahapan = v),
                  validator: (v) => v == null ? 'Pilih tahapan' : null,
                ),
                const SizedBox(height: 16),

                // Input Jumlah
                TextFormField(
                  controller: _jumlahController,
                  style: TextStyle(color: colors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Masukkan jumlah',
                    hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.5)),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.iconBg(colors.blue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.tag, color: colors.blue, size: 20),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 52),
                    filled: true,
                    fillColor: colors.cardBg,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.blue, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.red, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Jumlah tidak boleh kosong';
                    final n = int.tryParse(value);
                    if (n == null) return 'Masukkan angka yang valid';
                    if (n <= 0) return 'Jumlah harus lebih dari 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Estimasi Gaji Realtime
                if (_estimasiGaji() != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.iconBg(colors.green),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.payments_rounded, color: colors.green, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Estimasi Gaji:',
                          style: TextStyle(fontWeight: FontWeight.w600, color: colors.green, fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          Formatters.rupiah(_estimasiGaji()),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // Tombol Simpan
                GestureDetector(
                  onTap: worker.isLoading ? null : _simpan,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: worker.isLoading
                          ? null
                          : colors.primaryGradient,
                      color: worker.isLoading ? colors.cardBorder : null,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: worker.isLoading
                          ? null
                          : [
                              BoxShadow(
                                color: colors.gradientEndColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: worker.isLoading
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: colors.textSecondary, strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Simpan Progres',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown<T>({
    required WorkerColors colors,
    required T? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      style: TextStyle(color: colors.textPrimary, fontSize: 14),
      dropdownColor: colors.cardBg,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.textSecondary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.5)),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.iconBg(colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colors.blue, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 52),
        filled: true,
        fillColor: colors.cardBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}