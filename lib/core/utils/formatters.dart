// File: lib/core/utils/formatters.dart
// Utilitas format data untuk tampilan UI (Rupiah, Tanggal, dll)

import 'package:intl/intl.dart' as intl;

class Formatters {
  // Format angka integer menjadi format Rupiah (contoh: Rp 1.500.000)
  static String rupiah(num? angka) {
    if (angka == null) return 'Rp 0';
    final intl.NumberFormat formatter = intl.NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(angka);
  }

  // Format angka desimal (untuk stok bahan baku) dengan koma sebagai pemisah desimal
  static String angkaDesimal(num? angka, {int digit = 2}) {
    if (angka == null) return '0';
    return intl.NumberFormat.decimalPattern('id_ID')
        .format(double.parse(angka.toStringAsFixed(digit)));
  }

  // Format DateTime menjadi string tanggal Indonesia (contoh: 5 Juni 2026)
  static String tanggal(DateTime? tanggal) {
    if (tanggal == null) return '-';
    return intl.DateFormat('d MMMM yyyy', 'id_ID').format(tanggal);
  }

  // Format DateTime menjadi string tanggal lengkap dengan jam (contoh: 5 Jun 2026, 07:35)
  static String tanggalWaktu(DateTime? tanggal) {
    if (tanggal == null) return '-';
    return intl.DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(tanggal);
  }

  // Format DateTime menjadi string tanggal pendek (contoh: 05/06/2026)
  static String tanggalPendek(DateTime? tanggal) {
    if (tanggal == null) return '-';
    return intl.DateFormat('dd/MM/yyyy', 'id_ID').format(tanggal);
  }

  // Format DateTime menjadi bulan-tahun (contoh: Juni 2026)
  static String bulanTahun(DateTime? tanggal) {
    if (tanggal == null) return '-';
    return intl.DateFormat('MMMM yyyy', 'id_ID').format(tanggal);
  }

  // Mendapatkan tanggal hari ini dengan jam 00:00:00 (untuk filter harian)
  static DateTime awalHariIni() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Mendapatkan tanggal hari ini dengan jam 23:59:59 (untuk filter harian)
  static DateTime akhirHariIni() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  // Mendapatkan awal minggu ini (Senin)
  static DateTime awalMingguIni() {
    final now = DateTime.now();
    final daysFromMonday = now.weekday - 1;
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromMonday));
  }

  // Mendapatkan awal bulan ini
  static DateTime awalBulanIni() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
}
