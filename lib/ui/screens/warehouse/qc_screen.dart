import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/qc_produksi_model.dart';
import '../../../data/models/sepatu_model.dart';
import '../../../data/repositories/warehouse_repository.dart';
import '../../../logic/auth_provider.dart';

/// Model untuk data QC per hari
class _QcDailyData {
  final int jumlahBagus;
  final int jumlahReject;
  _QcDailyData({required this.jumlahBagus, required this.jumlahReject});
  int get total => jumlahBagus + jumlahReject;
}

class QcScreen extends StatefulWidget {
  final bool isDark;
  const QcScreen({super.key, this.isDark = true});

  @override
  State<QcScreen> createState() => _QcScreenState();
}

class _QcScreenState extends State<QcScreen> {
  final WarehouseRepository _repository = WarehouseRepository();
  List<SepatuModel> _sepatu = [];
  bool _loading = true;

  // Data QC untuk grafik
  List<QcProduksiDetail> _riwayatQc = [];
  Map<int, _QcDailyData> _weeklyData = {};

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
        _repository.getDaftarSepatu(),
        _repository.getRiwayatQcProduksi(limit: 500),
      ]);
      if (!mounted) return;
      _sepatu = results[0] as List<SepatuModel>;
      _riwayatQc = results[1] as List<QcProduksiDetail>;
      _hitungDataMingguan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat: $e'), backgroundColor: AppTheme.redAccent));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Menghitung data QC per hari dalam seminggu ini (Senin-Jumat)
  void _hitungDataMingguan() {
    _weeklyData = {};

    // Cari Senin minggu ini
    final now = DateTime.now();
    final dayOfWeek = now.weekday; // 1=Senin, 7=Minggu
    final monday = now.subtract(Duration(days: dayOfWeek - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    // Akhir minggu = Minggu (atau hari ini jika belum Minggu)
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    for (final detail in _riwayatQc) {
      final dt = detail.qc.createdAt;
      if (dt == null) continue;

      // Hanya data minggu ini (Sen-Min), skip jika di luar range
      if (dt.isBefore(startOfWeek) || dt.isAfter(endOfDay)) continue;

      final dayOfWeekIndex = dt.weekday; // 1=Sen, 5=Jum, 6=Sab, 7=Min
      // Hanya tampilkan Sen-Jum (1-5)
      if (dayOfWeekIndex < 1 || dayOfWeekIndex > 5) continue;

      final existing = _weeklyData[dayOfWeekIndex];
      if (existing != null) {
        _weeklyData[dayOfWeekIndex] = _QcDailyData(
          jumlahBagus: existing.jumlahBagus + detail.qc.jumlahBagus,
          jumlahReject: existing.jumlahReject + detail.qc.jumlahReject,
        );
      } else {
        _weeklyData[dayOfWeekIndex] = _QcDailyData(
          jumlahBagus: detail.qc.jumlahBagus,
          jumlahReject: detail.qc.jumlahReject,
        );
      }
    }
  }

  void _tampilkanFormQc(BuildContext context, SepatuModel sepatu) {
    final formKey = GlobalKey<FormState>();
    final bagusController = TextEditingController();
    final rejectController = TextEditingController();

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
                      Text('Penerimaan & QC', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textPri)),
                      IconButton(icon: Icon(Icons.close, color: _textSec), onPressed: () => Navigator.pop(modalContext)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(sepatu.namaModel, style: TextStyle(color: _textSec, fontSize: 14)),
                  Text('Stok Bagus: ${sepatu.stokBagus} | Reject: ${sepatu.stokReject}', style: TextStyle(color: _textSec, fontSize: 12)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: bagusController,
                    style: TextStyle(color: _textPri),
                    decoration: InputDecoration(
                      labelText: 'Jumlah Lolos QC (Bagus)',
                      labelStyle: TextStyle(color: _textSec),
                      prefixIcon: const Icon(Icons.check_circle, color: AppTheme.greenAccent),
                      filled: true,
                      fillColor: _cardBg,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.greenAccent, width: 1.5)),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi (boleh 0)';
                      final n = int.tryParse(v);
                      if (n == null || n < 0) return 'Masukkan angka valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: rejectController,
                    style: TextStyle(color: _textPri),
                    decoration: InputDecoration(
                      labelText: 'Jumlah Reject (Cacat)',
                      labelStyle: TextStyle(color: _textSec),
                      prefixIcon: const Icon(Icons.cancel, color: AppTheme.redAccent),
                      filled: true,
                      fillColor: _cardBg,
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.redAccent, width: 1.5)),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Wajib diisi (boleh 0)';
                      final n = int.tryParse(v);
                      if (n == null || n < 0) return 'Masukkan angka valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.blueAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.blueAccent.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.blueAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Stok akan bertambah otomatis. Upah pekerja TIDAK dipotong dari barang reject.',
                            style: TextStyle(fontSize: 11, color: _textSec),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        final navigator = Navigator.of(modalContext);
                        final messenger = ScaffoldMessenger.of(context);
                        final userId = context.read<AuthProvider>().currentUser?.id;
                        if (userId == null) return;
                        final qc = QcProduksiModel(
                          idSepatu: sepatu.id, idUser: userId,
                          jumlahBagus: int.parse(bagusController.text.trim()),
                          jumlahReject: int.parse(rejectController.text.trim()),
                        );
                        try {
                          await _repository.insertQcProduksi(qc);
                          navigator.pop();
                          await _muat();
                          messenger.showSnackBar(const SnackBar(content: Text('Penerimaan barang berhasil dicatat'), backgroundColor: AppTheme.greenAccent));
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
                      child: const Center(child: Text('Simpan QC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
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

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Text('Input Quality Control', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textPri)),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _cardBg, border: Border.all(color: _cardBorder)),
            child: Icon(Icons.help_outline, color: _textSec, size: 20),
          ),
        ],
      ),
    );

    if (_sepatu.isEmpty) {
      return Column(
        children: [
          header,
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_outlined, size: 64, color: _textSec.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('Belum ada katalog sepatu', style: TextStyle(color: _textSec)),
                  const SizedBox(height: 4),
                  Text('Hubungi Admin', style: TextStyle(color: _textSec, fontSize: 12), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Hitung total dari data real
    int totalBagus = 0;
    int totalReject = 0;
    for (final entry in _weeklyData.values) {
      totalBagus += entry.jumlahBagus;
      totalReject += entry.jumlahReject;
    }
    final totalAll = totalBagus + totalReject;

    return RefreshIndicator(
      onRefresh: _muat,
      color: AppTheme.blueAccent,
      backgroundColor: _cardBg,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          header,
          const SizedBox(height: 12),
          // QC Guide card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.blueAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on, color: AppTheme.blueAccent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Panduan QC', style: TextStyle(fontWeight: FontWeight.bold, color: _textPri, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          'Periksa kebersihan sepatu, jahitan, dan kelengkapan box sebelum menekan tombol \'Catat\'.',
                          style: TextStyle(color: _textSec, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Pilih Model Sepatu header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Pilih Model Sepatu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPri)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.blueAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${_sepatu.length} Model', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.blueAccent)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Shoe cards with info + button
          ..._sepatu.map((s) {
            final totalStok = s.stokBagus + s.stokReject;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppTheme.blueAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.blueAccent, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.namaModel, style: TextStyle(fontWeight: FontWeight.bold, color: _textPri, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text('Batch: B-${20 + s.id}001', style: TextStyle(fontSize: 11, color: _textSec)),
                              Text('Stok: $totalStok Pcs', style: TextStyle(fontSize: 11, color: _textSec)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _tampilkanFormQc(context, s),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.blueAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_task, color: AppTheme.blueAccent, size: 18),
                          const SizedBox(width: 6),
                          Text('Catat Penerimaan & QC', style: TextStyle(color: AppTheme.blueAccent, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          // Status QC Minggu Ini (real data)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Status QC Minggu Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPri)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cardBorder),
              ),
              child: Column(
                children: [
                  // Line chart dari data real
                  SizedBox(
                    height: 140,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _QcLineChartPainter(
                        weeklyData: _weeklyData,
                        isDark: _isDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.greenAccent)),
                      const SizedBox(width: 6),
                      Text('Passed: $totalBagus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.greenAccent)),
                      const SizedBox(width: 16),
                      Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.redAccent)),
                      const SizedBox(width: 6),
                      Text('Rejected: $totalReject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.redAccent)),
                      const SizedBox(width: 16),
                      Text('Total: $totalAll', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textPri)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

/// CustomPainter untuk line chart QC mingguan
/// Garis hijau = jumlah lolos QC (bagus)
/// Garis merah = jumlah reject (cacat)
class _QcLineChartPainter extends CustomPainter {
  final Map<int, _QcDailyData> weeklyData;
  final bool isDark;

  _QcLineChartPainter({required this.weeklyData, required this.isDark});

  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum'];
  static const _green = AppTheme.greenAccent;
  static const _red = AppTheme.redAccent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ruang untuk label hari di bawah
    final bottomPadding = 24.0;
    final topPadding = 16.0;
    final leftPadding = 4.0;
    final rightPadding = 4.0;
    final chartH = h - bottomPadding - topPadding;
    final chartW = w - leftPadding - rightPadding;

    // Cari max value untuk normalisasi
    int maxVal = 1;
    for (final entry in weeklyData.values) {
      if (entry.jumlahBagus > maxVal) maxVal = entry.jumlahBagus;
      if (entry.jumlahReject > maxVal) maxVal = entry.jumlahReject;
    }

    // Titik-titik untuk garis hijau (passed) dan merah (rejected)
    final greenPoints = <Offset>[];
    final redPoints = <Offset>[];

    for (int i = 0; i < 5; i++) {
      final weekday = i + 1; // 1=Sen ... 5=Jum
      final x = leftPadding + (i / 4) * chartW;
      final data = weeklyData[weekday];

      final passedVal = data?.jumlahBagus ?? 0;
      final rejectVal = data?.jumlahReject ?? 0;

      final yPassed = topPadding + chartH - (passedVal / maxVal) * chartH;
      final yReject = topPadding + chartH - (rejectVal / maxVal) * chartH;

      greenPoints.add(Offset(x, yPassed));
      redPoints.add(Offset(x, yReject));
    }

    // --- Gambar grid lines tipis ---
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 0.5;
    for (int i = 1; i <= 4; i++) {
      final y = topPadding + (i / 4) * chartH;
      canvas.drawLine(Offset(leftPadding, y), Offset(w - rightPadding, y), gridPaint);
    }

    // --- Gambar garis hijau (passed) ---
    _drawLine(canvas, greenPoints, _green, 2.5);
    // --- Gambar garis merah (rejected) ---
    _drawLine(canvas, redPoints, _red, 2.5);

    // --- Gambar titik data points ---
    _drawDots(canvas, greenPoints, _green);
    _drawDots(canvas, redPoints, _red);

    // --- Gambar label hari di bawah ---
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    final labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMediumEmphasis,
    );

    for (int i = 0; i < 5; i++) {
      final x = leftPadding + (i / 4) * chartW;
      labelPainter.text = TextSpan(text: _days[i], style: labelStyle);
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(x - labelPainter.width / 2, h - bottomPadding + 4),
      );
    }

    // --- Gambar angka di atas titik data ---
    final valueStyle = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w700,
      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textHighEmphasis,
    );
    final valuePainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 5; i++) {
      final weekday = i + 1;
      final data = weeklyData[weekday];
      if (data == null) continue;

      if (data.jumlahBagus > 0) {
        valuePainter.text = TextSpan(text: '${data.jumlahBagus}', style: valueStyle.copyWith(color: _green));
        valuePainter.layout();
        valuePainter.paint(canvas, Offset(greenPoints[i].dx - valuePainter.width / 2, greenPoints[i].dy - 14));
      }
      if (data.jumlahReject > 0) {
        valuePainter.text = TextSpan(text: '${data.jumlahReject}', style: valueStyle.copyWith(color: _red));
        valuePainter.layout();
        valuePainter.paint(canvas, Offset(redPoints[i].dx - valuePainter.width / 2, redPoints[i].dy - 14));
      }
    }
  }

  void _drawLine(Canvas canvas, List<Offset> points, Color color, double strokeWidth) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      // Smooth curve menggunakan quadratic bezier
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      path.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(path, paint);

    // Area fill di bawah garis (transparan gradient)
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTRB(points.first.dx, 0, points.last.dx, points.first.dy + 20));
    
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, points.first.dy + 40);
    fillPath.lineTo(points.first.dx, points.first.dy + 40);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
  }

  void _drawDots(Canvas canvas, List<Offset> points, Color color) {
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isDark ? AppTheme.darkCard : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final p in points) {
      // White border circle
      canvas.drawCircle(p, 5, borderPaint);
      // Colored dot
      canvas.drawCircle(p, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _QcLineChartPainter oldDelegate) {
    return oldDelegate.weeklyData != weeklyData || oldDelegate.isDark != isDark;
  }
}
