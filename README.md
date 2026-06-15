<div align="center">

# 👟 Sistem Informasi Produksi Sepatu

**Sistem manajemen produksi sepatu berbasis Android untuk home industri**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?logo=dart)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-2.5+-3FCF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

</div>

---

## 📋 Deskripsi

**Sistem Informasi Produksi Sepatu** adalah aplikasi Android yang dirancang untuk mengelola seluruh alur produksi sepatu pada skala home industri. Aplikasi ini menyediakan dashboard terpisah untuk tiga peran pengguna — **Admin**, **Pekerja**, dan **Gudang** — guna memastikan monitoring dan pengelolaan produksi yang efisien dan transparan.

Sistem ini dibangun menggunakan **Flutter** sebagai framework UI, **Supabase** sebagai backend (PostgreSQL, Autentikasi, & Realtime), serta **Provider** untuk manajemen state.

---

## ✨ Fitur Utama

### 🔐 Autentikasi & Otorisasi
- Login dengan email & password
- Role-based access control (RBAC) — Admin, Pekerja, Gudang
- Sesi pengguna menggunakan Supabase Auth

### 👑 Admin
- **Dashboard** — Ringkasan data produksi secara real-time
- **Manajemen Tahapan** — CRUD tahapan produksi sepatu
- **Katalog Sepatu** — Kelola data model sepatu beserta stok bagus/reject
- **Manajemen Pekerja** — Kelola data pekerja
- **Payroll** — Monitoring dan pengelolaan gaji pekerja
- **Laporan** — Analisis dan laporan produksi

### 🛠️ Pekerja
- **Dashboard** — Status dan ringkasan pekerjaan
- **Input Progres** — Catat progres produksi per tahapan
- **Riwayat Progres** — Histori progres produksi yang telah dicatat

### 📦 Gudang
- **Dashboard** — Status stok dan inventaris
- **Bahan Baku** — Kelola data bahan baku produksi
- **Log Bahan** — Catat pengeluaran/pemasukan bahan
- **Quality Control (QC)** — Input dan monitoring hasil QC

### 🎨 UI/UX
- **Dark Mode** — Tema gelap & terang yang dapat diaktifkan
- **Tipografi Google Fonts** — Tampilan modern dan minimalis
- **Format Lokal Indonesia** — Format Rupiah, tanggal, dan angka sesuai lokal

---

## 🏗️ Arsitektur Aplikasi

```
lib/
├── main.dart                          # Entry point aplikasi
├── core/
│   ├── constants/
│   │   └── api_constants.dart         # Konstanta API & Supabase
│   ├── theme/
│   │   └── app_theme.dart             # Tema aplikasi (light & dark)
│   └── utils/
│       └── formatters.dart            # Utilitas format Rupiah, tanggal, dll
├── data/
│   ├── models/
│   │   ├── sepatu_model.dart          # Model data sepatu
│   │   ├── user_model.dart            # Model data pengguna
│   │   ├── tahapan_model.dart         # Model tahapan produksi
│   │   ├── bahan_baku_model.dart      # Model bahan baku
│   │   ├── log_bahan_model.dart       # Model log penggunaan bahan
│   │   ├── progres_produksi_model.dart # Model progres produksi
│   │   └── qc_produksi_model.dart     # Model quality control
│   ├── repositories/
│   │   ├── auth_repository.dart       # Repositori autentikasi
│   │   ├── admin_repository.dart      # Repositori data admin
│   │   ├── worker_repository.dart     # Repositori data pekerja
│   │   └── warehouse_repository.dart  # Repositori data gudang
│   └── services/
│       └── supabase_service.dart      # Service Supabase client
├── logic/
│   ├── auth_provider.dart             # State manajemen autentikasi
│   ├── admin_provider.dart            # State manajemen admin
│   ├── worker_provider.dart           # State manajemen pekerja
│   └── theme_provider.dart            # State manajemen tema
└── ui/
    ├── screens/
    │   ├── login_screen.dart          # Layar login
    │   ├── admin/
    │   │   ├── admin_dashboard_screen.dart
    │   │   ├── tahapan_screen.dart
    │   │   ├── sepatu_katalog_screen.dart
    │   │   ├── pekerja_screen.dart
    │   │   ├── payroll_screen.dart
    │   │   └── laporan_screen.dart
    │   ├── worker/
    │   │   ├── worker_dashboard_screen.dart
    │   │   ├── input_progres_screen.dart
    │   │   └── riwayat_progres_screen.dart
    │   └── warehouse/
    │       ├── warehouse_dashboard_screen.dart
    │       ├── bahan_baku_screen.dart
    │       ├── riwayat_barang_screen.dart
    │       └── qc_screen.dart
    └── widgets/
        ├── custom_bottom_nav.dart     # Navigasi bawah (admin/worker)
        └── warehouse_bottom_nav.dart  # Navigasi bawah (gudang)
```

---

## 🗄️ Struktur Database (Supabase)

| Tabel | Deskripsi |
|-------|-----------|
| `tb_users` | Data pengguna (admin, pekerja, gudang) |
| `tb_master_tahapan` | Master data tahapan produksi |
| `tb_master_sepatu` | Katalog model sepatu & stok |
| `tb_bahan_baku` | Data stok bahan baku |
| `tb_log_bahan` | Log pengeluaran/pemasukan bahan baku |
| `tb_progres_produksi` | Catatan progres produksi per pekerja |
| `tb_qc_produksi` | Hasil quality control produksi |

---

## 🚀 Persiapan & Instalasi

### Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.2
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.2
- [Supabase Account](https://supabase.com) (gratis)
- Android Studio / VS Code
- Device atau emulator Android

### Langkah Instalasi

1. **Clone repository**

   ```bash
   git clone https://github.com/Ahmadwahyuapryanto/sepatu_produksi_app.git
   cd sepatu_produksi_app
   ```

2. **Install dependensi**

   ```bash
   flutter pub get
   ```

3. **Siapkan file `.env`**

   Buat file `.env` di root project:

   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

   > Dapatkan nilai-nilai tersebut dari **Supabase Dashboard → Project Settings → API**.

4. **Setup Database Supabase**

   - Buka [Supabase Dashboard](https://app.supabase.com)
   - Buka **SQL Editor** → jalankan script SQL yang diperlukan untuk membuat tabel-tabel di atas
   - Untuk development, jalankan `SUPABASE_RLS_POLICIES.sql` yang disertakan dalam repository

5. **Jalankan aplikasi**

   ```bash
   flutter run
   ```

---

## 📦 Dependensi

| Package | Versi | Fungsi |
|---------|-------|--------|
| `flutter` | SDK | Framework UI cross-platform |
| `supabase_flutter` | ^2.5.0 | Koneksi ke Supabase (Auth, Database, Realtime) |
| `provider` | ^6.1.2 | Manajemen state & logika bisnis |
| `flutter_dotenv` | ^5.1.0 | Pemuatan environment variables dari `.env` |
| `google_fonts` | ^6.2.1 | Tipografi UI dengan Google Fonts |
| `intl` | ^0.19.0 | Format tanggal, angka, dan mata uang (locale `id_ID`) |
| `shared_preferences` | ^2.2.2 | Persistensi preferensi pengguna (dark mode) |
| `cupertino_icons` | ^1.0.6 | Ikon standar iOS-style |

---

## 🛡️ Keamanan

- **Environment Variables** — Kredensial Supabase disimpan di file `.env` yang tidak di-commit ke version control
- **Row Level Security (RLS)** — Konfigurasi keamanan database tingkat baris tersedia di `SUPABASE_RLS_POLICIES.sql`
- **Role-Based Access** — Setiap pengguna hanya memiliki akses sesuai perannya

> ⚠️ **Catatan:** File `.env` tidak boleh di-commit ke repository. Pastikan `.env` sudah terdaftar di `.gitignore`.

---

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan fork repository ini dan buat pull request.

1. Fork repository
2. Buat branch fitur (`git checkout -b fitur/nama-fitur`)
3. Commit perubahan (`git commit -m 'Tambah fitur: nama fitur'`)
4. Push ke branch (`git push origin fitur/nama-fitur`)
5. Buka Pull Request

---

## 👨‍💻 Penulis

**Ahmad Wahyu Apryanto** — [GitHub](https://github.com/Ahmadwahyuapryanto)

---

## 📄 Lisensi

Proyek ini berlisensi di bawah Lisensi MIT — lihat file [LICENSE](LICENSE) untuk informasi lebih lanjut.

---

<div align="center">

*Dibuat dengan ❤️ menggunakan Flutter & Supabase*

</div>