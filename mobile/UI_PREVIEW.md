# Pratinjau UI Workshop UNAND

Implementasi Flutter mengikuti [referensi Figma](https://score-plant-12480283.figma.site/): font Inter, hijau `#14532D`, kartu kegiatan, gambar kampus, latar `#F7F8FA`, dan navigasi empat menu. Pada layar besar, antarmuka dibatasi hingga 430 px seperti referensi. Gambar dan font dibundel sehingga tidak memerlukan jaringan saat ditampilkan.

## Menjalankan

Dari folder `mobile`:

```powershell
flutter pub get
flutter run
```

Untuk menjalankan tampilan di browser Chrome:

```powershell
flutter run -d chrome
```

Dukungan web sudah disiapkan di folder `web`; tidak perlu `npm install` atau server backend untuk menjelajahi data contoh.

Pilih **Masuk sebagai Mahasiswa** untuk menjelajahi data contoh. Form peserta umum memvalidasi email dan kata sandi minimal enam karakter. Jangan gunakan kata sandi asli untuk pratinjau.

## Halaman dan interaksi

- Login mahasiswa/peserta umum dan formulir pendaftaran akun.
- Beranda dengan pencarian, filter jenis kegiatan, kartu unggulan, dan daftar kegiatan. Setiap kartu menampilkan label Online (ikon video) untuk kegiatan daring atau nama tempat (ikon lokasi) untuk kegiatan luring sebelum detail dibuka; label juga muncul di Kegiatan Saya dan detail kegiatan. Nama tempat yang panjang dapat membungkus ke baris berikutnya agar tetap terbaca.
- Detail kegiatan dengan informasi pelaksanaan, narasumber, manfaat, kuota, serta dialog konfirmasi dan hasil pendaftaran.
- Kegiatan Saya dengan tab Akan Datang, Berlangsung, dan Selesai.
- Presensi dengan delapan pilihan hasil simulasi; keberhasilan mengubah status kehadiran lokal.
- Daftar, pratinjau, dan formulir perbaikan sertifikat.
- Notifikasi dengan penanda belum dibaca dan aksi tandai semua dibaca.
- Profil, edit data, konfirmasi keluar, dan akses diagnostik server.

## Data contoh dan integrasi

Tanggal, isi kegiatan, identitas peserta contoh, dan gambar mengikuti Figma. Tahun 2025 dipertahankan sebagai isi prototipe, bukan jadwal kegiatan aktual.

State pratinjau dikelola oleh `lib/core/demo/preview_data.dart` menggunakan Riverpod. Login tidak melakukan autentikasi server atau membuat token. Pendaftaran akun/kegiatan, perubahan profil, presensi, dan pengajuan perbaikan hanya mendemonstrasikan alur UI. State kembali ke data awal saat keluar atau aplikasi dimulai ulang.

Pemindaian tidak mengakses kamera/GPS. Sertifikat diberi penanda pratinjau; tombol unduh menjelaskan bahwa dokumen resmi belum tersedia. Tidak ada PDF resmi atau tanda tangan elektronik yang dibuat. Integrasi API, SSO UNAND, kamera/GPS, unduhan resmi, dan penyimpanan permanen tetap memerlukan implementasi backend terkait. Diagnostik `/health` tetap memakai layanan API yang sudah ada.

Inter dimuat dari aset lokal dengan lisensi OFL di `assets/fonts/OFL.txt`; foto memakai aset Unsplash yang sama dengan referensi. Logo UNAND memakai gambar yang diberikan pengguna di `assets/images/unand-logo.png`, termasuk logo header, pratinjau sertifikat, dan ikon browser.

## Pemeriksaan

```powershell
flutter test
```

Pengujian mencakup validasi formulir, pencarian/filter, pembatalan dan konfirmasi pendaftaran, larangan duplikasi/kuota penuh, navigasi, perubahan profil, notifikasi, presensi, pengajuan koreksi, logout, serta tata letak 320 px dan pembesaran teks.
