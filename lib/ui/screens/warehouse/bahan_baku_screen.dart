import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/bahan_baku_model.dart';
import '../../../data/models/log_bahan_model.dart';
import '../../../data/repositories/warehouse_repository.dart';
import '../../../logic/auth_provider.dart';

class BahanBakuScreen extends StatefulWidget {
  final bool isDark;
  const BahanBakuScreen({super.key, this.isDark = true});

  @override
  State<BahanBakuScreen> createState() => _BahanBakuScreenState();
}

class _BahanBakuScreenState extends State<BahanBakuScreen> {
  final WarehouseRepository _repository = WarehouseRepository();
  List<BahanBakuModel> _bahanBaku = [];
  bool _loading = true;
  String _filter = '';

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
      _bahanBaku = await _repository.getDaftarBahanBaku();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat: $e'), backgroundColor: AppTheme.redAccent));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _tampilkanFormTambahBahanBaku(BuildContext context, {BahanBakuModel? bahan}) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: bahan?.namaBahan);
    final satuanController = TextEditingController(text: bahan?.satuan);
    final isEdit = bahan != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
      builder: (BuildContext modalContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(modalContext).viewInsets.bottom, left: 24, right: 24, top: 24),
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
                      Text(isEdit ? 'Ubah Jenis Bahan Baku' : 'Tambah Jenis Bahan Baku', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textPri)),
                      IconButton(icon: Icon(Icons.close, color: _textSec), onPressed: () => Navigator.pop(modalContext)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: namaController,
                    style: TextStyle(color: _textPri),
                    decoration: InputDecoration(
                      labelText: 'Nama Bahan Baku',
                      labelStyle: TextStyle(color: _textSec),
                      prefixIcon: const Icon(Icons.inventory_2, color: AppTheme.blueAccent),
                      filled: true,
                      fillColor: _cardBg,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.blueAccent, width: 1.5)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Nama bahan baku wajib diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: satuanController,
                    style: TextStyle(color: _textPri),
                    decoration: InputDecoration(
                      labelText: 'Satuan',
                      hintText: 'Contoh: kg, meter, lembar',
                      hintStyle: TextStyle(color: _textSec.withValues(alpha: 0.5)),
                      labelStyle: TextStyle(color: _textSec),
                      prefixIcon: const Icon(Icons.straighten, color: AppTheme.blueAccent),
                      filled: true,
                      fillColor: _cardBg,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.blueAccent, width: 1.5)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Satuan wajib diisi';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        final navigator = Navigator.of(modalContext);
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          if (isEdit) {
                            final updatedBahan = BahanBakuModel(id: bahan.id, namaBahan: namaController.text.trim(), satuan: satuanController.text.trim(), totalStok: bahan.totalStok);
                            await _repository.updateBahanBaku(updatedBahan);
                            messenger.showSnackBar(const SnackBar(content: Text('Berhasil memperbarui'), backgroundColor: AppTheme.greenAccent));
                          } else {
                            await _repository.tambahBahanBaku(namaController.text.trim(), satuanController.text.trim());
                            messenger.showSnackBar(const SnackBar(content: Text('Berhasil menambahkan'), backgroundColor: AppTheme.greenAccent));
                          }
                          navigator.pop();
                          await _muat();
                        } catch (e) {
                          navigator.pop();
                          messenger.showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppTheme.redAccent));
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.gradientStart, AppTheme.gradientEnd]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
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

  void _tampilkanFormTransaksi(BuildContext context, BahanBakuModel bahan, {required String tipe}) {
    final formKey = GlobalKey<FormState>();
    final jumlahController = TextEditingController();
    final ketController = TextEditingController();
    final isMasuk = tipe == 'MASUK';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
      builder: (BuildContext modalContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(modalContext).viewInsets.bottom, left: 24, right: 24, top: 24),
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
                      Text(isMasuk ? 'Catat Bahan Masuk' : 'Catat Bahan Keluar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textPri)),
                      IconButton(icon: Icon(Icons.close, color: _textSec), onPressed: () => Navigator.pop(modalContext)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(bahan.namaBahan, style: TextStyle(color: _textSec, fontSize: 14)),
                  Text('Stok saat ini: ${Formatters.angkaDesimal(bahan.totalStok)} ${bahan.satuan}', style: TextStyle(color: _textSec, fontSize: 12)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: jumlahController,
                    style: TextStyle(color: _textPri),
                    decoration: InputDecoration(
                      labelText: 'Jumlah (${bahan.satuan})',
                      labelStyle: TextStyle(color: _textSec),
                      prefixIcon: Icon(isMasuk ? Icons.add : Icons.remove, color: isMasuk ? AppTheme.greenAccent : AppTheme.redAccent),
                      filled: true,
                      fillColor: _cardBg,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isMasuk ? AppTheme.greenAccent : AppTheme.redAccent, width: 1.5)),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Jumlah wajib diisi';
                      final n = double.tryParse(value);
                      if (n == null || n <= 0) return 'Jumlah harus lebih dari 0';
                      if (!isMasuk && n > bahan.totalStok) return 'Stok tidak cukup';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ketController,
                    style: TextStyle(color: _textPri),
                    decoration: InputDecoration(
                      labelText: 'Keterangan (opsional)',
                      labelStyle: TextStyle(color: _textSec),
                      prefixIcon: const Icon(Icons.note_outlined, color: AppTheme.blueAccent),
                      filled: true,
                      fillColor: _cardBg,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.blueAccent, width: 1.5)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        final navigator = Navigator.of(modalContext);
                        final messenger = ScaffoldMessenger.of(context);
                        final userId = context.read<AuthProvider>().currentUser?.id;
                        if (userId == null) return;
                        final log = LogBahanModel(
                          idBahan: bahan.id, idUser: userId, tipeTransaksi: tipe,
                          jumlah: double.parse(jumlahController.text.trim()),
                          keterangan: ketController.text.trim().isEmpty ? null : ketController.text.trim(),
                        );
                        try {
                          await _repository.insertLogBahan(log);
                          navigator.pop();
                          await _muat();
                          messenger.showSnackBar(SnackBar(content: Text('Berhasil mencatat ${isMasuk ? "bahan masuk" : "bahan keluar"}'), backgroundColor: AppTheme.greenAccent));
                        } catch (e) {
                          navigator.pop();
                          messenger.showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppTheme.redAccent));
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [isMasuk ? const Color(0xFF059669) : const Color(0xFFDC2626), isMasuk ? AppTheme.greenAccent : AppTheme.redAccent]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
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

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppTheme.blueAccent));

    final listFilter = _filter.isEmpty
        ? _bahanBaku
        : _bahanBaku.where((b) => b.namaBahan.toLowerCase().contains(_filter.toLowerCase())).toList();

    int totalStok = 0;
    int stokRendah = 0;
    for (final b in _bahanBaku) {
      totalStok += b.totalStok.toInt();
      if (b.totalStok <= 5) stokRendah++;
    }

    return Stack(
      children: [
        Column(
          children: [
            // Header "Materials" + bell icon
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Text('Materials', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textPri)),
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
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            style: TextStyle(color: _textPri),
            decoration: InputDecoration(
              hintText: 'Cari material...',
              hintStyle: TextStyle(color: _textSec.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.search, color: _textSec),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: _cardBorder)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune, color: _textSec, size: 16),
                    const SizedBox(width: 4),
                    Text('Filters', style: TextStyle(color: _textSec, fontSize: 12)),
                  ],
                ),
              ),
              filled: true,
              fillColor: _cardBg,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _cardBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.blueAccent, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (v) => setState(() => _filter = v),
          ),
        ),
        // Status Inventaris
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status Inventaris', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textPri)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildInventarisCard('TOTAL STOK', '${_isDark ? totalStok : totalStok}', 'Unit', AppTheme.blueAccent)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInventarisCard('STOK RENDAH', '$stokRendah', 'Items', AppTheme.redAccent)),
                ],
              ),
            ],
          ),
        ),
        // Daftar Material header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text('Daftar Material', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textPri)),
              const Spacer(),
              Text('Total ${listFilter.length} item', style: TextStyle(fontSize: 12, color: _textSec)),
            ],
          ),
        ),
        // List
        Expanded(
          child: listFilter.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: _textSec.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('Belum ada data bahan baku', style: TextStyle(color: _textSec)),
                      const SizedBox(height: 4),
                      Text('Tekan tombol + di bawah', style: TextStyle(color: _textSec, fontSize: 12)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _muat,
                  color: AppTheme.blueAccent,
                  backgroundColor: _cardBg,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: listFilter.length,
                    itemBuilder: (context, i) {
                      final b = listFilter[i];
                      final isKritis = b.totalStok <= 5;
                      return _buildMaterialCard(b, isKritis);
                    },
                  ),
                ),
          ),
        ],
       ),
       // FAB
       Positioned(
         right: 16,
         bottom: 16,
         child: GestureDetector(
           onTap: () => _tampilkanFormTambahBahanBaku(context),
           child: Container(
             width: 56,
             height: 56,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: AppTheme.blueAccent,
               boxShadow: [
                 BoxShadow(color: AppTheme.blueAccent.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
               ],
             ),
             child: const Icon(Icons.add, color: Colors.white, size: 28),
           ),
         ),
       ),
      ],
    );
  }

  Widget _buildInventarisCard(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _textSec)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(unit, style: TextStyle(fontSize: 11, color: _textSec)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(BahanBakuModel b, bool isKritis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isKritis ? AppTheme.redAccent : AppTheme.blueAccent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isKritis ? Icons.warning_amber : Icons.inventory_2,
                  color: isKritis ? AppTheme.redAccent : AppTheme.blueAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.namaBahan, style: TextStyle(fontWeight: FontWeight.bold, color: _textPri, fontSize: 14)),
                    Text('SKU: ${b.namaBahan.substring(0, b.namaBahan.length > 3 ? 3 : b.namaBahan.length).toUpperCase()}', style: TextStyle(color: _textSec, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isKritis ? AppTheme.redAccent : AppTheme.greenAccent).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isKritis ? 'STOK RENDAH' : 'STOK AMAN',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isKritis ? AppTheme.redAccent : AppTheme.greenAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stok Saat Ini', style: TextStyle(fontSize: 10, color: _textSec)),
                    Text(
                      '${Formatters.angkaDesimal(b.totalStok)} ${b.satuan}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isKritis ? AppTheme.redAccent : _textPri),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lokasi', style: TextStyle(fontSize: 10, color: _textSec)),
                    Text('Rak ${String.fromCharCode(65 + (b.id % 5))}-${(b.id % 9) + 1}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPri)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _tampilkanFormTransaksi(context, b, tipe: 'MASUK'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.blueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        const Text('Masuk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _tampilkanFormTransaksi(context, b, tipe: 'KELUAR'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove, color: _textSec, size: 16),
                        const SizedBox(width: 4),
                        Text('Keluar', style: TextStyle(color: _textSec, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}