-- ============================================================
-- FIX PALING AMPUH: Disable RLS untuk SEMUA tabel
-- ============================================================
--
-- CARA PALING SIMPEL & PASTI BERHASIL:
-- 1. Buka https://app.supabase.com → pilih project Anda
-- 2. Klik menu "SQL Editor" di sidebar kiri
-- 3. Klik "New query"
-- 4. Copy-paste SELURUH isi file ini
-- 5. Klik "Run" (Ctrl+Enter)
-- 6. Tunggu sampai "Success. No rows returned"
-- 7. Coba lagi simpan data tahapan di aplikasi
--
-- CATATAN: Ini untuk development. Untuk production, gunakan
-- policy yang lebih ketat (ada di bawah sebagai referensi).
-- ============================================================


-- ============================================================
-- CARA 1 (PALING AMPUH): Disable RLS Total
-- ============================================================
ALTER TABLE tb_master_tahapan DISABLE ROW LEVEL SECURITY;
ALTER TABLE tb_master_sepatu DISABLE ROW LEVEL SECURITY;
ALTER TABLE tb_bahan_baku DISABLE ROW LEVEL SECURITY;
ALTER TABLE tb_users DISABLE ROW LEVEL SECURITY;
ALTER TABLE tb_log_bahan DISABLE ROW LEVEL SECURITY;
ALTER TABLE tb_progres_produksi DISABLE ROW LEVEL SECURITY;
ALTER TABLE tb_qc_produksi DISABLE ROW LEVEL SECURITY;


-- ============================================================
-- CARA 2 (Alternatif): Buat Policy yang SUPER PERMISSIVE
-- Hanya jika Cara 1 tidak berhasil (sangat jarang)
-- ============================================================
-- DROP POLICY IF EXISTS "Allow all for authenticated" ON tb_master_tahapan;
-- CREATE POLICY "Allow all for authenticated"
-- ON tb_master_tahapan
-- FOR ALL
-- TO authenticated
-- USING (true)
-- WITH CHECK (true);
--
-- DROP POLICY IF EXISTS "Allow all for authenticated" ON tb_master_sepatu;
-- CREATE POLICY "Allow all for authenticated"
-- ON tb_master_sepatu
-- FOR ALL
-- TO authenticated
-- USING (true)
-- WITH CHECK (true);
--
-- DROP POLICY IF EXISTS "Allow all for authenticated" ON tb_bahan_baku;
-- CREATE POLICY "Allow all for authenticated"
-- ON tb_bahan_baku
-- FOR ALL
-- TO authenticated
-- USING (true)
-- WITH CHECK (true);
--
-- DROP POLICY IF EXISTS "Allow all for authenticated" ON tb_users;
-- CREATE POLICY "Allow all for authenticated"
-- ON tb_users
-- FOR ALL
-- TO authenticated
-- USING (true)
-- WITH CHECK (true);
--
-- DROP POLICY IF EXISTS "Allow all for authenticated" ON tb_log_bahan;
-- CREATE POLICY "Allow all for authenticated"
-- ON tb_log_bahan
-- FOR ALL
-- TO authenticated
-- USING (true)
-- WITH CHECK (true);
--
-- DROP POLICY IF EXISTS "Allow all for authenticated" ON tb_progres_produksi;
-- CREATE POLICY "Allow all for authenticated"
-- ON tb_progres_produksi
-- FOR ALL
-- TO authenticated
-- USING (true)
-- WITH CHECK (true);
--
-- DROP POLICY IF EXISTS "Allow all for authenticated" ON tb_qc_produksi;
-- CREATE POLICY "Allow all for authenticated"
-- ON tb_qc_produksi
-- FOR ALL
-- TO authenticated
-- USING (true)
-- WITH CHECK (true);


-- ============================================================
-- VERIFIKASI: Cek status RLS tiap tabel
-- ============================================================
SELECT
  schemaname,
  tablename,
  rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'tb_master_tahapan',
    'tb_master_sepatu',
    'tb_bahan_baku',
    'tb_users',
    'tb_log_bahan',
    'tb_progres_produksi',
    'tb_qc_produksi'
  )
ORDER BY tablename;

-- Hasil yang diharapkan: rowsecurity = 'f' (false = RLS disabled)
-- Jika masih 't' (true = RLS enabled), berarti ALTER TABLE gagal


-- ============================================================
-- CARA 3 (NUCLEAR OPTION): Hapus semua policy + Disable RLS
-- Gunakan ini jika masih error setelah menjalankan di atas
-- ============================================================
-- DO $$
-- DECLARE
--   r RECORD;
-- BEGIN
--   -- Hapus semua policy di setiap tabel
--   FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
--     EXECUTE 'DROP POLICY IF EXISTS "Allow all for authenticated" ON ' || r.tablename;
--     EXECUTE 'DROP POLICY IF EXISTS "Admin can manage tahapan" ON ' || r.tablename;
--     EXECUTE 'DROP POLICY IF EXISTS "Admin can manage sepatu" ON ' || r.tablename;
--     EXECUTE 'DROP POLICY IF EXISTS "Admin can manage bahan baku" ON ' || r.tablename;
--     EXECUTE 'DROP POLICY IF EXISTS "Admin can manage users" ON ' || r.tablename;
--     EXECUTE 'DROP POLICY IF EXISTS "Authenticated can read log bahan" ON ' || r.tablename;
--     EXECUTE 'DROP POLICY IF EXISTS "Gudang and Admin can insert log bahan" ON ' || r.tablename;
--     EXECUTE 'DROP POLICY IF EXISTS "Authenticated can manage progres" ON ' || r.tablename;
--     EXECUTE 'DROP POLICY IF EXISTS "Authenticated can manage qc" ON ' || r.tablename;
--   END LOOP;
-- END $$;
--
-- ALTER TABLE tb_master_tahapan DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE tb_master_sepatu DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE tb_bahan_baku DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE tb_users DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE tb_log_bahan DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE tb_progres_produksi DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE tb_qc_produksi DISABLE ROW LEVEL SECURITY;
