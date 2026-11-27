# Pratinjau UI Workshop UNAND

Tampilan diseragamkan dengan portal web peserta (`WorkshopFTIPPSI/frontend/src/pages/peserta/peserta.css`): font Plus Jakarta Sans, hijau `#14532D` dengan aksen `#228B45` dan tint `#EDF7EF`, garis `#DFE6E1`, sudut 8 px, pil status bertitik (hijau/amber/merah/biru/abu), kotak info biru, kartu statistik beranda, kotak tanggal di Kegiatan Saya, serta navigasi empat menu dengan item aktif hijau penuh seperti sidebar web. Pada layar besar, antarmuka dibatasi hingga 430 px seperti referensi. Gambar dan font dibundel sehingga tidak memerlukan jaringan saat ditampilkan.

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

Aplikasi membutuhkan backend `WorkshopFTIPPSI/backend` yang berjalan (lihat README). Masuk memakai akun peserta, misalnya akun demo `peserta@unand.ac.id` / `password123`. Saat dijalankan di Chrome, gunakan `--dart-define=API_BASE_URL=http://localhost:5000/api/v1`.

## Halaman dan interaksi

- Login mahasiswa/peserta umum dan formulir pendaftaran akun.
- Beranda dengan pencarian, filter jenis kegiatan, kartu unggulan, dan daftar kegiatan. Setiap kartu menampilkan label Online (ikon video) untuk kegiatan daring atau nama tempat (ikon lokasi) untuk kegiatan luring sebelum detail dibuka; label juga muncul di Kegiatan Saya dan detail kegiatan. Nama tempat yang panjang dapat membungkus ke baris berikutnya agar tetap terbaca.
- Kegiatan online menampilkan keterangan tautan dibagikan H-1 melalui Kegiatan Saya, tanpa tempat atau ruangan. Kegiatan offline tetap menampilkan lokasi fisik.
- Detail kegiatan dengan informasi pelaksanaan, jadwal per hari, narasumber, manfaat, kuota, serta dialog konfirmasi dan hasil pendaftaran. Kegiatan dapat berlangsung beberapa hari.
- Kegiatan Saya dengan tab Akan Datang, Berlangsung, dan Selesai.
- Presensi dicatat terpisah untuk setiap hari kegiatan. Kegiatan offline memakai pemindai QR kamera atau kode manual dari panitia (plus lokasi GPS bila kegiatan memiliki titik lokasi); kegiatan online mengunggah screenshot PNG/JPG maksimal 2 MB ke server dengan status Menunggu Verifikasi. Bukti yang ditolak panitia dapat diunggah ulang.
- Coba **Bootcamp Keterampilan Digital** pada Kegiatan Saya → Berlangsung untuk alur online tiga hari. Hari pertama dan kedua masih dibuka panitia; hari ketiga belum dibuka. Workshop Data Science mencontohkan kegiatan offline dua hari.
- Daftar, pratinjau, dan formulir perbaikan sertifikat.
- Notifikasi dengan penanda belum dibaca dan aksi tandai semua dibaca.
- Profil, edit data, konfirmasi keluar, dan akses diagnostik server.

## Data contoh dan integrasi

Seluruh data berasal dari backend `WorkshopFTIPPSI/backend` melalui `lib/core/data/participant_store.dart` (Riverpod). Login menyimpan token JWT di secure storage; pendaftaran, presensi, perbaikan sertifikat, profil, dan notifikasi disimpan di server sehingga terlihat juga di portal web. Tanggal sesi presensi mengikuti `attendanceDate` dari server.

Plus Jakarta Sans (font yang sama dengan web) dimuat dari aset lokal dengan lisensi OFL di `assets/fonts/OFL.txt`; foto memakai aset Unsplash yang sama dengan referensi. Logo UNAND memakai gambar yang diberikan pengguna di `assets/images/unand-logo.png`, termasuk logo header, pratinjau sertifikat, dan ikon browser.

## Pemeriksaan

```powershell
flutter test
```

Pengujian memakai server tiruan di level HTTP (`test/support/fake_backend.dart`) yang meniru respons backend asli, dan mencakup login/penolakan akun non-peserta, registrasi, validasi formulir, pencarian/filter, pembatalan dan konfirmasi pendaftaran, larangan duplikasi/kuota penuh, navigasi, perubahan profil, notifikasi, presensi, pengajuan koreksi, logout, serta tata letak 320 px dan pembesaran teks.
